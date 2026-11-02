# EpicSports — Deployment Guide

> Full-stack deployment reference for the **EpicSports** platform.
> Stack: React (Vite) frontend + Java Spring Boot backend + SQL database.

---

## Table of Contents

1. [Pre-Deployment Checklist](#1-pre-deployment-checklist)
2. [Production Configuration](#2-production-configuration)
3. [Option A — Deploy on a Single VPS / Cloud VM](#option-a--deploy-on-a-single-vps--cloud-vm-recommended)
4. [Option B — Railway (Backend) + Vercel (Frontend)](#option-b--railway-backend--vercel-frontend)
5. [Option C — Render (Backend) + Netlify (Frontend)](#option-c--render-backend--netlify-frontend)
6. [Option D — Docker Compose (Self-Hosted)](#option-d--docker-compose-self-hosted)
7. [Database: Switch from H2 to MySQL / PostgreSQL](#5-database-switch-from-h2-to-mysql--postgresql)
8. [Environment Variables Reference](#6-environment-variables-reference)
9. [SSL & Custom Domain](#7-ssl--custom-domain)
10. [Troubleshooting](#8-troubleshooting)

---

## 1. Pre-Deployment Checklist

Before deploying, complete these steps:

- [ ] Change the JWT secret to a long random string (min 64 chars)
- [ ] Switch the database from H2 to MySQL or PostgreSQL
- [ ] Set `spring.jpa.hibernate.ddl-auto=validate` (not `update`) in production
- [ ] Disable the H2 console (`spring.h2.console.enabled=false`)
- [ ] Set CORS to allow only your frontend domain
- [ ] Build the React frontend (`npm run build`)
- [ ] Make sure Java 17+ is installed on the server

---

## 2. Production Configuration

### 2a. Backend — `application-prod.properties`

Create this file at:
`epicsports-backend/src/main/resources/application-prod.properties`

```properties
# -----------------------------------------------
# PRODUCTION Spring Boot Configuration
# -----------------------------------------------

# Server
server.port=${PORT:8080}

# PostgreSQL (recommended for production)
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DATABASE_USERNAME}
spring.datasource.password=${DATABASE_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Disable H2 console in production
spring.h2.console.enabled=false

# JWT (use a strong 64+ char secret)
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

# Serve React build files
spring.web.resources.static-locations=classpath:/static/

# Logging
logging.level.root=WARN
logging.level.com.epicsports=INFO
```

### 2b. Backend — Add PostgreSQL driver to `pom.xml`

Add this dependency inside `<dependencies>` in
[`epicsports-backend/pom.xml`](file:///d:/project/epicsports-backend/pom.xml):

```xml
<!-- PostgreSQL Driver (for production) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### 2c. Backend — Update CORS for production

In [`SecurityConfig.java`](file:///d:/project/epicsports-backend/src/main/java/com/epicsports/security/SecurityConfig.java),
update the CORS origin to your actual frontend URL:

```java
// Replace this:
configuration.setAllowedOriginPatterns(List.of("*"));

// With this:
configuration.setAllowedOriginPatterns(List.of(
    "https://your-frontend-domain.com",
    "http://localhost:3000"  // keep for local dev
));
```

### 2d. Frontend — Update `vite.config.js` for production build

The build is already configured to output to the Spring Boot static folder.
To deploy frontend + backend as **one JAR**, run:

```bash
# Step 1: build React into Spring Boot's static directory
cd epicsports-frontend
npm run build

# Step 2: build the Spring Boot JAR (it will include the React build)
cd ../epicsports-backend
./mvnw clean package -Pprod -DskipTests
```

The resulting JAR at `target/epicsports-backend-0.0.1-SNAPSHOT.jar`
serves both the API and the React frontend on port 8080.

---

## Option A — Deploy on a Single VPS / Cloud VM (Recommended)

Best for: **AWS EC2, DigitalOcean Droplet, Azure VM, Google Compute Engine**

### Requirements
- Ubuntu 22.04 LTS (or similar)
- Java 17+
- PostgreSQL 15+
- Nginx (reverse proxy)

---

### Step 1: Provision Server

```bash
# Connect to your server
ssh ubuntu@YOUR_SERVER_IP

# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 17
sudo apt install -y openjdk-17-jdk
java -version   # should show 17.x

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Step 2: Set Up PostgreSQL Database

```bash
# Switch to postgres user
sudo -u postgres psql

# Inside psql shell:
CREATE DATABASE epicsportsdb;
CREATE USER epicsports_user WITH ENCRYPTED PASSWORD 'YourStrongPassword123!';
GRANT ALL PRIVILEGES ON DATABASE epicsportsdb TO epicsports_user;
\q
```

### Step 3: Build the Application Locally

On your **local machine** (Windows):

```powershell
# 1. Build the React frontend
cd d:\project\epicsports-frontend
npm run build

# 2. Package the Spring Boot JAR
cd d:\project\epicsports-backend
./mvnw.cmd clean package -DskipTests
```

This creates: `epicsports-backend/target/epicsports-backend-0.0.1-SNAPSHOT.jar`

### Step 4: Upload the JAR to Server

```bash
# From your local machine:
scp d:\project\epicsports-backend\target\epicsports-backend-0.0.1-SNAPSHOT.jar \
    ubuntu@YOUR_SERVER_IP:/home/ubuntu/epicsports/app.jar
```

### Step 5: Configure Environment Variables

```bash
# On the server, create an env file
sudo mkdir -p /etc/epicsports
sudo nano /etc/epicsports/env

# Paste these (replace values with your own):
DATABASE_URL=jdbc:postgresql://localhost:5432/epicsportsdb
DATABASE_USERNAME=epicsports_user
DATABASE_PASSWORD=YourStrongPassword123!
JWT_SECRET=ReplaceThisWithA64CharRandomStringForExampleAbCdEfGhIjKlMnOpQrStUvWxYz1234
PORT=8080

# Save and exit (Ctrl+X, Y, Enter)
sudo chmod 600 /etc/epicsports/env
```

### Step 6: Create a systemd Service

```bash
sudo nano /etc/systemd/system/epicsports.service
```

Paste:

```ini
[Unit]
Description=EpicSports Spring Boot Application
After=network.target postgresql.service

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/epicsports
EnvironmentFile=/etc/epicsports/env
ExecStart=/usr/bin/java \
  -Dspring.profiles.active=prod \
  -jar /home/ubuntu/epicsports/app.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable epicsports
sudo systemctl start epicsports

# Check status
sudo systemctl status epicsports

# View live logs
sudo journalctl -u epicsports -f
```

### Step 7: Configure Nginx as Reverse Proxy

```bash
sudo apt install -y nginx

sudo nano /etc/nginx/sites-available/epicsports
```

Paste:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    gzip_min_length 1000;
}
```

```bash
sudo ln -s /etc/nginx/sites-available/epicsports /etc/nginx/sites-enabled/
sudo nginx -t        # test config
sudo systemctl restart nginx
sudo systemctl enable nginx
```

Your app is now live at **http://your-domain.com** !

### Step 8: Add Free SSL with Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renew (already configured, verify with):
sudo certbot renew --dry-run
```

After this, your app runs at **https://your-domain.com** with auto-renewing SSL.

---

## Option B — Railway (Backend) + Vercel (Frontend)

Best for: **Fastest free-tier cloud deployment, no server management**

---

### Backend → Railway

1. Go to [railway.app](https://railway.app) and sign up with GitHub.

2. Click **New Project → Deploy from GitHub repo**.

3. Select your repository and the `epicsports-backend` folder.

4. Railway auto-detects Spring Boot. Add a **PostgreSQL** plugin:
   - Click **+ New** → **Database** → **PostgreSQL**
   - Railway auto-injects `DATABASE_URL`

5. Set these environment variables in Railway dashboard:

   | Variable | Value |
   |----------|-------|
   | `SPRING_PROFILES_ACTIVE` | `prod` |
   | `JWT_SECRET` | *(64-char random string)* |
   | `DATABASE_URL` | *(auto-set by Railway PostgreSQL)* |
   | `DATABASE_USERNAME` | *(auto-set)* |
   | `DATABASE_PASSWORD` | *(auto-set)* |

6. Set the **Start Command** in Railway settings:
   ```
   java -Dspring.profiles.active=prod -jar target/epicsports-backend-0.0.1-SNAPSHOT.jar
   ```

7. Railway gives you a public URL like:
   `https://epicsports-backend-production.up.railway.app`

---

### Frontend → Vercel

1. First, update [`vite.config.js`](file:///d:/project/epicsports-frontend/vite.config.js)
   to remove the `build.outDir` override (Vercel handles its own build):

   ```js
   build: {
     outDir: 'dist',  // back to default
   }
   ```

2. Create `epicsports-frontend/vercel.json`:

   ```json
   {
     "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }],
     "headers": [
       {
         "source": "/assets/(.*)",
         "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
       }
     ]
   }
   ```

3. Create `epicsports-frontend/.env.production`:

   ```env
   VITE_API_BASE_URL=https://epicsports-backend-production.up.railway.app/api
   ```

4. Update [`src/api/client.js`](file:///d:/project/epicsports-frontend/src/api/client.js)
   to use the env variable:

   ```js
   const api = axios.create({
     baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
   });
   ```

5. Push to GitHub, then go to [vercel.com](https://vercel.com):
   - **New Project** → import your GitHub repo
   - Set **Root Directory** to `epicsports-frontend`
   - Add env variable: `VITE_API_BASE_URL` = your Railway backend URL
   - Click **Deploy**

6. Vercel gives you: `https://epicsports-frontend.vercel.app`

---

## Option C — Render (Backend) + Netlify (Frontend)

Best for: **Free-tier with persistent disk storage**

---

### Backend → Render

1. Go to [render.com](https://render.com) and create a **New Web Service**.

2. Connect your GitHub repo, set **Root Directory** to `epicsports-backend`.

3. Settings:
   - **Environment**: `Java`
   - **Build Command**: `./mvnw clean package -DskipTests`
   - **Start Command**: `java -Dspring.profiles.active=prod -jar target/epicsports-backend-0.0.1-SNAPSHOT.jar`

4. Create a **PostgreSQL** database on Render (free tier available).
   Copy the connection string.

5. Add Environment Variables:
   ```
   SPRING_PROFILES_ACTIVE=prod
   DATABASE_URL=<your render postgres URL>
   DATABASE_USERNAME=<from render>
   DATABASE_PASSWORD=<from render>
   JWT_SECRET=<64 char secret>
   ```

6. Deploy → Render gives you: `https://epicsports-backend.onrender.com`

---

### Frontend → Netlify

1. Go to [netlify.com](https://netlify.com) → **Add new site** → **Import from Git**.

2. Set **Base directory**: `epicsports-frontend`
   **Build command**: `npm run build`
   **Publish directory**: `epicsports-frontend/dist`

3. Add env variable: `VITE_API_BASE_URL=https://epicsports-backend.onrender.com/api`

4. Create `epicsports-frontend/public/_redirects`:
   ```
   /*  /index.html  200
   ```
   This fixes React Router on page refresh.

5. Deploy → Netlify gives you: `https://epicsports.netlify.app`

---

## Option D — Docker Compose (Self-Hosted)

Best for: **Full control, reproducible environments**

---

### Create `Dockerfile` for Backend

Create `epicsports-backend/Dockerfile`:

```dockerfile
# --- Build Stage ---
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# --- Runtime Stage ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/epicsports-backend-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-Dspring.profiles.active=prod", "-jar", "app.jar"]
```

### Create `Dockerfile` for Frontend

Create `epicsports-frontend/Dockerfile`:

```dockerfile
# --- Build Stage ---
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- Serve Stage ---
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Create `epicsports-frontend/nginx.conf`

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
}
```

### Create `docker-compose.yml` (at project root)

Create `d:\project\docker-compose.yml`:

```yaml
version: '3.9'

services:

  postgres:
    image: postgres:15-alpine
    container_name: epicsports_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: epicsportsdb
      POSTGRES_USER: epicsports_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U epicsports_user -d epicsportsdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: ./epicsports-backend
    container_name: epicsports_backend
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: jdbc:postgresql://postgres:5432/epicsportsdb
      DATABASE_USERNAME: epicsports_user
      DATABASE_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      SPRING_PROFILES_ACTIVE: prod
    ports:
      - "8080:8080"

  frontend:
    build: ./epicsports-frontend
    container_name: epicsports_frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "80:80"
      - "443:443"

volumes:
  postgres_data:
```

### Create `.env` file (project root)

```bash
# d:\project\.env  (DO NOT commit this to Git!)
DB_PASSWORD=YourStrongPassword123!
JWT_SECRET=ReplaceThisWithA64CharRandomStringAbCdEfGhIjKlMnOpQrStUvWxYz12345678
```

### Run with Docker Compose

```bash
# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop everything
docker-compose down

# Stop and remove volumes (wipes database!)
docker-compose down -v
```

App is live at **http://localhost** (port 80).

---

## 5. Database: Switch from H2 to MySQL / PostgreSQL

The app currently uses **H2 (in-memory)** — data is lost on restart.
For production, switch to a persistent database.

### PostgreSQL (Recommended)

Add to `pom.xml`:
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

In `application-prod.properties`:
```properties
spring.datasource.url=jdbc:postgresql://HOST:5432/epicsportsdb
spring.datasource.username=epicsports_user
spring.datasource.password=YourPassword
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

### MySQL

Add to `pom.xml`:
```xml
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <scope>runtime</scope>
</dependency>
```

In `application-prod.properties`:
```properties
spring.datasource.url=jdbc:mysql://HOST:3306/epicsportsdb?useSSL=true&serverTimezone=UTC
spring.datasource.username=epicsports_user
spring.datasource.password=YourPassword
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect
```

---

## 6. Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | Full JDBC connection string | `jdbc:postgresql://...` |
| `DATABASE_USERNAME` | DB username | `epicsports_user` |
| `DATABASE_PASSWORD` | DB password | `StrongPass123!` |
| `JWT_SECRET` | 64+ char secret key for JWT signing | *(random string)* |
| `PORT` | HTTP port (default 8080) | `8080` |
| `SPRING_PROFILES_ACTIVE` | Spring profile to activate | `prod` |
| `VITE_API_BASE_URL` | Frontend: Backend API base URL | `https://api.example.com/api` |

### Generate a secure JWT secret (PowerShell):

```powershell
# Run this on your local machine:
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object { [char]$_ })
```

Or online: [randomkeygen.com](https://randomkeygen.com) → use "CodeIgniter Encryption Keys"

---

## 7. SSL & Custom Domain

### Using Nginx + Let's Encrypt (on VPS)

```bash
# Install certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Certbot auto-configures Nginx for HTTPS
# Test auto-renewal:
sudo certbot renew --dry-run
```

### Using Cloudflare (easiest option)

1. Add your domain to [cloudflare.com](https://cloudflare.com) (free)
2. Point DNS to your server IP
3. Enable **"Full (strict)"** SSL mode in Cloudflare dashboard
4. Cloudflare handles SSL termination automatically

---

## 8. Troubleshooting

### App won't start — port already in use
```bash
# Find and kill process on port 8080
sudo fuser -k 8080/tcp
sudo systemctl restart epicsports
```

### JWT errors after deployment
- Make sure `JWT_SECRET` is exactly the same across all instances
- The secret must be at least 64 characters for HS512
- Verify with: `echo -n "YOUR_SECRET" | wc -c`

### CORS errors in browser
- Update `SecurityConfig.java` to allow your frontend domain
- Rebuild and redeploy the backend JAR

### Database connection refused
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check connection manually
psql -h localhost -U epicsports_user -d epicsportsdb
```

### Spring Boot JAR not found after build
```bash
# Check target directory
ls epicsports-backend/target/*.jar

# If missing, rebuild:
cd epicsports-backend
./mvnw clean package -DskipTests
```

### H2 data lost on restart (dev only)
This is expected — H2 is in-memory. Switch to PostgreSQL/MySQL for persistence.

### React 404 on page refresh (Netlify/Nginx)
- Netlify: Add `public/_redirects` file with `/* /index.html 200`
- Nginx: Add `try_files $uri $uri/ /index.html;` in the location block

---

## Quick Reference

| Task | Command |
|------|---------|
| Build frontend | `cd epicsports-frontend && npm run build` |
| Build backend JAR | `cd epicsports-backend && ./mvnw clean package -DskipTests` |
| Run JAR in prod | `java -Dspring.profiles.active=prod -jar app.jar` |
| Start with Docker | `docker-compose up --build -d` |
| View server logs | `sudo journalctl -u epicsports -f` |
| Restart service | `sudo systemctl restart epicsports` |
| Renew SSL cert | `sudo certbot renew` |

---

*Built with Java Spring Boot 4 + React 18 + Vite*

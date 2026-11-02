# EpicSports — Premium Sports E-Commerce Platform

> Full-stack web application built with **React + Java Spring Boot + JWT Authentication + SQL Database**

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 18, Vite, React Router v6, TanStack Query, Zustand, Axios, Lucide Icons |
| **Backend** | Java Spring Boot 4, Spring Security, Spring Data JPA |
| **Authentication** | JWT (JJWT 0.12.6) — stateless token-based auth |
| **Database** | H2 (dev / in-memory) · PostgreSQL / MySQL (production) |
| **Styling** | Custom CSS — Dark Glassmorphism design system |

---

## Local Development

### Prerequisites

| Tool | Min Version | Download |
|------|-------------|----------|
| Java JDK | 17 | https://adoptium.net |
| Maven | 3.9+ | (bundled via `mvnw`) |
| Node.js | 18+ | https://nodejs.org |

---

### Step 1 — Start the Java Backend

```bash
cd epicsports-backend
./mvnw spring-boot:run
```

> **Windows:** use `mvnw.cmd spring-boot:run`

- API base: **http://localhost:8080/api**
- H2 Console: **http://localhost:8080/h2-console**
  - JDBC URL: `jdbc:h2:mem:epicsportsdb`
  - Username: `sa` | Password: `password`

---

### Step 2 — Start the React Frontend

Open a **new terminal**:

```bash
cd epicsports-frontend
npm install        # first time only
npm run dev
```

- App URL: **http://localhost:3000**
- All `/api/*` calls are proxied to `localhost:8080` automatically

---

## Demo Credentials

| Role | Username | Password | Access |
|------|----------|----------|--------|
| Admin | `admin` | `admin123` | Full access |
| Customer | `john_doe` | `password123` | Shopping, orders |

*(Seeded into the database automatically on startup)*

---

## Features

### Frontend Pages
| Route | Page | Auth Required |
|-------|------|:---:|
| `/` | Homepage — hero, sport categories, featured products | No |
| `/products` | Product catalog with search & filters | No |
| `/login` | JWT login with redirect support | No |
| `/register` | Registration with password strength meter | No |
| `/checkout` | 4-step checkout — cart, shipping, payment, confirm | Yes |
| `/orders` | Order history with real-time status | Yes |
| `/profile` | User profile with order stats | Yes |

### Backend REST API
| Method | Endpoint | Auth |
|--------|----------|------|
| `POST` | `/api/auth/register` | No |
| `POST` | `/api/auth/login` | No |
| `GET` | `/api/auth/me` | Yes |
| `GET` | `/api/products` | No |
| `GET` | `/api/products?category=Footwear` | No |
| `GET` | `/api/products?sport=Soccer` | No |
| `GET` | `/api/products?search=shoe` | No |
| `GET` | `/api/products?featured=true` | No |
| `GET` | `/api/products/{id}` | No |
| `GET` | `/api/products/categories` | No |
| `GET` | `/api/products/sports` | No |
| `POST` | `/api/orders` | Yes |
| `GET` | `/api/orders/my-orders` | Yes |
| `GET` | `/api/orders/{orderNumber}` | Yes |

---

## Project Structure

```
d:\project\
├── epicsports-backend/                    Java Spring Boot
│   ├── src/main/java/com/epicsports/
│   │   ├── EpicsportsApplication.java     Main entry point
│   │   ├── config/DataSeeder.java         Seeds demo data on startup
│   │   ├── controller/
│   │   │   ├── AuthController.java        Login / Register / Me
│   │   │   ├── ProductController.java     Product listing & filters
│   │   │   └── OrderController.java       Place & retrieve orders
│   │   ├── model/
│   │   │   ├── User.java                  JPA entity
│   │   │   ├── Product.java               JPA entity
│   │   │   ├── Order.java                 JPA entity
│   │   │   └── OrderItem.java             JPA entity
│   │   ├── repository/                    Spring Data JPA repos
│   │   ├── security/
│   │   │   ├── SecurityConfig.java        Spring Security + CORS
│   │   │   ├── JwtService.java            Token generation & validation
│   │   │   ├── JwtAuthenticationFilter.java  Request filter
│   │   │   └── UserDetailsServiceImpl.java
│   │   └── dto/                           Request/Response DTOs
│   └── src/main/resources/
│       ├── application.properties         Dev config (H2)
│       └── application-prod.properties    Prod config (PostgreSQL)
│
├── epicsports-frontend/                   React + Vite
│   └── src/
│       ├── api/client.js                  Axios client + JWT interceptors
│       ├── store/
│       │   ├── authStore.js               Zustand: user auth state
│       │   └── cartStore.js               Zustand: cart (persisted)
│       ├── components/
│       │   ├── Navbar.jsx                 Top navigation bar
│       │   ├── CartDrawer.jsx             Slide-in shopping cart
│       │   ├── ProductCard.jsx            Product grid card
│       │   └── ProtectedRoute.jsx         Auth route guard
│       ├── pages/
│       │   ├── HomePage.jsx               Landing page
│       │   ├── ProductsPage.jsx           Catalog + filters
│       │   ├── LoginPage.jsx              Auth
│       │   ├── RegisterPage.jsx           Auth
│       │   ├── CheckoutPage.jsx           Multi-step checkout
│       │   ├── OrdersPage.jsx             Order history
│       │   └── ProfilePage.jsx            User profile
│       ├── App.jsx                        Routes + providers
│       └── App.css                        Full design system CSS
│
├── README.md                              This file
└── DEPLOYMENT.md                          Deployment guide
```

---

## Deployment

See the full deployment guide: **[DEPLOYMENT.md](./DEPLOYMENT.md)**

Quick options:

| Option | Frontend | Backend | Database | Difficulty |
|--------|----------|---------|----------|------------|
| **VPS (Recommended)** | Nginx | systemd JAR | PostgreSQL | Medium |
| **Railway + Vercel** | Vercel | Railway | Railway PG | Easy |
| **Render + Netlify** | Netlify | Render | Render PG | Easy |
| **Docker Compose** | Docker/Nginx | Docker | Docker PG | Medium |

---

## Security Notes

- JWT tokens expire after **24 hours** (configurable)
- Passwords are hashed with **BCrypt**
- All order/profile endpoints require a valid JWT in the `Authorization: Bearer <token>` header
- H2 console is **disabled in production** profile
- Change the `jwt.secret` in `application.properties` before deploying!
# stock-management-retail-inventory-
  stock management system for retail inventory 




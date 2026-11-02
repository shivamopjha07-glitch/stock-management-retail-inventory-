package com.epicsports.config;

import com.epicsports.model.Product;
import com.epicsports.model.User;
import com.epicsports.repository.ProductRepository;
import com.epicsports.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(UserRepository userRepository, ProductRepository productRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.productRepository = productRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        seedUsers();
        seedProducts();
    }

    private void seedUsers() {
        if (userRepository.count() == 0) {
            User admin = new User(
                    "admin",
                    "admin@epicsports.com",
                    passwordEncoder.encode("admin123"),
                    "Epic Sports Administrator",
                    "ROLE_ADMIN"
            );
            userRepository.save(admin);

            User customer = new User(
                    "customer",
                    "customer@epicsports.com",
                    passwordEncoder.encode("customer123"),
                    "Alex Morgan",
                    "ROLE_CUSTOMER"
            );
            userRepository.save(customer);
        }
    }

    private void seedProducts() {
        if (productRepository.count() == 0) {
            List<Product> products = Arrays.asList(
                    new Product("Apex Predator FG Soccer Cleats", "Footwear", "Soccer", 189.99, 4.9, 142, 45, "https://images.unsplash.com/photo-1511886929837-354d827aae26?auto=format&fit=crop&w=600&q=80", "Lightweight synthetic upper with micro-textured grip for explosive ball control and agility.", true),
                    new Product("CourtVision HyperDunk Basketball Shoes", "Footwear", "Basketball", 159.99, 4.8, 98, 38, "https://images.unsplash.com/photo-1579338559194-a162d19bf842?auto=format&fit=crop&w=600&q=80", "High-top responsive foam cushioning with multi-directional herringbone traction outsole.", true),
                    new Product("AeroVelocity Carbon Running Shoes", "Footwear", "Running", 219.99, 4.9, 215, 60, "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80", "Full-length carbon fiber plate propulsion system engineered for marathon pacing and energy return.", true),
                    new Product("Official Match Pro Soccer Ball (Size 5)", "Equipment", "Soccer", 69.99, 4.7, 85, 120, "https://images.unsplash.com/photo-1614632537423-1e6c2e7e0aab?auto=format&fit=crop&w=600&q=80", "FIFA-quality thermally bonded seamless surface for true trajectory and low water absorption.", false),
                    new Product("Indoor/Outdoor Composite Basketball", "Equipment", "Basketball", 49.99, 4.8, 178, 85, "https://images.unsplash.com/photo-1519861531473-9200262188bf?auto=format&fit=crop&w=600&q=80", "Moisture-wicking composite microfiber leather with deep channel design for superior fingertip touch.", false),
                    new Product("Dri-Fit Compression Training Long Sleeve", "Apparel", "Fitness", 39.99, 4.6, 64, 75, "https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&w=600&q=80", "Targeted 4-way compression fabric reduces muscle vibration and speeds up workout recovery.", false),
                    new Product("Pro Strike Customized Team Jersey", "Teamwear", "Soccer", 54.99, 4.9, 112, 150, "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=600&q=80", "Fully customizable team jersey with sublimated numbers, names, and team crest options.", true),
                    new Product("Graphite Speed Tennis Racket Pro 300g", "Equipment", "Tennis", 199.99, 4.8, 52, 28, "https://images.unsplash.com/photo-1617083934555-563d77d703e3?auto=format&fit=crop&w=600&q=80", "High-modulus carbon frame engineered for pinpoint accuracy and effortless topspin generation.", false),
                    new Product("Thermal Winter Running Tights", "Apparel", "Running", 64.99, 4.7, 73, 50, "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80", "Brushed fleece interior provides warmth while reflective 360-degree accents keep night runs safe.", false),
                    new Product("Heavy Duty Hex Dumbbell Set (10-30 lbs)", "Equipment", "Fitness", 149.99, 4.9, 134, 20, "https://images.unsplash.com/photo-1586401100295-7a8096fd231a?auto=format&fit=crop&w=600&q=80", "Anti-roll hexagonal rubber coated weights with knurled chrome ergonomic grip handles.", false),
                    new Product("Maple Wood Baseball Bat 33 Inch", "Equipment", "Baseball", 89.99, 4.6, 42, 35, "https://images.unsplash.com/photo-1508344928928-7165b67de128?auto=format&fit=crop&w=600&q=80", "Handcrafted pro-grade hard maple with bone-rubbed barrel finish for maximum pop.", false),
                    new Product("Pro Padded Goalkeeper Gloves with Finger Spines", "Accessories", "Soccer", 59.99, 4.8, 89, 40, "https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?auto=format&fit=crop&w=600&q=80", "4mm German contact latex palm with removable finger-save spines for elite shot stopping.", true)
            );
            productRepository.saveAll(products);
        }
    }
}

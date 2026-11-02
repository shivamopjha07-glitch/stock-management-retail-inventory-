package com.epicsports.controller;

import com.epicsports.dto.ApiResponse;
import com.epicsports.model.Product;
import com.epicsports.repository.ProductRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductRepository productRepository;

    public ProductController(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Product>>> getAllProducts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String sport,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Boolean featured
    ) {
        List<Product> products;

        if (search != null && !search.trim().isEmpty()) {
            products = productRepository.findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(search.trim(), search.trim());
        } else if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("All")) {
            products = productRepository.findByCategoryIgnoreCase(category.trim());
        } else if (sport != null && !sport.trim().isEmpty() && !sport.equalsIgnoreCase("All")) {
            products = productRepository.findBySportIgnoreCase(sport.trim());
        } else if (Boolean.TRUE.equals(featured)) {
            products = productRepository.findByFeaturedTrue();
        } else {
            products = productRepository.findAll();
        }

        return ResponseEntity.ok(new ApiResponse<>(true, "Products retrieved successfully", products));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Product>> getProductById(@PathVariable Long id) {
        return productRepository.findById(id)
                .map(p -> ResponseEntity.ok(new ApiResponse<>(true, "Product found", p)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getCategories() {
        List<String> categories = Arrays.asList("All", "Footwear", "Apparel", "Equipment", "Accessories", "Teamwear");
        return ResponseEntity.ok(new ApiResponse<>(true, "Categories retrieved", categories));
    }

    @GetMapping("/sports")
    public ResponseEntity<ApiResponse<List<String>>> getSports() {
        List<String> sports = Arrays.asList("All", "Soccer", "Basketball", "Running", "Baseball", "Fitness");
        return ResponseEntity.ok(new ApiResponse<>(true, "Sports categories retrieved", sports));
    }
}

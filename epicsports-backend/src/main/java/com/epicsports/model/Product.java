package com.epicsports.model;

import jakarta.persistence.*;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(nullable = false, length = 50)
    private String category; // Footwear, Apparel, Equipment, Accessories, Teamwear

    @Column(nullable = false, length = 50)
    private String sport; // Soccer, Basketball, Running, Tennis, Training

    @Column(nullable = false)
    private Double price;

    @Column(nullable = false)
    private Double rating;

    @Column(name = "review_count")
    private Integer reviewCount;

    @Column(nullable = false)
    private Integer stock;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(length = 1000)
    private String description;

    @Column(name = "is_featured")
    private Boolean featured = false;

    public Product() {}

    public Product(String name, String category, String sport, Double price, Double rating, Integer reviewCount, Integer stock, String imageUrl, String description, Boolean featured) {
        this.name = name;
        this.category = category;
        this.sport = sport;
        this.price = price;
        this.rating = rating;
        this.reviewCount = reviewCount;
        this.stock = stock;
        this.imageUrl = imageUrl;
        this.description = description;
        this.featured = featured;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSport() { return sport; }
    public void setSport(String sport) { this.sport = sport; }

    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { this.reviewCount = reviewCount; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Boolean getFeatured() { return featured; }
    public void setFeatured(Boolean featured) { this.featured = featured; }
}

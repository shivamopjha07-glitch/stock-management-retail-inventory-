package com.epicsports.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    @JsonBackReference
    private Order order;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "unit_price", nullable = false)
    private Double unitPrice;

    @Column(name = "customization_details", length = 300)
    private String customizationDetails; // e.g. "Jersey #10 - PRAJAPATI / Adult L"

    public OrderItem() {}

    public OrderItem(Product product, Integer quantity, Double unitPrice, String customizationDetails) {
        this.product = product;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.customizationDetails = customizationDetails;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }

    public String getCustomizationDetails() { return customizationDetails; }
    public void setCustomizationDetails(String customizationDetails) { this.customizationDetails = customizationDetails; }
}

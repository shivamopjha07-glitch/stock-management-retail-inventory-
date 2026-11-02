package com.epicsports.dto;

public class OrderItemRequest {
    private Long productId;
    private Integer quantity;
    private String customizationDetails;

    public OrderItemRequest() {}

    public OrderItemRequest(Long productId, Integer quantity, String customizationDetails) {
        this.productId = productId;
        this.quantity = quantity;
        this.customizationDetails = customizationDetails;
    }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getCustomizationDetails() { return customizationDetails; }
    public void setCustomizationDetails(String customizationDetails) { this.customizationDetails = customizationDetails; }
}

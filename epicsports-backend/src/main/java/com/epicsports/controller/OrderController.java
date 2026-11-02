package com.epicsports.controller;

import com.epicsports.dto.ApiResponse;
import com.epicsports.dto.OrderItemRequest;
import com.epicsports.dto.OrderRequest;
import com.epicsports.model.Order;
import com.epicsports.model.OrderItem;
import com.epicsports.model.Product;
import com.epicsports.model.User;
import com.epicsports.repository.OrderRepository;
import com.epicsports.repository.ProductRepository;
import com.epicsports.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    public OrderController(OrderRepository orderRepository, ProductRepository productRepository, UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    @PostMapping
    @Transactional
    public ResponseEntity<ApiResponse<Order>> createOrder(@RequestBody OrderRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ApiResponse<>(false, "User must be authenticated to place an order"));
        }

        User user = userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new RuntimeException("Authenticated user not found"));

        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body(new ApiResponse<>(false, "Order must contain at least one item"));
        }

        double totalAmount = 0.0;
        String orderNumber = "ES-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();

        Order order = new Order(
                orderNumber,
                user,
                0.0,
                request.getShippingAddress(),
                request.getPaymentMethod(),
                "PAID",
                "PROCESSING"
        );

        for (OrderItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findById(itemReq.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found: " + itemReq.getProductId()));

            int qty = itemReq.getQuantity() != null && itemReq.getQuantity() > 0 ? itemReq.getQuantity() : 1;
            
            // Deduct stock if available
            if (product.getStock() >= qty) {
                product.setStock(product.getStock() - qty);
                productRepository.save(product);
            }

            double itemTotal = product.getPrice() * qty;
            totalAmount += itemTotal;

            OrderItem orderItem = new OrderItem(
                    product,
                    qty,
                    product.getPrice(),
                    itemReq.getCustomizationDetails()
            );
            order.addItem(orderItem);
        }

        order.setTotalAmount(Math.round(totalAmount * 100.0) / 100.0);
        Order savedOrder = orderRepository.save(order);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(true, "Order placed successfully", savedOrder));
    }

    @GetMapping("/my-orders")
    public ResponseEntity<ApiResponse<List<Order>>> getMyOrders() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ApiResponse<>(false, "Not authenticated"));
        }

        User user = userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new RuntimeException("Authenticated user not found"));

        List<Order> orders = orderRepository.findByUserOrderByCreatedAtDesc(user);
        return ResponseEntity.ok(new ApiResponse<>(true, "Orders retrieved successfully", orders));
    }

    @GetMapping("/{orderNumber}")
    public ResponseEntity<ApiResponse<Order>> getOrderByNumber(@PathVariable String orderNumber) {
        return orderRepository.findByOrderNumber(orderNumber)
                .map(o -> ResponseEntity.ok(new ApiResponse<>(true, "Order details retrieved", o)))
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ApiResponse<>(false, "Order not found")));
    }
}

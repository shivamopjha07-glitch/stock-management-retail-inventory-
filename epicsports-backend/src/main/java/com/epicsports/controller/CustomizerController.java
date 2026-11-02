package com.epicsports.controller;

import com.epicsports.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/customizer")
public class CustomizerController {

    @GetMapping("/templates")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getTemplates() {
        List<Map<String, Object>> templates = new ArrayList<>();

        Map<String, Object> t1 = new HashMap<>();
        t1.put("id", "jersey-soccer-pro");
        t1.put("name", "Epic Striker Pro Soccer Kit");
        t1.put("sport", "Soccer");
        t1.put("basePrice", 49.99);
        t1.put("availableColors", Arrays.asList("#0284c7", "#dc2626", "#16a34a", "#0f172a", "#f8fafc"));
        t1.put("fontStyles", Arrays.asList("Athletic Bold", "Modern Sans", "Classic Varsity"));
        templates.add(t1);

        Map<String, Object> t2 = new HashMap<>();
        t2.put("id", "jersey-basketball-elite");
        t2.put("name", "CourtMaster Elite Basketball Uniform");
        t2.put("sport", "Basketball");
        t2.put("basePrice", 54.99);
        t2.put("availableColors", Arrays.asList("#ea580c", "#7c3aed", "#2563eb", "#1e293b", "#facc15"));
        t2.put("fontStyles", Arrays.asList("NBA Block", "Varsity Outline", "Slam Dunk"));
        templates.add(t2);

        Map<String, Object> t3 = new HashMap<>();
        t3.put("id", "jersey-baseball-pinstripe");
        t3.put("name", "All-Star Classic Pinstripe Baseball Jersey");
        t3.put("sport", "Baseball");
        t3.put("basePrice", 59.99);
        t3.put("availableColors", Arrays.asList("#1e3a8a", "#991b1b", "#065f46", "#334155"));
        t3.put("fontStyles", Arrays.asList("Script Classic", "Vintage Arch", "Block College"));
        templates.add(t3);

        return ResponseEntity.ok(new ApiResponse<>(true, "Uniform templates retrieved", templates));
    }

    @PostMapping("/calculate-quote")
    public ResponseEntity<ApiResponse<Map<String, Object>>> calculateCustomQuote(@RequestBody Map<String, Object> payload) {
        double unitPrice = payload.containsKey("basePrice") ? Double.parseDouble(payload.get("basePrice").toString()) : 49.99;
        int quantity = payload.containsKey("quantity") ? Integer.parseInt(payload.get("quantity").toString()) : 1;

        double discountRate = 0.0;
        String tier = "Standard";

        if (quantity >= 25) {
            discountRate = 0.25; // 25% bulk club discount
            tier = "Varsity Club (25% Off)";
        } else if (quantity >= 10) {
            discountRate = 0.15; // 15% team discount
            tier = "Team Pack (15% Off)";
        } else if (quantity >= 5) {
            discountRate = 0.10; // 10% small group discount
            tier = "Squad Pack (10% Off)";
        }

        double subtotal = unitPrice * quantity;
        double discountAmount = subtotal * discountRate;
        double finalTotal = subtotal - discountAmount;

        Map<String, Object> quote = new HashMap<>();
        quote.put("unitPrice", unitPrice);
        quote.put("quantity", quantity);
        quote.put("discountTier", tier);
        quote.put("discountPercentage", (int)(discountRate * 100));
        quote.put("subtotal", Math.round(subtotal * 100.0) / 100.0);
        quote.put("discountAmount", Math.round(discountAmount * 100.0) / 100.0);
        quote.put("finalTotal", Math.round(finalTotal * 100.0) / 100.0);

        return ResponseEntity.ok(new ApiResponse<>(true, "Team customizer quote calculated", quote));
    }
}

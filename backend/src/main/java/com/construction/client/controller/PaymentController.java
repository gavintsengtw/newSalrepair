package com.construction.client.controller;

import com.construction.client.service.PaymentService;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @GetMapping("/{userId}")
    public List<Map<String, Object>> getPaymentInfo(
            @PathVariable String userId,
            @RequestParam(required = false) String pjnoid,
            @RequestParam(required = false) String unoid) {
        return paymentService.getPaymentInfo(userId, pjnoid, unoid);
    }
}

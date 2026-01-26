package com.construction.client.controller;

import com.construction.client.dto.PaymentInfoDTO;
import com.construction.client.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @GetMapping("/{userId}")
    public PaymentInfoDTO getPaymentInfo(@PathVariable String userId) {
        return paymentService.getPaymentInfo(userId);
    }
}

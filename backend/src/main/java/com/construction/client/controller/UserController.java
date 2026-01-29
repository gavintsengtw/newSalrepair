package com.construction.client.controller;

import com.construction.client.dto.FcmTokenUploadDTO;
import com.construction.client.service.PushTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private PushTokenService pushTokenService;

    @PostMapping("/fcm-token")
    public ResponseEntity<?> updateFcmToken(@RequestBody FcmTokenUploadDTO request, Principal principal) {
        // 從 Spring Security 的 Principal 取得當前登入的使用者帳號
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        String accountId = principal.getName();
        pushTokenService.updateToken(accountId, request.getToken());

        return ResponseEntity.ok().build();
    }
}
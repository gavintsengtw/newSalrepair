package com.construction.client.controller;

import com.construction.client.dto.PushNotificationRequestDTO;
import com.construction.client.entity.PushToken;
import com.construction.client.service.FcmService;
import com.construction.client.service.InboxMessageService;
import com.construction.client.repository.PushTokenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/push")
@CrossOrigin(origins = "*")
public class PushNotificationController {

    @Autowired
    private FcmService fcmService;

    @Autowired
    private InboxMessageService inboxMessageService;

    @Autowired
    private PushTokenRepository pushTokenRepository;

    @PostMapping("/send")
    public ResponseEntity<?> sendNotification(@RequestBody PushNotificationRequestDTO request) {
        if (request.getTargetToken() == null || request.getTargetToken().isEmpty()) {
            return ResponseEntity.badRequest().body("Target token is required");
        }

        String result = fcmService.sendNotification(
                request.getTargetToken(),
                request.getTitle(),
                request.getBody(),
                request.getImage(),
                request.getData());

        // 嘗試儲存訊息到 Inbox
        try {
            // 根據 Token 找出對應的 AccountId
            String accountId = pushTokenRepository.findByFcmToken(request.getTargetToken())
                    .map(PushToken::getAccountId)
                    .orElse(null);

            // 解析 Data 中的 category 與 target_id
            String category = request.getData() != null ? request.getData().getOrDefault("category", "SYSTEM")
                    : "SYSTEM";
            String targetIdStr = request.getData() != null ? request.getData().get("target_id") : null;
            Integer targetId = targetIdStr != null ? Integer.parseInt(targetIdStr) : null;

            if (accountId != null) {
                inboxMessageService.saveMessage(accountId, request.getTargetToken(), category, request.getTitle(),
                        request.getBody(), targetId);
            }
        } catch (Exception e) {
            // 僅記錄錯誤，不影響推播發送結果
            System.err.println("Failed to save inbox message: " + e.getMessage());
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", result);

        if (result.startsWith("Error")) {
            return ResponseEntity.internalServerError().body(response);
        }
        return ResponseEntity.ok(response);
    }
}
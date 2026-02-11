package com.construction.client.controller;

import com.construction.client.dto.NotificationListResponse;
import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import com.construction.client.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public ResponseEntity<NotificationListResponse> getNotifications(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal) {

        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        String accountId = principal.getName();
        Optional<User> userOpt = userRepository.findByAccountid(accountId);

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Long userId = userOpt.get().getUid();
        NotificationListResponse response = notificationService.getUserNotifications(userId, page, size);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        // Ideally verify if the notification belongs to the user
        // But for now we just mark it as read based on ID
        notificationService.markAsRead(id);

        return ResponseEntity.ok().build();
    }
}

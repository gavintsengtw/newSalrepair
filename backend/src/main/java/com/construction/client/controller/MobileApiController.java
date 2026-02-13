package com.construction.client.controller;

import com.construction.client.dto.DeviceRegisterRequest;

import com.construction.client.dto.NotificationListResponse;
import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import com.construction.client.service.DeviceService;
import com.construction.client.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
public class MobileApiController {

    @Autowired
    private DeviceService deviceService;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;

    // --- Device Management ---

    @PostMapping("/api/device/register")
    public ResponseEntity<?> registerDevice(@RequestBody DeviceRegisterRequest request, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        String accountId = principal.getName();
        Optional<User> userOpt = userRepository.findByAccountid(accountId);

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        deviceService.registerDevice(request, userOpt.get().getUid());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/device/logout")
    public ResponseEntity<?> logoutDevice(@RequestBody Map<String, String> request) {
        // Note: Specification says Input is "{ "fcmToken": "..." }"
        // We can use DeviceUnregisterRequest or just Map. Using Map for flexibility as
        // per prompt example.
        String fcmToken = request.get("fcmToken");
        if (fcmToken == null || fcmToken.isEmpty()) {
            // Try to see if it came as DeviceUnregisterRequest structure if Map failed,
            // but here we just expect simple JSON with fcmToken.
            return ResponseEntity.badRequest().body("fcmToken is required");
        }

        deviceService.unregisterDevice(fcmToken);
        return ResponseEntity.ok().build();
    }

    // --- Notification Management ---

    @GetMapping("/api/notifications")
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

    @PutMapping("/api/notifications/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        // Ideally verify if the notification belongs to the user
        notificationService.markAsRead(id);

        return ResponseEntity.ok().build();
    }
}

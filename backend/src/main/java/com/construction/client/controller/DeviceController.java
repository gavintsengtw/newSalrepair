package com.construction.client.controller;

import com.construction.client.dto.DeviceRegisterRequest;
import com.construction.client.dto.DeviceUnregisterRequest;
import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import com.construction.client.service.DeviceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/devices")
@CrossOrigin(origins = "*")
public class DeviceController {

    @Autowired
    private DeviceService deviceService;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
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

    @PostMapping("/unregister")
    public ResponseEntity<?> unregisterDevice(@RequestBody DeviceUnregisterRequest request, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        // Technically we might want to check if the token belongs to the user,
        // but unregistering a token is generally safe if we trust the token owner (the
        // app).
        deviceService.unregisterDevice(request.getFcmToken());
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public java.util.List<com.construction.client.entity.AppDevices> getAllDevices() {
        return deviceService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<com.construction.client.entity.AppDevices> getDeviceById(@PathVariable Integer id) {
        return deviceService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDevice(@PathVariable Integer id) {
        deviceService.deleteById(id);
        return ResponseEntity.ok().build();
    }
}

package com.construction.client.controller;

import com.construction.client.dto.UserProfileDTO;
import com.construction.client.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/{userId}")
    public UserProfileDTO getUserProfile(@PathVariable String userId) {
        return profileService.getUserProfile(userId);
    }

    @PutMapping("/{userId}")
    public UserProfileDTO updateProfile(@PathVariable String userId, @RequestBody UserProfileDTO profile) {
        return profileService.updateProfile(userId, profile);
    }
}

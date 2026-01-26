package com.construction.client.service;

import com.construction.client.dto.UserProfileDTO;
import org.springframework.stereotype.Service;

@Service
public class ProfileService {

    public UserProfileDTO getUserProfile(String userId) {
        // Mock Data
        UserProfileDTO profile = new UserProfileDTO();
        profile.setUserId(userId);
        profile.setName("John Doe");
        profile.setEmail("john.doe@example.com");
        profile.setPhoneNumber("0912345678");
        profile.setContractNumber("CN-2023-001");
        profile.setPushEnabled(true);
        return profile;
    }

    public UserProfileDTO updateProfile(String userId, UserProfileDTO profile) {
        // Mock Logic
        return profile;
    }
}

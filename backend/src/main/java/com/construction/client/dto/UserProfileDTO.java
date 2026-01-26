package com.construction.client.dto;

import lombok.Data;

@Data
public class UserProfileDTO {
    private String userId;
    private String name;
    private String email;
    private String phoneNumber;
    private String contractNumber;
    private boolean pushEnabled;
}

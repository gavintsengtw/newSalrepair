package com.construction.client.dto;

import lombok.Data;

@Data
public class DeviceRegisterRequest {
    private String fcmToken;
    private String deviceType;
    private String deviceModel;
    private String osVersion;
    private String appVersion;
}

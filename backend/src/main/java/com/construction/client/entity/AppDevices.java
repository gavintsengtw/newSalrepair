package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "AppDevices", indexes = {
        @Index(name = "IX_AppDevices_UserID", columnList = "UserID"),
        @Index(name = "IX_AppDevices_FCMToken", columnList = "FCMToken")
})
public class AppDevices {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DeviceID")
    private Integer deviceId;

    @Column(name = "UserID", nullable = false)
    private Long userId;

    @Column(name = "FCMToken", length = 500, nullable = false)
    private String fcmToken;

    @Column(name = "DeviceType", length = 20, nullable = false)
    private String deviceType;

    @Column(name = "DeviceModel", length = 100)
    private String deviceModel;

    @Column(name = "OSVersion", length = 50)
    private String osVersion;

    @Column(name = "AppVersion", length = 20)
    private String appVersion;

    @Column(name = "LastActiveTime")
    private LocalDateTime lastActiveTime;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (lastActiveTime == null) {
            lastActiveTime = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        lastActiveTime = LocalDateTime.now();
    }
}

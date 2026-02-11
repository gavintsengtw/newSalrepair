package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "NotificationSettings")
public class NotificationSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SettingID")
    private Integer settingId;

    @Column(name = "UserID", nullable = false, unique = true)
    private Long userId;

    @Column(name = "EnablePayment")
    private Boolean enablePayment = true;

    @Column(name = "EnableProgress")
    private Boolean enableProgress = true;

    @Column(name = "EnableRepair")
    private Boolean enableRepair = true;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

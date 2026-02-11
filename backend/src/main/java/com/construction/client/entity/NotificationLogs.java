package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "NotificationLogs")
public class NotificationLogs {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private Long logId;

    @Column(name = "UserID", nullable = false)
    private Long userId;

    @Column(name = "UnitID")
    private Integer unitId;

    @Column(name = "Category", length = 50, nullable = false)
    private String category;

    @Column(name = "Title", length = 100, nullable = false)
    private String title;

    @Column(name = "Body", columnDefinition = "NVARCHAR(MAX)", nullable = false)
    private String body;

    @Column(name = "TargetID", length = 50)
    private String targetId;

    @Column(name = "IsRead")
    private Boolean isRead = false;

    @Column(name = "SentTime")
    private LocalDateTime sentTime;

    @Column(name = "ReadTime")
    private LocalDateTime readTime;

    @PrePersist
    protected void onCreate() {
        if (sentTime == null) {
            sentTime = LocalDateTime.now();
        }
    }
}

package com.construction.client.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class NotificationDto {
    private Long id;
    private String category;
    private String title;
    private String body;
    private LocalDateTime sentTime;
    private Boolean isRead;
    private String targetId;
}

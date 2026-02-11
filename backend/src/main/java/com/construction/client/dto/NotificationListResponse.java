package com.construction.client.dto;

import lombok.Data;
import java.util.List;

@Data
public class NotificationListResponse {
    private long unreadCount;
    private List<NotificationDto> data;
}

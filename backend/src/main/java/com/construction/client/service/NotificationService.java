package com.construction.client.service;

import com.construction.client.dto.NotificationDto;
import com.construction.client.dto.NotificationListResponse;
import com.construction.client.entity.AppDevices;
import com.construction.client.entity.NotificationLogs;
import com.construction.client.repository.AppDevicesRepository;
import com.construction.client.repository.NotificationLogsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    @Autowired
    private NotificationLogsRepository notificationLogsRepository;

    @Autowired
    private AppDevicesRepository appDevicesRepository;

    @Autowired
    private FcmService fcmService;

    @Transactional(readOnly = true)
    public NotificationListResponse getUserNotifications(Long userId, int page, int size) {
        Pageable pageable = PageRequest.of(page - 1, size); // Page is 1-indexed in request, 0-indexed in JPA
        Page<NotificationLogs> logsPage = notificationLogsRepository.findByUserIdOrderBySentTimeDesc(userId, pageable);

        long unreadCount = notificationLogsRepository.countByUserIdAndIsReadFalse(userId);

        List<NotificationDto> dtoList = logsPage.getContent().stream().map(log -> {
            NotificationDto dto = new NotificationDto();
            dto.setId(log.getLogId());
            dto.setCategory(log.getCategory());
            dto.setTitle(log.getTitle());
            dto.setBody(log.getBody());
            dto.setSentTime(log.getSentTime());
            dto.setIsRead(log.getIsRead());
            dto.setTargetId(log.getTargetId());
            return dto;
        }).collect(Collectors.toList());

        NotificationListResponse response = new NotificationListResponse();
        response.setUnreadCount(unreadCount);
        response.setData(dtoList);

        return response;
    }

    @Transactional
    public void markAsRead(Long notificationId) {
        notificationLogsRepository.findById(notificationId).ifPresent(log -> {
            if (!Boolean.TRUE.equals(log.getIsRead())) {
                log.setIsRead(true);
                log.setReadTime(LocalDateTime.now());
                notificationLogsRepository.save(log);
            }
        });
    }

    @Transactional
    public void sendNotificationToUser(Long userId, String category, String title, String body, String targetId,
            Integer unitId) {
        // 1. Save Log
        NotificationLogs log = new NotificationLogs();
        log.setUserId(userId);
        log.setCategory(category);
        log.setTitle(title);
        log.setBody(body);
        log.setTargetId(targetId);
        log.setUnitId(unitId);
        log.setIsRead(false);
        log.setSentTime(LocalDateTime.now());
        NotificationLogs savedLog = notificationLogsRepository.save(log);

        // 2. Find User Devices
        List<AppDevices> devices = appDevicesRepository.findByUserId(userId);

        if (devices.isEmpty()) {
            return;
        }

        // 3. Prepare Data Payload
        Map<String, String> data = new HashMap<>();
        data.put("category", category);
        data.put("target_id", targetId != null ? targetId : "");
        data.put("notification_log_id", String.valueOf(savedLog.getLogId()));
        if (unitId != null) {
            data.put("unit_id", String.valueOf(unitId));
        }
        data.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        // 4. Send to each device
        for (AppDevices device : devices) {
            fcmService.sendNotification(
                    device.getFcmToken(),
                    title,
                    body,
                    null, // No image for now
                    data);
        }
    }
}

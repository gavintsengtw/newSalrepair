package com.construction.client.repository;

import com.construction.client.entity.NotificationLogs;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NotificationLogsRepository extends JpaRepository<NotificationLogs, Long> {
    Page<NotificationLogs> findByUserIdOrderBySentTimeDesc(Long userId, Pageable pageable);

    long countByUserIdAndIsReadFalse(Long userId);
}

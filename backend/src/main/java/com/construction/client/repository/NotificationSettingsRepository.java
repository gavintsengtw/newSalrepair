package com.construction.client.repository;

import com.construction.client.entity.NotificationSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NotificationSettingsRepository extends JpaRepository<NotificationSettings, Integer> {
    Optional<NotificationSettings> findByUserId(Long userId);
}

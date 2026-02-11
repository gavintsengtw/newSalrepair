package com.construction.client.repository;

import com.construction.client.entity.AppDevices;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AppDevicesRepository extends JpaRepository<AppDevices, Integer> {
    Optional<AppDevices> findByFcmToken(String fcmToken);

    List<AppDevices> findByUserId(Long userId);

    @Modifying
    void deleteByFcmToken(String fcmToken);

    @Modifying
    void deleteByLastActiveTimeBefore(LocalDateTime cutoff);
}

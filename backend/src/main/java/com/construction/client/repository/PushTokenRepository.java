package com.construction.client.repository;

import com.construction.client.entity.PushToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PushTokenRepository extends JpaRepository<PushToken, Long> {
    Optional<PushToken> findByAccountId(String accountId);

    Optional<PushToken> findByFcmToken(String fcmToken);
}
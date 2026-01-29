package com.construction.client.service;

import com.construction.client.entity.PushToken;
import com.construction.client.repository.PushTokenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class PushTokenService {

    @Autowired
    private PushTokenRepository pushTokenRepository;

    @Transactional
    public void updateToken(String accountId, String token) {
        Optional<PushToken> existing = pushTokenRepository.findByAccountId(accountId);

        PushToken pushToken;
        if (existing.isPresent()) {
            pushToken = existing.get();
        } else {
            pushToken = new PushToken();
            pushToken.setAccountId(accountId);
            // 預設為 Android，若需區分 iOS/Web 可從 Controller 傳入 User-Agent 判斷
            pushToken.setDeviceType("Android");
        }

        pushToken.setFcmToken(token);
        pushToken.setLastUpdated(LocalDateTime.now());

        pushTokenRepository.save(pushToken);
    }
}
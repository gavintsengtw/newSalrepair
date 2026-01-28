package com.construction.client.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class TokenBlacklistService {

    // 建立一個 Cache 來儲存黑名單 Token
    // 設定過期時間為 24 小時 (與 JwtUtil 的 EXPIRATION_TIME 一致或稍長)
    private final Cache<String, Boolean> blacklist = Caffeine.newBuilder()
            .expireAfterWrite(24, TimeUnit.HOURS)
            .build();

    public void addToBlacklist(String token) {
        blacklist.put(token, true);
    }

    public boolean isBlacklisted(String token) {
        return blacklist.getIfPresent(token) != null;
    }
}
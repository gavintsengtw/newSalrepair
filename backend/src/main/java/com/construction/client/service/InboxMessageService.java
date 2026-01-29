package com.construction.client.service;

import com.construction.client.entity.InboxMessage;
import com.construction.client.repository.InboxMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class InboxMessageService {

    @Autowired
    private InboxMessageRepository repository;

    @Transactional
    public InboxMessage saveMessage(String accountId, String fcmToken, String category, String title, String body,
            Integer targetId) {
        InboxMessage message = new InboxMessage();
        message.setAccountId(accountId);
        message.setFcmToken(fcmToken);
        message.setCategory(category);
        message.setTitle(title);
        message.setBody(body);
        message.setTargetId(targetId);
        message.setIsRead(false);
        message.setCreatedAt(LocalDateTime.now());
        return repository.save(message);
    }

    public List<InboxMessage> getMessages(String accountId) {
        return repository.findByAccountIdOrderByCreatedAtDesc(accountId);
    }

    @Transactional
    public void markAsRead(Long nid) {
        repository.findById(nid).ifPresent(msg -> {
            msg.setIsRead(true);
            repository.save(msg);
        });
    }
}
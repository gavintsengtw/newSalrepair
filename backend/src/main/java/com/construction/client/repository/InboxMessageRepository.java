package com.construction.client.repository;

import com.construction.client.entity.InboxMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InboxMessageRepository extends JpaRepository<InboxMessage, Long> {
    List<InboxMessage> findByAccountIdOrderByCreatedAtDesc(String accountId);
}
package com.construction.client.controller;

import com.construction.client.entity.InboxMessage;
import com.construction.client.service.InboxMessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/inbox")
@CrossOrigin(origins = "*")
public class InboxMessageController {

    @Autowired
    private InboxMessageService inboxMessageService;

    @GetMapping
    public ResponseEntity<List<InboxMessage>> getMyMessages(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(inboxMessageService.getMessages(principal.getName()));
    }

    @PutMapping("/{nid}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long nid) {
        inboxMessageService.markAsRead(nid);
        return ResponseEntity.ok().build();
    }
}
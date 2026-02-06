package com.construction.client.controller;

import com.construction.client.service.LineMessageService;
import com.linecorp.bot.webhook.model.Event;
import com.linecorp.bot.webhook.model.MessageEvent;
import com.linecorp.bot.webhook.model.TextMessageContent;
import com.linecorp.bot.spring.boot.handler.annotation.EventMapping;
import com.linecorp.bot.spring.boot.handler.annotation.LineMessageHandler;
import org.springframework.beans.factory.annotation.Autowired;

@LineMessageHandler
public class LineBotController {

    @Autowired
    private LineMessageService lineMessageService;

    @EventMapping
    public void handleTextMessageEvent(MessageEvent event) {
        // System.out.println("event: " + event);
        if (event.message() instanceof TextMessageContent) {
            lineMessageService.handleTextMessage(event);
        }
    }

    @EventMapping
    public void handleDefaultMessageEvent(Event event) {
        // System.out.println("event: " + event);
    }
}

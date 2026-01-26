package com.construction.client.service;

import com.linecorp.bot.messaging.client.MessagingApiClient;
import com.linecorp.bot.messaging.model.ReplyMessageRequest;
import com.linecorp.bot.messaging.model.TextMessage;
import com.linecorp.bot.webhook.model.MessageEvent;
import com.linecorp.bot.webhook.model.TextMessageContent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class LineMessageService {

    @Autowired
    private MessagingApiClient messagingApiClient;

    public void handleTextMessage(MessageEvent event) {
        if (event.message() instanceof TextMessageContent) {
            TextMessageContent message = (TextMessageContent) event.message();
            String originalMessageText = message.text();

            // Echo logic: Reply with the same text
            TextMessage textMessage = new TextMessage(originalMessageText);
            ReplyMessageRequest replyMessageRequest = new ReplyMessageRequest(
                    event.replyToken(),
                    List.of(textMessage),
                    false);

            try {
                messagingApiClient.replyMessage(replyMessageRequest).get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        }
    }
}

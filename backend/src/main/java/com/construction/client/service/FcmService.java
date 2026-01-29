package com.construction.client.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Map;

@Service
public class FcmService {

    // 初始化 Firebase App
    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                // 請確保 firebase-service-account.json 位於專案根目錄或指定路徑
                FileInputStream serviceAccount = new FileInputStream("firebase-service-account.json");

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
                System.out.println("Firebase application has been initialized");
            }
        } catch (IOException e) {
            System.err.println("Firebase initialization failed: " + e.getMessage());
            // 在開發環境若無憑證檔，可選擇不拋出例外以免影響其他功能啟動
        }
    }

    // 發送單一裝置推播
    public String sendNotification(String targetToken, String title, String body, String imageUrl,
            Map<String, String> data) {
        try {
            Notification.Builder notificationBuilder = Notification.builder()
                    .setTitle(title)
                    .setBody(body);

            if (imageUrl != null && !imageUrl.isEmpty()) {
                notificationBuilder.setImage(imageUrl);
            }

            Message.Builder messageBuilder = Message.builder()
                    .setToken(targetToken)
                    .setNotification(notificationBuilder.build());

            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            Message message = messageBuilder.build();

            // 發送訊息
            String response = FirebaseMessaging.getInstance().send(message);
            return "Successfully sent message: " + response;

        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending message: " + e.getMessage();
        }
    }
}
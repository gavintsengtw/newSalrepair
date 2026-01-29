package com.construction.client.dto;

import java.util.Map;

public class PushNotificationRequestDTO {
    private String targetToken; // 接收者的 FCM Token (手機端產生)
    private String title; // 推播標題
    private String body; // 推播內容
    private String image; // (選填) 圖片網址
    private Map<String, String> data; // (選填) 自訂資料，如跳轉路由

    // Getters and Setters
    public String getTargetToken() {
        return targetToken;
    }

    public void setTargetToken(String targetToken) {
        this.targetToken = targetToken;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Map<String, String> getData() {
        return data;
    }

    public void setData(Map<String, String> data) {
        this.data = data;
    }
}
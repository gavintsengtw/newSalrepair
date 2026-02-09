package com.construction.client.service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

@Service
public class PaymentService {

    private final RestTemplate restTemplate;

    public PaymentService() {
        this.restTemplate = new RestTemplate();
    }

    public List<Map<String, Object>> getPaymentInfo(String userId, String pjnoid, String unoid) {
        if (pjnoid == null || pjnoid.isEmpty() || unoid == null || unoid.isEmpty()) {
            // Log warning or throw error
            System.out.println("Warning: pjnoid or unoid is null or empty for payment query");
            return Collections.emptyList();
        }

        String url = String.format(
                "https://bpm.fong-yi.com.tw/servlet/jform?file=fy_wsSAL.pkg&buttonid=getUnoInvList&salStord=%s&salUno=%s&salCno=%s",
                pjnoid, unoid, userId);

        try {
            // Response is expected to be a JSON array of objects
            ResponseEntity<List<Map<String, Object>>> responseEntity = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<Map<String, Object>>>() {
                    });
            List<Map<String, Object>> response = responseEntity.getBody();
            return response != null ? response : Collections.emptyList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}

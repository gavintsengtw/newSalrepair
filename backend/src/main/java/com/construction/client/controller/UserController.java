package com.construction.client.controller;

import com.construction.client.dto.FcmTokenUploadDTO;
import com.construction.client.service.PushTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private PushTokenService pushTokenService;

    @Autowired
    private com.construction.client.repository.SalrepairStoreRepository salrepairStoreRepository;

    @PostMapping("/fcm-token")
    public ResponseEntity<?> updateFcmToken(@RequestBody FcmTokenUploadDTO request, Principal principal) {
        // 從 Spring Security 的 Principal 取得當前登入的使用者帳號
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        String accountId = principal.getName();
        pushTokenService.updateToken(accountId, request.getToken());

        return ResponseEntity.ok().build();
    }

    @Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @GetMapping("/projects")
    public ResponseEntity<?> getUserProjects(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        String accountId = principal.getName();
        java.util.List<com.construction.client.model.SalrepairStore> projects = salrepairStoreRepository
                .findByAccountid(accountId);

        // Populate projectName for each project
        for (com.construction.client.model.SalrepairStore project : projects) {
            try {
                String sql = "SELECT S_NAME FROM STORE WHERE S_PJNO = ?";
                // Note: pjnoid in SalrepairStore seems to correspond to S_PJNO in STORE
                String pjno = project.getPjnoid();

                // Assuming one result or taking the first one
                java.util.List<String> names = jdbcTemplate.query(sql, (rs, rowNum) -> rs.getString("S_NAME"), pjno);

                if (!names.isEmpty()) {
                    project.setProjectName(names.get(0));
                }
            } catch (Exception e) {
                // Log error but continue, leaving projectName as null
                e.printStackTrace();
            }
        }

        return ResponseEntity.ok(projects);
    }
}
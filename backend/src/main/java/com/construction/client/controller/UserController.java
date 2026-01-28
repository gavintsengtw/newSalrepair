package com.construction.client.controller;

import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import com.construction.client.security.JwtUtil;
import com.construction.client.service.TokenBlacklistService;
import com.construction.client.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    /**
     * 處理 Token 換發請求
     * 對應前端 UserProvider._refreshToken()
     * 路徑: POST /api/users/refresh
     */
    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String accountId = request.get("accountid");

        if (accountId != null && !accountId.trim().isEmpty()) {
            // 查詢使用者以取得角色資訊，確保新 Token 包含權限
            java.util.Optional<User> userOpt = userRepository.findByAccountid(accountId);
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                String newToken = jwtUtil.generateToken(user.getAccountid(), user.getRoles());
                Map<String, Object> response = new HashMap<>();
                response.put("message", "Token refreshed successfully");
                response.put("token", newToken);
                response.put("expiry", jwtUtil.extractExpiration(newToken));
                return ResponseEntity.ok(response);
            }
            return ResponseEntity.badRequest().body(Map.of("message", "User not found"));
        }

        return ResponseEntity.badRequest().body("Invalid account ID");
    }

    /**
     * 處理登入請求 (支援前端 LoginPage)
     * 路徑: POST /api/users/login
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        String accountId = request.get("accountid");
        String password = request.get("password");

        if (accountId != null && password != null) {
            User user = userService.login(accountId, password);
            if (user != null) {
                String token = jwtUtil.generateToken(user.getAccountid(), user.getRoles());
                Map<String, Object> response = new HashMap<>();
                response.put("accountid", user.getAccountid());
                response.put("token", token);
                response.put("expiry", jwtUtil.extractExpiration(token));

                // Add new fields to response
                response.put("roles", user.getRoles());
                response.put("pjnoid", user.getPjnoid());
                response.put("isDefaultPassword", user.getIsDefaultPassword());

                return ResponseEntity.ok(response);
            }
        }
        return ResponseEntity.badRequest().body("Invalid credentials");
    }

    /**
     * 處理登出請求
     * 將目前的 Token 加入黑名單，使其立即失效
     * 路徑: POST /api/users/logout
     */
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            tokenBlacklistService.addToBlacklist(token);
            return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
        }
        return ResponseEntity.badRequest().body("No token found");
    }

    /**
     * 變更密碼
     * 路徑: POST /api/users/change-password
     */
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> request) {
        String accountId = request.get("accountid");
        String oldPassword = request.get("oldPassword");
        String newPassword = request.get("newPassword");

        if (accountId == null || oldPassword == null || newPassword == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Missing required fields"));
        }

        if (oldPassword.equals(newPassword)) {
            return ResponseEntity.badRequest().body(Map.of("message", "新密碼不可與舊密碼相同"));
        }

        // 密碼強度驗證: 至少8碼，且包含英文與數字
        if (!newPassword.matches("^(?=.*[A-Za-z])(?=.*\\d).{8,}$")) {
            return ResponseEntity.badRequest().body(Map.of("message", "密碼須包含英文與數字，且長度至少8碼"));
        }

        return userRepository.findByAccountid(accountId).map(user -> {
            if (!user.getPassword().equals(oldPassword)) {
                return ResponseEntity.badRequest().body(Map.of("message", "舊密碼錯誤"));
            }
            user.setPassword(newPassword);
            user.setIsDefaultPassword(false);
            userRepository.save(user);
            return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
        }).orElse(ResponseEntity.badRequest().body(Map.of("message", "User not found")));
    }
}
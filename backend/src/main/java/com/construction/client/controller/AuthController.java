package com.construction.client.controller;

import com.construction.client.model.User;
import com.construction.client.security.JwtUtil;
import com.construction.client.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String accountid = loginRequest.get("accountid");
        String password = loginRequest.get("password");

        if (accountid == null || password == null) {
            return ResponseEntity.badRequest().body("Account and password are required");
        }

        User user = userService.login(accountid, password);

        if (user != null) {
            String token = jwtUtil.generateToken(user.getAccountid(), user.getRoles());
            
            // Build response
            Map<String, Object> response = new HashMap<>();
            response.put("token", token);
            response.put("accountid", user.getAccountid());
            response.put("roles", user.getRoles());
            response.put("pjnoid", user.getPjnoid());
            response.put("isDefaultPassword", user.getIsDefaultPassword());
            
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(401).body("Invalid credentials");
        }
    }
}

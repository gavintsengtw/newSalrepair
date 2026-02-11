package com.construction.client.controller;

import com.construction.client.entity.AppUserRole;
import com.construction.client.service.AppUserRoleService;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/user-roles")
@CrossOrigin(origins = "*")
public class AppUserRoleController {

    @Autowired
    private AppUserRoleService userRoleService;

    @GetMapping
    public List<AppUserRole> getRolesByUser(@RequestParam(required = false) Long userId) {
        if (userId != null) {
            return userRoleService.findByUserId(userId);
        }
        return userRoleService.findAll();
    }

    @Data
    public static class AssignRoleRequest {
        private Long userId;
        private Integer roleId;
    }

    @PostMapping
    public AppUserRole assignRole(@RequestBody AssignRoleRequest request) {
        return userRoleService.assignRoleToUser(
                request.getUserId(),
                request.getRoleId());
    }

    @DeleteMapping("/{userId}/{roleId}")
    public ResponseEntity<?> removeRole(@PathVariable Long userId, @PathVariable Integer roleId) {
        userRoleService.removeRoleFromUser(userId, roleId);
        return ResponseEntity.ok().build();
    }
}

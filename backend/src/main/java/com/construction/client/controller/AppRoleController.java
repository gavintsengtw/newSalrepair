package com.construction.client.controller;

import com.construction.client.entity.AppRole;
import com.construction.client.service.AppRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
@CrossOrigin(origins = "*")
public class AppRoleController {

    @Autowired
    private AppRoleService appRoleService;

    @GetMapping
    public List<AppRole> getAllRoles() {
        return appRoleService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppRole> getRoleById(@PathVariable Integer id) {
        return appRoleService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public AppRole createRole(@RequestBody AppRole role) {
        return appRoleService.create(role);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppRole> updateRole(@PathVariable Integer id, @RequestBody AppRole roleDetails) {
        return ResponseEntity.ok(appRoleService.update(id, roleDetails));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRole(@PathVariable Integer id) {
        appRoleService.delete(id);
        return ResponseEntity.ok().build();
    }
}

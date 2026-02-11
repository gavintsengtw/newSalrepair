package com.construction.client.controller;

import com.construction.client.entity.AppRoleFunctionAccess;
import com.construction.client.service.AppRoleFunctionAccessService;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/role-access")
@CrossOrigin(origins = "*")
public class AppRoleFunctionAccessController {

    @Autowired
    private AppRoleFunctionAccessService accessService;

    @GetMapping
    public List<AppRoleFunctionAccess> getAccessByRole(@RequestParam(required = false) Integer roleId) {
        if (roleId != null) {
            return accessService.findByRoleId(roleId);
        }
        return accessService.findAll();
    }

    @Data
    public static class AssignRequest {
        private Integer roleId;
        private Integer functionId;
        private Boolean canRead;
        private Boolean canEdit;
    }

    @PostMapping
    public AppRoleFunctionAccess assignFunction(@RequestBody AssignRequest request) {
        return accessService.assignFunctionToRole(
                request.getRoleId(),
                request.getFunctionId(),
                request.getCanRead(),
                request.getCanEdit());
    }

    @DeleteMapping("/{roleId}/{functionId}")
    public ResponseEntity<?> removeFunction(@PathVariable Integer roleId, @PathVariable Integer functionId) {
        accessService.removeFunctionFromRole(roleId, functionId);
        return ResponseEntity.ok().build();
    }
}

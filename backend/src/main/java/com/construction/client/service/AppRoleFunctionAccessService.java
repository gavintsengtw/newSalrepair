package com.construction.client.service;

import com.construction.client.entity.AppFunction;
import com.construction.client.entity.AppRole;
import com.construction.client.entity.AppRoleFunctionAccess;
import com.construction.client.entity.AppRoleFunctionAccessId;
import com.construction.client.repository.AppFunctionRepository;
import com.construction.client.repository.AppRoleFunctionAccessRepository;
import com.construction.client.repository.AppRoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AppRoleFunctionAccessService {

    @Autowired
    private AppRoleFunctionAccessRepository accessRepository;

    @Autowired
    private AppRoleRepository roleRepository;

    @Autowired
    private AppFunctionRepository functionRepository;

    public List<AppRoleFunctionAccess> findByRoleId(Integer roleId) {
        return accessRepository.findById_RoleId(roleId);
    }

    @Transactional
    public AppRoleFunctionAccess assignFunctionToRole(Integer roleId, Integer functionId, Boolean canRead,
            Boolean canEdit) {
        AppRole role = roleRepository.findById(roleId)
                .orElseThrow(() -> new RuntimeException("Role not found"));
        AppFunction function = functionRepository.findById(functionId)
                .orElseThrow(() -> new RuntimeException("Function not found"));

        AppRoleFunctionAccessId id = new AppRoleFunctionAccessId(roleId, functionId);
        AppRoleFunctionAccess access = new AppRoleFunctionAccess();
        access.setId(id);
        access.setRole(role);
        access.setFunction(function);
        access.setCanRead(canRead);
        access.setCanEdit(canEdit);

        return accessRepository.save(access);
    }

    @Transactional
    public void removeFunctionFromRole(Integer roleId, Integer functionId) {
        AppRoleFunctionAccessId id = new AppRoleFunctionAccessId(roleId, functionId);
        accessRepository.deleteById(id);
    }

    public List<AppRoleFunctionAccess> findAll() {
        return accessRepository.findAll();
    }
}

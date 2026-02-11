package com.construction.client.service;

import com.construction.client.entity.AppRole;
import com.construction.client.repository.AppRoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AppRoleService {

    @Autowired
    private AppRoleRepository appRoleRepository;

    public List<AppRole> findAll() {
        return appRoleRepository.findAll();
    }

    public Optional<AppRole> findById(Integer id) {
        return appRoleRepository.findById(id);
    }

    public AppRole create(AppRole role) {
        return appRoleRepository.save(role);
    }

    public AppRole update(Integer id, AppRole details) {
        return appRoleRepository.findById(id).map(role -> {
            role.setRoleName(details.getRoleName());
            role.setDescription(details.getDescription());
            return appRoleRepository.save(role);
        }).orElseThrow(() -> new RuntimeException("Role not found with id " + id));
    }

    public void delete(Integer id) {
        appRoleRepository.deleteById(id);
    }
}

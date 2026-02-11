package com.construction.client.service;

import com.construction.client.entity.AppRole;
import com.construction.client.entity.AppUserRole;
import com.construction.client.entity.AppUserRoleId;
import com.construction.client.model.User;
import com.construction.client.repository.AppRoleRepository;
import com.construction.client.repository.AppUserRoleRepository;
import com.construction.client.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AppUserRoleService {

    @Autowired
    private AppUserRoleRepository userRoleRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AppRoleRepository roleRepository;

    public List<AppUserRole> findByUserId(Long userId) {
        // Depending on repository implementation, one of these should work
        // Ideally we should check AppUserRoleRepository to confirm method name
        return userRoleRepository.findByUser_Uid(userId);
    }

    @Transactional
    public AppUserRole assignRoleToUser(Long userId, Integer roleId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        AppRole role = roleRepository.findById(roleId)
                .orElseThrow(() -> new RuntimeException("Role not found"));

        AppUserRoleId id = new AppUserRoleId(userId, roleId);
        AppUserRole userRole = new AppUserRole();
        userRole.setId(id);
        userRole.setUser(user);
        userRole.setRole(role);

        return userRoleRepository.save(userRole);
    }

    @Transactional
    public void removeRoleFromUser(Long userId, Integer roleId) {
        AppUserRoleId id = new AppUserRoleId(userId, roleId);
        userRoleRepository.deleteById(id);
    }

    public List<AppUserRole> findAll() {
        List<AppUserRole> allRoles = userRoleRepository.findAll();
        // remove orphaned roles where user or role is null
        allRoles.removeIf(ur -> ur.getUser() == null || ur.getRole() == null);
        return allRoles;
    }

}

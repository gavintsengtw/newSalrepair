package com.construction.client.service;

import com.construction.client.dto.MenuDto;
import com.construction.client.entity.AppRoleFunctionAccess;
import com.construction.client.entity.AppUserRole;
import com.construction.client.repository.AppRoleFunctionAccessRepository;
import com.construction.client.repository.AppUserRoleRepository;
import com.construction.client.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MenuService {

        private final AppUserRoleRepository userRoleRepository;
        private final AppRoleFunctionAccessRepository roleFunctionAccessRepository;
        private final UserRepository userRepository;

        @Autowired
        public MenuService(AppUserRoleRepository userRoleRepository,
                        AppRoleFunctionAccessRepository roleFunctionAccessRepository,
                        UserRepository userRepository) {
                this.userRoleRepository = userRoleRepository;
                this.roleFunctionAccessRepository = roleFunctionAccessRepository;
                this.userRepository = userRepository;
        }

        public List<MenuDto> getUserMenus(String accountId) {
                System.out.println("getUserMenus called for accountId: " + accountId);

                return userRepository.findByAccountid(accountId).map(user -> {
                        Long userId = user.getUid();

                        // 2. Get User Roles
                        List<AppUserRole> userRoles = userRoleRepository.findByUser_Uid(userId);
                        List<Integer> roleIds = userRoles.stream()
                                        .map(ur -> ur.getRole().getRoleId())
                                        .collect(Collectors.toList());

                        if (roleIds.isEmpty()) {
                                return new java.util.ArrayList<MenuDto>();
                        }

                        // 3. Get Role Functions (CanRead = true)
                        List<AppRoleFunctionAccess> accesses = roleFunctionAccessRepository
                                        .findByRole_RoleIdInAndCanReadTrue(roleIds);

                        // 4. Map to DTOs first (keeping a reference to ParentID for structure building)
                        // Use a wrapper or map to hold DTOs by ID
                        java.util.Map<Integer, MenuDto> dtoMap = new java.util.HashMap<>();
                        java.util.Map<Integer, Integer> parentMap = new java.util.HashMap<>();

                        accesses.stream()
                                        .map(AppRoleFunctionAccess::getFunction)
                                        .filter(func -> func.getIsActive() != null && func.getIsActive())
                                        .distinct()
                                        .forEach(func -> {
                                                MenuDto dto = new MenuDto(
                                                                func.getFunctionId(),
                                                                func.getFunctionName(),
                                                                func.getFunctionCode(),
                                                                func.getIconKey(),
                                                                func.getRoutePath(),
                                                                func.getSortOrder() != null ? func.getSortOrder() : 0);
                                                dtoMap.put(dto.getId(), dto);
                                                if (func.getParentId() != null) {
                                                        parentMap.put(dto.getId(), func.getParentId());
                                                }
                                        });

                        // 5. Build Tree Structure
                        List<MenuDto> rootMenus = new java.util.ArrayList<>();

                        for (MenuDto dto : dtoMap.values()) {
                                Integer parentId = parentMap.get(dto.getId());
                                if (parentId != null) {
                                        MenuDto parent = dtoMap.get(parentId);
                                        if (parent != null) {
                                                parent.getChildren().add(dto);
                                        } else {
                                                // Parent not accessible or found, maybe treat as root?
                                                // For now, if parent not found, we skip or add to root if robust
                                                // behavior needed.
                                                // Let's add to root to be safe if parent is missing from access.
                                                rootMenus.add(dto);
                                        }
                                } else {
                                        rootMenus.add(dto);
                                }
                        }

                        // 6. Sort
                        // Sort roots
                        rootMenus.sort(Comparator.comparingInt(MenuDto::getOrder));

                        // Sort children recursively
                        for (MenuDto root : rootMenus) {
                                sortChildren(root);
                        }

                        System.out.println("Returning hierarchical menus count: " + rootMenus.size());
                        return rootMenus;
                }).orElseGet(() -> {
                        System.out.println("User not found for accountId: " + accountId);
                        return List.of();
                });
        }

        private void sortChildren(MenuDto menu) {
                if (menu.getChildren() != null && !menu.getChildren().isEmpty()) {
                        menu.getChildren().sort(Comparator.comparingInt(MenuDto::getOrder));
                        for (MenuDto child : menu.getChildren()) {
                                sortChildren(child);
                        }
                }
        }
}

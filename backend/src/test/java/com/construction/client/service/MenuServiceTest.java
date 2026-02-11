package com.construction.client.service;

import com.construction.client.dto.MenuDto;
import com.construction.client.entity.AppFunction;
import com.construction.client.entity.AppRole;
import com.construction.client.entity.AppRoleFunctionAccess;
import com.construction.client.entity.AppUserRole;
import com.construction.client.model.User;
import com.construction.client.repository.AppRoleFunctionAccessRepository;
import com.construction.client.repository.AppUserRoleRepository;
import com.construction.client.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyList;

import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MenuServiceTest {

    @Mock
    private AppUserRoleRepository userRoleRepository;

    @Mock
    private AppRoleFunctionAccessRepository roleFunctionAccessRepository;

    @Mock
    private UserRepository userRepository;

    private MenuService menuService;

    @BeforeEach
    void setUp() {
        menuService = new MenuService(userRoleRepository, roleFunctionAccessRepository, userRepository);
    }

    @Test
    void testGetUserMenus_A33_ReturnsExpectedFunctions() {
        // 1. Mock User
        String accountId = "A33@06-A7";
        Long userId = 1L;
        User user = new User();
        user.setUid(userId);
        user.setAccountid(accountId);

        when(userRepository.findByAccountid(accountId)).thenReturn(Optional.of(user));

        // 2. Mock User Roles
        AppRole role = new AppRole();
        role.setRoleId(101);
        role.setRoleName("一般住戶");

        AppUserRole userRole = new AppUserRole();
        userRole.setUser(user);
        userRole.setRole(role);

        when(userRoleRepository.findByUser_Uid(userId)).thenReturn(List.of(userRole));

        // 3. Mock Functions and Access
        // Creating functions based on the user's SQL result
        List<AppFunction> functions = Arrays.asList(
                createFunction(1, "基本資料", "PROFILE_INFO", 10),
                createFunction(2, "修改密碼", "CHANGE_PWD", 20),
                createFunction(3, "推播設定", "NOTIFY_SETTING", 30),
                createFunction(4, "切換案場", "SWITCH_PROJECT", 40),
                createFunction(5, "工程進度", "PROGRESS", 50),
                createFunction(6, "繳款查詢", "PAYMENT", 60),
                createFunction(7, "會員中心", "PROFILE", 70),
                createFunction(8, "登出", "LOGOUT", 80));

        // Create Access objects (CanRead = true)
        List<AppRoleFunctionAccess> accesses = functions.stream()
                .map(func -> {
                    AppRoleFunctionAccess access = new AppRoleFunctionAccess();
                    access.setRole(role);
                    access.setFunction(func);
                    access.setCanRead(true);
                    return access;
                }).toList();

        // Also add a function that is NOT active or NOT readable to verify filtering if
        // needed?
        // The requirements say: IsActive=1 AND CanRead=1.
        // MenuService.getUserMenus calls findByRole_RoleIdInAndCanReadTrue, so
        // repository does CanRead filtering.
        // It also does .filter(func -> func.getIsActive() ... ) in stream.

        // Let's add an inactive function to verify it's filtered out by service code
        AppFunction inactiveFunc = createFunction(9, "InactiveFunc", "INACTIVE", 90);
        inactiveFunc.setIsActive(false);
        AppRoleFunctionAccess inactiveAccess = new AppRoleFunctionAccess();
        inactiveAccess.setFunction(inactiveFunc);
        inactiveAccess.setCanRead(true);

        // The repository mock needs to return all these
        List<AppRoleFunctionAccess> allAccesses = new java.util.ArrayList<>(accesses);
        allAccesses.add(inactiveAccess);

        when(roleFunctionAccessRepository.findByRole_RoleIdInAndCanReadTrue(anyList())).thenReturn(allAccesses);

        // 4. Execute
        List<MenuDto> result = menuService.getUserMenus(accountId);

        // 5. Verify
        assertEquals(8, result.size());
        assertEquals("基本資料", result.get(0).getName());
        assertEquals("修改密碼", result.get(1).getName());
        assertEquals("推播設定", result.get(2).getName());
        assertEquals("切換案場", result.get(3).getName());
        assertEquals("工程進度", result.get(4).getName());
        assertEquals("繳款查詢", result.get(5).getName());
        assertEquals("會員中心", result.get(6).getName());
        assertEquals("登出", result.get(7).getName());
    }

    private AppFunction createFunction(Integer id, String name, String code, Integer sortOrder) {
        AppFunction f = new AppFunction();
        f.setFunctionId(id);
        f.setFunctionName(name);
        f.setFunctionCode(code);
        f.setSortOrder(sortOrder);
        f.setIsActive(true); // Default to active
        return f;
    }
}

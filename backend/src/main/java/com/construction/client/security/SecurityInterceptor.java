package com.construction.client.security;

import com.construction.client.dto.MenuDto;
import com.construction.client.service.MenuService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class SecurityInterceptor implements HandlerInterceptor {

    private final MenuService menuService;

    // Define protected paths and their required function codes
    // In a real scenario, this mapping could also be dynamic/DB-driven
    private static final Map<String, String> PATH_TO_FUNCTION_CODE = Map.of(
            "/api/progress", "PROGRESS",
            "/api/payment", "PAYMENT",
            "/api/repair", "REPAIR"
    // Add more mappings as needed
    );

    @Autowired
    public SecurityInterceptor(MenuService menuService) {
        this.menuService = menuService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        String path = request.getRequestURI();

        // Find which function code protects this path
        String requiredFunctionCode = PATH_TO_FUNCTION_CODE.entrySet().stream()
                .filter(entry -> path.startsWith(entry.getKey()))
                .map(Map.Entry::getValue)
                .findFirst()
                .orElse(null);

        if (requiredFunctionCode == null) {
            return true; // Public or checks not handled here (e.g., standard authenticated endpoints)
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return false;
        }

        String accountId = auth.getName();
        List<MenuDto> allowedMenus = menuService.getUserMenus(accountId);
        Set<String> allowedCodes = allowedMenus.stream()
                .map(MenuDto::getCode)
                .collect(Collectors.toSet());

        if (!allowedCodes.contains(requiredFunctionCode)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: You do not have permission for this resource.");
            return false;
        }

        return true;
    }
}

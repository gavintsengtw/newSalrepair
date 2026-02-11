package com.construction.client.controller;

import com.construction.client.dto.MenuDto;
import com.construction.client.service.MenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/user")
@org.springframework.web.bind.annotation.CrossOrigin(origins = "*")
public class MenuController {

    private final MenuService menuService;

    @Autowired
    public MenuController(MenuService menuService) {
        this.menuService = menuService;
    }

    @GetMapping("/menus")
    public ResponseEntity<Map<String, Object>> getUserMenus() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String accountId = auth.getName(); // Assuming UserDetails returns accountId as username

        List<MenuDto> menus = menuService.getUserMenus(accountId);

        Map<String, Object> data = new HashMap<>();
        data.put("menus", menus);

        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("data", data);

        return ResponseEntity.ok(response);
    }
}

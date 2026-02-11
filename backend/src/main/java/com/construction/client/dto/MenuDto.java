package com.construction.client.dto;

import lombok.Data;

@Data
public class MenuDto {
    private Integer id;
    private String name;
    private String code;
    private String icon;
    private String route;
    private Integer order;

    private java.util.List<MenuDto> children;

    public MenuDto(Integer id, String name, String code, String icon, String route, Integer order) {
        this.id = id;
        this.name = name;
        this.code = code;
        this.icon = icon;
        this.route = route;
        this.order = order;
        this.children = new java.util.ArrayList<>();
    }
}

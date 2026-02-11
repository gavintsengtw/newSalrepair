package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "AppRoles")
public class AppRole {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RoleID")
    private Integer roleId;

    @Column(name = "RoleName", nullable = false)
    private String roleName;

    @Column(name = "Description")
    private String description;
}

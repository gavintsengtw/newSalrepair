package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;
import com.construction.client.model.User;

@Data
@Entity
@Table(name = "UserRoles")
public class AppUserRole {

    @EmbeddedId
    private AppUserRoleId id;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "UserID")
    @org.hibernate.annotations.NotFound(action = org.hibernate.annotations.NotFoundAction.IGNORE)
    private User user;

    @ManyToOne
    @MapsId("roleId")
    @JoinColumn(name = "RoleID")
    private AppRole role;
}

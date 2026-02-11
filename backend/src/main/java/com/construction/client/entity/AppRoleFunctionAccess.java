package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "RoleFunctionAccess")
public class AppRoleFunctionAccess {

    @EmbeddedId
    private AppRoleFunctionAccessId id;

    @Column(name = "CanRead")
    private Boolean canRead;

    @Column(name = "CanEdit")
    private Boolean canEdit;

    @ManyToOne
    @MapsId("roleId")
    @JoinColumn(name = "RoleID")
    private AppRole role;

    @ManyToOne
    @MapsId("functionId")
    @JoinColumn(name = "FunctionID")
    private AppFunction function;
}

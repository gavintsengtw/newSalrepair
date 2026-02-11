package com.construction.client.entity;

import java.io.Serializable;
import java.util.Objects;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class AppRoleFunctionAccessId implements Serializable {

    @Column(name = "RoleID")
    private Integer roleId;

    @Column(name = "FunctionID")
    private Integer functionId;

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        AppRoleFunctionAccessId that = (AppRoleFunctionAccessId) o;
        return Objects.equals(roleId, that.roleId) &&
                Objects.equals(functionId, that.functionId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(roleId, functionId);
    }
}

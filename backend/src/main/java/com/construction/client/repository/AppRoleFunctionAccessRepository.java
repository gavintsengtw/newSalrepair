package com.construction.client.repository;

import com.construction.client.entity.AppRoleFunctionAccess;
import com.construction.client.entity.AppRoleFunctionAccessId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppRoleFunctionAccessRepository extends JpaRepository<AppRoleFunctionAccess, AppRoleFunctionAccessId> {
    List<AppRoleFunctionAccess> findById_RoleId(Integer roleId);

    List<AppRoleFunctionAccess> findByRole_RoleIdInAndCanReadTrue(List<Integer> roleIds);
}

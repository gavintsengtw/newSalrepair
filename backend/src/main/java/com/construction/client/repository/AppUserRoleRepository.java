package com.construction.client.repository;

import com.construction.client.entity.AppUserRole;
import com.construction.client.entity.AppUserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppUserRoleRepository extends JpaRepository<AppUserRole, AppUserRoleId> {
    List<AppUserRole> findByUser_Uid(Long uid);

}

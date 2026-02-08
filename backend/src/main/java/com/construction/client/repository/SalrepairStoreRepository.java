package com.construction.client.repository;

import com.construction.client.model.SalrepairStore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SalrepairStoreRepository extends JpaRepository<SalrepairStore, Long> {
    List<SalrepairStore> findByAccountid(String accountid);
}

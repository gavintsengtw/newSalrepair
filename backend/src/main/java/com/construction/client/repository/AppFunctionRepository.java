package com.construction.client.repository;

import com.construction.client.entity.AppFunction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppFunctionRepository extends JpaRepository<AppFunction, Integer> {
    List<AppFunction> findAllByOrderBySortOrderAsc();
}

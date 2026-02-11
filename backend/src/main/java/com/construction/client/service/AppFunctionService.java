package com.construction.client.service;

import com.construction.client.entity.AppFunction;
import com.construction.client.repository.AppFunctionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AppFunctionService {

    @Autowired
    private AppFunctionRepository appFunctionRepository;

    public List<AppFunction> findAll() {
        return appFunctionRepository.findAllByOrderBySortOrderAsc();
    }

    public Optional<AppFunction> findById(Integer id) {
        return appFunctionRepository.findById(id);
    }

    public AppFunction create(AppFunction function) {
        return appFunctionRepository.save(function);
    }

    public AppFunction update(Integer id, AppFunction details) {
        return appFunctionRepository.findById(id).map(function -> {
            function.setParentId(details.getParentId());
            function.setFunctionName(details.getFunctionName());
            function.setFunctionCode(details.getFunctionCode());
            function.setIconKey(details.getIconKey());
            function.setRoutePath(details.getRoutePath());
            function.setSortOrder(details.getSortOrder());
            function.setIsActive(details.getIsActive());
            // CreatedAt is generally not updated
            return appFunctionRepository.save(function);
        }).orElseThrow(() -> new RuntimeException("Function not found with id " + id));
    }

    public void delete(Integer id) {
        appFunctionRepository.deleteById(id);
    }
}

package com.construction.client.controller;

import com.construction.client.dto.RepairRequestDTO;
import com.construction.client.service.RepairService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/repair")
public class RepairController {

    @Autowired
    private RepairService repairService;

    @GetMapping("/{userId}")
    public List<RepairRequestDTO> getRepairHistory(@PathVariable String userId) {
        return repairService.getRepairHistory(userId);
    }

    @PostMapping("/{userId}")
    public RepairRequestDTO createRepairRequest(@PathVariable String userId, @RequestBody RepairRequestDTO request) {
        return repairService.createRepairRequest(userId, request);
    }
}

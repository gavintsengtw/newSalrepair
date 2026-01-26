package com.construction.client.controller;

import com.construction.client.dto.ProgressDataDTO;
import com.construction.client.service.ProgressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/progress")
public class ProgressController {

    @Autowired
    private ProgressService progressService;

    @GetMapping("/{userId}")
    public ProgressDataDTO getProgressData(@PathVariable String userId) {
        return progressService.getProgressData(userId);
    }
}

package com.construction.client.controller;

import com.construction.client.dto.HomeDataDTO;
import com.construction.client.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/home")
public class HomeController {

    @Autowired
    private HomeService homeService;

    @GetMapping("/{userId}")
    public HomeDataDTO getHomeData(@PathVariable String userId) {
        return homeService.getHomeData(userId);
    }
}

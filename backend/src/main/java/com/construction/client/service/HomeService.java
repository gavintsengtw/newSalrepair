package com.construction.client.service;

import com.construction.client.dto.HomeDataDTO;
import org.springframework.stereotype.Service;
import java.util.Arrays;

@Service
public class HomeService {

    public HomeDataDTO getHomeData(String userId) {
        // Mock Data
        HomeDataDTO data = new HomeDataDTO();
        data.setProjectName("Sunshine Heights");
        data.setConstructionSummary("Foundation work completed. Currently working on the 1st floor structure.");
        data.setAnnouncements(Arrays.asList(
                "Typhoon safety measures in place.",
                "Monthly progress report available."));
        data.setQuickLinks(Arrays.asList("Pay Bill", "Report Issue", "View Photos"));
        return data;
    }
}

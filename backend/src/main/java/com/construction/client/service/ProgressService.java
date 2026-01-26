package com.construction.client.service;

import com.construction.client.dto.ProgressDataDTO;
import org.springframework.stereotype.Service;
import java.util.Arrays;

@Service
public class ProgressService {

    public ProgressDataDTO getProgressData(String userId) {
        // Mock Data
        ProgressDataDTO data = new ProgressDataDTO();
        data.setCurrentStage("Structural Work - 1F");
        data.setProgressPercentage(15.5);
        data.setConstructionLogs(Arrays.asList(
                "2023-10-25: Concrete pouring for 1F columns.",
                "2023-10-24: Rebar inspection passed."));
        data.setPhotoUrls(Arrays.asList(
                "http://example.com/photo1.jpg",
                "http://example.com/photo2.jpg"));
        return data;
    }
}

package com.construction.client.dto;

import lombok.Data;
import java.util.List;

@Data
public class ProgressDataDTO {
    private String currentStage;
    private Double progressPercentage; // S-Curve value
    private List<String> constructionLogs;
    private List<String> photoUrls;
}

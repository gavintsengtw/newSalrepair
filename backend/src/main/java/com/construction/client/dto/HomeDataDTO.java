package com.construction.client.dto;

import lombok.Data;
import java.util.List;

@Data
public class HomeDataDTO {
    private String projectName;
    private String constructionSummary;
    private List<String> announcements;
    private List<String> quickLinks;
}

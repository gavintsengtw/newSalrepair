package com.construction.client.dto;

import lombok.Data;
import java.util.List;

@Data
public class RepairRequestDTO {
    private String requestId;
    private String issueDescription;
    private String status; // "PENDING", "IN_PROGRESS", "COMPLETED"
    private String requestDate;
    private String scheduledDate;
    private List<String> photoUrls;
}

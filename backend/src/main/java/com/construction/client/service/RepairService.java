package com.construction.client.service;

import com.construction.client.dto.RepairRequestDTO;
import org.springframework.stereotype.Service;
import java.util.Arrays;
import java.util.List;

@Service
public class RepairService {

    public List<RepairRequestDTO> getRepairHistory(String userId) {
        // Mock Data
        RepairRequestDTO r1 = new RepairRequestDTO();
        r1.setRequestId("R-001");
        r1.setIssueDescription("Leaking faucet in kitchen");
        r1.setStatus("COMPLETED");
        r1.setRequestDate("2023-09-15");
        r1.setScheduledDate("2023-09-16");

        RepairRequestDTO r2 = new RepairRequestDTO();
        r2.setRequestId("R-002");
        r2.setIssueDescription("Crack in bedroom wall");
        r2.setStatus("PENDING");
        r2.setRequestDate("2023-10-26");

        return Arrays.asList(r1, r2);
    }

    public RepairRequestDTO createRepairRequest(String userId, RepairRequestDTO request) {
        // Mock Logic
        request.setRequestId("R-" + System.currentTimeMillis());
        request.setStatus("PENDING");
        return request;
    }
}

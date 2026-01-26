package com.construction.client.dto;

import lombok.Data;
import java.util.List;

@Data
public class PaymentInfoDTO {
    private String contractId;
    private List<PaymentDetail> paymentDetails;
    private String remittanceInfo;

    @Data
    public static class PaymentDetail {
        private String termName; // e.g., "Signing Fee", "1st Installment"
        private Double amount;
        private String status; // "PAID", "UNPAID", "OVERDUE"
        private String dueDate;
    }
}

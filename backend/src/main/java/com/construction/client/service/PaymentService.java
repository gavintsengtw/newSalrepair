package com.construction.client.service;

import com.construction.client.dto.PaymentInfoDTO;
import org.springframework.stereotype.Service;
import java.util.Arrays;

@Service
public class PaymentService {

    public PaymentInfoDTO getPaymentInfo(String userId) {
        // Mock Data
        PaymentInfoDTO data = new PaymentInfoDTO();
        data.setContractId("CN-2023-001");
        data.setRemittanceInfo("Bank: 001, Account: 1234567890");

        PaymentInfoDTO.PaymentDetail d1 = new PaymentInfoDTO.PaymentDetail();
        d1.setTermName("Signing Fee");
        d1.setAmount(100000.0);
        d1.setStatus("PAID");
        d1.setDueDate("2023-01-01");

        PaymentInfoDTO.PaymentDetail d2 = new PaymentInfoDTO.PaymentDetail();
        d2.setTermName("1st Installment");
        d2.setAmount(50000.0);
        d2.setStatus("UNPAID");
        d2.setDueDate("2023-11-01");

        data.setPaymentDetails(Arrays.asList(d1, d2));
        return data;
    }
}

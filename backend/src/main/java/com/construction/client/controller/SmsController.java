package com.construction.client.controller;

import com.construction.client.dto.SendSmsResponse;
import com.construction.client.service.SmsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class SmsController {

    @Autowired
    private SmsService smsService;

    // 接收簡訊傳送後的回覆資料 (Callback)
    @RequestMapping(value = "/callback", method = RequestMethod.GET, produces = "text/plain;charset=UTF-8")
    public ResponseEntity<String> handleSmsCallback(
            @RequestParam String msgid,
            @RequestParam String dstaddr,
            @RequestParam String dlvtime,
            @RequestParam String donetime,
            @RequestParam String statuscode,
            @RequestParam String statusstr,
            @RequestParam String StatusFlag) {

        // System.out.println("Received SMS Callback: " + LocalDateTime.now());
        // System.out.println("msgid: " + msgid);
        // System.out.println("dstaddr: " + dstaddr);
        // System.out.println("statusstr: " + statusstr);

        SendSmsResponse data = new SendSmsResponse();
        data.setMsgid(msgid);
        data.setDstaddr(dstaddr);
        data.setDlvtime(dlvtime);
        data.setDonetime(donetime);
        data.setStatuscode(statuscode);
        data.setStatusstr(statusstr);
        data.setStatusFlag(StatusFlag);

        try {
            smsService.updateSmsStatus(data);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 確保回應內容符合格式，包含 LF (`\n`)
        String responseBody = "magicid=sms_gateway_rpack\nmsgid=" + msgid + "\n";

        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_PLAIN)
                .body(responseBody);
    }

    // 新增 API：取得簡訊紀錄
    @GetMapping("/api/sms/logs")
    public ResponseEntity<List<Map<String, Object>>> getSmsLogs() {
        return ResponseEntity.ok(smsService.getSmsLogs());
    }
}

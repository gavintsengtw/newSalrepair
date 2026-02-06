package com.construction.client.service;

import com.construction.client.dto.RepairRequestDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.client.RestTemplate;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class RepairService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 檔案儲存路徑 (建議設定在 application.properties，此處為範例)
    private static final String UPLOAD_DIR = "C:/salrepair_uploads/";

    /**
     * 建立報修單 (包含檔案上傳)
     */
    @Transactional
    public void createRepair(String pjnoid, String unoid, String address,
            String contactName, String contactPhone, String contactType,
            String content, List<MultipartFile> files) throws IOException {

        // 1. 產生報修單號 (Repair ID)
        // 格式: 專案代號(pjnoid) + YYYYMMDD + 3碼流水號
        String today = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String repairId = generateRepairId(pjnoid, today);
        String sysId = UUID.randomUUID().toString(); // 主檔 GUID

        // 2. 寫入報修主檔 (salrepairBase)
        String sqlBase = "INSERT INTO salrepairBase " +
                "(sysid, repairid, pjnoid, unoid, addrs, custname, custphone, custtype, repairmeno, sysdte, importMark, endMark) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), 'N', 'N')";

        jdbcTemplate.update(sqlBase,
                sysId, repairId, pjnoid, unoid, address, contactName, contactPhone, contactType, content);

        // 3. 處理檔案上傳並寫入 salrepairFile
        if (files != null && !files.isEmpty()) {
            saveFiles(sysId, repairId, pjnoid, unoid, files);
        }

        // 4. 發送外部通知
        sendRepairNotification(repairId, pjnoid, unoid, contactName, content);
    }

    /**
     * 取號邏輯: 檢查 salrepairTakeNum 並取得下一號
     */
    private String generateRepairId(String pjnoid, String dateStr) {
        String sqlCheck = "SELECT sysnum FROM salrepairTakeNum WHERE syspjno = ? AND sysyymmdd = ?";
        List<String> nums = jdbcTemplate.queryForList(sqlCheck, String.class, pjnoid, dateStr);

        String newNum;
        if (nums.isEmpty()) {
            // 當日無紀錄，從 001 開始
            newNum = "001";
            String sqlInsert = "INSERT INTO salrepairTakeNum (syspjno, sysyymmdd, sysnum) VALUES (?, ?, ?)";
            jdbcTemplate.update(sqlInsert, pjnoid, dateStr, newNum);
        } else {
            // 當日有紀錄，序號 + 1
            int current = Integer.parseInt(nums.get(0));
            newNum = String.format("%03d", current + 1);
            String sqlUpdate = "UPDATE salrepairTakeNum SET sysnum = ? WHERE syspjno = ? AND sysyymmdd = ?";
            jdbcTemplate.update(sqlUpdate, newNum, pjnoid, dateStr);
        }

        return pjnoid + dateStr + newNum;
    }

    /**
     * 儲存實體檔案並寫入資料庫
     */
    private void saveFiles(String baseSysId, String repairId, String pjnoid, String unoid, List<MultipartFile> files)
            throws IOException {
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String sqlFile = "INSERT INTO salrepairFile (sysid, sid, repairid, pjnoid, unoid, filename, filepath, sysdte) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";

        for (MultipartFile file : files) {
            if (file.isEmpty())
                continue;

            String originalFilename = file.getOriginalFilename();
            String fileSysId = UUID.randomUUID().toString();
            // 檔名加上 UUID 防止重複
            String savedFileName = fileSysId + "_" + originalFilename;
            Path path = Paths.get(UPLOAD_DIR + savedFileName);

            // 寫入磁碟
            Files.write(path, file.getBytes());

            // 寫入資料庫 (sid 這裡暫用 fileSysId，視需求可調整)
            jdbcTemplate.update(sqlFile,
                    fileSysId, baseSysId, repairId, pjnoid, unoid, originalFilename, path.toString());
        }
    }

    // 取得報修歷史 (Placeholder)
    public List<RepairRequestDTO> getRepairHistory(String userId) {
        // 實作查詢邏輯...
        return new ArrayList<>();
    }

    // 建立報修 (JSON DTO 版本 - 若前端改用 JSON 呼叫可使用此方法)
    public RepairRequestDTO createRepairRequest(String userId, RepairRequestDTO request) {
        // 這裡可以呼叫上面的 createRepair，但需處理 DTO 轉換
        try {
            createRepair(request.getPjnoid(), request.getUnoid(), request.getAddrs(),
                    request.getCustname(), request.getCustphone(), request.getCusttype(),
                    request.getRepairmeno(), null);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return request;
    }

    // 新增：取得戶別地址
    public String getRepairUnoAddr(String repairStord, String repairUno) {
        String url = "https://bpm.fong-yi.com.tw/servlet/jform?file=fy_wsSendPIM.pkg&buttonid=getRepairUnoAddr&repairStord="
                + repairStord + "&repairUno=" + repairUno;
        RestTemplate restTemplate = new RestTemplate();
        try {
            return restTemplate.getForObject(url, String.class);
        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"" + e.getMessage() + "\"}";
        }
    }

    /**
     * 發送報修通知
     */
    private void sendRepairNotification(String repairId, String pjnoid, String unoid, String custName,
            String repairMeno) {
        try {
            // 1. 取得發送對象 (toUser)
            String sqlUsers = "SELECT userid FROM salrepairSendtoUser";
            List<String> users = jdbcTemplate.queryForList(sqlUsers, String.class);
            if (users.isEmpty()) {
                // System.out.println("DEBUG: 無通知對象，略過發送通知");
                return;
            }
            // 轉小寫並以逗號分隔
            String toUser = String.join(",", users).toLowerCase();

            // 2. 組合內容 (content)
            // 格式參考:
            // [報修通知] 線上報修通知 {repairId}
            // 案別：{pjnoid} {unoid}
            // 聯絡人：{custName}
            // 說明：{repairMeno}
            StringBuilder contentBuilder = new StringBuilder();
            contentBuilder.append(String.format("[報修通知]　%s %s", "線上報修通知", repairId)).append("\n");
            contentBuilder.append(String.format("案別：%s %s", pjnoid, unoid)).append("\n");
            contentBuilder.append(String.format("聯絡人：%s", custName)).append("\n");
            contentBuilder.append(String.format("說明：%s", repairMeno));

            String content = contentBuilder.toString();

            // System.out.println("DEBUG: 發送報修通知...");
            // System.out.println("To: " + toUser);
            // System.out.println("Content: " + content);

            // 3. 呼叫外部 API
            String url = "https://bpm.fong-yi.com.tw/servlet/jform?file=fy_wsSendPIM.pkg&content={content}&toUser={toUser}";

            Map<String, String> params = new HashMap<>();
            params.put("content", content);
            params.put("toUser", toUser);

            RestTemplate restTemplate = new RestTemplate();
            restTemplate.getForObject(url, String.class, params);

            // System.out.println("DEBUG: 通知發送結果: " + response);

        } catch (Exception e) {
            System.err.println("ERROR: 發送報修通知失敗: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
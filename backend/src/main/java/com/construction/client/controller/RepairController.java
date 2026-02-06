package com.construction.client.controller;

import com.construction.client.dto.RepairRequestDTO;
import com.construction.client.service.RepairService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;
import org.springframework.cache.annotation.Cacheable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Controller
@CrossOrigin(origins = "*")
public class RepairController {

    @Autowired
    private RepairService repairService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 新增：新建報修頁面 (對應前端樣板 repair_new.html)
    @GetMapping("/repair/new")
    public ModelAndView newRepairPage() {
        ModelAndView mav = new ModelAndView("repair_new");
        // 直接利用現有的方法取得資料並傳遞給視圖
        mav.addObject("contactTypes", getContactTypes());
        return mav;
    }

    @ResponseBody
    @GetMapping("/api/repair/{userId}")
    public List<RepairRequestDTO> getRepairHistory(@PathVariable String userId) {
        return repairService.getRepairHistory(userId);
    }

    @ResponseBody
    @PostMapping("/api/repair/{userId}")
    public RepairRequestDTO createRepairRequest(@PathVariable String userId, @RequestBody RepairRequestDTO request) {
        return repairService.createRepairRequest(userId, request);
    }

    // 取得聯絡人類別選單
    @ResponseBody
    @GetMapping("/api/repair/contact-types")
    public List<Map<String, Object>> getContactTypes() {
        // System.out.println("DEBUG: 正在取得聯絡人類別...");
        String sql = "SELECT uid, itemid, kindid, kindName FROM salrepairKinds WHERE itemid = 'custtype'";
        try {
            // 使用 RowMapper 明確指定 Key 的名稱，避免資料庫回傳大寫欄位導致前端解析失敗
            List<Map<String, Object>> results = jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("kindid", rs.getString("kindid"));
                map.put("kindName", rs.getString("kindName"));
                return map;
            });
            // System.out.println("DEBUG: 取得聯絡人類別數量: " + results.size());

            return results;
        } catch (Exception e) {
            System.err.println("ERROR: 取得聯絡人類別失敗: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 取得案場名稱 (依據 S_PJNO 從 STORE 資料表讀取 S_NAME)
    @ResponseBody
    @GetMapping("/api/repair/store-info")
    @Cacheable(value = "storeNames", key = "#pjno != null ? #pjno.trim() : ''")
    public Map<String, String> getStoreInfo(@RequestParam String pjno) {
        String trimmedPjno = pjno != null ? pjno.trim() : "";
        // System.out.println("DEBUG: 正在查詢社區名稱 (pjno: " + trimmedPjno + ")");

        // 修改 SQL：使用 LTRIM(RTRIM()) 以支援舊版 SQL Server，避免 TRIM 函數不支援導致的錯誤
        String sql = "SELECT S_NAME FROM STORE WHERE LTRIM(RTRIM(S_PJNO)) = ?";
        Map<String, String> result = new HashMap<>();
        try {
            List<String> names = jdbcTemplate.query(sql, (rs, rowNum) -> rs.getString("S_NAME"), trimmedPjno);
            String name = names.isEmpty() ? "" : names.get(0);
            // System.out.println("DEBUG: 查詢結果: " + name);
            result.put("communityName", name);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("communityName", "");
        }
        return result;
    }

    // 新建報修 (支援檔案上傳)
    @ResponseBody
    @PostMapping(value = "/api/repair/new", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createRepair(
            @RequestParam String pjnoid, // 必填: 專案代號 (e.g., 19A)
            @RequestParam(required = false) String communityName,
            @RequestParam(required = false) String unit,
            @RequestParam(required = false) String address,
            @RequestParam String contactName,
            @RequestParam String contactPhone,
            @RequestParam(required = false) String contactType,
            @RequestParam String content, // 報修內容 (前端語音轉文字後的結果)
            @RequestParam(value = "files", required = false) List<MultipartFile> files) {
        // 驗證必填欄位
        if (pjnoid == null || pjnoid.trim().isEmpty() ||
                contactName == null || contactName.trim().isEmpty() ||
                contactPhone == null || contactPhone.trim().isEmpty() ||
                content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("專案代號, 聯絡人姓名, 聯絡電話, 報修內容 為必填欄位");
        }

        // 驗證檔案大小與類型
        if (files != null && !files.isEmpty()) {
            long maxFileSize = 50 * 1024 * 1024; // 限制單一檔案 50MB
            for (MultipartFile file : files) {
                // System.out.println(
                // "DEBUG: 收到檔案: " + file.getOriginalFilename() + ", ContentType: " +
                // file.getContentType());
                if (file.getSize() > maxFileSize) {
                    return ResponseEntity.badRequest().body("檔案過大: " + file.getOriginalFilename() + " (限制 50MB)");
                }

                String contentType = file.getContentType();
                // 簡單檢查 MIME type，僅允許圖片或影片
                if (contentType == null || (!contentType.startsWith("image/") && !contentType.startsWith("video/"))) {
                    return ResponseEntity.badRequest().body("不支援的檔案格式: " + file.getOriginalFilename() + " (僅限圖片或影片)");
                }
            }
        }

        try {
            // unit 對應 unoid (戶號)
            String unoid = (unit != null) ? unit : "E06"; // 範例預設值

            repairService.createRepair(pjnoid, unoid, address, contactName, contactPhone, contactType, content, files);
            return ResponseEntity.ok().body("報修單建立成功");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("報修單建立失敗: " + e.getMessage());
        }
    }

    // 新增：取得戶別地址
    @ResponseBody
    @GetMapping("/api/repair/address")
    public ResponseEntity<String> getRepairAddress(@RequestParam String repairStord, @RequestParam String repairUno) {
        String result = repairService.getRepairUnoAddr(repairStord, repairUno);
        // 設定回傳為 JSON 格式
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(result);
    }
}

package com.construction.client.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;
import java.util.Map;

@Controller
public class StoreController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/store")
    public ModelAndView getStoreInfo() {
        // 使用您提供的 SQL 查詢欄位
        String sql = "SELECT S_PJNO, S_NAME, S_COMP1, S_AREA, BUILD_AREA, S_LPER, S_HPER, S_TKIND, S_TKIND3, S_LOANID FROM STORE";

        // 執行查詢
        // 由於 TenantInterceptor 已經解析了帳號中的案場代號 (例如 E78)，
        // 這裡的 jdbcTemplate 會自動路由到該案場對應的資料庫進行查詢。
        List<Map<String, Object>> storeData = jdbcTemplate.queryForList(sql);

        // 建立 ModelAndView，"store_view" 為前端視圖名稱 (需自行對應 JSP 或 Thymeleaf 檔案)
        ModelAndView modelAndView = new ModelAndView("store_view");
        modelAndView.addObject("storeData", storeData);

        return modelAndView;
    }
}
package com.construction.client.controller;

import com.construction.client.dto.HomeDataDTO;
import com.construction.client.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.ModelAndView;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class HomeController {

    @Autowired
    private HomeService homeService;

    // 保留原有的 API 功能，需加上 @ResponseBody 並指定完整路徑
    @ResponseBody
    @GetMapping("/api/home/{userId}")
    public HomeDataDTO getHomeData(@PathVariable String userId) {
        return homeService.getHomeData(userId);
    }

    // 新增首頁視圖，回傳四個大按鈕的資料
    @GetMapping("/home")
    public ModelAndView home() {
        ModelAndView mav = new ModelAndView("home"); // 對應前端樣板 home.html
        mav.addObject("title", "豐邑客服系統");
        List<Map<String, String>> buttons = new ArrayList<>();

        buttons.add(createButton("工程進度", "/progress", "construction"));
        buttons.add(createButton("繳款查詢", "/payment", "payment"));
        buttons.add(createButton("報修服務", "/repair/new", "repair"));
        buttons.add(createButton("會員中心", "/profile", "member"));

        mav.addObject("buttons", buttons);
        return mav;
    }

    private Map<String, String> createButton(String name, String link, String icon) {
        Map<String, String> btn = new HashMap<>();
        btn.put("name", name);
        btn.put("link", link);
        btn.put("icon", icon);
        return btn;
    }
}

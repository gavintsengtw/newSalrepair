package com.construction.client.service;

import com.construction.client.dto.SendSmsResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class SmsService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 更新簡訊狀態 (Callback)
     * 如果 msgid 存在則更新，否則新增
     */
    public void updateSmsStatus(SendSmsResponse data) {
        String sqlCheck = "SELECT COUNT(*) FROM sendSmsResponse WHERE msgid = ?";
        Integer count = jdbcTemplate.queryForObject(sqlCheck, Integer.class, data.getMsgid());

        if (count != null && count > 0) {
            // 更新
            String sqlUpdate = "UPDATE sendSmsResponse SET dstaddr = ?, dlvtime = ?, donetime = ?, statuscode = ?, statusstr = ?, statusFlag = ? WHERE msgid = ?";
            jdbcTemplate.update(sqlUpdate,
                    data.getDstaddr(), data.getDlvtime(), data.getDonetime(),
                    data.getStatuscode(), data.getStatusstr(), data.getStatusFlag(),
                    data.getMsgid());
        } else {
            // 新增
            String sqlInsert = "INSERT INTO sendSmsResponse (uid, msgid, dstaddr, dlvtime, donetime, statuscode, statusstr, statusFlag, crddte, statuscode1) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?)";
            // statuscode1 logic unknown from request, leveraging default similar field or "1" as example in JSON
            jdbcTemplate.update(sqlInsert,
                    UUID.randomUUID().toString(), data.getMsgid(), data.getDstaddr(),
                    data.getDlvtime(), data.getDonetime(), data.getStatuscode(),
                    data.getStatusstr(), data.getStatusFlag(), "1");
        }
    }

    /**
     * 取得簡訊紀錄
     */
    public List<Map<String, Object>> getSmsLogs() {
        String sql = "SELECT uid, msgid, dstaddr, dlvtime, donetime, statuscode, statusstr, statusFlag, crddte, statuscode1 FROM sendSmsResponse ORDER BY crddte DESC";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("uid", rs.getString("uid"));
            map.put("msgid", rs.getString("msgid"));
            map.put("dstaddr", rs.getString("dstaddr"));
            map.put("dlvtime", rs.getString("dlvtime"));
            map.put("donetime", rs.getString("donetime"));
            map.put("statuscode", rs.getString("statuscode"));
            map.put("statusstr", rs.getString("statusstr"));
            map.put("statusFlag", rs.getString("statusFlag"));
            map.put("crddte", rs.getString("crddte"));
            map.put("statuscode1", rs.getString("statuscode1"));
            return map;
        });
    }
}

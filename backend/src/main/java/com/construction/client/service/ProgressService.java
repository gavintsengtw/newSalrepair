package com.construction.client.service;

import com.construction.client.dto.ProgressDataDTO;
import org.springframework.stereotype.Service;
import java.util.Arrays;

@Service
public class ProgressService {

    @org.springframework.beans.factory.annotation.Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    // Base URL for images
    private static final String IMG_BASE_URL = "https://booking.fong-yi.com.tw/projectimages/";

    // Existing mock method (keep or deprecate)
    public ProgressDataDTO getProgressData(String userId) {
        // Mock Data
        ProgressDataDTO data = new ProgressDataDTO();
        data.setCurrentStage("Structural Work - 1F");
        data.setProgressPercentage(15.5);
        data.setConstructionLogs(Arrays.asList(
                "2023-10-25: Concrete pouring for 1F columns.",
                "2023-10-24: Rebar inspection passed."));
        data.setPhotoUrls(Arrays.asList(
                "https://example.com/photo1.jpg",
                "https://example.com/photo2.jpg"));
        return data;
    }

    /**
     * Get distinct dates for a project's progress photos.
     * Table: PRNOTEPAYIMAGES
     * Column: ENDDTE
     */
    public java.util.List<String> getProjectProgressDates(String pjnoid) {
        String sql = "SELECT DISTINCT ENDDTE FROM PRNOTEPAYIMAGES WHERE STOREID = ? ORDER BY ENDDTE DESC";
        return jdbcTemplate.queryForList(sql, String.class, pjnoid);
    }

    /**
     * Get images for a specific project and date.
     * Table: PRNOTEPAYIMAGES
     * Columns: MEMO, ERFILENAME1
     */
    public java.util.List<com.construction.client.dto.ProgressImageDTO> getProjectProgressImages(String pjnoid,
            String date) {
        String sql = "SELECT MEMO, ERFILENAME1, ENDDTE FROM PRNOTEPAYIMAGES WHERE STOREID = ? AND ENDDTE = ?";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            String memo = rs.getString("MEMO");
            String filename = rs.getString("ERFILENAME1");
            String endDte = rs.getString("ENDDTE");

            // Construct full URL
            String imageUrl = (filename != null && !filename.isEmpty()) ? IMG_BASE_URL + filename : "";

            return new com.construction.client.dto.ProgressImageDTO(memo, imageUrl, endDte, filename);
        }, pjnoid, date);
    }
}

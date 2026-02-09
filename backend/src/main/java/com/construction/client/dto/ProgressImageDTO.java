package com.construction.client.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProgressImageDTO {
    private String memo; // MEMO
    private String imageUrl; // Constructed from ERFILENAME1
    private String endDte; // ENDDTE
    private String filename; // Original filename for proxy
}

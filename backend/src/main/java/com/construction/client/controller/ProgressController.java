package com.construction.client.controller;

import com.construction.client.dto.ProgressDataDTO;
import com.construction.client.service.ProgressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/progress")
@CrossOrigin(origins = "*")
public class ProgressController {

    @Autowired
    private ProgressService progressService;

    @GetMapping("/{userId}")
    public ProgressDataDTO getProgressData(@PathVariable String userId) {
        return progressService.getProgressData(userId);
    }

    @GetMapping("/dates/{pjnoid}")
    public java.util.List<String> getProgressDates(@PathVariable String pjnoid) {
        return progressService.getProjectProgressDates(pjnoid);
    }

    @GetMapping("/images/{pjnoid}/{date}")
    public java.util.List<com.construction.client.dto.ProgressImageDTO> getProgressImages(
            @PathVariable String pjnoid,
            @PathVariable String date) {
        return progressService.getProjectProgressImages(pjnoid, date);
    }

    @GetMapping("/image")
    public org.springframework.http.ResponseEntity<byte[]> getProxyImage(@RequestParam String filename) {
        try {
            // Validate filename to prevent path traversal (basic check)
            if (filename == null || filename.contains("..")) {
                return org.springframework.http.ResponseEntity.badRequest().build();
            }

            // URL Encode the filename to handle spaces and Chinese characters
            // But preserve slashes for subdirectories
            String encodedFilename = java.net.URLEncoder.encode(filename, java.nio.charset.StandardCharsets.UTF_8)
                    .replace("+", "%20")
                    .replace("%2F", "/");
            java.net.URI uri = java.net.URI.create("https://booking.fong-yi.com.tw/projectimages/" + encodedFilename);

            // Use insecure RestTemplate to bypass SSL errors
            org.springframework.web.client.RestTemplate restTemplate = createInsecureRestTemplate();
            byte[] imageBytes = restTemplate.getForObject(uri, byte[].class);

            // Determine content type
            org.springframework.http.MediaType mediaType = org.springframework.http.MediaType.IMAGE_JPEG;
            if (filename.toLowerCase().endsWith(".png")) {
                mediaType = org.springframework.http.MediaType.IMAGE_PNG;
            } else if (filename.toLowerCase().endsWith(".gif")) {
                mediaType = org.springframework.http.MediaType.IMAGE_GIF;
            }

            return org.springframework.http.ResponseEntity.ok().contentType(mediaType).body(imageBytes);
        } catch (Exception e) {
            System.err.println("Error fetching image: " + e.getMessage());
            e.printStackTrace();
            return org.springframework.http.ResponseEntity.notFound().build();
        }
    }

    private org.springframework.web.client.RestTemplate createInsecureRestTemplate() {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory() {
            @Override
            protected java.net.HttpURLConnection openConnection(java.net.URL url, java.net.Proxy proxy)
                    throws java.io.IOException {
                java.net.HttpURLConnection connection = super.openConnection(url, proxy);
                if (connection instanceof javax.net.ssl.HttpsURLConnection) {
                    try {
                        javax.net.ssl.SSLContext sslContext = javax.net.ssl.SSLContext.getInstance("TLS");
                        sslContext.init(null, new javax.net.ssl.TrustManager[] {
                                new javax.net.ssl.X509TrustManager() {
                                    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                                        return null;
                                    }

                                    public void checkClientTrusted(java.security.cert.X509Certificate[] certs,
                                            String authType) {
                                    }

                                    public void checkServerTrusted(java.security.cert.X509Certificate[] certs,
                                            String authType) {
                                    }
                                }
                        }, new java.security.SecureRandom());
                        ((javax.net.ssl.HttpsURLConnection) connection)
                                .setSSLSocketFactory(sslContext.getSocketFactory());
                        ((javax.net.ssl.HttpsURLConnection) connection)
                                .setHostnameVerifier((hostname, session) -> true);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                return connection;
            }
        };
        return new org.springframework.web.client.RestTemplate(factory);
    }
}

package com.construction.client.config;

import com.construction.client.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.boot.web.servlet.FilterRegistrationBean;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity // 啟用方法級別的權限控制 (支援 @PreAuthorize)
public class SecurityConfig {

        @Autowired
        private JwtAuthenticationFilter jwtAuthenticationFilter;

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                                .csrf(csrf -> csrf.disable())
                                .authorizeHttpRequests(auth -> auth
                                                // 靜態資源與前端頁面 (包含 CanvasKit)
                                                .requestMatchers("/", "/index.html", "/assets/**", "/canvaskit/**",
                                                                "/manifest.json",
                                                                "/favicon.png", "/icons/**", "/*.js", "/*.html",
                                                                "/*.css", "/*.json", "/*.wasm", "/*.png")
                                                .permitAll()
                                                // API 與 Swagger
                                                .requestMatchers("/api/users/login", "/api/users/refresh", "/home",
                                                                "/api/repair/contact-types",
                                                                "/api/repair/store-info", "/swagger-ui/**",
                                                                "/v3/api-docs/**", "/swagger-ui.html")
                                                .permitAll() // 公開端點
                                                .anyRequest().authenticated() // 其他所有請求都需要 Token
                                )
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }

        @Bean
        public WebSecurityCustomizer webSecurityCustomizer() {
                return (web) -> web.ignoring().requestMatchers(
                                "/", "/index.html", "/manifest.json", "/favicon.png", "/flutter.js",
                                "/flutter_bootstrap.js",
                                "/assets/**", "/canvaskit/**", "/icons/**",
                                "/*.js", "/*.css", "/*.json", "/*.wasm", "/*.png", "/*.jpg", "/*.ico");
        }

        @Bean
        public FilterRegistrationBean<JwtAuthenticationFilter> registration(JwtAuthenticationFilter filter) {
                FilterRegistrationBean<JwtAuthenticationFilter> registration = new FilterRegistrationBean<>(filter);
                registration.setEnabled(false);
                return registration;
        }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();
                configuration.setAllowedOrigins(Arrays.asList("*")); // 允許所有來源 (開發用)
                configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
                configuration.setAllowedHeaders(Arrays.asList("*"));
                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}
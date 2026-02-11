package com.construction.client.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.construction.client.service.TokenBlacklistService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
            @NonNull FilterChain chain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        String username = null;
        String jwt = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtil.extractUsername(jwt);
                logger.debug("Extracted username from JWT: {}", username);
            } catch (Exception e) {
                logger.error("Error extracting username from JWT", e);
            }
        } else {
            logger.warn("Authorization header is missing or does not start with Bearer");
        }

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // 驗證 Token 是否有效，且不在黑名單中
            if (jwtUtil.validateToken(jwt, username) && !tokenBlacklistService.isBlacklisted(jwt)) {
                logger.debug("Token is valid and not blacklisted for user: {}", username);

                // 從 Token 中解析角色並設定權限
                String roles = jwtUtil.extractRoles(jwt);
                List<SimpleGrantedAuthority> authorities = new ArrayList<>();

                if (roles != null && !roles.isEmpty()) {
                    for (String role : roles.split(",")) {
                        // Spring Security hasRole() 預設檢查 ROLE_ 前綴
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + role.trim()));
                    }
                }

                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        username, null, authorities);
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            } else {
                logger.warn("Token validation failed or token is blacklisted for user: {}", username);
            }
        } else {
            if (username == null) {
                logger.debug("Username is null, skipping authentication");
            } else {
                logger.debug("SecurityContext already has authentication: {}",
                        SecurityContextHolder.getContext().getAuthentication());
            }
        }

        chain.doFilter(request, response);
    }
}
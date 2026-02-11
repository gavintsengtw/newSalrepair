package com.construction.client.config;

import org.springframework.context.annotation.Configuration;

import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.boot.web.server.MimeMappings;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.server.ConfigurableServletWebServerFactory;
import org.springframework.context.annotation.Bean;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final com.construction.client.security.SecurityInterceptor securityInterceptor;

    public WebConfig(com.construction.client.security.SecurityInterceptor securityInterceptor) {
        this.securityInterceptor = securityInterceptor;
    }

    @Override
    public void addInterceptors(org.springframework.web.servlet.config.annotation.InterceptorRegistry registry) {
        registry.addInterceptor(securityInterceptor)
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/v1/user/menus", "/api/auth/**", "/api/public/**");
    }

    @Bean
    public WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> mimeMappingsCustomizer() {
        return container -> {
            MimeMappings mappings = new MimeMappings(MimeMappings.DEFAULT);
            mappings.add("wasm", "application/wasm");
            container.setMimeMappings(mappings);
        };
    }
}

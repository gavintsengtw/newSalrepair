package com.construction.client.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Configuration
public class DataSourceConfig {

    @Bean
    @ConfigurationProperties(prefix = "tenants")
    public TenantProperties tenantProperties() {
        return new TenantProperties();
    }

    @Bean
    @Primary
    public DataSource dataSource(TenantProperties tenantProperties) {
        Map<Object, Object> targetDataSources = new HashMap<>();

        DataSource defaultDataSource = null;

        // Create DataSources for each tenant
        if (tenantProperties.getDatasources() != null) {
            for (TenantProperties.DataSourceProperty property : tenantProperties.getDatasources()) {
                DataSource ds = DataSourceBuilder.create()
                        .url(property.getUrl())
                        .username(property.getUsername())
                        .password(property.getPassword())
                        .driverClassName(property.getDriverClassName())
                        .build();
                targetDataSources.put(property.getTenantId(), ds);

                if ("default".equals(property.getTenantId())) {
                    defaultDataSource = ds;
                }
            }
        }

        TenantDataSourceRouter router = new TenantDataSourceRouter();
        router.setTargetDataSources(targetDataSources);

        // Set a default datasource if needed, or handle the case where no tenant is
        // selected
        if (defaultDataSource != null) {
            router.setDefaultTargetDataSource(defaultDataSource);
        }

        router.afterPropertiesSet();
        return router;
    }

    @Component
    @ConfigurationProperties(prefix = "tenants")
    public static class TenantProperties {
        private List<DataSourceProperty> datasources;

        public List<DataSourceProperty> getDatasources() {
            return datasources;
        }

        public void setDatasources(List<DataSourceProperty> datasources) {
            this.datasources = datasources;
        }

        public static class DataSourceProperty {
            private String tenantId;
            private String url;
            private String username;
            private String password;
            private String driverClassName;

            // Getters and Setters
            public String getTenantId() {
                return tenantId;
            }

            public void setTenantId(String tenantId) {
                this.tenantId = tenantId;
            }

            public String getUrl() {
                return url;
            }

            public void setUrl(String url) {
                this.url = url;
            }

            public String getUsername() {
                return username;
            }

            public void setUsername(String username) {
                this.username = username;
            }

            public String getPassword() {
                return password;
            }

            public void setPassword(String password) {
                this.password = password;
            }

            public String getDriverClassName() {
                return driverClassName;
            }

            public void setDriverClassName(String driverClassName) {
                this.driverClassName = driverClassName;
            }
        }
    }
}

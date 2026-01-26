package com.construction.client.config;

import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;

public class TenantDataSourceRouter extends AbstractRoutingDataSource {

    @Override
    protected Object determineCurrentLookupKey() {
        return TenantContext.getTenantId();
    }
}

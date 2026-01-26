package com.construction.client;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

// Exclude DataSourceAutoConfiguration because we will configure it manually for multi-tenancy
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class ClientApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ClientApiApplication.class, args);
	}

}

package com.construction.client;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cache.annotation.EnableCaching;

// Exclude DataSourceAutoConfiguration because we will configure it manually for multi-tenancy
@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class })
@EnableCaching
public class ClientApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ClientApiApplication.class, args);
	}

	@org.springframework.context.annotation.Bean
	public org.springframework.boot.CommandLineRunner commandLineRunner(
			com.construction.client.repository.UserRepository userRepository) {
		return args -> {
			System.out.println("----------------------------------------------------------");
			System.out.println("STARTUP DB CHECK:");
			try {
				// Set default tenant for this check
				com.construction.client.config.TenantContext.setTenantId("default");
				long count = userRepository.count();
				System.out.println("Successfully connected to DB. User count: " + count);

				if (count > 0) {
					System.out.println("First user found: " + userRepository.findAll().get(0).getAccountid());
				} else {
					System.out.println("WARNING: No users found in the database!");
				}
			} catch (Exception e) {
				System.out.println("ERROR connecting to DB: " + e.getMessage());
				e.printStackTrace();
			}
			System.out.println("----------------------------------------------------------");
		};
	}

}

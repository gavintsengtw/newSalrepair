package com.construction.client;

import com.construction.client.controller.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class AppStructureTest {

    @Autowired
    private HomeController homeController;
    @Autowired
    private ProgressController progressController;
    @Autowired
    private PaymentController paymentController;
    @Autowired
    private RepairController repairController;
    @Autowired
    private ProfileController profileController;

    @Test
    void contextLoads() {
        assertThat(homeController).isNotNull();
        assertThat(progressController).isNotNull();
        assertThat(paymentController).isNotNull();
        assertThat(repairController).isNotNull();
        assertThat(profileController).isNotNull();
    }
}

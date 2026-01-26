package com.construction.client.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "salrepairAccount")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "uid")
    private Long uid;

    @Column(name = "accountid", nullable = false, unique = true)
    private String accountid;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "sysdte")
    private java.time.LocalDateTime sysdte;
}

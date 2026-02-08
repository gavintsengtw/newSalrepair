package com.construction.client.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "salrepairStore")
public class SalrepairStore {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sid")
    private BigDecimal sid; // Using BigDecimal as requested (Decimal 18,0)

    @Column(name = "accountid")
    private String accountid;

    @Column(name = "pjnoid")
    private String pjnoid;

    @Column(name = "unoid")
    private String unoid;

    @Column(name = "buildid")
    private String buildid;

    @Column(name = "floorid")
    private String floorid;

    @Column(name = "CRDUSER")
    private String crdUser;

    @Column(name = "CRDDTE")
    private LocalDateTime crdDte;

    @Column(name = "MDFUSER")
    private String mdfUser;

    @Column(name = "MDFDTE")
    private LocalDateTime mdfDte;
}

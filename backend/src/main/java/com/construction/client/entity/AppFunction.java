package com.construction.client.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "AppFunctions")
public class AppFunction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "FunctionID")
    private Integer functionId;

    @Column(name = "ParentID")
    private Integer parentId;

    @Column(name = "FunctionName", nullable = false)
    private String functionName;

    @Column(name = "FunctionCode", nullable = false, unique = true)
    private String functionCode;

    @Column(name = "IconKey")
    private String iconKey;

    @Column(name = "RoutePath")
    private String routePath;

    @Column(name = "SortOrder")
    private Integer sortOrder;

    @Column(name = "IsActive")
    private Boolean isActive;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;
}

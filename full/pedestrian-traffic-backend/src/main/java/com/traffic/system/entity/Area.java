package com.traffic.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("area")
public class Area implements Serializable {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String areaCode;
    private String areaName;
    private String areaType;
    private String address;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private String description;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

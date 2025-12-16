package com.traffic.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("device")
public class Device implements Serializable {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String deviceCode;
    private String deviceName;
    private String deviceType;
    private Long areaId;
    private String ipAddress;
    private String rtspUrl;
    private Integer onlineStatus;
    private LocalDateTime lastOnlineTime;
    private LocalDate installDate;
    private String description;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableField(exist = false)
    private String areaName;
}

package com.traffic.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("alert")
public class Alert implements Serializable {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String alertType;
    private String alertLevel;
    private LocalDateTime occurTime;
    private Long areaId;
    private Long deviceId;
    private String alertContent;
    private String handleStatus;
    private LocalDateTime handleTime;
    private Long handlerId;
    private String handleRemark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableField(exist = false)
    private String areaName;
}

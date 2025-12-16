package com.traffic.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("violation_record")
public class ViolationRecord implements Serializable {
    
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    
    private String violationType;
    
    private LocalDateTime occurTime;
    
    private Long areaId;
    
    private Long deviceId;
    
    private String imageUrl;
    
    private String videoUrl;
    
    private Integer personCount;
    
    private String severityLevel;
    
    private String handleStatus;
    
    private String description;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    // 关联字段(非数据库字段)
    @TableField(exist = false)
    private String areaName;
    
    @TableField(exist = false)
    private String deviceName;
}

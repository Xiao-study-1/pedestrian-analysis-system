package com.traffic.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("traffic_flow")
public class TrafficFlow implements Serializable {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private Long areaId;
    private Long deviceId;
    private LocalDateTime statTime;
    private LocalDate statDate;
    private Integer statHour;
    private Integer flowCount;
    private String timePeriod;
    private Integer avgStayTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

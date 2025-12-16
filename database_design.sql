-- ========================================
-- 行人交通行为智能分析系统 - 数据库设计
-- ========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS pedestrian_traffic_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE pedestrian_traffic_system;

-- ========================================
-- 1. 用户表
-- ========================================
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '密码(加密)',
  `nickname` VARCHAR(50) COMMENT '昵称',
  `email` VARCHAR(100) COMMENT '邮箱',
  `phone` VARCHAR(20) COMMENT '手机号',
  `avatar` VARCHAR(255) COMMENT '头像URL',
  `role` VARCHAR(20) NOT NULL DEFAULT 'USER' COMMENT '角色:ADMIN,USER',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) COMMENT '最后登录IP',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认管理员账号 (密码: admin123)
INSERT INTO `sys_user` (`username`, `password`, `nickname`, `role`) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 'ADMIN');

-- ========================================
-- 2. 区域信息表
-- ========================================
CREATE TABLE `area` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '区域ID',
  `area_code` VARCHAR(50) NOT NULL COMMENT '区域编码',
  `area_name` VARCHAR(100) NOT NULL COMMENT '区域名称',
  `area_type` VARCHAR(50) NOT NULL COMMENT '区域类型:学校区,商圈,医院周边,交通枢纽,其他',
  `address` VARCHAR(255) COMMENT '详细地址',
  `longitude` DECIMAL(10, 7) COMMENT '经度',
  `latitude` DECIMAL(10, 7) COMMENT '纬度',
  `description` TEXT COMMENT '区域描述',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_area_code` (`area_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域信息表';

-- 插入示例区域数据
INSERT INTO `area` (`area_code`, `area_name`, `area_type`) VALUES
('AREA001', '学校门口路口', '学校区'),
('AREA002', '商业街路口', '商圈'),
('AREA003', '医院门口', '医院周边'),
('AREA004', '地铁站出口', '交通枢纽'),
('AREA005', '公园入口', '其他');

-- ========================================
-- 3. 设备信息表
-- ========================================
CREATE TABLE `device` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `device_code` VARCHAR(50) NOT NULL COMMENT '设备编码',
  `device_name` VARCHAR(100) NOT NULL COMMENT '设备名称',
  `device_type` VARCHAR(50) NOT NULL COMMENT '设备类型:摄像头,传感器,其他',
  `area_id` BIGINT NOT NULL COMMENT '所属区域ID',
  `ip_address` VARCHAR(50) COMMENT 'IP地址',
  `rtsp_url` VARCHAR(255) COMMENT '视频流地址',
  `online_status` TINYINT NOT NULL DEFAULT 0 COMMENT '在线状态:0-离线,1-在线',
  `last_online_time` DATETIME COMMENT '最后在线时间',
  `install_date` DATE COMMENT '安装日期',
  `description` TEXT COMMENT '设备描述',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_device_code` (`device_code`),
  KEY `idx_area_id` (`area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备信息表';

-- 插入示例设备数据
INSERT INTO `device` (`device_code`, `device_name`, `device_type`, `area_id`, `online_status`) VALUES
('DEV001', '学校路口摄像头1', '摄像头', 1, 1),
('DEV002', '学校路口摄像头2', '摄像头', 1, 1),
('DEV003', '商业街摄像头1', '摄像头', 2, 1),
('DEV004', '医院门口摄像头1', '摄像头', 3, 0),
('DEV005', '地铁站摄像头1', '摄像头', 4, 1);

-- ========================================
-- 4. 违规行为记录表
-- ========================================
CREATE TABLE `violation_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `violation_type` VARCHAR(50) NOT NULL COMMENT '违规类型:闯红灯,违规横穿,路口逗留,逆行,违规骑行',
  `occur_time` DATETIME NOT NULL COMMENT '发生时间',
  `area_id` BIGINT NOT NULL COMMENT '发生区域ID',
  `device_id` BIGINT NOT NULL COMMENT '设备ID',
  `image_url` VARCHAR(255) COMMENT '截图URL',
  `video_url` VARCHAR(255) COMMENT '视频URL',
  `person_count` INT DEFAULT 1 COMMENT '涉及人数',
  `severity_level` VARCHAR(20) DEFAULT 'MEDIUM' COMMENT '严重程度:LOW,MEDIUM,HIGH',
  `handle_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '处理状态:PENDING-待处理,PROCESSING-处理中,COMPLETED-已完成',
  `description` TEXT COMMENT '描述',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_occur_time` (`occur_time`),
  KEY `idx_area_id` (`area_id`),
  KEY `idx_device_id` (`device_id`),
  KEY `idx_violation_type` (`violation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违规行为记录表';

-- ========================================
-- 5. 行为处置记录表
-- ========================================
CREATE TABLE `disposal_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '处置ID',
  `violation_id` BIGINT NOT NULL COMMENT '违规记录ID',
  `disposal_type` VARCHAR(50) NOT NULL COMMENT '处置类型:和解劝离,引导整改,罚款警示,其他',
  `disposal_time` DATETIME NOT NULL COMMENT '处置时间',
  `handler_id` BIGINT COMMENT '处置人员ID',
  `handler_name` VARCHAR(50) COMMENT '处置人员姓名',
  `disposal_result` VARCHAR(20) NOT NULL COMMENT '处置结果:SUCCESS-成功,FAILED-失败',
  `remark` TEXT COMMENT '备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_violation_id` (`violation_id`),
  KEY `idx_disposal_time` (`disposal_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行为处置记录表';

-- ========================================
-- 6. 人流统计表
-- ========================================
CREATE TABLE `traffic_flow` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `area_id` BIGINT NOT NULL COMMENT '区域ID',
  `device_id` BIGINT COMMENT '设备ID',
  `stat_time` DATETIME NOT NULL COMMENT '统计时间',
  `stat_date` DATE NOT NULL COMMENT '统计日期',
  `stat_hour` INT NOT NULL COMMENT '统计小时(0-23)',
  `flow_count` INT NOT NULL DEFAULT 0 COMMENT '人流量',
  `time_period` VARCHAR(20) NOT NULL COMMENT '时段类型:PEAK-高峰,NORMAL-平峰,VALLEY-低谷',
  `avg_stay_time` INT COMMENT '平均停留时间(秒)',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_area_date` (`area_id`, `stat_date`),
  KEY `idx_stat_time` (`stat_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人流统计表';

-- ========================================
-- 7. 预警信息表
-- ========================================
CREATE TABLE `alert` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `alert_type` VARCHAR(50) NOT NULL COMMENT '预警类型:人流拥堵,设备异常,违规频发,其他',
  `alert_level` VARCHAR(20) NOT NULL COMMENT '预警级别:INFO,WARNING,ERROR,CRITICAL',
  `occur_time` DATETIME NOT NULL COMMENT '发生时间',
  `area_id` BIGINT COMMENT '区域ID',
  `device_id` BIGINT COMMENT '设备ID',
  `alert_content` TEXT NOT NULL COMMENT '预警内容',
  `handle_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态:PENDING-待处理,HANDLED-已处理,IGNORED-已忽略',
  `handle_time` DATETIME COMMENT '处理时间',
  `handler_id` BIGINT COMMENT '处理人ID',
  `handle_remark` TEXT COMMENT '处理备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_occur_time` (`occur_time`),
  KEY `idx_handle_status` (`handle_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警信息表';

-- ========================================
-- 8. 操作日志表
-- ========================================
CREATE TABLE `operation_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT COMMENT '用户ID',
  `username` VARCHAR(50) COMMENT '用户名',
  `operation` VARCHAR(100) NOT NULL COMMENT '操作内容',
  `method` VARCHAR(200) COMMENT '请求方法',
  `params` TEXT COMMENT '请求参数',
  `ip` VARCHAR(50) COMMENT 'IP地址',
  `location` VARCHAR(100) COMMENT 'IP归属地',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-失败,1-成功',
  `error_msg` TEXT COMMENT '错误信息',
  `execute_time` INT COMMENT '执行时长(ms)',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ========================================
-- 9. 系统配置表
-- ========================================
CREATE TABLE `sys_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT NOT NULL COMMENT '配置值',
  `config_type` VARCHAR(20) NOT NULL DEFAULT 'STRING' COMMENT '配置类型:STRING,NUMBER,BOOLEAN,JSON',
  `description` VARCHAR(255) COMMENT '配置描述',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- ========================================
-- 插入模拟数据
-- ========================================

-- 插入违规记录模拟数据
INSERT INTO `violation_record` (`violation_type`, `occur_time`, `area_id`, `device_id`, `severity_level`, `handle_status`) VALUES
('闯红灯', DATE_SUB(NOW(), INTERVAL 1 HOUR), 1, 1, 'HIGH', 'PENDING'),
('违规横穿', DATE_SUB(NOW(), INTERVAL 2 HOUR), 2, 3, 'MEDIUM', 'PROCESSING'),
('路口逗留', DATE_SUB(NOW(), INTERVAL 3 HOUR), 1, 1, 'LOW', 'COMPLETED'),
('逆行', DATE_SUB(NOW(), INTERVAL 4 HOUR), 4, 5, 'MEDIUM', 'PENDING'),
('违规骑行', DATE_SUB(NOW(), INTERVAL 5 HOUR), 2, 3, 'MEDIUM', 'COMPLETED');

-- 插入人流统计模拟数据(最近7天)
INSERT INTO `traffic_flow` (`area_id`, `stat_time`, `stat_date`, `stat_hour`, `flow_count`, `time_period`)
SELECT 
    a.id,
    DATE_SUB(NOW(), INTERVAL d.day_offset DAY) + INTERVAL h.hour_val HOUR,
    DATE(DATE_SUB(NOW(), INTERVAL d.day_offset DAY)),
    h.hour_val,
    FLOOR(1000 + RAND() * 4000),
    CASE 
        WHEN h.hour_val BETWEEN 7 AND 9 THEN 'PEAK'
        WHEN h.hour_val BETWEEN 17 AND 19 THEN 'PEAK'
        WHEN h.hour_val BETWEEN 10 AND 16 THEN 'NORMAL'
        ELSE 'VALLEY'
    END
FROM 
    area a
    CROSS JOIN (SELECT 0 AS day_offset UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) d
    CROSS JOIN (SELECT 7 AS hour_val UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19) h
WHERE a.id <= 5;

-- 插入预警信息模拟数据
INSERT INTO `alert` (`alert_type`, `alert_level`, `occur_time`, `area_id`, `device_id`, `alert_content`, `handle_status`) VALUES
('人流拥堵', 'WARNING', DATE_SUB(NOW(), INTERVAL 30 MINUTE), 1, 1, '学校门口路口人流量超过阈值,建议加强疏导', 'PENDING'),
('违规频发', 'ERROR', DATE_SUB(NOW(), INTERVAL 1 HOUR), 2, 3, '商业街路口1小时内发生5起闯红灯行为', 'PENDING'),
('设备异常', 'CRITICAL', DATE_SUB(NOW(), INTERVAL 2 HOUR), 3, 4, '医院门口摄像头1离线', 'HANDLED');

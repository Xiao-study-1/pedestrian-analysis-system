# API接口设计文档

## 接口规范

### 基础URL
```
开发环境: http://localhost:8080
生产环境: https://api.yourdom ain.com
```

### 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1700000000000
}
```

### 状态码说明
- 200: 成功
- 400: 请求参数错误
- 401: 未认证
- 403: 无权限
- 404: 资源不存在
- 500: 服务器错误

### 认证方式
使用JWT Token认证,请求头携带:
```
Authorization: Bearer {token}
```

---

## 1. 认证模块

### 1.1 用户登录
**接口**: `POST /api/auth/login`

**请求参数**:
```json
{
  "username": "admin",
  "password": "admin123",
  "captcha": "8A3F"
}
```

**响应数据**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userInfo": {
      "id": 1,
      "username": "admin",
      "nickname": "系统管理员",
      "role": "ADMIN",
      "avatar": null
    }
  }
}
```

### 1.2 用户登出
**接口**: `POST /api/auth/logout`

**响应数据**:
```json
{
  "code": 200,
  "message": "登出成功"
}
```

### 1.3 获取当前用户信息
**接口**: `GET /api/auth/info`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "系统管理员",
    "email": "admin@example.com",
    "role": "ADMIN"
  }
}
```

---

## 2. 首页大屏数据

### 2.1 违规行为TOP5
**接口**: `GET /api/dashboard/violation-top5`

**请求参数**:
- timeRange: string (today/week/month) - 时间范围

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {
      "violationType": "闯红灯",
      "count": 381,
      "location": "学校门口路口"
    },
    {
      "violationType": "违规横穿",
      "count": 87,
      "location": "商业街路口"
    },
    {
      "violationType": "路口逗留",
      "count": 87,
      "location": "医院门口"
    },
    {
      "violationType": "逆行",
      "count": 70,
      "location": "地铁站出口"
    },
    {
      "violationType": "违规骑行",
      "count": 64,
      "location": "公园入口"
    }
  ]
}
```

### 2.2 设备在线状态
**接口**: `GET /api/dashboard/device-status`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "online": 67,
    "offline": 33,
    "areaStatus": [
      {
        "areaName": "所有路口",
        "onlineRate": 67
      },
      {
        "areaName": "学校区",
        "onlineRate": 84
      },
      {
        "areaName": "商圈",
        "onlineRate": 60
      },
      {
        "areaName": "医院周边",
        "onlineRate": 50
      },
      {
        "areaName": "交通枢纽",
        "onlineRate": 61
      }
    ]
  }
}
```

### 2.3 行人行为类型占比
**接口**: `GET /api/dashboard/behavior-ratio`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "totalSamples": 2000,
    "behaviors": [
      {
        "type": "合规通行",
        "count": 860,
        "percentage": 43
      },
      {
        "type": "闯红灯",
        "count": 600,
        "percentage": 30
      },
      {
        "type": "违规横穿",
        "count": 260,
        "percentage": 13
      },
      {
        "type": "其他",
        "count": 160,
        "percentage": 8
      },
      {
        "type": "路口逗留",
        "count": 120,
        "percentage": 6
      }
    ]
  }
}
```

### 2.4 行为处置结果占比
**接口**: `GET /api/dashboard/disposal-ratio`

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {
      "type": "和解劝离案件",
      "percentage": 20.8
    },
    {
      "type": "引导整改案件",
      "percentage": 20.8
    },
    {
      "type": "罚款警示案件",
      "percentage": 20.8
    },
    {
      "type": "其他处置",
      "percentage": 37.6
    }
  ]
}
```

### 2.5 人流量趋势
**接口**: `GET /api/dashboard/traffic-trend`

**请求参数**:
- days: int (默认7) - 查询天数

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "dates": ["周一", "周二", "周三", "周四", "周五"],
    "avgFlow": [3200, 3500, 3100, 3800, 4200],
    "peakFlow": [4500, 4800, 4300, 5100, 5500]
  }
}
```

### 2.6 区域人流对比
**接口**: `GET /api/dashboard/area-comparison`

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {
      "areaId": 1,
      "areaName": "学校门口路口",
      "hourlyData": [
        {"hour": 7, "flow": 1200},
        {"hour": 8, "flow": 2500},
        {"hour": 9, "flow": 1800}
      ]
    },
    {
      "areaId": 2,
      "areaName": "商业街路口",
      "hourlyData": [
        {"hour": 7, "flow": 800},
        {"hour": 8, "flow": 1500},
        {"hour": 9, "flow": 2200}
      ]
    }
  ]
}
```

### 2.7 实时热力图数据
**接口**: `GET /api/dashboard/heatmap`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "gridSize": 10,
    "data": [
      {"x": 0, "y": 0, "value": 120},
      {"x": 0, "y": 1, "value": 85},
      {"x": 1, "y": 0, "value": 200}
    ]
  }
}
```

---

## 3. 违规记录管理

### 3.1 获取违规记录列表
**接口**: `GET /api/violations`

**请求参数**:
- page: int (默认1) - 页码
- pageSize: int (默认10) - 每页数量
- violationType: string - 违规类型
- areaId: long - 区域ID
- startTime: datetime - 开始时间
- endTime: datetime - 结束时间
- handleStatus: string - 处理状态

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "list": [
      {
        "id": 1,
        "violationType": "闯红灯",
        "occurTime": "2023-11-25 08:30:00",
        "areaName": "学校门口路口",
        "deviceName": "学校路口摄像头1",
        "imageUrl": "/images/violation/001.jpg",
        "severityLevel": "HIGH",
        "handleStatus": "PENDING"
      }
    ]
  }
}
```

### 3.2 获取违规记录详情
**接口**: `GET /api/violations/{id}`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "violationType": "闯红灯",
    "occurTime": "2023-11-25 08:30:00",
    "areaId": 1,
    "areaName": "学校门口路口",
    "deviceId": 1,
    "deviceName": "学校路口摄像头1",
    "imageUrl": "/images/violation/001.jpg",
    "videoUrl": "/videos/violation/001.mp4",
    "personCount": 1,
    "severityLevel": "HIGH",
    "handleStatus": "PENDING",
    "description": "行人无视红灯直接通过路口",
    "createTime": "2023-11-25 08:30:15"
  }
}
```

### 3.3 更新违规记录
**接口**: `PUT /api/violations/{id}`

**请求参数**:
```json
{
  "handleStatus": "COMPLETED",
  "description": "已处理"
}
```

---

## 4. 人流分析

### 4.1 总人流量统计
**接口**: `GET /api/traffic/total-flow`

**请求参数**:
- areaId: long - 区域ID
- startDate: date - 开始日期
- endDate: date - 结束日期

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "totalFlow": 125000,
    "avgDailyFlow": 17857,
    "peakDayFlow": 22000,
    "peakDayDate": "2023-11-20"
  }
}
```

### 4.2 停留时间分布
**接口**: `GET /api/traffic/stay-time`

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {"range": "0-30秒", "count": 5000, "percentage": 40},
    {"range": "30-60秒", "count": 3750, "percentage": 30},
    {"range": "1-3分钟", "count": 2500, "percentage": 20},
    {"range": "3-5分钟", "count": 875, "percentage": 7},
    {"range": "5分钟以上", "count": 375, "percentage": 3}
  ]
}
```

### 4.3 高峰时段分析
**接口**: `GET /api/traffic/peak-time`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "hours": [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
    "flowData": [1200, 2500, 1800, 1500, 1600, 1400, 1300, 1400, 1500, 1700, 2800, 2200, 1600]
  }
}
```

### 4.4 重点区域分析
**接口**: `GET /api/traffic/key-area`

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {
      "areaName": "学校门口路口",
      "totalFlow": 35000,
      "avgFlow": 5000,
      "peakFlow": 8000
    },
    {
      "areaName": "商业街路口",
      "totalFlow": 28000,
      "avgFlow": 4000,
      "peakFlow": 6500
    }
  ]
}
```

### 4.5 趋势分析
**接口**: `GET /api/traffic/trend`

**请求参数**:
- areaId: long - 区域ID
- days: int (默认30) - 天数

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "dates": ["11-01", "11-02", "11-03"],
    "flowData": [15000, 16500, 14800],
    "trend": "UP"
  }
}
```

---

## 5. 预警管理

### 5.1 获取预警列表
**接口**: `GET /api/alerts`

**请求参数**:
- page: int
- pageSize: int
- alertType: string
- alertLevel: string
- handleStatus: string

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 50,
    "list": [
      {
        "id": 1,
        "alertType": "人流拥堵",
        "alertLevel": "WARNING",
        "occurTime": "2023-11-25 08:30:00",
        "areaName": "学校门口路口",
        "alertContent": "学校门口路口人流量超过阈值,建议加强疏导",
        "handleStatus": "PENDING"
      }
    ]
  }
}
```

### 5.2 处理预警
**接口**: `PUT /api/alerts/{id}/handle`

**请求参数**:
```json
{
  "handleRemark": "已派遣人员处理"
}
```

### 5.3 预警统计
**接口**: `GET /api/alerts/statistics`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "pending": 15,
    "handled": 80,
    "ignored": 5,
    "byLevel": {
      "INFO": 20,
      "WARNING": 50,
      "ERROR": 25,
      "CRITICAL": 5
    }
  }
}
```

---

## 6. 设备管理

### 6.1 获取设备列表
**接口**: `GET /api/devices`

**请求参数**:
- page: int
- pageSize: int
- areaId: long
- onlineStatus: int

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "list": [
      {
        "id": 1,
        "deviceCode": "DEV001",
        "deviceName": "学校路口摄像头1",
        "deviceType": "摄像头",
        "areaName": "学校门口路口",
        "onlineStatus": 1,
        "lastOnlineTime": "2023-11-25 10:00:00"
      }
    ]
  }
}
```

### 6.2 更新设备状态
**接口**: `PUT /api/devices/{id}/status`

**请求参数**:
```json
{
  "onlineStatus": 1
}
```

---

## 7. 区域管理

### 7.1 获取区域列表
**接口**: `GET /api/areas`

**响应数据**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "areaCode": "AREA001",
      "areaName": "学校门口路口",
      "areaType": "学校区",
      "deviceCount": 5,
      "status": 1
    }
  ]
}
```

---

## 8. 用户管理

### 8.1 获取用户信息
**接口**: `GET /api/users/profile`

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "系统管理员",
    "email": "admin@example.com",
    "phone": "13800138000",
    "avatar": "/avatars/admin.jpg",
    "role": "ADMIN",
    "lastLoginTime": "2023-11-25 08:00:00"
  }
}
```

### 8.2 更新用户信息
**接口**: `PUT /api/users/profile`

**请求参数**:
```json
{
  "nickname": "管理员",
  "email": "admin@example.com",
  "phone": "13800138000"
}
```

### 8.3 获取操作日志
**接口**: `GET /api/users/logs`

**请求参数**:
- page: int
- pageSize: int

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "total": 200,
    "list": [
      {
        "id": 1,
        "operation": "用户登录",
        "ip": "192.168.1.100",
        "location": "北京市",
        "status": 1,
        "createTime": "2023-11-25 08:00:00"
      }
    ]
  }
}
```

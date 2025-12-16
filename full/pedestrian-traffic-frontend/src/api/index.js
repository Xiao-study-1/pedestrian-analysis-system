import request from '@/utils/request'

// ========== 认证相关 ==========
export const authAPI = {
  // 用户登录
  login(data) {
    return request({
      url: '/auth/login',
      method: 'post',
      data
    })
  },
  
  // 用户登出
  logout() {
    return request({
      url: '/auth/logout',
      method: 'post'
    })
  },
  
  // 获取用户信息
  getUserInfo() {
    return request({
      url: '/auth/info',
      method: 'get'
    })
  }
}

// ========== 首页大屏 ==========
export const dashboardAPI = {
  // 违规行为TOP5
  getViolationTop5(params) {
    return request({
      url: '/dashboard/violation-top5',
      method: 'get',
      params
    })
  },
  
  // 设备在线状态
  getDeviceStatus() {
    return request({
      url: '/dashboard/device-status',
      method: 'get'
    })
  },
  
  // 行人行为类型占比
  getBehaviorRatio() {
    return request({
      url: '/dashboard/behavior-ratio',
      method: 'get'
    })
  },
  
  // 行为处置结果占比
  getDisposalRatio() {
    return request({
      url: '/dashboard/disposal-ratio',
      method: 'get'
    })
  },
  
  // 人流量趋势
  getTrafficTrend(params) {
    return request({
      url: '/dashboard/traffic-trend',
      method: 'get',
      params
    })
  },
  
  // 区域人流对比
  getAreaComparison() {
    return request({
      url: '/dashboard/area-comparison',
      method: 'get'
    })
  },
  
  // 实时热力图数据
  getHeatmap() {
    return request({
      url: '/dashboard/heatmap',
      method: 'get'
    })
  }
}

// ========== 违规记录 ==========
export const violationAPI = {
  // 获取违规记录列表
  getList(params) {
    return request({
      url: '/violations',
      method: 'get',
      params
    })
  },
  
  // 获取违规记录详情
  getDetail(id) {
    return request({
      url: `/violations/${id}`,
      method: 'get'
    })
  },
  
  // 更新违规记录
  update(id, data) {
    return request({
      url: `/violations/${id}`,
      method: 'put',
      data
    })
  }
}

// ========== 人流分析 ==========
export const trafficAPI = {
  // 总人流量统计
  getTotalFlow(params) {
    return request({
      url: '/traffic/total-flow',
      method: 'get',
      params
    })
  },
  
  // 停留时间分布
  getStayTime() {
    return request({
      url: '/traffic/stay-time',
      method: 'get'
    })
  },
  
  // 高峰时段分析
  getPeakTime() {
    return request({
      url: '/traffic/peak-time',
      method: 'get'
    })
  },
  
  // 重点区域分析
  getKeyArea() {
    return request({
      url: '/traffic/key-area',
      method: 'get'
    })
  },
  
  // 趋势分析
  getTrend(params) {
    return request({
      url: '/traffic/trend',
      method: 'get',
      params
    })
  }
}

// ========== 预警管理 ==========
export const alertAPI = {
  // 获取预警列表
  getList(params) {
    return request({
      url: '/alerts',
      method: 'get',
      params
    })
  },
  
  // 处理预警
  handle(id, data) {
    return request({
      url: `/alerts/${id}/handle`,
      method: 'put',
      data
    })
  },
  
  // 预警统计
  getStatistics() {
    return request({
      url: '/alerts/statistics',
      method: 'get'
    })
  }
}

// ========== 设备管理 ==========
export const deviceAPI = {
  // 获取设备列表
  getList(params) {
    return request({
      url: '/devices',
      method: 'get',
      params
    })
  }
}

// ========== 区域管理 ==========
export const areaAPI = {
  // 获取区域列表
  getList() {
    return request({
      url: '/areas',
      method: 'get'
    })
  }
}

// ========== 用户管理 ==========
export const userAPI = {
  // 获取用户信息
  getProfile() {
    return request({
      url: '/users/profile',
      method: 'get'
    })
  },
  
  // 更新用户信息
  updateProfile(data) {
    return request({
      url: '/users/profile',
      method: 'put',
      data
    })
  },
  
  // 获取操作日志
  getLogs(params) {
    return request({
      url: '/users/logs',
      method: 'get',
      params
    })
  }
}

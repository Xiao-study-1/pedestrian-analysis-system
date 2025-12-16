<template>
  <div class="monitor-container">
    <!-- 顶部导航栏 (保持与Dashboard一致) -->
    <header class="header">
      <div class="header-left">
        <i class="fa fa-line-chart"></i>
        <h1>行人交通管控智能分析系统</h1>
      </div>

      <nav class="nav">
        <router-link to="/dashboard" class="nav-item">首页</router-link>
        <router-link to="/monitor" class="nav-item active">实时监控</router-link>
        <router-link to="/people" class="nav-item">人流分析</router-link>
        <router-link to="/remind" class="nav-item">行为预警</router-link>
        <router-link to="/profile" class="nav-item">个人信息</router-link>
      </nav>

      <div class="header-right">
        <div class="status-item">
          <span>系统状态:</span>
          <span class="status-value">运行中</span>
        </div>
        <i class="fa fa-question-circle"></i>
        <div class="user-avatar">
          <i class="fa fa-user"></i>
        </div>
      </div>
    </header>

    <!-- 主内容区 -->
    <main class="main-content">
      <div class="content-grid">
        <!-- 左侧视频区 -->
        <div class="video-column">
          <div class="card video-matrix-card">
            <div class="card-header">
              <h2>视频监控矩阵</h2>
              <div class="btn-group">
                <el-button size="small" @click="refreshVideos">
                  <el-icon><Refresh /></el-icon> 刷新
                </el-button>
                <el-button size="small" @click="toggleCarousel">
                  <el-icon><VideoPlay /></el-icon> 轮播 (5s)
                </el-button>
                <el-button size="small" @click="fullScreen">
                  <el-icon><FullScreen /></el-icon> 全屏
                </el-button>
              </div>
            </div>
            
            <!-- 3×3视频矩阵 -->
            <div class="video-grid">
              <div v-for="video in videoList" :key="video.id" 
                   :class="['video-item', { 'red-blink': video.status === '异常' }]">
                <div class="video-placeholder">
                  <img :src="video.streamUrl" alt="监控画面" class="video-image">
                  <div class="video-overlay">
                    <div class="video-info">
                      <p>设备ID: {{ video.id }}</p>
                      <p>延迟: {{ video.latency }} | 分辨率: {{ video.resolution }}</p>
                    </div>
                  </div>
                </div>
                <div class="video-tag location-tag">
                  <span :class="['status-dot', { 'bg-success': video.status === '正常', 'bg-danger': video.status === '异常' }]"></span>
                  <span>{{ video.location }}</span>
                </div>
                <div v-if="video.status === '异常'" class="video-tag status-tag danger-tag">
                  {{ video.status }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧告警区 -->
        <div class="alert-column">
          <!-- 实时告警 -->
          <div class="card alert-list-card">
            <h2>实时告警 ({{ realTimeAlerts.length }})</h2>
            <div class="alert-list">
              <div v-for="alert in realTimeAlerts" :key="alert.id" class="alert-item">
                <div class="alert-icon">
                  <el-icon><WarningFilled /></el-icon>
                </div>
                <div class="alert-content">
                  <p class="alert-title">{{ alert.type }}</p>
                  <p class="alert-detail">
                    <span class="text-primary">{{ alert.location }}</span> 
                    于 <span class="text-warning">{{ alert.time }}</span> 发生
                  </p>
                </div>
                <el-tag :type="alert.level === '高' ? 'danger' : 'warning'" size="small">{{ alert.level }}</el-tag>
              </div>
            </div>
          </div>

          <!-- 告警统计 -->
          <div class="card stats-card">
            <h2>告警统计</h2>
            <div class="stats-grid">
              <div class="stat-item">
                <p class="stat-value text-danger">{{ stats.totalAlerts }}</p>
                <p class="stat-label">总告警数</p>
              </div>
              <div class="stat-item">
                <p class="stat-value text-warning">{{ stats.unhandledAlerts }}</p>
                <p class="stat-label">待处理</p>
              </div>
              <div class="stat-item">
                <p class="stat-value text-primary">{{ stats.todayAlerts }}</p>
                <p class="stat-label">今日告警</p>
              </div>
              <div class="stat-item">
                <p class="stat-value text-success">{{ stats.handledRate }}%</p>
                <p class="stat-label">处理率</p>
              </div>
            </div>
          </div>

          <!-- 告警类型分布图 -->
          <div class="card chart-card">
            <h2>告警类型分布</h2>
            <div class="chart-container" ref="alertTypeChartRef"></div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { deviceAPI, alertAPI } from '@/api'
import { ElMessage } from 'element-plus'

const videoList = ref([])
const realTimeAlerts = ref([])
const stats = ref({})
const alertTypeChartRef = ref(null)
let alertTypeChart = null

// 模拟视频流刷新
const refreshVideos = () => {
  videoList.value.forEach(video => {
    // 模拟视频流地址变化
    video.streamUrl = `https://picsum.photos/640/360?random=${Math.random()}`
    // 模拟延迟变化
    video.latency = (Math.random() * 1.5 + 0.5).toFixed(1) + 's'
  })
  ElMessage.success('视频流已刷新')
}

// 模拟轮播
const isCarousel = ref(false)
let carouselTimer = null
const toggleCarousel = () => {
  isCarousel.value = !isCarousel.value
  if (isCarousel.value) {
    ElMessage.success('开始轮播')
    // 实际应用中需要实现视频切换逻辑
  } else {
    ElMessage.info('停止轮播')
    clearInterval(carouselTimer)
  }
}

// 模拟全屏
const fullScreen = () => {
  ElMessage.info('进入全屏模式 (需手动实现)')
}

// 初始化图表
const initChart = (data) => {
  if (!alertTypeChartRef.value) return
  alertTypeChart = echarts.init(alertTypeChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      textStyle: {
        color: '#c8d0e8'
      }
    },
    series: [
      {
        name: '告警类型',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['60%', '50%'],
        data: data,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        },
        label: {
          color: '#c8d0e8',
          formatter: '{b}: {c} ({d}%)'
        }
      }
    ]
  }
  alertTypeChart.setOption(option)
}

// 加载数据
const fetchData = async () => {
  try {
    // 模拟设备列表 (视频流)
    const deviceRes = await deviceAPI.getList({ pageSize: 9 })
    videoList.value = deviceRes.list.map((item, index) => ({
      id: item.deviceId,
      location: item.areaName,
      status: index % 5 === 0 ? '异常' : '正常', // 模拟异常状态
      latency: (Math.random() * 1.5 + 0.5).toFixed(1) + 's',
      resolution: index % 3 === 0 ? '720p' : '1080p',
      streamUrl: `https://picsum.photos/640/360?random=${index}`
    }))

    // 实时告警
    const alertRes = await alertAPI.getList({ pageSize: 5, status: '未处理' })
    realTimeAlerts.value = alertRes.list.map(item => ({
      id: item.id,
      type: item.alertType,
      location: item.areaName,
      time: item.alertTime,
      level: item.alertLevel
    }))

    // 告警统计
    stats.value = await alertAPI.getStatistics()
    
    // 告警类型分布
    initChart(stats.value.typeDistribution)

  } catch (error) {
    console.error('加载实时监控数据失败:', error)
    ElMessage.error('加载数据失败')
  }
}

onMounted(() => {
  fetchData()
  window.addEventListener('resize', () => {
    alertTypeChart && alertTypeChart.resize()
  })
})

onUnmounted(() => {
  clearInterval(carouselTimer)
  alertTypeChart && alertTypeChart.dispose()
})
</script>

<style scoped>
/* 顶部导航栏样式 (与Dashboard一致) */
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: #0a0e1a;
  border-bottom: 1px solid rgba(0, 212, 255, 0.3);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  z-index: 1000;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-left i {
  font-size: 28px;
  color: #00d4ff;
}

.header-left h1 {
  font-size: 20px;
  font-weight: bold;
  color: #00d4ff;
}

.nav {
  display: flex;
  gap: 32px;
}

.nav-item {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  transition: color 0.3s;
}

.nav-item:hover,
.nav-item.active {
  color: #00d4ff;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.status-item {
  display: flex;
  gap: 8px;
  color: rgba(255, 255, 255, 0.7);
}

.status-value {
  color: #52c41a;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(0, 212, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00d4ff;
}

/* 主内容区样式 */
.monitor-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #0a0e1a, #121826);
}

.main-content {
  padding: 88px 24px 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.content-grid {
  display: grid;
  grid-template-columns: 3fr 1fr; /* 视频区占3/4, 告警区占1/4 */
  gap: 24px;
}

.card {
  background: #142033;
  border: 1px solid rgba(0, 212, 255, 0.3);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 0 10px rgba(0, 212, 255, 0.2);
  margin-bottom: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.card h2 {
  font-size: 18px;
  font-weight: bold;
  color: white;
}

/* 视频矩阵样式 */
.video-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.video-item {
  position: relative;
  border-radius: 6px;
  overflow: hidden;
  transition: all 0.3s;
  border: 1px solid transparent;
}

.video-item:hover {
  border-color: #00d4ff;
  box-shadow: 0 0 15px rgba(0, 212, 255, 0.5);
}

.video-placeholder {
  aspect-ratio: 16 / 9;
  background: #0a0e1a;
  display: flex;
  align-items: center;
  justify-content: center;
}

.video-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(10, 14, 26, 0.7), transparent);
  opacity: 0;
  transition: opacity 0.3s;
  display: flex;
  align-items: flex-end;
}

.video-item:hover .video-overlay {
  opacity: 1;
}

.video-info {
  padding: 8px;
  font-size: 12px;
  color: #c8d0e8;
}

.video-tag {
  position: absolute;
  top: 8px;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
  display: flex;
  align-items: center;
}

.location-tag {
  left: 8px;
  background: rgba(10, 14, 26, 0.7);
  color: #c8d0e8;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-right: 4px;
}

.bg-success {
  background-color: #52c41a;
}

.bg-danger {
  background-color: #ff4d4f;
}

.status-tag {
  right: 8px;
  color: white;
}

.danger-tag {
  background: rgba(255, 77, 79, 0.7);
}

/* 告警区样式 */
.alert-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.alert-list {
  max-height: 300px;
  overflow-y: auto;
}

.alert-item {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px dashed rgba(0, 212, 255, 0.1);
}

.alert-item:last-child {
  border-bottom: none;
}

.alert-icon {
  font-size: 24px;
  color: #ff4d4f;
  margin-right: 12px;
}

.alert-content {
  flex-grow: 1;
}

.alert-title {
  font-weight: bold;
  color: white;
  margin-bottom: 2px;
}

.alert-detail {
  font-size: 12px;
  color: #a1a9c5;
}

.text-primary {
  color: #00d4ff;
}

.text-warning {
  color: #faad14;
}

/* 告警统计样式 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  text-align: center;
}

.stat-item {
  background: rgba(0, 212, 255, 0.05);
  padding: 15px 10px;
  border-radius: 6px;
  border: 1px solid rgba(0, 212, 255, 0.1);
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #a1a9c5;
}

.chart-container {
  height: 200px;
}

/* 动画 */
@keyframes redBlink {
  from { box-shadow: 0 0 5px rgba(255,77,79,0.5); }
  to { box-shadow: 0 0 15px rgba(255,77,79,0.8); }
}

.red-blink {
  animation: redBlink 1s infinite alternate;
}
</style>

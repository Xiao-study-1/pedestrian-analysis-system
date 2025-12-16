<template>
  <div class="dashboard-container">
    <!-- 顶部导航栏 -->
    <header class="header">
      <div class="header-left">
        <i class="fa fa-line-chart"></i>
        <h1>行人交通管控智能分析系统</h1>
      </div>

      <nav class="nav">
        <router-link to="/dashboard" class="nav-item active">首页</router-link>
        <router-link to="/monitor" class="nav-item">实时监控</router-link>
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
        <!-- 左栏 -->
        <div class="left-column">
          <!-- 违规行为TOP5 -->
          <div class="card">
            <div class="card-header">
              <h2>行人违规行为 TOP5</h2>
              <el-select v-model="timeRange" size="small">
                <el-option label="今日" value="today" />
                <el-option label="本周" value="week" />
                <el-option label="本月" value="month" />
              </el-select>
            </div>
            <div class="chart-container" ref="violationChartRef"></div>
          </div>

          <!-- 设备在线状态 -->
          <div class="card">
            <h2>设备在线状态</h2>
            <div class="device-status">
              <div v-for="item in deviceStatus" :key="item.name" class="status-item">
                <div class="status-label">
                  <span>{{ item.name }}</span>
                  <span class="status-value">{{ item.rate }}</span>
                </div>
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: item.rate + '%' }"></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 中栏 -->
        <div class="middle-column">
          <!-- 实时监控 -->
          <div class="card">
            <div class="card-header">
              <h2>实时监控</h2>
              <div class="btn-group">
                <el-button size="small">上一个</el-button>
                <el-button size="small">下一个</el-button>
              </div>
            </div>
            <div class="heatmap-container" ref="heatmapRef"></div>
          </div>

          <!-- 行为类型和处置结果 -->
          <div class="chart-row">
            <div class="card">
              <h2>行人行为类型占比</h2>
              <div class="chart-container" ref="behaviorChartRef"></div>
            </div>
            <div class="card">
              <h2>行为处置结果占比</h2>
              <div class="chart-container" ref="disposalChartRef"></div>
            </div>
          </div>
        </div>

        <!-- 右栏 -->
        <div class="right-column">
          <!-- 人流量趋势 -->
          <div class="card">
            <h2>行人流量变化趋势</h2>
            <div class="chart-container" ref="trendChartRef"></div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { dashboardAPI } from '@/api'

const timeRange = ref('today')
const violationChartRef = ref(null)
const behaviorChartRef = ref(null)
const disposalChartRef = ref(null)
const trendChartRef = ref(null)
const heatmapRef = ref(null)

const deviceStatus = ref([
  { name: '所有路口', rate: 67 },
  { name: '学校区', rate: 84 },
  { name: '商圈', rate: 60 },
  { name: '医院周边', rate: 50 },
  { name: '交通枢纽', rate: 61 }
])

let charts = []

// 初始化图表
const initCharts = async () => {
  // 违规行为TOP5
  const violationChart = echarts.init(violationChartRef.value)
  const violationData = await dashboardAPI.getViolationTop5({ timeRange: timeRange.value })
  violationChart.setOption({
    grid: { left: '15%', right: '5%', top: '5%', bottom: '5%' },
    xAxis: {
      type: 'value',
      axisLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.3)' } },
      splitLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.1)' } }
    },
    yAxis: {
      type: 'category',
      data: violationData.map(item => item.violationType),
      axisLine: { show: false }
    },
    series: [{
      type: 'bar',
      data: violationData.map(item => item.count),
      itemStyle: { color: '#00d4ff', borderRadius: 4 }
    }]
  })
  charts.push(violationChart)

  // 行为类型占比
  const behaviorChart = echarts.init(behaviorChartRef.value)
  const behaviorData = await dashboardAPI.getBehaviorRatio()
  behaviorChart.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: behaviorData.behaviors.map(item => ({
        name: item.type,
        value: item.count
      })),
      label: { color: '#c8d0e8' }
    }]
  })
  charts.push(behaviorChart)

  // 处置结果占比
  const disposalChart = echarts.init(disposalChartRef.value)
  const disposalData = await dashboardAPI.getDisposalRatio()
  disposalChart.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: disposalData.map(item => ({
        name: item.type,
        value: item.percentage
      })),
      label: { color: '#c8d0e8' }
    }]
  })
  charts.push(disposalChart)

  // 人流量趋势
  const trendChart = echarts.init(trendChartRef.value)
  const trendData = await dashboardAPI.getTrafficTrend()
  trendChart.setOption({
    grid: { left: '10%', right: '5%', top: '15%', bottom: '10%' },
    xAxis: {
      type: 'category',
      data: trendData.dates,
      axisLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.3)' } }
    },
    yAxis: {
      type: 'value',
      axisLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.3)' } },
      splitLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.1)' } }
    },
    series: [
      {
        name: '日均人流量',
        type: 'line',
        data: trendData.avgFlow,
        smooth: true,
        itemStyle: { color: '#39FF14' }
      },
      {
        name: '高峰时段人数',
        type: 'bar',
        data: trendData.peakFlow,
        itemStyle: { color: '#00d4ff' }
      }
    ]
  })
  charts.push(trendChart)
}

onMounted(() => {
  initCharts()
  
  // 监听窗口大小变化
  window.addEventListener('resize', () => {
    charts.forEach(chart => chart.resize())
  })
})

onUnmounted(() => {
  charts.forEach(chart => chart.dispose())
})
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #0a0e1a, #121826);
}

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

.main-content {
  padding: 88px 24px 24px;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  gap: 24px;
}

.left-column,
.middle-column,
.right-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.card {
  background: #142033;
  border: 1px solid rgba(0, 212, 255, 0.3);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 0 10px rgba(0, 212, 255, 0.2);
}

.card h2 {
  font-size: 18px;
  font-weight: bold;
  color: white;
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.chart-container {
  height: 250px;
}

.heatmap-container {
  height: 320px;
  background: rgba(10, 14, 26, 0.5);
  border: 1px solid rgba(0, 212, 255, 0.3);
  border-radius: 8px;
}

.chart-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.device-status {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.status-label {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 14px;
}

.progress-bar {
  height: 8px;
  background: rgba(10, 14, 26, 0.5);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #00d4ff;
  border-radius: 4px;
  transition: width 0.3s;
}
</style>

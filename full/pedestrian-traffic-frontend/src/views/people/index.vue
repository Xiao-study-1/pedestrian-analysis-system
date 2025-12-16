<template>
  <div class="people-container">
    <!-- 顶部导航栏 (保持与Dashboard一致) -->
    <header class="header">
      <div class="header-left">
        <i class="fa fa-line-chart"></i>
        <h1>行人交通管控智能分析系统</h1>
      </div>

      <nav class="nav">
        <router-link to="/dashboard" class="nav-item">首页</router-link>
        <router-link to="/monitor" class="nav-item">实时监控</router-link>
        <router-link to="/people" class="nav-item active">人流分析</router-link>
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
      <!-- 筛选栏 -->
      <div class="card filter-card">
        <div class="filter-row">
          <!-- 时间胶囊 -->
          <el-radio-group v-model="timeRange" size="small">
            <el-radio-button label="today">今日</el-radio-button>
            <el-radio-button label="week">本周</el-radio-button>
            <el-radio-button label="month">本月</el-radio-button>
          </el-radio-group>
          
          <!-- 区域选择 -->
          <el-select v-model="selectedArea" placeholder="选择区域" size="small">
            <el-option label="全区域" value="all" />
            <el-option label="主城区" value="main" />
            <el-option label="学校区" value="school" />
            <el-option label="商业区" value="business" />
            <el-option label="医院周边" value="hospital" />
            <el-option label="交通枢纽" value="hub" />
          </el-select>
          
          <!-- 对比模式 -->
          <div class="compare-switch">
            <el-switch v-model="compareMode" active-text="对比模式" />
          </div>
          
          <!-- 导出按钮 -->
          <el-button size="small" @click="exportData">
            <el-icon><Download /></el-icon> 导出数据
          </el-button>
        </div>
      </div>
      
      <!-- 热力图 -->
      <div class="card heatmap-card">
        <h2>区域人流热力图</h2>
        <div class="heatmap-wrapper">
          <!-- 模拟地图底图 -->
          <div class="map-base"></div>
          
          <!-- 道路网络 (简化) -->
          <div class="road-network">
            <div class="road horizontal top-1/2"></div>
            <div class="road vertical left-1/3"></div>
            <div class="road vertical left-2/3"></div>
            <div class="road horizontal top-1/3"></div>
            <div class="road horizontal top-2/3"></div>
          </div>
          
          <!-- 热力图 (使用ECharts实现) -->
          <div class="heatmap-chart" ref="heatmapChartRef"></div>
          
          <!-- 热力图图例 -->
          <div class="heatmap-legend">
            <p class="text-subtitle mb-2">人群密度</p>
            <div class="legend-item">
              <div class="color-box bg-primary"></div>
              <span>高 (500+ 人)</span>
            </div>
            <div class="legend-item">
              <div class="color-box bg-primary-medium"></div>
              <span>中 (200-500 人)</span>
            </div>
            <div class="legend-item">
              <div class="color-box bg-primary-dark"></div>
              <span>低 (0-200 人)</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 统计卡片 -->
      <div class="stats-grid">
        <div class="card stat-card">
          <div class="stat-header">
            <div>
              <p class="stat-label">总流量</p>
              <h3 class="stat-value text-primary">{{ stats.totalFlow.value }}</h3>
            </div>
            <div class="stat-icon">
              <el-icon><UserFilled /></el-icon>
            </div>
          </div>
          <div class="stat-trend">
            <span :class="['trend-text', stats.totalFlow.change > 0 ? 'text-success' : 'text-danger']">
              <el-icon><component :is="stats.totalFlow.change > 0 ? 'CaretTop' : 'CaretBottom'" /></el-icon> {{ Math.abs(stats.totalFlow.change) }}%
            </span>
            <span class="text-subtitle">较昨日同期</span>
          </div>
          <div class="mini-chart" ref="totalFlowChartRef"></div>
        </div>
        
        <div class="card stat-card">
          <div class="stat-header">
            <div>
              <p class="stat-label">平均停留时长</p>
              <h3 class="stat-value text-primary">{{ stats.avgStayTime.value }} 分钟</h3>
            </div>
            <div class="stat-icon">
              <el-icon><Clock /></el-icon>
            </div>
          </div>
          <div class="stat-trend">
            <span :class="['trend-text', stats.avgStayTime.change > 0 ? 'text-danger' : 'text-success']">
              <el-icon><component :is="stats.avgStayTime.change > 0 ? 'CaretTop' : 'CaretBottom'" /></el-icon> {{ Math.abs(stats.avgStayTime.change) }}%
            </span>
            <span class="text-subtitle">较昨日同期</span>
          </div>
          <div class="mini-chart" ref="stayTimeChartRef"></div>
        </div>
        
        <div class="card stat-card">
          <div class="stat-header">
            <div>
              <p class="stat-label">高峰时段</p>
              <h3 class="stat-value text-primary">{{ stats.peakTime.value }}</h3>
            </div>
            <div class="stat-icon">
              <el-icon><TrendCharts /></el-icon>
            </div>
          </div>
          <div class="stat-trend">
            <span :class="['trend-text', stats.peakTime.change === '缩短' ? 'text-success' : 'text-danger']">
              <el-icon><component :is="stats.peakTime.change === '缩短' ? 'CaretBottom' : 'CaretTop'" /></el-icon> {{ stats.peakTime.change }}
            </span>
            <span class="text-subtitle">较昨日</span>
          </div>
          <div class="mini-chart" ref="peakTimeChartRef"></div>
        </div>
        
        <div class="card stat-card">
          <div class="stat-header">
            <div>
              <p class="stat-label">重点区域</p>
              <h3 class="stat-value text-primary">{{ stats.keyArea.value }}</h3>
            </div>
            <div class="stat-icon">
              <el-icon><LocationFilled /></el-icon>
            </div>
          </div>
          <div class="stat-trend">
            <span :class="['trend-text', stats.keyArea.change > 0 ? 'text-danger' : 'text-success']">
              <el-icon><component :is="stats.keyArea.change > 0 ? 'CaretTop' : 'CaretBottom'" /></el-icon> {{ Math.abs(stats.keyArea.change) }}%
            </span>
            <span class="text-subtitle">较昨日同期</span>
          </div>
          <div class="mini-chart" ref="keyAreaChartRef"></div>
        </div>
      </div>
      
      <!-- 趋势图和路径分析 -->
      <div class="trend-path-grid">
        <!-- 趋势图 -->
        <div class="card trend-chart-card">
          <h2>人流与违规趋势</h2>
          <div class="trend-chart" ref="trendChartRef"></div>
        </div>
        
        <!-- 路径分析 -->
        <div class="card path-analysis-card">
          <h2>热门路径分析</h2>
          <div class="path-list">
            <div v-for="(path, index) in pathAnalysis" :key="index" class="path-item">
              <div class="path-header">
                <h3 class="path-title">{{ path.name }}</h3>
                <el-tag v-if="index === 0" type="success" size="small">频次最高</el-tag>
                <el-tag v-else type="info" size="small">第{{ index + 1 }}名</el-tag>
              </div>
              <div class="path-details">
                <span>平均耗时: {{ path.avgTime }}</span>
                <span>日均流量: {{ path.dailyFlow }}人</span>
              </div>
              <div class="path-visual">
                <!-- 简化的路径可视化 -->
                <div class="path-line"></div>
                <div class="path-dot start-dot"></div>
                <div class="path-dot end-dot"></div>
                <div v-for="(dot, i) in path.dots" :key="i" 
                     :style="{ left: dot.position }" 
                     class="path-dot flow-dot pulse-animation"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import * as echarts from 'echarts'
import { trafficAPI } from '@/api'
import { ElMessage } from 'element-plus'

const timeRange = ref('today')
const selectedArea = ref('all')
const compareMode = ref(false)

const stats = ref({
  totalFlow: { value: '24,587', change: 12.5, data: { labels: [], values: [] } },
  avgStayTime: { value: '8.4', change: 3.2, data: { labels: [], values: [] } },
  peakTime: { value: '17:00-19:00', change: '缩短', data: { labels: [], values: [] } },
  keyArea: { value: '商业中心', change: 8.7, data: { labels: [], values: [] } }
})

const pathAnalysis = ref([
  { name: '学校 → 地铁站', avgTime: '12分钟', dailyFlow: '2,450', dots: [{ position: '25%' }, { position: '50%' }, { position: '75%' }] },
  { name: '商业中心 → 公交站', avgTime: '8分钟', dailyFlow: '1,870', dots: [{ position: '30%' }, { position: '60%' }] },
  { name: '医院 → 商业区', avgTime: '15分钟', dailyFlow: '1,240', dots: [{ position: '40%' }] }
])

const heatmapChartRef = ref(null)
const totalFlowChartRef = ref(null)
const stayTimeChartRef = ref(null)
const peakTimeChartRef = ref(null)
const keyAreaChartRef = ref(null)
const trendChartRef = ref(null)

let charts = {}

const exportData = () => {
  ElMessage.success('数据导出功能已触发 (需后端实现)')
}

// 初始化迷你图表
const initMiniChart = (ref, data, color, type = 'line') => {
  if (!ref.value) return
  const chart = echarts.init(ref.value)
  
  let seriesOption = {
    type: type,
    data: data.values,
    itemStyle: { color: color }
  }

  if (type === 'line') {
    seriesOption = {
      ...seriesOption,
      smooth: true,
      showSymbol: false,
      lineStyle: { width: 1.5, color: color },
      areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: color + '33' }, { offset: 1, color: color + '00' }]) }
    }
  } else if (type === 'bar') {
    seriesOption = {
      ...seriesOption,
      barWidth: '60%'
    }
  }

  chart.setOption({
    grid: { left: 0, top: 0, right: 0, bottom: 0 },
    xAxis: { type: 'category', show: false, data: data.labels },
    yAxis: { type: 'value', show: false },
    series: [seriesOption]
  })
  charts[ref.value.id] = chart
}

// 初始化趋势图
const initTrendChart = (data) => {
  if (!trendChartRef.value) return
  const chart = echarts.init(trendChartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'cross' } },
    legend: { data: ['人流量', '违规次数'], textStyle: { color: '#c8d0e8' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: data.labels,
      axisLine: { lineStyle: { color: 'rgba(0, 212, 255, 0.3)' } },
      axisLabel: { color: '#a1a9c5' }
    },
    yAxis: [
      {
        type: 'value',
        name: '人流量',
        position: 'left',
        axisLine: { lineStyle: { color: '#00d4ff' } },
        splitLine: { lineStyle: { color: 'rgba(0, 212, 255, 0.1)' } },
        axisLabel: { color: '#a1a9c5' }
      },
      {
        type: 'value',
        name: '违规次数',
        position: 'right',
        axisLine: { lineStyle: { color: '#ff4d4f' } },
        splitLine: { show: false },
        axisLabel: { color: '#a1a9c5' }
      }
    ],
    series: [
      {
        name: '人流量',
        type: 'line',
        yAxisIndex: 0,
        data: data.flow,
        smooth: true,
        itemStyle: { color: '#00d4ff' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: '#00d4ff33' }, { offset: 1, color: '#00d4ff00' }]) }
      },
      {
        name: '违规次数',
        type: 'line',
        yAxisIndex: 1,
        data: data.violation,
        smooth: true,
        itemStyle: { color: '#ff4d4f' }
      }
    ]
  })
  charts[trendChartRef.value.id] = chart
}

// 初始化热力图 (使用散点图模拟)
const initHeatmapChart = (data) => {
  if (!heatmapChartRef.value) return
  const chart = echarts.init(heatmapChartRef.value)
  chart.setOption({
    grid: { left: 0, top: 0, right: 0, bottom: 0 },
    xAxis: { show: false, min: 0, max: 100 },
    yAxis: { show: false, min: 0, max: 100 },
    series: [{
      type: 'scatter',
      coordinateSystem: 'cartesian2d',
      data: data,
      symbolSize: function (val) {
        return val[2] / 10; // 根据人流量大小调整点的大小
      },
      itemStyle: {
        shadowBlur: 10,
        shadowColor: 'rgba(0, 212, 255, 0.5)',
        shadowOffsetY: 5,
        color: new echarts.graphic.RadialGradient(0.4, 0.3, 1, [{
          offset: 0,
          color: 'rgba(0, 212, 255, 0.9)'
        }, {
          offset: 1,
          color: 'rgba(0, 212, 255, 0.1)'
        }])
      }
    }]
  })
  charts[heatmapChartRef.value.id] = chart
}

// 加载数据
const fetchData = async () => {
  try {
    // 统计卡片数据
    const totalFlowData = await trafficAPI.getTotalFlow({ timeRange: timeRange.value, area: selectedArea.value })
    stats.value.totalFlow = totalFlowData.totalFlow
    stats.value.avgStayTime = totalFlowData.avgStayTime
    stats.value.peakTime = totalFlowData.peakTime
    stats.value.keyArea = totalFlowData.keyArea
    
    // 迷你图表数据
    initMiniChart(totalFlowChartRef, totalFlowData.totalFlow.data, '#00d4ff')
    initMiniChart(stayTimeChartRef, totalFlowData.avgStayTime.data, '#00d4ff')
    // 峰值图使用柱状图
    initMiniChart(peakTimeChartRef, totalFlowData.peakTime.data, '#00d4ff', 'bar')
    initMiniChart(keyAreaChartRef, totalFlowData.keyArea.data, '#00d4ff')

    // 趋势图数据
    const trendData = await trafficAPI.getTrend({ timeRange: timeRange.value, area: selectedArea.value })
    initTrendChart(trendData)

    // 热力图数据
    const heatmapData = await trafficAPI.getHeatmap()
    initHeatmapChart(heatmapData)

  } catch (error) {
    console.error('加载人流分析数据失败:', error)
    ElMessage.error('加载数据失败')
  }
}

watch([timeRange, selectedArea], fetchData)

onMounted(() => {
  fetchData()
  window.addEventListener('resize', () => {
    Object.values(charts).forEach(chart => chart.resize())
  })
})

onUnmounted(() => {
  Object.values(charts).forEach(chart => chart.dispose())
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
.people-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #0a0e1a, #121826);
}

.main-content {
  padding: 88px 24px 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.card {
  background: #142033;
  border: 1px solid rgba(0, 212, 255, 0.3);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 0 10px rgba(0, 212, 255, 0.2);
  margin-bottom: 24px;
}

/* 筛选栏样式 */
.filter-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
}

.compare-switch {
  margin-left: auto;
}

/* 热力图样式 */
.heatmap-card h2 {
  font-size: 18px;
  font-weight: bold;
  color: white;
  margin-bottom: 16px;
}

.heatmap-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  background: #0f1420;
  border-radius: 8px;
  overflow: hidden;
}

.map-base {
  position: absolute;
  inset: 0;
  background-image: url('https://picsum.photos/1200/675?random=20'); /* 模拟地图底图 */
  background-size: cover;
  background-position: center;
  opacity: 0.2;
}

.road-network {
  position: absolute;
  inset: 0;
}

.road {
  position: absolute;
  background: rgba(0, 212, 255, 0.3);
}

.road.horizontal {
  left: 0;
  right: 0;
  height: 1px;
  transform: translateY(-50%);
}

.road.vertical {
  top: 0;
  bottom: 0;
  width: 1px;
  transform: translateX(-50%);
}

.top-1\/2 { top: 50%; }
.left-1\/3 { left: 33.333%; }
.left-2\/3 { left: 66.666%; }
.top-1\/3 { top: 33.333%; }
.top-2\/3 { top: 66.666%; }

.heatmap-chart {
  position: absolute;
  inset: 0;
}

.heatmap-legend {
  position: absolute;
  bottom: 16px;
  right: 16px;
  background: rgba(10, 14, 26, 0.8);
  padding: 12px;
  border-radius: 8px;
  font-size: 12px;
  color: #c8d0e8;
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}

.color-box {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 8px;
}

.bg-primary { background-color: #00d4ff; }
.bg-primary-medium { background-color: #0099ff; }
.bg-primary-dark { background-color: #0066cc; }

/* 统计卡片样式 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

.stat-card {
  padding: 16px;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.stat-label {
  font-size: 12px;
  color: #a1a9c5;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  margin-top: 4px;
}

.stat-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(0, 212, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00d4ff;
  font-size: 18px;
}

.stat-trend {
  display: flex;
  align-items: center;
  font-size: 12px;
  margin-bottom: 8px;
}

.trend-text {
  margin-right: 8px;
  display: flex;
  align-items: center;
}

.text-success { color: #52c41a; }
.text-danger { color: #ff4d4f; }
.text-subtitle { color: #a1a9c5; }

.mini-chart {
  height: 40px;
}

/* 趋势图和路径分析样式 */
.trend-path-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}

.trend-chart {
  height: 320px;
}

.path-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.path-item {
  background: #0a0e1a;
  padding: 16px;
  border-radius: 6px;
  border: 1px solid rgba(0, 212, 255, 0.1);
}

.path-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.path-title {
  font-size: 14px;
  font-weight: bold;
  color: white;
}

.path-details {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #a1a9c5;
  margin-bottom: 12px;
}

.path-visual {
  height: 20px;
  position: relative;
  overflow: hidden;
}

.path-line {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: rgba(0, 212, 255, 0.3);
  transform: translateY(-50%);
}

.path-dot {
  position: absolute;
  top: 50%;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  transform: translate(-50%, -50%);
}

.start-dot, .end-dot {
  background: #00d4ff;
  width: 10px;
  height: 10px;
}

.start-dot { left: 0; }
.end-dot { left: 100%; }

.flow-dot {
  background: rgba(0, 212, 255, 0.7);
  width: 6px;
  height: 6px;
}

@keyframes pulse-animation {
  0% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
  50% { transform: translate(-50%, -50%) scale(1.5); opacity: 0.5; }
  100% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
}

.pulse-animation {
  animation: pulse-animation 2s infinite;
}
</style>

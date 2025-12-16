<template>
  <div class="remind-container">
    <!-- 顶部导航栏 (保持与Dashboard一致) -->
    <header class="header">
      <div class="header-left">
        <i class="fa fa-line-chart"></i>
        <h1>行人交通管控智能分析系统</h1>
      </div>

      <nav class="nav">
        <router-link to="/dashboard" class="nav-item">首页</router-link>
        <router-link to="/monitor" class="nav-item">实时监控</router-link>
        <router-link to="/people" class="nav-item">人流分析</router-link>
        <router-link to="/remind" class="nav-item active">行为预警</router-link>
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
        <!-- 左侧告警列表和筛选 -->
        <div class="filter-list-column">
          <!-- 过滤区 -->
          <div class="card filter-card">
            <div class="space-y-4">
              <!-- 搜索框 -->
              <el-input v-model="filter.keyword" placeholder="搜索地点或事件类型" clearable>
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              
              <!-- 严重程度 -->
              <div>
                <label class="block text-sm text-subtitle mb-2">严重程度</label>
                <el-select v-model="filter.level" placeholder="选择严重程度" class="w-full">
                  <el-option label="全部" value="" />
                  <el-option label="紧急" value="紧急" />
                  <el-option label="高危" value="高危" />
                  <el-option label="一般" value="一般" />
                </el-select>
              </div>
              
              <!-- 状态筛选 -->
              <div>
                <label class="block text-sm text-subtitle mb-2">处理状态</label>
                <el-select v-model="filter.status" placeholder="选择处理状态" class="w-full">
                  <el-option label="全部" value="" />
                  <el-option label="未确认" value="未确认" />
                  <el-option label="处理中" value="处理中" />
                  <el-option label="已归档" value="已归档" />
                </el-select>
              </div>
              
              <!-- 时间范围 -->
              <div>
                <label class="block text-sm text-subtitle mb-2">时间范围</label>
                <el-date-picker
                  v-model="filter.dateRange"
                  type="daterange"
                  range-separator="至"
                  start-placeholder="开始日期"
                  end-placeholder="结束日期"
                  class="w-full"
                />
              </div>
              
              <!-- 重置和确认按钮 -->
              <div class="flex gap-2">
                <el-button @click="resetFilter" class="flex-1">重置</el-button>
                <el-button type="primary" @click="applyFilter" class="flex-1">确认筛选</el-button>
              </div>
            </div>
          </div>
          
          <!-- 告警列表 -->
          <div class="card alert-list-card">
            <div class="p-4 border-b border-subtitle/20">
              <h2 class="text-white text-xl font-bold">告警列表 <span class="text-sm text-subtitle font-normal ml-2">({{ totalAlerts }}条)</span></h2>
            </div>
            
            <div class="alert-list-wrapper">
              <div v-for="alert in alerts" :key="alert.id" 
                   :class="['alert-item', { 'pulse-alert': alert.level === '紧急' && alert.status === '未确认' }]"
                   @click="selectAlert(alert)">
                <div class="flex items-start">
                  <div :class="['alert-icon-wrapper', getLevelClass(alert.level, 'bg')]">
                    <el-icon><WarningFilled /></el-icon>
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="flex justify-between">
                      <h3 class="text-white font-medium truncate">{{ alert.type }}</h3>
                      <span :class="['text-xs', getLevelClass(alert.level, 'text-bg')]">{{ alert.level }}</span>
                    </div>
                    <p class="text-sm text-subtitle mt-1 truncate">地点：{{ alert.location }}</p>
                    <div class="flex justify-between items-center mt-2">
                      <span class="text-xs">{{ alert.time }}</span>
                      <span :class="['text-xs', getStatusClass(alert.status)]">{{ alert.status }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="pagination-wrapper">
              <el-pagination
                small
                layout="prev, pager, next"
                :total="totalAlerts"
                :page-size="filter.pageSize"
                :current-page="filter.pageNum"
                @current-change="handlePageChange"
              />
            </div>
          </div>
        </div>

        <!-- 右侧告警详情 -->
        <div class="detail-column">
          <div class="card detail-card">
            <h2 class="text-white text-xl font-bold mb-6">告警详情</h2>
            
            <div v-if="selectedAlert">
              <!-- 基础信息 -->
              <div class="detail-section">
                <h3 class="section-title">事件信息</h3>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">事件类型:</span>
                    <span class="info-value">{{ selectedAlert.type }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">严重程度:</span>
                    <span :class="['info-value', getLevelClass(selectedAlert.level, 'text')]">{{ selectedAlert.level }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">发生时间:</span>
                    <span class="info-value">{{ selectedAlert.time }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">发生地点:</span>
                    <span class="info-value">{{ selectedAlert.location }}</span>
                  </div>
                  <div class="info-item col-span-2">
                    <span class="info-label">详细描述:</span>
                    <span class="info-value">{{ selectedAlert.description }}</span>
                  </div>
                </div>
              </div>

              <!-- 现场快照 -->
              <div class="detail-section">
                <h3 class="section-title">现场快照</h3>
                <div class="snapshot-wrapper">
                  <img :src="selectedAlert.snapshotUrl" alt="现场快照" class="snapshot-image">
                  <div class="snapshot-overlay">
                    <el-button type="primary" size="small" @click="viewVideo">
                      <el-icon><VideoPlay /></el-icon> 查看录像
                    </el-button>
                  </div>
                </div>
              </div>

              <!-- 处置流程 -->
              <div class="detail-section">
                <h3 class="section-title">处置流程</h3>
                <el-steps :active="getStepIndex(selectedAlert.status)" finish-status="success" direction="vertical">
                  <el-step title="事件触发" :description="selectedAlert.time" />
                  <el-step title="系统自动确认" description="已完成自动识别和记录" />
                  <el-step title="人工介入处理" :description="selectedAlert.handler ? `处理人: ${selectedAlert.handler}` : '等待人工介入'" />
                  <el-step title="事件归档" description="处理结果已记录并归档" />
                </el-steps>
              </div>

              <!-- 处置操作 -->
              <div class="detail-section action-section">
                <h3 class="section-title">处置操作</h3>
                <div class="flex gap-4">
                  <el-button type="warning" :disabled="selectedAlert.status !== '未确认'" @click="handleAlert('处理中')">
                    <el-icon><Edit /></el-icon> 标记处理中
                  </el-button>
                  <el-button type="success" :disabled="selectedAlert.status === '已归档'" @click="handleAlert('已归档')">
                    <el-icon><Check /></el-icon> 归档事件
                  </el-button>
                  <el-button type="danger" @click="handleAlert('忽略')">
                    <el-icon><Close /></el-icon> 忽略误报
                  </el-button>
                </div>
              </div>
            </div>
            <div v-else class="text-center py-20 text-subtitle">
              请从左侧列表中选择一个告警事件查看详情
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { alertAPI } from '@/api'
import { ElMessage } from 'element-plus'

const filter = ref({
  keyword: '',
  level: '',
  status: '',
  dateRange: [],
  pageNum: 1,
  pageSize: 10
})

const alerts = ref([])
const totalAlerts = ref(0)
const selectedAlert = ref(null)

const getLevelClass = (level, type) => {
  const map = {
    '紧急': { text: 'text-urgent', bg: 'bg-urgent/20', 'text-bg': 'bg-urgent/20 text-urgent' },
    '高危': { text: 'text-highRisk', bg: 'bg-highRisk/20', 'text-bg': 'bg-highRisk/20 text-highRisk' },
    '一般': { text: 'text-normalRisk', bg: 'bg-normalRisk/20', 'text-bg': 'bg-normalRisk/20 text-normalRisk' }
  }
  return map[level] ? map[level][type] : 'text-subtitle'
}

const getStatusClass = (status) => {
  const map = {
    '未确认': 'bg-danger/20 text-danger',
    '处理中': 'bg-warning/20 text-warning',
    '已归档': 'bg-success/20 text-success'
  }
  return `text-xs px-2 py-0.5 rounded ${map[status] || 'bg-subtitle/20 text-subtitle'}`
}

const getStepIndex = (status) => {
  const map = {
    '未确认': 1,
    '处理中': 3,
    '已归档': 4
  }
  return map[status] || 1
}

const fetchData = async () => {
  try {
    const params = {
      ...filter.value,
      startTime: filter.value.dateRange?.[0] ? new Date(filter.value.dateRange[0]).toISOString() : undefined,
      endTime: filter.value.dateRange?.[1] ? new Date(filter.value.dateRange[1]).toISOString() : undefined,
    }
    
    const res = await alertAPI.getList(params)
    alerts.value = res.list
    totalAlerts.value = res.total
    
    // 默认选中第一个告警
    if (alerts.value.length > 0 && !selectedAlert.value) {
      selectedAlert.value = alerts.value[0]
    } else if (selectedAlert.value) {
      // 刷新当前选中的告警详情
      const currentAlert = alerts.value.find(a => a.id === selectedAlert.value.id)
      if (currentAlert) {
        selectedAlert.value = currentAlert
      } else {
        selectedAlert.value = alerts.value[0] || null
      }
    }

  } catch (error) {
    console.error('加载告警列表失败:', error)
    ElMessage.error('加载告警列表失败')
  }
}

const applyFilter = () => {
  filter.value.pageNum = 1
  fetchData()
}

const resetFilter = () => {
  filter.value = {
    keyword: '',
    level: '',
    status: '',
    dateRange: [],
    pageNum: 1,
    pageSize: 10
  }
  fetchData()
}

const handlePageChange = (val) => {
  filter.value.pageNum = val
  fetchData()
}

const selectAlert = (alert) => {
  selectedAlert.value = alert
}

const handleAlert = (action) => {
  if (!selectedAlert.value) return
  
  let newStatus = selectedAlert.value.status
  let message = ''
  
  if (action === '处理中' && selectedAlert.value.status === '未确认') {
    newStatus = '处理中'
    message = '已标记为处理中'
  } else if (action === '已归档') {
    newStatus = '已归档'
    message = '事件已归档'
  } else if (action === '忽略') {
    newStatus = '已归档' // 误报也归档
    message = '已忽略并归档'
  } else {
    ElMessage.warning('当前状态无法执行此操作')
    return
  }
  
  // 模拟后端更新
  selectedAlert.value.status = newStatus
  selectedAlert.value.handler = '当前用户'
  
  // 刷新列表
  fetchData()
  ElMessage.success(message)
}

const viewVideo = () => {
  ElMessage.info('正在跳转到实时监控页面查看录像...')
  // 实际应用中可以跳转到 monitor 页面并定位到对应设备
}

onMounted(() => {
  fetchData()
})

watch(filter.value, () => {
  // 仅在非分页操作时重置页码
  if (filter.value.pageNum !== 1) return
  fetchData()
}, { deep: true })
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
.remind-container {
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
  grid-template-columns: 400px 1fr; /* 左侧固定宽度, 右侧自适应 */
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

.filter-list-column {
  display: flex;
  flex-direction: column;
}

.alert-list-card {
  flex-grow: 1;
  padding: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.alert-list-wrapper {
  flex-grow: 1;
  overflow-y: auto;
  max-height: calc(100vh - 450px); /* 预估高度 */
}

.alert-item {
  padding: 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  cursor: pointer;
  transition: background-color 0.3s;
}

.alert-item:hover {
  background-color: rgba(0, 212, 255, 0.05);
}

.alert-icon-wrapper {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

/* 严重程度颜色 */
.text-urgent { color: #ff3333; }
.bg-urgent\/20 { background-color: rgba(255, 51, 51, 0.2); color: #ff3333; }
.text-highRisk { color: #faad14; }
.bg-highRisk\/20 { background-color: rgba(250, 173, 20, 0.2); color: #faad14; }
.text-normalRisk { color: #4e8cff; }
.bg-normalRisk\/20 { background-color: rgba(78, 140, 255, 0.2); color: #4e8cff; }

/* 状态颜色 */
.bg-danger\/20 { background-color: rgba(255, 77, 79, 0.2); color: #ff4d4f; }
.bg-warning\/20 { background-color: rgba(250, 173, 20, 0.2); color: #faad14; }
.bg-success\/20 { background-color: rgba(82, 196, 26, 0.2); color: #52c41a; }

/* 告警详情样式 */
.detail-column {
  flex-grow: 1;
}

.detail-card {
  min-height: calc(100vh - 112px);
}

.detail-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px dashed rgba(255, 255, 255, 0.1);
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  color: #00d4ff;
  margin-bottom: 15px;
  border-left: 3px solid #00d4ff;
  padding-left: 10px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.info-item {
  display: flex;
  flex-direction: column;
}

.info-item.col-span-2 {
  grid-column: span 2;
}

.info-label {
  font-size: 12px;
  color: #a1a9c5;
  margin-bottom: 4px;
}

.info-value {
  font-size: 14px;
  color: #c8d0e8;
}

.snapshot-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 6px;
  overflow: hidden;
}

.snapshot-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.snapshot-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.snapshot-wrapper:hover .snapshot-overlay {
  opacity: 1;
}

.action-section {
  border-bottom: none;
}

.pagination-wrapper {
  padding: 10px 0;
  text-align: center;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

/* 动画 */
@keyframes pulseAlert {
  0% { box-shadow: 0 0 0 0 rgba(255, 51, 51, 0.7); }
  70% { box-shadow: 0 0 0 10px rgba(255, 51, 51, 0); }
  100% { box-shadow: 0 0 0 0 rgba(255, 51, 51, 0); }
}

.pulse-alert {
  animation: pulseAlert 1.5s infinite;
}
</style>

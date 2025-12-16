<template>
  <div class="profile-container">
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
        <router-link to="/remind" class="nav-item">行为预警</router-link>
        <router-link to="/profile" class="nav-item active">个人信息</router-link>
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
        <!-- 左侧菜单 -->
        <div class="menu-column">
          <div class="card menu-card">
            <div class="user-info">
              <div class="avatar-wrapper">
                <el-avatar :size="96" :src="userInfo.avatar" />
                <div class="camera-icon" @click="changeAvatar">
                  <el-icon><Camera /></el-icon>
                </div>
              </div>
              <h3 class="text-white font-medium mt-3">{{ userInfo.name }}</h3>
              <p class="text-subtitle text-sm">{{ userInfo.role }}</p>
            </div>
            
            <el-menu
              :default-active="activeSection"
              class="profile-menu"
              @select="handleMenuSelect"
            >
              <el-menu-item index="basic-info">
                <el-icon><User /></el-icon>
                <span>基础信息</span>
              </el-menu-item>
              <el-menu-item index="account-security">
                <el-icon><Lock /></el-icon>
                <span>账户安全</span>
              </el-menu-item>
              <el-menu-item index="operation-log">
                <el-icon><Tickets /></el-icon>
                <span>操作日志</span>
              </el-menu-item>
              <el-menu-item index="notifications">
                <el-icon><Bell /></el-icon>
                <span>消息通知</span>
                <el-badge :value="unreadCount" :max="99" class="ml-auto" />
              </el-menu-item>
            </el-menu>
          </div>
        </div>
        
        <!-- 右侧内容区 -->
        <div class="content-column">
          <!-- 基础信息 -->
          <div id="basic-info" class="card content-section">
            <h2 class="section-title">基础信息</h2>
            <el-form :model="userInfo" label-width="100px" label-position="top" class="form-grid">
              <el-form-item label="姓名">
                <el-input v-model="userInfo.name" />
              </el-form-item>
              <el-form-item label="工号">
                <el-input v-model="userInfo.jobId" disabled />
              </el-form-item>
              <el-form-item label="所属部门">
                <el-select v-model="userInfo.department" placeholder="选择部门" class="w-full">
                  <el-option label="系统管理部" value="系统管理部" />
                  <el-option label="数据分析部" value="数据分析部" />
                  <el-option label="运维部" value="运维部" />
                </el-select>
              </el-form-item>
              <el-form-item label="联系电话">
                <el-input v-model="userInfo.phone" />
              </el-form-item>
              <el-form-item label="电子邮箱">
                <el-input v-model="userInfo.email" />
              </el-form-item>
              <el-form-item label="创建时间">
                <el-input v-model="userInfo.createTime" disabled />
              </el-form-item>
            </el-form>
            <div class="flex justify-end mt-6">
              <el-button @click="resetBasicInfo">取消</el-button>
              <el-button type="primary" @click="saveBasicInfo">保存修改</el-button>
            </div>
          </div>
          
          <!-- 账户安全 -->
          <div id="account-security" class="card content-section">
            <h2 class="section-title">账户安全</h2>
            
            <div class="space-y-8">
              <!-- 密码修改 -->
              <div>
                <h3 class="sub-section-title">密码修改</h3>
                <el-form :model="passwordForm" label-width="100px" label-position="top" class="form-grid">
                  <el-form-item label="当前密码">
                    <el-input v-model="passwordForm.oldPassword" type="password" show-password />
                  </el-form-item>
                  <el-form-item label="新密码">
                    <el-input v-model="passwordForm.newPassword" type="password" show-password />
                  </el-form-item>
                  <el-form-item label="确认新密码" class="md:col-span-2">
                    <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
                    
                    <!-- 密码强度 -->
                    <div class="password-strength">
                      <div class="flex justify-between text-xs mb-1">
                        <span>密码强度</span>
                        <span :class="getPasswordStrengthClass(passwordStrength)">{{ passwordStrengthText }}</span>
                      </div>
                      <el-progress :percentage="passwordStrength * 25" :show-text="false" :stroke-width="6" :color="getPasswordStrengthColor(passwordStrength)" />
                      <p class="text-xs text-subtitle mt-1">建议使用字母、数字和特殊符号的组合，长度不少于8位</p>
                    </div>
                  </el-form-item>
                </el-form>
                
                <div class="flex justify-end mt-4">
                  <el-button type="primary" size="small" @click="changePassword">确认修改</el-button>
                </div>
              </div>
              
              <!-- 登录历史 -->
              <div class="border-t border-subtitle/20 pt-6">
                <h3 class="sub-section-title">登录历史</h3>
                <el-table :data="loginHistory" style="width: 100%" class="login-history-table">
                  <el-table-column prop="time" label="登录时间" width="180" />
                  <el-table-column prop="ip" label="IP地址" width="120" />
                  <el-table-column prop="location" label="登录地点" width="150" />
                  <el-table-column prop="device" label="设备信息" />
                  <el-table-column prop="status" label="状态" width="80">
                    <template #default="{ row }">
                      <el-tag :type="row.status === '正常' ? 'success' : 'danger'" size="small">{{ row.status }}</el-tag>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
              
              <!-- 二次验证 -->
              <div class="border-t border-subtitle/20 pt-6">
                <h3 class="sub-section-title">二次验证</h3>
                <div class="flex items-center justify-between bg-dark p-4 rounded">
                  <div>
                    <p class="text-white">手机短信验证</p>
                    <p class="text-xs text-subtitle mt-1">开启后，登录时需要输入手机验证码</p>
                  </div>
                  <el-switch v-model="twoFactorAuth" />
                </div>
              </div>
            </div>
          </div>
          
          <!-- 操作日志 -->
          <div id="operation-log" class="card content-section">
            <h2 class="section-title">操作日志</h2>
            
            <div class="log-filter-row">
              <el-input v-model="logFilter.keyword" placeholder="搜索操作内容" clearable class="w-64">
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="logFilter.type" placeholder="操作类型" class="w-40">
                <el-option label="全部操作类型" value="" />
                <el-option label="系统设置" value="系统设置" />
                <el-option label="设备管理" value="设备管理" />
                <el-option label="数据查询" value="数据查询" />
              </el-select>
              <el-date-picker v-model="logFilter.date" type="date" placeholder="选择日期" />
              <el-button @click="fetchOperationLogs">
                <el-icon><Refresh /></el-icon> 刷新
              </el-button>
            </div>
            
            <!-- 时间轴 -->
            <div class="timeline-wrapper">
              <el-timeline>
                <el-timeline-item v-for="(log, index) in operationLogs" :key="index" :timestamp="log.time" placement="top">
                  <div class="log-item">
                    <el-tag size="small">{{ log.type }}</el-tag>
                    <p class="log-content">{{ log.content }}</p>
                  </div>
                </el-timeline-item>
              </el-timeline>
            </div>
            
            <!-- 分页 -->
            <div class="log-pagination">
              <span class="text-xs text-subtitle">显示 {{ (logFilter.pageNum - 1) * logFilter.pageSize + 1 }} - {{ Math.min(logFilter.pageNum * logFilter.pageSize, totalLogs) }} 条，共 {{ totalLogs }} 条记录</span>
              <el-pagination
                small
                layout="prev, pager, next"
                :total="totalLogs"
                :page-size="logFilter.pageSize"
                :current-page="logFilter.pageNum"
                @current-change="handleLogPageChange"
              />
            </div>
          </div>
          
          <!-- 消息通知 -->
          <div id="notifications" class="card content-section">
            <h2 class="section-title">消息通知</h2>
            
            <div class="space-y-4">
              <div v-for="msg in notifications" :key="msg.id" :class="['notification-item', { 'unread': msg.status === 'unread' }]">
                <div class="flex justify-between">
                  <h3 class="text-white font-medium">{{ msg.title }}</h3>
                  <span class="text-xs text-subtitle">{{ msg.time }}</span>
                </div>
                <p class="text-sm mt-2">{{ msg.content }}</p>
                <div v-if="msg.status === 'unread'" class="flex justify-end mt-3">
                  <el-button type="text" size="small" @click="markAsRead(msg.id)">标记为已读</el-button>
                </div>
              </div>
            </div>
            
            <!-- 分页 -->
            <div class="log-pagination mt-6">
              <el-pagination
                small
                layout="prev, pager, next"
                :total="totalNotifications"
                :page-size="notificationFilter.pageSize"
                :current-page="notificationFilter.pageNum"
                @current-change="handleNotificationPageChange"
              />
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { userAPI } from '@/api'

const activeSection = ref('basic-info')
const unreadCount = ref(3) // 模拟未读消息数量

// 基础信息
const userInfo = ref({
  avatar: 'https://picsum.photos/200/200?random=10',
  name: '张三',
  role: '系统管理员',
  jobId: 'ADM-2025-023',
  department: '系统管理部',
  phone: '13800138000',
  email: 'zhangsan@163.com',
  createTime: '2025-05-15 09:30:00'
})

// 账户安全
const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const passwordStrength = ref(2) // 0: 弱, 1: 中, 2: 强
const passwordStrengthText = ref('中')
const twoFactorAuth = ref(true)
const loginHistory = ref([
  { time: '2023-06-15 09:23:45', ip: '192.168.1.100', location: '北京市 联通', device: 'Windows 10 / Chrome 112.0', status: '正常' },
  { time: '2023-06-14 16:45:12', ip: '192.168.1.100', location: '北京市 联通', device: 'macOS Monterey / Safari 16.4', status: '正常' },
  { time: '2023-06-13 21:32:08', ip: '223.104.56.78', location: '上海市 移动', device: 'iOS 16.5 / Safari', status: '异常IP' },
  { time: '2023-06-13 08:55:33', ip: '192.168.1.100', location: '北京市 联通', device: 'Windows 10 / Edge 112.0', status: '正常' }
])

// 操作日志
const logFilter = ref({
  keyword: '',
  type: '',
  date: null,
  pageNum: 1,
  pageSize: 5
})
const operationLogs = ref([])
const totalLogs = ref(24)

// 消息通知
const notificationFilter = ref({
  pageNum: 1,
  pageSize: 5
})
const notifications = ref([])
const totalNotifications = ref(10)

// --- Methods ---

const handleMenuSelect = (index) => {
  activeSection.value = index
  nextTick(() => {
    document.getElementById(index).scrollIntoView({ behavior: 'smooth' })
  })
}

const changeAvatar = () => {
  ElMessage.info('更换头像功能待实现')
}

const resetBasicInfo = () => {
  // 实际应用中应从后端重新获取数据
  ElMessage.info('基础信息已重置')
}

const saveBasicInfo = async () => {
  try {
    // 模拟保存
    await userAPI.updateProfile(userInfo.value)
    ElMessage.success('基础信息保存成功')
  } catch (error) {
    ElMessage.error('保存失败')
  }
}

const getPasswordStrengthClass = (strength) => {
  if (strength === 0) return 'text-danger'
  if (strength === 1) return 'text-warning'
  return 'text-success'
}

const getPasswordStrengthColor = (strength) => {
  if (strength === 0) return '#ff4d4f'
  if (strength === 1) return '#faad14'
  return '#52c41a'
}

const changePassword = () => {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    ElMessage.error('两次输入的新密码不一致')
    return
  }
  // 实际应用中调用 userAPI.changePassword
  ElMessage.success('密码修改成功 (模拟)')
  passwordForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
}

const fetchOperationLogs = async () => {
  try {
    // 模拟从后端获取日志
    const res = await userAPI.getOperationLogs(logFilter.value)
    operationLogs.value = res.list
    totalLogs.value = res.total
  } catch (error) {
    ElMessage.error('加载操作日志失败')
  }
}

const handleLogPageChange = (val) => {
  logFilter.value.pageNum = val
  fetchOperationLogs()
}

const fetchNotifications = async () => {
  try {
    // 模拟从后端获取通知
    const res = await userAPI.getNotifications(notificationFilter.value)
    notifications.value = res.list
    totalNotifications.value = res.total
    unreadCount.value = res.list.filter(n => n.status === 'unread').length
  } catch (error) {
    ElMessage.error('加载消息通知失败')
  }
}

const handleNotificationPageChange = (val) => {
  notificationFilter.value.pageNum = val
  fetchNotifications()
}

const markAsRead = (id) => {
  // 模拟标记为已读
  const index = notifications.value.findIndex(n => n.id === id)
  if (index !== -1) {
    notifications.value[index].status = 'read'
    unreadCount.value--
    ElMessage.success('已标记为已读')
  }
}

// --- Lifecycle ---

onMounted(() => {
  // 模拟加载初始数据
  fetchOperationLogs()
  fetchNotifications()
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
.profile-container {
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
  grid-template-columns: 240px 1fr; /* 左侧固定宽度, 右侧自适应 */
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

.menu-column {
  position: sticky;
  top: 88px;
  height: fit-content;
}

.menu-card {
  padding: 0;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.avatar-wrapper {
  position: relative;
  margin-bottom: 12px;
}

.camera-icon {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #00d4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #142033;
  font-size: 14px;
  cursor: pointer;
  border: 2px solid #142033;
}

.profile-menu {
  border-right: none;
  background: transparent;
}

.profile-menu .el-menu-item {
  color: #c8d0e8;
  height: 50px;
  line-height: 50px;
}

.profile-menu .el-menu-item:hover {
  background-color: rgba(0, 212, 255, 0.1);
  color: #00d4ff;
}

.profile-menu .el-menu-item.is-active {
  background-color: rgba(0, 212, 255, 0.2);
  color: #00d4ff;
}

/* 右侧内容区 */
.content-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.content-section {
  scroll-margin-top: 112px; /* 顶部导航栏高度 + 间距 */
}

.section-title {
  font-size: 20px;
  font-weight: bold;
  color: #00d4ff;
  margin-bottom: 24px;
}

.sub-section-title {
  font-size: 16px;
  font-weight: bold;
  color: #c8d0e8;
  margin-bottom: 16px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.form-grid .el-form-item {
  margin-bottom: 0;
}

.form-grid .el-form-item__label {
  color: #a1a9c5;
}

.password-strength {
  margin-top: 12px;
}

.text-danger { color: #ff4d4f; }
.text-warning { color: #faad14; }
.text-success { color: #52c41a; }

.log-filter-row {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.timeline-wrapper {
  padding: 20px 0;
}

.log-item {
  background: #0a0e1a;
  padding: 12px;
  border-radius: 4px;
  border-left: 3px solid #00d4ff;
}

.log-content {
  margin-top: 8px;
  font-size: 14px;
  color: #c8d0e8;
}

.log-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
}

.notification-item {
  background: #0a0e1a;
  padding: 16px;
  border-radius: 4px;
  border-left: 4px solid transparent;
}

.notification-item.unread {
  border-left-color: #00d4ff;
  background: rgba(0, 212, 255, 0.05);
}
</style>

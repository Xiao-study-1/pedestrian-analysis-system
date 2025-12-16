<template>
  <div class="login-container">
    <!-- 装饰性元素 -->
    <div class="decoration">
      <div class="circle circle-1"></div>
      <div class="circle circle-2"></div>
      <div class="circle circle-3"></div>
    </div>

    <!-- 登录卡片 -->
    <div class="login-card">
      <!-- 头部 -->
      <div class="card-header">
        <div class="header-content">
          <i class="fa fa-line-chart"></i>
          <h1>行人交通行为智能分析系统</h1>
        </div>
        <p class="subtitle">请输入账号信息进行登录</p>
      </div>

      <!-- 登录表单 -->
      <div class="card-body">
        <el-form :model="loginForm" :rules="rules" ref="loginFormRef">
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              prefix-icon="User"
              size="large"
            />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              prefix-icon="Lock"
              size="large"
              show-password
            />
          </el-form-item>

          <el-form-item prop="captcha">
            <div class="captcha-row">
              <el-input
                v-model="loginForm.captcha"
                placeholder="请输入验证码"
                prefix-icon="Shield"
                size="large"
              />
              <div class="captcha-image" @click="refreshCaptcha">
                <span>{{ captchaText }}</span>
              </div>
            </div>
          </el-form-item>

          <el-form-item>
            <el-checkbox v-model="loginForm.remember">记住我</el-checkbox>
          </el-form-item>

          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              @click="handleLogin"
              class="login-button"
            >
              <span>登录系统</span>
              <i class="fa fa-arrow-right"></i>
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>

    <!-- 页脚 -->
    <div class="footer">
      <p>© 2023 行人交通行为智能分析系统 版权所有</p>
      <p>系统版本 v2.3.0 | 数据加密传输</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)
const captchaText = ref('8A3F')

const loginForm = reactive({
  username: 'admin',
  password: 'admin123',
  captcha: '',
  remember: false
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  captcha: [{ required: true, message: '请输入验证码', trigger: 'blur' }]
}

// 刷新验证码
const refreshCaptcha = () => {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let result = ''
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  captchaText.value = result
}

// 登录处理
const handleLogin = async () => {
  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await userStore.login(loginForm)
        ElMessage.success('登录成功')
        router.push('/dashboard')
      } catch (error) {
        ElMessage.error(error.message || '登录失败')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  background: linear-gradient(to bottom right, #020617, #0f172a);
}

.decoration {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.circle {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
}

.circle-1 {
  top: 10%;
  left: 5%;
  width: 256px;
  height: 256px;
  background: rgba(0, 212, 255, 0.05);
}

.circle-2 {
  bottom: 15%;
  right: 10%;
  width: 320px;
  height: 320px;
  background: rgba(56, 189, 248, 0.05);
}

.circle-3 {
  top: 40%;
  right: 20%;
  width: 160px;
  height: 160px;
  background: rgba(0, 212, 255, 0.08);
}

.login-card {
  width: 100%;
  max-width: 450px;
  background: rgba(20, 32, 51, 0.8);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(0, 212, 255, 0.2);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s;
  z-index: 10;
}

.login-card:hover {
  border-color: rgba(0, 212, 255, 0.4);
}

.card-header {
  background: linear-gradient(to right, rgba(0, 212, 255, 0.2), rgba(56, 189, 248, 0.2));
  padding: 24px;
  border-bottom: 1px solid rgba(0, 212, 255, 0.2);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 8px;
}

.header-content i {
  font-size: 32px;
  color: #00d4ff;
}

.header-content h1 {
  font-size: 24px;
  font-weight: bold;
  color: white;
  text-shadow: 0 0 8px rgba(0, 212, 255, 0.5);
}

.subtitle {
  text-align: center;
  color: #a1a9c5;
  font-size: 14px;
}

.card-body {
  padding: 30px 24px;
}

.captcha-row {
  display: flex;
  gap: 12px;
}

.captcha-image {
  width: 120px;
  height: 40px;
  background: rgba(10, 14, 26, 0.5);
  border: 1px solid rgba(0, 212, 255, 0.3);
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  user-select: none;
}

.captcha-image span {
  font-family: monospace;
  font-size: 14px;
  color: rgba(0, 212, 255, 0.8);
}

.login-button {
  width: 100%;
  background: linear-gradient(to right, #00d4ff, #38bdf8);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.footer {
  position: absolute;
  bottom: 24px;
  text-align: center;
  color: #6b7280;
  font-size: 12px;
  z-index: 10;
}

.footer p {
  margin: 4px 0;
}
</style>

import { defineStore } from 'pinia'
import { authAPI } from '@/api'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null
  }),
  
  actions: {
    // 登录
    async login(loginForm) {
      try {
        const data = await authAPI.login(loginForm)
        this.token = data.token
        this.userInfo = data.userInfo
        localStorage.setItem('token', data.token)
        return data
      } catch (error) {
        throw error
      }
    },
    
    // 登出
    async logout() {
      try {
        await authAPI.logout()
      } finally {
        this.token = ''
        this.userInfo = null
        localStorage.removeItem('token')
      }
    },
    
    // 获取用户信息
    async getUserInfo() {
      try {
        const data = await authAPI.getUserInfo()
        this.userInfo = data
        return data
      } catch (error) {
        throw error
      }
    }
  }
})

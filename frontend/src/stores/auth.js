import { defineStore } from 'pinia'
import api from '../utils/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    user: JSON.parse(localStorage.getItem('user') || '{}'),
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
    username: (state) => state.user?.real_name || state.user?.username || '',
  },
  actions: {
    async login(username, password) {
      const res = await api.post('/auth/login', { username, password })
      this._setSession(res)
      return res
    },
    async codeLogin(email, code) {
      const res = await api.post('/auth/code-login', { email, code })
      this._setSession(res.data)
      return res
    },
    async register(username, password, realName, phone, email, code) {
      const res = await api.post('/auth/register', {
        username, password, real_name: realName, phone, email, code,
      })
      this._setSession(res.data)
      return res
    },
    async sendCode(email) {
      return await api.post('/auth/send-code', { email, purpose: 'login' })
    },
    async resetPassword(email, code, newPassword) {
      return await api.post('/auth/reset-password', {
        email, code, new_password: newPassword,
      })
    },
    _setSession(data) {
      this.token = data.access_token
      this.user = {
        id: data.user_id,
        username: data.username,
        real_name: data.real_name,
        role_id: data.role_id,
      }
      localStorage.setItem('token', data.access_token)
      localStorage.setItem('user', JSON.stringify(this.user))
    },
    logout() {
      this.token = ''
      this.user = {}
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})

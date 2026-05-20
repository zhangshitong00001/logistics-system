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
      this.token = res.access_token
      this.user = { id: res.user_id, username: res.username, real_name: res.real_name, role_id: res.role_id }
      localStorage.setItem('token', res.access_token)
      localStorage.setItem('user', JSON.stringify(this.user))
      return res
    },
    logout() {
      this.token = ''
      this.user = {}
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})

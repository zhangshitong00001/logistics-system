<template>
  <div class="admin-login-page">
    <div class="login-card">
      <div class="login-icon">🔐</div>
      <h1 class="login-title">管理员登录</h1>
      <p class="login-subtitle">跨境物流业务系统 — 后台管理</p>

      <el-form :model="form" class="login-form" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input v-model="form.username" placeholder="管理员用户名" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.password" type="password" placeholder="密码" prefix-icon="Lock" size="large" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <div class="code-row">
            <el-input v-model="form.code" placeholder="邮箱验证码" prefix-icon="Key" size="large" maxlength="6" @keyup.enter="handleLogin" />
            <el-button class="code-btn" :disabled="sending || countdown > 0" @click="handleSendCode">
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleLogin">登 录</el-button>
      </el-form>

      <p v-if="error" class="login-error">{{ error }}</p>

      <div class="login-footer">
        <router-link to="/login">← 普通用户登录</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

const router = useRouter()
const auth = useAuthStore()

const loading = ref(false)
const sending = ref(false)
const error = ref('')
const countdown = ref(0)
let timer = null

const form = reactive({ username: 'admin', password: 'admin123', code: '' })

async function handleSendCode() {
  if (!form.username) {
    error.value = '请先输入用户名'
    return
  }
  sending.value = true
  error.value = ''
  try {
    await api.post('/auth/admin-send-code', { username: form.username })
    ElMessage.success('验证码已发送到管理员邮箱，请注意查收')
    countdown.value = 60
    timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) clearInterval(timer)
    }, 1000)
  } catch (e) {
    error.value = e.response?.data?.detail || '发送失败'
  } finally {
    sending.value = false
  }
}

async function handleLogin() {
  if (!form.username || !form.password) {
    error.value = '请输入用户名和密码'
    return
  }
  if (!form.code) {
    error.value = '请先获取并输入邮箱验证码'
    return
  }
  loading.value = true
  error.value = ''
  try {
    await auth.adminLogin(form.username, form.password, form.code)
    router.push('/dashboard')
  } catch (e) {
    error.value = e.response?.data?.detail || '登录失败'
  } finally {
    loading.value = false
  }
}

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.admin-login-page {
  min-height: 100vh;
  min-height: 100dvh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 30%, #4338ca 70%, #6d28d9 100%);
  position: relative;
}
.admin-login-page::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at 20% 50%, rgba(99,102,241,0.3) 0%, transparent 60%),
              radial-gradient(ellipse at 80% 50%, rgba(139,92,246,0.2) 0%, transparent 60%);
  pointer-events: none;
}
.login-card {
  width: 400px;
  padding: 36px 36px 40px;
  background: rgba(255,255,255,0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  box-shadow: 0 25px 60px rgba(0,0,0,0.3);
  text-align: center;
  position: relative;
  z-index: 1;
}
.login-icon {
  width: 56px;
  height: 56px;
  margin: 0 auto 14px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
  box-shadow: 0 8px 24px rgba(99,102,241,0.35);
}
.login-title { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 2px; }
.login-subtitle { font-size: 12px; color: #64748b; margin-bottom: 24px; }

.login-form .el-input { --el-input-height: 42px; }
.login-form .el-form-item { margin-bottom: 14px; }

.code-row { display: flex; gap: 10px; width: 100%; }
.code-row .el-input { flex: 1; }
.code-btn { flex-shrink: 0; width: 110px; height: 42px; padding: 0; font-size: 13px; border-radius: 8px; }

.login-btn { width: 100%; height: 42px; margin-top: 8px; font-size: 15px; border-radius: 10px; background: linear-gradient(135deg, #6366f1, #8b5cf6); border: none; }
.login-btn:hover { background: linear-gradient(135deg, #4f46e5, #7c3aed); }
.login-error { color: #ef4444; font-size: 13px; margin-top: 12px; }
.login-footer { margin-top: 18px; font-size: 13px; }
.login-footer a { color: #6366f1; text-decoration: none; }
.login-footer a:hover { text-decoration: underline; }
</style>

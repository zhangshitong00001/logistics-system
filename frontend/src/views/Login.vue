<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-icon">📦</div>
      <h1 class="login-title">跨境物流业务系统</h1>
      <p class="login-subtitle">China-Kazakhstan Logistics Platform</p>

      <!-- 标签切换 -->
      <div class="tab-bar">
        <span v-for="t in tabs" :key="t.key"
          :class="['tab-item', { active: activeTab === t.key }]"
          @click="activeTab = t.key">{{ t.label }}</span>
      </div>

      <!-- 密码登录 -->
      <el-form v-if="activeTab === 'login'" :model="loginForm" class="login-form" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input v-model="loginForm.username" placeholder="用户名" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="loginForm.password" type="password" placeholder="密码" prefix-icon="Lock" size="large" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <!-- 图片验证码 -->
        <SliderCaptcha @verified="onCaptchaVerified" @submit="handleLogin" ref="captchaRef" />
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleLogin">登 录</el-button>
      </el-form>

      <!-- 验证码登录 -->
      <el-form v-else-if="activeTab === 'codeLogin'" :model="codeForm" class="login-form" @submit.prevent="handleCodeLogin">
        <el-form-item>
          <el-input v-model="codeForm.email" placeholder="邮箱地址" prefix-icon="Message" size="large" />
        </el-form-item>
        <el-form-item>
          <div class="code-row">
            <el-input v-model="codeForm.code" placeholder="验证码" prefix-icon="Key" size="large" maxlength="6" @keyup.enter="handleCodeLogin" />
            <el-button class="code-btn" :disabled="codeSending || codeCountdown > 0" @click="handleSendCode">
              {{ codeCountdown > 0 ? `${codeCountdown}s` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleCodeLogin">登 录</el-button>
      </el-form>

      <!-- 注册 -->
      <el-form v-else-if="activeTab === 'register'" :model="regForm" class="login-form" @submit.prevent="handleRegister">
        <el-form-item>
          <el-input v-model="regForm.username" placeholder="用户名" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="regForm.password" type="password" placeholder="密码（至少6位）" prefix-icon="Lock" size="large" show-password />
        </el-form-item>
        <el-form-item>
          <el-input v-model="regForm.realName" placeholder="真实姓名（选填）" prefix-icon="Avatar" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="regForm.phone" placeholder="手机号（选填）" prefix-icon="Iphone" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="regForm.email" placeholder="邮箱地址" prefix-icon="Message" size="large" />
        </el-form-item>
        <el-form-item>
          <div class="code-row">
            <el-input v-model="regForm.code" placeholder="验证码" prefix-icon="Key" size="large" maxlength="6" />
            <el-button class="code-btn" :disabled="regSending || regCountdown > 0" @click="handleRegSendCode">
              {{ regCountdown > 0 ? `${regCountdown}s` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleRegister">注 册</el-button>
      </el-form>

      <!-- 重置密码 -->
      <el-form v-else-if="activeTab === 'reset'" :model="resetForm" class="login-form" @submit.prevent="handleReset">
        <el-form-item>
          <el-input v-model="resetForm.email" placeholder="注册邮箱" prefix-icon="Message" size="large" />
        </el-form-item>
        <el-form-item>
          <div class="code-row">
            <el-input v-model="resetForm.code" placeholder="验证码" prefix-icon="Key" size="large" maxlength="6" />
            <el-button class="code-btn" :disabled="resetSending || resetCountdown > 0" @click="handleResetSendCode">
              {{ resetCountdown > 0 ? `${resetCountdown}s` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-form-item>
          <el-input v-model="resetForm.newPassword" type="password" placeholder="新密码（至少6位）" prefix-icon="Lock" size="large" show-password @keyup.enter="handleReset" />
        </el-form-item>
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleReset">重置密码</el-button>
      </el-form>

      <p v-if="error" class="login-error">{{ error }}</p>
      <p v-if="successMsg" class="login-success">{{ successMsg }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'
import SliderCaptcha from '../components/SliderCaptcha.vue'

const router = useRouter()
const auth = useAuthStore()

const loading = ref(false)
const error = ref('')
const successMsg = ref('')
const activeTab = ref('login')

// 图片验证码状态
const captchaRef = ref(null)
const loginCaptcha = reactive({ captcha_id: '', code: '', verified: false })

function onCaptchaVerified(data) {
  loginCaptcha.captcha_id = data.captcha_id
  loginCaptcha.code = data.code
  loginCaptcha.verified = true
}

const tabs = [
  { key: 'login', label: '密码登录' },
  { key: 'codeLogin', label: '验证码登录' },
  { key: 'register', label: '注册' },
  { key: 'reset', label: '重置密码' },
]

// 密码登录
const loginForm = reactive({ username: 'admin', password: 'admin123' })

// 验证码登录
const codeForm = reactive({ email: '', code: '' })
const codeSending = ref(false)
const codeCountdown = ref(0)
let codeTimer = null

// 注册
const regForm = reactive({ username: '', password: '', realName: '', phone: '', email: '', code: '' })
const regSending = ref(false)
const regCountdown = ref(0)
let regTimer = null

// 重置密码
const resetForm = reactive({ email: '', code: '', newPassword: '' })
const resetSending = ref(false)
const resetCountdown = ref(0)
let resetTimer = null

function startCountdown(timerRef, countRef, intervalRef) {
  countRef.value = 60
  intervalRef = setInterval(() => {
    countRef.value--
    if (countRef.value <= 0) {
      clearInterval(intervalRef)
      intervalRef = null
    }
  }, 1000)
}

onUnmounted(() => {
  [codeTimer, regTimer, resetTimer].forEach(t => t && clearInterval(t))
})

// ====== 密码登录 ======
async function handleLogin() {
  if (!loginForm.username || !loginForm.password) {
    error.value = '请输入用户名和密码'
    return
  }
  if (!loginCaptcha.verified) {
    error.value = '请先完成验证码'
    return
  }
  loading.value = true; error.value = ''; successMsg.value = ''
  try {
    const captchaStr = `${loginCaptcha.captcha_id}:${loginCaptcha.code}`
    await auth.login(loginForm.username, loginForm.password, captchaStr)
    router.push('/dashboard')
  } catch (e) {
    error.value = e.response?.data?.detail || '登录失败'
    // 验证码失效，重置
    loginCaptcha.verified = false
    if (captchaRef.value) captchaRef.value?.refresh?.()
  } finally { loading.value = false }
}

// ====== 发送验证码（通用） ======
async function sendCode(email, sendingRef, countRef, timerRef) {
  if (!email) { error.value = '请输入邮箱地址'; return }
  sendingRef.value = true; error.value = ''
  try {
    await auth.sendCode(email)
    ElMessage.success(`验证码已发送到 ${email}，请注意查收（控制台可见）`)
    countRef.value = 60
    timerRef = setInterval(() => {
      countRef.value--
      if (countRef.value <= 0) clearInterval(timerRef)
    }, 1000)
  } catch (e) {
    error.value = e.response?.data?.detail || '发送失败'
  } finally { sendingRef.value = false }
}

function handleSendCode() { sendCode(codeForm.email, codeSending, codeCountdown, codeTimer) }
function handleRegSendCode() { sendCode(regForm.email, regSending, regCountdown, regTimer) }
function handleResetSendCode() { sendCode(resetForm.email, resetSending, resetCountdown, resetTimer) }

// ====== 验证码登录 ======
async function handleCodeLogin() {
  if (!codeForm.email || !codeForm.code) {
    error.value = '请输入邮箱和验证码'
    return
  }
  loading.value = true; error.value = ''; successMsg.value = ''
  try {
    await auth.codeLogin(codeForm.email, codeForm.code)
    router.push('/dashboard')
  } catch (e) {
    error.value = e.response?.data?.detail || '登录失败'
  } finally { loading.value = false }
}

// ====== 注册 ======
async function handleRegister() {
  if (!regForm.username || !regForm.password) {
    error.value = '用户名和密码不能为空'; return
  }
  if (regForm.password.length < 6) {
    error.value = '密码至少6位'; return
  }
  if (!regForm.email || !regForm.code) {
    error.value = '请填写邮箱和验证码'; return
  }
  loading.value = true; error.value = ''; successMsg.value = ''
  try {
    await auth.register(regForm.username, regForm.password, regForm.realName, regForm.phone, regForm.email, regForm.code)
    ElMessage.success('注册成功！')
    router.push('/dashboard')
  } catch (e) {
    error.value = e.response?.data?.detail || '注册失败'
    console.log('[DEBUG] 注册失败详情:', e.response?.data)
  } finally { loading.value = false }
}

// ====== 重置密码 ======
async function handleReset() {
  if (!resetForm.email || !resetForm.code || !resetForm.newPassword) {
    error.value = '请填写完整信息'; return
  }
  if (resetForm.newPassword.length < 6) {
    error.value = '密码至少6位'; return
  }
  loading.value = true; error.value = ''; successMsg.value = ''
  try {
    await auth.resetPassword(resetForm.email, resetForm.code, resetForm.newPassword)
    successMsg.value = '密码重置成功，请使用新密码登录'
    ElMessage.success('密码重置成功！')
    setTimeout(() => { activeTab.value = 'login' }, 2000)
  } catch (e) {
    error.value = e.response?.data?.detail || '重置失败'
  } finally { loading.value = false }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  min-height: 100dvh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 30%, #3b82f6 70%, #6366f1 100%);
  position: relative;
}
.login-page::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at 20% 50%, rgba(59,130,246,0.3) 0%, transparent 60%),
              radial-gradient(ellipse at 80% 50%, rgba(139,92,246,0.2) 0%, transparent 60%);
  pointer-events: none;
}
.login-card {
  width: 420px;
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
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
  box-shadow: 0 8px 24px rgba(59,130,246,0.35);
}
.login-title { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 2px; }
.login-subtitle { font-size: 12px; color: #64748b; margin-bottom: 20px; }

/* Tab 切换 */
.tab-bar { display: flex; gap: 0; margin-bottom: 20px; border-radius: 10px; overflow: hidden; border: 1px solid #e2e8f0; }
.tab-item { flex: 1; padding: 8px 0; font-size: 13px; color: #64748b; cursor: pointer; transition: all .2s; background: #f8fafc; }
.tab-item.active { color: #fff; background: linear-gradient(135deg, #3b82f6, #6366f1); font-weight: 600; }
.tab-item:not(.active):hover { background: #eef2ff; }

.login-form .el-input { --el-input-height: 42px; }
.login-form .el-form-item { margin-bottom: 14px; }

/* 验证码行 */
.code-row { display: flex; gap: 10px; width: 100%; }
.code-row .el-input { flex: 1; }
.code-btn { flex-shrink: 0; width: 110px; height: 42px; padding: 0; font-size: 13px; border-radius: 8px; }

.login-btn { width: 100%; height: 42px; margin-top: 4px; font-size: 15px; border-radius: 10px; background: linear-gradient(135deg, #3b82f6, #6366f1); border: none; }
.login-btn:hover { background: linear-gradient(135deg, #2563eb, #4f46e5); }
.login-error { color: #ef4444; font-size: 13px; margin-top: 12px; }
.login-success { color: #22c55e; font-size: 13px; margin-top: 12px; }
</style>

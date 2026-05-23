<template>
  <div class="img-captcha">
    <div class="captcha-row">
      <img :src="imgSrc" class="captcha-img" alt="验证码" @click="refresh" />
      <el-button size="small" class="refresh-btn" @click="refresh" :loading="loading">换一张</el-button>
    </div>
    <div class="captcha-input-row">
      <el-input v-model="inputCode" placeholder="输入验证码（不区分大小写）" size="large" maxlength="4"
        @keyup.enter="$emit('submit')" @input="onInput" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '../utils/api'

const emit = defineEmits(['verified', 'submit'])

const imgSrc = ref('')
const captchaId = ref('')
const inputCode = ref('')
const loading = ref(false)
const verified = ref(false)

async function refresh() {
  loading.value = true
  verified.value = false
  inputCode.value = ''
  try {
    const res = await api.get('/auth/captcha')
    const d = res.data || res
    captchaId.value = d.captcha_id
    imgSrc.value = d.image
  } catch (e) {
    console.warn('[Captcha] get fail:', e)
  } finally {
    loading.value = false
  }
}

function onInput() {
  if (inputCode.value.length >= 4) {
    verify()
  }
}

async function verify() {
  if (!inputCode.value || !captchaId.value) return
  if (verified.value) {
    emit('verified', { captcha_id: captchaId.value, code: inputCode.value })
    return
  }
  try {
    const res = await api.post('/auth/captcha/verify', {
      captcha_id: captchaId.value,
      code: inputCode.value,
    })
    const d = res.data || res
    if (d.passed) {
      verified.value = true
      emit('verified', { captcha_id: captchaId.value, code: inputCode.value })
    } else {
      refresh()
    }
  } catch {
    refresh()
  }
}

onMounted(refresh)
defineExpose({ refresh })
</script>

<style scoped>
.img-captcha {
  margin-bottom: 10px;
}
.captcha-row {
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 8px;
}
.captcha-img {
  display: block;
  height: 40px;
  border-radius: 4px;
  cursor: pointer;
  border: 1px solid #e2e8f0;
}
.refresh-btn { flex-shrink: 0; }
.captcha-input-row { width: 100%; }
.captcha-input-row .el-input { --el-input-height: 36px; }
</style>

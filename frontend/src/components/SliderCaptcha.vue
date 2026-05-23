<template>
  <div class="slider-captcha" :class="{ 'is-success': success }">
    <div class="slider-body">
      <div class="sc-slider" ref="trackRef">
        <!-- 目标标记（随机位置） -->
        <div class="sc-target" :style="{ left: targetPct + '%' }">
          <div class="sc-target-dot" />
        </div>
        <!-- 已滑过的填充 -->
        <div class="sc-fill" :style="{ width: fillW + '%' }" />
        <!-- 滑块 -->
        <div class="sc-thumb" :class="{ dragging, success }"
          :style="{ left: thumbLeft + 'px' }"
          @mousedown.prevent="onStart" @touchstart.prevent="onStart">
          <span class="sc-icon">{{ success ? '✓' : (dragging ? '◀' : '►') }}</span>
        </div>
      </div>
      <div class="sc-text">{{ hintText }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import api from '../utils/api'

const emit = defineEmits(['verified'])

const trackRef = ref(null)
const dragging = ref(false)
const success = ref(false)
const failed = ref(false)
const fillW = ref(0)
const thumbLeft = ref(0)
const targetPct = ref(50)
const captchaId = ref('')
const hintText = computed(() => {
  if (success.value) return '验证通过 ✓'
  if (failed.value) return '验证失败，请重新滑动'
  return '按住滑块拖动到指定位置'
})

async function initCaptcha() {
  success.value = false; failed.value = false
  fillW.value = 0; thumbLeft.value = 0
  try {
    const res = await api.get('/auth/captcha')
    const d = res.data || res
    captchaId.value = d.captcha_id
    // 后端 offset_x 范围 50-200, canvas_width=280 → 映射到 18%-72%
    targetPct.value = 20 + (d.offset_x / 200) * 55
  } catch (e) { console.warn('[Captcha] init fail:', e) }
}

function cx(e) { return e.touches ? e.touches[0].clientX : e.clientX }

let _sx = 0, _sp = 0, _sw = 0, _range = 0

function onStart(e) {
  if (success.value) return
  dragging.value = true; failed.value = false
  const t = trackRef.value; if (!t) return
  _range = t.offsetWidth - 36
  _sx = cx(e); _sp = thumbLeft.value; _sw = fillW.value
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', onEnd)
  document.addEventListener('touchmove', onMove, { passive: false })
  document.addEventListener('touchend', onEnd)
}

function onMove(e) {
  if (!dragging.value) return; e.preventDefault()
  let tp = _sp + (cx(e) - _sx)
  tp = Math.max(0, Math.min(_range, tp))
  thumbLeft.value = tp
  fillW.value = Math.max(0, Math.min(100, _sw + (tp - _sp) / _range * 100))
}

async function onEnd() {
  if (!dragging.value) return; dragging.value = false
  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', onEnd)
  document.removeEventListener('touchmove', onMove)
  document.removeEventListener('touchend', onEnd)

  // 计算用户拖到的百分比位置
  const t = trackRef.value; if (!t) return
  const userPct = (thumbLeft.value / _range) * 100  // 0~100

  // 映射回 offset_x: 20%→50, 75%→200 (与 showTarget 反向)
  const ratio = Math.max(0, Math.min(1, (userPct - 20) / 55))
  const calcOffset = Math.round(50 + ratio * 150)

  try {
    const res = await api.post('/auth/captcha/verify', {
      captcha_id: captchaId.value,
      offset_x: calcOffset,
    })
    const d = res.data || res
    if (d.passed) {
      success.value = true
      emit('verified', { captcha_id: captchaId.value, offset_x: calcOffset })
    } else {
      failed.value = true; setTimeout(initCaptcha, 800)
    }
  } catch { failed.value = true; setTimeout(initCaptcha, 800) }
}

onMounted(initCaptcha)
onUnmounted(() => {
  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', onEnd)
  document.removeEventListener('touchmove', onMove)
  document.removeEventListener('touchend', onEnd)
})

defineExpose({ initCaptcha })
</script>

<style scoped>
.slider-captcha {
  margin-bottom: 10px;
  user-select: none; -webkit-user-select: none;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 10px 12px;
  background: #fafbfc;
  transition: border-color .25s, background .25s;
}
.slider-captcha.is-success { border-color: #22c55e; background: #f0fdf4; }

.slider-body { width: 100%; }

.sc-slider {
  position: relative; width: 100%; height: 36px;
  background: #e8ecf1;
  border-radius: 18px;
  overflow: visible;
}
.sc-fill {
  position: absolute; left: 0; top: 0;
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #6366f1);
  border-radius: 18px;
  transition: width .02s;
}

/* 目标标记 - 底部小三角 */
.sc-target {
  position: absolute; top: -6px;
  width: 0; height: 0;
  transform: translateX(-50%);
  z-index: 1;
}
.sc-target-dot {
  width: 0; height: 0;
  border-left: 7px solid transparent;
  border-right: 7px solid transparent;
  border-top: 8px solid #6366f1;
  filter: drop-shadow(0 1px 2px rgba(99,102,241,.3));
}

.sc-thumb {
  position: absolute; top: -1px;
  width: 38px; height: 38px;
  background: #fff;
  border: 2px solid #3b82f6;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  cursor: grab; z-index: 3;
  box-shadow: 0 2px 6px rgba(59,130,246,.25);
  transition: box-shadow .2s, border-color .2s, background .2s;
}
.sc-thumb.dragging { cursor: grabbing; box-shadow: 0 4px 12px rgba(59,130,246,.35); }
.sc-thumb.success { border-color: #22c55e; background: #22c55e; cursor: default; box-shadow: 0 2px 6px rgba(34,197,94,.25); }
.sc-icon { font-size: 13px; color: #3b82f6; line-height: 1; }
.sc-thumb.success .sc-icon { color: #fff; }

.sc-text {
  text-align: center;
  font-size: 12px;
  color: #94a3b8;
  margin-top: 6px;
  transition: color .2s;
}
.slider-captcha.is-success .sc-text { color: #22c55e; }
</style>

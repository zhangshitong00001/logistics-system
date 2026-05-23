<template>
  <div class="slider-captcha" :class="{ 'is-success': success }">
    <div class="captcha-canvas-wrap">
      <canvas ref="bgCanvas" :width="canvasWidth" :height="canvasHeight" class="bg-canvas" />
      <canvas ref="pieceCanvas" :width="pieceSize" :height="canvasHeight" class="piece-canvas"
        :style="{ left: pieceLeft + 'px' }" />
      <div v-if="success" class="captcha-success">✓ 验证通过</div>
      <div v-if="failed" class="captcha-fail">验证失败，请重试</div>
    </div>

    <div class="slider-track">
      <div class="slider-bg" :style="{ width: sliderPercent + '%' }" />
      <div class="slider-thumb" :class="{ dragging: dragging, success: success }"
        @mousedown.prevent="onStart" @touchstart.prevent="onStart"
        :style="{ left: `calc(${sliderPercent}% - ${thumbSize}px)` }">
        <span v-if="!success" class="thumb-icon">{{ dragging ? '▶' : '▶▶' }}</span>
        <span v-else class="thumb-icon">✓</span>
      </div>
    </div>

    <div class="captcha-hint">{{ hintText }}</div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import api from '../utils/api'

const emit = defineEmits(['verified'])

const canvasWidth = 280
const canvasHeight = 160
const pieceSize = 40
const thumbSize = 40

const bgCanvas = ref(null)
const pieceCanvas = ref(null)

const dragging = ref(false)
const success = ref(false)
const failed = ref(false)
const sliderPercent = ref(0)
const pieceLeft = ref(0)
const captchaId = ref('')
const targetOffset = ref(0)

const hintText = computed(() => {
  if (success.value) return '验证通过'
  if (failed.value) return '验证失败，请拖动滑块重试'
  return '请按住滑块，拖动完成拼图'
})

// ====== 生成背景图案 ======
function drawBackground(ctx, w, h, seed) {
  // 用 captcha_id 的字符码作为随机种子
  let s = seed || 0
  const rng = () => {
    s = (s * 9301 + 49297) % 233280
    return s / 233280
  }

  // 基础渐变背景
  const grad = ctx.createLinearGradient(0, 0, w, h)
  const hue1 = Math.floor(rng() * 360)
  const hue2 = (hue1 + 30 + Math.floor(rng() * 60)) % 360
  grad.addColorStop(0, `hsl(${hue1}, 50%, 65%)`)
  grad.addColorStop(0.5, `hsl(${hue2}, 50%, 55%)`)
  grad.addColorStop(1, `hsl(${(hue1 + 120) % 360}, 45%, 70%)`)
  ctx.fillStyle = grad
  ctx.fillRect(0, 0, w, h)

  // 随机条纹
  ctx.globalAlpha = 0.15
  for (let i = 0; i < 8; i++) {
    const x = rng() * w
    const y = rng() * h
    ctx.fillStyle = `hsl(${Math.floor(rng() * 360)}, 60%, ${40 + Math.floor(rng() * 30)}%)`
    if (rng() > 0.5) {
      ctx.fillRect(x, y, 30 + rng() * 50, 4 + rng() * 8)
    } else {
      ctx.beginPath()
      ctx.arc(x, y, 6 + rng() * 14, 0, Math.PI * 2)
      ctx.fill()
    }
  }

  // 随机网格线
  ctx.strokeStyle = `hsla(0, 0%, 100%, 0.1)`
  ctx.lineWidth = 1
  for (let x = 0; x < w; x += 15 + rng() * 20) {
    ctx.beginPath()
    ctx.moveTo(x, 0)
    ctx.lineTo(x, h)
    ctx.stroke()
  }
  for (let y = 0; y < h; y += 15 + rng() * 20) {
    ctx.beginPath()
    ctx.moveTo(0, y)
    ctx.lineTo(w, y)
    ctx.stroke()
  }

  ctx.globalAlpha = 1
}

// ====== 绘制拼图块（从背景中切出） ======
function drawPiece(ctx, srcCanvas, offsetX, ps, h) {
  ctx.clearRect(0, 0, ps, h)
  // 从背景复制拼图块区域
  ctx.drawImage(srcCanvas, offsetX, 0, ps, h, 0, 0, ps, h)

  // 加边缘阴影
  ctx.shadowColor = 'rgba(0,0,0,0.4)'
  ctx.shadowBlur = 4
  ctx.strokeStyle = 'rgba(255,255,255,0.5)'
  ctx.lineWidth = 1
  ctx.strokeRect(1, 1, ps - 2, h - 2)
  ctx.shadowBlur = 0
}

// ====== 绘制缺口标记 ======
function drawGapMark(ctx, offsetX, ps, h) {
  ctx.fillStyle = 'rgba(0,0,0,0.25)'
  ctx.fillRect(offsetX, 0, ps, h)

  // 缺口边框
  ctx.strokeStyle = 'rgba(255,255,255,0.3)'
  ctx.lineWidth = 1.5
  ctx.setLineDash([4, 3])
  ctx.strokeRect(offsetX + 2, 2, ps - 4, h - 4)
  ctx.setLineDash([])
}

// ====== 初始化验证码 ======
async function initCaptcha() {
  success.value = false
  failed.value = false
  sliderPercent.value = 0
  pieceLeft.value = -pieceSize

  try {
    const res = await api.get('/auth/captcha')
    const data = res.data || res
    captchaId.value = data.captcha_id
    targetOffset.value = data.offset_x

    const bg = bgCanvas.value
    const pc = pieceCanvas.value
    if (!bg || !pc) return

    const bgCtx = bg.getContext('2d')
    const pcCtx = pc.getContext('2d')

    // 生成种子：用 captchaId 的字符码和
    let seed = 0
    for (let i = 0; i < captchaId.value.length; i++) {
      seed += captchaId.value.charCodeAt(i)
    }

    drawBackground(bgCtx, canvasWidth, canvasHeight, seed)
    drawGapMark(bgCtx, targetOffset.value, pieceSize, canvasHeight)
    drawPiece(pcCtx, bg, targetOffset.value, pieceSize, canvasHeight)
  } catch (e) {
    console.error('[Captcha] 初始化失败:', e)
  }
}

// ====== 拖拽逻辑 ======
let startX = 0
let startPercent = 0
let trackWidth = 0

function getClientX(e) {
  return e.touches ? e.touches[0].clientX : e.clientX
}

function onStart(e) {
  if (success.value) return
  dragging.value = true
  failed.value = false
  const track = e.currentTarget.parentElement
  const rect = track.getBoundingClientRect()
  trackWidth = rect.width - thumbSize
  startX = getClientX(e)
  startPercent = sliderPercent.value

  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', onEnd)
  document.addEventListener('touchmove', onMove, { passive: false })
  document.addEventListener('touchend', onEnd)
}

function onMove(e) {
  if (!dragging.value) return
  e.preventDefault()
  const clientX = getClientX(e)
  const dx = clientX - startX
  let pct = startPercent + (dx / trackWidth) * 100
  pct = Math.max(0, Math.min(100, pct))
  sliderPercent.value = pct

  // 拼图块跟随滑块
  const maxPieceLeft = canvasWidth - pieceSize
  pieceLeft.value = (pct / 100) * maxPieceLeft
}

async function onEnd() {
  if (!dragging.value) return
  dragging.value = false

  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', onEnd)
  document.removeEventListener('touchmove', onMove)
  document.removeEventListener('touchend', onEnd)

  // 验证
  const userOffset = Math.round(pieceLeft.value)
  try {
    const res = await api.post('/auth/captcha/verify', {
      captcha_id: captchaId.value,
      offset_x: userOffset,
    })
    const data = res.data || res
    if (data.passed) {
      success.value = true
      emit('verified', { captcha_id: captchaId.value, offset_x: userOffset })
    } else {
      failed.value = true
      setTimeout(() => initCaptcha(), 800)
    }
  } catch (e) {
    failed.value = true
    setTimeout(() => initCaptcha(), 800)
  }
}

onMounted(() => {
  initCaptcha()
})

onUnmounted(() => {
  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', onEnd)
  document.removeEventListener('touchmove', onMove)
  document.removeEventListener('touchend', onEnd)
})
</script>

<style scoped>
.slider-captcha {
  margin-bottom: 14px;
  user-select: none;
  -webkit-user-select: none;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 12px;
  background: #fafbfc;
  transition: border-color 0.3s, background 0.3s;
}
.slider-captcha.is-success {
  border-color: #22c55e;
  background: #f0fdf4;
}

.captcha-canvas-wrap {
  position: relative;
  width: 280px;
  height: 160px;
  margin: 0 auto 12px;
  border-radius: 6px;
  overflow: hidden;
  background: #e2e8f0;
}
.bg-canvas {
  display: block;
  width: 280px;
  height: 160px;
}
.piece-canvas {
  position: absolute;
  top: 0;
  width: 40px;
  height: 160px;
  pointer-events: none;
  transition: none;
}

.captcha-success {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(34, 197, 94, 0.15);
  color: #16a34a;
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 2px;
}
.captcha-fail {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(239, 68, 68, 0.15);
  color: #dc2626;
  font-size: 14px;
  font-weight: 600;
}

/* 滑块轨道 */
.slider-track {
  position: relative;
  width: 100%;
  height: 40px;
  background: #e2e8f0;
  border-radius: 20px;
  cursor: pointer;
  overflow: hidden;
}
.slider-bg {
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #6366f1);
  border-radius: 20px;
  transition: width 0.05s;
}
.slider-thumb {
  position: absolute;
  top: 0;
  width: 40px;
  height: 40px;
  background: #fff;
  border: 2px solid #3b82f6;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: grab;
  z-index: 2;
  box-shadow: 0 2px 6px rgba(59, 130, 246, 0.3);
  transition: box-shadow 0.2s;
}
.slider-thumb.dragging {
  cursor: grabbing;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.5);
}
.slider-thumb.success {
  border-color: #22c55e;
  background: #22c55e;
  cursor: default;
  box-shadow: 0 2px 6px rgba(34, 197, 94, 0.3);
}
.thumb-icon {
  font-size: 14px;
  color: #3b82f6;
  line-height: 1;
}
.slider-thumb.success .thumb-icon {
  color: #fff;
}

.captcha-hint {
  text-align: center;
  font-size: 12px;
  color: #94a3b8;
  margin-top: 8px;
}
.slider-captcha.is-success .captcha-hint {
  color: #22c55e;
}
</style>

<template>
  <div class="slider-captcha" :class="{ 'is-success': success }">
    <div class="captcha-canvas-wrap">
      <canvas ref="bgCanvas" :width="CW" :height="CH" class="bg-canvas" />
      <canvas ref="pieceCanvas" :width="PS" :height="CH" class="piece-canvas" :style="{ left: pieceLeft + 'px' }" />
      <div v-if="success" class="cap-overlay success">✓ 验证通过</div>
      <div v-if="failed" class="cap-overlay fail">验证失败</div>
    </div>

    <div class="slider-track" ref="trackRef">
      <div class="slider-fill" :style="{ width: fillW + '%' }" />
      <div class="slider-thumb" :class="{ dragging, success }"
        :style="{ left: thumbLeft + 'px' }"
        @mousedown.prevent="onStart" @touchstart.prevent="onStart">
        <span v-if="!success" class="ti">{{ dragging ? '◀' : '►' }}</span>
        <span v-else class="ti">✓</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import api from '../utils/api'

const emit = defineEmits(['verified'])

const CW = 260, CH = 80, PS = 40  // canvas w/h, piece size

const bgCanvas = ref(null)
const pieceCanvas = ref(null)
const trackRef = ref(null)
const dragging = ref(false)
const success = ref(false)
const failed = ref(false)

const fillW = ref(0)       // 0~100
const pieceLeft = ref(-PS) // -40 → 220
const thumbLeft = ref(0)   // 0 → (trackW - 36)
const captchaId = ref('')
const targetX = ref(0)

function seededRng(seed) {
  let s = seed || 0
  return () => { s = (s * 9301 + 49297) % 233280; return s / 233280 }
}

function drawBg(ctx, w, h, seed) {
  const r = seededRng(seed)
  const g = ctx.createLinearGradient(0, 0, w, h)
  const h1 = Math.floor(r() * 360), h2 = (h1 + 40 + Math.floor(r() * 50)) % 360
  g.addColorStop(0, `hsl(${h1},55%,60%)`); g.addColorStop(1, `hsl(${h2},50%,55%)`)
  ctx.fillStyle = g; ctx.fillRect(0, 0, w, h)

  ctx.globalAlpha = 0.18
  for (let i = 0; i < 6; i++) {
    const x = r() * w, y = r() * h
    ctx.fillStyle = `hsl(${Math.floor(r() * 360)}, 60%, ${45 + Math.floor(r() * 25)}%)`
    if (r() > 0.5) ctx.fillRect(x, y, 20 + r() * 35, 3 + r() * 5)
    else { ctx.beginPath(); ctx.arc(x, y, 4 + r() * 10, 0, Math.PI * 2); ctx.fill() }
  }
  ctx.globalAlpha = 1

  ctx.fillStyle = 'rgba(0,0,0,0.22)'; ctx.fillRect(0, 0, PS, CH)
}

function drawPiece(ctx, src, ox, ps, h) {
  ctx.clearRect(0, 0, ps, h)
  ctx.drawImage(src, ox, 0, ps, h, 0, 0, ps, h)
  ctx.shadowColor = 'rgba(0,0,0,0.35)'; ctx.shadowBlur = 3
  ctx.strokeStyle = 'rgba(255,255,255,0.4)'
  ctx.strokeRect(1, 1, ps - 2, h - 2); ctx.shadowBlur = 0
}

async function initCaptcha() {
  success.value = false; failed.value = false
  fillW.value = 0; pieceLeft.value = -PS; thumbLeft.value = 0
  try {
    const res = await api.get('/auth/captcha')
    const d = res.data || res
    captchaId.value = d.captcha_id; targetX.value = d.offset_x
    const bg = bgCanvas.value, pc = pieceCanvas.value
    if (!bg || !pc) return
    let seed = 0
    for (let i = 0; i < captchaId.value.length; i++) seed += captchaId.value.charCodeAt(i)
    drawBg(bg.getContext('2d'), CW, CH, seed)
    drawPiece(pc.getContext('2d'), bg, targetX.value, PS, CH)
  } catch (e) { console.warn('[Captcha] init fail:', e) }
}

function cx(e) { return e.touches ? e.touches[0].clientX : e.clientX }

let _sx = 0, _sp = 0, _st = 0, _range = 0

function onStart(e) {
  if (success.value) return
  dragging.value = true; failed.value = false
  const track = trackRef.value
  if (!track) return
  _range = track.offsetWidth - 36  // track px - thumb px = max drag
  _sx = cx(e); _sp = thumbLeft.value; _st = fillW.value
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', onEnd)
  document.addEventListener('touchmove', onMove, { passive: false })
  document.addEventListener('touchend', onEnd)
}

function onMove(e) {
  if (!dragging.value) return; e.preventDefault()
  const dx = cx(e) - _sx
  // thumb pixel position
  let tp = _sp + dx
  tp = Math.max(0, Math.min(_range, tp))
  thumbLeft.value = tp
  // piece left: map 0→_range to -PS→(CW-PS)
  const maxPiece = CW - PS
  pieceLeft.value = -PS + (tp / _range) * (maxPiece + PS)
  // fill width
  fillW.value = _st + (tp - _sp) / _range * 100
  fillW.value = Math.max(0, Math.min(100, fillW.value))
}

async function onEnd() {
  if (!dragging.value) return; dragging.value = false
  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', onEnd)
  document.removeEventListener('touchmove', onMove)
  document.removeEventListener('touchend', onEnd)
  const off = Math.round(pieceLeft.value)
  try {
    const res = await api.post('/auth/captcha/verify', { captcha_id: captchaId.value, offset_x: off })
    const d = res.data || res
    if (d.passed) { success.value = true; emit('verified', { captcha_id: captchaId.value, offset_x: off }) }
    else { failed.value = true; setTimeout(initCaptcha, 700) }
  } catch { failed.value = true; setTimeout(initCaptcha, 700) }
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
  padding: 8px;
  background: #fafbfc;
  transition: border-color .25s, background .25s;
}
.slider-captcha.is-success { border-color: #22c55e; background: #f0fdf4; }

.captcha-canvas-wrap {
  position: relative; width: 260px; height: 80px;
  margin: 0 auto 8px;
  border-radius: 4px; overflow: hidden;
  background: #e2e8f0;
}
.bg-canvas { display: block; width: 260px; height: 80px; }
.piece-canvas {
  position: absolute; top: 0;
  width: 40px; height: 80px;
  pointer-events: none;
}
.cap-overlay {
  position: absolute; inset: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 15px; font-weight: 700;
}
.cap-overlay.success { background: rgba(34,197,94,0.15); color: #16a34a; letter-spacing: 2px; }
.cap-overlay.fail { background: rgba(239,68,68,0.15); color: #dc2626; font-size: 13px; }

.slider-track {
  position: relative; width: 100%; height: 36px;
  background: #e2e8f0;
  border-radius: 18px; cursor: pointer;
  overflow: hidden;
}
.slider-fill {
  position: absolute; left: 0; top: 0; height: 100%;
  background: linear-gradient(90deg, #3b82f6, #6366f1);
  border-radius: 18px; transition: width .03s;
}
.slider-thumb {
  position: absolute; top: 0;
  width: 36px; height: 36px;
  background: #fff;
  border: 2px solid #3b82f6;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  cursor: grab; z-index: 2;
  box-shadow: 0 1px 4px rgba(59,130,246,.3);
  transition: box-shadow .2s, border-color .2s, background .2s;
}
.slider-thumb.dragging { cursor: grabbing; box-shadow: 0 3px 8px rgba(59,130,246,.4); }
.slider-thumb.success { border-color: #22c55e; background: #22c55e; cursor: default; box-shadow: 0 1px 4px rgba(34,197,94,.3); }
.ti { font-size: 12px; color: #3b82f6; line-height: 1; }
.slider-thumb.success .ti { color: #fff; }
</style>

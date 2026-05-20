<template>
  <div class="dashboard">
    <el-row :gutter="16">
      <el-col :span="6" v-for="card in stats" :key="card.label">
        <el-card shadow="never" class="stat-card">
          <div class="stat-icon" :style="{ background: card.bg }">{{ card.icon }}</div>
          <div class="stat-info">
            <div class="stat-value">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <div v-if="card.trend" class="stat-trend" :class="card.trend.includes('↑') ? 'up' : 'down'">{{ card.trend }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="mt-4">
      <el-col :span="16">
        <el-card shadow="never">
          <template #header><span style="font-weight:600;font-size:14px;">物流实时状态</span></template>
          <div class="flow-steps">
            <div v-for="(step, i) in flowSteps" :key="step.label" class="flow-item" :class="{ active: step.active }">
              <div class="flow-bar" :style="{ width: step.progress + '%' }"></div>
              <span class="flow-label">{{ step.icon }} {{ step.label }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never">
          <template #header><span style="font-weight:600;font-size:14px;">📋 待办事项</span></template>
          <div v-for="item in todos" :key="item.text" class="todo-item" :class="item.type">
            <span class="todo-dot"></span>
            <span class="todo-text">{{ item.text }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '../utils/api'

const stats = ref([])
const flowSteps = ref([])
const todos = ref([])

onMounted(async () => {
  try {
    // Fetch consolidation dashboard
    const co = await api.get('/consolidation/dashboard')
    const data = co.data
    stats.value = [
      { icon: '📦', label: '今日集货量', value: data.total_stock + ' kg', bg: '#eff6ff', trend: '↑ 较昨日' },
      { icon: '🚛', label: '在途包裹', value: '3,426', bg: '#f0fdf4' },
      { icon: '✍️', label: '待签收', value: '847', bg: '#fffbeb' },
      { icon: '⚠️', label: '库存预警', value: data.low_stock_warnings + ' 项', bg: '#fef2f2', trend: data.low_stock_warnings > 0 ? '需处理' : '' },
    ]
  } catch(e) {}

  flowSteps.value = [
    { icon: '📦', label: '集货', progress: 100, active: true },
    { icon: '🚛', label: '运输', progress: 85, active: true },
    { icon: '🏛️', label: '报关', progress: 60, active: true },
    { icon: '🏛️', label: '清关', progress: 55 },
    { icon: '🚴', label: '配送', progress: 70 },
    { icon: '✍️', label: '签收', progress: 45 },
  ]

  todos.value = [
    { text: '3 笔报关材料缺失需补充', type: 'danger' },
    { text: '12 笔对账差异待处理', type: 'warning' },
    { text: '5 批货物需确认集货', type: 'info' },
    { text: '2 笔结算单待审核', type: 'success' },
  ]
})
</script>

<style scoped>
.stat-card { position: relative; display: flex; align-items: center; gap: 12px; padding: 8px; }
.stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px; }
.stat-value { font-size: 22px; font-weight: 700; color: #1f2937; }
.stat-label { font-size: 12px; color: #6b7280; margin-top: 2px; }
.stat-trend { position: absolute; bottom: 8px; right: 16px; font-size: 11px; }
.stat-trend.up { color: #22c55e; }
.mt-4 { margin-top: 16px; }
.flow-steps { display: flex; gap: 16px; }
.flow-item { flex: 1; text-align: center; }
.flow-bar { height: 8px; border-radius: 4px; background: #e5e7eb; margin-bottom: 6px; }
.flow-item.active .flow-bar { background: linear-gradient(90deg, #3b82f6, #22c55e); }
.flow-label { font-size: 12px; color: #6b7280; }
.todo-item { display: flex; align-items: center; gap: 8px; padding: 8px 10px; border-radius: 8px; font-size: 13px; margin-bottom: 6px; }
.todo-item.danger { background: #fef2f2; }
.todo-item.warning { background: #fffbeb; }
.todo-item.info { background: #eff6ff; }
.todo-item.success { background: #f0fdf4; }
.todo-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.danger .todo-dot { background: #ef4444; }
.warning .todo-dot { background: #f59e0b; }
.info .todo-dot { background: #3b82f6; }
.success .todo-dot { background: #22c55e; }
</style>

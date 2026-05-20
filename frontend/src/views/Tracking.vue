<template>
  <div class="tracking">
    <!-- 统计卡片 -->
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

    <!-- 查询栏 -->
    <el-card shadow="never" class="mt-4 search-card">
      <el-form :model="searchForm" inline @keyup.enter="handleSearch">
        <el-form-item label="查询类型">
          <el-select v-model="searchForm.type" style="width:120px">
            <el-option label="订单号" value="order_no" />
            <el-option label="运单号" value="waybill_no" />
            <el-option label="批次号" value="batch" />
          </el-select>
        </el-form-item>
        <el-form-item label="查询值">
          <el-input v-model="searchForm.query" :placeholder="`请输入${typeLabel}`" clearable style="width:240px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">🔍 查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 查询结果 -->
    <el-card shadow="never" class="mt-4">
      <template #header>
        <span>📄 追踪结果</span>
      </template>
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%" @row-click="handleRowClick">
        <el-table-column prop="package_no" label="包裹号" min-width="150" />
        <el-table-column prop="order_no" label="订单号" min-width="160" />
        <el-table-column prop="goods_name" label="品名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="sender" label="发件方" min-width="120" show-overflow-tooltip />
        <el-table-column prop="receiver" label="收件方" min-width="120" show-overflow-tooltip />
        <el-table-column prop="current_node" label="当前节点" min-width="120" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small" effect="plain">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
      <div v-if="tableData.length === 0 && !loading" class="empty-tip">
        <el-empty description="请输入查询条件查看追踪结果" />
      </div>
    </el-card>

    <!-- 时间线弹窗 -->
    <el-dialog v-model="showTimelineDialog" title="📦 物流追踪详情" width="700px" :close-on-click-modal="false" top="5vh">
      <template v-if="timelinePackage">
        <el-descriptions :column="2" border size="small" class="mb-4">
          <el-descriptions-item label="包裹号">{{ timelinePackage.package_no }}</el-descriptions-item>
          <el-descriptions-item label="订单号">{{ timelinePackage.order_no }}</el-descriptions-item>
          <el-descriptions-item label="品名">{{ timelinePackage.goods_name }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusType(timelinePackage.status)" size="small" effect="plain">
              {{ statusLabel(timelinePackage.status) }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <!-- 七步进度 -->
        <div class="step-progress">
          <div
            v-for="(step, idx) in steps"
            :key="idx"
            class="step-item"
            :class="{ active: step.done, current: step.active }"
          >
            <div class="step-dot">
              <span v-if="step.done">✓</span>
              <span v-else-if="step.active">●</span>
              <span v-else>○</span>
            </div>
            <div class="step-label">{{ step.label }}</div>
            <div v-if="step.time" class="step-time">{{ step.time }}</div>
          </div>
        </div>

        <el-divider />

        <!-- 详细时间线 -->
        <div class="detail-timeline">
          <div v-for="(item, idx) in timelineDetail" :key="idx" class="timeline-item">
            <div class="timeline-dot" :class="{ highlight: idx === 0 }"></div>
            <div class="timeline-content">
              <div class="timeline-title">{{ item.node }}</div>
              <div class="timeline-desc">{{ item.description || item.action }}</div>
              <div class="timeline-time">{{ item.time }}</div>
            </div>
          </div>
          <div v-if="timelineDetail.length === 0" class="empty-tip">
            <el-empty description="暂无详细时间线数据" />
          </div>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// 统计卡片
const stats = ref([
  { icon: '📦', label: '运输中', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '已签收', value: '0', bg: '#f0fdf4' },
  { icon: '⏳', label: '待揽收', value: '0', bg: '#fffbeb' },
  { icon: '⚠️', label: '异常件', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/tracking/dashboard')
    const d = res.data
    stats.value = [
      { icon: '📦', label: '运输中', value: d.in_transit ?? '0', bg: '#eff6ff' },
      { icon: '✅', label: '已签收', value: d.signed ?? '0', bg: '#f0fdf4', trend: '完成' },
      { icon: '⏳', label: '待揽收', value: d.pending ?? '0', bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '⚠️', label: '异常件', value: d.abnormal ?? '0', bg: '#fef2f2', trend: d.abnormal > 0 ? '需关注' : '' },
    ]
  } catch (e) {
    // fallback
  }
}

// 搜索
const searchForm = reactive({
  type: 'order_no',
  query: '',
})
const typeLabel = computed(() => {
  const map = { order_no: '订单号', waybill_no: '运单号', batch: '批次号' }
  return map[searchForm.type] || '查询值'
})

const loading = ref(false)
const tableData = ref([])

async function handleSearch() {
  const q = searchForm.query.trim()
  if (!q) {
    ElMessage.warning('请输入查询值')
    return
  }
  loading.value = true
  try {
    const params = { type: searchForm.type, query: q }
    const res = await api.get('/tracking/query', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    if (tableData.value.length === 0) {
      ElMessage.info('未找到匹配的追踪记录')
    }
  } catch (e) {
    ElMessage.error('查询失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  searchForm.query = ''
  tableData.value = []
}

// 7步进度定义
const steps = ref([
  { label: '已下单', key: 'ordered', done: false, active: false, time: '' },
  { label: '已揽收', key: 'collected', done: false, active: false, time: '' },
  { label: '已出关', key: 'exported', done: false, active: false, time: '' },
  { label: '运输中', key: 'in_transit', done: false, active: false, time: '' },
  { label: '已清关', key: 'cleared', done: false, active: false, time: '' },
  { label: '配送中', key: 'delivering', done: false, active: false, time: '' },
  { label: '已签收', key: 'signed', done: false, active: false, time: '' },
])

// 时间线弹窗
const showTimelineDialog = ref(false)
const timelinePackage = ref(null)
const timelineDetail = ref([])

async function handleRowClick(row) {
  timelinePackage.value = row
  showTimelineDialog.value = true
  try {
    const res = await api.get(`/tracking/${row.package_no}/detail`)
    const d = res.data
    timelineDetail.value = d.timeline || d.list || d.items || []

    // 更新7步进度
    const newSteps = steps.value.map(s => ({ ...s, done: false, active: false, time: '' }))
    if (d.nodes && d.nodes.length > 0) {
      d.nodes.forEach(n => {
        const match = newSteps.find(s => s.key === n.key)
        if (match) {
          match.done = n.done ?? true
          match.active = n.active ?? false
          match.time = n.time || ''
        }
      })
    } else if (timelineDetail.value.length > 0) {
      // 从详细时间线推断进度
      const nodeKeys = timelineDetail.value.map(t => t.node_key || t.key).filter(Boolean)
      nodeKeys.forEach(k => {
        const match = newSteps.find(s => s.key === k)
        if (match) match.done = true
      })
    }
    steps.value = newSteps
  } catch (e) {
    // fallback — show empty detail
    timelineDetail.value = []
  }
}

// 工具函数
function statusType(status) {
  const map = { pending: 'info', collected: 'warning', exported: 'primary', in_transit: 'primary', cleared: '', delivering: 'warning', signed: 'success', abnormal: 'danger' }
  return map[status] || 'info'
}
function statusLabel(status) {
  const map = { pending: '待揽收', collected: '已揽收', exported: '已出关', in_transit: '运输中', cleared: '已清关', delivering: '配送中', signed: '已签收', abnormal: '异常' }
  return map[status] || status
}

// 初始化
onMounted(() => {
  fetchDashboard()
})
</script>

<style scoped>
.stat-card {
  position: relative;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px;
}
.stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}
.stat-info { flex: 1; }
.stat-value { font-size: 22px; font-weight: 700; color: #1f2937; }
.stat-label { font-size: 12px; color: #6b7280; margin-top: 2px; }
.stat-trend {
  position: absolute;
  bottom: 8px;
  right: 16px;
  font-size: 11px;
}
.stat-trend.up { color: #22c55e; }
.stat-trend.down { color: #ef4444; }
.mt-4 { margin-top: 16px; }
.search-card {
  padding: 6px 12px;
}
.search-card .el-form {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.empty-tip {
  padding: 24px 0;
}
.mb-4 { margin-bottom: 16px; }

/* 七步进度条 */
.step-progress {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16px 0;
  position: relative;
}
.step-progress::before {
  content: '';
  position: absolute;
  top: 28px;
  left: 30px;
  right: 30px;
  height: 3px;
  background: #e5e7eb;
  z-index: 0;
}
.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 1;
  flex: 1;
  cursor: default;
}
.step-dot {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  color: #9ca3af;
  margin-bottom: 6px;
  transition: all 0.3s;
}
.step-item.active .step-dot {
  background: #3b82f6;
  color: #fff;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}
.step-item.current .step-dot {
  background: #f59e0b;
  color: #fff;
  box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.2);
  animation: pulse 1.5s infinite;
}
@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.2); }
  50% { box-shadow: 0 0 0 8px rgba(245, 158, 11, 0.1); }
}
.step-label {
  font-size: 11px;
  color: #6b7280;
  text-align: center;
  white-space: nowrap;
}
.step-time {
  font-size: 10px;
  color: #9ca3af;
  margin-top: 2px;
}

/* 详细时间线 */
.detail-timeline {
  padding: 8px 0;
  position: relative;
}
.detail-timeline::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 12px;
  width: 2px;
  background: #e5e7eb;
}
.timeline-item {
  display: flex;
  gap: 16px;
  padding-bottom: 20px;
  position: relative;
}
.timeline-item:last-child {
  padding-bottom: 0;
}
.timeline-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #d1d5db;
  margin-top: 5px;
  flex-shrink: 0;
  position: relative;
  z-index: 1;
  margin-left: 8px;
}
.timeline-dot.highlight {
  background: #3b82f6;
  width: 12px;
  height: 12px;
  margin-left: 7px;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
}
.timeline-content {
  flex: 1;
}
.timeline-title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}
.timeline-desc {
  font-size: 12px;
  color: #6b7280;
  margin-top: 2px;
}
.timeline-time {
  font-size: 11px;
  color: #9ca3af;
  margin-top: 4px;
}
</style>

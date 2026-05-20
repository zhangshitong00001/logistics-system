<template>
  <div class="analytics">
    <!-- KPI 卡片 -->
    <el-row :gutter="16">
      <el-col :span="4" v-for="card in kpiCards" :key="card.label">
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

    <!-- 指标切换 + 图表占位 -->
    <el-card shadow="never" class="mt-4">
      <div class="chart-header">
        <div class="chart-tabs">
          <el-button
            v-for="tab in metricTabs"
            :key="tab.key"
            :type="activeMetric === tab.key ? 'primary' : 'default'"
            size="small"
            @click="activeMetric = tab.key"
          >
            {{ tab.label }}
          </el-button>
        </div>
      </div>
      <div class="chart-placeholder">
        <div class="placeholder-icon">📊</div>
        <div class="placeholder-text">图表可视化区域 — {{ activeMetricLabel }}</div>
        <div class="placeholder-sub">（集成 ECharts / Chart.js 后可展示动态图表）</div>
      </div>
    </el-card>

    <!-- 预置报表 -->
    <el-card shadow="never" class="mt-4">
      <template #header>
        <span>📋 预置报表</span>
      </template>
      <el-table :data="reportList" stripe style="width:100%">
        <el-table-column prop="report_name" label="报表名称" min-width="200" />
        <el-table-column prop="report_type" label="类型" width="120">
          <template #default="{ row }">
            <el-tag size="small" effect="plain">{{ row.report_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" min-width="260" />
        <el-table-column prop="updated_at" label="更新时间" width="170" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleViewReport(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// KPI 卡片
const kpiCards = ref([
  { icon: '✅', label: '报关通过率', value: '0%', bg: '#f0fdf4' },
  { icon: '🚚', label: '配送完成率', value: '0%', bg: '#eff6ff' },
  { icon: '📊', label: '对账准确率', value: '0%', bg: '#fffbeb' },
  { icon: '📦', label: '集货总量', value: '0', bg: '#fef2f2' },
  { icon: '💰', label: '月结算金额', value: '¥0', bg: '#f5f3ff' },
])

async function fetchKpi() {
  try {
    const res = await api.get('/analytics/kpi')
    const d = res.data
    kpiCards.value = [
      { icon: '✅', label: '报关通过率', value: d.customs_pass_rate != null ? d.customs_pass_rate + '%' : '0%', bg: '#f0fdf4', trend: d.customs_pass_rate > 80 ? '↑ 良好' : '↓ 偏低' },
      { icon: '🚚', label: '配送完成率', value: d.delivery_completion_rate != null ? d.delivery_completion_rate + '%' : '0%', bg: '#eff6ff', trend: d.delivery_completion_rate > 80 ? '↑ 良好' : '' },
      { icon: '📊', label: '对账准确率', value: d.reconciliation_accuracy != null ? d.reconciliation_accuracy + '%' : '0%', bg: '#fffbeb', trend: d.reconciliation_accuracy > 90 ? '↑ 优秀' : '' },
      { icon: '📦', label: '集货总量', value: d.total_consolidation != null ? Number(d.total_consolidation).toLocaleString() : '0', bg: '#fef2f2' },
      { icon: '💰', label: '月结算金额', value: d.monthly_settlement != null ? '¥' + Number(d.monthly_settlement).toLocaleString() : '¥0', bg: '#f5f3ff', trend: '本月' },
    ]
  } catch (e) { /* fallback */ }
}

// 指标切换
const activeMetric = ref('customs')
const metricTabs = [
  { key: 'customs', label: '📋 报关通过率' },
  { key: 'delivery', label: '🚚 配送完成率' },
  { key: 'reconciliation', label: '📊 对账准确率' },
  { key: 'consolidation', label: '📦 集货趋势' },
  { key: 'settlement', label: '💰 结算趋势' },
]

const activeMetricLabel = computed(() => {
  const found = metricTabs.find(t => t.key === activeMetric.value)
  return found ? found.label : ''
})

// 预置报表
const reportList = ref([])

async function fetchReports() {
  try {
    const res = await api.get('/analytics/report')
    const d = res.data
    reportList.value = d.list || d.items || d || []
  } catch (e) {
    // 使用默认数据
    reportList.value = [
      { report_name: '集货量日报', report_type: '日报', description: '每日各仓库集货量统计，含件数、重量、体积', updated_at: '-' },
      { report_name: '运输时效分析', report_type: '分析', description: '各线路运输时长统计与时效达成率分析', updated_at: '-' },
      { report_name: '报关通过率统计', report_type: '统计', description: '报关申请通过率月度趋势与原因分析', updated_at: '-' },
      { report_name: '配送完成率报表', report_type: '月报', description: '配送任务完成率及超时配送明细', updated_at: '-' },
      { report_name: '对账差异分析', report_type: '分析', description: '对账差异汇总、原因分类与趋势分析', updated_at: '-' },
      { report_name: '月度结算汇总', report_type: '月报', description: '月度应收应付汇总与合作方结算明细', updated_at: '-' },
    ]
  }
}

function handleViewReport(row) {
  ElMessage.info(`报表：${row.report_name}`)
}

// 初始化
onMounted(() => {
  fetchKpi()
  fetchReports()
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
.chart-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}
.chart-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
.chart-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 280px;
  background: #f9fafb;
  border: 2px dashed #d1d5db;
  border-radius: 12px;
  color: #9ca3af;
}
.placeholder-icon {
  font-size: 48px;
  margin-bottom: 12px;
}
.placeholder-text {
  font-size: 18px;
  font-weight: 600;
  color: #6b7280;
}
.placeholder-sub {
  font-size: 13px;
  color: #9ca3af;
  margin-top: 6px;
}
</style>

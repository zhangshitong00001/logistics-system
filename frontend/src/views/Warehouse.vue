<template>
  <div class="warehouse">
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

    <!-- 看板：三列布局 -->
    <el-row :gutter="16" class="mt-4 kanban-row">
      <!-- 待分拣 -->
      <el-col :span="8">
        <el-card shadow="never" class="kanban-column">
          <template #header>
            <div class="kanban-header">
              <span>⏳ 待分拣</span>
              <el-tag type="warning" size="small">{{ pendingTasks.length }}</el-tag>
            </div>
          </template>
          <div class="kanban-body" v-loading="loading">
            <div v-if="pendingTasks.length === 0" class="kanban-empty">暂无待分拣任务</div>
            <div v-for="task in pendingTasks" :key="task.id" class="kanban-card">
              <div class="kanban-card-title">{{ task.task_no || task.id }}</div>
              <div class="kanban-card-info">
                <span>批次：{{ task.batch }}</span>
                <span>货品：{{ task.goods }}</span>
              </div>
              <div class="kanban-card-info">
                <span>数量：{{ task.quantity }}</span>
              </div>
              <div class="kanban-card-actions">
                <el-button size="small" type="primary" plain @click="handleStartSort(task)">开始分拣</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 分拣中 -->
      <el-col :span="8">
        <el-card shadow="never" class="kanban-column">
          <template #header>
            <div class="kanban-header">
              <span>🔄 分拣中</span>
              <el-tag type="primary" size="small">{{ activeTasks.length }}</el-tag>
            </div>
          </template>
          <div class="kanban-body" v-loading="loading">
            <div v-if="activeTasks.length === 0" class="kanban-empty">暂无分拣中的任务</div>
            <div v-for="task in activeTasks" :key="task.id" class="kanban-card kanban-card-active">
              <div class="kanban-card-title">{{ task.task_no || task.id }}</div>
              <div class="kanban-card-info">
                <span>批次：{{ task.batch }}</span>
                <span>货品：{{ task.goods }}</span>
              </div>
              <div class="kanban-card-info">
                <span>数量：{{ task.quantity }}</span>
                <span>分拣员：{{ task.operator || '-' }}</span>
              </div>
              <div class="kanban-card-actions">
                <el-button size="small" type="success" plain @click="handleCompleteSort(task)">完成分拣</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 已完成 -->
      <el-col :span="8">
        <el-card shadow="never" class="kanban-column">
          <template #header>
            <div class="kanban-header">
              <span>✅ 已完成</span>
              <el-tag type="success" size="small">{{ completedTasks.length }}</el-tag>
            </div>
          </template>
          <div class="kanban-body" v-loading="loading">
            <div v-if="completedTasks.length === 0" class="kanban-empty">暂无已完成任务</div>
            <div v-for="task in completedTasks" :key="task.id" class="kanban-card kanban-card-done">
              <div class="kanban-card-title">{{ task.task_no || task.id }}</div>
              <div class="kanban-card-info">
                <span>批次：{{ task.batch }}</span>
                <span>货品：{{ task.goods }}</span>
              </div>
              <div class="kanban-card-info">
                <span>完成时间：{{ task.completed_time || task.update_time || '-' }}</span>
              </div>
              <div class="kanban-card-actions">
                <el-tag type="success" size="small" effect="plain">✅ 已完成</el-tag>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// 统计卡片
const stats = ref([
  { icon: '⏳', label: '待分拣', value: '0', bg: '#fffbeb' },
  { icon: '🔄', label: '分拣中', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '已完成', value: '0', bg: '#f0fdf4' },
  { icon: '🎯', label: '准确率', value: '0%', bg: '#f5f3ff' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/warehouse/dashboard')
    const d = res.data
    stats.value = [
      { icon: '⏳', label: '待分拣', value: d.pending ?? '0', bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '🔄', label: '分拣中', value: d.in_progress ?? '0', bg: '#eff6ff' },
      { icon: '✅', label: '已完成', value: d.completed ?? '0', bg: '#f0fdf4' },
      { icon: '🎯', label: '准确率', value: (d.accuracy ?? 0) + '%', bg: '#f5f3ff' },
    ]
  } catch (e) {
    // fallback
  }
}

// 看板数据
const loading = ref(false)
const kanbanData = ref([])

const pendingTasks = computed(() => kanbanData.value.filter(t => t.status === 'pending'))
const activeTasks = computed(() => kanbanData.value.filter(t => t.status === 'in_progress'))
const completedTasks = computed(() => kanbanData.value.filter(t => t.status === 'completed'))

async function fetchKanban() {
  loading.value = true
  try {
    const res = await api.get('/warehouse/kanban')
    kanbanData.value = res.data?.list || res.data?.tasks || res.data || []
  } catch (e) {
    ElMessage.error('获取看板数据失败')
  } finally {
    loading.value = false
  }
}

// 操作
async function handleStartSort(task) {
  try {
    await api.put(`/warehouse/sorting-task/${task.id}/start`)
    ElMessage.success(`任务 ${task.task_no || task.id} 已开始分拣`)
    fetchKanban()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

async function handleCompleteSort(task) {
  try {
    await api.put(`/warehouse/sorting-task/${task.id}/complete`)
    ElMessage.success(`任务 ${task.task_no || task.id} 已完成分拣`)
    fetchKanban()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

// 初始化
onMounted(() => {
  fetchDashboard()
  fetchKanban()
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

/* 看板样式 */
.kanban-row {
  min-height: 480px;
}
.kanban-column {
  height: 100%;
}
.kanban-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 600;
  font-size: 14px;
}
.kanban-body {
  min-height: 360px;
  max-height: 600px;
  overflow-y: auto;
  padding: 4px 0;
}
.kanban-empty {
  text-align: center;
  color: #9ca3af;
  padding: 40px 0;
  font-size: 13px;
}
.kanban-card {
  background: #f9fafb;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 10px;
  border-left: 4px solid #eab308;
  transition: box-shadow 0.2s;
}
.kanban-card:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.kanban-card-active {
  border-left-color: #3b82f6;
}
.kanban-card-done {
  border-left-color: #22c55e;
  opacity: 0.85;
}
.kanban-card-title {
  font-weight: 600;
  font-size: 13px;
  color: #1f2937;
  margin-bottom: 6px;
}
.kanban-card-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
}
.kanban-card-actions {
  margin-top: 8px;
  display: flex;
  justify-content: flex-end;
}
</style>

<template>
  <div class="transport">
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

    <!-- 车辆表格 + 运输任务表格 -->
    <el-row :gutter="16" class="mt-4">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span style="font-weight:600;font-size:14px;">🚛 运输车辆</span>
              <el-button size="small" type="primary" plain @click="fetchVehicles">刷新</el-button>
            </div>
          </template>
          <el-table :data="vehicles" stripe style="width:100%" v-loading="vehicleLoading" size="small">
            <el-table-column prop="plate" label="车牌号" min-width="110" />
            <el-table-column prop="driver" label="司机" min-width="80" />
            <el-table-column prop="type" label="车辆类型" min-width="80" />
            <el-table-column label="状态" min-width="80">
              <template #default="{ row }">
                <el-tag :type="statusType(row.status)" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span style="font-weight:600;font-size:14px;">📋 运输任务</span>
              <el-button size="small" type="primary" @click="dialogVisible = true">+ 创建任务</el-button>
            </div>
          </template>
          <el-table :data="tasks" stripe style="width:100%" v-loading="taskLoading" size="small">
            <el-table-column prop="task_no" label="任务编号" min-width="120" />
            <el-table-column prop="route" label="路线" min-width="110" />
            <el-table-column prop="batch" label="批次" min-width="70" />
            <el-table-column prop="driver" label="司机" min-width="80" />
            <el-table-column label="状态" min-width="80">
              <template #default="{ row }">
                <el-tag :type="statusType(row.status)" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- 创建运输任务弹窗 -->
    <el-dialog v-model="dialogVisible" title="创建运输任务" width="500px" :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px" size="small">
        <el-form-item label="任务编号" prop="task_no">
          <el-input v-model="form.task_no" placeholder="自动生成则留空" />
        </el-form-item>
        <el-form-item label="路线" prop="route">
          <el-select v-model="form.route" placeholder="请选择路线" style="width:100%">
            <el-option label="广州→深圳" value="广州→深圳" />
            <el-option label="广州→东莞" value="广州→东莞" />
            <el-option label="深圳→广州" value="深圳→广州" />
            <el-option label="东莞→广州" value="东莞→广州" />
          </el-select>
        </el-form-item>
        <el-form-item label="批次" prop="batch">
          <el-input v-model="form.batch" placeholder="请输入批次号" />
        </el-form-item>
        <el-form-item label="司机" prop="driver">
          <el-input v-model="form.driver" placeholder="请输入司机姓名" />
        </el-form-item>
        <el-form-item label="车牌号" prop="plate">
          <el-input v-model="form.plate" placeholder="请输入车牌号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="dialogVisible = false">取消</el-button>
        <el-button size="small" type="primary" :loading="submitting" @click="handleSubmit">确认创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// ----- 统计卡片 -----
const stats = ref([
  { icon: '🚛', label: '运输中车辆', value: '0', bg: '#eff6ff' },
  { icon: '🚀', label: '今日发车', value: '0', bg: '#f0fdf4' },
  { icon: '🏁', label: '今日到达', value: '0', bg: '#f5f3ff' },
  { icon: '✅', label: '准点率', value: '0%', bg: '#fffbeb' },
  { icon: '⚠️', label: '异常数', value: '0', bg: '#fef2f2', trend: '' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/transport/dashboard')
    const d = res.data
    stats.value = [
      { icon: '🚛', label: '运输中车辆', value: d.in_transit ?? '0', bg: '#eff6ff' },
      { icon: '🚀', label: '今日发车', value: d.departed_today ?? '0', bg: '#f0fdf4' },
      { icon: '🏁', label: '今日到达', value: d.arrived_today ?? '0', bg: '#f5f3ff' },
      { icon: '✅', label: '准点率', value: (d.on_time_rate ?? 0) + '%', bg: '#fffbeb' },
      { icon: '⚠️', label: '异常数', value: d.anomaly_count ?? '0', bg: '#fef2f2', trend: d.anomaly_count > 0 ? '需处理' : '' },
    ]
  } catch (e) {
    // fallback to defaults
  }
}

// ----- 车辆表格 -----
const vehicles = ref([])
const vehicleLoading = ref(false)

async function fetchVehicles() {
  vehicleLoading.value = true
  try {
    const res = await api.get('/transport/vehicle')
    vehicles.value = res.data || []
  } catch (e) {
    ElMessage.error('获取车辆数据失败')
  } finally {
    vehicleLoading.value = false
  }
}

// ----- 运输任务表格 -----
const tasks = ref([])
const taskLoading = ref(false)

async function fetchTasks() {
  taskLoading.value = true
  try {
    const res = await api.get('/transport/task')
    tasks.value = res.data || []
  } catch (e) {
    ElMessage.error('获取任务数据失败')
  } finally {
    taskLoading.value = false
  }
}

// ----- 创建任务弹窗 -----
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const form = ref({
  task_no: '',
  route: '',
  batch: '',
  driver: '',
  plate: '',
})

const rules = {
  route: [{ required: true, message: '请选择路线', trigger: 'change' }],
  batch: [{ required: true, message: '请输入批次号', trigger: 'blur' }],
  driver: [{ required: true, message: '请输入司机姓名', trigger: 'blur' }],
  plate: [{ required: true, message: '请输入车牌号', trigger: 'blur' }],
}

async function handleSubmit() {
  if (!formRef.value) return
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    await api.post('/transport/task', { ...form.value })
    ElMessage.success('运输任务创建成功')
    dialogVisible.value = false
    formRef.value.resetFields()
    fetchTasks()
  } catch (e) {
    ElMessage.error('创建失败')
  } finally {
    submitting.value = false
  }
}

// ----- 工具函数 -----
function statusType(status) {
  const map = {
    '待发车': 'info',
    '运输中': 'warning',
    '已到达': 'success',
    '已签收': 'success',
    '异常': 'danger',
  }
  return map[status] || 'info'
}

// ----- 初始化 -----
onMounted(() => {
  fetchDashboard()
  fetchVehicles()
  fetchTasks()
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
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>

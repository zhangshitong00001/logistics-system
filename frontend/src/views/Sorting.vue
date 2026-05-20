<template>
  <div class="sorting">
    <!-- Statistics Cards -->
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

    <!-- Search & Actions -->
    <el-row :gutter="16" class="mt-4">
      <el-col :span="24">
        <el-card shadow="never">
          <div class="toolbar">
            <div class="search-area">
              <el-input
                v-model="searchQuery"
                placeholder="搜索收件点名称、编号或地址..."
                clearable
                style="width: 320px"
                @clear="fetchTasks"
                @keyup.enter="fetchTasks"
              >
                <template #prefix>
                  <el-icon><span>🔍</span></el-icon>
                </template>
              </el-input>
              <el-button type="primary" @click="fetchTasks">搜索</el-button>
            </div>
            <el-button type="primary" @click="showCreateDialog = true">
              ＋ 新建分装任务
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Table -->
    <el-row :gutter="16" class="mt-4">
      <el-col :span="24">
        <el-card shadow="never">
          <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
            <el-table-column prop="id" label="编号" width="80" />
            <el-table-column prop="name" label="收件点名称" min-width="140" />
            <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
            <el-table-column prop="batch" label="批次" width="120" />
            <el-table-column prop="package_count" label="包裹数" width="90" align="center" />
            <el-table-column prop="responsible_person" label="负责人" width="120" />
            <el-table-column label="进度" width="200">
              <template #default="{ row }">
                <div class="progress-cell">
                  <el-progress
                    :percentage="row.progress"
                    :status="row.progress >= 100 ? 'success' : row.status === 'abnormal' ? 'exception' : ''"
                    :stroke-width="16"
                    :text-inside="true"
                  />
                </div>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- Pagination -->
          <div class="pagination-wrap" v-if="total > 0">
            <el-pagination
              v-model:current-page="currentPage"
              :page-size="pageSize"
              :total="total"
              background
              layout="total, prev, pager, next"
              @current-change="fetchTasks"
            />
          </div>

          <el-empty v-if="!loading && tableData.length === 0" description="暂无分装任务" />
        </el-card>
      </el-col>
    </el-row>

    <!-- Create Task Dialog -->
    <el-dialog v-model="showCreateDialog" title="新建分装任务" width="520px" :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="110px">
        <el-form-item label="收件点" prop="point_name">
          <el-input v-model="form.point_name" placeholder="请输入收件点名称" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入收件点地址" />
        </el-form-item>
        <el-form-item label="批次" prop="batch">
          <el-input v-model="form.batch" placeholder="例如：BATCH-20260520" />
        </el-form-item>
        <el-form-item label="包裹数量" prop="package_count">
          <el-input-number v-model="form.package_count" :min="1" :max="99999" style="width: 100%" />
        </el-form-item>
        <el-form-item label="负责人" prop="responsible_person">
          <el-input v-model="form.responsible_person" placeholder="请输入负责人姓名" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleCreate">确认创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// ---- Stats ----
const stats = ref([])

// ---- Table ----
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(15)
const searchQuery = ref('')

// ---- Dialog ----
const showCreateDialog = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const form = ref({
  point_name: '',
  address: '',
  batch: '',
  package_count: 1,
  responsible_person: '',
})
const formRules = {
  point_name: [{ required: true, message: '请输入收件点名称', trigger: 'blur' }],
  batch: [{ required: true, message: '请输入批次', trigger: 'blur' }],
  package_count: [{ required: true, type: 'number', min: 1, message: '包裹数量至少为 1', trigger: 'blur' }],
  responsible_person: [{ required: true, message: '请输入负责人', trigger: 'blur' }],
}

// ---- Fetch Dashboard Stats ----
async function fetchDashboard() {
  try {
    const res = await api.get('/sorting/dashboard')
    const data = res.data || res
    stats.value = [
      { icon: '📍', label: '收件点总数', value: data.total_points ?? 408, bg: '#eff6ff' },
      { icon: '📋', label: '今日分装任务', value: data.today_tasks ?? '—', bg: '#f0fdf4' },
      { icon: '✅', label: '已完成', value: data.completed ?? '—', bg: '#fffbeb' },
      { icon: '⚠️', label: '异常件', value: data.abnormal ?? '—', bg: '#fef2f2', trend: data.abnormal > 0 ? '需处理' : '' },
    ]
  } catch (e) {
    // Fallback static stats
    stats.value = [
      { icon: '📍', label: '收件点总数', value: '408', bg: '#eff6ff' },
      { icon: '📋', label: '今日分装任务', value: '—', bg: '#f0fdf4' },
      { icon: '✅', label: '已完成', value: '—', bg: '#fffbeb' },
      { icon: '⚠️', label: '异常件', value: '—', bg: '#fef2f2' },
    ]
  }
}

// ---- Fetch Tasks ----
async function fetchTasks() {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      page_size: pageSize.value,
    }
    if (searchQuery.value.trim()) {
      params.query = searchQuery.value.trim()
    }
    const res = await api.get('/sorting/task', { params })
    const data = res.data || res
    tableData.value = data.items || data.list || []
    total.value = data.total ?? tableData.value.length
  } catch (e) {
    // Fallback demo data
    tableData.value = generateDemoData()
    total.value = tableData.value.length
  } finally {
    loading.value = false
  }
}

// Generate fallback demo data
function generateDemoData() {
  const points = [
    { id: 'SP-001', name: '城东收件点', address: '东城区建国路88号', batch: 'BATCH-001', package_count: 256, responsible_person: '张三', progress: 100, status: 'completed' },
    { id: 'SP-002', name: '城南收件点', address: '南山区科技路12号', batch: 'BATCH-001', package_count: 189, responsible_person: '李四', progress: 65, status: 'active' },
    { id: 'SP-003', name: '城西收件点', address: '西城区解放路56号', batch: 'BATCH-002', package_count: 312, responsible_person: '王五', progress: 40, status: 'active' },
    { id: 'SP-004', name: '城北收件点', address: '北城区人民路77号', batch: 'BATCH-002', package_count: 145, responsible_person: '赵六', progress: 0, status: 'pending' },
    { id: 'SP-005', name: '机场收件点', address: '机场大道1号航站楼B1', batch: 'BATCH-003', package_count: 520, responsible_person: '孙七', progress: 85, status: 'active' },
    { id: 'SP-006', name: '大学城收件点', address: '大学城学府路100号', batch: 'BATCH-003', package_count: 78, responsible_person: '周八', progress: 30, status: 'abnormal' },
    { id: 'SP-007', name: '开发区收件点', address: '经济技术开发区工业路9号', batch: 'BATCH-003', package_count: 223, responsible_person: '吴九', progress: 100, status: 'completed' },
    { id: 'SP-008', name: '火车站收件点', address: '火车站广场东侧物流中心', batch: 'BATCH-004', package_count: 167, responsible_person: '郑十', progress: 55, status: 'active' },
  ]
  return points
}

// ---- Create Task ----
async function handleCreate() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    await api.post('/sorting/task', {
      point_name: form.value.point_name,
      address: form.value.address,
      batch: form.value.batch,
      package_count: form.value.package_count,
      responsible_person: form.value.responsible_person,
    })
    ElMessage.success('分装任务创建成功')
    showCreateDialog.value = false
    formRef.value.resetFields()
    form.value = { point_name: '', address: '', batch: '', package_count: 1, responsible_person: '' }
    fetchTasks()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    submitting.value = false
  }
}

// ---- Edit ----
function handleEdit(row) {
  ElMessage.info(`编辑功能开发中 - ${row.name}`)
}

// ---- Init ----
onMounted(() => {
  fetchDashboard()
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
.stat-value {
  font-size: 22px;
  font-weight: 700;
  color: #1f2937;
}
.stat-label {
  font-size: 12px;
  color: #6b7280;
  margin-top: 2px;
}
.stat-trend {
  position: absolute;
  bottom: 8px;
  right: 16px;
  font-size: 11px;
}
.stat-trend.up { color: #22c55e; }
.stat-trend.down { color: #ef4444; }

.mt-4 { margin-top: 16px; }

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.search-area {
  display: flex;
  align-items: center;
  gap: 8px;
}

.progress-cell {
  padding: 4px 0;
}

.pagination-wrap {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>

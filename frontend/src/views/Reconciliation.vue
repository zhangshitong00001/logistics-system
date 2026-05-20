<template>
  <div class="reconciliation">
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

    <!-- 操作栏 -->
    <el-card shadow="never" class="mt-4 search-card">
      <el-form :model="filterForm" inline @keyup.enter="fetchData">
        <el-form-item label="结算周期">
          <el-select v-model="filterForm.cycle" placeholder="选择周期" style="width:120px" @change="fetchData">
            <el-option label="周结" value="weekly" />
            <el-option label="月结" value="monthly" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filterForm.status" placeholder="全部状态" clearable style="width:130px" @change="fetchData">
            <el-option label="待对账" value="pending" />
            <el-option label="对账中" value="in_progress" />
            <el-option label="已完成" value="completed" />
            <el-option label="差异待处理" value="diff_pending" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="success" @click="showCreateDialog = true">+ 创建对账</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 对账任务表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="reconciliation_no" label="对账编号" min-width="160" />
        <el-table-column prop="cycle_label" label="周期" min-width="120" />
        <el-table-column prop="total_amount" label="总金额" width="130" align="right">
          <template #default="{ row }">
            {{ row.total_amount != null ? '¥' + Number(row.total_amount).toLocaleString() : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="diff_amount" label="差异金额" width="130" align="right">
          <template #default="{ row }">
            <span :class="row.diff_amount > 0 ? 'diff-warn' : ''">
              {{ row.diff_amount != null ? '¥' + Number(row.diff_amount).toLocaleString() : '-' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="110">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small" effect="plain">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button
              v-if="row.status === 'diff_pending'"
              text type="warning" size="small"
              @click="openResolveDiff(row)"
            >处理差异</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 创建对账弹窗 -->
    <el-dialog v-model="showCreateDialog" title="+ 创建对账任务" width="520px" :close-on-click-modal="false">
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="100px">
        <el-form-item label="对账编号" prop="reconciliation_no">
          <el-input v-model="createForm.reconciliation_no" placeholder="自动生成则留空" />
        </el-form-item>
        <el-form-item label="结算周期" prop="cycle">
          <el-select v-model="createForm.cycle" placeholder="选择结算周期" style="width:100%">
            <el-option label="周结" value="weekly" />
            <el-option label="月结" value="monthly" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="start_date">
          <el-date-picker v-model="createForm.start_date" type="date" placeholder="开始日期" style="width:100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="结束日期" prop="end_date">
          <el-date-picker v-model="createForm.end_date" type="date" placeholder="结束日期" style="width:100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="createForm.remark" type="textarea" :rows="3" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showCreateDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="creating" @click="handleCreate">确认创建</el-button>
      </template>
    </el-dialog>

    <!-- 处理差异弹窗 -->
    <el-dialog v-model="showDiffDialog" title="⚠️ 处理差异" width="520px" :close-on-click-modal="false">
      <el-descriptions :column="2" border size="small" class="mb-4">
        <el-descriptions-item label="对账编号">{{ diffRow.reconciliation_no }}</el-descriptions-item>
        <el-descriptions-item label="周期">{{ diffRow.cycle_label }}</el-descriptions-item>
        <el-descriptions-item label="总金额">{{ diffRow.total_amount != null ? '¥' + Number(diffRow.total_amount).toLocaleString() : '-' }}</el-descriptions-item>
        <el-descriptions-item label="差异金额">
          <span class="diff-warn">{{ diffRow.diff_amount != null ? '¥' + Number(diffRow.diff_amount).toLocaleString() : '-' }}</span>
        </el-descriptions-item>
      </el-descriptions>
      <el-divider />
      <el-form ref="diffFormRef" :model="diffForm" :rules="diffRules" label-width="100px">
        <el-form-item label="处理方式" prop="action">
          <el-radio-group v-model="diffForm.action">
            <el-radio value="adjust">调整金额</el-radio>
            <el-radio value="ignore">忽略差异</el-radio>
            <el-radio value="reconcile">重新对账</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="调整金额" v-if="diffForm.action === 'adjust'">
          <el-input-number v-model="diffForm.adjust_amount" :min="0" :precision="2" style="width:100%" placeholder="输入调整金额" />
        </el-form-item>
        <el-form-item label="处理说明" prop="remark">
          <el-input v-model="diffForm.remark" type="textarea" :rows="3" placeholder="请输入差异处理说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showDiffDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="resolving" @click="handleResolveDiff">确认处理</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// 统计卡片
const stats = ref([
  { icon: '📋', label: '待对账', value: '0', bg: '#fffbeb' },
  { icon: '🔄', label: '对账中', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '已完成', value: '0', bg: '#f0fdf4' },
  { icon: '⚠️', label: '差异待处理', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/reconciliation/dashboard')
    const d = res.data
    stats.value = [
      { icon: '📋', label: '待对账', value: d.pending ?? '0', bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '🔄', label: '对账中', value: d.in_progress ?? '0', bg: '#eff6ff' },
      { icon: '✅', label: '已完成', value: d.completed ?? '0', bg: '#f0fdf4' },
      { icon: '⚠️', label: '差异待处理', value: d.diff_pending ?? '0', bg: '#fef2f2', trend: d.diff_pending > 0 ? '需处理' : '' },
    ]
  } catch (e) {
    // fallback
  }
}

// 筛选
const filterForm = reactive({
  cycle: 'monthly',
  status: '',
})

// 表格
const loading = ref(false)
const tableData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function fetchData() {
  loading.value = true
  try {
    const params = { page: page.value, page_size: pageSize.value, ...filterForm }
    Object.keys(params).forEach(k => { if (!params[k]) delete params[k] })
    const res = await api.get('/reconciliation/task', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取对账数据失败')
  } finally {
    loading.value = false
  }
}

// 创建对账弹窗
const showCreateDialog = ref(false)
const creating = ref(false)
const createFormRef = ref(null)
const createForm = reactive({
  reconciliation_no: '',
  cycle: 'monthly',
  start_date: '',
  end_date: '',
  remark: '',
})
const createRules = {
  cycle: [{ required: true, message: '请选择结算周期', trigger: 'change' }],
  start_date: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  end_date: [{ required: true, message: '请选择结束日期', trigger: 'change' }],
}

async function handleCreate() {
  if (!createFormRef.value) return
  const valid = await createFormRef.value.validate().catch(() => false)
  if (!valid) return
  creating.value = true
  try {
    await api.post('/reconciliation/task', { ...createForm })
    ElMessage.success('对账任务创建成功')
    showCreateDialog.value = false
    createFormRef.value.resetFields()
    createForm.cycle = 'monthly'
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    creating.value = false
  }
}

// 处理差异弹窗
const showDiffDialog = ref(false)
const resolving = ref(false)
const diffFormRef = ref(null)
const diffRow = ref({})
const diffForm = reactive({
  action: 'adjust',
  adjust_amount: 0,
  remark: '',
})
const diffRules = {
  action: [{ required: true, message: '请选择处理方式', trigger: 'change' }],
  remark: [{ required: true, message: '请输入处理说明', trigger: 'blur' }],
}

function openResolveDiff(row) {
  diffRow.value = { ...row }
  diffForm.action = 'adjust'
  diffForm.adjust_amount = Math.abs(row.diff_amount || 0)
  diffForm.remark = ''
  showDiffDialog.value = true
}

async function handleResolveDiff() {
  if (!diffFormRef.value) return
  const valid = await diffFormRef.value.validate().catch(() => false)
  if (!valid) return
  resolving.value = true
  try {
    const payload = { ...diffForm }
    if (payload.action !== 'adjust') {
      delete payload.adjust_amount
    }
    await api.put(`/reconciliation/task/${diffRow.value.id}/resolve-diff`, payload)
    ElMessage.success('差异已处理')
    showDiffDialog.value = false
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('处理失败，请重试')
  } finally {
    resolving.value = false
  }
}

// 查看
function handleView(row) {
  ElMessage.info(`对账编号：${row.reconciliation_no}`)
}

// 工具函数
function statusType(status) {
  const map = { pending: 'warning', in_progress: 'primary', completed: 'success', diff_pending: 'danger' }
  return map[status] || 'info'
}
function statusLabel(status) {
  const map = { pending: '待对账', in_progress: '对账中', completed: '已完成', diff_pending: '差异待处理' }
  return map[status] || status
}

// 初始化
onMounted(() => {
  fetchDashboard()
  fetchData()
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
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
.mb-4 { margin-bottom: 16px; }
.diff-warn {
  color: #ef4444;
  font-weight: 600;
}
</style>

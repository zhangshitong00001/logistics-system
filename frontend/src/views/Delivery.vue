<template>
  <div class="delivery">
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
      <el-form :model="searchForm" inline @keyup.enter="handleSearch">
        <el-form-item label="配送单号">
          <el-input v-model="searchForm.delivery_no" placeholder="配送单号" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="配送员">
          <el-input v-model="searchForm.courier" placeholder="配送员" clearable style="width:140px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width:130px">
            <el-option label="待配送" value="pending" />
            <el-option label="配送中" value="in_transit" />
            <el-option label="已签收" value="signed" />
            <el-option label="异常" value="abnormal" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">🔍 搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="showCreateDialog = true">+ 创建配送</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="delivery_no" label="配送单号" min-width="160" />
        <el-table-column prop="recipient" label="收件点" min-width="120" />
        <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="parcel_count" label="包裹数" width="90" align="center" />
        <el-table-column prop="courier" label="配送员" min-width="100" />
        <el-table-column label="状态" width="100">
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
              v-if="row.status === 'pending'"
              text type="warning" size="small"
              @click="handleUpdateStatus(row, 'in_transit')"
            >开始配送</el-button>
            <el-button
              v-if="row.status === 'in_transit'"
              text type="success" size="small"
              @click="handleUpdateStatus(row, 'signed')"
            >签收</el-button>
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

    <!-- 创建配送任务弹窗 -->
    <el-dialog v-model="showCreateDialog" title="+ 创建配送任务" width="520px" :close-on-click-modal="false">
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="100px">
        <el-form-item label="配送单号" prop="delivery_no">
          <el-input v-model="createForm.delivery_no" placeholder="自动生成则留空" />
        </el-form-item>
        <el-form-item label="收件点" prop="recipient">
          <el-input v-model="createForm.recipient" placeholder="请输入收件点名称" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="createForm.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="包裹数" prop="parcel_count">
          <el-input-number v-model="createForm.parcel_count" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="配送员" prop="courier">
          <el-select v-model="createForm.courier" placeholder="请选择配送员" style="width:100%" filterable allow-create>
            <el-option v-for="c in courierOptions" :key="c" :label="c" :value="c" />
          </el-select>
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../utils/api'

// 统计卡片
const stats = ref([
  { icon: '🚚', label: '配送中', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '今日完成', value: '0', bg: '#f0fdf4' },
  { icon: '📊', label: '完成率', value: '0%', bg: '#f5f3ff' },
  { icon: '⚠️', label: '异常', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/delivery/dashboard')
    const d = res.data
    stats.value = [
      { icon: '🚚', label: '配送中', value: d.in_transit ?? '0', bg: '#eff6ff' },
      { icon: '✅', label: '今日完成', value: d.completed_today ?? '0', bg: '#f0fdf4', trend: '今日' },
      { icon: '📊', label: '完成率', value: (d.completion_rate ?? 0) + '%', bg: '#f5f3ff' },
      { icon: '⚠️', label: '异常', value: d.abnormal ?? '0', bg: '#fef2f2', trend: d.abnormal > 0 ? '需处理' : '' },
    ]
  } catch (e) {
    // fallback
  }
}

// 搜索
const searchForm = reactive({
  delivery_no: '',
  courier: '',
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
    const params = { page: page.value, page_size: pageSize.value, ...searchForm }
    Object.keys(params).forEach(k => { if (!params[k]) delete params[k] })
    const res = await api.get('/delivery/task', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取配送数据失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  fetchData()
}

function handleReset() {
  searchForm.delivery_no = ''
  searchForm.courier = ''
  searchForm.status = ''
  page.value = 1
  fetchData()
}

// 创建配送弹窗
const showCreateDialog = ref(false)
const creating = ref(false)
const createFormRef = ref(null)
const courierOptions = ref(['张三', '李四', '王五', '赵六'])
const createForm = reactive({
  delivery_no: '',
  recipient: '',
  address: '',
  parcel_count: 1,
  courier: '',
  remark: '',
})
const createRules = {
  recipient: [{ required: true, message: '请输入收件点名称', trigger: 'blur' }],
  address: [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
  parcel_count: [{ required: true, message: '请输入包裹数', trigger: 'blur' }],
  courier: [{ required: true, message: '请选择配送员', trigger: 'change' }],
}

async function handleCreate() {
  if (!createFormRef.value) return
  const valid = await createFormRef.value.validate().catch(() => false)
  if (!valid) return
  creating.value = true
  try {
    await api.post('/delivery/task', { ...createForm })
    ElMessage.success('配送任务创建成功')
    showCreateDialog.value = false
    createFormRef.value.resetFields()
    createForm.parcel_count = 1
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    creating.value = false
  }
}

// 操作
function handleView(row) {
  ElMessage.info(`配送单号：${row.delivery_no}`)
}

async function handleUpdateStatus(row, newStatus) {
  const actionLabel = newStatus === 'in_transit' ? '开始配送' : '确认签收'
  const statusDesc = newStatus === 'in_transit' ? '开始配送该任务？' : '确认该配送任务已签收？'
  try {
    await ElMessageBox.confirm(statusDesc, actionLabel, { type: 'info', confirmButtonText: '确认', cancelButtonText: '取消' })
    await api.put(`/delivery/task/${row.id}/status`, { status: newStatus })
    ElMessage.success(actionLabel + '成功')
    fetchData()
    fetchDashboard()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// 工具函数
function statusType(status) {
  const map = { pending: 'info', in_transit: 'warning', signed: 'success', abnormal: 'danger' }
  return map[status] || 'info'
}
function statusLabel(status) {
  const map = { pending: '待配送', in_transit: '配送中', signed: '已签收', abnormal: '异常' }
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
</style>

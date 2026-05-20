<template>
  <div class="settlement">
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
        <el-form-item label="结算单号">
          <el-input v-model="filterForm.settlement_no" placeholder="结算单号" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="合作方">
          <el-input v-model="filterForm.partner" placeholder="合作方" clearable style="width:140px" @keyup.enter="fetchData" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filterForm.status" placeholder="全部状态" clearable style="width:130px" @change="fetchData">
            <el-option label="草稿" value="draft" />
            <el-option label="待审核" value="pending_audit" />
            <el-option label="已审核" value="approved" />
            <el-option label="已驳回" value="rejected" />
            <el-option label="已结算" value="settled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">🔍 搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="showCreateDialog = true">+ 创建结算单</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 结算单表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="settlement_no" label="结算单号" min-width="160" />
        <el-table-column prop="partner" label="合作方" min-width="130" />
        <el-table-column prop="amount" label="金额" width="130" align="right">
          <template #default="{ row }">
            {{ row.amount != null ? '¥' + Number(row.amount).toLocaleString() : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="方向" width="90">
          <template #default="{ row }">
            <el-tag :type="row.direction === 'receivable' ? 'primary' : 'warning'" size="small" effect="plain">
              {{ row.direction === 'receivable' ? '应收' : '应付' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small" effect="plain">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button
              v-if="row.status === 'draft'"
              text type="warning" size="small"
              @click="handleSubmitAudit(row)"
            >提交审核</el-button>
            <el-button
              v-if="row.status === 'pending_audit'"
              text type="success" size="small"
              @click="openAudit(row)"
            >审核</el-button>
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

    <!-- 创建结算单弹窗 -->
    <el-dialog v-model="showCreateDialog" title="+ 创建结算单" width="520px" :close-on-click-modal="false">
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="100px">
        <el-form-item label="结算单号" prop="settlement_no">
          <el-input v-model="createForm.settlement_no" placeholder="自动生成则留空" />
        </el-form-item>
        <el-form-item label="合作方" prop="partner">
          <el-input v-model="createForm.partner" placeholder="请输入合作方名称" />
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="createForm.amount" :min="0" :precision="2" style="width:100%" placeholder="请输入金额" />
        </el-form-item>
        <el-form-item label="方向" prop="direction">
          <el-radio-group v-model="createForm.direction">
            <el-radio value="receivable">应收</el-radio>
            <el-radio value="payable">应付</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="结算周期" prop="cycle">
          <el-select v-model="createForm.cycle" placeholder="选择结算周期" style="width:100%">
            <el-option label="周结" value="weekly" />
            <el-option label="月结" value="monthly" />
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

    <!-- 审核弹窗 -->
    <el-dialog v-model="showAuditDialog" title="🔍 审核结算单" width="480px" :close-on-click-modal="false">
      <el-descriptions :column="2" border size="small" class="mb-4">
        <el-descriptions-item label="结算单号">{{ auditRow.settlement_no }}</el-descriptions-item>
        <el-descriptions-item label="合作方">{{ auditRow.partner }}</el-descriptions-item>
        <el-descriptions-item label="金额">{{ auditRow.amount != null ? '¥' + Number(auditRow.amount).toLocaleString() : '-' }}</el-descriptions-item>
        <el-descriptions-item label="方向">
          <el-tag :type="auditRow.direction === 'receivable' ? 'primary' : 'warning'" size="small" effect="plain">
            {{ auditRow.direction === 'receivable' ? '应收' : '应付' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
      <el-divider />
      <el-form ref="auditFormRef" :model="auditForm" :rules="auditRules" label-width="80px">
        <el-form-item label="审核结果" prop="action">
          <el-radio-group v-model="auditForm.action">
            <el-radio value="approve">通过</el-radio>
            <el-radio value="reject">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核意见" prop="comment">
          <el-input v-model="auditForm.comment" type="textarea" :rows="3" placeholder="请输入审核意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showAuditDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="auditing" @click="handleAudit">确认</el-button>
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
  { icon: '💰', label: '待结算金额', value: '¥0', bg: '#fffbeb' },
  { icon: '📊', label: '本月结算', value: '¥0', bg: '#eff6ff' },
  { icon: '📤', label: '应付', value: '¥0', bg: '#fef2f2' },
  { icon: '📥', label: '应收', value: '¥0', bg: '#f0fdf4' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/settlement/dashboard')
    const d = res.data
    stats.value = [
      { icon: '💰', label: '待结算金额', value: d.pending_amount != null ? '¥' + Number(d.pending_amount).toLocaleString() : '¥0', bg: '#fffbeb', trend: d.pending_amount > 0 ? '待结算' : '' },
      { icon: '📊', label: '本月结算', value: d.monthly_amount != null ? '¥' + Number(d.monthly_amount).toLocaleString() : '¥0', bg: '#eff6ff', trend: '本月' },
      { icon: '📤', label: '应付', value: d.payable_amount != null ? '¥' + Number(d.payable_amount).toLocaleString() : '¥0', bg: '#fef2f2' },
      { icon: '📥', label: '应收', value: d.receivable_amount != null ? '¥' + Number(d.receivable_amount).toLocaleString() : '¥0', bg: '#f0fdf4' },
    ]
  } catch (e) {
    // fallback
  }
}

// 筛选
const filterForm = reactive({
  settlement_no: '',
  partner: '',
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
    const res = await api.get('/settlement/order', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取结算数据失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  fetchData()
}

function handleReset() {
  filterForm.settlement_no = ''
  filterForm.partner = ''
  filterForm.status = ''
  page.value = 1
  fetchData()
}

// 创建结算单弹窗
const showCreateDialog = ref(false)
const creating = ref(false)
const createFormRef = ref(null)
const createForm = reactive({
  settlement_no: '',
  partner: '',
  amount: 0,
  direction: 'receivable',
  cycle: 'monthly',
  remark: '',
})
const createRules = {
  partner: [{ required: true, message: '请输入合作方名称', trigger: 'blur' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }],
  direction: [{ required: true, message: '请选择方向', trigger: 'change' }],
  cycle: [{ required: true, message: '请选择结算周期', trigger: 'change' }],
}

async function handleCreate() {
  if (!createFormRef.value) return
  const valid = await createFormRef.value.validate().catch(() => false)
  if (!valid) return
  creating.value = true
  try {
    await api.post('/settlement/order', { ...createForm })
    ElMessage.success('结算单创建成功')
    showCreateDialog.value = false
    createFormRef.value.resetFields()
    createForm.amount = 0
    createForm.direction = 'receivable'
    createForm.cycle = 'monthly'
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    creating.value = false
  }
}

// 提交审核
async function handleSubmitAudit(row) {
  try {
    await ElMessageBox.confirm(`确认提交结算单 ${row.settlement_no} 进行审核？`, '提交审核', {
      type: 'info',
      confirmButtonText: '确认提交',
      cancelButtonText: '取消',
    })
    await api.put(`/settlement/order/${row.id}/submit-audit`)
    ElMessage.success('已提交审核')
    fetchData()
    fetchDashboard()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('提交审核失败')
    }
  }
}

// 审核弹窗
const showAuditDialog = ref(false)
const auditing = ref(false)
const auditFormRef = ref(null)
const auditRow = ref({})
const auditForm = reactive({
  action: 'approve',
  comment: '',
})
const auditRules = {
  action: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
}

function openAudit(row) {
  auditRow.value = { ...row }
  auditForm.action = 'approve'
  auditForm.comment = ''
  showAuditDialog.value = true
}

async function handleAudit() {
  if (!auditFormRef.value) return
  const valid = await auditFormRef.value.validate().catch(() => false)
  if (!valid) return
  auditing.value = true
  try {
    await api.put(`/settlement/order/${auditRow.value.id}/audit`, { ...auditForm })
    ElMessage.success(auditForm.action === 'approve' ? '审核通过' : '已驳回')
    showAuditDialog.value = false
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('审核操作失败')
  } finally {
    auditing.value = false
  }
}

// 查看
function handleView(row) {
  ElMessage.info(`结算单号：${row.settlement_no}`)
}

// 工具函数
function statusType(status) {
  const map = { draft: 'info', pending_audit: 'warning', approved: 'success', rejected: 'danger', settled: 'primary' }
  return map[status] || 'info'
}
function statusLabel(status) {
  const map = { draft: '草稿', pending_audit: '待审核', approved: '已审核', rejected: '已驳回', settled: '已结算' }
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
</style>

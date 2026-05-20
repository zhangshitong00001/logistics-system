<template>
  <div class="customs">
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
        <el-form-item label="报关单号">
          <el-input v-model="searchForm.declaration_no" placeholder="报关单号" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="批次">
          <el-input v-model="searchForm.batch" placeholder="批次号" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width:130px">
            <el-option label="待提交" value="draft" />
            <el-option label="审核中" value="pending" />
            <el-option label="已通过" value="approved" />
            <el-option label="已驳回" value="rejected" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">🔍 搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="showSubmitDialog = true">📄 提交报关</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="declaration_no" label="报关单号" min-width="160" />
        <el-table-column prop="batch" label="批次" min-width="120" />
        <el-table-column prop="goods" label="货物" min-width="140" />
        <el-table-column prop="amount" label="金额" width="110" align="right">
          <template #default="{ row }">
            {{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="submit_time" label="提交时间" width="170" />
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
              @click="openReview(row)"
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

    <!-- 提交报关弹窗 -->
    <el-dialog v-model="showSubmitDialog" title="📄 提交报关" width="520px" :close-on-click-modal="false">
      <el-form ref="submitFormRef" :model="submitForm" :rules="submitRules" label-width="100px">
        <el-form-item label="报关单号" prop="declaration_no">
          <el-input v-model="submitForm.declaration_no" placeholder="自动生成则留空" />
        </el-form-item>
        <el-form-item label="批次" prop="batch">
          <el-input v-model="submitForm.batch" placeholder="请输入批次号" />
        </el-form-item>
        <el-form-item label="货物" prop="goods">
          <el-input v-model="submitForm.goods" placeholder="请输入货物名称" />
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="submitForm.amount" :min="0" :precision="2" style="width:100%" placeholder="请输入金额" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="submitForm.remark" type="textarea" :rows="3" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showSubmitDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 审核弹窗 -->
    <el-dialog v-model="showReviewDialog" title="🔍 审核报关" width="480px" :close-on-click-modal="false">
      <el-descriptions :column="2" border size="small" class="review-info">
        <el-descriptions-item label="报关单号">{{ reviewRow.declaration_no }}</el-descriptions-item>
        <el-descriptions-item label="批次">{{ reviewRow.batch }}</el-descriptions-item>
        <el-descriptions-item label="货物">{{ reviewRow.goods }}</el-descriptions-item>
        <el-descriptions-item label="金额">{{ reviewRow.amount ? '¥' + Number(reviewRow.amount).toLocaleString() : '-' }}</el-descriptions-item>
        <el-descriptions-item label="提交时间" :span="2">{{ reviewRow.submit_time }}</el-descriptions-item>
      </el-descriptions>
      <el-divider />
      <el-form ref="reviewFormRef" :model="reviewForm" :rules="reviewRules" label-width="80px">
        <el-form-item label="审核结果" prop="action">
          <el-radio-group v-model="reviewForm.action">
            <el-radio value="approve">通过</el-radio>
            <el-radio value="reject">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核意见" prop="comment">
          <el-input v-model="reviewForm.comment" type="textarea" :rows="3" placeholder="请输入审核意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showReviewDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="reviewing" @click="handleReview">确认</el-button>
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
  { icon: '📋', label: '待提交', value: '0', bg: '#fffbeb' },
  { icon: '🔄', label: '审核中', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '已通过', value: '0', bg: '#f0fdf4' },
  { icon: '❌', label: '已驳回', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/customs/dashboard')
    const d = res.data
    stats.value = [
      { icon: '📋', label: '待提交', value: d.draft ?? '0', bg: '#fffbeb', trend: d.draft > 0 ? '待处理' : '' },
      { icon: '🔄', label: '审核中', value: d.pending ?? '0', bg: '#eff6ff' },
      { icon: '✅', label: '已通过', value: d.approved ?? '0', bg: '#f0fdf4' },
      { icon: '❌', label: '已驳回', value: d.rejected ?? '0', bg: '#fef2f2', trend: d.rejected > 0 ? '需处理' : '' },
    ]
  } catch (e) {
    // fallback
  }
}

// 搜索
const searchForm = reactive({
  declaration_no: '',
  batch: '',
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
    const res = await api.get('/customs/declaration', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取报关数据失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  fetchData()
}

function handleReset() {
  searchForm.declaration_no = ''
  searchForm.batch = ''
  searchForm.status = ''
  page.value = 1
  fetchData()
}

// 提交报关弹窗
const showSubmitDialog = ref(false)
const submitting = ref(false)
const submitFormRef = ref(null)
const submitForm = reactive({
  declaration_no: '',
  batch: '',
  goods: '',
  amount: 0,
  remark: '',
})
const submitRules = {
  batch: [{ required: true, message: '请输入批次号', trigger: 'blur' }],
  goods: [{ required: true, message: '请输入货物名称', trigger: 'blur' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }],
}

async function handleSubmit() {
  if (!submitFormRef.value) return
  const valid = await submitFormRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    await api.post('/customs/declaration', { ...submitForm })
    ElMessage.success('报关提交成功')
    showSubmitDialog.value = false
    submitFormRef.value.resetFields()
    submitForm.amount = 0
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('提交失败，请重试')
  } finally {
    submitting.value = false
  }
}

// 审核弹窗
const showReviewDialog = ref(false)
const reviewing = ref(false)
const reviewFormRef = ref(null)
const reviewRow = ref({})
const reviewForm = reactive({
  action: 'approve',
  comment: '',
})
const reviewRules = {
  action: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
}

function openReview(row) {
  reviewRow.value = { ...row }
  reviewForm.action = 'approve'
  reviewForm.comment = ''
  showReviewDialog.value = true
}

async function handleReview() {
  if (!reviewFormRef.value) return
  const valid = await reviewFormRef.value.validate().catch(() => false)
  if (!valid) return
  reviewing.value = true
  try {
    await api.put(`/customs/declaration/${reviewRow.value.id}/review`, { ...reviewForm })
    ElMessage.success(reviewForm.action === 'approve' ? '已通过' : '已驳回')
    showReviewDialog.value = false
    fetchData()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('审核操作失败')
  } finally {
    reviewing.value = false
  }
}

// 查看
function handleView(row) {
  ElMessage.info(`报关单号：${row.declaration_no}`)
}

// 工具函数
function statusType(status) {
  const map = { draft: 'warning', pending: 'primary', approved: 'success', rejected: 'danger' }
  return map[status] || 'info'
}
function statusLabel(status) {
  const map = { draft: '待提交', pending: '审核中', approved: '已通过', rejected: '已驳回' }
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
.review-info {
  margin-bottom: 8px;
}
</style>

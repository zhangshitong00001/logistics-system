<template>
  <div class="signin">
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

    <!-- 包裹查询 -->
    <el-card shadow="never" class="mt-4 search-card">
      <el-form :model="searchForm" inline @keyup.enter="handleQueryPackage">
        <el-form-item label="包裹号">
          <el-input v-model="searchForm.package_no" placeholder="请输入包裹号" clearable style="width:260px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQueryPackage">🔍 查询包裹</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 签收表单 -->
    <el-card v-if="showSignForm" shadow="never" class="mt-4">
      <template #header>
        <span>📋 签收登记 — {{ currentPackage.package_no }}</span>
      </template>
      <el-form ref="signFormRef" :model="signForm" :rules="signRules" label-width="100px">
        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="包裹号" prop="package_no">
              <el-input v-model="signForm.package_no" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="签收结果" prop="sign_result">
              <el-select v-model="signForm.sign_result" placeholder="请选择签收结果" style="width:100%">
                <el-option label="正常签收" value="normal" />
                <el-option label="破损" value="damaged" />
                <el-option label="短少" value="shortage" />
                <el-option label="拒收" value="refused" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="签收人" prop="signer">
              <el-input v-model="signForm.signer" placeholder="请输入签收人姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="备注">
              <el-input v-model="signForm.remark" placeholder="备注信息（选填）" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item>
          <el-button type="primary" :loading="signing" @click="handleSign">✅ 确认签收</el-button>
          <el-button @click="showSignForm = false">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 签收记录 -->
    <el-card shadow="never" class="mt-4">
      <template #header>
        <span>📄 签收记录</span>
      </template>
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="sign_no" label="签收单号" min-width="160" />
        <el-table-column prop="package_no" label="包裹号" min-width="150" />
        <el-table-column label="签收结果" width="100">
          <template #default="{ row }">
            <el-tag :type="signResultType(row.sign_result)" size="small" effect="plain">
              {{ signResultLabel(row.sign_result) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="signer" label="签收人" width="100" />
        <el-table-column prop="sign_time" label="签收时间" width="170" />
        <el-table-column label="入库状态" width="110">
          <template #default="{ row }">
            <el-tag :type="row.inbound_status === 'done' ? 'success' : 'warning'" size="small" effect="plain">
              {{ row.inbound_status === 'done' ? '已入库' : '待入库' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.inbound_status !== 'done'"
              type="primary" size="small"
              :loading="inboundingId === row.id"
              @click="handleConfirmInbound(row)"
            >确认入库</el-button>
            <el-tag v-else type="success" size="small" effect="plain">✅ 已入库</el-tag>
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
          @size-change="fetchRecords"
          @current-change="fetchRecords"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

// 统计卡片
const stats = ref([
  { icon: '📦', label: '今日签收', value: '0', bg: '#f0fdf4' },
  { icon: '✅', label: '已入库', value: '0', bg: '#eff6ff' },
  { icon: '⏳', label: '待入库', value: '0', bg: '#fffbeb' },
  { icon: '⚠️', label: '异常签收', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/sign/dashboard')
    const d = res.data
    stats.value = [
      { icon: '📦', label: '今日签收', value: d.today ?? '0', bg: '#f0fdf4', trend: '今日' },
      { icon: '✅', label: '已入库', value: d.inbound ?? '0', bg: '#eff6ff' },
      { icon: '⏳', label: '待入库', value: d.pending ?? '0', bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '⚠️', label: '异常签收', value: d.abnormal ?? '0', bg: '#fef2f2', trend: d.abnormal > 0 ? '需关注' : '' },
    ]
  } catch (e) {
    // fallback
  }
}

// 包裹查询
const searchForm = reactive({
  package_no: '',
})
const showSignForm = ref(false)
const currentPackage = ref({})

async function handleQueryPackage() {
  const pkg = searchForm.package_no.trim()
  if (!pkg) {
    ElMessage.warning('请输入包裹号')
    return
  }
  try {
    const res = await api.get(`/sign/package/${pkg}`)
    currentPackage.value = res.data || res
    signForm.package_no = currentPackage.value.package_no || pkg
    showSignForm.value = true
    ElMessage.success('包裹查询成功')
  } catch (e) {
    ElMessage.error('未找到该包裹或查询失败')
    showSignForm.value = false
  }
}

function handleReset() {
  searchForm.package_no = ''
  showSignForm.value = false
}

// 签收表单
const signFormRef = ref(null)
const signing = ref(false)
const signForm = reactive({
  package_no: '',
  sign_result: '',
  signer: '',
  remark: '',
})
const signRules = {
  sign_result: [{ required: true, message: '请选择签收结果', trigger: 'change' }],
  signer: [{ required: true, message: '请输入签收人', trigger: 'blur' }],
}

async function handleSign() {
  if (!signFormRef.value) return
  const valid = await signFormRef.value.validate().catch(() => false)
  if (!valid) return
  signing.value = true
  try {
    await api.post('/sign', { ...signForm })
    ElMessage.success('签收成功')
    showSignForm.value = false
    signFormRef.value.resetFields()
    signForm.package_no = ''
    fetchRecords()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('签收失败，请重试')
  } finally {
    signing.value = false
  }
}

// 签收记录表格
const loading = ref(false)
const tableData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const inboundingId = ref(null)

async function fetchRecords() {
  loading.value = true
  try {
    const params = { page: page.value, page_size: pageSize.value }
    const res = await api.get('/sign/records', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取签收记录失败')
  } finally {
    loading.value = false
  }
}

// 确认入库
async function handleConfirmInbound(row) {
  inboundingId.value = row.id
  try {
    await api.put(`/sign/${row.id}/inbound`)
    ElMessage.success(`包裹 ${row.package_no} 已确认入库`)
    fetchRecords()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('入库失败')
  } finally {
    inboundingId.value = null
  }
}

// 工具函数
function signResultType(val) {
  const map = { normal: 'success', damaged: 'warning', shortage: 'danger', refused: 'info' }
  return map[val] || 'info'
}
function signResultLabel(val) {
  const map = { normal: '正常签收', damaged: '破损', shortage: '短少', refused: '拒收' }
  return map[val] || val
}

// 初始化
onMounted(() => {
  fetchDashboard()
  fetchRecords()
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

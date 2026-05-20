<template>
  <div class="consolidation">
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

    <!-- 搜索栏 -->
    <el-card shadow="never" class="mt-4 search-card">
      <el-form :model="searchForm" inline @keyup.enter="handleSearch">
        <el-form-item label="批次号">
          <el-input v-model="searchForm.batch_no" placeholder="批次号" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="品名">
          <el-input v-model="searchForm.product_name" placeholder="品名" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="SKU">
          <el-input v-model="searchForm.sku" placeholder="SKU" clearable style="width:160px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">🔍 搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="showReceiptDialog = true">📥 收货登记</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="batch_no" label="批次号" min-width="140" />
        <el-table-column prop="product_name" label="品名" min-width="120" />
        <el-table-column prop="sku" label="SKU" width="130" />
        <el-table-column prop="quantity" label="数量" width="80" align="right" />
        <el-table-column prop="weight" label="重量(kg)" width="100" align="right" />
        <el-table-column prop="owner" label="货主" min-width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusMap[row.status]?.type || 'info'" size="small" effect="plain">
              {{ statusMap[row.status]?.label || row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button text type="warning" size="small" @click="handleConfirm(row)" v-if="row.status === 'pending'">确认集货</el-button>
            <el-button text type="success" size="small" @click="handleReceipt(row)">收货</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
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

    <!-- 收货登记弹窗 -->
    <el-dialog v-model="showReceiptDialog" title="📥 收货登记" width="480px" :close-on-click-modal="false">
      <el-form :model="receiptForm" label-width="90px" ref="receiptFormRef" :rules="receiptRules">
        <el-form-item label="批次号" prop="batch_no">
          <el-input v-model="receiptForm.batch_no" placeholder="请输入批次号" />
        </el-form-item>
        <el-form-item label="SKU" prop="sku">
          <el-input v-model="receiptForm.sku" placeholder="请输入SKU" />
        </el-form-item>
        <el-form-item label="品名" prop="product_name">
          <el-input v-model="receiptForm.product_name" placeholder="请输入品名" />
        </el-form-item>
        <el-form-item label="数量" prop="quantity">
          <el-input-number v-model="receiptForm.quantity" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="重量(kg)" prop="weight">
          <el-input-number v-model="receiptForm.weight" :min="0" :precision="2" :step="0.1" style="width:100%" />
        </el-form-item>
        <el-form-item label="货主" prop="owner">
          <el-input v-model="receiptForm.owner" placeholder="请输入货主名称" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="receiptForm.remark" type="textarea" :rows="2" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showReceiptDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitReceipt">确认登记</el-button>
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
  { icon: '📦', label: '库存总量', value: '-', bg: '#eff6ff' },
  { icon: '⏳', label: '待确认集货', value: '-', bg: '#fffbeb' },
  { icon: '📥', label: '今日收货', value: '-', bg: '#f0fdf4' },
  { icon: '⚠️', label: '缺货预警', value: '-', bg: '#fef2f2' },
])

// 状态映射
const statusMap = {
  pending:    { label: '待确认', type: 'warning' },
  confirmed:  { label: '已确认', type: 'primary' },
  received:   { label: '已收货', type: 'success' },
  shortage:   { label: '缺货',   type: 'danger' },
}

// 搜索
const searchForm = reactive({
  batch_no: '',
  product_name: '',
  sku: '',
})

// 表格
const loading = ref(false)
const tableData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 收货弹窗
const showReceiptDialog = ref(false)
const submitting = ref(false)
const receiptFormRef = ref(null)
const receiptForm = reactive({
  batch_no: '',
  sku: '',
  product_name: '',
  quantity: 1,
  weight: 0,
  owner: '',
  remark: '',
})
const receiptRules = {
  batch_no:    [{ required: true, message: '请输入批次号', trigger: 'blur' }],
  sku:         [{ required: true, message: '请输入SKU',   trigger: 'blur' }],
  product_name:[{ required: true, message: '请输入品名',   trigger: 'blur' }],
  quantity:    [{ required: true, message: '请输入数量',   trigger: 'blur' }],
  weight:      [{ required: true, message: '请输入重量',   trigger: 'blur' }],
  owner:       [{ required: true, message: '请输入货主',   trigger: 'blur' }],
}

// 获取统计卡片数据
async function fetchStats() {
  try {
    const res = await api.get('/consolidation/dashboard')
    const d = res.data
    stats.value = [
      { icon: '📦', label: '库存总量',   value: (d.total_stock ?? '-') + ' 件',    bg: '#eff6ff', trend: d.total_stock_trend ?? '' },
      { icon: '⏳', label: '待确认集货', value: (d.pending ?? '-') + ' 批',       bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '📥', label: '今日收货',   value: (d.today_receipts ?? '-') + ' 件', bg: '#f0fdf4', trend: '今日' },
      { icon: '⚠️', label: '缺货预警',   value: (d.shortage ?? '-') + ' 项',      bg: '#fef2f2', trend: d.shortage > 0 ? '⚠️ 需补货' : '' },
    ]
  } catch (e) {
    // fallback to defaults
  }
}

// 获取表格数据
async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: page.value,
      page_size: pageSize.value,
      ...searchForm,
    }
    // 清除空值
    Object.keys(params).forEach(k => { if (!params[k]) delete params[k] })
    const res = await api.get('/consolidation/inventory', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取库存数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
function handleSearch() {
  page.value = 1
  fetchData()
}

function handleReset() {
  searchForm.batch_no = ''
  searchForm.product_name = ''
  searchForm.sku = ''
  page.value = 1
  fetchData()
}

// 操作
function handleView(row) {
  ElMessage.info(`查看详情：${row.batch_no}`)
}

async function handleConfirm(row) {
  try {
    await api.post('/consolidation/receipt', { batch_no: row.batch_no, action: 'confirm' })
    ElMessage.success(`批次 ${row.batch_no} 已确认集货`)
    fetchData()
    fetchStats()
  } catch (e) {
    ElMessage.error('确认失败')
  }
}

function handleReceipt(row) {
  receiptForm.batch_no = row.batch_no
  receiptForm.sku = row.sku
  receiptForm.product_name = row.product_name
  receiptForm.owner = row.owner
  receiptForm.quantity = 1
  receiptForm.weight = 0
  receiptForm.remark = ''
  showReceiptDialog.value = true
}

// 提交收货登记
async function submitReceipt() {
  const valid = await receiptFormRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    await api.post('/consolidation/receipt', { ...receiptForm })
    ElMessage.success('收货登记成功')
    showReceiptDialog.value = false
    fetchData()
    fetchStats()
  } catch (e) {
    ElMessage.error('登记失败，请重试')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchStats()
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

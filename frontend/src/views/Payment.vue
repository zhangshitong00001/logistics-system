<template>
  <div class="payment">
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

    <!-- 选项卡 -->
    <el-card shadow="never" class="mt-4">
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <!-- 支付记录 -->
        <el-tab-pane label="💰 支付记录" name="payment">
          <div class="toolbar">
            <el-button type="success" @click="showPayDialog = true">+ 发起支付</el-button>
          </div>
          <el-table :data="paymentData" stripe v-loading="loading" style="width:100%" class="mt-3">
            <el-table-column prop="payment_no" label="支付单号" min-width="160" />
            <el-table-column prop="amount" label="金额" width="130" align="right">
              <template #default="{ row }">
                {{ row.amount != null ? '¥' + Number(row.amount).toLocaleString() : '-' }}
              </template>
            </el-table-column>
            <el-table-column prop="channel" label="渠道" width="110">
              <template #default="{ row }">
                <el-tag size="small" effect="plain">{{ channelLabel(row.channel) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="pay_time" label="支付时间" width="170" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="payStatusType(row.status)" size="small" effect="plain">
                  {{ payStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button text type="primary" size="small" @click="handleViewPay(row)">查看</el-button>
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
              @size-change="fetchPayment"
              @current-change="fetchPayment"
            />
          </div>
        </el-tab-pane>

        <!-- 发票管理 -->
        <el-tab-pane label="🧾 发票管理" name="invoice">
          <div class="toolbar">
            <el-button type="success" @click="showInvoiceDialog = true">+ 生成发票</el-button>
          </div>
          <el-table :data="invoiceData" stripe v-loading="loadingInvoice" style="width:100%" class="mt-3">
            <el-table-column prop="invoice_no" label="发票号" min-width="160" />
            <el-table-column prop="invoice_type" label="类型" width="100">
              <template #default="{ row }">
                {{ row.invoice_type === 'vat_special' ? '增值税专用' : row.invoice_type === 'vat_normal' ? '增值税普通' : row.invoice_type }}
              </template>
            </el-table-column>
            <el-table-column prop="amount" label="金额" width="130" align="right">
              <template #default="{ row }">
                {{ row.amount != null ? '¥' + Number(row.amount).toLocaleString() : '-' }}
              </template>
            </el-table-column>
            <el-table-column prop="buyer" label="购方" min-width="150" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="invStatusType(row.status)" size="small" effect="plain">
                  {{ invStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button text type="primary" size="small" @click="handleViewInvoice(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="invPage"
              v-model:page-size="invPageSize"
              :page-sizes="[10, 20, 50]"
              :total="invTotal"
              layout="total, sizes, prev, pager, next"
              @size-change="fetchInvoice"
              @current-change="fetchInvoice"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 发起支付弹窗 -->
    <el-dialog v-model="showPayDialog" title="+ 发起支付" width="520px" :close-on-click-modal="false">
      <el-form ref="payFormRef" :model="payForm" :rules="payRules" label-width="100px">
        <el-form-item label="支付金额" prop="amount">
          <el-input-number v-model="payForm.amount" :min="0.01" :precision="2" style="width:100%" placeholder="请输入支付金额" />
        </el-form-item>
        <el-form-item label="支付渠道" prop="channel">
          <el-select v-model="payForm.channel" placeholder="选择支付渠道" style="width:100%">
            <el-option label="银行转账" value="bank" />
            <el-option label="支付宝" value="alipay" />
            <el-option label="微信支付" value="wechat" />
            <el-option label="对公账户" value="corporate" />
          </el-select>
        </el-form-item>
        <el-form-item label="关联单号">
          <el-input v-model="payForm.ref_no" placeholder="关联结算单号/报关单号（选填）" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="payForm.remark" type="textarea" :rows="3" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showPayDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="paying" @click="handlePay">确认支付</el-button>
      </template>
    </el-dialog>

    <!-- 生成发票弹窗 -->
    <el-dialog v-model="showInvoiceDialog" title="+ 生成发票" width="520px" :close-on-click-modal="false">
      <el-form ref="invFormRef" :model="invForm" :rules="invRules" label-width="120px">
        <el-form-item label="发票类型" prop="invoice_type">
          <el-select v-model="invForm.invoice_type" placeholder="选择发票类型" style="width:100%">
            <el-option label="增值税专用发票" value="vat_special" />
            <el-option label="增值税普通发票" value="vat_normal" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="invForm.amount" :min="0.01" :precision="2" style="width:100%" placeholder="请输入金额" />
        </el-form-item>
        <el-form-item label="购方名称" prop="buyer">
          <el-input v-model="invForm.buyer" placeholder="请输入购方名称" />
        </el-form-item>
        <el-form-item label="购方税号">
          <el-input v-model="invForm.buyer_tax_no" placeholder="购方税号（选填）" />
        </el-form-item>
        <el-form-item label="关联支付单">
          <el-input v-model="invForm.payment_no" placeholder="关联支付单号（选填）" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="invForm.remark" type="textarea" :rows="3" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showInvoiceDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="generating" @click="handleGenerateInvoice">确认生成</el-button>
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
  { icon: '💰', label: '今日支付', value: '¥0', bg: '#eff6ff' },
  { icon: '📊', label: '本月支付', value: '¥0', bg: '#f0fdf4' },
  { icon: '🧾', label: '待开票', value: '0', bg: '#fffbeb' },
  { icon: '✅', label: '已开票', value: '0', bg: '#fef2f2' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/payment/dashboard')
    const d = res.data
    stats.value = [
      { icon: '💰', label: '今日支付', value: d.today_amount != null ? '¥' + Number(d.today_amount).toLocaleString() : '¥0', bg: '#eff6ff' },
      { icon: '📊', label: '本月支付', value: d.monthly_amount != null ? '¥' + Number(d.monthly_amount).toLocaleString() : '¥0', bg: '#f0fdf4', trend: '本月' },
      { icon: '🧾', label: '待开票', value: d.pending_invoice ?? '0', bg: '#fffbeb', trend: d.pending_invoice > 0 ? '待处理' : '' },
      { icon: '✅', label: '已开票', value: d.invoiced ?? '0', bg: '#fef2f2' },
    ]
  } catch (e) { /* fallback */ }
}

// 选项卡
const activeTab = ref('payment')
function handleTabChange() {
  if (activeTab.value === 'payment') fetchPayment()
  else fetchInvoice()
}

// 支付表格
const loading = ref(false)
const paymentData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function fetchPayment() {
  loading.value = true
  try {
    const params = { page: page.value, page_size: pageSize.value }
    const res = await api.get('/payment/list', { params })
    const d = res.data
    paymentData.value = d.list || d.items || []
    total.value = d.total ?? paymentData.value.length
  } catch (e) {
    ElMessage.error('获取支付记录失败')
  } finally {
    loading.value = false
  }
}

function channelLabel(ch) {
  const map = { bank: '银行转账', alipay: '支付宝', wechat: '微信支付', corporate: '对公账户' }
  return map[ch] || ch || '-'
}

function payStatusType(s) {
  const map = { pending: 'warning', success: 'success', failed: 'danger', refunded: 'info' }
  return map[s] || 'info'
}

function payStatusLabel(s) {
  const map = { pending: '支付中', success: '已支付', failed: '支付失败', refunded: '已退款' }
  return map[s] || s || '-'
}

// 发票表格
const loadingInvoice = ref(false)
const invoiceData = ref([])
const invPage = ref(1)
const invPageSize = ref(10)
const invTotal = ref(0)

async function fetchInvoice() {
  loadingInvoice.value = true
  try {
    const params = { page: invPage.value, page_size: invPageSize.value }
    const res = await api.get('/payment/invoice/list', { params })
    const d = res.data
    invoiceData.value = d.list || d.items || []
    invTotal.value = d.total ?? invoiceData.value.length
  } catch (e) {
    ElMessage.error('获取发票数据失败')
  } finally {
    loadingInvoice.value = false
  }
}

function invStatusType(s) {
  const map = { draft: 'info', issued: 'success', voided: 'danger' }
  return map[s] || 'info'
}

function invStatusLabel(s) {
  const map = { draft: '草稿', issued: '已开具', voided: '已作废' }
  return map[s] || s || '-'
}

// 发起支付弹窗
const showPayDialog = ref(false)
const paying = ref(false)
const payFormRef = ref(null)
const payForm = reactive({
  amount: 0,
  channel: '',
  ref_no: '',
  remark: '',
})
const payRules = {
  amount: [{ required: true, message: '请输入支付金额', trigger: 'blur' }],
  channel: [{ required: true, message: '请选择支付渠道', trigger: 'change' }],
}

async function handlePay() {
  if (!payFormRef.value) return
  const valid = await payFormRef.value.validate().catch(() => false)
  if (!valid) return
  paying.value = true
  try {
    await api.post('/payment', { ...payForm })
    ElMessage.success('支付发起成功')
    showPayDialog.value = false
    payFormRef.value.resetFields()
    payForm.amount = 0
    payForm.channel = ''
    fetchPayment()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('支付发起失败，请重试')
  } finally {
    paying.value = false
  }
}

// 生成发票弹窗
const showInvoiceDialog = ref(false)
const generating = ref(false)
const invFormRef = ref(null)
const invForm = reactive({
  invoice_type: '',
  amount: 0,
  buyer: '',
  buyer_tax_no: '',
  payment_no: '',
  remark: '',
})
const invRules = {
  invoice_type: [{ required: true, message: '请选择发票类型', trigger: 'change' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }],
  buyer: [{ required: true, message: '请输入购方名称', trigger: 'blur' }],
}

async function handleGenerateInvoice() {
  if (!invFormRef.value) return
  const valid = await invFormRef.value.validate().catch(() => false)
  if (!valid) return
  generating.value = true
  try {
    await api.post('/payment/invoice', { ...invForm })
    ElMessage.success('发票生成成功')
    showInvoiceDialog.value = false
    invFormRef.value.resetFields()
    invForm.amount = 0
    invForm.invoice_type = ''
    fetchInvoice()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('发票生成失败，请重试')
  } finally {
    generating.value = false
  }
}

// 查看
function handleViewPay(row) {
  ElMessage.info(`支付单号：${row.payment_no}`)
}

function handleViewInvoice(row) {
  ElMessage.info(`发票号：${row.invoice_no}`)
}

// 初始化
onMounted(() => {
  fetchDashboard()
  fetchPayment()
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
.mt-3 { margin-top: 12px; }
.toolbar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 4px;
}
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>

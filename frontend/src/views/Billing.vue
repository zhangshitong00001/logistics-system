<template>
  <div class="billing">
    <!-- 统计卡片 -->
    <el-row :gutter="16">
      <el-col :span="6" v-for="card in stats" :key="card.label">
        <el-card shadow="never" class="stat-card">
          <div class="stat-icon" :style="{ background: card.bg }">{{ card.icon }}</div>
          <div class="stat-info">
            <div class="stat-value">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 筛选 + 操作 -->
    <el-card shadow="never" class="mt-4 search-card">
      <el-form :model="filterForm" inline>
        <el-form-item label="费用类型">
          <el-select v-model="filterForm.fee_type" placeholder="全部类型" clearable style="width:160px" @change="fetchData">
            <el-option label="运输费" value="transport" />
            <el-option label="仓储费" value="storage" />
            <el-option label="包装费" value="packaging" />
            <el-option label="附加费" value="surcharge" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="success" @click="openCreateDialog">+ 创建规则</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 规则表格 -->
    <el-card shadow="never" class="mt-4">
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="rule_name" label="规则名称" min-width="160" />
        <el-table-column label="费用类型" width="110">
          <template #default="{ row }">
            <el-tag size="small" effect="plain">{{ feeTypeLabel(row.fee_type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="billing_method" label="计费方式" width="130">
          <template #default="{ row }">
            {{ methodLabel(row.billing_method) }}
          </template>
        </el-table-column>
        <el-table-column label="费率" width="120" align="right">
          <template #default="{ row }">
            {{ row.rate != null ? (row.billing_method === 'percentage' ? row.rate + '%' : '¥' + row.rate) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级" width="80" align="center" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small" effect="plain">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="openEditDialog(row)">编辑</el-button>
            <el-button text type="success" size="small" @click="openSurchargeDialog(row)">+ 附加费</el-button>
            <el-button
              text
              :type="row.status === 1 ? 'warning' : 'success'"
              size="small"
              @click="toggleStatus(row)"
            >
              {{ row.status === 1 ? '禁用' : '启用' }}
            </el-button>
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

    <!-- 创建/编辑规则弹窗 -->
    <el-dialog v-model="showRuleDialog" :title="isEdit ? '✏️ 编辑规则' : '+ 创建规则'" width="520px" :close-on-click-modal="false">
      <el-form ref="ruleFormRef" :model="ruleForm" :rules="ruleRules" label-width="110px">
        <el-form-item label="规则名称" prop="rule_name">
          <el-input v-model="ruleForm.rule_name" placeholder="请输入规则名称" />
        </el-form-item>
        <el-form-item label="费用类型" prop="fee_type">
          <el-select v-model="ruleForm.fee_type" placeholder="选择费用类型" style="width:100%">
            <el-option label="运输费" value="transport" />
            <el-option label="仓储费" value="storage" />
            <el-option label="包装费" value="packaging" />
            <el-option label="附加费" value="surcharge" />
          </el-select>
        </el-form-item>
        <el-form-item label="计费方式" prop="billing_method">
          <el-select v-model="ruleForm.billing_method" placeholder="选择计费方式" style="width:100%">
            <el-option label="固定金额" value="fixed" />
            <el-option label="按比例" value="percentage" />
            <el-option label="按重量" value="weight" />
            <el-option label="按体积" value="volume" />
            <el-option label="按件数" value="quantity" />
          </el-select>
        </el-form-item>
        <el-form-item label="费率" prop="rate">
          <el-input-number v-model="ruleForm.rate" :min="0" :precision="4" style="width:100%" placeholder="请输入费率" />
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-input-number v-model="ruleForm.priority" :min="1" :max="999" style="width:100%" placeholder="数字越小优先级越高" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="ruleForm.description" type="textarea" :rows="2" placeholder="规则描述（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showRuleDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="savingRule" @click="handleSaveRule">{{ isEdit ? '保存修改' : '确认创建' }}</el-button>
      </template>
    </el-dialog>

    <!-- 附加费弹窗 -->
    <el-dialog v-model="showSurchargeDialog" title="+ 添加附加费" width="480px" :close-on-click-modal="false">
      <p class="mb-2">为规则 <strong>{{ surchargeRow.rule_name }}</strong> 添加附加费</p>
      <el-form ref="surchargeFormRef" :model="surchargeForm" :rules="surchargeRules" label-width="100px">
        <el-form-item label="附加费名称" prop="name">
          <el-input v-model="surchargeForm.name" placeholder="如：燃油附加费" />
        </el-form-item>
        <el-form-item label="费用类型" prop="fee_type">
          <el-select v-model="surchargeForm.fee_type" placeholder="选择类型" style="width:100%">
            <el-option label="固定金额" value="fixed" />
            <el-option label="按比例" value="percentage" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额/比例" prop="amount">
          <el-input-number v-model="surchargeForm.amount" :min="0" :precision="4" style="width:100%" :placeholder="surchargeForm.fee_type === 'percentage' ? '输入百分比' : '输入金额'" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="surchargeForm.description" type="textarea" :rows="2" placeholder="附加费说明（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showSurchargeDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="savingSurcharge" @click="handleSaveSurcharge">确认添加</el-button>
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
  { icon: '📋', label: '规则总数', value: '0', bg: '#eff6ff' },
  { icon: '✅', label: '已启用', value: '0', bg: '#f0fdf4' },
  { icon: '⏸️', label: '已禁用', value: '0', bg: '#fffbeb' },
  { icon: '📊', label: '附加费规则', value: '0', bg: '#fef2f2' },
])

// 筛选
const filterForm = reactive({
  fee_type: '',
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
    const params = { page: page.value, page_size: pageSize.value }
    if (filterForm.fee_type) params.fee_type = filterForm.fee_type
    const res = await api.get('/billing/rules', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取计费规则失败')
  } finally {
    loading.value = false
  }
}

function feeTypeLabel(t) {
  const map = { transport: '运输费', storage: '仓储费', packaging: '包装费', surcharge: '附加费' }
  return map[t] || t || '-'
}

function methodLabel(m) {
  const map = { fixed: '固定金额', percentage: '按比例', weight: '按重量', volume: '按体积', quantity: '按件数' }
  return map[m] || m || '-'
}

// 创建/编辑规则弹窗
const showRuleDialog = ref(false)
const isEdit = ref(false)
const editRuleId = ref(null)
const savingRule = ref(false)
const ruleFormRef = ref(null)
const ruleForm = reactive({
  rule_name: '',
  fee_type: '',
  billing_method: '',
  rate: 0,
  priority: 50,
  description: '',
})
const ruleRules = {
  rule_name: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  fee_type: [{ required: true, message: '请选择费用类型', trigger: 'change' }],
  billing_method: [{ required: true, message: '请选择计费方式', trigger: 'change' }],
  rate: [{ required: true, message: '请输入费率', trigger: 'blur' }],
  priority: [{ required: true, message: '请设置优先级', trigger: 'blur' }],
}

function openCreateDialog() {
  isEdit.value = false
  editRuleId.value = null
  ruleForm.rule_name = ''
  ruleForm.fee_type = ''
  ruleForm.billing_method = ''
  ruleForm.rate = 0
  ruleForm.priority = 50
  ruleForm.description = ''
  showRuleDialog.value = true
}

function openEditDialog(row) {
  isEdit.value = true
  editRuleId.value = row.id
  ruleForm.rule_name = row.rule_name
  ruleForm.fee_type = row.fee_type
  ruleForm.billing_method = row.billing_method
  ruleForm.rate = row.rate ?? 0
  ruleForm.priority = row.priority ?? 50
  ruleForm.description = row.description || ''
  showRuleDialog.value = true
}

async function handleSaveRule() {
  if (!ruleFormRef.value) return
  const valid = await ruleFormRef.value.validate().catch(() => false)
  if (!valid) return
  savingRule.value = true
  try {
    const payload = { ...ruleForm }
    if (isEdit.value && editRuleId.value) {
      await api.put(`/billing/rules/${editRuleId.value}`, payload)
      ElMessage.success('规则已更新')
    } else {
      await api.post('/billing/rules', payload)
      ElMessage.success('规则创建成功')
    }
    showRuleDialog.value = false
    ruleFormRef.value.resetFields()
    ruleForm.rate = 0
    ruleForm.priority = 50
    fetchData()
  } catch (e) {
    ElMessage.error(isEdit.value ? '更新失败，请重试' : '创建失败，请重试')
  } finally {
    savingRule.value = false
  }
}

// 启用/禁用
async function toggleStatus(row) {
  const newStatus = row.status === 1 ? 0 : 1
  try {
    await api.put(`/billing/rules/${row.id}`, { status: newStatus })
    ElMessage.success(newStatus === 1 ? '规则已启用' : '规则已禁用')
    fetchData()
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

// 附加费弹窗
const showSurchargeDialog = ref(false)
const savingSurcharge = ref(false)
const surchargeFormRef = ref(null)
const surchargeRow = ref({})
const surchargeForm = reactive({
  name: '',
  fee_type: 'fixed',
  amount: 0,
  description: '',
})
const surchargeRules = {
  name: [{ required: true, message: '请输入附加费名称', trigger: 'blur' }],
  amount: [{ required: true, message: '请输入金额或比例', trigger: 'blur' }],
}

function openSurchargeDialog(row) {
  surchargeRow.value = { ...row }
  surchargeForm.name = ''
  surchargeForm.fee_type = 'fixed'
  surchargeForm.amount = 0
  surchargeForm.description = ''
  showSurchargeDialog.value = true
}

async function handleSaveSurcharge() {
  if (!surchargeFormRef.value) return
  const valid = await surchargeFormRef.value.validate().catch(() => false)
  if (!valid) return
  savingSurcharge.value = true
  try {
    await api.post(`/billing/rules/${surchargeRow.value.id}/surcharge`, { ...surchargeForm })
    ElMessage.success('附加费已添加')
    showSurchargeDialog.value = false
    surchargeFormRef.value.resetFields()
    surchargeForm.amount = 0
    surchargeForm.fee_type = 'fixed'
    fetchData()
  } catch (e) {
    ElMessage.error('添加失败，请重试')
  } finally {
    savingSurcharge.value = false
  }
}

// 初始化
onMounted(() => {
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
.mb-2 { margin-bottom: 8px; }
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

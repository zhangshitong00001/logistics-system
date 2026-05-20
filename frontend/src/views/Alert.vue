<template>
  <div class="alert">
    <!-- 统计卡片 -->
    <el-row :gutter="16">
      <el-col :span="4" v-for="card in stats" :key="card.label">
        <el-card shadow="never" class="stat-card">
          <div class="stat-icon" :style="{ background: card.bg }">{{ card.icon }}</div>
          <div class="stat-info">
            <div class="stat-value">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 选项卡 -->
    <el-card shadow="never" class="mt-4">
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <!-- 预警记录 -->
        <el-tab-pane label="🚨 预警记录" name="record">
          <el-table :data="recordData" stripe v-loading="loading" style="width:100%">
            <el-table-column prop="alert_no" label="预警编号" min-width="140" />
            <el-table-column label="严重程度" width="100">
              <template #default="{ row }">
                <el-tag :type="severityType(row.severity)" size="small" effect="dark">
                  {{ severityLabel(row.severity) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="title" label="预警标题" min-width="180" />
            <el-table-column prop="source" label="来源" width="120" />
            <el-table-column prop="occur_time" label="发生时间" width="170" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'handled' ? 'success' : 'danger'" size="small" effect="plain">
                  {{ row.status === 'handled' ? '已处理' : '待处理' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="{ row }">
                <el-button v-if="row.status !== 'handled'" text type="primary" size="small" @click="openHandle(row)">处理</el-button>
                <el-button v-else text type="info" size="small" @click="handleViewAlert(row)">查看</el-button>
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
        </el-tab-pane>

        <!-- 预警规则 -->
        <el-tab-pane label="⚙️ 预警规则" name="rule">
          <el-table :data="ruleData" stripe v-loading="loadingRule" style="width:100%">
            <el-table-column prop="rule_name" label="规则名称" min-width="160" />
            <el-table-column prop="rule_code" label="规则编码" width="140" />
            <el-table-column prop="severity" label="触发级别" width="100">
              <template #default="{ row }">
                <el-tag :type="severityType(row.severity)" size="small" effect="dark">
                  {{ severityLabel(row.severity) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="condition_desc" label="触发条件" min-width="220" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-switch
                  v-model="row.enabled"
                  :active-value="1"
                  :inactive-value="0"
                  @change="(val) => toggleRule(row, val)"
                />
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 处理预警弹窗 -->
    <el-dialog v-model="showHandleDialog" title="🚨 处理预警" width="520px" :close-on-click-modal="false">
      <el-descriptions :column="2" border size="small" class="mb-4">
        <el-descriptions-item label="预警编号">{{ handleRow.alert_no }}</el-descriptions-item>
        <el-descriptions-item label="严重程度">
          <el-tag :type="severityType(handleRow.severity)" size="small" effect="dark">
            {{ severityLabel(handleRow.severity) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="标题" :span="2">{{ handleRow.title }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ handleRow.source }}</el-descriptions-item>
        <el-descriptions-item label="发生时间">{{ handleRow.occur_time }}</el-descriptions-item>
      </el-descriptions>
      <el-divider />
      <el-form ref="handleFormRef" :model="handleForm" :rules="handleRules" label-width="100px">
        <el-form-item label="处理方式" prop="action">
          <el-select v-model="handleForm.action" placeholder="选择处理方式" style="width:100%">
            <el-option label="已确认（无需处理）" value="confirmed" />
            <el-option label="已处理（问题解决）" value="resolved" />
            <el-option label="已忽略" value="ignored" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理说明" prop="remark">
          <el-input v-model="handleForm.remark" type="textarea" :rows="3" placeholder="请输入处理说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showHandleDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="handling" @click="handleAlert">确认处理</el-button>
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
  { icon: '🆕', label: '今日新增', value: '0', bg: '#fef2f2' },
  { icon: '⏳', label: '待处理', value: '0', bg: '#fffbeb' },
  { icon: '⏰', label: '超时未处理', value: '0', bg: '#fef2f2' },
  { icon: '📊', label: '本周总数', value: '0', bg: '#eff6ff' },
  { icon: '⏱️', label: '平均处理时长', value: '0h', bg: '#f0fdf4' },
])

async function fetchDashboard() {
  try {
    const res = await api.get('/alert/dashboard')
    const d = res.data
    stats.value = [
      { icon: '🆕', label: '今日新增', value: d.today_new ?? '0', bg: '#fef2f2', trend: d.today_new > 0 ? '↑ 新增' : '' },
      { icon: '⏳', label: '待处理', value: d.pending ?? '0', bg: '#fffbeb', trend: d.pending > 0 ? '待处理' : '' },
      { icon: '⏰', label: '超时未处理', value: d.timeout ?? '0', bg: '#fef2f2', trend: d.timeout > 0 ? '⚠️ 超时' : '' },
      { icon: '📊', label: '本周总数', value: d.weekly_total ?? '0', bg: '#eff6ff' },
      { icon: '⏱️', label: '平均处理时长', value: (d.avg_handle_hours != null ? d.avg_handle_hours + 'h' : '0h'), bg: '#f0fdf4' },
    ]
  } catch (e) { /* fallback */ }
}

// 选项卡
const activeTab = ref('record')
function handleTabChange() {
  if (activeTab.value === 'record') fetchRecords()
  else fetchRules()
}

// 预警记录表格
const loading = ref(false)
const recordData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function fetchRecords() {
  loading.value = true
  try {
    const params = { page: page.value, page_size: pageSize.value }
    const res = await api.get('/alert/record', { params })
    const d = res.data
    recordData.value = d.list || d.items || []
    total.value = d.total ?? recordData.value.length
  } catch (e) {
    ElMessage.error('获取预警记录失败')
  } finally {
    loading.value = false
  }
}

function severityType(s) {
  const map = { critical: 'danger', high: 'warning', medium: 'primary', low: 'success' }
  return map[s] || 'info'
}

function severityLabel(s) {
  const map = { critical: '严重', high: '高', medium: '中', low: '低' }
  return map[s] || s || '-'
}

// 预警规则表格
const loadingRule = ref(false)
const ruleData = ref([])

async function fetchRules() {
  loadingRule.value = true
  try {
    const res = await api.get('/alert/rule')
    const d = res.data
    ruleData.value = d.list || d.items || d || []
  } catch (e) {
    ElMessage.error('获取预警规则失败')
  } finally {
    loadingRule.value = false
  }
}

async function toggleRule(row, val) {
  try {
    await api.put(`/alert/rule/${row.id}`, { enabled: val })
    ElMessage.success(val ? '规则已启用' : '规则已禁用')
  } catch (e) {
    ElMessage.error('操作失败')
    row.enabled = val === 1 ? 0 : 1
  }
}

// 处理预警弹窗
const showHandleDialog = ref(false)
const handling = ref(false)
const handleFormRef = ref(null)
const handleRow = ref({})
const handleForm = reactive({
  action: '',
  remark: '',
})
const handleRules = {
  action: [{ required: true, message: '请选择处理方式', trigger: 'change' }],
  remark: [{ required: true, message: '请输入处理说明', trigger: 'blur' }],
}

function openHandle(row) {
  handleRow.value = { ...row }
  handleForm.action = ''
  handleForm.remark = ''
  showHandleDialog.value = true
}

async function handleAlert() {
  if (!handleFormRef.value) return
  const valid = await handleFormRef.value.validate().catch(() => false)
  if (!valid) return
  handling.value = true
  try {
    await api.put(`/alert/record/${handleRow.value.id}/handle`, { ...handleForm })
    ElMessage.success('预警已处理')
    showHandleDialog.value = false
    fetchRecords()
    fetchDashboard()
  } catch (e) {
    ElMessage.error('处理失败，请重试')
  } finally {
    handling.value = false
  }
}

function handleViewAlert(row) {
  ElMessage.info(`预警编号：${row.alert_no} — ${row.title}`)
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
.mb-4 { margin-bottom: 16px; }
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>

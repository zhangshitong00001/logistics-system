<template>
  <div class="files">
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

    <!-- 文件类型卡片网格 -->
    <el-card shadow="never" class="mt-4">
      <template #header>
        <div class="card-header">
          <span style="font-weight:600;font-size:14px;">📁 文件类型</span>
          <el-button size="small" type="primary" @click="showGenerateDialog = true">+ 生成文件</el-button>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col :span="6" v-for="ft in fileTypes" :key="ft.key">
          <el-card shadow="hover" class="file-type-card" @click="showGenerateDialog = true">
            <div class="file-type-icon">{{ ft.icon }}</div>
            <div class="file-type-name">{{ ft.name }}</div>
            <div class="file-type-desc">{{ ft.desc }}</div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>

    <!-- 文件列表表格 -->
    <el-card shadow="never" class="mt-4">
      <template #header>
        <div class="card-header">
          <span style="font-weight:600;font-size:14px;">📄 文件列表</span>
          <el-button size="small" plain @click="fetchData">刷新</el-button>
        </div>
      </template>
      <el-table :data="tableData" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="file_name" label="文件名称" min-width="200" />
        <el-table-column label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="fileTypeTag(row.file_type)" size="small" effect="plain">
              {{ fileTypeLabel(row.file_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="batch" label="批次" min-width="120" />
        <el-table-column prop="version" label="版本" width="80" align="center" />
        <el-table-column prop="generated_time" label="生成时间" width="170" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handlePreview(row)">预览</el-button>
            <el-button text type="success" size="small" @click="handleExport(row)">导出</el-button>
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

    <!-- 生成文件弹窗 -->
    <el-dialog v-model="showGenerateDialog" title="📄 生成文件" width="520px" :close-on-click-modal="false">
      <el-form ref="generateFormRef" :model="generateForm" :rules="generateRules" label-width="100px">
        <el-form-item label="选择批次" prop="batch">
          <el-select v-model="generateForm.batch" placeholder="请选择批次" style="width:100%" filterable>
            <el-option v-for="b in batchOptions" :key="b" :label="b" :value="b" />
          </el-select>
        </el-form-item>
        <el-form-item label="文件类型" prop="file_types">
          <el-checkbox-group v-model="generateForm.file_types">
            <el-checkbox v-for="ft in fileTypes" :key="ft.key" :label="ft.key" :value="ft.key">
              {{ ft.icon }} {{ ft.name }}
            </el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="generateForm.remark" type="textarea" :rows="3" placeholder="备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showGenerateDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="generating" @click="handleGenerate">确认生成</el-button>
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
  { icon: '📄', label: '文件总数', value: '0', bg: '#eff6ff' },
  { icon: '📋', label: '装车清单', value: '0', bg: '#fffbeb' },
  { icon: '📦', label: '报关文件', value: '0', bg: '#f0fdf4' },
  { icon: '🔄', label: '今日生成', value: '0', bg: '#f5f3ff' },
])

// 文件类型
const fileTypes = [
  { key: 'loading_list', name: '装车清单', icon: '📋', desc: '批次装载货物明细清单' },
  { key: 'commercial_invoice', name: '商业发票', icon: '🧾', desc: '跨境贸易商业发票' },
  { key: 'packing_list', name: '装箱单', icon: '📦', desc: '货物装箱明细单' },
  { key: 'origin_cert', name: '原产地证明', icon: '🌍', desc: '货物原产地证书' },
]

function fileTypeTag(key) {
  const map = { loading_list: 'warning', commercial_invoice: 'primary', packing_list: 'success', origin_cert: 'danger' }
  return map[key] || 'info'
}
function fileTypeLabel(key) {
  const map = { loading_list: '装车清单', commercial_invoice: '商业发票', packing_list: '装箱单', origin_cert: '原产地证明' }
  return map[key] || key
}

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
    const res = await api.get('/files', { params })
    const d = res.data
    tableData.value = d.list || d.items || []
    total.value = d.total ?? tableData.value.length
  } catch (e) {
    ElMessage.error('获取文件列表失败')
  } finally {
    loading.value = false
  }
}

// 生成文件弹窗
const showGenerateDialog = ref(false)
const generating = ref(false)
const generateFormRef = ref(null)
const batchOptions = ref([])
const generateForm = reactive({
  batch: '',
  file_types: [],
  remark: '',
})
const generateRules = {
  batch: [{ required: true, message: '请选择批次', trigger: 'change' }],
  file_types: [{ required: true, message: '请至少选择一种文件类型', trigger: 'change' }],
}

async function fetchBatchOptions() {
  try {
    const res = await api.get('/files/batches')
    batchOptions.value = res.data || []
  } catch (e) {
    batchOptions.value = []
  }
}

async function handleGenerate() {
  if (!generateFormRef.value) return
  const valid = await generateFormRef.value.validate().catch(() => false)
  if (!valid) return
  generating.value = true
  try {
    // 根据选择的文件类型分别调用不同API
    const promises = []
    if (generateForm.file_types.includes('loading_list')) {
      promises.push(api.post('/files/loading-list', {
        batch: generateForm.batch,
        remark: generateForm.remark,
      }))
    }
    if (generateForm.file_types.some(t => ['commercial_invoice', 'packing_list', 'origin_cert'].includes(t))) {
      promises.push(api.post('/files/customs-docs', {
        batch: generateForm.batch,
        doc_types: generateForm.file_types.filter(t => ['commercial_invoice', 'packing_list', 'origin_cert'].includes(t)),
        remark: generateForm.remark,
      }))
    }
    await Promise.all(promises)
    ElMessage.success('文件生成成功')
    showGenerateDialog.value = false
    generateFormRef.value.resetFields()
    generateForm.file_types = []
    fetchData()
  } catch (e) {
    ElMessage.error('文件生成失败，请重试')
  } finally {
    generating.value = false
  }
}

// 操作
function handlePreview(row) {
  if (row.file_url) {
    window.open(row.file_url, '_blank')
  } else {
    ElMessage.info(`预览文件：${row.file_name}`)
  }
}

function handleExport(row) {
  if (row.file_url) {
    const link = document.createElement('a')
    link.href = row.file_url
    link.download = row.file_name
    link.click()
  } else {
    ElMessage.info(`导出文件：${row.file_name}`)
  }
}

// 初始化
onMounted(() => {
  fetchData()
  fetchBatchOptions()
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
.mt-4 { margin-top: 16px; }
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.file-type-card {
  cursor: pointer;
  text-align: center;
  padding: 16px 8px;
  transition: transform 0.2s;
}
.file-type-card:hover {
  transform: translateY(-2px);
}
.file-type-icon {
  font-size: 36px;
  margin-bottom: 8px;
}
.file-type-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}
.file-type-desc {
  font-size: 11px;
  color: #9ca3af;
}
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>

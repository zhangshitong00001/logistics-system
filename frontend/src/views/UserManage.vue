<template>
  <div>
    <el-card shadow="never">
      <div class="toolbar">
        <span style="font-size:13px;color:#666;">共 {{ total }} 个注册用户</span>
        <el-button type="primary" size="small" @click="showCreate = true">+ 创建用户</el-button>
      </div>

      <el-table :data="users" stripe v-loading="loading" style="width:100%" class="mt-3">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="real_name" label="姓名" width="110" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column label="角色" width="120">
          <template #default="{ row }">
            <el-tag size="small" effect="plain">{{ roleName(row.role_id) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="create_time" label="注册时间" width="170" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="openEdit(row)">编辑</el-button>
            <el-button
              text
              :type="row.status === 1 ? 'danger' : 'success'"
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
          @size-change="fetch"
          @current-change="fetch"
        />
      </div>
    </el-card>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="showEdit" title="编辑用户" width="480px" :close-on-click-modal="false">
      <el-form ref="editFormRef" :model="editForm" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="editForm.username" disabled />
        </el-form-item>
        <el-form-item label="姓名" prop="real_name">
          <el-input v-model="editForm.real_name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="editForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="editForm.role_id" placeholder="选择角色" style="width:100%">
            <el-option v-for="r in roles" :key="r.id" :label="r.role_name" :value="r.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showEdit = false">取消</el-button>
        <el-button size="small" type="primary" :loading="saving" @click="handleEdit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 创建用户弹窗 -->
    <el-dialog v-model="showCreate" title="创建用户" width="480px" :close-on-click-modal="false">
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="createForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="姓名" prop="real_name">
          <el-input v-model="createForm.real_name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="createForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="createForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="createForm.password" type="password" show-password placeholder="请设置密码" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="createForm.role_id" placeholder="选择角色" style="width:100%">
            <el-option v-for="r in roles" :key="r.id" :label="r.role_name" :value="r.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showCreate = false">取消</el-button>
        <el-button size="small" type="primary" :loading="creating" @click="handleCreate">确认创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../utils/api'

const users = ref([])
const roles = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const loading = ref(false)

const roleMap = {}
function roleName(id) {
  return roleMap[id] || `角色#${id}`
}

async function fetchRoles() {
  try {
    const res = await api.get('/permission/role', { params: { page: 1, size: 100 } })
    const d = res.data || res
    const list = d.records || d.list || d.items || []
    roles.value = list
    list.forEach(r => { roleMap[r.id] = r.role_name })
  } catch { /* ignore */ }
}

async function fetch() {
  loading.value = true
  try {
    const res = await api.get('/permission/user', { params: { page: page.value, size: pageSize.value } })
    const d = res.data || res
    users.value = d.records || d.list || d.items || []
    total.value = d.total || users.value.length
  } catch { ElMessage.error('获取用户列表失败') }
  finally { loading.value = false }
}

// 编辑
const showEdit = ref(false)
const saving = ref(false)
const editFormRef = ref(null)
const editForm = reactive({ id: 0, username: '', real_name: '', phone: '', email: '', role_id: 0 })

function openEdit(row) {
  Object.assign(editForm, {
    id: row.id, username: row.username, real_name: row.real_name || '',
    phone: row.phone || '', email: row.email || '', role_id: row.role_id || 0,
  })
  showEdit.value = true
}

async function handleEdit() {
  saving.value = true
  try {
    await api.put(`/permission/user/${editForm.id}`, {
      real_name: editForm.real_name, phone: editForm.phone,
      email: editForm.email, role_id: editForm.role_id,
    })
    ElMessage.success('保存成功')
    showEdit.value = false
    fetch()
  } catch { ElMessage.error('保存失败') }
  finally { saving.value = false }
}

// 禁用/启用
async function toggleStatus(row) {
  const newStatus = row.status === 1 ? 0 : 1
  const label = newStatus === 1 ? '启用' : '禁用'
  try {
    await ElMessageBox.confirm(`确认${label}用户「${row.username}」？`, '提示', { type: 'warning' })
    await api.put(`/permission/user/${row.id}`, { status: newStatus })
    ElMessage.success(`已${label}`)
    fetch()
  } catch (e) { if (e !== 'cancel') ElMessage.error('操作失败') }
}

// 创建
const showCreate = ref(false)
const creating = ref(false)
const createFormRef = ref(null)
const createForm = reactive({ username: '', real_name: '', phone: '', email: '', password: '', role_id: 0 })
const createRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  real_name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [{ required: true, message: '请设置密码', trigger: 'blur' }],
}

async function handleCreate() {
  const valid = await createFormRef.value?.validate().catch(() => false)
  if (!valid) return
  creating.value = true
  try {
    await api.post('/permission/user', { ...createForm })
    ElMessage.success('创建成功')
    showCreate.value = false
    createFormRef.value?.resetFields()
    createForm.role_id = 0
    fetch()
  } catch { ElMessage.error('创建失败') }
  finally { creating.value = false }
}

onMounted(() => { fetchRoles(); fetch() })
</script>

<style scoped>
.mt-3 { margin-top: 12px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
</style>

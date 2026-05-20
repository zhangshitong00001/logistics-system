<template>
  <div class="permission">
    <!-- 选项卡 -->
    <el-card shadow="never">
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <!-- 角色管理 -->
        <el-tab-pane label="👥 角色管理" name="role">
          <div class="toolbar">
            <el-button type="success" @click="showCreateRole = true">+ 创建角色</el-button>
          </div>
          <el-table :data="roleData" stripe v-loading="loadingRole" style="width:100%" class="mt-3">
            <el-table-column prop="role_name" label="角色名称" min-width="150" />
            <el-table-column prop="role_code" label="编码" width="140" />
            <el-table-column prop="description" label="描述" min-width="200" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small" effect="plain">
                  {{ row.status === 1 ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" fixed="right">
              <template #default="{ row }">
                <el-button text type="primary" size="small" @click="openConfigPermission(row)">配置权限</el-button>
                <el-button text type="warning" size="small" @click="openEditRole(row)">编辑</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <!-- 用户管理 -->
        <el-tab-pane label="👤 用户管理" name="user">
          <div class="toolbar">
            <el-button type="success" @click="showCreateUser = true">+ 创建用户</el-button>
          </div>
          <el-table :data="userData" stripe v-loading="loadingUser" style="width:100%" class="mt-3">
            <el-table-column prop="username" label="用户名" min-width="130" />
            <el-table-column prop="real_name" label="姓名" width="110" />
            <el-table-column prop="phone" label="手机" width="130" />
            <el-table-column prop="email" label="邮箱" min-width="180" />
            <el-table-column prop="role_name" label="角色" width="120">
              <template #default="{ row }">
                <el-tag size="small" effect="plain">{{ row.role_name || '-' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small" effect="plain">
                  {{ row.status === 1 ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" fixed="right">
              <template #default="{ row }">
                <el-button text type="primary" size="small" @click="openEditUser(row)">编辑</el-button>
                <el-button
                  text
                  :type="row.status === 1 ? 'danger' : 'success'"
                  size="small"
                  @click="toggleUserStatus(row)"
                >
                  {{ row.status === 1 ? '禁用' : '启用' }}
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="userPage"
              v-model:page-size="userPageSize"
              :page-sizes="[10, 20, 50]"
              :total="userTotal"
              layout="total, sizes, prev, pager, next"
              @size-change="fetchUsers"
              @current-change="fetchUsers"
            />
          </div>
        </el-tab-pane>

        <!-- 操作日志 -->
        <el-tab-pane label="📋 操作日志" name="log">
          <el-table :data="logData" stripe v-loading="loadingLog" style="width:100%">
            <el-table-column prop="user_name" label="操作人" width="120" />
            <el-table-column prop="action" label="操作" min-width="140" />
            <el-table-column prop="target" label="操作对象" min-width="160" />
            <el-table-column prop="detail" label="详情" min-width="240" />
            <el-table-column prop="ip" label="IP" width="140" />
            <el-table-column prop="created_at" label="操作时间" width="170" />
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="logPage"
              v-model:page-size="logPageSize"
              :page-sizes="[10, 20, 50]"
              :total="logTotal"
              layout="total, sizes, prev, pager, next"
              @size-change="fetchLogs"
              @current-change="fetchLogs"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 创建角色弹窗 -->
    <el-dialog v-model="showCreateRole" title="+ 创建角色" width="480px" :close-on-click-modal="false">
      <el-form ref="roleFormRef" :model="roleForm" :rules="roleRules" label-width="100px">
        <el-form-item label="角色名称" prop="role_name">
          <el-input v-model="roleForm.role_name" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色编码" prop="role_code">
          <el-input v-model="roleForm.role_code" placeholder="请输入角色编码，如 admin" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="roleForm.description" type="textarea" :rows="3" placeholder="角色描述（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showCreateRole = false">取消</el-button>
        <el-button size="small" type="primary" :loading="creatingRole" @click="handleCreateRole">确认创建</el-button>
      </template>
    </el-dialog>

    <!-- 配置权限弹窗 -->
    <el-dialog v-model="showPermDialog" title="🔑 配置权限" width="560px" :close-on-click-modal="false">
      <p class="mb-2">角色：<strong>{{ permRole.role_name }}</strong>（{{ permRole.role_code }}）</p>
      <el-tree
        ref="permTreeRef"
        :data="permissionTree"
        show-checkbox
        node-key="id"
        default-expand-all
        :props="{ label: 'name', children: 'children' }"
        class="perm-tree"
      />
      <template #footer>
        <el-button size="small" @click="showPermDialog = false">取消</el-button>
        <el-button size="small" type="primary" :loading="savingPerm" @click="handleSavePermissions">保存权限</el-button>
      </template>
    </el-dialog>

    <!-- 创建用户弹窗 -->
    <el-dialog v-model="showCreateUser" title="+ 创建用户" width="520px" :close-on-click-modal="false">
      <el-form ref="userFormRef" :model="userForm" :rules="userRules" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="姓名" prop="real_name">
          <el-input v-model="userForm.real_name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="userForm.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="角色" prop="role_code">
          <el-select v-model="userForm.role_code" placeholder="选择角色" style="width:100%">
            <el-option v-for="r in roleData" :key="r.role_code" :label="r.role_name" :value="r.role_code" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showCreateUser = false">取消</el-button>
        <el-button size="small" type="primary" :loading="creatingUser" @click="handleCreateUser">确认创建</el-button>
      </template>
    </el-dialog>

    <!-- 编辑用户弹窗 -->
    <el-dialog v-model="showEditUser" title="✏️ 编辑用户" width="520px" :close-on-click-modal="false">
      <el-form ref="editUserFormRef" :model="editUserForm" :rules="editUserRules" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="editUserForm.username" disabled />
        </el-form-item>
        <el-form-item label="姓名" prop="real_name">
          <el-input v-model="editUserForm.real_name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机" prop="phone">
          <el-input v-model="editUserForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="editUserForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色" prop="role_code">
          <el-select v-model="editUserForm.role_code" placeholder="选择角色" style="width:100%">
            <el-option v-for="r in roleData" :key="r.role_code" :label="r.role_name" :value="r.role_code" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="showEditUser = false">取消</el-button>
        <el-button size="small" type="primary" :loading="editingUser" @click="handleEditUser">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../utils/api'

// 选项卡
const activeTab = ref('role')
function handleTabChange() {
  if (activeTab.value === 'role') fetchRoles()
  else if (activeTab.value === 'user') fetchUsers()
  else fetchLogs()
}

// ========== 角色管理 ==========
const loadingRole = ref(false)
const roleData = ref([])

async function fetchRoles() {
  loadingRole.value = true
  try {
    const res = await api.get('/permission/role')
    const d = res.data
    roleData.value = d.list || d.items || d || []
  } catch (e) {
    ElMessage.error('获取角色列表失败')
  } finally {
    loadingRole.value = false
  }
}

// 创建角色
const showCreateRole = ref(false)
const creatingRole = ref(false)
const roleFormRef = ref(null)
const roleForm = reactive({
  role_name: '',
  role_code: '',
  description: '',
})
const roleRules = {
  role_name: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  role_code: [{ required: true, message: '请输入角色编码', trigger: 'blur' }],
}

async function handleCreateRole() {
  if (!roleFormRef.value) return
  const valid = await roleFormRef.value.validate().catch(() => false)
  if (!valid) return
  creatingRole.value = true
  try {
    await api.post('/permission/role', { ...roleForm })
    ElMessage.success('角色创建成功')
    showCreateRole.value = false
    roleFormRef.value.resetFields()
    fetchRoles()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    creatingRole.value = false
  }
}

// 配置权限
const showPermDialog = ref(false)
const savingPerm = ref(false)
const permRole = ref({})
const permTreeRef = ref(null)
const permissionTree = ref([
  { id: 1, name: '仪表盘', children: [
    { id: 11, name: '查看仪表盘' },
  ]},
  { id: 2, name: '运输管理', children: [
    { id: 21, name: '查看运输单' },
    { id: 22, name: '创建运输单' },
    { id: 23, name: '编辑运输单' },
    { id: 24, name: '删除运输单' },
  ]},
  { id: 3, name: '报关管理', children: [
    { id: 31, name: '查看报关单' },
    { id: 32, name: '提交报关' },
    { id: 33, name: '审核报关' },
  ]},
  { id: 4, name: '仓储管理', children: [
    { id: 41, name: '查看仓库' },
    { id: 42, name: '入库操作' },
    { id: 43, name: '出库操作' },
  ]},
  { id: 5, name: '结算管理', children: [
    { id: 51, name: '查看结算单' },
    { id: 52, name: '创建结算单' },
    { id: 53, name: '审核结算单' },
  ]},
  { id: 6, name: '系统设置', children: [
    { id: 61, name: '角色管理' },
    { id: 62, name: '用户管理' },
    { id: 63, name: '操作日志查看' },
  ]},
])

function openConfigPermission(row) {
  permRole.value = { ...row }
  showPermDialog.value = true
  // 模拟已选权限（实际应从 API 获取）
  if (permTreeRef.value) {
    permTreeRef.value.setCheckedKeys([])
  }
}

async function handleSavePermissions() {
  if (!permTreeRef.value) return
  const checkedKeys = permTreeRef.value.getCheckedKeys()
  savingPerm.value = true
  try {
    await api.put(`/permission/role/${permRole.value.id}/permissions`, { permission_ids: checkedKeys })
    ElMessage.success('权限配置已保存')
    showPermDialog.value = false
  } catch (e) {
    ElMessage.error('保存失败，请重试')
  } finally {
    savingPerm.value = false
  }
}

function openEditRole(row) {
  ElMessage.info(`编辑角色：${row.role_name}`)
}

// ========== 用户管理 ==========
const loadingUser = ref(false)
const userData = ref([])
const userPage = ref(1)
const userPageSize = ref(10)
const userTotal = ref(0)

async function fetchUsers() {
  loadingUser.value = true
  try {
    const params = { page: userPage.value, page_size: userPageSize.value }
    const res = await api.get('/permission/user', { params })
    const d = res.data
    userData.value = d.list || d.items || []
    userTotal.value = d.total ?? userData.value.length
  } catch (e) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loadingUser.value = false
  }
}

// 创建用户
const showCreateUser = ref(false)
const creatingUser = ref(false)
const userFormRef = ref(null)
const userForm = reactive({
  username: '',
  real_name: '',
  phone: '',
  email: '',
  password: '',
  role_code: '',
})
const userRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  real_name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  role_code: [{ required: true, message: '请选择角色', trigger: 'change' }],
}

async function handleCreateUser() {
  if (!userFormRef.value) return
  const valid = await userFormRef.value.validate().catch(() => false)
  if (!valid) return
  creatingUser.value = true
  try {
    await api.post('/permission/user', { ...userForm })
    ElMessage.success('用户创建成功')
    showCreateUser.value = false
    userFormRef.value.resetFields()
    userForm.role_code = ''
    fetchUsers()
  } catch (e) {
    ElMessage.error('创建失败，请重试')
  } finally {
    creatingUser.value = false
  }
}

// 编辑用户
const showEditUser = ref(false)
const editingUser = ref(false)
const editUserFormRef = ref(null)
const editUserForm = reactive({
  id: '',
  username: '',
  real_name: '',
  phone: '',
  email: '',
  role_code: '',
})
const editUserRules = {
  real_name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  role_code: [{ required: true, message: '请选择角色', trigger: 'change' }],
}

function openEditUser(row) {
  editUserForm.id = row.id
  editUserForm.username = row.username
  editUserForm.real_name = row.real_name
  editUserForm.phone = row.phone || ''
  editUserForm.email = row.email || ''
  editUserForm.role_code = row.role_code || ''
  showEditUser.value = true
}

async function handleEditUser() {
  if (!editUserFormRef.value) return
  const valid = await editUserFormRef.value.validate().catch(() => false)
  if (!valid) return
  editingUser.value = true
  try {
    const payload = { ...editUserForm }
    delete payload.id
    delete payload.username
    await api.put(`/permission/user/${editUserForm.id}`, payload)
    ElMessage.success('用户信息已更新')
    showEditUser.value = false
    fetchUsers()
  } catch (e) {
    ElMessage.error('更新失败，请重试')
  } finally {
    editingUser.value = false
  }
}

async function toggleUserStatus(row) {
  const newStatus = row.status === 1 ? 0 : 1
  const action = newStatus === 1 ? '启用' : '禁用'
  try {
    await ElMessageBox.confirm(`确认${action}用户 ${row.username}？`, '提示', {
      type: 'warning',
      confirmButtonText: '确认',
      cancelButtonText: '取消',
    })
    await api.put(`/permission/user/${row.id}`, { status: newStatus })
    ElMessage.success(`用户已${action}`)
    fetchUsers()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// ========== 操作日志 ==========
const loadingLog = ref(false)
const logData = ref([])
const logPage = ref(1)
const logPageSize = ref(10)
const logTotal = ref(0)

async function fetchLogs() {
  loadingLog.value = true
  try {
    const params = { page: logPage.value, page_size: logPageSize.value }
    const res = await api.get('/permission/log', { params })
    const d = res.data
    logData.value = d.list || d.items || []
    logTotal.value = d.total ?? logData.value.length
  } catch (e) {
    ElMessage.error('获取操作日志失败')
  } finally {
    loadingLog.value = false
  }
}

// 初始化
onMounted(() => {
  fetchRoles()
})
</script>

<style scoped>
.mt-3 { margin-top: 12px; }
.mb-2 { margin-bottom: 8px; }
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
.perm-tree {
  max-height: 360px;
  overflow-y: auto;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 12px;
}
</style>

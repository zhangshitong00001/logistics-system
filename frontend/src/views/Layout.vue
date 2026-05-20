<template>
  <div class="layout">
    <el-menu :default-active="activeMenu" class="sidebar" :collapse="collapsed" router @select="handleSelect">
      <div class="sidebar-header" @click="collapsed = !collapsed">
        <span class="logo-icon">{{ collapsed ? '📦' : '📦' }}</span>
        <span v-show="!collapsed" class="logo-text">物流系统</span>
      </div>

      <template v-for="group in menuGroups" :key="group.label">
        <div v-if="!collapsed" class="menu-group-label">{{ group.label }}</div>
        <el-menu-item v-for="item in group.children" :key="item.path" :index="item.path">
          <el-icon><span>{{ item.icon }}</span></el-icon>
          <template #title>{{ item.label }}</template>
        </el-menu-item>
      </template>
    </el-menu>

    <div class="main-area">
      <header class="topbar">
        <h2 class="page-title">{{ currentTitle }}</h2>
        <div class="topbar-right">
          <span class="user-name">{{ auth.username }}</span>
          <el-button text type="primary" @click="handleLogout">退出</el-button>
        </div>
      </header>
      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const collapsed = ref(false)

const menuMap = {
  dashboard: '系统首页',
  consolidation: '云仓集货管理',
  sorting: '收件点分装管理',
  files: '文件生成管理',
  transport: '装车运输管理',
  customs: '报关/清关管理',
  warehouse: '仓库分拣管理',
  delivery: '配送管理',
  signin: '签收入库管理',
  tracking: '物流状态追踪',
  reconciliation: '对账管理',
  settlement: '资金结算',
  payment: '支付开票',
  alert: '异常预警中心',
  analytics: '统计分析',
  permission: '权限管理',
  billing: '计费规则配置',
}

const currentTitle = computed(() => menuMap[route.path.split('/')[1]] || '系统首页')

const menuGroups = [
  {
    label: '核心视图',
    children: [
      { path: '/dashboard', label: '系统首页', icon: '📊' },
    ]
  },
  {
    label: '业务流程',
    children: [
      { path: '/consolidation', label: '云仓集货管理', icon: '📦' },
      { path: '/sorting', label: '收件点分装管理', icon: '📋' },
      { path: '/files', label: '文件生成管理', icon: '📄' },
      { path: '/transport', label: '装车运输管理', icon: '🚛' },
      { path: '/customs', label: '报关/清关管理', icon: '🏛️' },
      { path: '/warehouse', label: '仓库分拣管理', icon: '📦' },
      { path: '/delivery', label: '配送管理', icon: '🚚' },
      { path: '/signin', label: '签收入库管理', icon: '✍️' },
    ]
  },
  {
    label: '财务管理',
    children: [
      { path: '/reconciliation', label: '对账管理', icon: '💰' },
      { path: '/settlement', label: '资金结算', icon: '💵' },
      { path: '/payment', label: '支付开票', icon: '📜' },
    ]
  },
  {
    label: '核心功能',
    children: [
      { path: '/tracking', label: '物流状态追踪', icon: '🔍' },
      { path: '/permission', label: '权限管理', icon: '🔐' },
      { path: '/analytics', label: '统计分析', icon: '📈' },
      { path: '/alert', label: '异常预警中心', icon: '⚠️' },
      { path: '/billing', label: '计费规则配置', icon: '⚙️' },
    ]
  },
]

const activeMenu = computed(() => '/' + route.path.split('/')[1])

function handleSelect(index) {
  router.push(index)
}

function handleLogout() {
  auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.layout { display: flex; height: 100vh; overflow: hidden; }
.sidebar { width: 220px; height: 100%; overflow-y: auto; border-right: 1px solid #e5e7eb; }
.sidebar:not(.el-menu--collapse) { width: 220px; }
.sidebar-header { display: flex; align-items: center; gap: 10px; padding: 16px 20px; border-bottom: 1px solid #e5e7eb; cursor: pointer; }
.logo-icon { font-size: 24px; }
.logo-text { font-weight: 700; font-size: 14px; color: #1f2937; }
.menu-group-label { padding: 12px 20px 4px; font-size: 10px; color: #9ca3af; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
.main-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.topbar { height: 56px; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; border-bottom: 1px solid #e5e7eb; background: #fff; }
.page-title { font-size: 15px; font-weight: 600; color: #1f2937; }
.topbar-right { display: flex; align-items: center; gap: 12px; }
.user-name { font-size: 13px; color: #6b7280; }
.content { flex: 1; overflow-y: auto; padding: 20px; background: #f9fafb; }
</style>

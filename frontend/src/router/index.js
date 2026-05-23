import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import AdminLogin from '../views/AdminLogin.vue'
import Layout from '../views/Layout.vue'
import Dashboard from '../views/Dashboard.vue'
import Consolidation from '../views/Consolidation.vue'
import Sorting from '../views/Sorting.vue'
import Files from '../views/Files.vue'
import Transport from '../views/Transport.vue'
import Customs from '../views/Customs.vue'
import Warehouse from '../views/Warehouse.vue'
import Delivery from '../views/Delivery.vue'
import SignIn from '../views/SignIn.vue'
import Tracking from '../views/Tracking.vue'
import Reconciliation from '../views/Reconciliation.vue'
import Settlement from '../views/Settlement.vue'
import Payment from '../views/Payment.vue'
import Alert from '../views/Alert.vue'
import Analytics from '../views/Analytics.vue'
import Permission from '../views/Permission.vue'
import Billing from '../views/Billing.vue'
import UserManage from '../views/UserManage.vue'

const routes = [
  { path: '/login', component: Login },
  { path: '/admin/login', component: AdminLogin },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', component: Dashboard },
      { path: 'consolidation', component: Consolidation },
      { path: 'sorting', component: Sorting },
      { path: 'files', component: Files },
      { path: 'transport', component: Transport },
      { path: 'customs', component: Customs },
      { path: 'warehouse', component: Warehouse },
      { path: 'delivery', component: Delivery },
      { path: 'signin', component: SignIn },
      { path: 'tracking', component: Tracking },
      { path: 'reconciliation', component: Reconciliation },
      { path: 'settlement', component: Settlement },
      { path: 'payment', component: Payment },
      { path: 'alert', component: Alert },
      { path: 'analytics', component: Analytics },
      { path: 'permission', component: Permission },
      { path: 'billing', component: Billing },
      { path: 'users', component: UserManage },
    ]
  }
]

const router = createRouter({
  history: createWebHistory('/logistics/'),
  routes,
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  // 登录页和 admin 登录页不需要登录即可访问
  if (to.path === '/login' || to.path === '/admin/login') {
    next()
  } else if (!token) {
    // 未登录访问受保护页面，跳转普通用户登录
    next('/login')
  } else {
    next()
  }
})

export default router

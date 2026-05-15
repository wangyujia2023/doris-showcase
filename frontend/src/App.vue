<template>
  <el-container class="app-wrap">
    <el-aside width="188px" class="aside">
      <div class="logo">
        <el-icon size="18" color="#409eff"><DataBoard /></el-icon>
        <span>{{ t('app.title') }}</span>
      </div>

      <el-menu
        :default-active="activeMenu"
        router
        background-color="#001529"
        text-color="#ffffffa0"
        active-text-color="#409eff"
      >
        <template v-for="group in menuGroups" :key="group.key || group.titleKey">
          <div v-if="group.titleKey" class="menu-group-title">{{ t(group.titleKey) }}</div>
          <el-menu-item v-for="item in group.items" :key="item.path" :index="item.path">
            <el-icon><component :is="iconMap[item.icon]" /></el-icon>
            <span>{{ t(item.titleKey) }}</span>
          </el-menu-item>
        </template>
      </el-menu>

      <div class="doris-status">
        <span class="dot" :class="dorisOk ? 'ok' : 'err'"></span>
        <span>{{ dorisOk ? t('app.dorisConnected') : t('app.dorisDisconnected') }}</span>
      </div>
    </el-aside>

    <el-container>
      <el-header class="header">
        <span class="page-title">{{ currentTitle }}</span>
        <div class="header-right">
          <el-tag type="warning" size="small" effect="plain" style="margin-left:8px">{{ t('app.ai') }}</el-tag>
          <el-dropdown trigger="click" @command="setLocale">
            <el-button size="small" plain>
              {{ localeName }}
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item v-for="item in locales" :key="item.value" :command="item.value">
                  {{ item.label() }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <span class="username">{{ t('app.analyst') }}</span>
        </div>
      </el-header>
      <el-main class="main-content">
        <router-view :key="route.fullPath" />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import {
  ArrowDown,
  Coin,
  Cpu,
  DataAnalysis,
  DataBoard,
  Document,
  Grid,
  Histogram,
  Monitor,
  Odometer,
  PriceTag,
  Promotion,
  Setting,
  SetUp,
  Share,
  Tickets,
  Tools,
  TrendCharts,
  User,
  WalletFilled,
} from '@element-plus/icons-vue'
import { systemApi } from '@/api'
import { menuGroups } from '@/config/menu'
import { locale, locales, setLocale, t } from '@/i18n'

const route = useRoute()
const dorisOk = ref(false)
const activeMenu = computed(() => route.path)
const currentTitle = computed(() => (route.meta?.titleKey ? t(route.meta.titleKey) : t('app.title')))
const localeName = computed(() => locales.find((item) => item.value === locale.value)?.label() || locale.value)

const iconMap = {
  ArrowDown,
  Coin,
  Cpu,
  DataAnalysis,
  Document,
  Grid,
  Histogram,
  Monitor,
  Odometer,
  PriceTag,
  Promotion,
  Setting,
  SetUp,
  Share,
  Tickets,
  Tools,
  TrendCharts,
  User,
  WalletFilled,
}

onMounted(async () => {
  try {
    const res = await systemApi.health()
    dorisOk.value = res.status === 'ok'
  } catch {
    dorisOk.value = false
  }
})
</script>

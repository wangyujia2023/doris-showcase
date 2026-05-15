<template>
  <div>
    <el-row :gutter="16">
      <el-col :span="24">
        <div class="card">
          <div class="card-title">{{ t('sysconfig.connTitle') }}</div>
          <el-descriptions :column="1" border size="small">
            <el-descriptions-item :label="t('sysconfig.labelHost')">{{ cfg.doris_host }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelPort')">{{ cfg.doris_port }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelDb')">{{ cfg.doris_database }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelBackendPort')">{{ cfg.backend_port }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelFrontendPort')">{{ cfg.frontend_port }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelHasp')">
              <el-tag :type="cfg.hasp_enabled ? 'success' : 'danger'">
                {{ cfg.hasp_enabled ? t('sysconfig.haspEnabled') : t('sysconfig.haspDisabled') }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelOpenMetadata')">
              <el-tag :type="cfg.openmetadata_configured ? 'success' : 'warning'">
                {{ cfg.openmetadata_configured ? t('sysconfig.configured') : t('sysconfig.notConfigured') }}
              </el-tag>
              <span style="margin-left:8px;color:#909399">{{ cfg.openmetadata_base_url }}</span>
            </el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelUploadDir')">{{ cfg.upload_dir }}</el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelConn')">
              <el-tag :type="dorisStatus === 'ok' ? 'success' : 'danger'">
                {{ dorisStatus === 'ok' ? t('sysconfig.connOk') : t('sysconfig.connFail') }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item :label="t('sysconfig.labelVersion')">{{ dorisVersion }}</el-descriptions-item>
          </el-descriptions>
          <el-button type="primary" style="margin-top:12px" @click="testDoris" :loading="testing">
            {{ t('sysconfig.retestBtn') }}
          </el-button>
        </div>
      </el-col>
    </el-row>

    <!-- HASP 说明 -->
    <div class="card">
      <div class="card-title">{{ t('sysconfig.haspTitle') }}</div>
      <el-row :gutter="16">
        <el-col :span="8" v-for="item in haspFeatures" :key="item.title">
          <el-card shadow="never" style="height:100%">
            <div style="font-size:24px;margin-bottom:8px">{{ item.icon }}</div>
            <div style="font-weight:600;margin-bottom:6px">{{ item.title }}</div>
            <div style="font-size:13px;color:#606266;line-height:1.6">{{ item.desc }}</div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 启动说明 -->
    <div class="card">
      <div class="card-title">{{ t('sysconfig.startTitle') }}</div>
      <el-steps direction="vertical" :active="4" finish-status="success">
        <el-step v-for="step in startupSteps" :key="step.title"
                 :title="step.title" :description="step.desc" />
      </el-steps>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { systemApi } from '@/api'
import { t, locale } from '@/i18n'

const cfg = ref({})
const dorisStatus  = ref('checking')
const dorisVersion = ref('...')
const testing = ref(false)

const haspFeatures = computed(() => t('sysconfig.haspFeatures'))
const startupSteps = computed(() => t('sysconfig.startupSteps'))

async function testDoris() {
  testing.value = true
  try {
    const res = await systemApi.health()
    dorisStatus.value  = res.status
    dorisVersion.value = res.doris_version
  } catch { dorisStatus.value = 'error' }
  finally { testing.value = false }
}

onMounted(async () => {
  try { cfg.value = await systemApi.config() } catch {}
  testDoris()
})
</script>

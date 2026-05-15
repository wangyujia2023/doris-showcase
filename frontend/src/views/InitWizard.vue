<template>
  <div class="setup-page">
    <div class="card setup-hero">
      <div>
        <div class="setup-title">{{ t('initWizard.title') }}</div>
        <div class="setup-subtitle">{{ t('initWizard.subtitle') }}</div>
      </div>
      <div class="setup-actions">
        <el-button :disabled="activeStep === 0" @click="prevStep">{{ t('initWizard.prev') }}</el-button>
        <el-button v-if="activeStep < 2" type="primary" @click="nextStep">{{ t('initWizard.next') }}</el-button>
        <el-button v-else type="primary" :loading="importingMode === 'all'" @click="runInit('all')">{{ t('initWizard.importAll') }}</el-button>
      </div>
    </div>

    <div class="card">
      <el-steps :active="activeStep" finish-status="success" simple>
        <el-step :title="t('initWizard.stepBasic')" />
        <el-step :title="t('initWizard.stepConn')" />
        <el-step :title="t('initWizard.stepImport')" />
      </el-steps>
    </div>

    <div v-if="activeStep === 0" class="setup-grid">
      <div class="card setup-panel">
        <div class="card-title">{{ t('initWizard.systemTitle') }}</div>
        <el-form :model="form" label-width="140px" size="default">
          <el-form-item :label="t('initWizard.uploadDir')"><el-input v-model="form.upload_dir" /></el-form-item>
          <el-form-item :label="t('initWizard.logDir')"><el-input v-model="form.log_dir" /></el-form-item>
        </el-form>
      </div>

      <div class="card setup-panel">
        <div class="panel-hd">
          <div class="card-title">{{ t('initWizard.llmTitle') }}</div>
          <el-button type="primary" plain size="small" :loading="llmTesting" @click="testLlm">
            {{ t('initWizard.testLlm') }}
          </el-button>
        </div>
        <el-form :model="form" label-width="140px" size="default">
          <el-form-item :label="t('initWizard.llmProvider')">
            <el-select v-model="form.doris_ai_provider" clearable :placeholder="t('initWizard.optional')" style="width:100%" @change="applyProviderPreset">
              <el-option label="Gemini" value="gemini" />
              <el-option label="OpenAI" value="openai" />
              <el-option label="Qwen" value="qwen" />
              <el-option label="DeepSeek" value="deepseek" />
              <el-option :label="t('initWizard.customProvider')" value="custom" />
            </el-select>
          </el-form-item>
          <el-form-item :label="t('initWizard.llmModel')">
            <el-input v-model="form.doris_ai_model" placeholder="e.g. deepseek-chat" />
          </el-form-item>
          <el-form-item :label="t('initWizard.llmEndpoint')">
            <el-input v-model="form.doris_ai_endpoint" placeholder="https://api.deepseek.com" />
          </el-form-item>
          <el-form-item :label="t('initWizard.llmApiKey')">
            <el-input v-model="form.doris_ai_api_key" type="password" show-password />
          </el-form-item>
        </el-form>
        <div v-if="llmResult" :class="['llm-result', llmResultOk ? 'llm-ok' : 'llm-err']">
          <span class="llm-result-icon">{{ llmResultOk ? '✓' : '✗' }}</span>
          <span class="llm-result-text">{{ llmResult }}</span>
        </div>
      </div>
    </div>

    <div v-else-if="activeStep === 1" class="card setup-panel">
      <div class="panel-hd">
        <div class="card-title">{{ t('initWizard.dbTitle') }}</div>
        <div class="setup-actions">
          <el-button :loading="testing" @click="testConnection">
            {{ testing ? t('initWizard.testing') : t('initWizard.test') }}
          </el-button>
          <el-button type="primary" :loading="saving" @click="saveConfig">
            {{ saving ? t('initWizard.saving') : t('initWizard.save') }}
          </el-button>
        </div>
      </div>

      <el-form :model="form" label-width="140px" size="default">
        <div class="form-section-label">{{ t('initWizard.dbConnTitle') }}</div>
        <div class="form-2col">
          <el-form-item :label="t('initWizard.host')">
            <el-input v-model="form.doris_host" />
          </el-form-item>
          <el-form-item :label="t('initWizard.mainDb')">
            <el-input v-model="form.doris_database" />
          </el-form-item>
          <el-form-item :label="t('initWizard.mysqlPort')">
            <el-input-number v-model="form.doris_port" :min="1" :max="65535" controls-position="right" style="width:100%" />
          </el-form-item>
          <el-form-item :label="t('initWizard.httpPort')">
            <el-input-number v-model="form.doris_http_port" :min="1" :max="65535" controls-position="right" style="width:100%" />
          </el-form-item>
          <el-form-item :label="t('initWizard.user')">
            <el-input v-model="form.doris_user" />
          </el-form-item>
          <el-form-item :label="t('initWizard.password')">
            <el-input v-model="form.doris_password" type="password" show-password />
          </el-form-item>
        </div>

        <div class="conn-status-bar">
          <el-tag :type="connStatus === 'ok' ? 'success' : connStatus === 'error' ? 'danger' : 'info'" effect="plain">
            {{ connLabel }}
          </el-tag>
        </div>

        <div class="form-section-label form-section-divider">{{ t('initWizard.aiTitle') }}</div>
        <el-alert type="info" :closable="false" style="margin-bottom:14px">
          <template #title>
            {{ t('initWizard.aiResourceNote') }}
          </template>
        </el-alert>
        <el-form-item :label="t('initWizard.llmResource')">
          <el-input :model-value="form.doris_ai_resource" disabled>
            <template #append>
              <el-tooltip :content="t('initWizard.aiResourceLocked')" placement="top">
                <el-icon style="cursor:default"><Lock /></el-icon>
              </el-tooltip>
            </template>
          </el-input>
        </el-form-item>
      </el-form>
    </div>

    <div v-else class="setup-grid">
      <div class="card setup-panel">
        <div class="card-title">{{ t('initWizard.importTitle') }}</div>
        <el-descriptions :column="1" border size="small" style="margin-top:14px">
          <el-descriptions-item :label="t('initWizard.targetDb')">{{ form.doris_database }}</el-descriptions-item>
          <el-descriptions-item :label="t('initWizard.dropDatabases')">
            <el-switch v-model="form.drop_databases" />
          </el-descriptions-item>
          <el-descriptions-item :label="t('initWizard.initOnDeploy')">
            <el-switch v-model="form.init_database_on_deploy" />
          </el-descriptions-item>
        </el-descriptions>
        <div class="setup-footer">
          <el-button type="primary" :loading="importingMode === 'all'" @click="runInit('all')">{{ t('initWizard.importAll') }}</el-button>
          <el-button :loading="importingMode === 'validate'" @click="runInit('validate')">{{ t('initWizard.validate') }}</el-button>
        </div>
      </div>

      <div class="card setup-panel log-panel">
        <div class="panel-hd" style="margin-bottom:10px">
          <div class="card-title">{{ t('initWizard.output') }}</div>
          <div style="display:flex;align-items:center;gap:8px">
            <span v-if="importingMode" class="log-running">
              <span class="log-dot" />{{ t('initWizard.running') }}
            </span>
            <el-button v-if="output" size="small" plain @click="output=''">{{ t('initWizard.clearLog') }}</el-button>
          </div>
        </div>
        <pre ref="logEl" class="setup-log">{{ output || t('initWizard.notRun') }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Lock } from '@element-plus/icons-vue'
import { systemApi } from '@/api'
import { t } from '@/i18n'

const activeStep = ref(0)
const saving = ref(false)
const testing = ref(false)
const llmTesting = ref(false)
const importingMode = ref('')
const connStatus = ref('idle')
const output = ref('')
const llmResult = ref('')
const llmResultOk = ref(false)
const logEl = ref(null)

function scrollLog() {
  nextTick(() => { if (logEl.value) logEl.value.scrollTop = logEl.value.scrollHeight })
}

const form = reactive({
  backend_host: '0.0.0.0',
  backend_port: 27713,
  backend_proxy_host: '127.0.0.1',
  frontend_host: '0.0.0.0',
  frontend_port: 5173,
  doris_host: '127.0.0.1',
  doris_port: 9030,
  doris_http_port: 18030,
  doris_user: 'root',
  doris_password: '',
  doris_database: 'doris_showcase',
  doris_ai_resource: 'llm_resource',
  doris_ai_provider: '',
  doris_ai_model: '',
  doris_ai_endpoint: '',
  doris_ai_api_key: '',
  upload_dir: './uploads',
  log_dir: './logs',
  openmetadata_base_url: '',
  openmetadata_jwt_token: '',
  init_database_on_deploy: false,
  drop_databases: false,
})

const connLabel = computed(() => {
  if (connStatus.value === 'ok') return t('initWizard.testOk')
  if (connStatus.value === 'error') return t('initWizard.testFail')
  return t('initWizard.notRun')
})

function payload() {
  return {
    ...form,
    lineage_database: form.doris_database,
    openmetadata_base_url: '',
    openmetadata_jwt_token: '',
  }
}

async function loadConfig() {
  const cfg = await systemApi.config()
  Object.assign(form, {
    backend_host: cfg.backend_host || form.backend_host,
    backend_port: cfg.backend_port || form.backend_port,
    backend_proxy_host: cfg.backend_proxy_host || form.backend_proxy_host,
    frontend_host: cfg.frontend_host || form.frontend_host,
    frontend_port: cfg.frontend_port || form.frontend_port,
    doris_host: cfg.doris_host || form.doris_host,
    doris_port: cfg.doris_port || form.doris_port,
    doris_http_port: cfg.doris_http_port || form.doris_http_port,
    doris_user: cfg.doris_user || form.doris_user,
    doris_database: cfg.doris_database || form.doris_database,
    doris_ai_resource: cfg.ai_resource || form.doris_ai_resource,
    doris_ai_provider: cfg.ai_provider || '',
    doris_ai_model: cfg.ai_model || '',
    doris_ai_endpoint: cfg.ai_endpoint || '',
    upload_dir: cfg.upload_dir || form.upload_dir,
    log_dir: cfg.log_dir || form.log_dir,
    init_database_on_deploy: !!cfg.init_database_on_deploy,
    drop_databases: !!cfg.drop_databases,
  })
}

async function saveConfig() {
  saving.value = true
  try {
    await systemApi.saveInitConfig(payload())
    ElMessage.success(t('initWizard.saved'))
  } finally {
    saving.value = false
  }
}

async function testConnection() {
  testing.value = true
  try {
    const res = await systemApi.testInitConfig(payload())
    connStatus.value = res.status === 'ok' ? 'ok' : 'error'
    ElMessage[connStatus.value === 'ok' ? 'success' : 'error'](connLabel.value)
  } finally {
    testing.value = false
  }
}

async function testLlm() {
  llmTesting.value = true
  llmResult.value = ''
  try {
    const res = await systemApi.testInitLlm(payload())
    if (res.status === 'ok') {
      llmResultOk.value = true
      llmResult.value = res.answer || t('initWizard.testLlmOk')
    } else {
      llmResultOk.value = false
      llmResult.value = res.message || t('initWizard.testLlmFail')
    }
  } catch (e) {
    llmResultOk.value = false
    llmResult.value = e.message || t('initWizard.testLlmFail')
  } finally {
    llmTesting.value = false
  }
}

function applyProviderPreset(provider) {
  const presets = {
    deepseek: { model: 'deepseek-chat', endpoint: 'https://api.deepseek.com/chat/completions' },
    qwen: { model: 'qwen-plus', endpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions' },
  }
  const preset = presets[provider]
  if (!preset) return
  if (!form.doris_ai_model || form.doris_ai_model.startsWith('gemini-') || form.doris_ai_model.startsWith('deepseek-v')) {
    form.doris_ai_model = preset.model
  }
  if (!form.doris_ai_endpoint || form.doris_ai_endpoint === 'https://api.deepseek.com') {
    form.doris_ai_endpoint = preset.endpoint
  }
}

async function nextStep() {
  await saveConfig()
  activeStep.value = Math.min(activeStep.value + 1, 2)
}

function prevStep() {
  activeStep.value = Math.max(activeStep.value - 1, 0)
}

async function runInit(mode) {
  await saveConfig()
  importingMode.value = mode
  output.value = ''
  try {
    const resp = await fetch('/api/system/init/database/stream', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...payload(), mode }),
    })
    if (!resp.ok) {
      output.value = await resp.text()
      ElMessage.error(t('initWizard.importFail'))
      return
    }
    const reader = resp.body.getReader()
    const decoder = new TextDecoder()
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      output.value += decoder.decode(value, { stream: true })
      scrollLog()
    }
    const ok = output.value.includes('✅')
    ElMessage[ok ? 'success' : 'error'](ok
      ? (mode === 'validate' ? t('initWizard.validateOk') : t('initWizard.importOk'))
      : t('initWizard.importFail'))
  } catch (e) {
    output.value += `\n[Error] ${e.message}`
    ElMessage.error(t('initWizard.importFail'))
  } finally {
    importingMode.value = ''
    scrollLog()
  }
}

onMounted(() => {
  loadConfig().catch(() => {})
})
</script>

<style scoped>
/* ── 页面布局 ── */
.setup-page { display:flex; flex-direction:column; gap:16px; max-width:960px; margin:0 auto; padding:4px 0 32px }

.setup-hero {
  display:flex; align-items:center; justify-content:space-between; padding:20px 24px;
}
.setup-title { font-size:20px; font-weight:700; color:#1d2129; line-height:1.3 }
.setup-subtitle { font-size:13px; color:#86909c; margin-top:4px }
.setup-actions { display:flex; gap:10px; align-items:center }

/* ── 卡片 ── */
.card {
  background:#fff; border-radius:10px;
  box-shadow:0 1px 3px rgba(0,0,0,.08), 0 0 0 1px rgba(0,0,0,.04);
}
.card-title { font-size:14px; font-weight:600; color:#1d2129 }

/* ── 两栏 grid ── */
.setup-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; align-items:start }
.setup-panel { padding:22px 24px }

/* ── 面板头部：标题 + 操作按钮 ── */
.panel-hd {
  display:flex; align-items:center; justify-content:space-between;
  margin-bottom:18px; padding-bottom:14px; border-bottom:1px solid #f2f3f5;
}
.panel-hd .card-title { margin:0 }

/* ── 表单分节标签 ── */
.form-section-label {
  font-size:11px; font-weight:600; color:#86909c; text-transform:uppercase;
  letter-spacing:.6px; margin:0 0 14px;
}
.form-section-divider { margin-top:22px; padding-top:18px; border-top:1px solid #f2f3f5 }

/* ── 两列表单布局 ── */
.form-2col { display:grid; grid-template-columns:1fr 1fr; column-gap:16px }
.form-2col .el-form-item { margin-bottom:16px }

/* ── 连接状态栏 ── */
.conn-status-bar { display:flex; align-items:center; gap:8px; margin:6px 0 4px; padding:10px 14px; background:#fafafa; border-radius:6px; border:1px solid #f2f3f5 }

/* ── LLM 测试结果 ── */
.llm-result {
  display:flex; align-items:flex-start; gap:10px; margin-top:14px;
  padding:12px 14px; border-radius:7px; font-size:13px; line-height:1.5;
}
.llm-ok { background:#f0f9eb; border:1px solid #b3e19d; color:#529b2e }
.llm-err { background:#fff0f0; border:1px solid #fbc4c4; color:#c45656 }
.llm-result-icon { font-size:14px; font-weight:700; flex-shrink:0; margin-top:1px }
.llm-result-text { flex:1; word-break:break-word; font-family:'JetBrains Mono', Consolas, monospace; font-size:12px }

/* ── 第三步日志输出 ── */
.setup-log {
  font-family:'JetBrains Mono', Consolas, monospace; font-size:12px;
  background:#1a1a2e; color:#a8b3cf; border-radius:7px;
  padding:14px 16px; min-height:220px; max-height:480px;
  overflow-y:auto; white-space:pre-wrap; word-break:break-all; margin:0;
}
.setup-footer { display:flex; gap:10px; justify-content:flex-start; margin-top:18px; padding-top:16px; border-top:1px solid #f2f3f5 }

/* ── Steps 容器 ── */
.card .el-steps { padding:12px 24px }

/* ── 覆盖 el-form label 颜色 ── */
:deep(.el-form-item__label) { color:#4e5969; font-size:13px }
:deep(.el-input__wrapper) { border-radius:6px }
:deep(.el-input-number) { width:100% }

/* ── 日志面板 ── */
.log-panel { display:flex; flex-direction:column }
.log-running { display:flex; align-items:center; gap:6px; font-size:12px; color:#e6a23c; font-weight:600 }
.log-dot {
  width:7px; height:7px; border-radius:50%; background:#e6a23c; flex-shrink:0;
  animation: blink 1s ease-in-out infinite;
}
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.25} }
</style>

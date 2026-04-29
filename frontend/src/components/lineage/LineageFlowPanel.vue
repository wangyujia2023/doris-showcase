<template>
  <div class="card flow-card">
    <el-collapse v-model="flowPanel" accordion>
      <el-collapse-item name="flow">
        <template #title>
          <div class="flow-title">
            <span>{{ t('lineage.flowTitle') }}</span>
            <span class="flow-hint">{{ t('lineage.flowHint') }}</span>
          </div>
        </template>
        <div class="flow-diagram">
          <div class="flow-lane doris" style="grid-column:1">{{ t('lineage.flowLaneDoris') }}</div>
          <div class="flow-lane app" style="grid-column:3">{{ t('lineage.flowLaneImport') }}</div>
          <div class="flow-lane om" style="grid-column:5">{{ t('lineage.flowLaneOM') }}</div>
          <div class="flow-lane app" style="grid-column:7">{{ t('lineage.flowLaneQuery') }}</div>

          <div class="flow-node doris" style="grid-column:1">
            <div class="flow-step-no">{{ t('lineage.flowStep1No') }}</div>
            <div class="flow-step-title">{{ t('lineage.flowStep1Title') }}</div>
            <div class="flow-step-desc">{{ t('lineage.flowStep1Desc') }}</div>
          </div>
          <div class="flow-arrow" style="grid-column:2">-&gt;</div>
          <div class="flow-node app" style="grid-column:3">
            <div class="flow-step-no">{{ t('lineage.flowStep2No') }}</div>
            <div class="flow-step-title">{{ t('lineage.flowStep2Title') }}</div>
            <div class="flow-step-desc">{{ t('lineage.flowStep2Desc') }}</div>
          </div>
          <div class="flow-arrow" style="grid-column:4">-&gt;</div>
          <div class="flow-node om" style="grid-column:5">
            <div class="flow-step-no">{{ t('lineage.flowStep3No') }}</div>
            <div class="flow-step-title">{{ t('lineage.flowStep3Title') }}</div>
            <div class="flow-step-desc">{{ t('lineage.flowStep3Desc') }}</div>
          </div>
          <div class="flow-arrow" style="grid-column:6">-&gt;</div>
          <div class="flow-node app" style="grid-column:7">
            <div class="flow-step-no">{{ t('lineage.flowStep4No') }}</div>
            <div class="flow-step-title">{{ t('lineage.flowStep4Title') }}</div>
            <div class="flow-step-desc">{{ t('lineage.flowStep4Desc') }}</div>
          </div>
        </div>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { t } from '@/i18n'

const flowPanel = ref([])
</script>

<style scoped>
.card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.flow-card { margin-bottom: 16px; }
.flow-title { display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 600; color: #1f2937; }
.flow-hint { font-size: 12px; color: #6b7280; font-weight: 400; }
.flow-diagram { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 12px; align-items: stretch; margin-top: 16px; }
.flow-lane { grid-row: 1; font-size: 12px; font-weight: 700; text-align: center; padding: 10px 12px; border-radius: 8px; border: 2px solid; color: #fff; }
.flow-lane.doris { border-color: #faad14; background: linear-gradient(135deg, #ffd666 0%, #faad14 100%); color: #5c4a1a; }
.flow-lane.app { border-color: #1890ff; background: linear-gradient(135deg, #69b1ff 0%, #1890ff 100%); color: #fff; }
.flow-lane.om { border-color: #52c41a; background: linear-gradient(135deg, #95de64 0%, #52c41a 100%); color: #274e2b; }
.flow-node { grid-row: 2; padding: 16px; border-radius: 12px; border: 2px solid; color: #fff; min-height: 100px; box-shadow: 0 4px 12px rgba(0,0,0,.08); transition: all .3s ease; }
.flow-node:hover { transform: translateY(-4px); box-shadow: 0 8px 20px rgba(0,0,0,.12); }
.flow-node.doris { border-color: #faad14; background: linear-gradient(135deg, #fffbe6 0%, #fff7e6 100%); color: #1f2937; }
.flow-node.app { border-color: #1890ff; background: linear-gradient(135deg, #e6f7ff 0%, #f0f5ff 100%); color: #0050b3; }
.flow-node.om { border-color: #52c41a; background: linear-gradient(135deg, #f6ffed 0%, #f9ffef 100%); color: #274e2b; }
.flow-step-no { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 999px; font-size: 12px; font-weight: 700; margin-bottom: 10px; }
.flow-node.doris .flow-step-no { background: rgba(250,173,20,.15); border: 2px solid #faad14; color: #d48806; }
.flow-node.app .flow-step-no { background: rgba(24,144,255,.15); border: 2px solid #1890ff; color: #0050b3; }
.flow-node.om .flow-step-no { background: rgba(82,196,26,.15); border: 2px solid #52c41a; color: #274e2b; }
.flow-step-title { font-size: 14px; font-weight: 700; margin-bottom: 6px; }
.flow-step-desc { font-size: 12px; line-height: 1.5; }
.flow-node.doris .flow-step-desc { color: #595959; }
.flow-node.app .flow-step-desc, .flow-node.om .flow-step-desc { color: #1f2937; }
.flow-arrow { display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 700; align-self: center; color: #1890ff; animation: flow-arrow-blink 2s ease-in-out infinite; }
@keyframes flow-arrow-blink { 0%,100% { opacity: 1; transform: translateX(0); } 50% { opacity: .6; transform: translateX(4px); } }
</style>

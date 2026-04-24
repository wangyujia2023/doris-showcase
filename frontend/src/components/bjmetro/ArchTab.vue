<template>
  <div class="arch-wrap">
    <!-- 标题 -->
    <div class="arch-title">
      <span class="title-text">{{ t('bjm.archTitle') }}</span>
      <span class="title-sub">{{ t('bjm.archSub') }}</span>
    </div>

    <!-- 主架构图 -->
    <div class="arch-body">

      <!-- 第一层：数据源 -->
      <div class="layer">
        <div class="layer-label">{{ t('bjm.sourceLayer') }}</div>
        <div class="layer-cards">
          <div class="src-card" v-for="s in sources" :key="s.name">
            <span class="src-icon">{{ s.icon }}</span>
            <span class="src-name">{{ s.name }}</span>
            <span class="src-tag" :class="s.type">{{ s.typeLabel }}</span>
          </div>
        </div>
      </div>

      <!-- 第二层：采集接入 -->
      <div class="layer layer-ingestion">
        <div class="layer-label">{{ t('bjm.ingestLayer') }}</div>
        <div class="layer-cards">
          <div class="ing-card" v-for="i in ingestion" :key="i.name">
            <span class="ing-icon">{{ i.icon }}</span>
            <div class="ing-info">
              <div class="ing-name">{{ i.name }}</div>
              <div class="ing-desc">{{ i.desc }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 第三层：Doris 核心 -->
      <div class="layer layer-doris">
        <div class="layer-label doris-label">{{ t('bjm.coreLayer') }}</div>
        <div class="doris-block">
          <div class="doris-header">
            <span class="doris-logo">🔥 SelectDB </span>
            <span class="doris-subtitle">{{ t('bjm.coreWarehouse') }}</span>
          </div>
          <div class="doris-content">
            <div class="doris-layers">
              <div class="dl-card" v-for="l in dorisLayers" :key="l.name">
                <div class="dl-name">{{ l.name }}</div>
                <div class="dl-desc">{{ l.desc }}</div>
              </div>
            </div>
            <div class="doris-features">
              <div class="feat-title">{{ t('bjm.coreFeatures') }}</div>
              <div class="feat-tags">
                <span class="feat-tag" v-for="f in dorisFeatures" :key="f">{{ f }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 第四层：服务计算 -->
      <div class="layer layer-service">
        <div class="layer-label">{{ t('bjm.serviceLayer') }}</div>
        <div class="layer-cards">
          <div class="svc-card" v-for="s in services" :key="s.name">
            <span class="svc-icon">{{ s.icon }}</span>
            <div class="svc-info">
              <div class="svc-name">{{ s.name }}</div>
              <div class="svc-desc">{{ s.desc }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 第五层：应用展现 -->
      <div class="layer layer-app">
        <div class="layer-label">{{ t('bjm.appLayer') }}</div>
        <div class="layer-cards">
          <div class="app-card" v-for="a in apps" :key="a.name">
            <span class="app-icon">{{ a.icon }}</span>
            <span class="app-name">{{ a.name }}</span>
          </div>
        </div>
      </div>

    </div>

    <!-- 底部关键指标 -->
    <div class="metrics-row">
      <div class="metric-item" v-for="m in metrics" :key="m.label">
        <div class="metric-val">{{ m.val }}</div>
        <div class="metric-label">{{ m.label }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { t } from '@/i18n'
const sources = [
  { icon: '🎫', name: t('bjm.srcAfc'),    type: 'rt',  typeLabel: t('bjm.rt') },
  { icon: '🚆', name: t('bjm.srcVehicle'), type: 'rt',  typeLabel: t('bjm.rt') },
  { icon: '📡', name: t('bjm.srcSignal'),  type: 'rt',  typeLabel: t('bjm.rt') },
  { icon: '👁️', name: t('bjm.srcVideo'),   type: 'rt',  typeLabel: t('bjm.rt') },
  { icon: '🔧', name: t('bjm.srcMaintain'), type: 'bat', typeLabel: t('bjm.batch') },
  { icon: '💼', name: t('bjm.srcBusiness'), type: 'bat', typeLabel: t('bjm.batch') },
]

const ingestion = [
  { icon: '⚡', name: 'Apache Kafka',      desc: t('bjm.kafkaDesc') },
  { icon: '🌊', name: 'Apache Flink',      desc: t('bjm.flinkDesc') },
  { icon: '🔄', name: 'DataX / SeaTunnel', desc: t('bjm.etlDesc') },
]

const dorisLayers = [
  { name: t('bjm.odsLayer'), desc: t('bjm.odsDesc') },
  { name: t('bjm.dwdLayer'), desc: t('bjm.dwdDesc') },
  { name: t('bjm.dwsLayer'), desc: t('bjm.dwsDesc') },
  { name: t('bjm.adsLayer'), desc: t('bjm.adsDesc') },
]

const dorisFeatures = [
  t('bjm.uniqueKey'), t('bjm.duplicateKey'),
  t('bjm.invertedIndex'), t('bjm.rollup'),
  t('bjm.streamLoad'), t('bjm.bitmap'),
  t('bjm.vectorEngine'), t('bjm.columnCompress'),
]

const services = [
  { icon: '📊', name: t('bjm.olapQuery'), desc: t('bjm.olapDesc') },
  { icon: '🔍', name: t('bjm.searchSvc'),  desc: t('bjm.searchDesc') },
  { icon: '🤖', name: t('bjm.aiSvc'),  desc: t('bjm.aiDesc') },
  { icon: '🔗', name: t('bjm.apiSvc'),   desc: t('bjm.apiDesc') },
]

const apps = [
  { icon: '📊', name: t('bjm.appOps') },
  { icon: '👥', name: t('bjm.appFlowPred') },
  { icon: '🚇', name: t('bjm.appDispatch') },
  { icon: '⚙️', name: t('bjm.appWarning') },
  { icon: '💰', name: t('bjm.appScreen') },
]

const metrics = [
  { val: '< 1s',  label: t('bjm.metricResp') },
  { val: '10万+', label: t('bjm.metricQps') },
  { val: '30 天', label: t('bjm.metricHotWindow') },
  { val: '99.9%', label: t('bjm.metricAvail') },
  { val: '10:1+', label: t('bjm.metricCompress') },
  { val: '亿级',  label: t('bjm.metricScale') },
]
</script>

<style scoped>
.arch-wrap {
  display: flex;
  flex-direction: column;
  gap: 10px;
  height: 100%;
}

/* 标题 */
.arch-title {
  display: flex;
  align-items: baseline;
  gap: 12px;
  padding-bottom: 10px;
  border-bottom: 2px solid #e4e7ed;
  flex-shrink: 0;
}
.title-text {
  font-size: 18px;
  font-weight: 700;
  color: #1a1a2e;
}
.title-sub {
  font-size: 13px;
  color: #909399;
}

/* 主体 */
.arch-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}

/* 通用层布局 */
.layer {
  display: flex;
  align-items: center;
  gap: 10px;
}
.layer-label {
  writing-mode: vertical-rl;
  text-orientation: mixed;
  white-space: nowrap;
  font-size: 11px;
  font-weight: 600;
  color: #909399;
  letter-spacing: 2px;
  min-width: 26px;
  text-align: center;
}
.layer-cards {
  display: flex;
  gap: 8px;
  flex: 1;
}

/* 数据源卡片 */
.src-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 10px 6px;
  box-shadow: 0 1px 4px rgba(0,0,0,.05);
}
.src-icon { font-size: 20px; line-height: 1; }
.src-name { font-size: 11px; font-weight: 600; color: #303133; text-align: center; }
.src-tag {
  padding: 1px 6px;
  border-radius: 8px;
  font-size: 10px;
  font-weight: 600;
}
.src-tag.rt  { background: #fff7e6; color: #fa8c16; border: 1px solid #ffd591; }
.src-tag.bat { background: #e6f7ff; color: #1890ff; border: 1px solid #91d5ff; }

/* 采集层 */
.ing-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  background: #fff;
  border: 1px solid #d9ecff;
  border-left: 3px solid #409eff;
  border-radius: 6px;
  padding: 8px 12px;
  box-shadow: 0 1px 4px rgba(64,158,255,.1);
}
.ing-icon { font-size: 18px; }
.ing-name { font-size: 12px; font-weight: 700; color: #303133; }
.ing-desc { font-size: 10px; color: #909399; margin-top: 2px; }

/* Doris 核心层 */
.layer-doris { align-items: stretch; }
.doris-label { color: #e6522c; }
.doris-block {
  flex: 1;
  background: linear-gradient(135deg, #fffaf9 0%, #fff3f0 100%);
  border: 2px solid #e6522c;
  border-radius: 10px;
  padding: 10px 14px;
  box-shadow: 0 2px 12px rgba(230,82,44,.1);
}
.doris-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.doris-logo {
  font-size: 14px;
  font-weight: 700;
  color: #e6522c;
}
.doris-subtitle {
  font-size: 11px;
  color: #999;
}
.doris-content {
  display: flex;
  gap: 12px;
}
.doris-layers {
  display: flex;
  gap: 8px;
  flex: 2;
}
.dl-card {
  flex: 1;
  background: #fff;
  border: 1px solid #ffd6c9;
  border-radius: 6px;
  padding: 8px;
  text-align: center;
}
.dl-name {
  font-size: 12px;
  font-weight: 700;
  color: #e6522c;
  margin-bottom: 4px;
}
.dl-desc {
  font-size: 10px;
  color: #8c8c8c;
  line-height: 1.5;
  white-space: pre-line;
}
.doris-features {
  flex: 1;
  background: #fff;
  border: 1px dashed #ffd6c9;
  border-radius: 6px;
  padding: 8px 10px;
}
.feat-title {
  font-size: 11px;
  font-weight: 700;
  color: #e6522c;
  margin-bottom: 6px;
}
.feat-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
.feat-tag {
  background: #fff3f0;
  border: 1px solid #ffd6c9;
  color: #c0392b;
  border-radius: 3px;
  font-size: 10px;
  padding: 1px 6px;
  font-weight: 500;
}

/* 服务层 */
.svc-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  background: #fff;
  border: 1px solid #d9f7be;
  border-left: 3px solid #52c41a;
  border-radius: 6px;
  padding: 8px 12px;
  box-shadow: 0 1px 4px rgba(82,196,26,.1);
}
.svc-icon { font-size: 18px; }
.svc-name { font-size: 12px; font-weight: 700; color: #303133; }
.svc-desc { font-size: 10px; color: #909399; margin-top: 2px; }

/* 应用层 */
.app-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  background: #fff;
  border: 1px solid #d6e4ff;
  border-top: 3px solid #2f54eb;
  border-radius: 6px;
  padding: 10px 6px;
  box-shadow: 0 1px 4px rgba(47,84,235,.08);
}
.app-icon { font-size: 20px; }
.app-name { font-size: 11px; font-weight: 600; color: #303133; text-align: center; }

/* 底部指标 */
.metrics-row {
  display: flex;
  gap: 0;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 10px 0;
  box-shadow: 0 1px 4px rgba(0,0,0,.05);
  flex-shrink: 0;
}
.metric-item {
  flex: 1;
  text-align: center;
  border-right: 1px solid #f0f0f0;
  padding: 0 8px;
}
.metric-item:last-child { border-right: none; }
.metric-val {
  font-size: 20px;
  font-weight: 700;
  color: #e6522c;
  line-height: 1.2;
}
.metric-label {
  font-size: 11px;
  color: #909399;
  margin-top: 2px;
}
</style>

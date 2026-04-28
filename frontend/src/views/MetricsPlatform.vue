<template>
  <div class="mp-wrap">

    <!-- ── 左侧面板 ─────────────────────────────── -->
    <div class="left-panel card">
      <div class="lp-tabs">
        <span :class="['lp-tab', lpTab==='catalog'?'act':'']"   @click="lpTab='catalog'">{{ t('catalog') }}</span>
        <span :class="['lp-tab', lpTab==='template'?'act':'']"  @click="lpTab='template';loadTemplates()">{{ t('template') }}</span>
        <span :class="['lp-tab', lpTab==='saved'?'act':'']"     @click="lpTab='saved';loadSaved()">{{ t('saved') }}</span>
        <span :class="['lp-tab', lpTab==='history'?'act':'']"   @click="lpTab='history';loadHistory()">{{ t('history') }}</span>
      </div>

      <!-- 目录 -->
      <div v-show="lpTab==='catalog'" class="lp-body">
        <div class="cat-title">{{ t('dimensions') }} <el-tag size="small" type="info">{{ defs.dimensions.length }}</el-tag></div>
        <div v-for="d in defs.dimensions" :key="d.field"
          class="cat-item" :class="{ active: selectedDims.includes(d.field) }"
          @click="toggleDim(d.field)">
          <span>{{ d.icon }}</span><span class="ci-label">{{ dimLabel(d.field) }}</span>
          <el-icon v-if="selectedDims.includes(d.field)" color="#409eff" size="13"><Check /></el-icon>
        </div>
        <div class="cat-title" style="margin-top:8px">{{ t('measures') }} <el-tag size="small" type="success">{{ defs.measures.length }}</el-tag></div>
        <div v-for="m in defs.measures" :key="m.alias"
          class="cat-item" :class="{ active: selectedMeasures.includes(m.alias) }"
          @click="toggleMeasure(m.alias)">
          <span>📊</span><span class="ci-label">{{ measureLabel(m.alias) }}</span>
          <el-tag v-if="m.fmt==='money'" size="small" effect="plain" type="warning" style="font-size:10px;margin-left:auto">¥</el-tag>
          <el-tag v-else-if="m.fmt==='pct'"  size="small" effect="plain" type="info"    style="font-size:10px;margin-left:auto">%</el-tag>
          <el-icon v-if="selectedMeasures.includes(m.alias)" color="#67c23a" size="13"><Check /></el-icon>
        </div>
      </div>

      <!-- 模板 -->
      <div v-show="lpTab==='template'" class="lp-body">
          <div v-for="t in templates" :key="t.id" class="tmpl-card" @click="applyTemplate(t)">
          <div class="tmpl-name">{{ templateText(t.id, 'name', t.name) }}</div>
          <div class="tmpl-desc">{{ templateText(t.id, 'desc', t.desc) }}</div>
        </div>
      </div>

      <!-- 收藏 -->
      <div v-show="lpTab==='saved'" class="lp-body">
        <el-empty v-if="!savedList.length" :description="t('noSaved')" :image-size="48" />
        <div v-for="s in savedList" :key="s.id" class="saved-item">
          <span class="si-name" @click="loadSavedConfig(s)">{{ s.name }}</span>
          <span class="si-time">{{ s.created_at }}</span>
          <el-button size="small" type="danger" text @click="deleteSaved(s.id)">✕</el-button>
        </div>
      </div>

      <!-- 历史 -->
      <div v-show="lpTab==='history'" class="lp-body">
        <el-empty v-if="!history.length" :description="t('noHistory')" :image-size="48" />
        <div v-for="(h, i) in history" :key="i" class="hist-item">
          <div class="hist-meta">
            <el-tag size="small" type="success">{{ h.rows }} {{ t('rows') }}</el-tag>
            <el-tag size="small" type="info">{{ h.elapsed_ms }}ms</el-tag>
            <span class="hist-time">{{ h.time }}</span>
          </div>
          <div class="hist-sql">{{ h.sql.substring(0, 120) }}</div>
        </div>
      </div>
    </div>

    <!-- ── 右侧主区 ─────────────────────────────── -->
    <div class="right-col">

      <!-- 查询构建器 -->
      <div class="card qb-card">
        <!-- 时间筛选 -->
        <div class="qb-row">
          <span class="qb-label">{{ t('time') }}</span>
          <el-radio-group v-model="timeRange" size="small" @change="()=>{}">
            <el-radio-button value="">{{ t('any') }}</el-radio-button>
            <el-radio-button value="today">{{ t('today') }}</el-radio-button>
            <el-radio-button value="week">{{ t('last7d') }}</el-radio-button>
            <el-radio-button value="month">{{ t('last30d') }}</el-radio-button>
            <el-radio-button value="quarter">{{ t('lastQuarter') }}</el-radio-button>
            <el-radio-button value="custom">{{ t('custom') }}</el-radio-button>
          </el-radio-group>
          <el-date-picker v-if="timeRange==='custom'" v-model="customRange"
            type="daterange" size="small" style="margin-left:8px;width:230px"
            :start-placeholder="t('start')" :end-placeholder="t('end')" value-format="YYYY-MM-DD" />
        </div>

        <!-- 维度 -->
        <div class="qb-row">
          <span class="qb-label">{{ t('dimensions') }}</span>
          <div class="chip-area">
            <el-tag v-for="f in selectedDims" :key="f" closable type="primary" effect="plain" size="small"
              style="margin:2px" @close="toggleDim(f)">{{ dimLabel(f) }}</el-tag>
            <span v-if="!selectedDims.length" class="ph">{{ t('pickDim') }}</span>
          </div>
        </div>

        <!-- 指标 -->
        <div class="qb-row">
          <span class="qb-label">{{ t('measures') }}</span>
          <div class="chip-area">
            <el-tag v-for="a in selectedMeasures" :key="a" closable type="success" effect="plain" size="small"
              style="margin:2px" @close="toggleMeasure(a)">{{ measureLabel(a) }}</el-tag>
            <span v-if="!selectedMeasures.length" class="ph">{{ t('pickMeasure') }}</span>
          </div>
        </div>

        <!-- 筛选条件 -->
        <div class="qb-row" style="align-items:flex-start">
          <span class="qb-label" style="padding-top:4px">{{ t('filters') }}</span>
          <div style="flex:1">
            <div v-for="(f, i) in filters" :key="i" class="filter-row">
              <el-select v-if="i>0" v-model="f.logic" size="small" style="width:54px">
                <el-option value="AND" :label="t('and')" /><el-option value="OR" :label="t('or')" />
              </el-select>
              <span v-else style="width:54px;font-size:12px;color:#909399">WHERE</span>
              <el-select v-model="f.field" size="small" :placeholder="t('field')" style="width:110px">
                <el-option-group :label="t('dimensions')">
                  <el-option v-for="d in defs.dimensions" :key="d.field" :value="d.field" :label="dimLabel(d.field)" />
                </el-option-group>
                <el-option-group :label="t('numerics')">
                  <el-option value="aum_total"    :label="metricText('aum_total')" />
                  <el-option value="credit_score"  :label="metricText('credit_score')" />
                  <el-option value="churn_prob"    :label="metricText('churn_prob')" />
                  <el-option value="loan_amount"   :label="metricText('loan_amount')" />
                  <el-option value="fund_amount"   :label="metricText('fund_amount')" />
                  <el-option value="deposit_amount" :label="metricText('deposit_amount')" />
                  <el-option value="age"           :label="metricText('age')" />
                </el-option-group>
              </el-select>
              <el-select v-model="f.op" size="small" style="width:68px">
                <el-option v-for="op in ['=','!=','>','>=','<','<=','LIKE']" :key="op" :value="op" :label="op" />
              </el-select>
              <el-input v-model="f.value" size="small" :placeholder="t('value')" style="width:110px" />
              <el-button size="small" type="danger" text @click="filters.splice(i,1)">✕</el-button>
            </div>
            <el-button size="small" type="primary" text @click="addFilter">+ {{ t('addFilter') }}</el-button>
          </div>
        </div>

        <!-- 自定义计算字段（折叠） -->
        <div class="qb-row" v-if="showCalc" style="align-items:flex-start">
          <span class="qb-label" style="padding-top:4px">{{ t('calcFields') }}</span>
          <div style="flex:1">
            <div v-for="(cf, i) in calcFields" :key="i" style="display:flex;gap:6px;margin-bottom:6px;align-items:center">
              <el-input v-model="cf.label" size="small" :placeholder="t('name')" style="width:90px" />
              <span style="font-size:12px;color:#909399">=</span>
              <el-input v-model="cf.expr"  size="small" :placeholder="t('formula')" style="width:220px" />
              <el-button size="small" type="danger" text @click="calcFields.splice(i,1)">✕</el-button>
            </div>
            <el-button size="small" type="primary" text @click="calcFields.push({label:'',expr:''})">+ {{ t('addFormula') }}</el-button>
          </div>
        </div>

        <!-- 操作栏 -->
        <div class="qb-actions">
          <el-button type="primary" :loading="querying" :disabled="!canQuery" @click="doQuery">
            <el-icon><Search /></el-icon> {{ t('runQuery') }}
          </el-button>
          <el-button @click="clearAll">{{ t('clear') }}</el-button>
          <el-button :type="showCalc?'warning':'default'" @click="showCalc=!showCalc">ƒ {{ t('calcFields') }}</el-button>

          <el-select v-model="sortBy" size="small" :placeholder="t('sortField')" style="width:110px" clearable>
            <el-option v-for="a in selectedMeasures" :key="a" :value="a" :label="measureLabel(a)" />
          </el-select>
          <el-select v-model="sortDir" size="small" style="width:72px">
            <el-option value="DESC" :label="t('desc')" /><el-option value="ASC" :label="t('asc')" />
          </el-select>
          <el-select v-model="topN" size="small" :placeholder="t('topn')" style="width:82px" clearable>
            <el-option :value="5"  label="Top5" /><el-option :value="10" label="Top10" />
            <el-option :value="20" label="Top20" /><el-option :value="50" label="Top50" />
          </el-select>

          <div style="margin-left:auto;display:flex;align-items:center;gap:6px">
            <span style="font-size:12px;color:#909399">{{ t('returnRows') }}</span>
            <el-select v-model="pageSize" size="small" style="width:68px">
              <el-option v-for="n in [20,50,100,200]" :key="n" :value="n" :label="n" />
            </el-select>
          </div>
        </div>
      </div>

      <!-- SQL 透明化 -->
      <div v-if="result.sql" class="card sql-card">
        <div class="sql-toggle" @click="sqlExpanded=!sqlExpanded">
          <el-tag type="success" effect="dark" size="small">SQL</el-tag>
          <span class="sql-meta">{{ t('elapsed') }} {{ result.elapsed_ms }}ms · {{ result.total }} {{ t('rows') }}</span>
          <span style="margin-left:auto;font-size:12px;color:#67c23a">{{ sqlExpanded?t('collapse'):t('expand') }}</span>
        </div>
        <pre v-if="sqlExpanded" class="sql-code">{{ result.sql }}</pre>
      </div>

      <!-- 结果面板 -->
      <div v-if="result.rows.length || queried" class="card result-card">
        <el-tabs v-model="resultTab" @tab-click="onTabSwitch">

          <!-- ① 查询结果 -->
          <el-tab-pane :label="t('queryResult')" name="result">
            <div v-if="result.rows.length">
              <!-- 图表工具栏 -->
              <div v-if="canChart" class="chart-toolbar">
                <el-radio-group v-model="chartType" size="small">
                  <el-radio-button value="bar">{{ t('bar') }}</el-radio-button>
                  <el-radio-button value="line">{{ t('line') }}</el-radio-button>
                  <el-radio-button value="pie">{{ t('pie') }}</el-radio-button>
                  <el-radio-button value="scatter">{{ t('scatter') }}</el-radio-button>
                  <el-radio-button value="radar">{{ t('radar') }}</el-radio-button>
                </el-radio-group>
                <div style="margin-left:auto;display:flex;gap:6px">
                  <el-button size="small" @click="exportCsv">⬇ CSV</el-button>
                  <el-button size="small" @click="exportExcel">⬇ Excel</el-button>
                  <el-button size="small" @click="openSaveDialog" :disabled="!result.rows.length">💾 {{ t('save') }}</el-button>
                </div>
              </div>
              <v-chart :option="chartOpt" style="height:300px;margin-bottom:12px"
                autoresize @click="onChartClick" v-if="canChart" />

              <!-- 表格 -->
              <div class="table-toolbar">
                <el-tag size="small">{{ result.total }} {{ t('rows') }}</el-tag>
                <el-pagination v-model:current-page="curPage" :page-size="pageSize"
                  :total="result.total" layout="prev,pager,next"
                  @current-change="doQuery" small style="margin-left:auto" />
              </div>
              <el-table :data="result.rows" border stripe size="small" max-height="360"
                highlight-current-row @row-click="onRowClick">
                <el-table-column v-for="col in result.columns" :key="col.field"
                  :prop="col.field" :label="columnLabel(col)" sortable
                  :align="col.type==='measure'?'right':'left'" min-width="100">
                  <template #default="{row}">
                    <el-tag v-if="col.type==='dim'" size="small" effect="plain">{{ row[col.field] }}</el-tag>
                    <span v-else-if="col.fmt==='pct'"
                      :style="{color:+row[col.field]>30?'#f56c6c':'#409eff',fontWeight:'600'}">
                      {{ row[col.field] }}%
                    </span>
                    <span v-else-if="col.fmt==='money'" style="font-weight:600;color:#303133">
                      {{ fmtNum(row[col.field]) }}
                    </span>
                    <span v-else style="font-weight:600">{{ fmtNum(row[col.field]) }}</span>
                  </template>
                </el-table-column>
                <el-table-column :label="t('drill')" width="54" v-if="selectedDims.length">
                  <template #default="{row}">
                    <el-button size="small" text type="primary" @click.stop="initDrill(row)">→</el-button>
                  </template>
                </el-table-column>
              </el-table>

              <!-- 目标值对比 -->
              <div class="target-section">
                <span class="ts-title">{{ t('targetCompare') }}</span>
                <div class="target-grid">
                  <div v-for="a in selectedMeasures" :key="a" class="target-cell">
                    <div class="tc-label">{{ measureLabel(a) }}</div>
                    <el-input v-model="targets[a]" size="small" :placeholder="t('targetValue')" style="width:120px" />
                    <div v-if="targets[a] && result.rows.length" class="tc-rate">
                      {{ t('achieveRate') }}
                      <span :style="{color: achieveRate(a)>=100?'#67c23a':'#e6a23c',fontWeight:'700'}">
                        {{ achieveRate(a) }}%
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <el-empty v-else-if="queried && !querying" :description="t('noData')" :image-size="60" />
          </el-tab-pane>

          <!-- ② 对比分析 -->
          <el-tab-pane :label="t('compare')" name="compare">
            <div class="compare-toolbar">
              <el-radio-group v-model="compareType" size="small">
                <el-radio-button value="mom">{{ t('mom') }}</el-radio-button>
                <el-radio-button value="yoy">{{ t('yoy') }}</el-radio-button>
              </el-radio-group>
              <el-date-picker v-model="compareRange" type="daterange" size="small"
                style="margin-left:12px;width:230px" value-format="YYYY-MM-DD"
                :start-placeholder="t('currentStart')" :end-placeholder="t('currentEnd')" />
              <el-button type="primary" size="small" :loading="comparing"
                @click="doCompare" style="margin-left:8px">{{ t('analyze') }}</el-button>
            </div>

            <div v-if="compareResult.diffs && compareResult.diffs.length" style="margin-top:16px">
              <div class="period-label">
                <el-tag type="primary" effect="plain">{{ t('current') }}: {{ compareResult.current_period }}</el-tag>
                <el-tag type="info"    effect="plain" style="margin-left:8px">{{ t('compareTo') }}: {{ compareResult.prev_period }}</el-tag>
              </div>
              <div class="compare-cards">
                <div v-for="d in compareResult.diffs" :key="d.alias" class="cmp-card">
                  <div class="cc-label">{{ measureLabel(d.alias) }}</div>
                  <div class="cc-cur">{{ fmtNum(d.current) }}</div>
                  <div :class="['cc-chg', d.up?'up':'down']">
                    {{ d.up ? '▲' : '▼' }} {{ Math.abs(d.change_pct) }}%
                  </div>
                  <div class="cc-prev">{{ t('comparePeriod') }}: {{ fmtNum(d.previous) }}</div>
                </div>
              </div>
            </div>

            <div v-if="compareResult.rows && compareResult.rows.length" style="margin-top:16px">
              <el-table :data="compareResult.rows" border stripe size="small" max-height="380">
                <el-table-column v-for="f in compareResult.dim_fields" :key="f"
                  :prop="f" :label="dimLabel(f)" align="left">
                  <template #default="{row}">
                    <el-tag size="small" effect="plain">{{ row[f] }}</el-tag>
                  </template>
                </el-table-column>
                <template v-for="a in compareResult.measure_aliases" :key="a">
                  <el-table-column :label="measureLabel(a)" align="right" min-width="90">
                    <template #default="{row}">{{ fmtNum(row[a]) }}</template>
                  </el-table-column>
                  <el-table-column :label="t('comparePeriod')" align="right" min-width="80">
                    <template #default="{row}">{{ fmtNum(row[`${a}_prev`]) }}</template>
                  </el-table-column>
                  <el-table-column :label="t('changePct')" align="right" width="80">
                    <template #default="{row}">
                      <span :style="{color:row[`${a}_up`]?'#67c23a':'#f56c6c',fontWeight:'600'}">
                        {{ row[`${a}_up`]?'▲':'▼' }} {{ Math.abs(row[`${a}_chg`]) }}%
                      </span>
                    </template>
                  </el-table-column>
                </template>
              </el-table>
            </div>

            <el-empty v-if="!compareResult.diffs && !compareResult.rows" :description="t('compareHint')" :image-size="60" />
          </el-tab-pane>

          <!-- ③ 下钻分析 -->
          <el-tab-pane :label="t('drillAnalysis')" name="drill">
            <div v-if="!drillContext">
              <el-empty :description="t('drillHint')" :image-size="60" />
            </div>
            <div v-else>
              <el-breadcrumb separator="/" style="margin-bottom:12px">
                <el-breadcrumb-item @click="clearDrill" style="cursor:pointer">{{ t('all') }}</el-breadcrumb-item>
                <el-breadcrumb-item v-for="(p,i) in drillPath" :key="i">
                  {{ dimLabel(p.dim) }}: <b>{{ p.value }}</b>
                </el-breadcrumb-item>
              </el-breadcrumb>

              <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px">
                <span style="font-size:13px;color:#606266">{{ t('drillTo') }}</span>
                <el-select v-model="drillChildDim" size="small" style="width:120px">
                  <el-option v-for="d in drillableDims" :key="d.field" :value="d.field" :label="dimLabel(d.field)" />
                </el-select>
                <el-button size="small" type="primary" :loading="drilling" @click="executeDrill">{{ t('expand') }}</el-button>
                <el-button size="small" @click="clearDrill">{{ t('reset') }}</el-button>
              </div>

              <el-table v-if="drillResult.rows.length" :data="drillResult.rows"
                border stripe size="small" max-height="360"
                @row-click="onDrillRowClick">
                <el-table-column v-for="col in drillResult.columns" :key="col.field"
                  :prop="col.field" :label="columnLabel(col)" sortable
                  :align="col.type==='measure'?'right':'left'">
                  <template #default="{row}">
                    <el-tag v-if="col.type==='dim'" size="small" effect="plain">{{ row[col.field] }}</el-tag>
                    <span v-else style="font-weight:600">{{ fmtNum(row[col.field]) }}</span>
                  </template>
                </el-table-column>
                <el-table-column :label="t('continueDrill')" width="72">
                  <template #default="{row}">
                    <el-button size="small" text type="primary" @click.stop="initDrillFrom(row)">→</el-button>
                  </template>
                </el-table-column>
              </el-table>

              <div v-if="drillResult.sql" class="drill-sql">
                <el-tag type="info" size="small">SQL</el-tag>
                <code>{{ drillResult.sql }}</code>
              </div>
            </div>
          </el-tab-pane>

        </el-tabs>
      </div>

    </div><!-- end right-col -->
  </div>

  <!-- 保存查询对话框 -->
      <el-dialog v-model="saveVisible" :title="t('saveDialogTitle')" width="340px">
    <el-input v-model="saveName" :placeholder="t('queryName')" maxlength="30" show-word-limit />
    <template #footer>
      <el-button @click="saveVisible=false">{{ t('cancel') }}</el-button>
      <el-button type="primary" @click="doSave" :disabled="!saveName.trim()">{{ t('save') }}</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, LineChart, PieChart, ScatterChart, RadarChart } from 'echarts/charts'
import {
  GridComponent, TooltipComponent, LegendComponent,
  MarkLineComponent, RadarComponent,
} from 'echarts/components'
import VChart from 'vue-echarts'
import { Check, Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { metricsApi } from '@/api'
import { t as i18nT, locale } from '@/i18n'

const t = key => i18nT(`metrics.${key}`)

const DIM_EN = {
  asset_level:'Asset Level', age_group:'Age Group', city:'City', lifecycle_stage:'Lifecycle Stage',
  active_level:'Activity Level', preferred_channel:'Preferred Channel', gender:'Gender',
  credit_grade:'Credit Grade', risk_level:'Risk Level', province:'Province',
}
const MEASURE_EN = {
  user_cnt:'Users', total_aum:'Total AUM', avg_aum:'Avg AUM', max_aum:'Max AUM',
  anomaly_cnt:'Anomaly Users', anomaly_rate:'Anomaly Rate', avg_churn:'Avg Churn',
  avg_credit:'Avg Credit', loan_total:'Loan Total', fund_total:'Fund Total', deposit_sum:'Deposit Total',
  aum_total:'AUM', credit_score:'Credit Score', churn_prob:'Churn Probability', loan_amount:'Loan Amount',
  fund_amount:'Fund Amount', deposit_amount:'Deposit Amount', age:'Age',
}
const METRIC_ZH = {
  aum_total:'AUM', credit_score:'信用分', churn_prob:'流失概率', loan_amount:'贷款金额',
  fund_amount:'基金金额', deposit_amount:'存款金额', age:'年龄',
}
const TEMPLATE_EN = {
  t1: { name: 'Asset Level Distribution', desc: 'Count users and AUM by asset level' },
  t2: { name: 'Province Churn Analysis', desc: 'Compare average churn rate by province' },
  t3: { name: 'Channel Activity Analysis', desc: 'Credit score and AUM by preferred channel' },
  t4: { name: 'Lifecycle x Asset Cross', desc: 'Cross analysis of lifecycle stage and asset level' },
  t5: { name: 'High-Value Profile', desc: 'Client structure with AUM > 50万' },
  t6: { name: 'Credit Risk by Region', desc: 'Loan scale and anomaly rate by city' },
}

use([CanvasRenderer, BarChart, LineChart, PieChart, ScatterChart, RadarChart,
     GridComponent, TooltipComponent, LegendComponent, MarkLineComponent, RadarComponent])

// ── 左侧面板 ────────────────────────────────────────────
const lpTab     = ref('catalog')
const defs      = ref({ dimensions: [], measures: [] })
const templates = ref([])
const savedList = ref([])
const history   = ref([])

// ── 查询构建器状态 ───────────────────────────────────────
const selectedDims    = ref([])
const selectedMeasures = ref([])
const timeRange   = ref('')
const customRange = ref(null)
const filters     = ref([])
const sortBy      = ref('')
const sortDir     = ref('DESC')
const topN        = ref(null)
const showCalc    = ref(false)
const calcFields  = ref([])
const pageSize    = ref(50)
const curPage     = ref(1)
const targets     = reactive({})

// ── 查询结果 ─────────────────────────────────────────────
const querying    = ref(false)
const queried     = ref(false)
const result      = ref({ columns: [], rows: [], sql: '', elapsed_ms: 0, total: 0 })
const sqlExpanded = ref(false)
const chartType   = ref('bar')
const resultTab   = ref('result')

// ── 对比分析 ─────────────────────────────────────────────
const comparing     = ref(false)
const compareType   = ref('mom')
const compareRange  = ref(null)
const compareResult = ref({})

// ── 下钻 ─────────────────────────────────────────────────
const drillContext  = ref(null)   // { dim, value }
const drillPath     = ref([])
const drillChildDim = ref('')
const drillResult   = ref({ columns: [], rows: [], sql: '' })
const drilling      = ref(false)

// ── 保存弹窗 ─────────────────────────────────────────────
const saveVisible = ref(false)
const saveName    = ref('')

// ── 计算属性 ─────────────────────────────────────────────
const canQuery = computed(() =>
  selectedDims.value.length + selectedMeasures.value.length + calcFields.value.filter(c=>c.label&&c.expr).length > 0
)
const canChart = computed(() =>
  selectedDims.value.length >= 1 && selectedMeasures.value.length >= 1 && result.value.rows.length > 0
)

const dimLabel     = f => (locale.value === 'en' ? DIM_EN[f] : defs.value.dimensions.find(d => d.field === f)?.label) || f
const measureLabel = a => (locale.value === 'en' ? MEASURE_EN[a] : defs.value.measures.find(m => m.alias === a)?.label) || a
const metricText = k => (locale.value === 'en' ? MEASURE_EN[k] : METRIC_ZH[k]) || k
const templateText = (id, key, fallback) => (locale.value === 'en' ? TEMPLATE_EN[id]?.[key] : fallback) || fallback
const columnLabel = col => {
  if (!col) return ''
  if (col.type === 'dim') return dimLabel(col.field)
  const label = measureLabel(col.field)
  return label === col.field ? (col.label || col.field) : label
}

const drillableDims = computed(() =>
  defs.value.dimensions.filter(d => d.field !== drillContext.value?.dim)
)

function fmtNum(v) {
  if (v === null || v === undefined) return '-'
  const n = Number(v)
  if (isNaN(n)) return v
  return n % 1 === 0 ? n.toLocaleString() : n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// ── 目录交互 ─────────────────────────────────────────────
function toggleDim(f) {
  const i = selectedDims.value.indexOf(f)
  i >= 0 ? selectedDims.value.splice(i, 1) : selectedDims.value.push(f)
}
function toggleMeasure(a) {
  const i = selectedMeasures.value.indexOf(a)
  i >= 0 ? selectedMeasures.value.splice(i, 1) : selectedMeasures.value.push(a)
}
function addFilter() {
  filters.value.push({ field: '', op: '=', value: '', logic: 'AND' })
}
function clearAll() {
  selectedDims.value = []; selectedMeasures.value = []
  filters.value = []; calcFields.value = []
  timeRange.value = ''; customRange.value = null
  sortBy.value = ''; topN.value = null
  result.value = { columns: [], rows: [], sql: '', elapsed_ms: 0, total: 0 }
  queried.value = false; compareResult.value = {}
  clearDrill()
}

// ── 模板 ────────────────────────────────────────────────
function applyTemplate(t) {
  selectedDims.value    = [...(t.dimensions || [])]
  selectedMeasures.value = [...(t.measures || [])]
  filters.value  = (t.filters || []).map(f => ({ ...f }))
  calcFields.value = [...(t.calc_fields || [])]
  sortBy.value  = t.sort_by  || ''
  sortDir.value = t.sort_dir || 'DESC'
  pageSize.value = t.limit  || 50
  lpTab.value = 'catalog'
  ElMessage.success(i18nT('metrics.appliedTemplate', [templateText(t.id, 'name', t.name)]))
}

// ── 查询执行 ─────────────────────────────────────────────
async function doQuery() {
  querying.value = true; queried.value = true
  try {
    const cf = calcFields.value
      .filter(c => c.label && c.expr)
      .map(c => ({ name: c.label.replace(/\s+/g, '_'), label: c.label, expr: c.expr }))

    result.value = await metricsApi.query({
      dimensions:  selectedDims.value,
      measures:    selectedMeasures.value,
      limit:       pageSize.value,
      page:        curPage.value,
      filters:     filters.value.filter(f => f.field && f.value),
      sort_by:     sortBy.value || null,
      sort_dir:    sortDir.value,
      top_n:       topN.value || null,
      calc_fields: cf,
      time_range:  timeRange.value || null,
      start_date:  customRange.value?.[0] || null,
      end_date:    customRange.value?.[1] || null,
    })
    if (canChart.value) chartType.value = 'bar'
  } finally { querying.value = false }
}

// ── 对比分析 ─────────────────────────────────────────────
async function doCompare() {
  comparing.value = true
  try {
    compareResult.value = await metricsApi.compare({
      dimensions:    selectedDims.value,
      measures:      selectedMeasures.value,
      compare_type:  compareType.value,
      current_start: compareRange.value?.[0] || null,
      current_end:   compareRange.value?.[1] || null,
    })
  } finally { comparing.value = false }
}

// ── 下钻 ─────────────────────────────────────────────────
function initDrill(row) {
  if (!selectedDims.value.length) return
  const dim = selectedDims.value[0]
  drillContext.value = { dim, value: row[dim] }
  drillPath.value = [{ dim, value: row[dim] }]
  drillChildDim.value = defs.value.dimensions.find(d => d.field !== dim)?.field || ''
  drillResult.value = { columns: [], rows: [], sql: '' }
  resultTab.value = 'drill'
}
function initDrillFrom(row) {
  if (!drillResult.value.columns.length) return
  const dimCol = drillResult.value.columns.find(c => c.type === 'dim')
  if (!dimCol) return
  drillPath.value.push({ dim: dimCol.field, value: row[dimCol.field] })
  drillContext.value = { dim: dimCol.field, value: row[dimCol.field] }
  drillChildDim.value = defs.value.dimensions.find(d =>
    !drillPath.value.map(p=>p.dim).includes(d.field)
  )?.field || ''
  drillResult.value = { columns: [], rows: [], sql: '' }
}
function clearDrill() {
  drillContext.value = null; drillPath.value = []
  drillChildDim.value = ''; drillResult.value = { columns: [], rows: [], sql: '' }
}
async function executeDrill() {
  if (!drillContext.value || !drillChildDim.value) return
  drilling.value = true
  try {
    drillResult.value = await metricsApi.drilldown({
      parent_dim:   drillContext.value.dim,
      parent_value: String(drillContext.value.value),
      child_dim:    drillChildDim.value,
      measures:     selectedMeasures.value,
      filters:      filters.value.filter(f => f.field && f.value),
    })
  } finally { drilling.value = false }
}

// ── 图表交互 ─────────────────────────────────────────────
function onChartClick(params) {
  if (!selectedDims.value.length || !result.value.rows.length) return
  const dim = selectedDims.value[0]
  const row = result.value.rows.find(r => String(r[dim]) === String(params.name))
  if (row) initDrill(row)
}
function onRowClick(row) {
  // 可扩展：点击行联动图表高亮
}
function onTabSwitch() {}

// ── 保存 ─────────────────────────────────────────────────
function openSaveDialog() { saveVisible.value = true; saveName.value = '' }
async function doSave() {
  const config = {
    dimensions: selectedDims.value, measures: selectedMeasures.value,
    filters: filters.value, sort_by: sortBy.value, sort_dir: sortDir.value,
    limit: pageSize.value, calc_fields: calcFields.value,
    time_range: timeRange.value,
  }
  await metricsApi.saveQuery({ name: saveName.value.trim(), config })
  ElMessage.success(t('savedOk'))
  saveVisible.value = false
  loadSaved()
}
async function loadSaved() { savedList.value = await metricsApi.listSaved() }
function loadSavedConfig(s) {
  const c = s.config || {}
  selectedDims.value    = c.dimensions || []
  selectedMeasures.value = c.measures  || []
  filters.value  = (c.filters || []).map(f => ({ ...f }))
  calcFields.value = c.calc_fields || []
  sortBy.value  = c.sort_by  || ''
  sortDir.value = c.sort_dir || 'DESC'
  pageSize.value = c.limit  || 50
  timeRange.value = c.time_range || ''
  ElMessage.success(i18nT('metrics.loadedSaved', [s.name]))
  lpTab.value = 'catalog'
}
async function deleteSaved(id) {
  await metricsApi.deleteSaved(id)
  loadSaved()
}

async function loadTemplates() { templates.value = await metricsApi.templates() }
async function loadHistory()   { history.value   = await metricsApi.history() }

// ── 达成率 ────────────────────────────────────────────────
function achieveRate(alias) {
  const target = parseFloat(targets[alias])
  if (!target || !result.value.rows.length) return 0
  const actual = result.value.rows.reduce((s, r) => s + (parseFloat(r[alias]) || 0), 0)
  return Math.round(actual / target * 100)
}

// ── 导出 ─────────────────────────────────────────────────
function exportCsv() { doExport('csv') }
function exportExcel() { doExport('excel') }
function doExport(type) {
  const cols = result.value.columns
  const rows = result.value.rows
  const header = cols.map(c => columnLabel(c)).join(',')
  const lines  = rows.map(r => cols.map(c => `"${r[c.field] ?? ''}"`).join(','))
  const content = [header, ...lines].join('\n')
  const BOM = type === 'excel' ? '\uFEFF' : ''
  const blob = new Blob([BOM + content], {
    type: type === 'excel' ? 'application/vnd.ms-excel;charset=utf-8' : 'text/csv;charset=utf-8',
  })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url; a.download = `metrics_export.${type === 'excel' ? 'csv' : 'csv'}`
  a.click(); URL.revokeObjectURL(url)
}

// ── 图表配置 ─────────────────────────────────────────────
const COLORS = ['#409eff','#67c23a','#e6a23c','#f56c6c','#9b59b6','#1abc9c','#e74c3c','#2ecc71']

const chartOpt = computed(() => {
  if (!canChart.value) return {}
  const dimField = selectedDims.value[0]
  const mCols = result.value.columns.filter(c => c.type === 'measure')
  const cats  = result.value.rows.map(r => String(r[dimField] ?? ''))
  const type  = chartType.value

  if (type === 'pie') {
    return {
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      legend:  { type: 'scroll', orient: 'vertical', right: 10, top: 'center' },
      series: [{
        type: 'pie', radius: ['35%', '65%'], center: ['42%', '50%'],
        data: result.value.rows.map(r => ({
          name: String(r[dimField] ?? ''), value: r[mCols[0]?.field] ?? 0,
        })),
        label: { formatter: '{b}: {d}%' },
      }],
    }
  }

  if (type === 'scatter') {
    if (mCols.length < 2) return {}
    return {
      tooltip: { trigger: 'item', formatter: p => `${cats[p.dataIndex]}<br/>${columnLabel(mCols[0])}: ${p.value[0]}<br/>${columnLabel(mCols[1])}: ${p.value[1]}` },
      grid: { left: 60, right: 20, top: 30, bottom: 40 },
      xAxis: { type: 'value', name: columnLabel(mCols[0]) },
      yAxis: { type: 'value', name: columnLabel(mCols[1]) },
      series: [{ type: 'scatter', data: result.value.rows.map(r => [r[mCols[0].field], r[mCols[1].field]]),
        symbolSize: 10, itemStyle: { color: '#409eff' },
        label: { show: true, formatter: p => cats[p.dataIndex], position: 'top', fontSize: 10 },
      }],
    }
  }

  if (type === 'radar') {
    const maxVals = mCols.map(c => Math.max(...result.value.rows.map(r => r[c.field] || 0)) * 1.2 || 1)
    return {
      tooltip: {},
      legend: { data: cats, bottom: 0 },
      radar: { indicator: mCols.map((c, i) => ({ name: columnLabel(c), max: maxVals[i] })), radius: '65%' },
      series: [{
        type: 'radar',
        data: result.value.rows.slice(0, 6).map((r, ri) => ({
          name: cats[ri],
          value: mCols.map(c => r[c.field] ?? 0),
          itemStyle: { color: COLORS[ri % COLORS.length] },
          areaStyle: { opacity: 0.1 },
        })),
      }],
    }
  }

  // bar / line
  return {
    tooltip: { trigger: 'axis' },
    legend: { top: 0, data: mCols.map(c => columnLabel(c)) },
    grid: { left: 70, right: 20, top: 36, bottom: cats.length > 6 ? 60 : 30 },
    xAxis: { type: 'category', data: cats, axisLabel: { rotate: cats.length > 6 ? 30 : 0 } },
    yAxis: { type: 'value' },
    series: mCols.map((col, i) => ({
      name: columnLabel(col), type,
      data: result.value.rows.map(r => r[col.field]),
      itemStyle: { color: COLORS[i % COLORS.length] },
      label: { show: result.value.rows.length <= 12, position: 'top', fontSize: 10 },
      smooth: type === 'line',
    })),
  }
})

// ── 初始化 ────────────────────────────────────────────────
onMounted(async () => {
  defs.value = await metricsApi.definitions()
  templates.value = await metricsApi.templates()
})
</script>

<style scoped>
.mp-wrap { display: grid; grid-template-columns: 230px 1fr; gap: 16px; align-items: start; }

/* 左侧面板 */
.left-panel { padding: 0; overflow: hidden; max-height: calc(100vh - 140px); overflow-y: auto; }
.lp-tabs { display: flex; border-bottom: 1px solid #f0f0f0; }
.lp-tab { flex: 1; text-align: center; padding: 9px 0; font-size: 12px; cursor: pointer; color: #606266; transition: all .15s; }
.lp-tab:hover { color: #409eff; }
.lp-tab.act { color: #409eff; border-bottom: 2px solid #409eff; font-weight: 600; }
.lp-body { padding: 8px 0; }

.cat-title { font-size: 11px; font-weight: 600; color: #909399; padding: 8px 14px 4px; text-transform: uppercase; letter-spacing: .4px; }
.cat-item { display: flex; align-items: center; gap: 6px; padding: 6px 14px; cursor: pointer; font-size: 12px; color: #303133; transition: all .12s; }
.cat-item:hover  { background: #f5f7fa; }
.cat-item.active { background: #ecf5ff; color: #409eff; }
.ci-label { flex: 1; }

.tmpl-card { padding: 10px 14px; border-bottom: 1px solid #f0f0f0; cursor: pointer; transition: background .12s; }
.tmpl-card:hover { background: #f5f7fa; }
.tmpl-name { font-size: 13px; font-weight: 600; color: #303133; }
.tmpl-desc { font-size: 11px; color: #909399; margin-top: 2px; }

.saved-item { display: flex; align-items: center; gap: 6px; padding: 8px 14px; border-bottom: 1px solid #f5f5f5; }
.si-name { font-size: 12px; color: #409eff; cursor: pointer; flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.si-time { font-size: 10px; color: #c0c4cc; }

.hist-item { padding: 8px 14px; border-bottom: 1px solid #f5f5f5; }
.hist-meta { display: flex; align-items: center; gap: 4px; margin-bottom: 4px; }
.hist-time { margin-left: auto; font-size: 10px; color: #c0c4cc; }
.hist-sql { font-size: 10px; color: #909399; font-family: monospace; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* 右侧 */
.right-col { display: flex; flex-direction: column; gap: 16px; }

/* 查询构建器 */
.qb-card { display: flex; flex-direction: column; gap: 10px; }
.qb-row { display: flex; align-items: flex-start; gap: 10px; flex-wrap: wrap; }
.qb-label { font-size: 12px; font-weight: 600; color: #606266; white-space: nowrap; padding-top: 5px; min-width: 38px; }
.chip-area { flex: 1; display: flex; flex-wrap: wrap; min-height: 28px; padding: 2px 0; }
.ph { color: #c0c4cc; font-size: 12px; padding: 5px 0; }
.qb-actions { display: flex; align-items: center; gap: 8px; padding-top: 8px; border-top: 1px solid #f0f0f0; flex-wrap: wrap; }

.filter-row { display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }

/* SQL */
.sql-card { padding: 12px 16px; }
.sql-toggle { display: flex; align-items: center; cursor: pointer; }
.sql-toggle:hover { opacity: .8; }
.sql-meta { margin-left: 10px; font-size: 12px; color: #67c23a; }
.sql-code { background: #1e1e2e; color: #a8b3cf; padding: 12px 16px; border-radius: 6px; margin-top: 10px; font-size: 11px; font-family: monospace; white-space: pre-wrap; word-break: break-all; }

/* 结果 */
.result-card { min-height: 200px; }
.chart-toolbar { display: flex; align-items: center; margin-bottom: 10px; flex-wrap: wrap; gap: 8px; }
.table-toolbar { display: flex; align-items: center; margin-bottom: 6px; }

/* 对比 */
.compare-toolbar { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; }
.period-label { margin-bottom: 12px; }
.compare-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; margin-bottom: 16px; }
.cmp-card { background: #fafafa; border: 1px solid #ebeef5; border-radius: 8px; padding: 14px 16px; }
.cc-label { font-size: 12px; color: #909399; margin-bottom: 6px; }
.cc-cur   { font-size: 22px; font-weight: 700; color: #303133; }
.cc-chg   { font-size: 13px; font-weight: 600; margin: 4px 0; }
.cc-chg.up   { color: #67c23a; }
.cc-chg.down { color: #f56c6c; }
.cc-prev  { font-size: 11px; color: #c0c4cc; }

/* 目标值 */
.target-section { margin-top: 16px; padding-top: 12px; border-top: 1px dashed #ebeef5; }
.ts-title { font-size: 12px; font-weight: 600; color: #909399; display: block; margin-bottom: 10px; }
.target-grid { display: flex; flex-wrap: wrap; gap: 16px; }
.target-cell { display: flex; align-items: center; gap: 8px; }
.tc-label { font-size: 12px; color: #606266; min-width: 80px; }
.tc-rate  { font-size: 12px; color: #606266; }

/* 下钻 */
.drill-sql { margin-top: 12px; padding: 8px 12px; background: #f5f7fa; border-radius: 4px; font-size: 11px; color: #606266; }
.drill-sql code { font-family: monospace; word-break: break-all; }
</style>

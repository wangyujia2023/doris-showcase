<template>
  <div class="reg-wrap">

    <!-- ── 顶部栏 ── -->
    <div class="topbar">
      <div class="top-logo">🏦 {{ t('report.logo') }}<span>{{ t('report.oneTable') }}</span></div>
      <div class="top-sep"></div>
      <div class="top-period">{{ t('report.period') }}：<strong>2024 Q1</strong></div>
      <div class="top-period">{{ t('report.org') }}：<strong>{{ t('report.orgName') }}</strong></div>
      <div class="status-chips">
        <span class="chip ok">✓ {{ t('report.audited') }} {{ chips.ok }}</span>
        <span class="chip warn">⚠ {{ t('report.pending') }} {{ chips.warn }}</span>
        <span class="chip err">✗ {{ t('report.failed') }} {{ chips.err }}</span>
      </div>
      <div class="top-right">
        <button class="btn btn-init" @click="handleInit" :disabled="initing">
          {{ initing ? t('report.initializing') : t('report.initData') }}
        </button>
        <button class="btn btn-check" @click="activeTab='qc'">{{ t('report.qualityCheck') }}</button>
        <button class="btn btn-submit">{{ t('report.submit') }}</button>
      </div>
    </div>

    <!-- ── 主体三栏 ── -->
    <div class="main">

      <!-- 左侧导航 -->
      <div class="sidebar">
        <div v-for="group in displayNavGroups" :key="group.title" class="nav-group">
          <div class="nav-group-title">{{ group.title }}</div>
          <div v-for="item in group.items" :key="item.code"
               class="nav-item" :class="{ active: currentCode === item.code }"
               @click="selectReport(item.code)">
            <div class="nav-code">{{ item.code }}</div>
            <div class="nav-name">{{ item.name }}</div>
            <div class="nav-freq" :class="item.freq==='月'?'freq-m':'freq-q'">{{ freqLabel(item.freq) }}</div>
            <div class="nav-dot" :class="`nd-${item.status}`"></div>
          </div>
        </div>
      </div>

      <!-- 中间内容 -->
      <div class="content">
        <!-- 报表头 -->
        <div class="report-header">
          <div class="rh-code">{{ meta.code }}</div>
          <div class="rh-info">
            <h2>{{ meta.name }}</h2>
            <p>{{ meta.desc }}</p>
          </div>
          <div class="rh-tags">
            <span class="tag tag-cbirc">NFRA</span>
            <span class="tag" :class="meta.freqTag==='月'?'tag-month':'tag-qtr'">
              {{ meta.freqTag==='月' ? t('report.monthDue') : t('report.quarterDue') }}
            </span>
          </div>
        </div>

        <!-- Tab -->
        <div class="tab-bar">
          <div class="tab" :class="{active:activeTab==='data'}"    @click="switchTab('data')">{{ t('regulatory.tabOverview') }}</div>
          <div class="tab" :class="{active:activeTab==='formula'}" @click="switchTab('formula')">{{ t('report.formula') }}</div>
          <div class="tab" :class="{active:activeTab==='qc'}"      @click="switchTab('qc')">{{ t('regulatory.tabQuality') }}</div>
          <div class="tab" :class="{active:activeTab==='ddl'}"     @click="switchTab('ddl')">🗄️ DDL</div>
        </div>

        <!-- 内容区 -->
        <div class="content-body">

          <!-- 报表数据 -->
          <div v-show="activeTab==='data'">
            <div v-if="tableLoading" class="loading-placeholder">
              <div class="spinner"></div> {{ t('report.loading') }}
            </div>
            <table v-else class="report-table">
              <thead>
                <tr><th v-for="h in tableHeader" :key="h">{{ h }}</th></tr>
              </thead>
              <tbody>
                <tr v-for="(row, ri) in tableRows" :key="ri" :class="row.cls">
                  <td v-for="(col, ci) in row.cols" :key="ci"
                      :class="getCellClass(row, ci, col)">
                    <span v-if="col==='✓'" class="qc-ok">✓</span>
                    <span v-else-if="col==='⚠'||row.warn&&ci===row.cols.length-1" class="qc-warn">{{ col }}</span>
                    <template v-else>{{ col }}</template>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- 计算逻辑 -->
          <div v-show="activeTab==='formula'" v-html="currentFormula"></div>

          <!-- 数据质量 -->
          <div v-show="activeTab==='qc'">
            <div v-if="qcLoading" class="loading-placeholder"><div class="spinner"></div> {{ t('report.loadingQc') }}</div>
            <template v-else>
              <div class="qc-grid">
                <div class="qc-card">
                  <div class="qc-card-title">{{ t('report.completeness') }}</div>
                  <div class="qc-score pass">{{ qcData.score >= 95 ? '98' : Math.round(qcData.score) }}<span style="font-size:14px">%</span></div>
                  <div class="qc-meta">{{ qcData.passed }}/{{ qcData.total }} 规则通过</div>
                </div>
                <div class="qc-card">
                  <div class="qc-card-title">{{ t('report.balanceCheck') }}</div>
                  <div class="qc-score" :class="balancePass?'pass':'warn'">{{ balancePass?t('report.pass'):t('report.abnormal') }}</div>
                  <div class="qc-meta">{{ t('report.balanceMeta') }}</div>
                </div>
                <div class="qc-card">
                  <div class="qc-card-title">{{ t('report.ruleCheck') }}</div>
                  <div class="qc-score" :class="qcData.passed===qcData.total?'pass':'warn'">
                    {{ qcData.passed }}/{{ qcData.total }}
                  </div>
                  <div class="qc-meta" :style="{color: qcData.passed<qcData.total?'#d97706':'#059669'}">
                    {{ t('report.rulesFailed', [qcData.total - qcData.passed]) }}
                  </div>
                </div>
              </div>
              <div class="qc-rule-list">
                <div v-for="(r,i) in qcData.rules" :key="i" class="qc-rule"
                     :class="r.pass?'pass':'fail'">
                  <span class="qr-icon">{{ r.pass?'✅':'❌' }}</span>
                  <span class="qr-desc">{{ r.rule }}</span>
                  <span class="qr-val">{{ r.detail }}</span>
                </div>
              </div>
            </template>
          </div>

          <!-- 数据结构 -->
          <div v-show="activeTab==='ddl'" v-html="currentDdl"></div>

        </div>
      </div>

      <!-- 右侧面板 -->
      <div class="right-panel">
        <div class="rp-section">
          <div class="rp-title">{{ t('report.coreIndicators') }}</div>
          <div v-if="indLoading" class="loading-placeholder small"><div class="spinner"></div></div>
          <div v-else class="indicator-list">
            <div v-for="ind in indicators" :key="ind.name" class="ind-item">
              <div class="ind-name">{{ ind.name }}</div>
              <div class="ind-row">
                <div class="ind-val" :class="ind.status">{{ ind.val }}</div>
                <div class="ind-threshold">{{ ind.threshold }}</div>
              </div>
              <div class="ind-bar-wrap">
                <div class="ind-bar"
                     :style="{width:ind.pct+'%',background:ind.status==='ok'?'#10b981':ind.status==='warn'?'#f59e0b':'#ef4444'}">
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="rp-section">
          <div class="rp-title">{{ t('report.monthlyCalendar') }}</div>
          <div class="cal-list">
            <div v-for="c in calendar" :key="c.date+c.name" class="cal-item">
              <div class="cal-date">{{ c.date }}</div>
              <div class="cal-name">{{ c.name }}</div>
              <div class="cal-dot" :class="c.dot"></div>
            </div>
          </div>
        </div>

        <div class="rp-section">
          <div class="rp-title">{{ t('report.recentHistory') }}</div>
          <div class="hist-list">
            <div v-for="h in history" :key="h.title" class="hist-item"
                 :style="{borderLeftColor:h.warn?'#f59e0b':'#10b981'}">
              <div class="hist-title">{{ h.title }}</div>
              <div class="hist-meta">{{ h.meta }}</div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { regulatoryApi } from '@/api'
import { t, locale } from '@/i18n'

// ── 静态元数据 ─────────────────────────────────────────────────
const REPORT_META = {
  G01: { code:'G01', name:'资产负债表',       freqTag:'月', period:'2024-03',
         desc:'统计银行期末资产、负债及所有者权益科目余额 · 监管机构：国家金融监管总局' },
  G02: { code:'G02', name:'利润表',           freqTag:'季', period:'2024-Q1',
         desc:'统计银行各报告期收入、成本及利润情况 · 月度快报' },
  G03: { code:'G03', name:'资本充足率报表',    freqTag:'季', period:'2024-Q1',
         desc:'统计银行资本构成及风险加权资产，计算各级资本充足率 · 巴塞尔III框架' },
  G04A:{ code:'G04A',name:'贷款质量五级分类', freqTag:'月', period:'2024-03',
         desc:'按照五级分类标准统计各类贷款的质量分布及不良贷款情况' },
  G04B:{ code:'G04B',name:'迁徙矩阵',         freqTag:'季', period:'2024-Q1',
         desc:'统计贷款在各分类级别之间的迁移情况，衡量资产质量变化趋势' },
  G11: { code:'G11', name:'流动性覆盖率报表', freqTag:'月', period:'2024-03',
         desc:'统计合格优质流动资产及未来30天压力情景下的净现金流出，计算LCR' },
  G11A:{ code:'G11A',name:'净稳定资金比例',   freqTag:'季', period:'2024-Q1',
         desc:'统计可用稳定资金与所需稳定资金的比例，衡量中长期流动性' },
  G12: { code:'G12', name:'期限错配',         freqTag:'月', period:'2024-03',
         desc:'统计各期限资产负债缺口及累计缺口，反映流动性错配风险' },
  G21: { code:'G21', name:'人民币信贷收支',   freqTag:'月', period:'2024-03',
         desc:'统计人民币贷款、存款及相关结构数据，是货币统计核心报表' },
  G22: { code:'G22', name:'贷款投向统计',     freqTag:'季', period:'2024-Q1',
         desc:'按国民经济行业分类统计贷款分布，反映资金流向结构' },
  G23: { code:'G23', name:'房地产贷款',       freqTag:'季', period:'2024-Q1',
         desc:'统计房地产开发贷款、个人住房贷款等专项数据' },
  G31: { code:'G31', name:'单一客户集中度',   freqTag:'季', period:'2024-Q1',
         desc:'统计对单一客户授信集中度，防范大额风险暴露' },
  G32: { code:'G32', name:'集团客户授信',     freqTag:'季', period:'2024-Q1',
         desc:'统计对集团关联客户的授信总量及集中度指标' },
  G40: { code:'G40', name:'利率风险',         freqTag:'季', period:'2024-Q1',
         desc:'统计银行账簿利率风险敏感性缺口及净利息收入变动敏感度' },
  G42: { code:'G42', name:'杠杆率',           freqTag:'季', period:'2024-Q1',
         desc:'统计一级资本与调整后表内外资产余额的比率，≥4%' },
}

const REPORT_META_EN = {
  G01: { name:'Balance Sheet', desc:'Bank ending assets, liabilities and equity · Regulator: NFRA' },
  G02: { name:'Income Statement', desc:'Revenue, cost and profit by reporting period · Monthly flash report' },
  G03: { name:'Capital Adequacy Report', desc:'Capital structure and risk-weighted assets under Basel III' },
  G04A:{ name:'Five-category Loan Quality', desc:'Loan quality distribution and non-performing loan statistics' },
  G04B:{ name:'Migration Matrix', desc:'Loan migration across classification levels and asset quality trend' },
  G11: { name:'Liquidity Coverage Ratio', desc:'HQLA and 30-day stress net cash outflow for LCR calculation' },
  G11A:{ name:'Net Stable Funding Ratio', desc:'Available stable funding versus required stable funding' },
  G12: { name:'Maturity Mismatch', desc:'Asset-liability gap by maturity bucket and cumulative liquidity gap' },
  G21: { name:'RMB Credit Balance', desc:'Core monetary statistics for RMB loans, deposits and structures' },
  G22: { name:'Loan Use Statistics', desc:'Loan distribution by national economy industry classification' },
  G23: { name:'Real Estate Loans', desc:'Real estate development loans and personal mortgage statistics' },
  G31: { name:'Single Customer Concentration', desc:'Single-name credit concentration and large exposure control' },
  G32: { name:'Group Customer Credit', desc:'Credit exposure and concentration for related group customers' },
  G40: { name:'Interest Rate Risk', desc:'Banking book interest rate gap and NII sensitivity' },
  G42: { name:'Leverage Ratio', desc:'Tier-1 capital over adjusted on/off-balance-sheet assets, minimum 4%' },
}

// ── 静态公式内容 ───────────────────────────────────────────────
const FORMULAS = {
  G01:`<div class="formula-section"><h3>G01 资产负债表 · 核心勾稽关系</h3>
  <div class="formula-card"><h4>📐 基础恒等式</h4>
  <div class="formula-expr">资产总计 = 负债合计 + 所有者权益合计</div>
  <div class="formula-desc">所有输入数据均须满足此平衡方程，差额不得超过100万元。</div></div>
  <div class="formula-card"><h4>📐 A08 发放贷款及垫款净值</h4>
  <div class="formula-expr">A08净值 = 贷款总额 - A08.3贷款损失准备</div></div>
  <div class="formula-card"><h4>📐 A01 汇总</h4>
  <div class="formula-expr">A01 = A01.1现金 + A01.2存放央行款项</div></div>
  <div class="formula-card"><h4>📐 L05 吸收存款</h4>
  <div class="formula-expr">L05 = L05.1单位存款 + L05.2个人存款</div></div>
  <div class="formula-card"><h4>📎 G01↔G04A 贷款口径</h4>
  <div class="formula-expr">G01.A08贷款总额 ≈ G04A.贷款合计 + 票据贴现等
差异通常在7%以内，超过需说明</div></div>
  <div class="formula-card"><h4>📎 G01↔G02 留存收益</h4>
  <div class="formula-expr">G01.E05(期末) = G01.E05(期初) + G02.净利润 - 分配股利</div></div>
</div>`,
  G03:`<div class="formula-section"><h3>G03 资本充足率 · 巴塞尔III计算框架</h3>
  <div class="formula-card"><h4>CET1 核心一级资本净额</h4>
  <div class="formula-expr">CET1 = 实收资本+资本公积+盈余公积+一般风险准备+未分配利润
       + 少数股东资本 - 商誉 - 无形资产 - 对金融机构资本投资</div></div>
  <div class="formula-card"><h4>风险加权资产 RWA</h4>
  <div class="formula-expr">RWA = 信用风险RWA + 市场风险×12.5 + 操作风险×12.5</div></div>
  <div class="formula-card"><h4>三个资本充足率</h4>
  <div class="formula-expr">核心一级资本充足率 = CET1 / RWA  ≥ 7.5%
一级资本充足率   = (CET1+AT1) / RWA ≥ 8.5%
资本充足率       = 总资本净额 / RWA  ≥ 10.5%</div></div>
  <div class="formula-card"><h4>杠杆率</h4>
  <div class="formula-expr">杠杆率 = 一级资本净额 / 调整后表内外资产余额 ≥ 4%</div></div>
</div>`,
  G04A:`<div class="formula-section"><h3>G04A 五级分类 · 计算逻辑</h3>
  <div class="formula-card"><h4>不良贷款率</h4>
  <div class="formula-expr">NPL率 = (次级+可疑+损失) / 贷款总额 × 100%  ≤ 5%</div></div>
  <div class="formula-card"><h4>拨备充足性</h4>
  <div class="formula-expr">拨备覆盖率 = 贷款损失准备余额 / 不良贷款余额 ≥ 150%
贷款拨备率 = 贷款损失准备余额 / 贷款总额    ≥ 2.5%</div></div>
  <div class="formula-card"><h4>五级分类标准（逾期天数参考）</h4>
  <div class="formula-expr">正常  → 能正常偿还，无本息损失迹象
关注  → 逾期 ≤ 90天，存在不利因素
次级  → 逾期 90~180天
可疑  → 逾期 180~360天
损失  → 逾期 > 360天 或确定无法收回</div></div>
</div>`,
  G11:`<div class="formula-section"><h3>G11 流动性覆盖率 (LCR) · 计算框架</h3>
  <div class="formula-card"><h4>LCR 核心公式</h4>
  <div class="formula-expr">LCR = HQLA合计 / 净现金流出 ≥ 100%
净现金流出 = 现金流出 - min(现金流入, 75% × 现金流出)</div></div>
  <div class="formula-card"><h4>HQLA 三层结构</h4>
  <div class="formula-expr">一级资产  (L1)  = 现金 + 超额准备金 + 国债  折扣率0%
二级A类  (L2A) = 政策行债 + 地方债          折扣率15%
二级B类  (L2B) = 高评级企业债               折扣率50%
二级资产合计 ≤ 40% of HQLA</div></div>
  <div class="formula-card"><h4>压力系数（主要类别）</h4>
  <div class="formula-expr">零售存款（稳定）  5%   批发存款   25%
同业/金融机构  100%  已承诺便利  30%</div></div>
</div>`,
}

// ── 静态 DDL 内容 ──────────────────────────────────────────────
const DDLS = {
  G01:`<div class="formula-section"><h3>G01 · Doris 表结构（UNIQUE 模型）</h3></div>
<div class="ddl-block"><span class="kw">CREATE TABLE</span> reg_g01_balance (
    report_period   <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>   <span class="cm">-- 报告期 2024-03</span>
    org_code        <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    item_code       <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    curr_balance    <span class="tp">BIGINT</span>                   <span class="cm">-- 期末余额（万元）</span>
    prev_balance    <span class="tp">BIGINT</span>,
    currency_code   <span class="tp">VARCHAR(5)</span>   DEFAULT <span class="str">'CNY'</span>,
    status          <span class="tp">VARCHAR(20)</span>  DEFAULT <span class="str">'draft'</span>
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(report_period, org_code, item_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 5
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>
<div class="ddl-block"><span class="kw">CREATE TABLE</span> reg_item_dict (
    report_code     <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>,
    item_code       <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    item_name       <span class="tp">VARCHAR(100)</span> <span class="kw">NOT NULL</span>,
    item_type       <span class="tp">VARCHAR(20)</span>,
    parent_code     <span class="tp">VARCHAR(20)</span>,
    sign_flag       <span class="tp">TINYINT</span>      DEFAULT 1,
    sort_order      <span class="tp">INT</span>,
    is_summary      <span class="tp">TINYINT</span>      DEFAULT 0
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(report_code, item_code)
DISTRIBUTED BY HASH(report_code) BUCKETS 3
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>`,

  G03:`<div class="formula-section"><h3>G03 · Doris 表结构（UNIQUE 模型）</h3></div>
<div class="ddl-block"><span class="kw">CREATE TABLE</span> reg_g03_capital (
    report_period   <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>,
    org_code        <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    cet1_capital    <span class="tp">BIGINT</span>                   <span class="cm">-- 核心一级资本净额（万元）</span>
    at1_capital     <span class="tp">BIGINT</span>,
    t2_capital      <span class="tp">BIGINT</span>,
    total_capital   <span class="tp">BIGINT</span>,
    credit_rwa      <span class="tp">BIGINT</span>,
    market_rwa      <span class="tp">BIGINT</span>,
    ops_rwa         <span class="tp">BIGINT</span>,
    total_rwa       <span class="tp">BIGINT</span>,
    cet1_ratio      <span class="tp">DECIMAL(8,4)</span>,
    tier1_ratio     <span class="tp">DECIMAL(8,4)</span>,
    car_ratio       <span class="tp">DECIMAL(8,4)</span>,
    leverage_ratio  <span class="tp">DECIMAL(8,4)</span>,
    status          <span class="tp">VARCHAR(20)</span>  DEFAULT <span class="str">'draft'</span>
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>`,

  G04A:`<div class="formula-section"><h3>G04A · Doris 表结构（UNIQUE 模型）</h3></div>
<div class="ddl-block"><span class="kw">CREATE TABLE</span> reg_g04a_loan (
    report_period       <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>,
    org_code            <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    loan_type           <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>   <span class="cm">-- CORP/RETAIL/TOTAL</span>
    industry_code       <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>   <span class="cm">-- MFG/RE/WR/ALL...</span>
    total_balance       <span class="tp">BIGINT</span>,
    normal_balance      <span class="tp">BIGINT</span>,
    concern_balance     <span class="tp">BIGINT</span>,
    substandard_balance <span class="tp">BIGINT</span>,
    doubtful_balance    <span class="tp">BIGINT</span>,
    loss_balance        <span class="tp">BIGINT</span>,
    provision_balance   <span class="tp">BIGINT</span>,
    npl_balance         <span class="tp">BIGINT</span>,
    npl_ratio           <span class="tp">DECIMAL(8,4)</span>,
    provision_coverage  <span class="tp">DECIMAL(8,4)</span>
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(report_period, org_code, loan_type, industry_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 5
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>`,

  G11:`<div class="formula-section"><h3>G11 · Doris 表结构（UNIQUE 模型）</h3></div>
<div class="ddl-block"><span class="kw">CREATE TABLE</span> reg_g11_lcr (
    report_period    <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>,
    org_code         <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    hqla_l1          <span class="tp">BIGINT</span>                   <span class="cm">-- 一级资产折后值（万元）</span>
    hqla_l2a         <span class="tp">BIGINT</span>,
    hqla_l2b         <span class="tp">BIGINT</span>,
    hqla_total       <span class="tp">BIGINT</span>,
    outflow_retail   <span class="tp">BIGINT</span>,
    outflow_wholesale <span class="tp">BIGINT</span>,
    outflow_interbank <span class="tp">BIGINT</span>,
    outflow_other    <span class="tp">BIGINT</span>,
    total_outflow    <span class="tp">BIGINT</span>,
    inflow_loans     <span class="tp">BIGINT</span>,
    inflow_other     <span class="tp">BIGINT</span>,
    net_outflow      <span class="tp">BIGINT</span>,
    lcr_ratio        <span class="tp">DECIMAL(8,4)</span>,
    nsfr_ratio       <span class="tp">DECIMAL(8,4)</span>,
    is_compliant     <span class="tp">TINYINT</span>,
    status           <span class="tp">VARCHAR(20)</span>  DEFAULT <span class="str">'draft'</span>
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>
<div class="ddl-block"><span class="cm">-- 报送日志（UNIQUE 模型，log_id 去重）</span>
<span class="kw">CREATE TABLE</span> reg_submit_log (
    log_id       <span class="tp">VARCHAR(36)</span>  <span class="kw">NOT NULL</span>,
    report_code  <span class="tp">VARCHAR(10)</span>  <span class="kw">NOT NULL</span>,
    report_period <span class="tp">VARCHAR(10)</span> <span class="kw">NOT NULL</span>,
    org_code     <span class="tp">VARCHAR(20)</span>  <span class="kw">NOT NULL</span>,
    action       <span class="tp">VARCHAR(20)</span>,
    operator     <span class="tp">VARCHAR(50)</span>,
    action_time  <span class="tp">DATETIME</span>,
    qc_score     <span class="tp">DECIMAL(5,2)</span>,
    remark       <span class="tp">VARCHAR(500)</span>
) ENGINE=OLAP
<span class="kw">UNIQUE KEY</span>(log_id)
DISTRIBUTED BY HASH(log_id) BUCKETS 5
PROPERTIES (<span class="str">"replication_num"</span>=<span class="str">"1"</span>);</div>`,
}

// ── 响应式状态 ─────────────────────────────────────────────────
const currentCode   = ref('G01')
const activeTab     = ref('data')
const initing       = ref(false)
const tableLoading  = ref(false)
const qcLoading     = ref(false)
const indLoading    = ref(true)

const navGroups     = ref([])
const chips         = ref({ ok: 0, warn: 0, err: 0 })
const tableHeader   = ref([])
const tableRows     = ref([])
const indicators    = ref([])
const calendar      = ref([])
const history       = ref([])
const qcData        = ref({ rules: [], total: 0, passed: 0, score: 0 })

// ── 计算属性 ───────────────────────────────────────────────────
const meta    = computed(() => {
  const base = REPORT_META[currentCode.value] || REPORT_META.G01
  return locale.value === 'en' ? { ...base, ...(REPORT_META_EN[currentCode.value] || {}) } : base
})
const displayNavGroups = computed(() => navGroups.value.map(group => ({
  ...group,
  title: navGroupTitle(group.title),
  items: group.items.map(item => ({ ...item, name: reportName(item.code, item.name) })),
})))
const currentFormula = computed(() => FORMULAS[currentCode.value] || '<div style="padding:20px;color:#9ca3af">计算逻辑文档完善中…</div>')
const currentDdl     = computed(() => DDLS[currentCode.value]     || DDLS.G01)
const balancePass    = computed(() => (qcData.value.rules||[]).find(r=>r.rule.includes('平衡'))?.pass ?? true)
const reportName = (code, fallback) => locale.value === 'en' ? (REPORT_META_EN[code]?.name || fallback) : fallback
const navGroupTitle = title => locale.value === 'en' ? ({ '资产负债类':'Balance Sheet', '资本与风险类':'Capital & Risk', '流动性类':'Liquidity', '信贷统计类':'Credit Statistics', '集中度与市场风险':'Concentration & Market Risk' }[title] || title) : title
const freqLabel = freq => locale.value === 'en' ? ({ '月':'M', '季':'Q' }[freq] || freq) : freq

// ── 单元格样式 ─────────────────────────────────────────────────
function getCellClass(row, ci, col) {
  const c = []
  if (ci === 1) {
    c.push('item-name')
    if (row.i1) c.push('indent1')
  } else if (ci >= 2 && row.cls !== 'section-header' && col) {
    if (col.toString().includes(',') || (col.toString().includes('%') && col !== '✓' && col !== '⚠') || col === '—')
      c.push('num')
  }
  return c.join(' ')
}

// ── 加载数据 ───────────────────────────────────────────────────
async function loadNav() {
  try {
    const d = await regulatoryApi.nav()
    if (d.nav?.length) {
      navGroups.value = d.nav
      chips.value = d.chips || chips.value
    }
  } catch (e) { console.warn('nav err', e) }
}

async function loadIndicators() {
  indLoading.value = true
  try {
    const d = await regulatoryApi.indicators()
    if (d.indicators?.length) indicators.value = d.indicators
  } catch(e) { console.warn('ind err', e) }
  finally { indLoading.value = false }
}

async function loadCalendarHistory() {
  try {
    const [cal, hist] = await Promise.all([
      regulatoryApi.calendar(),
      regulatoryApi.history(),
    ])
    if (cal.calendar?.length)  calendar.value = cal.calendar
    if (hist.history?.length)  history.value  = hist.history
  } catch(e) { console.warn('cal/hist err', e) }
}

async function loadTableData(code) {
  const m = REPORT_META[code]
  if (!m) return
  tableLoading.value = true
  tableRows.value = []
  try {
    const d = await regulatoryApi.reportData(code, m.period)
    if (d.rows?.length) {
      tableHeader.value = d.header
      tableRows.value   = d.rows
    }
  } catch(e) { console.warn('table err', e) }
  finally { tableLoading.value = false }
}

async function loadQc() {
  const m = REPORT_META[currentCode.value]
  if (!m) return
  qcLoading.value = true
  try {
    const d = await regulatoryApi.qc(m.period)
    if (d.rules) qcData.value = d
  } catch(e) { console.warn('qc err', e) }
  finally { qcLoading.value = false }
}

// ── 用户操作 ───────────────────────────────────────────────────
async function selectReport(code) {
  currentCode.value = code
  activeTab.value   = 'data'
  await loadTableData(code)
}

async function switchTab(tab) {
  activeTab.value = tab
  if (tab === 'qc' && !qcData.value.rules?.length) await loadQc()
}

async function handleInit() {
  initing.value = true
  try {
    await regulatoryApi.init()
    await regulatoryApi.seed()
    await regulatoryApi.process()
    await Promise.all([loadNav(), loadIndicators(), loadCalendarHistory()])
    await loadTableData(currentCode.value)
  } catch(e) { console.error('init err', e) }
  finally { initing.value = false }
}

// ── 挂载时静默加载 ─────────────────────────────────────────────
onMounted(async () => {
  await Promise.all([loadNav(), loadIndicators(), loadCalendarHistory()])
  await loadTableData('G01')
})
</script>

<style scoped>
*{box-sizing:border-box}
.reg-wrap{
  font-family:'PingFang SC','Microsoft YaHei',sans-serif;
  background:#f5f7fa;color:#1f2937;
  height:100vh;display:flex;flex-direction:column;overflow:hidden;font-size:13px
}

/* 顶部栏 */
.topbar{
  height:52px;background:#fff;border-bottom:1px solid #e5e7eb;
  display:flex;align-items:center;padding:0 18px;gap:14px;flex-shrink:0;
  box-shadow:0 1px 3px rgba(0,0,0,.06)
}
.top-logo{font-size:15px;font-weight:700;color:#111827;white-space:nowrap}
.top-logo span{color:#2563eb}
.top-period{
  padding:3px 10px;background:#f3f4f6;border:1px solid #e5e7eb;border-radius:4px;
  font-size:12px;color:#6b7280;white-space:nowrap
}
.top-period strong{color:#111827}
.top-sep{width:1px;height:24px;background:#e5e7eb;flex-shrink:0}
.status-chips{display:flex;gap:5px;flex-shrink:0}
.chip{padding:3px 9px;border-radius:12px;font-size:11px;font-weight:600}
.chip.ok  {background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0}
.chip.warn{background:#fffbeb;color:#d97706;border:1px solid #fde68a}
.chip.err {background:#fef2f2;color:#dc2626;border:1px solid #fecaca}
.top-right{margin-left:auto;display:flex;gap:7px}
.btn{padding:5px 12px;border-radius:4px;font-size:12px;font-weight:600;cursor:pointer;border:none}
.btn:disabled{opacity:.5;cursor:not-allowed}
.btn-init  {background:#f3f4f6;color:#374151;border:1px solid #d1d5db}
.btn-check {background:#f3f4f6;color:#374151;border:1px solid #e5e7eb}
.btn-submit{background:#2563eb;color:#fff}

/* 主体 */
.main{display:flex;flex:1;overflow:hidden}

/* 左侧导航 */
.sidebar{width:214px;flex-shrink:0;background:#fff;border-right:1px solid #e5e7eb;overflow-y:auto;padding:10px 0}
.nav-group{margin-bottom:2px}
.nav-group-title{padding:5px 14px;font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:1.5px;text-transform:uppercase}
.nav-item{display:flex;align-items:center;gap:7px;padding:6px 14px;cursor:pointer;border-left:2px solid transparent;transition:all .13s}
.nav-item:hover{background:#f9fafb}
.nav-item.active{background:#eff6ff;border-left-color:#2563eb}
.nav-code{font-size:10px;color:#9ca3af;width:30px;flex-shrink:0}
.nav-name{font-size:12px;color:#6b7280;flex:1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.nav-item.active .nav-name{color:#1f2937;font-weight:600}
.nav-freq{font-size:10px;padding:1px 4px;border-radius:3px;flex-shrink:0}
.freq-m{background:#ecfdf5;color:#059669}
.freq-q{background:#fffbeb;color:#d97706}
.nav-dot{width:6px;height:6px;border-radius:50%;flex-shrink:0}
.nd-ok     {background:#10b981}
.nd-warn   {background:#f59e0b}
.nd-err    {background:#ef4444}
.nd-pending{background:#d1d5db}

/* 中间内容 */
.content{flex:1;overflow:hidden;display:flex;flex-direction:column}
.report-header{padding:12px 18px;background:#fff;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;gap:12px;flex-shrink:0}
.rh-code{font-size:21px;font-weight:800;color:#2563eb;letter-spacing:1px;flex-shrink:0}
.rh-info{flex:1;min-width:0}
.rh-info h2{font-size:14px;font-weight:700;color:#111827}
.rh-info p{font-size:11px;color:#9ca3af;margin-top:1px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.rh-tags{display:flex;gap:5px;flex-shrink:0}
.tag{padding:2px 7px;border-radius:4px;font-size:11px;font-weight:500}
.tag-cbirc{background:#eff6ff;color:#2563eb;border:1px solid #bfdbfe}
.tag-month{background:#ecfdf5;color:#059669;border:1px solid #a7f3d0}
.tag-qtr  {background:#fffbeb;color:#d97706;border:1px solid #fde68a}

.tab-bar{display:flex;padding:0 18px;background:#fff;border-bottom:1px solid #e5e7eb;flex-shrink:0}
.tab{padding:9px 16px;font-size:12px;color:#9ca3af;cursor:pointer;border-bottom:2px solid transparent;transition:all .13s;white-space:nowrap}
.tab:hover{color:#6b7280}
.tab.active{color:#2563eb;border-bottom-color:#2563eb;font-weight:600}

.content-body{flex:1;overflow-y:auto;padding:14px 18px}

/* 加载占位 */
.loading-placeholder{display:flex;align-items:center;gap:8px;padding:40px;justify-content:center;color:#9ca3af;font-size:13px}
.loading-placeholder.small{padding:20px}
.spinner{width:16px;height:16px;border:2px solid #e5e7eb;border-top-color:#2563eb;border-radius:50%;animation:spin .7s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}

/* 报表表格 */
.report-table{width:100%;border-collapse:collapse;font-size:12px}
.report-table thead th{background:#f9fafb;color:#374151;font-weight:600;padding:7px 10px;text-align:left;border:1px solid #e5e7eb;font-size:11px;white-space:nowrap}
.report-table tbody tr:hover{background:#fafafa}
.report-table tbody td{padding:6px 10px;border:1px solid #e5e7eb;color:#6b7280}
.report-table tbody td.item-name{color:#1f2937;font-weight:500}
.report-table tbody td.item-name.indent1{padding-left:26px;color:#6b7280;font-weight:400}
.report-table tbody td.num{text-align:right;font-variant-numeric:tabular-nums;color:#1f2937;font-family:'Fira Mono','Consolas',monospace}
.report-table tr.section-header td{background:#eff6ff;color:#2563eb;font-weight:700;font-size:11px}
.report-table tr.subtotal td{background:#f9fafb;font-weight:600;color:#059669!important}
.report-table tr.total-row td{background:#eff6ff;font-weight:700;color:#111827!important}
.qc-ok {color:#10b981}
.qc-warn{color:#f59e0b}

/* 计算逻辑 */
:deep(.formula-section){margin-bottom:18px}
:deep(.formula-section h3){font-size:13px;font-weight:700;color:#111827;margin-bottom:8px;padding-bottom:5px;border-bottom:1px solid #e5e7eb}
:deep(.formula-card){background:#fff;border:1px solid #e5e7eb;border-radius:6px;padding:12px 14px;margin-bottom:8px}
:deep(.formula-card h4){font-size:12px;color:#2563eb;font-weight:700;margin-bottom:6px}
:deep(.formula-expr){background:#f8fafc;border:1px solid #e2e8f0;border-radius:4px;padding:8px 12px;font-family:'Fira Mono','Consolas',monospace;font-size:12px;color:#059669;line-height:1.6;white-space:pre}
:deep(.formula-desc){font-size:11px;color:#9ca3af;line-height:1.7;margin-top:5px}

/* 数据质量 */
.qc-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px}
.qc-card{background:#fff;border:1px solid #e5e7eb;border-radius:6px;padding:12px}
.qc-card-title{font-size:11px;color:#9ca3af;margin-bottom:6px}
.qc-score{font-size:26px;font-weight:800}
.qc-score.pass{color:#10b981}
.qc-score.warn{color:#f59e0b}
.qc-meta{font-size:11px;color:#9ca3af;margin-top:3px}
.qc-rule-list{display:flex;flex-direction:column;gap:4px}
.qc-rule{display:flex;align-items:center;gap:8px;font-size:11px;padding:6px 10px;border-radius:4px;background:#fff;border:1px solid #e5e7eb}
.qc-rule.pass{border-left:3px solid #10b981}
.qc-rule.fail{border-left:3px solid #ef4444}
.qr-icon{font-size:12px;flex-shrink:0}
.qr-desc{flex:1;color:#374151}
.qr-val{color:#9ca3af;font-family:monospace;font-size:10px;white-space:nowrap}

/* DDL */
:deep(.ddl-block){background:#1e293b;border:1px solid #334155;border-radius:6px;padding:12px 14px;font-family:'Fira Mono','Consolas',monospace;font-size:11px;line-height:1.8;color:#cbd5e1;overflow-x:auto;margin-bottom:12px;white-space:pre}
:deep(.ddl-block .kw){color:#93c5fd}
:deep(.ddl-block .tp){color:#6ee7b7}
:deep(.ddl-block .cm){color:#64748b}
:deep(.ddl-block .str){color:#86efac}

/* 右侧面板 */
.right-panel{width:232px;flex-shrink:0;background:#fff;border-left:1px solid #e5e7eb;overflow-y:auto;padding:12px}
.rp-section{margin-bottom:18px}
.rp-title{font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:1.5px;margin-bottom:8px;text-transform:uppercase}
.indicator-list{display:flex;flex-direction:column;gap:7px}
.ind-item{background:#f9fafb;border:1px solid #e5e7eb;border-radius:5px;padding:8px 9px}
.ind-name{font-size:11px;color:#6b7280;margin-bottom:3px}
.ind-row{display:flex;align-items:baseline;gap:6px}
.ind-val{font-size:15px;font-weight:700}
.ind-val.ok  {color:#10b981}
.ind-val.warn{color:#f59e0b}
.ind-val.err {color:#ef4444}
.ind-threshold{font-size:10px;color:#9ca3af}
.ind-bar-wrap{height:3px;background:#e5e7eb;border-radius:2px;margin-top:5px;overflow:hidden}
.ind-bar{height:100%;border-radius:2px;transition:width .4s}

.cal-list{display:flex;flex-direction:column;gap:4px}
.cal-item{display:flex;align-items:center;gap:7px;padding:5px 7px;border-radius:4px;background:#f9fafb;border:1px solid #e5e7eb;font-size:11px}
.cal-date{font-weight:700;color:#1f2937;width:36px}
.cal-name{flex:1;color:#6b7280}
.cal-dot{width:6px;height:6px;border-radius:50%;flex-shrink:0}
.cal-dot.due   {background:#ef4444}
.cal-dot.coming{background:#f59e0b}
.cal-dot.done  {background:#10b981}

.hist-list{display:flex;flex-direction:column;gap:4px}
.hist-item{padding:6px 9px;border-radius:4px;background:#f9fafb;border:1px solid #e5e7eb;border-left:3px solid #10b981}
.hist-title{color:#374151;font-size:11px}
.hist-meta{color:#9ca3af;font-size:10px;margin-top:2px}

::-webkit-scrollbar{width:4px;height:4px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:#e5e7eb;border-radius:2px}
</style>

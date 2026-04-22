-- 银行监管报送一表通 · 建表DDL
USE regdb;

-- 1. 报表科目字典
DROP TABLE IF EXISTS reg_item_dict;
CREATE TABLE reg_item_dict (
    report_code     VARCHAR(10)  NOT NULL  COMMENT '报表代码',
    item_code       VARCHAR(20)  NOT NULL  COMMENT '科目代码',
    item_name       VARCHAR(100) NOT NULL  COMMENT '科目名称',
    item_type       VARCHAR(20)            COMMENT 'ASSET/LIABILITY/EQUITY/CAPITAL/LOAN/LIQUIDITY',
    parent_code     VARCHAR(20)            COMMENT '父级科目',
    sign_flag       TINYINT      DEFAULT 1 COMMENT '1=正值 -1=减项',
    sort_order      INT          DEFAULT 0,
    is_summary      TINYINT      DEFAULT 0 COMMENT '1=汇总行'
) ENGINE=OLAP
UNIQUE KEY(report_code, item_code)
DISTRIBUTED BY HASH(report_code) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 2. G01 资产负债表（按科目逐行存储）
DROP TABLE IF EXISTS reg_g01_balance;
CREATE TABLE reg_g01_balance (
    report_period   VARCHAR(10)  NOT NULL  COMMENT '报告期 2024-03',
    org_code        VARCHAR(20)  NOT NULL  COMMENT '机构代码',
    item_code       VARCHAR(20)  NOT NULL  COMMENT '科目代码',
    curr_balance    BIGINT                 COMMENT '期末余额（万元）',
    prev_balance    BIGINT                 COMMENT '上期余额（万元）',
    currency_code   VARCHAR(5)   DEFAULT 'CNY',
    data_source     VARCHAR(50)            COMMENT '来源系统',
    status          VARCHAR(20)  DEFAULT 'draft'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code, item_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 3. G03 资本充足率
DROP TABLE IF EXISTS reg_g03_capital;
CREATE TABLE reg_g03_capital (
    report_period   VARCHAR(10)  NOT NULL,
    org_code        VARCHAR(20)  NOT NULL,
    cet1_capital    BIGINT                 COMMENT '核心一级资本净额（万元）',
    at1_capital     BIGINT                 COMMENT '其他一级资本',
    t2_capital      BIGINT                 COMMENT '二级资本',
    total_capital   BIGINT                 COMMENT '资本净额合计',
    credit_rwa      BIGINT                 COMMENT '信用风险RWA',
    market_rwa      BIGINT                 COMMENT '市场风险RWA',
    ops_rwa         BIGINT                 COMMENT '操作风险RWA',
    total_rwa       BIGINT                 COMMENT '风险加权资产合计',
    cet1_ratio      DECIMAL(8,4)           COMMENT '核心一级资本充足率',
    tier1_ratio     DECIMAL(8,4)           COMMENT '一级资本充足率',
    car_ratio       DECIMAL(8,4)           COMMENT '资本充足率',
    leverage_ratio  DECIMAL(8,4)           COMMENT '杠杆率',
    status          VARCHAR(20)  DEFAULT 'draft'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 4. G04A 贷款五级分类
DROP TABLE IF EXISTS reg_g04a_loan;
CREATE TABLE reg_g04a_loan (
    report_period       VARCHAR(10)  NOT NULL,
    org_code            VARCHAR(20)  NOT NULL,
    loan_type           VARCHAR(20)  NOT NULL  COMMENT 'CORP/RETAIL/TOTAL',
    industry_code       VARCHAR(20)  NOT NULL  COMMENT '行业/ALL',
    total_balance       BIGINT                 COMMENT '贷款总额（万元）',
    normal_balance      BIGINT,
    concern_balance     BIGINT,
    substandard_balance BIGINT,
    doubtful_balance    BIGINT,
    loss_balance        BIGINT,
    provision_balance   BIGINT,
    npl_balance         BIGINT                 COMMENT '不良贷款=次级+可疑+损失',
    npl_ratio           DECIMAL(8,4),
    provision_coverage  DECIMAL(8,4)           COMMENT '拨备覆盖率'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code, loan_type, industry_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 5. G11 流动性覆盖率
DROP TABLE IF EXISTS reg_g11_lcr;
CREATE TABLE reg_g11_lcr (
    report_period   VARCHAR(10)  NOT NULL,
    org_code        VARCHAR(20)  NOT NULL,
    hqla_l1         BIGINT                 COMMENT '一级资产折后值（万元）',
    hqla_l2a        BIGINT                 COMMENT '二级A类折后值',
    hqla_l2b        BIGINT                 COMMENT '二级B类折后值',
    hqla_total      BIGINT                 COMMENT 'HQLA合计',
    outflow_retail  BIGINT                 COMMENT '零售存款流出',
    outflow_wholesale BIGINT               COMMENT '批发存款流出',
    outflow_interbank BIGINT               COMMENT '同业存款流出',
    outflow_other   BIGINT,
    total_outflow   BIGINT,
    inflow_loans    BIGINT,
    inflow_other    BIGINT,
    net_outflow     BIGINT,
    lcr_ratio       DECIMAL(8,4)           COMMENT 'LCR = HQLA/净流出',
    nsfr_ratio      DECIMAL(8,4)           COMMENT 'NSFR（单独字段）',
    is_compliant    TINYINT                COMMENT '1=达标',
    status          VARCHAR(20)  DEFAULT 'draft'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 6. G21 信贷收支（简化版）
DROP TABLE IF EXISTS reg_g21_credit;
CREATE TABLE reg_g21_credit (
    report_period       VARCHAR(10)  NOT NULL,
    org_code            VARCHAR(20)  NOT NULL,
    loan_balance        BIGINT                 COMMENT '贷款余额（万元）',
    loan_new            BIGINT                 COMMENT '本期新增',
    loan_corp           BIGINT                 COMMENT '企业贷款',
    loan_retail         BIGINT                 COMMENT '个人贷款',
    loan_bill           BIGINT                 COMMENT '票据贴现',
    deposit_balance     BIGINT                 COMMENT '存款余额',
    deposit_corp        BIGINT,
    deposit_retail      BIGINT,
    net_profit_w        BIGINT                 COMMENT '净利润（万元）',
    roa                 DECIMAL(8,4)           COMMENT '资产收益率',
    roe                 DECIMAL(8,4)           COMMENT '净资产收益率'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 7. 报送日志（DUPLICATE KEY + 倒排索引）
DROP TABLE IF EXISTS reg_submit_log;
CREATE TABLE reg_submit_log (
    log_id          VARCHAR(36)  NOT NULL,
    report_code     VARCHAR(10)  NOT NULL,
    report_period   VARCHAR(10)  NOT NULL,
    org_code        VARCHAR(20)  NOT NULL,
    action          VARCHAR(20)            COMMENT 'draft/qc/submit/accept/reject',
    operator        VARCHAR(50),
    action_time     DATETIME,
    qc_score        DECIMAL(5,2),
    fail_rules      VARCHAR(1000)          COMMENT 'JSON失败规则',
    remark          VARCHAR(500),
    INDEX idx_code   (report_code)  USING INVERTED,
    INDEX idx_period (report_period) USING INVERTED,
    INDEX idx_action (action)       USING INVERTED
) ENGINE=OLAP
DUPLICATE KEY(log_id, action_time)
DISTRIBUTED BY HASH(org_code) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 8. 一表通最终表（核心产出）
DROP TABLE IF EXISTS reg_master;
CREATE TABLE reg_master (
    report_period       VARCHAR(10)  NOT NULL  COMMENT '报告期（季度）',
    org_code            VARCHAR(20)  NOT NULL,
    -- G01 资产负债类
    total_assets_w      BIGINT                 COMMENT '总资产（万元）',
    total_liabilities_w BIGINT,
    total_equity_w      BIGINT,
    total_loans_w       BIGINT                 COMMENT '贷款余额',
    total_deposits_w    BIGINT                 COMMENT '存款余额',
    -- G03 资本类
    cet1_ratio          DECIMAL(8,4)           COMMENT '核心一级资本充足率',
    tier1_ratio         DECIMAL(8,4),
    car_ratio           DECIMAL(8,4)           COMMENT '资本充足率',
    leverage_ratio      DECIMAL(8,4),
    total_rwa_w         BIGINT,
    -- G04A 贷款质量
    npl_balance_w       BIGINT,
    npl_ratio           DECIMAL(8,4)           COMMENT '不良贷款率',
    provision_coverage  DECIMAL(8,4)           COMMENT '拨备覆盖率',
    loan_provision_rate DECIMAL(8,4)           COMMENT '贷款拨备率',
    -- G11 流动性
    lcr_ratio           DECIMAL(8,4)           COMMENT '流动性覆盖率',
    nsfr_ratio          DECIMAL(8,4)           COMMENT '净稳定资金比例',
    -- G21 盈利
    net_profit_w        BIGINT,
    roa                 DECIMAL(8,4),
    roe                 DECIMAL(8,4),
    -- 合规判断
    is_car_ok           TINYINT                COMMENT '资本充足率达标',
    is_lcr_ok           TINYINT                COMMENT 'LCR达标',
    is_npl_ok           TINYINT                COMMENT 'NPL达标',
    is_provision_ok     TINYINT                COMMENT '拨备覆盖率达标',
    compliance_score    DECIMAL(5,2)           COMMENT '综合合规得分',
    -- 报送状态
    g01_status          VARCHAR(20)  DEFAULT 'pending',
    g03_status          VARCHAR(20)  DEFAULT 'pending',
    g04a_status         VARCHAR(20)  DEFAULT 'pending',
    g11_status          VARCHAR(20)  DEFAULT 'pending',
    g21_status          VARCHAR(20)  DEFAULT 'pending',
    process_time        DATETIME               COMMENT '一键加工时间'
) ENGINE=OLAP
UNIQUE KEY(report_period, org_code)
DISTRIBUTED BY HASH(org_code) BUCKETS 3
PROPERTIES ("replication_num"="1");

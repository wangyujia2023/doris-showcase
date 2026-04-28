"""Business dictionaries for frontend labels.

Frontend i18n keeps fixed UI text. Business labels that may grow with data domains
live here, so adding languages or new tag sets does not require editing pages.
"""
from __future__ import annotations

from copy import deepcopy
from typing import Dict, Any

DEFAULT_LOCALE = "zh"
LOCALE_ALIASES = {
    "zh": "zh",
    "zh-CN": "zh",
    "cn": "zh",
    "en": "en",
    "en-US": "en",
    "en-GB": "en",
}

_DICTIONARIES: Dict[str, Dict[str, Dict[str, str]]] = {
    "asset_level": {
        "zh": {"VIP私行": "VIP私行", "VIP钻石": "VIP钻石", "VIP铂金": "VIP铂金", "VIP黄金": "VIP黄金", "普通": "普通", "AUM_0_10W": "0-10万", "AUM_10_50W": "10-50万", "AUM_50_300W": "50-300万", "AUM_300W_PLUS": "300万以上"},
        "en": {"VIP私行": "Private Banking", "VIP钻石": "Diamond VIP", "VIP铂金": "Platinum VIP", "VIP黄金": "Gold VIP", "普通": "Standard", "AUM_0_10W": "0-100K", "AUM_10_50W": "100K-500K", "AUM_50_300W": "500K-3M", "AUM_300W_PLUS": "3M+"},
    },
    "active_level": {
        "zh": {"高活": "高活", "中活": "中活", "低活": "低活", "沉睡": "沉睡", "HIGH": "高活跃", "MID": "中活跃", "LOW": "低活跃", "SILENT": "沉默"},
        "en": {"高活": "High", "中活": "Medium", "低活": "Low", "沉睡": "Dormant", "HIGH": "High", "MID": "Medium", "LOW": "Low", "SILENT": "Silent"},
    },
    "lifecycle_stage": {
        "zh": {"新客": "新客", "成长": "成长", "成熟": "成熟", "沉睡": "沉睡", "流失预警": "流失预警", "NEW": "新客", "GROWTH": "成长期", "MATURE": "成熟期", "CHURN_RISK": "流失风险", "LOST": "流失"},
        "en": {"新客": "New", "成长": "Growth", "成熟": "Mature", "沉睡": "Dormant", "流失预警": "Churn Risk", "NEW": "New", "GROWTH": "Growth", "MATURE": "Mature", "CHURN_RISK": "Churn Risk", "LOST": "Lost"},
    },
    "channel": {
        "zh": {"APP": "APP", "网点": "网点", "小程序": "小程序", "网银": "网银", "WEB": "网上银行", "BRANCH": "网点", "CALL_CENTER": "客服中心", "WECHAT": "微信"},
        "en": {"APP": "Mobile App", "网点": "Branch", "小程序": "Mini Program", "网银": "Web Banking", "WEB": "Web Banking", "BRANCH": "Branch", "CALL_CENTER": "Call Center", "WECHAT": "WeChat"},
    },
    "risk_level": {
        "zh": {"1": "保守", "2": "稳健", "3": "平衡", "4": "进取", "5": "激进"},
        "en": {"1": "Conservative", "2": "Stable", "3": "Balanced", "4": "Growth", "5": "Aggressive"},
    },
    "vector_tags": {
        "zh": {"活跃达人": "活跃达人", "高价值客户": "高价值客户", "年轻潮流": "年轻潮流", "理财达人": "理财达人", "科技爱好者": "科技爱好者", "运动健康": "运动健康", "娱乐消费": "娱乐消费", "稳健保守": "稳健保守", "冒险进取": "冒险进取", "学生群体": "学生群体", "行为特征": "行为特征", "资产特征": "资产特征", "人群特征": "人群特征", "兴趣特征": "兴趣特征", "消费特征": "消费特征", "风险特征": "风险特征", "student": "学生", "office_worker": "上班族", "elderly": "老年", "parent_child": "亲子", "fitness": "健身", "business": "商务", "outdoor": "户外", "fashion": "时尚"},
        "en": {"活跃达人": "Active Users", "高价值客户": "High Value", "年轻潮流": "Young Trend", "理财达人": "Wealth Planner", "科技爱好者": "Tech Enthusiast", "运动健康": "Fitness Lover", "娱乐消费": "Entertainment", "稳健保守": "Conservative", "冒险进取": "Risk Taker", "学生群体": "Students", "行为特征": "Behavior", "资产特征": "Assets", "人群特征": "Demographic", "兴趣特征": "Interest", "消费特征": "Consumption", "风险特征": "Risk", "student": "Student", "office_worker": "Office Worker", "elderly": "Elderly", "parent_child": "Parent Child", "fitness": "Fitness", "business": "Business", "outdoor": "Outdoor", "fashion": "Fashion"},
    },
    "metric_dimensions": {
        "zh": {"dt": "日期", "city": "城市", "asset_level": "资产层级", "age_group": "年龄段", "active_level": "活跃层级", "preferred_channel": "偏好渠道", "lifecycle_stage": "生命周期", "gender": "性别", "credit_grade": "信用等级", "risk_level": "风险等级", "province": "省份"},
        "en": {"dt": "Date", "city": "City", "asset_level": "Asset Level", "age_group": "Age Group", "active_level": "Activity Level", "preferred_channel": "Preferred Channel", "lifecycle_stage": "Lifecycle Stage", "gender": "Gender", "credit_grade": "Credit Grade", "risk_level": "Risk Level", "province": "Province"},
    },
    "metric_measures": {
        "zh": {"user_cnt": "用户数", "total_aum": "资产总额", "avg_aum": "平均资产", "max_aum": "最大资产", "anomaly_cnt": "异常用户", "anomaly_rate": "异常率", "avg_churn": "平均流失率", "avg_credit": "平均信用分", "loan_total": "贷款总额", "fund_total": "基金总额", "deposit_sum": "存款总额", "aum_total": "AUM", "credit_score": "信用分", "churn_prob": "流失概率", "loan_amount": "贷款金额", "fund_amount": "基金金额", "deposit_amount": "存款金额", "age": "年龄", "churn_rate": "流失率"},
        "en": {"user_cnt": "Users", "total_aum": "Total AUM", "avg_aum": "Avg AUM", "max_aum": "Max AUM", "anomaly_cnt": "Anomaly Users", "anomaly_rate": "Anomaly Rate", "avg_churn": "Avg Churn", "avg_credit": "Avg Credit", "loan_total": "Loan Total", "fund_total": "Fund Total", "deposit_sum": "Deposit Total", "aum_total": "AUM", "credit_score": "Credit Score", "churn_prob": "Churn Probability", "loan_amount": "Loan Amount", "fund_amount": "Fund Amount", "deposit_amount": "Deposit Amount", "age": "Age", "churn_rate": "Churn Rate"},
    },
    "lineage_layers": {
        "zh": {"ODS": "贴源层", "DWD": "明细层", "DWS": "汇总层", "ADS": "应用层", "DIM": "维表"},
        "en": {"ODS": "ODS", "DWD": "DWD", "DWS": "DWS", "ADS": "ADS", "DIM": "Dimension"},
    },
}


class DictionaryService:
    def normalize_locale(self, locale: str | None) -> str:
        return LOCALE_ALIASES.get((locale or "").strip(), DEFAULT_LOCALE)

    def all(self, locale: str | None = None) -> Dict[str, Any]:
        lang = self.normalize_locale(locale)
        data: Dict[str, Dict[str, str]] = {}
        for name, values in _DICTIONARIES.items():
            merged = deepcopy(values.get(DEFAULT_LOCALE, {}))
            merged.update(values.get(lang, {}))
            data[name] = merged
        return {"locale": lang, "dictionaries": data}

    def one(self, name: str, locale: str | None = None) -> Dict[str, Any]:
        lang = self.normalize_locale(locale)
        values = _DICTIONARIES.get(name, {})
        merged = deepcopy(values.get(DEFAULT_LOCALE, {}))
        merged.update(values.get(lang, {}))
        return {"locale": lang, "name": name, "items": merged}

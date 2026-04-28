-- ================================================================
-- Database: bank_cdp
-- Type: mock data
-- Description: Core CDP mock data and dashboard mock data.
-- Execute after bank_cdp_schema.sql.
-- Execute: mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_mock.sql
-- ================================================================

-- ================================================================
-- Mock data - users
-- ================================================================
USE bank_cdp;

INSERT INTO user_wide (user_id, update_date, user_name, id_card, phone, gender, age, age_group,
    city, province, education, occupation, register_date, asset_level, aum_total, deposit_amount,
    fund_amount, loan_amount, wm_amount, insurance_amount, has_credit_card, has_debit_card,
    has_mortgage, product_count, credit_score, credit_grade, risk_level, preferred_channel,
    app_login_30d, app_last_login, active_level, lifecycle_stage, churn_prob, clv_score,
    log_tags, anomaly_flag, created_at, updated_at)
VALUES
(10001,'2025-04-12','Alex Zhang','110***8881','138****0001',1,45,'36-45','Beijing','Beijing',5,'Finance',
 '2018-03-15','Private Banking',1280.50,520.00,380.00,0,350.00,30.50,1,1,0,8,820,'AAA',3,'APP',
 28,'2025-04-11','High Active','Mature',0.05,95000.00,'["High Net Worth","Fund Preference"]',0,NOW(),NOW()),

(10002,'2025-04-12','Lily Lee','310***2222','139****0002',2,32,'26-35','Shanghai','Shanghai',6,'IT Engineer',
 '2021-06-20','Diamond',380.20,120.00,180.00,50.00,80.00,0,1,1,1,5,760,'AA',4,'APP',
 45,'2025-04-12','High Active','Growth',0.08,42000.00,'["Wealth Preference","High Frequency Trading"]',0,NOW(),NOW()),

(10003,'2025-04-12','Fiona Wang','440***3333','136****0003',2,58,'46-55','Guangzhou','Guangdong',4,'Small Business Owner',
 '2019-11-08','Platinum',620.00,400.00,80.00,120.00,120.00,0,1,1,1,6,780,'AA',2,'Branch',
 3,'2025-03-20','Low Active','Dormant',0.42,55000.00,'["Loan Demand","Remote Login"]',1,NOW(),NOW()),

(10004,'2025-04-12','Charles Zhao','330***4444','135****0004',1,28,'26-35','Hangzhou','Zhejiang',5,'E-commerce Founder',
 '2024-01-10','Gold',85.30,30.00,35.00,20.00,0,0,1,1,0,3,680,'A',5,'Mini Program',
 62,'2025-04-12','High Active','New Customer',0.15,8500.00,'["New Customer","Frequent Operation"]',0,NOW(),NOW()),

(10005,'2025-04-12','May Chen','510***5555','137****0005',2,41,'36-45','Chengdu','Sichuan',5,'Doctor',
 '2020-07-22','Diamond',445.80,200.00,150.00,0,95.80,0,1,1,0,5,810,'AAA',2,'APP',
 15,'2025-04-10','Medium Active','Mature',0.18,48000.00,'["Insurance Preference","Conservative"]',0,NOW(),NOW()),

(10006,'2025-04-12','William Liu','420***6666','133****0006',1,35,'26-35','Wuhan','Hubei',6,'Sales Manager',
 '2022-09-05','Standard',18.50,10.00,5.00,3.50,0,0,1,0,0,2,580,'B',3,'Online Banking',
 8,'2025-04-08','Low Active','Churn Risk',0.68,1200.00,'[]',0,NOW(),NOW()),

(10007,'2025-04-12','Lina Sun','610***7777','132****0007',2,50,'46-55','Xian','Shaanxi',4,'Teacher',
 '2017-04-18','Platinum',560.00,380.00,60.00,0,120.00,0,1,1,0,4,800,'AAA',1,'Branch',
 2,'2025-03-01','Low Active','Dormant',0.55,60000.00,'["Large Transfer"]',1,NOW(),NOW()),

(10008,'2025-04-12','Tony Zhou','120***8888','131****0008',1,38,'36-45','Tianjin','Tianjin',5,'Civil Servant',
 '2023-02-28','Gold',125.60,80.00,30.00,0,15.60,0,1,1,0,3,720,'A',3,'APP',
 20,'2025-04-11','Medium Active','Growth',0.22,15000.00,'["Conservative"]',0,NOW(),NOW()),

(10009,'2025-04-12','Ruby Wu','350***9999','130****0009',2,29,'26-35','Fuzhou','Fujian',6,'Accountant',
 '2024-03-15','Gold',92.40,40.00,42.40,0,10.00,0,1,1,0,3,700,'A',4,'APP',
 35,'2025-04-12','High Active','New Customer',0.10,9800.00,'["Fund Preference"]',0,NOW(),NOW()),

(10010,'2025-04-12','Michael Zheng','370***0010','129****0010',1,55,'46-55','Jinan','Shandong',3,'Business Owner',
 '2016-08-12','Private Banking',2100.80,800.00,600.00,0,700.00,0.80,1,1,0,9,880,'AAA',4,'Branch',
 5,'2025-04-09','Medium Active','Mature',0.08,180000.00,'["High Net Worth","VIP"]',0,NOW(),NOW());

-- ================================================================
-- Mock data - user tag bitmaps
-- ================================================================
INSERT INTO user_tag (tag_date, tag_category, tag_name, tag_value, user_bitmap, user_count, updated_at)
VALUES
-- Asset Level
('2025-04-12','ASSET','asset_level','Private Banking',    TO_BITMAP(10001)|TO_BITMAP(10010), 2, NOW()),
('2025-04-12','ASSET','asset_level','Diamond',    TO_BITMAP(10002)|TO_BITMAP(10005), 2, NOW()),
('2025-04-12','ASSET','asset_level','Platinum',    TO_BITMAP(10003)|TO_BITMAP(10007), 2, NOW()),
('2025-04-12','ASSET','asset_level','Gold',    TO_BITMAP(10004)|TO_BITMAP(10008)|TO_BITMAP(10009), 3, NOW()),
('2025-04-12','ASSET','asset_level','Standard',       TO_BITMAP(10006), 1, NOW()),
-- Activity Level
('2025-04-12','BEHAVIOR','active_level','High Active',   TO_BITMAP(10001)|TO_BITMAP(10002)|TO_BITMAP(10004)|TO_BITMAP(10009), 4, NOW()),
('2025-04-12','BEHAVIOR','active_level','Medium Active',   TO_BITMAP(10005)|TO_BITMAP(10008)|TO_BITMAP(10010), 3, NOW()),
('2025-04-12','BEHAVIOR','active_level','Low Active',   TO_BITMAP(10003)|TO_BITMAP(10006)|TO_BITMAP(10007), 3, NOW()),
-- Lifecycle
('2025-04-12','LIFECYCLE','lifecycle_stage','New Customer',       TO_BITMAP(10004)|TO_BITMAP(10009), 2, NOW()),
('2025-04-12','LIFECYCLE','lifecycle_stage','Growth',       TO_BITMAP(10002)|TO_BITMAP(10008), 2, NOW()),
('2025-04-12','LIFECYCLE','lifecycle_stage','Mature',       TO_BITMAP(10001)|TO_BITMAP(10005)|TO_BITMAP(10010), 3, NOW()),
('2025-04-12','LIFECYCLE','lifecycle_stage','Dormant',       TO_BITMAP(10003)|TO_BITMAP(10007), 2, NOW()),
('2025-04-12','LIFECYCLE','lifecycle_stage','Churn Risk',   TO_BITMAP(10006), 1, NOW()),
-- Preferred Channel
('2025-04-12','CHANNEL','preferred_channel','APP',        TO_BITMAP(10001)|TO_BITMAP(10002)|TO_BITMAP(10005)|TO_BITMAP(10009), 4, NOW()),
('2025-04-12','CHANNEL','preferred_channel','Branch',       TO_BITMAP(10003)|TO_BITMAP(10007)|TO_BITMAP(10010), 3, NOW()),
('2025-04-12','CHANNEL','preferred_channel','Mini Program',     TO_BITMAP(10004), 1, NOW()),
('2025-04-12','CHANNEL','preferred_channel','Online Banking',       TO_BITMAP(10006)|TO_BITMAP(10008), 2, NOW()),
-- Anomaly Flag
('2025-04-12','RISK','anomaly_flag','1',           TO_BITMAP(10003)|TO_BITMAP(10007), 2, NOW());

-- ================================================================
-- Mock data - user behavior
-- ================================================================
INSERT INTO user_behavior (event_id, user_id, event_date, event_time, event_type, event_category,
    channel, product_code, amount, result_code, session_id, device_type)
VALUES
(1001,10001,'2025-04-12','2025-04-12 09:15:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s001','iOS'),
(1002,10001,'2025-04-12','2025-04-12 09:16:00','BROWSE_PRODUCT','BROWSE','APP','FUND_001',0,'SUCCESS','s001','iOS'),
(1003,10001,'2025-04-12','2025-04-12 09:20:00','TRANSACTION','TRANSACTION','APP','FUND_001',50000,'SUCCESS','s001','iOS'),
(1004,10002,'2025-04-12','2025-04-12 10:00:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s002','Android'),
(1005,10002,'2025-04-12','2025-04-12 10:05:00','TRANSACTION','TRANSACTION','APP','WM_002',100000,'SUCCESS','s002','Android'),
(1006,10003,'2025-04-11','2025-04-11 14:00:00','LOGIN','LOGIN','Branch','',0,'SUCCESS','s003','PC'),
(1007,10004,'2025-04-12','2025-04-12 11:00:00','REGISTER','REGISTER','Mini Program','',0,'SUCCESS','s004','Android'),
(1008,10004,'2025-04-12','2025-04-12 11:05:00','LOGIN','LOGIN','Mini Program','',0,'SUCCESS','s004','Android'),
(1009,10004,'2025-04-12','2025-04-12 11:10:00','BROWSE_PRODUCT','BROWSE','Mini Program','LOAN_003',0,'SUCCESS','s004','Android'),
(1010,10005,'2025-04-12','2025-04-12 08:30:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s005','iOS'),
(1011,10005,'2025-04-12','2025-04-12 08:35:00','BROWSE_PRODUCT','BROWSE','APP','INS_001',0,'SUCCESS','s005','iOS'),
(1012,10001,'2025-04-11','2025-04-11 15:00:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s006','iOS'),
(1013,10001,'2025-04-11','2025-04-11 15:05:00','TRANSACTION','TRANSACTION','APP','FUND_002',30000,'SUCCESS','s006','iOS'),
(1014,10002,'2025-04-11','2025-04-11 16:00:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s007','Android'),
(1015,10002,'2025-04-11','2025-04-11 16:30:00','APPLY','APPLY','APP','LOAN_001',0,'SUCCESS','s007','Android'),
(1016,10008,'2025-04-12','2025-04-12 09:00:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s008','Android'),
(1017,10009,'2025-04-12','2025-04-12 10:30:00','REGISTER','REGISTER','APP','',0,'SUCCESS','s009','iOS'),
(1018,10009,'2025-04-12','2025-04-12 10:35:00','LOGIN','LOGIN','APP','',0,'SUCCESS','s009','iOS'),
(1019,10009,'2025-04-12','2025-04-12 10:40:00','BROWSE_PRODUCT','BROWSE','APP','FUND_003',0,'SUCCESS','s009','iOS'),
(1020,10009,'2025-04-12','2025-04-12 10:45:00','APPLY','APPLY','APP','FUND_003',0,'SUCCESS','s009','iOS'),
(1021,10009,'2025-04-12','2025-04-12 10:50:00','TRANSACTION','TRANSACTION','APP','FUND_003',20000,'SUCCESS','s009','iOS');

-- ================================================================
-- Mock data - logs
-- ================================================================
INSERT INTO user_log_raw (log_id, log_date, log_time, user_id, session_id, log_level,
    log_source, log_content, operation_type, ip_address, user_region, created_at)
VALUES
(9001,'2025-04-12','2025-04-12 09:15:00',10001,'s001','INFO','APP',
 'user_id=10001 action=LOGIN device=iOS ip=1.2.3.4 result=SUCCESS','LOGIN','1.2.3.4','Beijing',NOW()),

(9002,'2025-04-12','2025-04-12 09:20:00',10001,'s001','INFO','APP',
 'user_id=10001 action=TRANSFER amount=50000 to_account=6217****1234 result=SUCCESS','TRANSFER','1.2.3.4','Beijing',NOW()),

(9003,'2025-04-12','2025-04-12 10:00:00',10002,'s002','INFO','APP',
 'user_id=10002 action=LOGIN device=Android ip=5.6.7.8 result=SUCCESS','LOGIN','5.6.7.8','Shanghai',NOW()),

(9004,'2025-04-12','2025-04-12 14:00:00',10003,'s003','WARN','CORE_BANK',
 'user_id=10003 action=LOGIN ip=221.1.2.3 region=Guangzhou device=PC Remote login detected: historical_region=Guangzhou current_ip_region=Heilongjiang','LOGIN','221.1.2.3','Heilongjiang',NOW()),

(9005,'2025-04-12','2025-04-12 14:05:00',10003,'s003','WARN','CORE_BANK',
 'user_id=10003 action=TRANSFER amount=800000 to_account=9988****5678 Large transfer alert, risk control review triggered','TRANSFER','221.1.2.3','Heilongjiang',NOW()),

(9006,'2025-04-12','2025-04-12 11:00:00',10004,'s004','INFO','Mini Program',
 'user_id=10004 action=REGISTER channel=Mini Program referral=Campaign A','LOGIN','10.1.1.1','Hangzhou',NOW()),

(9007,'2025-04-12','2025-04-12 11:10:00',10004,'s004','INFO','Mini Program',
 'user_id=10004 action=QUERY product=Loan Product amount_range=100k-500k','QUERY','10.1.1.1','Hangzhou',NOW()),

(9008,'2025-04-12','2025-04-12 08:30:00',10005,'s005','INFO','APP',
 'user_id=10005 action=LOGIN device=iOS result=SUCCESS','LOGIN','20.3.4.5','Chengdu',NOW()),

(9009,'2025-04-12','2025-04-12 22:00:00',10007,'s010','ERROR','CORE_BANK',
 'user_id=10007 action=TRANSFER amount=500000 Frequent operation alert: fifth transfer within 30 minutes, blocked by risk control','TRANSFER','110.2.3.4','Xian',NOW()),

(9010,'2025-04-12','2025-04-12 09:00:00',10008,'s008','INFO','APP',
 'user_id=10008 action=LOGIN action=BROWSE_PRODUCT product=Wealth Product result=SUCCESS','LOGIN','30.4.5.6','Tianjin',NOW());

-- ================================================================
-- Mock data - AI log tags
-- ================================================================
INSERT INTO user_log_tag (log_id, log_date, user_id, log_time, log_type, intent_tag,
    anomaly_tag, risk_level, ai_raw_result, tag_source, created_at)
VALUES
(9001,'2025-04-12',10001,'2025-04-12 09:15:00','Login Log','Account Setting','Normal','Low Risk',
 '{"log_type":"Login Log","intent":"Account Setting","anomaly_type":"Normal","risk_score":0.05}','PYTHON_API',NOW()),

(9002,'2025-04-12',10001,'2025-04-12 09:20:00','Transfer Log','Transfer','Normal','Low Risk',
 '{"log_type":"Transfer Log","intent":"Transfer","anomaly_type":"Normal","risk_score":0.1}','PYTHON_API',NOW()),

(9003,'2025-04-12',10002,'2025-04-12 10:00:00','Login Log','Account Setting','Normal','Low Risk',
 '{"log_type":"Login Log","intent":"Account Setting","anomaly_type":"Normal","risk_score":0.05}','PYTHON_API',NOW()),

(9004,'2025-04-12',10003,'2025-04-12 14:00:00','Anomaly Log','Account Setting','Remote Login','High Risk',
 '{"log_type":"Anomaly Log","intent":"Account Setting","anomaly_type":"Remote Login","risk_score":0.88}','PYTHON_API',NOW()),

(9005,'2025-04-12',10003,'2025-04-12 14:05:00','Transaction Log','Transfer','Large Transfer','High Risk',
 '{"log_type":"Transaction Log","intent":"Transfer","anomaly_type":"Large Transfer","risk_score":0.92}','PYTHON_API',NOW()),

(9006,'2025-04-12',10004,'2025-04-12 11:00:00','Login Log','Account Setting','Normal','Low Risk',
 '{"log_type":"Login Log","intent":"Account Setting","anomaly_type":"Normal","risk_score":0.05}','PYTHON_API',NOW()),

(9007,'2025-04-12',10004,'2025-04-12 11:10:00','Query Log','Loan Application','Normal','Low Risk',
 '{"log_type":"Query Log","intent":"Loan Application","anomaly_type":"Normal","risk_score":0.08}','PYTHON_API',NOW()),

(9008,'2025-04-12',10005,'2025-04-12 08:30:00','Login Log','Account Setting','Normal','Low Risk',
 '{"log_type":"Login Log","intent":"Account Setting","anomaly_type":"Normal","risk_score":0.03}','PYTHON_API',NOW()),

(9009,'2025-04-12',10007,'2025-04-12 22:00:00','Anomaly Log','Transfer','Frequent Operation','High Risk',
 '{"log_type":"Anomaly Log","intent":"Transfer","anomaly_type":"Frequent Operation","risk_score":0.95}','PYTHON_API',NOW()),

(9010,'2025-04-12',10008,'2025-04-12 09:00:00','Login Log','Buy Wealth Product','Normal','Low Risk',
 '{"log_type":"Login Log","intent":"Buy Wealth Product","anomaly_type":"Normal","risk_score":0.06}','PYTHON_API',NOW());

-- ================================================================
-- Mock data - tag dictionary
-- ================================================================
INSERT INTO tag_dict (tag_id, tag_category, tag_name, tag_label, tag_desc, value_type,
    value_options, source_table, source_field, is_ai_tag, enable_bitmap, status, sort_order, created_at)
VALUES
(1,'ASSET','asset_level','Asset Level','Customer AUM tier classification','ENUM',
 '["Private Banking","Diamond","Platinum","Gold","Standard"]','user_wide','asset_level',0,1,1,1,NOW()),
(2,'BEHAVIOR','active_level','Activity Level','Customer app activity level','ENUM',
 '["High Active","Medium Active","Low Active","Dormant"]','user_wide','active_level',0,1,1,2,NOW()),
(3,'LIFECYCLE','lifecycle_stage','Lifecycle','Customer lifecycle stage','ENUM',
 '["New Customer","Growth","Mature","Dormant","Churn Risk"]','user_wide','lifecycle_stage',0,1,1,3,NOW()),
(4,'CHANNEL','preferred_channel','Preferred Channel','Most used service channel','ENUM',
 '["APP","Branch","Mini Program","Online Banking"]','user_wide','preferred_channel',0,1,1,4,NOW()),
(5,'RISK','anomaly_flag','Anomaly Flag','Whether abnormal behavior exists','BOOLEAN',
 '["0","1"]','user_wide','anomaly_flag',0,1,1,5,NOW()),
(6,'LOG_AI','log_type','Log Type','Log operation type identified by AI','ENUM',
 '["Login Log","Transaction Log","Query Log","Transfer Log","Anomaly Log"]','user_log_tag','log_type',1,0,1,6,NOW()),
(7,'LOG_AI','intent_tag','Intent','User operation intent identified by AI','ENUM',
 '["Balance Inquiry","Transfer","Buy Wealth Product","Loan Application","Account Setting","Other"]','user_log_tag','intent_tag',1,0,1,7,NOW()),
(8,'LOG_AI','anomaly_tag','Anomaly Tag','Anomaly type identified by AI','ENUM',
 '["Normal","Remote Login","Large Transfer","Frequent Operation","Suspicious Account"]','user_log_tag','anomaly_tag',1,1,1,8,NOW()),
(9,'LOG_AI','risk_level','Risk Level','Risk level evaluated by AI','ENUM',
 '["Low Risk","Medium Risk","High Risk"]','user_log_tag','risk_level',1,1,1,9,NOW());


-- ================================================================
-- Dashboard / management overview mock data
-- ================================================================
USE bank_cdp;

INSERT INTO biz_metrics VALUES
('2024-04-01', 'Revenue', 85000000, 12.5, 3.2, 80000000, CURRENT_TIMESTAMP),
('2024-04-02', 'Revenue', 87500000, 13.1, 2.9, 80000000, CURRENT_TIMESTAMP),
('2024-04-03', 'Revenue', 89200000, 14.2, 1.9, 80000000, CURRENT_TIMESTAMP),
('2024-04-04', 'Revenue', 91100000, 15.3, 2.1, 80000000, CURRENT_TIMESTAMP),
('2024-04-05', 'Revenue', 93500000, 16.8, 2.6, 80000000, CURRENT_TIMESTAMP),
('2024-04-01', 'Cost', 32000000, -2.1, 1.5, 30000000, CURRENT_TIMESTAMP),
('2024-04-02', 'Cost', 31800000, -1.9, -0.6, 30000000, CURRENT_TIMESTAMP),
('2024-04-03', 'Cost', 31500000, -2.3, -0.9, 30000000, CURRENT_TIMESTAMP),
('2024-04-04', 'Cost', 31200000, -2.5, -0.9, 30000000, CURRENT_TIMESTAMP),
('2024-04-05', 'Cost', 31000000, -2.8, -0.6, 30000000, CURRENT_TIMESTAMP),
('2024-04-01', 'Profit', 53000000, 21.2, 4.8, 50000000, CURRENT_TIMESTAMP),
('2024-04-02', 'Profit', 55700000, 23.5, 5.1, 50000000, CURRENT_TIMESTAMP),
('2024-04-03', 'Profit', 57700000, 25.1, 3.6, 50000000, CURRENT_TIMESTAMP),
('2024-04-04', 'Profit', 59900000, 27.8, 3.8, 50000000, CURRENT_TIMESTAMP),
('2024-04-05', 'Profit', 62500000, 29.6, 4.3, 50000000, CURRENT_TIMESTAMP);

-- AUM data
INSERT INTO aum_metrics VALUES
('2024-04-01', 'Equity Fund', 12500000000, 45000, 277777.78, 500000000, 18.5, CURRENT_TIMESTAMP),
('2024-04-02', 'Equity Fund', 12800000000, 46200, 277099.00, 300000000, 19.2, CURRENT_TIMESTAMP),
('2024-04-03', 'Equity Fund', 13100000000, 47500, 275789.47, 300000000, 19.8, CURRENT_TIMESTAMP),
('2024-04-04', 'Equity Fund', 13450000000, 49000, 274489.80, 350000000, 20.5, CURRENT_TIMESTAMP),
('2024-04-05', 'Equity Fund', 13800000000, 50500, 273267.33, 350000000, 21.2, CURRENT_TIMESTAMP),
('2024-04-01', 'Bond Fund', 8300000000, 28000, 296428.57, 200000000, 8.5, CURRENT_TIMESTAMP),
('2024-04-02', 'Bond Fund', 8450000000, 28500, 296491.23, 150000000, 9.1, CURRENT_TIMESTAMP),
('2024-04-03', 'Bond Fund', 8600000000, 29000, 296551.72, 150000000, 9.7, CURRENT_TIMESTAMP),
('2024-04-04', 'Bond Fund', 8750000000, 29500, 296610.17, 150000000, 10.2, CURRENT_TIMESTAMP),
('2024-04-05', 'Bond Fund', 8900000000, 30000, 296666.67, 150000000, 10.8, CURRENT_TIMESTAMP),
('2024-04-01', 'Money Market Fund', 5200000000, 52000, 100000, 100000000, 3.2, CURRENT_TIMESTAMP),
('2024-04-02', 'Money Market Fund', 5350000000, 53500, 100000, 150000000, 3.8, CURRENT_TIMESTAMP),
('2024-04-03', 'Money Market Fund', 5500000000, 55000, 100000, 150000000, 4.5, CURRENT_TIMESTAMP),
('2024-04-04', 'Money Market Fund', 5650000000, 56500, 100000, 150000000, 5.1, CURRENT_TIMESTAMP),
('2024-04-05', 'Money Market Fund', 5800000000, 58000, 100000, 150000000, 5.7, CURRENT_TIMESTAMP),
('2024-04-01', 'Mixed Fund', 7100000000, 32000, 221875, 300000000, 12.5, CURRENT_TIMESTAMP),
('2024-04-02', 'Mixed Fund', 7250000000, 33000, 219696.97, 150000000, 13.2, CURRENT_TIMESTAMP),
('2024-04-03', 'Mixed Fund', 7400000000, 34000, 217647.06, 150000000, 13.9, CURRENT_TIMESTAMP),
('2024-04-04', 'Mixed Fund', 7550000000, 35000, 215714.29, 150000000, 14.6, CURRENT_TIMESTAMP),
('2024-04-05', 'Mixed Fund', 7700000000, 36000, 213888.89, 150000000, 15.3, CURRENT_TIMESTAMP);

-- Risk metric data
INSERT INTO risk_metrics VALUES
('2024-04-01', 'Low', 5000000000, 15, 0.0008, 185.5, 250000000, CURRENT_TIMESTAMP),
('2024-04-02', 'Low', 4950000000, 14, 0.0007, 187.2, 240000000, CURRENT_TIMESTAMP),
('2024-04-03', 'Low', 4900000000, 13, 0.0006, 189.1, 230000000, CURRENT_TIMESTAMP),
('2024-04-04', 'Low', 4850000000, 12, 0.0005, 191.3, 220000000, CURRENT_TIMESTAMP),
('2024-04-05', 'Low', 4800000000, 11, 0.0004, 193.5, 210000000, CURRENT_TIMESTAMP),
('2024-04-01', 'Medium', 8200000000, 35, 0.0018, 125.8, 650000000, CURRENT_TIMESTAMP),
('2024-04-02', 'Medium', 8150000000, 34, 0.0017, 127.2, 640000000, CURRENT_TIMESTAMP),
('2024-04-03', 'Medium', 8100000000, 33, 0.0016, 128.5, 630000000, CURRENT_TIMESTAMP),
('2024-04-04', 'Medium', 8050000000, 32, 0.0016, 129.8, 620000000, CURRENT_TIMESTAMP),
('2024-04-05', 'Medium', 8000000000, 31, 0.0015, 131.2, 610000000, CURRENT_TIMESTAMP),
('2024-04-01', 'High', 2800000000, 42, 0.0095, 75.2, 480000000, CURRENT_TIMESTAMP),
('2024-04-02', 'High', 2750000000, 40, 0.0091, 76.5, 470000000, CURRENT_TIMESTAMP),
('2024-04-03', 'High', 2700000000, 38, 0.0088, 77.8, 460000000, CURRENT_TIMESTAMP),
('2024-04-04', 'High', 2650000000, 36, 0.0085, 79.2, 450000000, CURRENT_TIMESTAMP),
('2024-04-05', 'High', 2600000000, 34, 0.0082, 80.5, 440000000, CURRENT_TIMESTAMP);

-- Position metric data
INSERT INTO position_metrics VALUES
('2024-04-01', 'Stock', 8500000000, 35.2, 8650000000, 150000000, 1.76, CURRENT_TIMESTAMP),
('2024-04-02', 'Stock', 8600000000, 35.5, 8780000000, 180000000, 2.09, CURRENT_TIMESTAMP),
('2024-04-03', 'Stock', 8700000000, 35.8, 8920000000, 220000000, 2.53, CURRENT_TIMESTAMP),
('2024-04-04', 'Stock', 8800000000, 36.1, 9060000000, 260000000, 2.95, CURRENT_TIMESTAMP),
('2024-04-05', 'Stock', 8900000000, 36.4, 9200000000, 300000000, 3.37, CURRENT_TIMESTAMP),
('2024-04-01', 'Bond', 9200000000, 38.1, 9150000000, -50000000, -0.55, CURRENT_TIMESTAMP),
('2024-04-02', 'Bond', 9300000000, 38.3, 9270000000, -30000000, -0.32, CURRENT_TIMESTAMP),
('2024-04-03', 'Bond', 9400000000, 38.6, 9390000000, -10000000, -0.11, CURRENT_TIMESTAMP),
('2024-04-04', 'Bond', 9500000000, 38.9, 9500000000, 0, 0.00, CURRENT_TIMESTAMP),
('2024-04-05', 'Bond', 9600000000, 39.2, 9620000000, 20000000, 0.21, CURRENT_TIMESTAMP),
('2024-04-01', 'Derivative', 3800000000, 15.7, 3850000000, 50000000, 1.32, CURRENT_TIMESTAMP),
('2024-04-02', 'Derivative', 3750000000, 15.4, 3820000000, 70000000, 1.87, CURRENT_TIMESTAMP),
('2024-04-03', 'Derivative', 3700000000, 15.2, 3780000000, 80000000, 2.16, CURRENT_TIMESTAMP),
('2024-04-04', 'Derivative', 3650000000, 14.9, 3740000000, 90000000, 2.47, CURRENT_TIMESTAMP),
('2024-04-05', 'Derivative', 3600000000, 14.7, 3700000000, 100000000, 2.78, CURRENT_TIMESTAMP),
('2024-04-01', 'Cash', 2200000000, 10.9, 2200000000, 0, 0.00, CURRENT_TIMESTAMP),
('2024-04-02', 'Cash', 2180000000, 9.8, 2180000000, 0, 0.00, CURRENT_TIMESTAMP),
('2024-04-03', 'Cash', 2160000000, 8.9, 2160000000, 0, 0.00, CURRENT_TIMESTAMP),
('2024-04-04', 'Cash', 2140000000, 8.8, 2140000000, 0, 0.00, CURRENT_TIMESTAMP),
('2024-04-05', 'Cash', 2120000000, 8.7, 2120000000, 0, 0.00, CURRENT_TIMESTAMP);

-- Product marketing data
INSERT INTO product_marketing VALUES
('2024-04-01', 'Stable Growth Fund A', 'Mixed Fund', 15000000, 180, 92.5, 45, 78.5, 4.8, CURRENT_TIMESTAMP),
('2024-04-02', 'Stable Growth Fund A', 'Mixed Fund', 16200000, 195, 93.2, 52, 79.1, 4.8, CURRENT_TIMESTAMP),
('2024-04-03', 'Stable Growth Fund A', 'Mixed Fund', 17500000, 210, 93.8, 58, 79.6, 4.9, CURRENT_TIMESTAMP),
('2024-04-04', 'Stable Growth Fund A', 'Mixed Fund', 18900000, 228, 94.3, 65, 80.1, 4.9, CURRENT_TIMESTAMP),
('2024-04-05', 'Stable Growth Fund A', 'Mixed Fund', 20500000, 246, 94.8, 72, 80.6, 4.9, CURRENT_TIMESTAMP),
('2024-04-01', 'Innovation Growth Fund B', 'Equity Fund', 25800000, 280, 88.5, 65, 72.3, 4.6, CURRENT_TIMESTAMP),
('2024-04-02', 'Innovation Growth Fund B', 'Equity Fund', 27500000, 298, 89.1, 72, 73.1, 4.7, CURRENT_TIMESTAMP),
('2024-04-03', 'Innovation Growth Fund B', 'Equity Fund', 29500000, 318, 89.7, 80, 73.8, 4.7, CURRENT_TIMESTAMP),
('2024-04-04', 'Innovation Growth Fund B', 'Equity Fund', 31800000, 340, 90.2, 88, 74.5, 4.7, CURRENT_TIMESTAMP),
('2024-04-05', 'Innovation Growth Fund B', 'Equity Fund', 34200000, 365, 90.8, 97, 75.2, 4.8, CURRENT_TIMESTAMP),
('2024-04-01', 'Fixed Income Fund C', 'Bond Fund', 12500000, 420, 95.8, 28, 85.2, 4.9, CURRENT_TIMESTAMP),
('2024-04-02', 'Fixed Income Fund C', 'Bond Fund', 13200000, 445, 96.1, 32, 85.6, 4.9, CURRENT_TIMESTAMP),
('2024-04-03', 'Fixed Income Fund C', 'Bond Fund', 14000000, 470, 96.4, 36, 86.0, 4.9, CURRENT_TIMESTAMP),
('2024-04-04', 'Fixed Income Fund C', 'Bond Fund', 14900000, 496, 96.7, 40, 86.3, 4.9, CURRENT_TIMESTAMP),
('2024-04-05', 'Fixed Income Fund C', 'Bond Fund', 15800000, 525, 97.0, 44, 86.7, 5.0, CURRENT_TIMESTAMP),
('2024-04-01', 'High Liquidity Money Fund D', 'Money Market Fund', 8500000, 850, 97.5, 15, 92.1, 4.8, CURRENT_TIMESTAMP),
('2024-04-02', 'High Liquidity Money Fund D', 'Money Market Fund', 9200000, 920, 97.8, 18, 92.5, 4.8, CURRENT_TIMESTAMP),
('2024-04-03', 'High Liquidity Money Fund D', 'Money Market Fund', 10000000, 1000, 98.0, 22, 92.8, 4.8, CURRENT_TIMESTAMP),
('2024-04-04', 'High Liquidity Money Fund D', 'Money Market Fund', 10900000, 1090, 98.2, 26, 93.1, 4.9, CURRENT_TIMESTAMP),
('2024-04-05', 'High Liquidity Money Fund D', 'Money Market Fund', 11800000, 1180, 98.4, 30, 93.4, 4.9, CURRENT_TIMESTAMP);

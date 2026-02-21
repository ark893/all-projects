use etl_fraud.public;
-- Looking at the number of rows that we've flagged, here is a weighting logic - creation assisted by ChatGPT

-- High value → 2
-- Z-score anomaly → 2
-- Velocity → 3 (strong signal)
-- Login risk → 1
-- Balance drain → 2

-- Max Score = 10

-- new view - v_fraud_scored - this scores the flagged transactions based on flags. 


CREATE OR REPLACE VIEW v_fraud_scored AS
SELECT
    *,
    
    (
        high_value_flag * 2 +
        zscore_flag * 2 +
        velocity_flag * 3 +
        login_flag * 1 +
        balance_flag * 2
    ) AS risk_score,

    CASE
        WHEN (
            high_value_flag * 2 +
            zscore_flag * 2 +
            velocity_flag * 3 +
            login_flag * 1 +
            balance_flag * 2
        ) >= 4 THEN 'HIGH'
        
        WHEN (
            high_value_flag * 2 +
            zscore_flag * 2 +
            velocity_flag * 3 +
            login_flag * 1 +
            balance_flag * 2
        ) >= 2 THEN 'MEDIUM'
        
        ELSE 'LOW'
    END AS risk_level

FROM v_fraud_features;

SELECT risk_level, COUNT(*)
FROM v_fraud_scored
GROUP BY 1
ORDER BY 1;
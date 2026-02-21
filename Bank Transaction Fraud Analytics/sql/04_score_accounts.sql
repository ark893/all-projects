use etl_fraud.public;

-- New view - v_account_risk - scores total risk by account. Aggregates all flagged transactions

CREATE OR REPLACE VIEW v_account_risk AS
SELECT
    AccountID,
    
    COUNT(*) AS total_transactions,
    
    SUM(risk_score) AS total_risk_score,
    
    MAX(risk_score) AS max_transaction_risk,
    
    COUNT_IF(risk_level = 'HIGH') AS high_risk_transactions,
    
    COUNT_IF(risk_level = 'MEDIUM') AS medium_risk_transactions,
    
    ROUND(AVG(risk_score), 2) AS avg_risk_score

FROM v_fraud_scored
GROUP BY AccountID;


SELECT *
FROM v_account_risk
ORDER BY total_risk_score DESC
LIMIT 10;

-- New view - v_flagged_account - flag accounts based on their risk score

CREATE OR REPLACE VIEW v_flagged_accounts AS
SELECT
    *,
    
    CASE
        WHEN total_risk_score >= 6
          OR high_risk_transactions >= 2
        THEN 1
        ELSE 0
    END AS account_flagged

FROM v_account_risk;

SELECT COUNT(*)
FROM v_flagged_accounts
WHERE account_flagged = 1;
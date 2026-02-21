use etl_fraud.public;

-- See risk distribution
SELECT risk_level, COUNT(*)
FROM fact_transactions
GROUP BY 1;

-- See top suspicious accounts
SELECT *
FROM fact_account_risk
WHERE account_flagged = 1
ORDER BY total_risk_score DESC
LIMIT 10;

-- Fraud trend over time
SELECT
    DATE_TRUNC('day', TransactionTimestamp) AS txn_day,
    COUNT_IF(risk_level = 'HIGH') AS high_risk_txns
FROM fact_transactions
WHERE RISK_LEVEL = 'HIGH'
GROUP BY 1
ORDER BY 1;

-- Channel risk breakdown
SELECT
    Channel,
    COUNT_IF(risk_level = 'HIGH') AS high_risk_count
FROM fact_transactions
GROUP BY 1
ORDER BY 2 DESC;
 
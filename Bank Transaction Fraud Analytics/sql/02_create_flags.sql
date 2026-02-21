use etl_fraud.public;

-- Version 1 of x; Showcase percentile values. 
CREATE OR REPLACE VIEW v_fraud_features AS
WITH base AS(
    SELECT
        *,
        PERCENTILE_CONT(0.95)
            WITHIN GROUP (ORDER BY TransactionAmount)
            OVER () AS p95
    FROM stg_transactions
)
SELECT
    *,
    CASE 
        WHEN TransactionAmount > p95 THEN 1
        ELSE 0
    END AS high_value_flag

FROM base; 

SELECT high_value_flag, COUNT(*)
FROM v_fraud_features
GROUP BY 1;

-- Verion 2 of x; Account-Level Amount Anomal using Z Score. 
-- If Abs(Z) > 2, flag transactions.
--  Keep all existing columns we created in base, add more moving forward
CREATE OR REPLACE VIEW v_fraud_features AS
WITH base AS (
    SELECT
        *,
        
        AVG(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS avg_amt,
            
        STDDEV(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS std_amt,
            
        PERCENTILE_CONT(0.95)
            WITHIN GROUP (ORDER BY TransactionAmount)
            OVER () AS p95

    FROM stg_transactions
)

SELECT
    *,
    
    CASE 
        WHEN TransactionAmount > p95 THEN 1
        ELSE 0
    END AS high_value_flag,

    CASE 
        WHEN std_amt > 0 
         AND ABS((TransactionAmount - avg_amt) / std_amt) > 2
        THEN 1
        ELSE 0
    END AS zscore_flag

FROM base;

SELECT zscore_flag, COUNT(*)
FROM v_fraud_features
GROUP BY 1;

-- Verion 3 of x; Add detection for same account making transactions within 5 minutes
CREATE OR REPLACE VIEW v_fraud_features AS
WITH base AS (
    SELECT
        *,
        
        AVG(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS avg_amt,
            
        STDDEV(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS std_amt,
            
        PERCENTILE_CONT(0.95)
            WITHIN GROUP (ORDER BY TransactionAmount)
            OVER () AS p95,

        LAG(TransactionTimestamp)
            OVER (PARTITION BY AccountID 
                  ORDER BY TransactionTimestamp) AS prev_txn_time

    FROM stg_transactions
)

SELECT
    *,

    CASE 
        WHEN TransactionAmount > p95 THEN 1
        ELSE 0
    END AS high_value_flag,

    CASE 
        WHEN std_amt > 0 
         AND ABS((TransactionAmount - avg_amt) / std_amt) > 2
        THEN 1
        ELSE 0
    END AS zscore_flag,

    CASE
        WHEN prev_txn_time IS NOT NULL
         AND DATEDIFF(
                minute,
                prev_txn_time,
                TransactionTimestamp
            ) <= 5
        THEN 1
        ELSE 0
    END AS velocity_flag

FROM base;

SELECT velocity_flag, COUNT(*)
FROM v_fraud_features
GROUP BY 1;

use etl_fraud.public;

-- Version 4 of x; Adding login risk and balance drain flags.
-- Login risk threshold is >=3
-- Balance drain threshold is 70% of account balance. 
CREATE OR REPLACE VIEW v_fraud_features AS
WITH base AS (
    SELECT
        *,
        
        AVG(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS avg_amt,
            
        STDDEV(TransactionAmount) 
            OVER (PARTITION BY AccountID) AS std_amt,
            
        PERCENTILE_CONT(0.95)
            WITHIN GROUP (ORDER BY TransactionAmount)
            OVER () AS p95,

        LAG(TransactionTimestamp)
            OVER (PARTITION BY AccountID 
                  ORDER BY TransactionTimestamp) AS prev_txn_time

    FROM stg_transactions
)

SELECT
    *,

    /* High Value */
    CASE 
        WHEN TransactionAmount > p95 THEN 1
        ELSE 0
    END AS high_value_flag,

    /* Account Z-score */
    CASE 
        WHEN std_amt > 0 
         AND ABS((TransactionAmount - avg_amt) / std_amt) > 2
        THEN 1
        ELSE 0
    END AS zscore_flag,

    /* Velocity */
    CASE
        WHEN prev_txn_time IS NOT NULL
         AND DATEDIFF(
                minute,
                prev_txn_time,
                TransactionTimestamp
            ) <= 5
        THEN 1
        ELSE 0
    END AS velocity_flag,

    /* Login Risk */
    CASE
        WHEN LoginAttempts >= 3 THEN 1
        ELSE 0
    END AS login_flag,

    /* Balance Drain */
    CASE
        WHEN AccountBalance > 0
         AND TransactionAmount / AccountBalance >= 0.7
        THEN 1
        ELSE 0
    END AS balance_flag

FROM base;

SELECT balance_flag, COUNT(*)
FROM v_fraud_features
GROUP BY 1
ORDER BY 1;

-- Sanity Check
SELECT
    SUM(high_value_flag) AS high_value_count,
    SUM(zscore_flag) AS zscore_count,
    SUM(velocity_flag) AS velocity_count,
    SUM(login_flag) AS login_count,
    SUM(balance_flag) AS balance_count
FROM v_fraud_features;
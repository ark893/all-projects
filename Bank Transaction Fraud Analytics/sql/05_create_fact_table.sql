use etl_fraud.public;

CREATE OR REPLACE TABLE fact_transactions AS
SELECT *
FROM v_fraud_scored;

ALTER TABLE fact_transactions
CLUSTER BY (AccountID, TransactionTimestamp);

CREATE OR REPLACE TABLE fact_account_risk AS
SELECT *
FROM v_flagged_accounts;
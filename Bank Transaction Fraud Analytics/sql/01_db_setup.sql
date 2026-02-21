use ETL_FRAUD.PUBLIC;

CREATE OR REPLACE TABLE stg_transactions AS
SELECT
    TransactionID,
    AccountID,
    TransactionAmount,
    
    -- Convert string to timestamp
    TO_TIMESTAMP(TransactionDate) AS TransactionTimestamp,
    
    TransactionType,
    Location,
    DeviceID,
    IPAddress,
    MerchantID,
    Channel,
    CustomerAge,
    CustomerOccupation,
    TransactionDuration,
    LoginAttempts,
    AccountBalance,
    
    TO_TIMESTAMP(PreviousTransactionDate) AS PreviousTransactionTimestamp

FROM transactions;

desc table stg_transactions;
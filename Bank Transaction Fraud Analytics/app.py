import streamlit as st
import snowflake.connector
import pandas as pd
import os
from dotenv import load_dotenv
import plotly.express as px

load_dotenv()  # Load environment variables from .env file

# --- Snowflake Connection ---
@st.cache_resource
def get_connection():
    conn = snowflake.connector.connect(
        user=os.getenv('user'),
        password=os.getenv('password'),
        account=os.getenv('account'),
        warehouse=os.getenv('warehouse'),
        database=os.getenv('database'),
        schema=os.getenv('schema')
    )
    return conn

conn = get_connection()



# --- Helper function ---
def run_query(query):
    return pd.read_sql(query, conn)

st.title("Bank Transaction Fraud Analytics Dashboard")

# ------------------------------
# 1. Risk Distribution
# ------------------------------
st.header("Transaction Risk Distribution")

risk_df = run_query("""
SELECT risk_level, COUNT(*) as count
FROM fact_transactions
GROUP BY 1
""")

# st.bar_chart(risk_df.set_index("RISK_LEVEL"))
fig = px.bar(risk_df, x="RISK_LEVEL", y="COUNT", title="Risk Distribution")
st.plotly_chart(fig)

# ------------------------------
# 2. Top Suspicious Accounts
# ------------------------------
st.header("Top Suspicious Accounts")

top_accounts = run_query("""
SELECT *
FROM fact_account_risk
WHERE account_flagged = 1
ORDER BY total_risk_score DESC
LIMIT 10
""")

st.dataframe(top_accounts)

# ------------------------------
# 3. High-Risk Transactions Over Time
# ------------------------------
st.header("High-Risk Transactions Over Time")

trend_df = run_query("""
SELECT
    DATE_TRUNC('day', TransactionTimestamp) as txn_day,
    COUNT_IF(risk_level = 'HIGH') as high_risk_txns
FROM fact_transactions
GROUP BY 1
ORDER BY 1
""")

st.line_chart(trend_df.set_index("TXN_DAY"))


# ------------------------------
# 4. Channel Risk Breakdown
# ------------------------------
st.header("Channel Risk Breakdown")

channel_df = run_query("""
SELECT
    Channel,
    COUNT_IF(risk_level = 'HIGH') AS high_risk_count
FROM fact_transactions
GROUP BY 1
ORDER BY 2 DESC;
""")

# st.bar_chart(channel_df.set_index("CHANNEL"))
fig = px.bar(channel_df, x="CHANNEL", y="HIGH_RISK_COUNT", title="Channel Risk Breakdown")
st.plotly_chart(fig)
# Delivery Duration Prediction – Machine Learning Project

This project focuses on predicting the **total food delivery duration (in seconds)** using a real-world dataset by DoorDash, hosted on [StrataScratch – Delivery Duration Prediction](https://platform.stratascratch.com/data-projects/delivery-duration-prediction). The primary objective is to model delivery times based on various order, store, and market-level features.

---

## Problem Statement

Given historical data on food delivery orders, including timestamps, store categories, dasher availability, and item details, the goal is to predict:

> **Total delivery duration = Time from order submission (`created_at`) to delivery completion (`actual_delivery_time`)**

---

## Key Objectives

- Data preprocessing and feature engineering (target encoding, congestion ratios, time buckets, etc.)
- Model experimentation with XGBoost, LightGBM, Random Forest, SVR, and Linear Regression
- Ensemble methods: Bagging and Stacking (XGBoost + LightGBM)
- Model evaluation using RMSE, R², and learning curves
- Pipeline architecture with sklearn and visual diagnostics using matplotlib and seaborn

---

## Dataset

- Source: [StrataScratch – Delivery Duration Prediction](https://platform.stratascratch.com/data-projects/delivery-duration-prediction)
- Fields include:
  - `created_at`, `actual_delivery_time`, `store_primary_category`
  - `total_items`, `num_distinct_items`, `subtotal`
  - `estimated_order_place_duration`, `estimated_store_to_consumer_driving_duration`
  - `total_onshift_dashers`, `total_busy_dashers`, `total_outstanding_orders`

---

## Methods & Tools

### Data Processing
- Feature engineering: market congestion, item diversity, time-of-day buckets
- Target encoding for high-cardinality categorical features
- Handling missing values and creating imputation strategies

### Models Trained
- **Baseline Models**: Linear Regression, Decision Tree, SVR
- **Ensemble Models**: Random Forest, XGBoost, LightGBM
- **Meta-Ensemble**: Combines XGBoost + LightGBM with Ridge meta-learner; 

### Evaluation Metrics
- Root Mean Squared Error (RMSE)
- R² Score
- Learning Curves (bias-variance analysis)

---

## Results

Below, you can view the best results for each model used ->

| Model            | RMSE       | R² Score  |
|------------------|------------|-----------|
| DecisionTree     | 991.464586 | -0.465006 |
| RandomForest     | 843.963719 | -0.061530 |
| LinearRegression | 796.522598 | 0.054458  |
| SVR              | 794.844970 | 0.058436  |
| XGBoost          | 763.063333 | 0.132227  |
| Bagging_DT       | 762.478925 | 0.133556  |
| **LightGBM**         | **762.019672** | **0.134599**  |

> 🔎 *Best model: LightGBM, which has a significantly lower score when compared to Decision Trees.*

---

## Reflections

The goal with this project was to use only classical ML models to perform regression analysis, in an effort to compare their performance. When I started work on this, I expected there to be a massive gulf in performance between models such as Linear Regression (which only understood collinearity) and XGBoost and LightGBM (ones that understood non-collinear variables too). 

What I didn't expect would make a huge difference was feature engineering. Case in point, comparing how a dataset which used One Hot Encoding performed against one that used Frequency Encoding was an eye opener. While I knew that feature engineering is an important part of the process, the scale of difference that it made was astounding. 

That is how I came up with metrics such as "market_congestion" - a feature that takes into account the available dashers and the outstanding orders in a 10 mile radius - to reflect the order density in and around a restaurant. 

I also spent time checking how the "created_time" - the time at which an order was placed/created - could be sorted into buckets and what were the time stamps that most effectively reflected order timings. This, among many others

---

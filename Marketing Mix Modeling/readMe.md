# Bayesian Hierarchical Marketing Mix Modeling

## Overview
This project implements a Bayesian hierarchical regression model to quantify the impact of marketing channels on conversion performance across multiple campaign categories.

The model uses partial pooling to stabilize channel effect estimates across sparse segments while preserving campaign-level heterogeneity.

## Data
The dataset consists of ~130K daily observations across multiple eCommerce organizations, including:
- Paid media spend (Google, Meta, TikTok)
- Conversion outcomes (purchases)
- Campaign category metadata
- Organic demand controls

## Methodology
- Log-transformed conversion outcome
- Hierarchical priors on channel effects by campaign category
- Organization-level random intercepts
- MCMC inference using the NUTS sampler (PyMC)

## Model Structure
log(Purchases) = 
- Organization random intercept
- Campaign-level channel effects
- Organic demand controls
- Gaussian noise

## Key Results
- Meta exhibits the strongest and most consistent average impact
- Channel effectiveness varies substantially by campaign category
- Hierarchical shrinkage improves stability for sparse segments
- Credible intervals provide uncertainty-aware decision support

## Repository Structure
See `Bayesian_Hierarchical_Modelling.ipynb` for step-by-step analysis and `/Results` for final figures and tables.

## Reproducibility
The model was prototyped on a representative subsample and scales to the full dataset. All results can be reproduced using the provided notebooks and requirements file.

# Python & Jupyter Notebooks Practice Guide
## Interactive Simulation Suite for Ordinary Least Squares (OLS) Assumptions

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Path:** `examples_and_simulations/jupyter_notebooks/`

---

## Overview

This guide details the Python 3 Jupyter Notebooks available in our open-source practice repository. Each Gauss-Markov assumption has its own standalone, individually numbered simulation notebook alongside a comprehensive master practice suite.

---

## Available Standalone Notebooks

### 1. `assumption_0_unbiasedness_sampling_distribution.ipynb`
* **Focus Topic:** Gauss-Markov Unbiasedness ($E[\hat{\beta}] = \beta$) & Sampling Distributions
* **Simulations:** Simulates $N=1,000$ population ($Y = 1 + 2X + \epsilon$). Runs a 1,000-loop Monte Carlo sampling experiment drawing $n=30$ points without replacement and plots side-by-side histograms proving sample means converge to exact true parameters ($\beta_0=1, \beta_1=2$).

### 2. `assumption_1_linearity_in_parameters.ipynb`
* **Focus Topic:** Linearity in Parameters ($Y = X\beta + \epsilon$) & Polynomial Transformations
* **Simulations:** Simulates cubic curvature ($Y = -5 + 0.8X^3 + \epsilon$). Demonstrates naive linear underfitting, reveals S-shaped LOESS systematic curves in `Residuals vs Fitted` plots, and applies $X^3$ transformations to restore exact linearity in parameters.

### 3. `assumption_2_representative_sampling.ipynb`
* **Focus Topic:** Representative & Random Sampling from Population vs Selection Bias
* **Simulations:** Constructs a global population ($N=2,000$, true slope $+1.50$) with localized sub-group dynamics. Compares a **True Random Representative Sample ($n=30$)** against an **Unrepresentative Range-Truncated Sample ($n=30$)** to show how selection bias reverses slopes (-0.85 slope via Simpson's Paradox) and inflates standard errors over 5x.

### 4. `assumption_3_exogeneity_zero_conditional_mean.ipynb`
* **Focus Topic:** Exogeneity & Zero Conditional Mean of Errors ($E[\epsilon|X] = 0$)
* **Simulations:** Injects unobserved confounders ($Z = 0.8X + v$) to show how omitted variables force $E[\epsilon|X] \neq 0$, causing $+1.20$ upward slope bias. Runs Monte Carlo proofs showing asymptotic inconsistency persists even as sample size $N \to \infty$.

### 5. `assumption_4_homoscedasticity_vs_heteroscedasticity.ipynb`
* **Focus Topic:** Homoscedasticity ($\text{Var}(\epsilon_i) = \sigma^2$) vs Megaphone Heteroscedasticity
* **Simulations:** Simulates expanding "megaphone" error spread ($\sigma_i = 0.4X_i$). Proves $\hat{\beta}$ remains unbiased across 1,000 loops while standard errors shrink artificially. Implements White's `HC3` robust covariance matrix (`mod.get_robustcov_results(cov_type="HC3")`).

### 6. `assumption_5_outliers_leverage_cooks_distance.ipynb`
* **Focus Topic:** Error Normality & Small Sample Outlier Sensitivity ($n \le 30$)
* **Simulations:** Simulates $n=14$ clean points and appends a 15th extreme horizontal leverage point at $X=12, Y=-3$. Computes Cook's Distance ($D_i > 4/n$) bar charts and demonstrates how Robust M-Estimation (`sm.RLM` with Huber loss) resists outlier distortion.

### 7. `assumption_6_no_perfect_multicollinearity.ipynb`
* **Focus Topic:** No Perfect Multicollinearity & Singular Matrix Crash
* **Simulations:** Constructs exact linear duplicates ($X_2 = 1.5X_1$) triggering Python's `LinAlgError: Singular matrix` exception. Injects near-collinear noise ($r=0.999$) to compute Variance Inflation Factors (`VIF > 10`) and plot see-saw slope volatility across 100 simulations.

### 8. `master_all_assumptions_suite.ipynb` *(Master Practice Suite)*
* **Focus Topic:** Complete All-in-One Simulation Suite covering all 6 assumptions sequentially.

---

## Setup & Running Locally

1. Create a Python virtual environment inside your project workspace:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```
2. Install dependencies:
   ```bash
   pip install numpy pandas matplotlib seaborn statsmodels scipy jupyterlab
   ```
3. Launch Jupyter Lab:
   ```bash
   jupyter lab
   ```

# Python & Jupyter Notebooks Practice Guide
## Interactive Simulation Suite for Ordinary Least Squares (OLS) Assumptions

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Path:** `examples_and_simulations/jupyter_notebooks/`

---

## Overview

This guide details the Python 3 Jupyter Notebooks available in our open-source practice repository. Each notebook provides fully reproducible, step-by-step Monte Carlo simulations and diagnostic plotting workflows using `numpy`, `pandas`, `matplotlib`, `seaborn`, and `statsmodels`.

---

## Available Notebooks

### 1. `4_ols_unbiasedness_sampling_distribution.ipynb` *(Sampling Distribution & Unbiasedness Proof)*
* **Focus Topic:** Gauss-Markov Unbiasedness ($E[\hat{\beta}] = \beta$) & Sampling Distributions
* **Core Simulations & Workflows:**
  * Generates a true underlying **Population of 1,000 observations** where $Y_i = 1.0 + 2.0X_i + \mathcal{N}(0, 1)$ across $X \in [0, 10]$.
  * Runs a **1,000-loop Monte Carlo sampling experiment**: in each loop, draws a random subsample of $n = 30$ observations without replacement, fits an Ordinary Least Squares (`sm.OLS`) model, and records the estimated intercept ($\hat{\beta}_0$) and slope ($\hat{\beta}_1$).
  * Generates side-by-side **KDE & Histogram plots** of the 1,000 sample estimates.
  * Proves empirically that while individual samples fluctuate (`1.85`, `2.15`), the mean of the sampling distribution aligns directly on $\beta_0 = 1.0$ and $\beta_1 = 2.0$.

### 2. `1_simulating_heteroscedasticity.ipynb`
* **Focus Assumption:** Assumption 4 (Homoscedasticity vs. Heteroscedasticity)
* **Core Simulations & Workflows:**
  * Simulates both homoscedastic data ($\epsilon_i \sim \mathcal{N}(0, 1.5^2)$) and expanding "megaphone" heteroscedastic data ($\epsilon_i \sim \mathcal{N}(0, (0.4X_i)^2)$).
  * Generates `Residuals vs Fitted` diagnostic scatter plots to reveal the expanding envelope.
  * Runs a 1,000-loop **Monte Carlo simulation** proving that while Ordinary Least Squares (OLS) coefficient estimates $\hat{\beta}$ remain **unbiased** under heteroscedasticity, standard errors become unreliable.
  * Implements and demonstrates White's **`HC3` Heteroscedasticity-Consistent Robust Standard Errors** (`mod.get_robustcov_results(cov_type="HC3")`).

### 3. `2_collinearity_crash.ipynb`
* **Focus Assumption:** Assumption 6 (No Perfect Multicollinearity)
* **Core Simulations & Workflows:**
  * Constructs a design matrix $X$ where $X_2 = 1.5X_1$ exactly to test the linear algebra requirement $(X'X)^{-1}$.
  * Demonstrates how the determinant $|X'X| = 0$ triggers Python's `LinAlgError: Singular matrix` exception when attempting `np.linalg.inv(XtX)`.
  * Simulates near-collinearity ($r = 0.999$) by injecting tiny noise ($X_2 = 1.5X_1 + \mathcal{N}(0, 0.05)$).
  * Computes **Variance Inflation Factors (`VIF`)** across all predictors ($VIF > 10$) and runs 100 simulations showing extreme **see-saw volatility** between $\hat{\beta}_1$ and $\hat{\beta}_2$.

### 4. `3_ols_assumptions_all_simulations.ipynb` *(Master Practice Suite)*
* **Focus Assumption:** Comprehensive Master Notebook covering Assumptions 1 through 6
* **Core Simulations & Workflows:**
  * **Linearity in Parameters:** Simulates cubic data ($Y = -5 + X^3 + \epsilon$), demonstrates linear underfitting, and applies $X^3$ polynomial transformation.
  * **Representative Samples:** Simulates range subsetting ($0<X<1.4$, etc.) producing negative slopes against a positive global population trend.
  * **Exogeneity & Zero Conditional Mean:** Injects intercept shifts ($\pm 1$) and slope tilts to show how omitted variables cause $E[\epsilon|X] \neq 0$.
  * **Error Variance & Autocorrelation:** Compares homoscedastic, megaphone heteroscedastic, and temporal autocorrelation drift ($e_t = \mathcal{N}(0,1) + t/10$).
  * **Normality Q-Q & Outlier Influence:** Generates Normal Q-Q plots ($n \le 30$) and measures Cook's Distance ($D_i$) for extreme horizontal leverage points.

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
   Navigate to `examples_and_simulations/jupyter_notebooks/` and open any `.ipynb` notebook.

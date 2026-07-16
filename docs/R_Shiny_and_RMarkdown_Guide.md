# R Markdown & R Shiny Practice Guide
## Interactive Simulation Suite & Web Apps for OLS Assumptions

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Paths:** `examples_and_simulations/r_markdowns/` & `examples_and_simulations/shiny_apps/`

---

## Overview

This guide details the R Markdown (`.Rmd`) simulation scripts and interactive R Shiny web applications available in our practice repository. Every single Gauss-Markov assumption has its own dedicated `.Rmd` notebook (with accompanying `.md` GitHub export) and interactive Shiny dashboard tab.

---

## Part 1: Standalone R Markdown Notebooks (`r_markdowns/`)

### 1. `assumption_0_unbiasedness_sampling_distribution.Rmd`
* **Focus Topic:** Gauss-Markov Unbiasedness ($E[\hat{\beta}] = \beta$) & Sampling Distributions
* **Simulations:** Simulates $N=1,000$ population ($Y = 1 + 2X + \epsilon$). Runs 1,000 Monte Carlo loops ($n=30$) via `purrr::map_dfr` and `broom::tidy` to prove unbiased parameter recovery.

### 2. `assumption_1_linearity_in_parameters.Rmd`
* **Focus Topic:** Linearity in Parameters ($Y = X\beta + \epsilon$) & Polynomial Transformations
* **Simulations:** Simulates cubic curvature ($Y = -5 + 0.8X^3 + \epsilon$). Compares naive linear models against `I(x^3)` polynomial fits using `patchwork` 4-panel diagnostic comparison charts.

### 3. `assumption_2_representative_sampling.Rmd`
* **Focus Topic:** Representative Samples ($n=30$) vs Range Subsetting Selection Bias
* **Simulations:** Simulates a global population ($N=2,000$, true slope $+1.50$) with localized sub-group dynamics. Compares a **True Random Representative Sample ($n=30$)** against an **Unrepresentative Range-Truncated Sample ($n=30$)** to demonstrate selection bias, slope reversals (-0.85), and 5x standard error inflation.

### 4. `assumption_3_exogeneity_zero_conditional_mean.Rmd`
* **Focus Topic:** Exogeneity & Zero Conditional Mean of Errors ($E[\epsilon|X] = 0$)
* **Simulations:** Injects unobserved confounders ($Z = 0.8X + v$) to show how omitted variables force $E[\epsilon|X] \neq 0$, causing $+1.20$ upward slope bias. Runs Monte Carlo proofs showing asymptotic inconsistency persists even as sample size $N \to \infty$.

### 5. `assumption_4_homoscedasticity_vs_heteroscedasticity.Rmd`
* **Focus Topic:** Homoscedasticity ($\text{Var}(\epsilon_i) = \sigma^2$) vs Megaphone Heteroscedasticity
* **Simulations:** Simulates expanding "megaphone" error spread ($\sigma_i = 0.4X_i$). Proves $\hat{\beta}$ remains unbiased while standard errors shrink artificially. Implements White's `HC3` robust covariance matrix (`sandwich::vcovHC` + `lmtest::coeftest`).

### 6. `assumption_5_outliers_leverage_cooks_distance.Rmd`
* **Focus Topic:** Error Normality & Small Sample Outlier Sensitivity ($n \le 30$)
* **Simulations:** Simulates $n=14$ clean points and appends a 15th extreme horizontal leverage point at $X=12, Y=-3$. Computes Cook's Distance ($D_i > 4/n$) bar charts and compares OLS against Robust Huber Regression (`MASS::rlm`).

### 7. `assumption_6_no_perfect_multicollinearity.Rmd`
* **Focus Topic:** No Perfect Multicollinearity & Singular Design Matrix
* **Simulations:** Constructs exact linear duplicates ($X_2 = 1.5X_1$) showing how R returns `NA` (`Coefficients: 1 not defined because of singularities`). Injects near-collinear noise ($r=0.999$) to compute Variance Inflation Factors (`car::vif > 10`) and plot see-saw slope volatility across 100 simulations.

### 8. `master_all_assumptions_suite.Rmd` *(Master Practice Suite)*
* **Focus Topic:** Complete All-in-One Simulation Suite covering all 6 assumptions sequentially using `tidyverse` and `broom`.

---

## Part 2: Interactive R Shiny Web Application (`shiny_apps/ols_assumptions_explorer/`)

Our interactive R Shiny web app features a sleek Bootstrap 5 (`bslib`) interface with real-time sliders for live experimentation:
* **Tab 1: Assumption 1 - Linearity & Transformations:** Slider for cubic/quadratic curvature strength. Toggle between linear fit and polynomial fit.
* **Tab 2: Assumption 2 - Representative vs Range Subsetting:** Slider for population subsetting range. See live slope reversals when restricting $X$.
* **Tab 3: Assumption 3 - Exogeneity & Omitted Variable Bias:** Slider for correlation between $X$ and omitted confounder $Z$. Observe bias shift in real time.
* **Tab 4: Assumption 4 - Megaphone Heteroscedasticity:** Slider for error variance slope. Side-by-side comparison of standard vs White `HC3` robust standard errors.
* **Tab 5: Assumption 5 - Outliers & Cook's Distance:** Interactive sliders to position an outlier anywhere in the $(X, Y)$ plane. Watch Cook's Distance bar chart update instantly.

### Running the Shiny App Locally
From your terminal:
```bash
Rscript -e "shiny::runApp('examples_and_simulations/shiny_apps/ols_assumptions_explorer', port = 3838)"
```
Or inside R / RStudio console:
```r
library(shiny)
runApp("examples_and_simulations/shiny_apps/ols_assumptions_explorer")
```

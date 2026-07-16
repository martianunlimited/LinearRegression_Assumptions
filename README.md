# Assumptions of Ordinary Least Squares (OLS) Regression
## Interactive Examples, Monte Carlo Simulations & Practice Suite

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Structure:** Ready for GitHub Check-in (`martianunlimited/LinearRegression_Assumptions`)

---

## Overview

This directory contains the complete, open-source code and interactive practice resources accompanying the **Assumptions of Ordinary Least Squares (OLS) Regression** lecture suite. Each Gauss-Markov assumption is split into its own standalone, individually numbered practice notebook (`Assumption 0` through `Assumption 6`) alongside a comprehensive master simulation suite and interactive R Shiny Web Application.

```
examples_and_simulations/
├── README.md                                # Master guide (this file)
├── jupyter_notebooks/                       # Python 3 / Jupyter Notebooks & HTML/MD exports
│   ├── assumption_0_unbiasedness_sampling_distribution.ipynb
│   ├── assumption_1_linearity_in_parameters.ipynb
│   ├── assumption_2_representative_sampling.ipynb           # Random vs Unrepresentative sampling (n=30)
│   ├── assumption_3_exogeneity_zero_conditional_mean.ipynb  # Omitted variable bias & endogeneity
│   ├── assumption_4_homoscedasticity_vs_heteroscedasticity.ipynb
│   ├── assumption_5_outliers_leverage_cooks_distance.ipynb  # Small sample leverage pull & Cook's distance
│   ├── assumption_6_no_perfect_multicollinearity.ipynb      # Singular matrix crash & VIF > 10
│   └── master_all_assumptions_suite.ipynb                   # Complete simulation suite across all 6 assumptions
├── r_markdowns/                             # R Markdown scripts (.Rmd) & rendered docs
│   ├── assumption_0_unbiasedness_sampling_distribution.Rmd (and .md)
│   ├── assumption_1_linearity_in_parameters.Rmd (and .md)
│   ├── assumption_2_representative_sampling.Rmd (and .md)   # Random vs Unrepresentative sampling (n=30)
│   ├── assumption_3_exogeneity_zero_conditional_mean.Rmd (and .md)
│   ├── assumption_4_homoscedasticity_vs_heteroscedasticity.Rmd (and .md)
│   ├── assumption_5_outliers_leverage_cooks_distance.Rmd (and .md)
│   ├── assumption_6_no_perfect_multicollinearity.Rmd (and .md)
│   └── master_all_assumptions_suite.Rmd                     # Full R tidyverse/broom simulation suite
├── shiny_apps/                              # Interactive R Shiny Web Applications
│   └── ols_assumptions_explorer/
│       ├── app.R                            # Multi-tab interactive explorer (Sliders for bias, curvature, outliers)
│       └── README.md                        # Quickstart instructions for running Shiny locally
└── docs/                                    # Documentation guides (also mirrored in repo root /docs)
    ├── Python_Notebooks_Guide.md
    └── R_Shiny_and_RMarkdown_Guide.md
```

---

## Summary of Practice Resources by Assumption

| # | Topic & Core Assumption | Individual Practice Notebooks | Primary Diagnostic & Takeaway |
|---|-------------------------|-------------------------------|-------------------------------|
| **0** | **Gauss-Markov Unbiasedness ($E[\hat{\beta}] = \beta$)**<br>*(Sampling Distribution)* | `assumption_0_unbiasedness_sampling_distribution.ipynb`<br>`assumption_0_unbiasedness_sampling_distribution.Rmd` | Simulate $N=1,000$ population ($Y = 1 + 2X + \epsilon$). Run 1,000 Monte Carlo loops drawing $n=30$ subsamples. Plot histograms verifying that sample parameter estimates center exactly on true parameters ($\beta_0=1, \beta_1=2$). |
| **1** | **Linearity in Parameters**<br>*(Assumption 1)* | `assumption_1_linearity_in_parameters.ipynb`<br>`assumption_1_linearity_in_parameters.Rmd`<br>`Shiny Tab 1: Linearity & Transformations` | Simulate cubic curvature ($Y = -5 + 0.8X^3 + \epsilon$). Observe how linear OLS underfits and biases slopes. Apply $X^3$ transformation to restore exact linearity in parameters and eliminate LOESS curvature. |
| **2** | **Representative Samples**<br>*(Assumption 2)* | `assumption_2_representative_sampling.ipynb`<br>`assumption_2_representative_sampling.Rmd`<br>`Shiny Tab 2: Range Subsetting Bias` | Simulate a global population ($N=2,000$, true slope $+1.50$) containing localized sub-clusters. Compare a **True Random Representative Sample ($n=30$)** against an **Unrepresentative Range-Truncated Sample ($n=30$)** to prove how selection bias reverses slopes (Simpson's Paradox) and inflates standard errors over 5x. |
| **3** | **Zero Conditional Mean ($E[\epsilon\|X]=0$)**<br>*(Assumption 3)* | `assumption_3_exogeneity_zero_conditional_mean.ipynb`<br>`assumption_3_exogeneity_zero_conditional_mean.Rmd`<br>`Shiny Tab 3: Exogeneity & Bias` | Inject unobserved confounders ($Z = 0.8X + v$) to show how omitted variables force $E[\epsilon|X] \neq 0$. Run Monte Carlo loops proving that inconsistency persists even as sample size $N \to \infty$. |
| **4** | **Homoscedasticity ($\text{Var}(\epsilon_i)=\sigma^2$)**<br>*(Assumption 4)* | `assumption_4_homoscedasticity_vs_heteroscedasticity.ipynb`<br>`assumption_4_homoscedasticity_vs_heteroscedasticity.Rmd`<br>`Shiny Tab 4: Megaphone Variance` | Simulate expanding "megaphone" error spread ($\sigma_i = 0.4X_i$). Prove $\hat{\beta}$ remains unbiased but standard errors become artificially tight. Implement White's `HC3` robust standard errors (`vcovHC`). |
| **5** | **Normality & Low Sample Sensitivity**<br>*(Assumption 5)* | `assumption_5_outliers_leverage_cooks_distance.ipynb`<br>`assumption_5_outliers_leverage_cooks_distance.Rmd`<br>`Shiny Tab 5: Outliers & Cook's Distance` | Simulate $n=14$ clean points and append a 15th extreme horizontal leverage outlier at $X=12, Y=-3$. Compute Cook's Distance ($D_i > 4/n$) and compare OLS against Robust Regression (`MASS::rlm` / `sm.RLM`). |
| **6** | **No Perfect Multicollinearity**<br>*(Assumption 6)* | `assumption_6_no_perfect_multicollinearity.ipynb`<br>`assumption_6_no_perfect_multicollinearity.Rmd` | Examine design matrix $(X'X)$. Set $X_2 = 1.5X_1$ to trigger `np.linalg.inv` -> `LinAlgError: Singular matrix`. Add tiny noise ($r=0.999$) to compute Variance Inflation Factors ($\text{VIF} > 10$) and observe coefficient see-sawing across simulations. |
| **ALL** | **Master Practice Suite**<br>*(All 6 Assumptions Combined)* | `master_all_assumptions_suite.ipynb`<br>`master_all_assumptions_suite.Rmd` | Comprehensive all-in-one simulation workflow combining every diagnostic test, Monte Carlo loop, and corrective model in one place. |

---

## Quickstart & Installation

### 1. Python Jupyter Notebooks (`jupyter_notebooks/`)

Ensure you have Python 3.10+ installed. Set up your virtual environment and launch Jupyter:

```bash
# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install required dependencies
pip install numpy pandas matplotlib seaborn statsmodels scipy jupyterlab

# Launch Jupyter Lab
jupyter lab
```

### 2. R Markdown & R Shiny Web Apps (`r_markdowns/` & `shiny_apps/`)

Ensure you have R 4.2+ installed (and optionally Posit / RStudio). Install required R packages from CRAN:

```r
# Launch R and run:
install.packages(c("ggplot2", "dplyr", "broom", "rmarkdown", "knitr", "shiny", "bslib", "MASS", "purrr", "sandwich", "lmtest", "car"))
```

To run the interactive R Shiny Web Application locally:

```r
# Launch R from the root directory or inside shiny_apps/ols_assumptions_explorer/
library(shiny)
runApp("shiny_apps/ols_assumptions_explorer")
```

Or via terminal command line:
```bash
Rscript -e "shiny::runApp('shiny_apps/ols_assumptions_explorer', port = 3838)"
```

---

## License & Citation

All code and simulations in this suite are open-source under the MIT License. Prepared for statistical interviews and econometric regression mastery.

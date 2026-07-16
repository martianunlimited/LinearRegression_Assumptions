# Assumptions of Ordinary Least Squares (OLS) Regression
## Interactive Examples, Monte Carlo Simulations & Practice Suite

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Structure:** Ready for GitHub Check-in (`martianunlimited/LinearRegression_Assumptions`)

---

## Overview

This directory contains the complete, open-source code and interactive practice resources accompanying the **Assumptions of Ordinary Least Squares (OLS) Regression** lecture suite. It is designed to let students, analysts, and interview candidates break the mathematical assumptions of OLS in real time, observe parameter breakdown (`Singular matrix` exceptions, biased slopes, see-sawing coefficients), and implement industry-standard fixes (`White HC3` robust standard errors, `MASS::rlm` M-estimation, polynomial transformations, and Cook's distance pruning).

```
examples_and_simulations/
├── README.md                                # Master guide (this file)
├── jupyter_notebooks/                       # Python 3 / Jupyter Notebooks & HTML/MD exports
│   ├── 1_simulating_heteroscedasticity.ipynb
│   ├── 2_collinearity_crash.ipynb
│   └── 3_ols_assumptions_all_simulations.ipynb # Complete interactive simulation suite for all 6 assumptions
├── r_markdowns/                             # R Markdown scripts (.Rmd) & rendered docs
│   ├── 1_cooks_distance_leverage.Rmd
│   ├── 1_cooks_distance_leverage.md
│   └── 2_ols_assumptions_simulations.Rmd      # Full R tidyverse/broom simulation suite
├── shiny_apps/                              # Interactive R Shiny Web Applications
│   └── ols_assumptions_explorer/
│       ├── app.R                            # Multi-tab interactive explorer (Sliders for bias, curvature, outliers)
│       └── README.md                        # Quickstart instructions for running Shiny locally
└── docs/                                    # Documentation guides (also mirrored in repo root /docs)
    ├── Python_Notebooks_Guide.md
    └── R_Shiny_and_RMarkdown_Guide.md
```

---

## Summary of Practice Resources

| # | Topic & Core Assumption | Interactive Resource | Primary Diagnostic & Takeaway |
|---|-------------------------|----------------------|-------------------------------|
| **1** | **Linearity in Parameters**<br>*(Assumption 1)* | `3_ols_assumptions_all_simulations.ipynb`<br>`2_ols_assumptions_simulations.Rmd`<br>`Shiny Tab 1: Linearity & Transformations` | Simulate cubic curvature ($Y = -5 + X^3 + \epsilon$). Observe how linear OLS underfits and biases slopes. Apply $X^3$ transformation to restore exact linearity in parameters. |
| **2** | **Representative Samples**<br>*(Assumption 2)* | `3_ols_assumptions_all_simulations.ipynb`<br>`2_ols_assumptions_simulations.Rmd`<br>`Shiny Tab 2: Range Subsetting Bias` | Simulate global positive trend ($Y \sim +X$) where local range subsets ($0<X<1.5$, etc.) exhibit negative slopes. Demonstrates why truncation distorts $\hat{\beta}_1$. |
| **3** | **Zero Conditional Mean ($E[\epsilon\|X]=0$)**<br>*(Assumption 3)* | `3_ols_assumptions_all_simulations.ipynb`<br>`Shiny Tab 3: Exogeneity & Bias` | Inject intercept shifts ($\pm 1$) and slope tilts to show how omitted variable bias or endogeneity causes $E[\epsilon\|X] \neq 0$, systematically biasing $\hat{\beta}$ away from true values. |
| **4** | **Homoscedasticity ($\text{Var}(\epsilon_i)=\sigma^2$)**<br>*(Assumption 4)* | `1_simulating_heteroscedasticity.ipynb`<br>`Shiny Tab 4: Megaphone Variance` | Simulate expanding "megaphone" error spread ($\sigma_i = 0.4X_i$). Run 1,000 Monte Carlo loops to prove $\hat{\beta}$ remains unbiased but standard errors become artificially tight. Implement White's `HC3` robust standard errors. |
| **5** | **Normality & Low Sample Sensitivity**<br>*(Assumption 5)* | `1_cooks_distance_leverage.Rmd`<br>`Shiny Tab 5: Outliers & Cook's Distance` | Simulate $n=14$ clean points and append a 15th extreme horizontal leverage outlier at $X=12, Y=-3$. Compute Cook's Distance ($D_i > 4/n$) and compare OLS against Robust Regression (`MASS::rlm`). |
| **6** | **No Perfect Multicollinearity**<br>*(Assumption 6)* | `2_collinearity_crash.ipynb`<br>`3_ols_assumptions_all_simulations.ipynb` | Examine design matrix $(X'X)$. Set $X_2 = 1.5X_1$ to trigger `np.linalg.inv` -> `LinAlgError: Singular matrix`. Add tiny noise ($r=0.999$) to compute Variance Inflation Factors ($\text{VIF} > 10$) and observe coefficient see-sawing across simulations. |

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
install.packages(c("ggplot2", "dplyr", "broom", "rmarkdown", "knitr", "shiny", "bslib", "MASS"))
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

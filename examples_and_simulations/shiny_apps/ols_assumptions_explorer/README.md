# Interactive OLS Assumptions Explorer (`R Shiny Web Application`)

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Built with:** R Shiny, `bslib`, `ggplot2`, `dplyr`, and `broom`.

---

## Overview

This interactive R Shiny web application allows students and interview candidates to dynamically explore the 6 Ordinary Least Squares (OLS) assumptions in real time. By adjusting sliders for noise, curvature, range truncation, exogeneity bias, error variance spread, and outlier coordinates, users can instantly observe how regression lines and diagnostic charts respond.

## Features & Tabs

1. **Tab 1: Linearity & Transformations:** Adjust sample size and cubic noise to see why forcing linear OLS creates U-shaped residuals vs polynomial $I(X^3)$ transformation.
2. **Tab 2: Range Subsetting Bias:** Select subsets of $X$ (`Lower 3rd`, `Middle 3rd`, `Upper 3rd`) to observe local negative slopes against a global positive population trend.
3. **Tab 3: Exogeneity & Zero Conditional Mean:** Inject intercept shifts ($\pm c$) and slope tilts to visualize conditional error expectations $E[\epsilon|X]$.
4. **Tab 4: Homoscedasticity vs. Megaphone Variance:** Toggle between homoscedastic and heteroscedastic spread (`alpha * X`). Compare standard OLS standard errors against White's `HC3` robust sandwich estimates.
5. **Tab 5: Outliers, Leverage & Cook's Distance:** Move an interactive 15th observation anywhere in $(X, Y)$ space to observe magnetic pull, Cook's distance bar charts ($D_i > 4/n$), and `MASS::rlm` M-estimation resistance.

---

## Running the App Locally

### 1. Prerequisites
Ensure you have R installed along with the required packages:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "broom", "bslib", "MASS", "sandwich", "lmtest"))
```

### 2. Launching from RStudio or Posit
Open `app.R` inside RStudio and click the green **Run App** button in the editor bar.

### 3. Launching from R Console / Terminal
From the repository root directory, run:

```r
library(shiny)
runApp("examples_and_simulations/shiny_apps/ols_assumptions_explorer")
```

Or via terminal shell:
```bash
Rscript -e "shiny::runApp('examples_and_simulations/shiny_apps/ols_assumptions_explorer', port = 3838)"
```

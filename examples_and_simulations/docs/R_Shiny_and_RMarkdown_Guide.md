# R Shiny & R Markdown Practice Guide
## Interactive Web Applications & Simulation Scripts for OLS Regression

**Prepared for:** Nick Lim & the *Assumptions of Least Square Regressions* Lecture Suite  
**Repository Paths:** `examples_and_simulations/shiny_apps/` and `examples_and_simulations/r_markdowns/`

---

## Overview

This guide documents the R Markdown (`.Rmd`) simulation scripts and interactive **R Shiny Web Applications** available in our practice repository. Utilizing modern `tidyverse` (`dplyr`, `ggplot2`), `broom`, `bslib`, and `MASS`, these tools allow students to explore OLS diagnostics and breakdown modes in real time.

---

## 1. Interactive R Shiny Web Application (`ols_assumptions_explorer/`)

The multi-tab interactive Shiny app (`app.R`) provides dynamic slider controls and real-time visualization tabs:

* **Tab 1: Linearity & Transformations:**
  * **Controls:** Sliders for sample size ($n$) and cubic noise level ($\sigma$). Radio buttons to toggle between naive `y ~ x` linear OLS and `y ~ I(x^3)` polynomial fit.
  * **Live Plots:** Side-by-side scatter plot with fitted regression line vs. `Residuals vs Fitted Values` plot showing real-time LOESS curvature.
* **Tab 2: Range Subsetting Bias:**
  * **Controls:** Sliders for global population slope (+0.8) vs local range tilt (-0.8). Dropdown selector to highlight lower, middle, or upper 3rd sample intervals.
  * **Live Plots:** Displays how range truncation across $X$ subsets distorts parameter estimates away from the true population trend.
* **Tab 3: Exogeneity & Zero Conditional Mean:**
  * **Controls:** Sliders to inject intercept shifts ($\pm c$) and candidate slope tilts ($aX + b$).
  * **Live Plots:** Maps observed residuals $e_i$ and true expected conditional mean $E[\epsilon|X] = (1-b)X - a$ across the range of $X$.
* **Tab 4: Error Variance & Robust SEs:**
  * **Controls:** Sliders for sample size and megaphone expansion coefficient ($\alpha$). Toggle between homoscedastic and heteroscedastic spread.
  * **Live Plots & Tables:** Displays `Residuals vs Fitted` and `Scale-Location` diagnostic charts along with an interactive summary table comparing standard OLS against White's `HC3` robust covariance sandwich estimates (`vcovHC`).
* **Tab 5: Outliers, Cook's Distance & Leverage:**
  * **Controls:** Sliders to position a 15th observation anywhere in $(X, Y)$ space ($X \in [1, 15], Y \in [-10, 15]$). Checkbox to overlay `MASS::rlm` M-estimation.
  * **Live Plots:** Shows how horizontal leverage points exert severe magnetic pull on the OLS line while Cook's Distance bar chart ($D_i > 4/n$) flags influential points in real time.

---

## 2. R Markdown Simulation Notebooks (`r_markdowns/`)

### `1_cooks_distance_leverage.Rmd`
* Simulates small sample data ($n=14$) and appends an extreme horizontal leverage point at $X=12, Y=-3$.
* Computes and visualizes **Cook's Distance ($D_i$)** bar charts against the critical $4/n$ threshold.
* Compares OLS regression slopes against robust regression (`MASS::rlm`) M-estimation.

### `2_ols_assumptions_simulations.Rmd` *(Master R Practice Suite)*
* Standalone R Markdown document simulating all 6 OLS assumptions sequentially.
* Features self-contained `ggplot2` diagnostic code chunks (`Residuals vs Fitted`, `Scale-Location`, range subsetting breakdowns, and Cook's leverage plots).
* Can be knitted directly to HTML, PDF, or Word via `rmarkdown::render()`.

---

## Quickstart Instructions

### 1. Running the R Shiny App Locally
From your R console (in RStudio or Posit):
```r
# Install required packages if missing:
install.packages(c("shiny", "ggplot2", "dplyr", "broom", "bslib", "MASS", "sandwich", "lmtest"))

# Launch the app:
library(shiny)
runApp("examples_and_simulations/shiny_apps/ols_assumptions_explorer")
```

### 2. Rendering R Markdown Scripts
To render any `.Rmd` notebook to HTML:
```r
library(rmarkdown)
render("examples_and_simulations/r_markdowns/2_ols_assumptions_simulations.Rmd")
```
Or via terminal:
```bash
Rscript -e "rmarkdown::render('examples_and_simulations/r_markdowns/2_ols_assumptions_simulations.Rmd')"
```

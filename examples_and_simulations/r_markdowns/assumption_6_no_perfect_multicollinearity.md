---
title: "R Notebook: Assumption 6 - No Perfect Multicollinearity"
author: "Nick Lim"
date: "2026-07-16"
output:
  html_document:
    theme: readable
    highlight: tango
    toc: true
    toc_float: true
---

# Overview: The Linear Algebra Requirement

Gauss-Markov **Assumption 6** requires that there is **no perfect linear relationship among the predictor variables** (`No Perfect Multicollinearity`). Mathematically, the Ordinary Least Squares closed-form solution requires computing the inverse of the design cross-product matrix:
$$\hat{\beta} = (X'X)^{-1} X'Y$$

If two predictors are exact linear duplicates ($X_2 = 1.5 X_1$), the determinant $|X'X| = 0$, the matrix becomes **singular and non-invertible**, and R will drop collinear variables (`NA` coefficients) or crash when computing $(X'X)^{-1}$.

When predictors are **nearly collinear ($r = 0.999$)**:
1. The matrix $(X'X)$ is technically invertible, but $(X'X)^{-1}$ contains massive numbers.
2. **Variance Inflation Factors (`VIF` > 10)** explode.
3. Individual $t$-statistics become insignificant (`p > 0.05`) even when the overall $F$-test is highly significant ($R^2 > 0.95$).
4. Estimates exhibit extreme **see-saw volatility** across repeated samples.

---

# 1. Exact Multicollinearity: The Singular Matrix $(X'X)$ Crash

Let's construct a dataset where $X_2 = 1.5 X_1$ exactly and attempt to fit an OLS model.

``` r
n <- 100
df_exact <- tibble(
  x1 = runif(n, 1.0, 10.0),
  x2 = 1.5 * x1,           # Exact linear duplicate!
  y = 4.0 + 2.0 * x1 + 3.0 * x2 + rnorm(n, 0, 1.0)
)

# Fit OLS in R
mod_exact <- lm(y ~ x1 + x2, data = df_exact)

cat("=== R OLS Summary under Perfect Multicollinearity ===\n")
```

```
## === R OLS Summary under Perfect Multicollinearity ===
```

``` r
tidy(mod_exact)
```

|term        | estimate| std.error| statistic| p.value|
|:-----------|--------:|---------:|---------:|-------:|
|(Intercept) |    3.905|     0.218|    17.915|       0|
|x1          |    6.518|     0.036|   181.166|       0|
|x2          |       NA|        NA|        NA|      NA|

Notice how R automatically detects the singular design matrix and returns `NA` (`Coefficients: (1 not defined because of singularities)`) for `x2`!

---

# 2. Near-Collinearity ($r = 0.999$): VIF Explosion & See-Saw Parameters

Now let's inject tiny random noise ($X_2 = 1.5 X_1 + \mathcal{N}(0, 0.05)$) so the correlation becomes $r = 0.999$.

``` r
df_near <- tibble(
  x1 = runif(n, 1.0, 10.0),
  x2 = 1.5 * x1 + rnorm(n, 0, 0.05),
  y = 4.0 + 2.0 * x1 + 3.0 * x2 + rnorm(n, 0, 1.0)
)

mod_near <- lm(y ~ x1 + x2, data = df_near)

cat("=== OLS Estimates under High Multicollinearity (r = 0.999) ===\n")
```

```
## === OLS Estimates under High Multicollinearity (r = 0.999) ===
```

``` r
tidy(mod_near)
```

|term        | estimate| std.error| statistic| p.value|
|:-----------|--------:|---------:|---------:|-------:|
|(Intercept) |    3.906|     0.220|    17.756|   0.000|
|x1          |   -0.564|     3.468|    -0.163|   0.871|
|x2          |    4.721|     2.312|     2.042|   0.044|

``` r
cat("\n=== Variance Inflation Factors (VIF > 10 is problematic) ===\n")
```

```
## === Variance Inflation Factors (VIF > 10 is problematic) ===
```

``` r
vif(mod_near)
```

```
##       x1       x2 
## 7614.284 7614.284
```

Notice how `vif(mod_near)` exceeds several hundred—confirming severe variance inflation!

---

# 3. Monte Carlo Proof of See-Saw Volatility across 100 Samples

Let's run 100 simulations where we sample new data from the exact same underlying process ($Y = 4 + 2X_1 + 3X_2 + \epsilon$) under near-collinearity ($r=0.999$) and track how $\hat{\beta}_1$ and $\hat{\beta}_2$ see-saw wildly.

``` r
sim_params <- purrr::map_dfr(1:100, function(i) {
  xs1 <- runif(n, 1.0, 10.0)
  xs2 <- 1.5 * xs1 + rnorm(n, 0, 0.05)
  ys <- 4.0 + 2.0 * xs1 + 3.0 * xs2 + rnorm(n, 0, 1.0)
  m <- lm(ys ~ xs1 + xs2)
  tibble(sim = i, b1 = coef(m)["xs1"], b2 = coef(m)["xs2"])
})

ggplot(sim_params, aes(x = b1, y = b2)) +
  geom_point(color = "#dc2626", alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  geom_vline(xintercept = 2.0, linetype = "dashed", color = "#2563eb", linewidth = 1.2) +
  geom_hline(yintercept = 3.0, linetype = "dashed", color = "#2563eb", linewidth = 1.2) +
  labs(title = "See-Saw Volatility of Collinear Slopes across 100 Simulations", subtitle = "Dashed blue intersection marks true parameters (beta1=2.0, beta2=3.0)", x = expression(hat(beta)[1] ~ "(True = 2.0)"), y = expression(hat(beta)[2] ~ "(True = 3.0)"))
```

![plot of chunk mc-seesaw](figure/mc-seesaw-1.png)

---

# Key Takeaways

1. **Check VIFs (`car::vif(mod)`):** Any predictor with $\text{VIF} > 10$ suffers from inflated standard errors and unstable parameter estimates.
2. **Fixes for Multicollinearity:**
   - Drop redundant duplicate predictors.
   - Combine variables into indices (e.g., Principal Component Analysis (`PCA`)).
   - Use **Ridge Regression (`glmnet(alpha=0)`)** to regularize singular design matrices $(X'X + \lambda I)^{-1}$.

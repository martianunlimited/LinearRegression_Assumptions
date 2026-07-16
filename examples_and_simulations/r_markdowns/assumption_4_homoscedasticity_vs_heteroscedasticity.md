---
title: "R Notebook: Assumption 4 - Homoscedasticity vs. Heteroscedasticity"
author: "Nick Lim"
date: "2026-07-16"
output:
  html_document:
    theme: readable
    highlight: tango
    toc: true
    toc_float: true
---

# Overview: Constant Error Variance

Gauss-Markov **Assumption 4** requires that the variance of the error term $\epsilon$ remains constant across all observations (`Homoscedasticity`):
$$\text{Var}(\epsilon_i | X_i) = \sigma^2$$

When error variance expands or contracts systematically across the range of $X$ (`Heteroscedasticity`):
1. **Unbiasedness is NOT lost:** OLS parameter estimates $\hat{\beta}_0, \hat{\beta}_1$ remain completely unbiased ($E[\hat{\beta}] = \beta$).
2. **Efficiency is lost:** OLS is no longer **BLUE** (Best Linear Unbiased Estimator).
3. **Standard Errors explode or shrink artificially:** Standard OLS variance formula $\hat{\sigma}^2 (X'X)^{-1}$ becomes invalid, leading to severely biased $t$-statistics and false $p$-values.

---

# 1. Simulating Megaphone Variance ($\sigma_i = 0.4 X_i$)

We simulate $n = 150$ data points where error spread grows linearly with $X$.

``` r
n <- 150
df <- tibble(
  x = runif(n, 1.0, 10.0),
  # Megaphone heteroscedasticity: sd is proportional to X
  err_het = rnorm(n, mean = 0, sd = 0.4 * x),
  y_het = 3.0 + 1.5 * x + err_het,
  
  # Homoscedastic baseline for comparison
  err_hom = rnorm(n, mean = 0, sd = 2.0),
  y_hom = 3.0 + 1.5 * x + err_hom
)

mod_hom <- lm(y_hom ~ x, data = df)
mod_het <- lm(y_het ~ x, data = df)
```

---

# 2. Diagnostic Plots: Scale-Location & Residual Spread

Let's inspect standard regression diagnostics. The **`Scale-Location` plot** ($\sqrt{|e_i|}$ vs $\hat{Y}$) directly exposes heteroscedasticity via an upward-sloping LOESS curve.

``` r
p1 <- ggplot(augment(mod_hom), aes(x = .fitted, y = .resid)) +
  geom_point(color = "#3b82f6", alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
  geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  labs(title = "Homoscedastic Residuals vs Fitted", subtitle = "Constant vertical envelope across all fitted values", x = "Fitted Values", y = "Residuals")

p2 <- ggplot(augment(mod_hom), aes(x = .fitted, y = sqrt(abs(.std.resid)))) +
  geom_point(color = "#3b82f6", alpha = 0.6) +
  geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  labs(title = "Homoscedastic Scale-Location Plot", subtitle = "Flat LOESS trend verifies constant variance", x = "Fitted Values", y = expression(sqrt(abs("Std. Residuals"))))

p3 <- ggplot(augment(mod_het), aes(x = .fitted, y = .resid)) +
  geom_point(color = "#f59e0b", alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
  geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  labs(title = "Heteroscedastic Residuals vs Fitted", subtitle = "Distinct expanding 'Megaphone' cone shape", x = "Fitted Values", y = "Residuals")

p4 <- ggplot(augment(mod_het), aes(x = .fitted, y = sqrt(abs(.std.resid)))) +
  geom_point(color = "#f59e0b", alpha = 0.6) +
  geom_smooth(method = "loess", se = FALSE, color = "#dc2626", linewidth = 1.5) +
  labs(title = "Heteroscedastic Scale-Location Plot", subtitle = "Steep upward LOESS slope confirms variance expansion", x = "Fitted Values", y = expression(sqrt(abs("Std. Residuals"))))

p1 + p2
p3 + p4
```

![plot of chunk plot-diagnostics](figure/plot-diagnostics-1.png)

---

# 3. The Fix: White's HC3 Robust Standard Errors

When heteroscedasticity is present, we apply **White's Heteroscedasticity-Consistent (`HC3`) sandwich estimators** (`sandwich::vcovHC` + `lmtest::coeftest`) to compute valid standard errors and hypothesis tests without changing our unbiased $\hat{\beta}$ parameters.

``` r
# Standard OLS summary (invalid standard errors under heteroscedasticity)
std_summary <- tidy(mod_het) %>% select(term, estimate, std.error, p.value)

# Robust HC3 summary (industry standard fix)
robust_cov <- vcovHC(mod_het, type = "HC3")
robust_summary <- coeftest(mod_het, vcov. = robust_cov) %>% tidy() %>% select(term, estimate, std.error, p.value)

comparison_table <- tibble(
  Parameter = c("Intercept (b0)", "Slope (b1)"),
  `OLS Estimate` = round(std_summary$estimate, 3),
  `Standard OLS SE (Invalid)` = round(std_summary$std.error, 4),
  `White HC3 Robust SE (Valid)` = round(robust_summary$std.error, 4),
  `SE Expansion` = paste0(round(robust_summary$std.error / std_summary$std.error * 100 - 100, 1), "%")
)

knitr::kable(comparison_table, caption = "Comparison of Standard vs. White HC3 Robust Standard Errors")
```

|Parameter      | OLS Estimate| Standard OLS SE (Invalid)| White HC3 Robust SE (Valid)|SE Expansion |
|:--------------|------------:|-------------------------:|---------------------------:|:------------|
|Intercept (b0) |        3.388|                    0.4682|                      0.2842|-39.3%       |
|Slope (b1)     |        1.458|                    0.0768|                      0.1042|35.7%        |

---

# Key Takeaways

- **Heteroscedasticity does not bias $\hat{\beta}$**, but it destroys the validity of standard errors and $p$-values.
- Always inspect the `Scale-Location` plot. If the LOESS line tilts upward or downward, use `vcovHC(mod, type = "HC3")` or Weighted Least Squares (`WLS`).

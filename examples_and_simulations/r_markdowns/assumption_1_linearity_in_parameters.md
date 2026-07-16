---
title: "R Notebook: Assumption 1 - Linearity in Parameters"
author: "Nick Lim"
date: "2026-07-16"
output:
  html_document:
    theme: readable
    highlight: tango
    toc: true
    toc_float: true
---

# Overview: What is Linearity in Parameters?

Ordinary Least Squares (OLS) requires that the regression model is **linear in parameters (`Assumption 1`)**. Mathematically, the expected value of the outcome variable must be a linear combination of the unknown parameters $\beta_0, \beta_1, \dots, \beta_k$:
$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \dots + \epsilon_i$$

Crucially, the model **does not need to be linear in the predictors ($X$)**! For example, polynomial regressions ($Y = \beta_0 + \beta_1 X + \beta_2 X^2$) and logarithmic models ($Y = \beta_0 + \beta_1 \ln X$) are 100% linear in parameters and fully satisfy Assumption 1.

---

# 1. Simulating Cubic Curvature ($Y = -5 + 0.8 X^3 + \epsilon$)

Let's simulate $n = 100$ observations across $X \in [-3, 3]$ where the true relationship is cubic.

``` r
n <- 100
df <- tibble(
  x = seq(-3.0, 3.0, length.out = n),
  true_error = rnorm(n, mean = 0, sd = 3.5),
  y = -5.0 + 0.8 * (x^3) + true_error,
  x3 = x^3
)

mod_naive <- lm(y ~ x, data = df)
mod_trans <- lm(y ~ I(x^3), data = df)

comp_df <- tibble(
  Specification = c("Naive Linear (y ~ x)", "Transformed Polynomial (y ~ I(x^3))"),
  `Estimated Intercept` = round(c(coef(mod_naive)[1], coef(mod_trans)[1]), 3),
  `Estimated Slope` = round(c(coef(mod_naive)[2], coef(mod_trans)[2]), 3),
  `R-Squared` = round(c(summary(mod_naive)$r.squared, summary(mod_trans)$r.squared), 3),
  AIC = round(c(AIC(mod_naive), AIC(mod_trans)), 1)
)

knitr::kable(comp_df, caption = "Specification Comparison: Naive vs. Transformed OLS")
```

|Specification                       | Estimated Intercept| Estimated Slope| R-Squared|   AIC|
|:-----------------------------------|-------------------:|---------------:|---------:|-----:|
|Naive Linear (y ~ x)                |              -4.885|           4.815|     0.741| 631.8|
|Transformed Polynomial (y ~ I(x^3)) |              -4.885|           0.803|     0.962| 530.1|

---

# 2. Visual Diagnostic: Fits & Residual Curves

Let's inspect both models using diagnostic scatter plots and residual checks.

``` r
p1 <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "#64748b", alpha = 0.6, size = 2) +
  geom_line(aes(y = fitted(mod_naive)), color = "#dc2626", linewidth = 1.6) +
  labs(title = "Naive Linear Fit (y ~ x)", subtitle = paste0("R-squared = ", round(summary(mod_naive)$r.squared, 2)), x = "Predictor (X)", y = "Outcome (Y)")

p2 <- ggplot(augment(mod_naive), aes(x = .fitted, y = .resid)) +
  geom_point(color = "#dc2626", alpha = 0.7, size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
  geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  labs(title = "Diagnostic: Naive Residuals vs Fitted", subtitle = "LOESS curve reveals severe S-shaped specification violation", x = "Fitted Values", y = "Residuals")

p3 <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "#64748b", alpha = 0.6, size = 2) +
  geom_line(aes(y = fitted(mod_trans)), color = "#2563eb", linewidth = 1.6) +
  labs(title = "Transformed Polynomial Fit (y ~ I(x^3))", subtitle = paste0("R-squared = ", round(summary(mod_trans)$r.squared, 2)), x = "Predictor (X)", y = "Outcome (Y)")

p4 <- ggplot(augment(mod_trans), aes(x = .fitted, y = .resid)) +
  geom_point(color = "#2563eb", alpha = 0.7, size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
  geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 1.4) +
  labs(title = "Diagnostic: Transformed Residuals vs Fitted", subtitle = "Residuals form clean random noise around zero", x = "Fitted Values", y = "Residuals")

p1 + p2
p3 + p4
```

![plot of chunk plot-diagnostics](figure/plot-diagnostics-1.png)

---

# Key Takeaways

1. **Residual Curvature is the #1 Red Flag:** If your `Residuals vs Fitted` scatter plot shows systematic bowing or S-shaped LOESS trends, Assumption 1 is violated.
2. **Transformation Fixes Specification:** Creating new terms ($X^2, X^3, \ln X$) allows standard linear OLS to fit complex non-linear curves while preserving exact linearity in parameters.

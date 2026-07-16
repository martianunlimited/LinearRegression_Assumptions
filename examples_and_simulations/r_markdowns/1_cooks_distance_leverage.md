---
title: "R Notebook 1: Cook's Distance & Leverage Diagnostics"
author: "Nick Lim"
date: "2026-07-15"
output:
  html_document:
    theme: readable
    highlight: tango
    toc: true
    toc_float: true
---

# Introduction

In this notebook, we explore **Assumption 5 (Normality of Errors & Low Sample Sensitivity)** and **Outlier Influence**. While Ordinary Least Squares (OLS) does not strictly require normal errors to calculate unbiased slopes when sample sizes are large (thanks to the Central Limit Theorem), **small samples are acutely vulnerable to extreme outliers**. Because OLS minimizes the **squared** residuals, a single high-leverage observation can pull the entire regression line off course like a magnet.

Here, you will learn:
1. How to measure **Leverage** (`hatvalues`) and **Cook's Distance** ($D_i$).
2. How to visualize Cook's Distance against the critical threshold ($4/n$).
3. How removing or re-weighting influential points restores accurate parameter estimation.

---

# 1. Simulating Small Sample Data with an Outlier

Let's generate $n=14$ clean observations from $Y = 1.0 + 1.2X + \epsilon$, and then append a 15th observation that is an extreme leverage outlier at $X=12.0, Y=-3.0$.

``` r
n_clean <- 14
x_clean <- seq(1, 8, length.out = n_clean)
y_clean <- 1.0 + 1.2 * x_clean + rnorm(n_clean, mean = 0, sd = 0.5)

# Add extreme outlier
df <- tibble(
  id = 1:(n_clean + 1),
  x = c(x_clean, 12.0),
  y = c(y_clean, -3.0),
  type = c(rep("Standard Observation", n_clean), "Extreme Leverage Outlier")
)

# Fit OLS models
mod_clean <- lm(y ~ x, data = filter(df, type == "Standard Observation"))
mod_outlier <- lm(y ~ x, data = df)

cat("=== OLS Slopes Comparison ===\n")
```

```
## === OLS Slopes Comparison ===
```

``` r
cat("Clean Data Slope (True ~ 1.20):", round(coef(mod_clean)[2], 3), "\n")
```

```
## Clean Data Slope (True ~ 1.20): 1.188
```

``` r
cat("Outlier Contaminated Slope    :", round(coef(mod_outlier)[2], 3), "\n")
```

```
## Outlier Contaminated Slope    : 0.09
```

---

# 2. Visualizing the Magnetic Pull of Outliers

Let's plot both regression lines to observe how the single point drags down the slope.

``` r
x_grid <- seq(0, 13, length.out = 100)
df_lines <- bind_rows(
  tibble(x = x_grid, y = predict(mod_clean, newdata = data.frame(x = x_grid)), model = "Without Outlier (Clean)"),
  tibble(x = x_grid, y = predict(mod_outlier, newdata = data.frame(x = x_grid)), model = "With Outlier (Contaminated)")
)

ggplot(df, aes(x = x, y = y)) +
  geom_point(aes(color = type, size = type), alpha = 0.85) +
  geom_line(data = df_lines, aes(x = x, y = y, linetype = model, color = model), linewidth = 1.3) +
  scale_color_manual(values = c("Standard Observation" = "#2563eb", "Extreme Leverage Outlier" = "#dc2626",
                                "Without Outlier (Clean)" = "#16a34a", "With Outlier (Contaminated)" = "#dc2626")) +
  scale_size_manual(values = c("Standard Observation" = 3.5, "Extreme Leverage Outlier" = 6)) +
  labs(
    title = "The Magnetic Pull of Extreme Leverage Outliers",
    subtitle = "Notice how one observation tilts the slope from positive to negative/zero!",
    x = "Predictor (X)",
    y = "Outcome (Y)"
  ) +
  theme(legend.position = "bottom")
```

![plot of chunk plot-regression](figure/plot-regression-1.png)

---

# 3. Cook's Distance Diagnostic ($D_i$)

How do we systematically flag points that exert undue influence? We use **Cook's Distance**, which measures how much all fitted values $\hat{Y}$ change when observation $i$ is removed from the dataset:

$$D_i = \frac{\sum_{j=1}^n (\hat{Y}_j - \hat{Y}_{j(i)})^2}{p \cdot s^2}$$

A common rule of thumb flags observations where $D_i > \frac{4}{n}$ as highly influential.

``` r
df_aug <- augment(mod_outlier) %>%
  mutate(
    id = row_number(),
    threshold = 4 / n(),
    is_influential = .cooksd > threshold
  )

cat("Critical Cook's Distance Threshold (4/n):", round(4/nrow(df), 3), "\n\n")
```

```
## Critical Cook's Distance Threshold (4/n): 0.267
```

``` r
print(select(df_aug, id, x, y, .hat, .cooksd, is_influential))
```

```
## # A tibble: 15 × 6
##       id     x     y   .hat  .cooksd is_influential
##    <int> <dbl> <dbl>  <dbl>    <dbl> <lgl>         
##  1     1  1     2.89 0.202  0.0866   FALSE         
##  2     2  1.54  2.56 0.168  0.0852   FALSE         
##  3     3  2.08  3.67 0.139  0.0289   FALSE         
##  4     4  2.62  4.45 0.115  0.00948  FALSE         
##  5     5  3.15  4.99 0.0954 0.00311  FALSE         
##  6     6  3.69  5.38 0.0811 0.000938 FALSE         
##  7     7  4.23  6.83 0.0717 0.00230  FALSE         
##  8     8  4.77  6.68 0.0671 0.00126  FALSE         
##  9     9  5.31  8.38 0.0675 0.0150   FALSE         
## 10    10  5.85  7.98 0.0727 0.0107   FALSE         
## 11    11  6.38  9.31 0.0829 0.0352   FALSE         
## 12    12  6.92 10.5  0.0979 0.0775   FALSE         
## 13    13  7.46  9.26 0.118  0.0490   FALSE         
## 14    14  8    10.5  0.143  0.120    FALSE         
## 15    15 12    -3    0.480  5.89     TRUE
```

Let's plot Cook's Distance across all observation indices:

``` r
ggplot(df_aug, aes(x = id, y = .cooksd)) +
  geom_segment(aes(xend = id, yend = 0, color = is_influential), linewidth = 1.2) +
  geom_point(aes(color = is_influential), size = 4) +
  geom_hline(aes(yintercept = threshold), linetype = "dashed", color = "#dc2626", linewidth = 1) +
  scale_color_manual(values = c("FALSE" = "#2563eb", "TRUE" = "#dc2626"), name = "Undue Leverage (D > 4/n)") +
  labs(
    title = "Cook's Distance Diagnostic Chart",
    subtitle = "Dashed red line indicates critical threshold (4/n)",
    x = "Observation Index (i)",
    y = "Cook's Distance (D_i)"
  ) +
  theme(legend.position = "top")
```

![plot of chunk plot-cooks](figure/plot-cooks-1.png)

---

# Summary & Best Practices

1. **Check Cook's Distance (`.cooksd`) and Leverage (`.hat`)** whenever running OLS on small sample sizes ($n < 30$).
2. **Do not blindly delete outliers!** Investigate whether the outlier is a data entry/measurement error, or a genuine extreme phenomenon.
3. If genuine, consider using **Robust Regression** (e.g., `MASS::rlm()` which uses M-estimation) rather than standard OLS squared error minimization.

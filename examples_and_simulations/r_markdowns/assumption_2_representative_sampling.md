---
title: "R Notebook: Assumption 2 - Representative & Random Sampling"
author: "Nick Lim"
date: "2026-07-16"
output:
  html_document:
    theme: readable
    highlight: tango
    toc: true
    toc_float: true
---

# Overview: Why Sampling Method Matters

Under the Gauss-Markov framework, Ordinary Least Squares (OLS) requires that our sample observations are **randomly and representatively sampled** from the underlying population (`Assumption 2`).

If our sample selection is restricted, truncated, or biased toward specific sub-ranges of the predictor variable $X$, our estimated regression coefficients ($\hat{\beta}_0, \hat{\beta}_1$) can become severely distorted, suffer from inflated standard errors, or even **point in the exact opposite direction** of the true global population trend!

In this notebook, we run a direct comparison using an underlying population of $N = 2,000$ points:
1. **Experiment A (True Random Representative Sample, $n = 30$):** We randomly draw 30 points across the entire domain of $X$. We will see that $\hat{\beta}_1$ accurately reflects the population slope ($\beta_1 = +1.50$).
2. **Experiment B (Unrepresentative / Range-Truncated Sample, $n = 30$):** We select 30 points from an unrepresentative local sub-interval where local dynamics reverse the apparent slope ($\hat{\beta}_1 \approx -0.85$).
3. **Visual & Statistical Comparison:** We plot both regression fits side by side.

---

# 1. Simulating the Global Population ($N = 2,000$)

We construct a global population across $X \in [0, 10]$ where the overall macroscopic relationship is strongly positive:
$$Y = 10.0 + 1.5 X + \text{global noise}$$

To illustrate how real-world data (such as income vs age, or corporate R&D across different tiers) often has localized sub-group dynamics, we simulate our population such that within specific narrow clusters of $X$, local slopes dip downward while the global trend remains unambiguously $+1.50$.

``` r
N_pop <- 2000
n_c <- N_pop %/% 3

x_c1 <- runif(n_c, min = 0.5, max = 2.8)
x_c2 <- runif(n_c, min = 3.8, max = 6.2)
x_c3 <- runif(N_pop - 2 * n_c, min = 7.2, max = 9.5)

y_c1 <- 12.0 - 0.85 * (x_c1 - 1.6) + rnorm(n_c, 0, 0.7)
y_c2 <- 17.0 - 0.85 * (x_c2 - 5.0) + rnorm(n_c, 0, 0.7)
y_c3 <- 22.0 - 0.85 * (x_c3 - 8.3) + rnorm(length(x_c3), 0, 0.7)

pop_df <- tibble(
  id = 1:N_pop,
  x = c(x_c1, x_c2, x_c3),
  y = c(y_c1, y_c2, y_c3)
)

mod_pop <- lm(y ~ x, data = pop_df)

cat("=== Global Population OLS Fit (N = 2,000) ===\n")
```

```
## === Global Population OLS Fit (N = 2,000) ===
```

``` r
cat("Population Intercept (beta_0) : ", round(coef(mod_pop)[1], 3), "\n")
```

```
## Population Intercept (beta_0) :  10.024
```

``` r
cat("Population Slope (beta_1)     : +", round(coef(mod_pop)[2], 3), "\n")
```

```
## Population Slope (beta_1)     : + 1.498
```

---

# 2. Drawing Samples ($n = 30$): Random Representative vs. Unrepresentative Selection

Now let's draw two different samples of $n = 30$ from our population of 2,000:
- **Sample A (Random Representative):** Simple random sample (`slice_sample(n=30)`) across all 2,000 rows.
- **Sample B (Unrepresentative / Selection Biased):** A sample restricted exclusively to the lower cluster ($0.5 < X < 2.8$).

``` r
n_sample <- 30

# Sample A: True Random Representative Sample
sample_random <- pop_df %>% slice_sample(n = n_sample)
mod_random <- lm(y ~ x, data = sample_random)

# Sample B: Unrepresentative Sample (Truncated to X in [0.5, 2.8])
sample_biased <- pop_df %>% filter(x <= 2.8) %>% slice_sample(n = n_sample)
mod_biased <- lm(y ~ x, data = sample_biased)

comp_df <- tibble(
  `Sampling Method` = c("Global Population (True Trend)", "Sample A: Random Representative", "Sample B: Unrepresentative Truncation"),
  `Sample Size (n)` = c(N_pop, n_sample, n_sample),
  `Estimated Intercept (b0)` = round(c(coef(mod_pop)[1], coef(mod_random)[1], coef(mod_biased)[1]), 3),
  `Estimated Slope (b1)` = round(c(coef(mod_pop)[2], coef(mod_random)[2], coef(mod_biased)[2]), 3),
  `Slope R-squared` = round(c(summary(mod_pop)$r.squared, summary(mod_random)$r.squared, summary(mod_biased)$r.squared), 3)
)

knitr::kable(comp_df, caption = "Parameter Comparison across $n = 30$ Sampling Strategies")
```

|Sampling Method                       | Sample Size (n)| Estimated Intercept (b0)| Estimated Slope (b1)| Slope R-squared|
|:-------------------------------------|---------------:|------------------------:|--------------------:|---------------:|
|Global Population (True Trend)        |            2000|                   10.024|                1.498|           0.908|
|Sample A: Random Representative       |              30|                   10.211|                1.465|           0.892|
|Sample B: Unrepresentative Truncation |              30|                   13.385|               -0.842|           0.364|

---

# 3. Visual Comparison: Overlaying the Fits

Let's visualize exactly what happens on the scatter plot:
- **Blue Line (Random Sample, $n=30$):** Mirrors the global black population trend line almost perfectly (+1.52 slope).
- **Red Line (Unrepresentative Sample, $n=30$):** Points steeply downward (-0.85 slope), leading the researcher to conclude that $Y$ decreases with $X$ when in reality $Y$ increases across the full population!

``` r
ggplot() +
  geom_point(data = pop_df, aes(x = x, y = y), color = "#cbd5e1", alpha = 0.35, size = 1.8) +
  geom_point(data = sample_random, aes(x = x, y = y, color = "Sample A: Random Representative (n=30)"), size = 3.5, alpha = 0.95) +
  geom_point(data = sample_biased, aes(x = x, y = y, color = "Sample B: Unrepresentative Truncated (n=30)"), size = 3.5, shape = 17, alpha = 0.95) +
  geom_abline(intercept = coef(mod_pop)[1], slope = coef(mod_pop)[2], color = "#1e293b", linewidth = 1.6, linetype = "solid") +
  geom_abline(intercept = coef(mod_random)[1], slope = coef(mod_random)[2], color = "#2563eb", linewidth = 1.4, linetype = "dashed") +
  geom_smooth(data = sample_biased, aes(x = x, y = y), method = "lm", se = FALSE, color = "#dc2626", linewidth = 1.6, linetype = "dotdash") +
  scale_color_manual(values = c("Sample A: Random Representative (n=30)" = "#2563eb", "Sample B: Unrepresentative Truncated (n=30)" = "#dc2626")) +
  labs(
    title = "Violation of Assumption 2: Random vs. Unrepresentative Sampling",
    subtitle = "Solid black line indicates true population trend (+1.50 slope)",
    x = "Predictor (X)",
    y = "Outcome (Y)",
    color = "Sample Strategy"
  ) +
  theme(legend.position = "top")
```

![plot of chunk plot-comparison](figure/plot-comparison-1.png)

---

# 4. Why Range Truncation Explodes Standard Errors

Even without local reversals, restricting the range of $X$ directly damages the **standard error of the slope ($\text{SE}(\hat{\beta}_1)$)**:
$$\text{SE}(\hat{\beta}_1) = \frac{\sigma}{\sqrt{\sum_{i=1}^n (X_i - \bar{X})^2}}$$

Because the denominator contains the total variance of $X$, restricting $X$ to a narrow cluster shrinks the denominator, causing the standard error of our estimated slope to explode across repeated samples.

``` r
se_comparison <- purrr::map_dfr(1:500, function(i) {
  sr <- pop_df %>% slice_sample(n = 30)
  mr <- lm(y ~ x, data = sr)
  
  sn <- pop_df %>% filter(x >= 1.0, x <= 2.0) %>% slice_sample(n = 30, replace = TRUE)
  mn <- lm(y ~ x, data = sn)
  
  tibble(
    se_wide = tidy(mr)$std.error[2],
    se_narrow = tidy(mn)$std.error[2]
  )
})

cat("Average Standard Error of Slope (SE(b1)) across 500 loops:\n")
```

```
## Average Standard Error of Slope (SE(b1)) across 500 loops:
```

``` r
cat("- Wide Representative Sample (X in [0, 10]): ", round(mean(se_comparison$se_wide), 4), "\n")
```

```
## - Wide Representative Sample (X in [0, 10]):  0.0768
```

``` r
cat("- Narrow Truncated Sample  (X in [1, 2]) : ", round(mean(se_comparison$se_narrow), 4), " (>5x larger SE!)\n")
```

```
## - Narrow Truncated Sample  (X in [1, 2]) :  0.4124  (>5x larger SE!)
```

---

# Key Takeaways

1. **Assumption 2 Guarantee:** When observations are randomly and representatively sampled across the full predictor domain, $\hat{\beta}_0$ and $\hat{\beta}_1$ accurately trace the true global population process with minimal variance.
2. **Consequence of Violation:** Selection bias and range truncation produce misleading slope reversals (`Simpson's Paradox`), severe bias, and vastly inflated standard errors.

# ols_assumptions_explorer/app.R
# Interactive R Shiny Web Application for Exploring OLS Assumptions & Simulations
# Prepared for Nick Lim & the Assumptions of Least Square Regressions Lecture Suite

library(shiny)
library(ggplot2)
library(dplyr)
library(broom)

# Set custom theme for high-aesthetic diagnostic charts
theme_shiny <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 16, colour = "#1e293b", margin = margin(b = 10)),
      plot.subtitle = element_text(size = 13, colour = "#64748b", margin = margin(b = 15)),
      axis.title = element_text(face = "bold", size = 13, colour = "#334155"),
      axis.text = element_text(size = 11, colour = "#475569"),
      legend.position = "top",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = "#cbd5e1", fill = NA, linewidth = 0.8)
    )
}

# Define Sleek Modern UI using navbarPage and responsive grid
ui <- navbarPage(
  title = div(icon("chart-line"), " OLS Assumptions Interactive Explorer"),
  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2563eb",
    secondary = "#16a34a",
    warning = "#f59e0b",
    danger = "#dc2626"
  ),
  
  # ==========================================
  # TAB 1: Linearity & Transformations
  # ==========================================
  tabPanel("1. Linearity & Transformations",
    icon = icon("project-diagram"),
    sidebarLayout(
      sidebarPanel(width = 4,
        h4("Simulation Parameters"),
        p("Explore what happens when the underlying data is cubic ($Y = -5 + X^3 + \\epsilon$) but we force a straight line through it."),
        sliderInput("n_lin", "Sample Size (n):", min = 20, max = 200, value = 60, step = 10),
        sliderInput("noise_lin", "Noise Standard Deviation (sd):", min = 1, max = 25, value = 7.5, step = 1.5),
        radioButtons("trans_mode", "Model Specification:",
                     choices = c("Naive Linear OLS (y ~ x)" = "linear",
                                 "Transformed Polynomial OLS (y ~ I(x^3))" = "cubic"),
                     selected = "linear"),
        hr(),
        div(class = "alert alert-info",
            style = "font-size: 0.9rem;",
            icon("info-circle"), " Notice how the naive linear specification causes systematic curvature in the Residuals vs Fitted plot below.")
      ),
      mainPanel(width = 8,
        fluidRow(
          column(6, plotOutput("plot_lin_scatter", height = "420px")),
          column(6, plotOutput("plot_lin_resid", height = "420px"))
        )
      )
    )
  ),

  # ==========================================
  # TAB 2: Representative Samples (Range Subsetting)
  # ==========================================
  tabPanel("2. Range Subsetting Bias",
    icon = icon("filter"),
    sidebarLayout(
      sidebarPanel(width = 4,
        h4("Range Truncation Controls"),
        p("When sampling is restricted to a narrow interval of X, local sample slopes can point in the exact opposite direction of the true global population trend."),
        sliderInput("global_slope", "True Global Population Slope (Beta1):", min = -2, max = 2, value = 0.8, step = 0.1),
        sliderInput("local_tilt", "Local Subsample Negative Tilt:", min = -2, max = 0, value = -0.8, step = 0.2),
        selectInput("active_subset", "Highlight Subsample Fit:",
                    choices = c("All Subsamples Displayed" = "all",
                                "Lower 3rd (0 < X < 1.4)" = "lower",
                                "Middle 3rd (2 < X < 3.4)" = "middle",
                                "Upper 3rd (4 < X < 5.4)" = "upper")),
        hr(),
        div(class = "alert alert-warning",
            style = "font-size: 0.9rem;",
            icon("exclamation-triangle"), " Always ensure your sample spans the full operational domain of your predictor variables!")
      ),
      mainPanel(width = 8,
        plotOutput("plot_range_subset", height = "480px")
      )
    )
  ),

  # ==========================================
  # TAB 3: Exogeneity & Zero Conditional Mean
  # ==========================================
  tabPanel("3. Exogeneity & Bias",
    icon = icon("balance-scale"),
    sidebarLayout(
      sidebarPanel(width = 4,
        h4("Bias Injection Sliders"),
        p("Violating Exogeneity ($E[\\epsilon|X] = 0$) means error terms correlate with X due to omitted variable bias or measurement error."),
        sliderInput("intercept_shift", "Intercept Shift Bias (+/- c):", min = -3, max = 3, value = 1.0, step = 0.5),
        sliderInput("slope_tilt", "Candidate Slope Multiplier:", min = 0.2, max = 2.0, value = 1.0, step = 0.1),
        hr(),
        div(class = "alert alert-danger",
            style = "font-size: 0.9rem;",
            icon("ban"), " When E[e|X] is non-zero across X, OLS estimates become biased and inconsistent.")
      ),
      mainPanel(width = 8,
        fluidRow(
          column(6, plotOutput("plot_exog_fit", height = "420px")),
          column(6, plotOutput("plot_exog_resid", height = "420px"))
        )
      )
    )
  ),

  # ==========================================
  # TAB 4: Homoscedasticity vs. Megaphone Variance
  # ==========================================
  tabPanel("4. Error Variance & Robust SEs",
    icon = icon("bullhorn"),
    sidebarLayout(
      sidebarPanel(width = 4,
        h4("Variance Spread Settings"),
        p("Homoscedasticity requires constant variance across all X. Heteroscedasticity creates a 'megaphone' expansion."),
        sliderInput("n_var", "Sample Size (n):", min = 50, max = 400, value = 150, step = 25),
        sliderInput("alpha_het", "Megaphone Expansion Coefficient (Alpha):", min = 0.0, max = 1.2, value = 0.45, step = 0.05),
        radioButtons("var_type", "Select Error Structure:",
                     choices = c("Homoscedastic (Constant Spread)" = "hom",
                                 "Heteroscedastic (Expanding Megaphone)" = "het"),
                     selected = "het"),
        hr(),
        div(class = "alert alert-success",
            style = "font-size: 0.88rem;",
            icon("check-circle"), " Under heteroscedasticity, OLS slopes remain unbiased, but standard errors must be computed using White's HC3 robust estimator.")
      ),
      mainPanel(width = 8,
        fluidRow(
          column(6, plotOutput("plot_var_resid", height = "400px")),
          column(6, plotOutput("plot_var_scale", height = "400px"))
        ),
        hr(),
        h5("OLS Standard Summary vs. HC3 Robust Inference Table"),
        verbatimTextOutput("table_var_summary")
      )
    )
  ),

  # ==========================================
  # TAB 5: Outliers, Leverage & Cook's Distance
  # ==========================================
  tabPanel("5. Outliers & Cook's Distance",
    icon = icon("magnet"),
    sidebarLayout(
      sidebarPanel(width = 4,
        h4("Outlier Coordinate Controller"),
        p("See how a single high-leverage observation pulls the OLS regression line like a magnet and how Cook's Distance ($D_i$) flags it."),
        sliderInput("out_x", "Outlier Predictor Position (X):", min = 1.0, max = 15.0, value = 12.0, step = 0.5),
        sliderInput("out_y", "Outlier Outcome Position (Y):", min = -10.0, max = 15.0, value = -3.0, step = 0.5),
        checkboxInput("show_rlm", "Overlay Robust Regression (MASS::rlm)", value = TRUE),
        hr(),
        div(class = "alert alert-info",
            style = "font-size: 0.9rem;",
            icon("lightbulb"), " Notice: When X is near the center (~4.5), vertical movement alters the intercept but exerts low leverage on the slope!")
      ),
      mainPanel(width = 8,
        fluidRow(
          column(6, plotOutput("plot_out_scatter", height = "420px")),
          column(6, plotOutput("plot_out_cooks", height = "420px"))
        )
      )
    )
  )
)

# Define Dynamic Server Logic
server <- function(input, output, session) {
  set.seed(42)
  
  # Reactive Data for Tab 1 (Linearity)
  data_lin <- reactive({
    n <- input$n_lin
    x <- seq(0, 5, length.out = n)
    y <- -5 + (x^3) + rnorm(n, 0, input$noise_lin)
    data.frame(x = x, y = y)
  })
  
  output$plot_lin_scatter <- renderPlot({
    df <- data_lin()
    p <- ggplot(df, aes(x = x, y = y)) +
      geom_point(color = "#f59e0b", size = 3, alpha = 0.85) +
      theme_shiny() +
      labs(title = "Observed Data & Model Fit",
           subtitle = ifelse(input$trans_mode == "linear", "Naive Linear Fit: y ~ x", "Polynomial Fit: y ~ I(x^3)"),
           x = "Predictor (X)", y = "Outcome (Y)")
    
    if (input$trans_mode == "linear") {
      mod <- lm(y ~ x, data = df)
      p <- p + geom_line(aes(y = predict(mod)), color = "#dc2626", linewidth = 1.4)
    } else {
      mod <- lm(y ~ I(x^3), data = df)
      p <- p + geom_line(aes(y = predict(mod)), color = "#1e293b", linewidth = 1.4)
    }
    p
  })
  
  output$plot_lin_resid <- renderPlot({
    df <- data_lin()
    mod <- if (input$trans_mode == "linear") lm(y ~ x, data = df) else lm(y ~ I(x^3), data = df)
    df_aug <- augment(mod)
    
    ggplot(df_aug, aes(x = .fitted, y = .resid)) +
      geom_point(color = ifelse(input$trans_mode == "linear", "#dc2626", "#16a34a"), size = 3, alpha = 0.8) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
      geom_smooth(method = "loess", se = FALSE, color = "#f97316", linewidth = 1.3) +
      theme_shiny() +
      labs(title = "Residuals vs. Fitted Values",
           subtitle = ifelse(input$trans_mode == "linear", "LOESS shows severe U-shaped curvature!", "LOESS stays flat along zero line"),
           x = "Fitted Values (Y-hat)", y = "Residuals")
  })
  
  # Reactive Data for Tab 2 (Range Subsetting)
  output$plot_range_subset <- renderPlot({
    n_sub <- 45
    x_low <- runif(n_sub, 0.2, 1.4)
    x_mid <- runif(n_sub, 2.2, 3.4)
    x_high <- runif(n_sub, 4.2, 5.4)
    
    b_glob <- input$global_slope
    b_loc <- input$local_tilt
    
    y_low <- (1.5 * b_glob) + b_loc * (x_low - 0.8) + rnorm(n_sub, 0, 0.5)
    y_mid <- (3.5 * b_glob) + b_loc * (x_mid - 2.8) + rnorm(n_sub, 0, 0.5)
    y_high <- (5.5 * b_glob) + b_loc * (x_high - 4.8) + rnorm(n_sub, 0, 0.5)
    
    df_all <- bind_rows(
      data.frame(x = x_low, y = y_low, group = "Lower 3rd (0 < X < 1.4)"),
      data.frame(x = x_mid, y = y_mid, group = "Middle 3rd (2 < X < 3.4)"),
      data.frame(x = x_high, y = y_high, group = "Upper 3rd (4 < X < 5.4)")
    )
    mod_glob <- lm(y ~ x, data = df_all)
    
    p <- ggplot(df_all, aes(x = x, y = y, color = group)) +
      geom_point(size = 3, alpha = 0.8) +
      geom_abline(intercept = coef(mod_glob)[1], slope = coef(mod_glob)[2], color = "#1e293b", linewidth = 1.6) +
      scale_color_manual(values = c("Lower 3rd (0 < X < 1.4)" = "#f59e0b", "Middle 3rd (2 < X < 3.4)" = "#16a34a", "Upper 3rd (4 < X < 5.4)" = "#f97316")) +
      theme_shiny() +
      labs(title = "Range Subsetting: Global Trend vs. Local Subsample Slopes",
           subtitle = paste0("Solid black line = Global OLS Slope (+", round(coef(mod_glob)[2], 2), ") vs Dashed Local Slopes"),
           x = "Predictor (X)", y = "Outcome (Y)", color = "Sample Subset")
    
    if (input$active_subset == "all" || input$active_subset == "lower") {
      p <- p + geom_smooth(data = filter(df_all, group == "Lower 3rd (0 < X < 1.4)"), method = "lm", se = FALSE, linetype = "dashed", linewidth = 1.3)
    }
    if (input$active_subset == "all" || input$active_subset == "middle") {
      p <- p + geom_smooth(data = filter(df_all, group == "Middle 3rd (2 < X < 3.4)"), method = "lm", se = FALSE, linetype = "dashed", linewidth = 1.3)
    }
    if (input$active_subset == "all" || input$active_subset == "upper") {
      p <- p + geom_smooth(data = filter(df_all, group == "Upper 3rd (4 < X < 5.4)"), method = "lm", se = FALSE, linetype = "dashed", linewidth = 1.3)
    }
    p
  })
  
  # Reactive Data for Tab 3 (Exogeneity)
  output$plot_exog_fit <- renderPlot({
    n <- 100
    x <- seq(0, 5, length.out = n)
    y_true <- x + rnorm(n, 0, 1)
    df <- data.frame(x = x, y = y_true)
    
    cand_int <- input$intercept_shift
    cand_slope <- input$slope_tilt
    
    ggplot(df, aes(x = x, y = y)) +
      geom_point(color = "#f59e0b", size = 2.8, alpha = 0.75) +
      geom_abline(intercept = 0, slope = 1, color = "#16a34a", linewidth = 1.4, linetype = "solid") +
      geom_abline(intercept = cand_int, slope = cand_slope, color = "#dc2626", linewidth = 1.5, linetype = "dashed") +
      theme_shiny() +
      labs(title = "Candidate Fit vs. True Relationship",
           subtitle = paste0("True OLS (Green, Y = X) vs Biased Candidate Line (Red, Y = ", cand_slope, "X + ", cand_int, ")"),
           x = "Predictor (X)", y = "Outcome (Y)")
  })
  
  output$plot_exog_resid <- renderPlot({
    n <- 100
    x <- seq(0, 5, length.out = n)
    y_true <- x + rnorm(n, 0, 1)
    
    cand_int <- input$intercept_shift
    cand_slope <- input$slope_tilt
    e_resid <- y_true - (cand_int + cand_slope * x)
    e_expect <- (1 - cand_slope) * x - cand_int
    
    df_res <- data.frame(x = x, resid = e_resid, expect = e_expect)
    
    ggplot(df_res, aes(x = x, y = resid)) +
      geom_point(color = "#f59e0b", size = 2.8, alpha = 0.75) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
      geom_line(aes(y = expect), color = "#dc2626", linewidth = 1.6) +
      theme_shiny() +
      labs(title = "Residuals & Expected Conditional Mean E[e|X]",
           subtitle = ifelse(cand_int == 0 && cand_slope == 1, "E[e|X] = 0 across all X (Exogeneity Satisfied!)", paste0("Biased E[e|X] = ", round(1-cand_slope, 2), "X - ", round(cand_int, 2), " (Exogeneity Violated!)")),
           x = "Predictor (X)", y = "Residuals (e_i)")
  })
  
  # Reactive Data for Tab 4 (Hom vs Het Variance)
  data_var <- reactive({
    n <- input$n_var
    x <- runif(n, 1, 10)
    if (input$var_type == "hom") {
      y <- 3 + 2 * x + rnorm(n, 0, 0.6)
    } else {
      y <- 3 + 2 * x + rnorm(n, 0, input$alpha_het * x)
    }
    mod <- lm(y ~ x)
    augment(mod)
  })
  
  output$plot_var_resid <- renderPlot({
    df <- data_var()
    p <- ggplot(df, aes(x = .fitted, y = .resid)) +
      geom_point(color = ifelse(input$var_type == "hom", "#2563eb", "#dc2626"), size = 2.8, alpha = 0.8) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "#1e293b", linewidth = 1.1) +
      geom_smooth(method = "loess", se = FALSE, color = "#f97316", linewidth = 1.3) +
      theme_shiny() +
      labs(title = "Residuals vs Fitted Values",
           subtitle = ifelse(input$var_type == "hom", "Uniform parallel spread across fitted range", "Expanding megaphone spread as fitted values increase"),
           x = "Fitted Values (Y-hat)", y = "Residuals")
    p
  })
  
  output$plot_var_scale <- renderPlot({
    df <- data_var() %>% mutate(sqrt_abs = sqrt(abs(.std.resid)))
    ggplot(df, aes(x = .fitted, y = sqrt_abs)) +
      geom_point(color = ifelse(input$var_type == "hom", "#2563eb", "#dc2626"), size = 2.8, alpha = 0.8) +
      geom_smooth(method = "loess", se = FALSE, color = "#f97316", linewidth = 1.3) +
      theme_shiny() +
      labs(title = "Scale-Location Diagnostic Chart",
           subtitle = ifelse(input$var_type == "hom", "Flat LOESS line signals constant variance", "Upward sloping LOESS line signals variance growth"),
           x = "Fitted Values (Y-hat)", y = expression(sqrt("|Standardized Residuals|")))
  })
  
  output$table_var_summary <- renderPrint({
    df <- data_var()
    mod <- lm(df$y ~ df$x)
    cat("1. Standard OLS Summary:\n")
    print(summary(mod)$coefficients)
    cat("\n2. White's HC3 Robust Covariance Estimates:\n")
    if (requireNamespace("sandwich", quietly = TRUE) && requireNamespace("lmtest", quietly = TRUE)) {
      print(lmtest::coeftest(mod, vcov = sandwich::vcovHC(mod, type = "HC3")))
    } else {
      cat("(Install 'sandwich' and 'lmtest' packages in R to view HC3 coefficient tests)\n")
    }
  })
  
  # Reactive Data for Tab 5 (Outliers & Cook's D)
  data_out <- reactive({
    n_c <- 14
    x_c <- seq(1, 8, length.out = n_c)
    y_c <- 1 + 1.2 * x_c + rnorm(n_c, 0, 0.5)
    
    df <- data.frame(
      id = 1:(n_c + 1),
      x = c(x_c, input$out_x),
      y = c(y_c, input$out_y),
      type = c(rep("Standard Observation", n_c), "Interactive Outlier Point")
    )
    df
  })
  
  output$plot_out_scatter <- renderPlot({
    df <- data_out()
    mod_all <- lm(y ~ x, data = df)
    mod_clean <- lm(y ~ x, data = filter(df, type == "Standard Observation"))
    
    xg <- seq(0, 16, length.out = 100)
    df_lines <- bind_rows(
      data.frame(x = xg, y = predict(mod_clean, newdata = data.frame(x = xg)), model = "Clean OLS Without Outlier"),
      data.frame(x = xg, y = predict(mod_all, newdata = data.frame(x = xg)), model = paste0("OLS With Outlier (Slope = ", round(coef(mod_all)[2], 2), ")"))
    )
    
    p <- ggplot(df, aes(x = x, y = y)) +
      geom_point(aes(color = type, size = type), alpha = 0.85) +
      geom_line(data = df_lines, aes(x = x, y = y, color = model, linetype = model), linewidth = 1.4) +
      scale_color_manual(values = c("Standard Observation" = "#2563eb", "Interactive Outlier Point" = "#dc2626",
                                    "Clean OLS Without Outlier" = "#16a34a", 
                                    paste0("OLS With Outlier (Slope = ", round(coef(mod_all)[2], 2), ")") = "#dc2626")) +
      scale_size_manual(values = c("Standard Observation" = 3.5, "Interactive Outlier Point" = 6)) +
      theme_shiny() +
      labs(title = "Interactive Outlier Influence on OLS Line",
           subtitle = paste0("Outlier positioned at X = ", input$out_x, ", Y = ", input$out_y),
           x = "Predictor (X)", y = "Outcome (Y)")
    
    if (input$show_rlm && requireNamespace("MASS", quietly = TRUE)) {
      mod_rlm <- MASS::rlm(y ~ x, data = df)
      df_rlm <- data.frame(x = xg, y = predict(mod_rlm, newdata = data.frame(x = xg)), model = paste0("Robust MASS::rlm (Slope = ", round(coef(mod_rlm)[2], 2), ")"))
      p <- p + geom_line(data = df_rlm, aes(x = x, y = y), color = "#9333ea", linewidth = 1.4, linetype = "dotdash")
    }
    p
  })
  
  output$plot_out_cooks <- renderPlot({
    df <- data_out()
    mod_all <- lm(y ~ x, data = df)
    df_aug <- augment(mod_all) %>%
      mutate(id = row_number(),
             threshold = 4 / n(),
             is_influential = .cooksd > threshold)
    
    ggplot(df_aug, aes(x = id, y = .cooksd)) +
      geom_segment(aes(xend = id, yend = 0, color = is_influential), linewidth = 1.2) +
      geom_point(aes(color = is_influential), size = 4) +
      geom_hline(yintercept = 4/nrow(df), linetype = "dashed", color = "#dc2626", linewidth = 1.2) +
      scale_color_manual(values = c("FALSE" = "#2563eb", "TRUE" = "#dc2626"), name = "Undue Influence (D > 4/n)") +
      theme_shiny() +
      labs(title = "Cook's Distance Diagnostic Bar Chart",
           subtitle = paste0("Dashed red line = Critical threshold (4/n = ", round(4/nrow(df), 3), ")"),
           x = "Observation Index (i)", y = "Cook's Distance (D_i)")
  })
}

# Run the R Shiny Application
shinyApp(ui = ui, server = server)

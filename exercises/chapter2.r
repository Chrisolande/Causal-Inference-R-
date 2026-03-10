
# Chapter 2: Exercise on Lalonde Job Training Data


options(warn = -1)

librarian::shelf(
  tidyverse, tidymodels,
  MatchIt, dagitty, ggdag,
  propensity, halfmoon, paletteer,
  tipr
)

# Load Data

data <- MatchIt::lalonde

head(data)
tail(data)

# DAG


lalonde_dag <- dagitty('
  dag {
    treat -> re78
    age -> treat ; age -> re78
    educ -> treat ; educ -> re78
    race -> treat ; race -> re78
    married -> treat ; married -> re78
    nodegree -> treat ; nodegree -> re78
    re74 -> treat ; re74 -> re78
    re75 -> treat ; re75 -> re78
    re74 -> re75
    educ -> nodegree
    age -> re74 ; age -> re75
  }
')

ggdag(lalonde_dag, layout = "sugiyama") +
  theme_dag() +
  geom_dag_point(color = "#4a6741", size = 14) +
  geom_dag_text(color = "white", size = 3, family = "Source Sans 3") +
  geom_dag_edges(edge_color = "#7a6a58") +
  labs(title = "Lalonde DAG — Job Training and 1978 Earnings") +
  theme(
    plot.title       = element_text(family = "Source Serif 4", size = 13,
                                    margin = margin(b = 12), color = "#3d3228"),
    plot.background  = element_rect(fill = "#faf8f3", color = NA),
    panel.background = element_rect(fill = "#faf8f3", color = NA)
  )

adjustmentSets(lalonde_dag, exposure = "treat", outcome = "re78")



# Exploratory Analysis


# Earnings distribution by treatment
ggplot(data, aes(x = re78, fill = as.factor(treat))) +
  geom_density() +
  paletteer::scale_fill_paletteer_d("ggsci::default_jco") +
  scale_x_continuous(labels = scales::label_number(scale = 1e-3, suffix = "k")) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 4),
                     labels = scales::label_number()) +
  labs(
    title = "Distribution of Earnings in 1978 by Job Assignment",
    x     = "Earnings in 1978 (Thousands)",
    y     = "Density",
    fill  = "Treatment Group"
  )

# Naive group means
data %>%
  group_by(treat) %>%
  summarise(mean_re78 = mean(re78))

# Unadjusted estimate
linear_reg() %>%
  set_engine("lm") %>%
  fit(re78 ~ treat, data = data) %>%
  tidy()

# Propensity Score Estimation


lalonde_f <- lalonde %>%
  mutate(treat = as.factor(treat))

propensity_model <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(
    treat ~ age + educ + race + married + nodegree + re74 + re75,
    data = lalonde_f
  )

tidy(propensity_model$fit)

# Append propensity scores and ATT weights
lalonde_wts <- lalonde_f %>%
  bind_cols(
    propensity_model %>%
      predict(lalonde_f, type = "prob") %>%
      rename(.fitted = .pred_1)
  ) %>%
  mutate(wts = wt_att(.fitted, treat))

lalonde_wts %>%
  select(treat, .fitted, wts) %>%
  head()



# Balance Assessment


# Propensity score overlap, unweighted
ggplot(lalonde_wts, aes(.fitted)) +
  geom_mirror_histogram(aes(fill = treat), bins = 50,
                        color = "white", linewidth = 0.2) +
  scale_fill_paletteer_d("ggsci::default_jco") +
  labs(
    title = "Propensity Score Distribution by Treatment Group",
    x     = "Estimated Propensity Score",
    fill  = "Treatment Group"
  )

# Propensity score overlap, unweighted vs weighted
ggplot(lalonde_wts, aes(.fitted)) +
  geom_mirror_histogram(aes(fill = treat), bins = 50,
                        color = "white", linewidth = 0.2) +
  geom_mirror_histogram(aes(fill = treat, weight = wts), bins = 50,
                        color = "white", linewidth = 0.2, alpha = 0.5) +
  scale_fill_paletteer_d("ggsci::default_jco") +
  labs(
    title = "Propensity Score Distribution by Treatment Group",
    x     = "Estimated Propensity Score",
    fill  = "Treatment Group"
  )

# SMD love plot
plot_df <- tidy_smd(
  lalonde_wts,
  c(age, educ, race, re75, married, nodegree, re74),
  .group = treat,
  .wts   = wts
)

ggplot(plot_df, aes(x = abs(smd), y = variable, group = method, color = method)) +
  geom_love() +
  labs(
    x     = "Absolute Value of SMD",
    y     = "Variable",
    title = "Covariate Balancing Before and After ATT Weighting"
  )

# ATT weight distribution
ggplot(lalonde_wts, aes(as.numeric(wts))) +
  geom_density(fill = "#4a6741", color = NA, alpha = 0.75) +
  geom_vline(
    xintercept = median(as.numeric(lalonde_wts$wts)),
    color      = "#8b4513", linewidth = 0.7, linetype = "dashed"
  ) +
  annotate(
    "text",
    x      = median(as.numeric(lalonde_wts$wts)) + 0.05,
    y      = 0.8,
    label  = paste("Median:", round(median(as.numeric(lalonde_wts$wts)), 2)),
    color  = "#8b4513", size = 3.5, hjust = 0, family = "Source Sans 3"
  ) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6)) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 5), expand = c(0, 0)) +
  labs(
    x        = "ATT Weight",
    y        = "Density",
    title    = "Distribution of ATT Weights",
    subtitle = "Bimodal structure reflects treated units (weight = 1) and reweighted controls"
  ) +
  theme_minimal(base_family = "Source Sans 3", base_size = 12) +
  theme(
    plot.title       = element_text(family = "Source Serif 4", size = 13,
                                    margin = margin(b = 4), color = "#3d3228"),
    plot.subtitle    = element_text(size = 10, color = "#7a6a58",
                                    margin = margin(b = 12)),
    axis.text        = element_text(color = "#7a6a58", size = 10),
    axis.title       = element_text(color = "#7a6a58", size = 10),
    axis.title.x     = element_text(margin = margin(t = 8)),
    axis.title.y     = element_text(margin = margin(r = 8)),
    panel.grid.major = element_line(color = "#e8dece", linewidth = 0.4),
    panel.grid.minor = element_blank(),
    plot.background  = element_rect(fill = "#faf8f3", color = NA),
    panel.background = element_rect(fill = "#faf8f3", color = NA),
    plot.margin      = margin(16, 20, 12, 16)
  )



# Weighted Outcome Model


lalonde_wts <- lalonde_wts %>%
  mutate(case_wts = importance_weights(as.numeric(wts)))

linear_reg() %>%
  set_engine("lm") %>%
  fit(re78 ~ treat, data = lalonde_wts, case_weights = lalonde_wts$case_wts) %>%
  tidy(conf.int = TRUE)

# Sanity check via weighted group means
lalonde_wts %>%
  group_by(treat) %>%
  summarise(mean_re78 = weighted.mean(re78, as.numeric(wts)))



# Bootstrap Inference


fit_ipw <- function(.split, ...) {
  .df <- as.data.frame(.split)

  propensity_model <- glm(
    treat ~ age + educ + race + married + nodegree + re74 + re75,
    data   = .df,
    family = binomial()
  )

  .df <- propensity_model %>%
    augment(type.predict = "response", data = .df) %>%
    mutate(wts = wt_att(.fitted, treat))

  lm(re78 ~ treat, data = .df, weights = wts) %>%
    tidy()
}

bootstrapped_lalonde <- bootstraps(lalonde, times = 1000, apparent = TRUE)

suppressMessages({
  ipw_results <- bootstrapped_lalonde %>%
    mutate(boot_fits = map(splits, fit_ipw))
})

# Bootstrap distribution of ATT estimates
ipw_results %>%
  filter(id != "Apparent") %>%
  mutate(
    estimate = map_dbl(
      boot_fits,
      \(.fit) .fit %>% filter(term == "treat") %>% pull(estimate)
    )
  ) %>%
  ggplot(aes(estimate)) +
  geom_histogram(fill = "#D55E00FF", color = "white", alpha = 0.8, binwidth = 100) +
  labs(
    x     = "Bootstrapped ATT Estimate",
    y     = "Count",
    title = "Bootstrap Distribution of IPW Estimates"
  )

# T-statistic bootstrap CIs
boot_estimate <- ipw_results %>%
  int_t(boot_fits) %>%
  filter(term == "treat")

boot_estimate



# Sensitivity Analysis


# Tipping point analysis
tipping_points <- tip_coef(boot_estimate$.upper, exposure_confounder_effect = 1:5)

tipping_points %>%
  ggplot(aes(confounder_outcome_effect, exposure_confounder_effect)) +
  geom_line(color = "#009E73", linewidth = 1.1) +
  geom_point(fill = "#009E73", color = "white", size = 2.5, shape = 21) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
  annotate(
    "text",
    x     = max(tipping_points$confounder_outcome_effect),
    y     = 1.15,
    label = "Minimum confounder imbalance",
    hjust = 1, size = 3.5, color = "gray40"
  ) +
  labs(
    x        = "Confounder-Outcome Effect",
    y        = "Scaled mean differences in\nconfounder between exposure groups",
    title    = "Tipping Point Sensitivity Analysis",
    subtitle = "Combinations that would nullify the upper CI bound"
  )

# Bias-adjusted estimates under assumed unmeasured confounder
adjusted_estimates <- boot_estimate %>%
  select(.estimate, .lower, .upper) %>%
  unlist() %>%
  adjust_coef_with_binary(
    exposed_confounder_prev   = 0.26,
    unexposed_confounder_prev = 0.05,
    confounder_outcome_effect = -10
  )

adjusted_estimates
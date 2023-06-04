# Ensemble Model

# Load package(s) ----
library(tidymodels)
library(tidyverse)
library(stacks)
library(doMC)

## Unix and macOS only
registerDoMC(cores = 5)

# Handle common conflicts
tidymodels_prefer()

# Load candidate model info ----
load("ensemble_files/rf_res.rda")
load("ensemble_files/knn_res.rda")

# Load in tuning data
load('results/initial_setup.rda')
load("recipes/recipe1")

# Create data stack ----
data_st <- 
  stacks() %>%
  add_candidates(rf_res) %>%
  add_candidates(knn_res)

save(data_st, file = "results/data_st.rda")

# Fit the stack ----
# penalty values for blending (set penalty argument when blending)
blend_penalty <- c(10^(-6:-1), 0.5, 1, 1.5, 2)

# Blend predictions using penalty defined above (tuning step, set seed)
set.seed(3013)

model_st <-
  data_st %>%
  blend_predictions(penalty = blend_penalty)

# fit to ensemble to entire training set ----
fitted_model_st <-
  model_st %>%
  fit_members()

save(fitted_model_st, file = "results/fitted_model_stack.rda")

load("results/fitted_model_stack.rda")

# Explore and assess trained ensemble model
assess <- credit_test %>%
  bind_cols(predict(fitted_model_st, .))

save(assess, file = "results/assess.rda")

# obtain probability of category
ensemble_prob <- predict(fitted_model_st, credit_test, type = "prob")

# bind cols together
ensemble_prob <- credit_test %>% 
  select(id) %>% 
  select(id, .pred_1) %>% 
  rename(y = .pred_1)

assess_table <- assess %>% 
  select(id, .pred_class) %>% 
  rename(y = .pred_class)

write_csv(assess_table, file = "tuned_models/ensemble_model.csv")

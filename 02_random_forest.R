# Random Forest

# Load packages
library(tidyverse)
library(tidymodels)
library(doMC)

# Seed
set.seed(3013)

# Handle common conflicts
tidymodels_prefer()

# Load in tuning data
load("results/initial_setup.rda")

# Set up parallel processing -----
## Unix and macOS only
registerDoMC(cores = 5)

# Write model
rf_model <- rand_forest(mode = "classification",
                        min_n = tune(),
                        mtry = tune(),
                        trees = 100) %>% 
  set_engine("ranger", importance = "impurity")

# Params 
rf_params <- parameters(rf_model) %>% 
  recipes::update(mtry = mtry(range = c(5, 10)))

# Create grid 
rf_grid <- grid_regular(rf_params, levels = 5)

# Recipe 1 ################################################################
load("recipes/recipe1")

rf_workflow1 <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(recipe1)

save(rf_workflow1, file = "results/rf_workflow1.rda")

# Random forest
rf_tuned1 <- tune_grid(rf_workflow1,
                      folds,
                      grid = rf_grid,
                      control = control_grid(save_pred = TRUE,
                                             save_workflow = TRUE,
                                             verbose = TRUE,
                                             parallel_over = "everything"))

save(rf_tuned1,
     file = "results/rf_tuned1b.rda")

load("results/rf_tuned1b.rda")

# 0.683
rf_tuned1 %>% 
  show_best()

# Recipe 2 ###############################################################

load("recipes/recipe2")

rf_workflow2 <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(recipe2)

# Random forest
rf_tuned2 <- tune_grid(rf_workflow2,
                       folds,
                       grid = rf_grid,
                       control = control_grid(save_pred = TRUE,
                                              save_workflow = TRUE,
                                              verbose = TRUE,
                                              parallel_over = "everything"))

save(rf_tuned2,
     file = "results/rf_tuned2.rda")

load("results/rf_tuned2.rda")

# 0.504
rf_tuned2 %>% 
  show_best()

# svm rbf tuning ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)
library(stacks)
library(doMC)

set.seed(3013)

# Handle common conflicts
tidymodels_prefer()

# Load in tuning data
load("results/initial_setup.rda")
load("recipes/recipe1")

## Unix and macOS only
registerDoMC(cores = 5)

# Define model ----
# Set up poly model
svm_poly_model <- svm_poly(
  mode = "classification",
  cost = tune(),
  degree = tune(),
  scale_factor = tune()
) %>%
  set_engine("kernlab")

# Params
svm_poly_params <- parameters(svm_poly_model)

# Create grid 
svm_poly_grid <- grid_regular(svm_poly_params, levels = 5)

# Set up workflow
svm_poly_workflow <- workflow() %>% 
  add_model(svm_poly_model) %>% 
  add_recipe(recipe1)

ctrl_grid <- control_stack_grid()

# Tune model
svm_poly_res <- tune_grid(svm_poly_workflow, 
                          folds,
                          grid = svm_poly_grid,
                          control = ctrl_grid)

# Write out results & workflow
save(svm_poly_res, file = "ensemble_files/svm_radial_res.rda")




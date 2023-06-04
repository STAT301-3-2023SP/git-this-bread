# Knn tuning ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)
library(stacks)

# Seed
set.seed(3013)

# Handle common conflicts
tidymodels_prefer()


# Load in tuning data
load("results/initial_setup.rda")
load("recipes/recipe1")

# Define model ----
knn_model <- nearest_neighbor(
  mode = "classification",
  neighbors = tune()
) %>%
  set_engine("kknn")


# set-up tuning grid ----
knn_params <- hardhat::extract_parameter_set_dials(knn_model) %>%
  update(neighbors = neighbors(range = c(1,40)))

# define grid
knn_grid <- grid_regular(knn_params, levels = 15)

# workflow ----
knn_workflow <- workflow() %>%
  add_model(knn_model) %>%
  add_recipe(recipe1)

keep_pred <- control_resamples(save_pred = TRUE)

ctrl_grid <- control_stack_grid()

# Tuning/fitting ----
knn_res <- knn_workflow %>%
  tune_grid(
    resamples = folds,
    grid = knn_grid,
    control = ctrl_grid
  )

# Write out results & workflow
save(knn_res, file = "ensemble_files/knn_res.rda")
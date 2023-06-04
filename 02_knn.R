# KNN

# Load packages
library(tidyverse)
library(tidymodels)
library(tictoc)
library(doMC)

# Handle common conflicts
tidymodels_prefer()

# Load in tuning data
load("results/initial_setup.rda")
load("recipes/recipe1")

# Set up parallel processing -----
## Unix and macOS only
registerDoMC(cores = 5)

# Create model
knn_model <- nearest_neighbor(mode = "classification",
                              neighbors = tune()) %>% 
  set_engine("kknn")

# Params 
knn_params <- parameters(knn_model)

# Create grid 
knn_grid <- grid_regular(knn_params, levels = 5)

# Random forest
knn_workflow1 <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(recipe1)


# Tune model
knn_tuned1 <- tune_grid(knn_workflow1, 
                        folds,
                        grid = knn_grid,
                        control = control_grid(save_pred = TRUE, 
                                               save_workflow = TRUE,
                                               verbose = TRUE,
                                               parallel_over = "everything"))

#save as rda
save(knn_tuned1,
     file = "results/knn_tuned1.rda")

load("results/knn_tuned1.rda")

# 0.646
knn_tuned1 %>% 
  show_best()

# Recipe 2 ##################################################################

load("recipes/recipe2")

# Random forest
knn_workflow2 <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(recipe2)


# Tune model
knn_tuned2 <- tune_grid(knn_workflow2, 
                        folds,
                        grid = knn_grid,
                        control = control_grid(save_pred = TRUE, 
                                               save_workflow = TRUE,
                                               verbose = TRUE,
                                               parallel_over = "everything"))

#save as rda
save(knn_tuned2,
     file = "results/knn_tuned2.rda")

load("results/knn_tuned2.rda")

# 0.504
knn_tuned2 %>% 
  show_best()

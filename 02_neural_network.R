# Neural Network

# Load packages
library(tidyverse)
library(tidymodels)
library(doMC)

# Handle common conflicts
tidymodels_prefer()

# Load in tuning data
load("results/initial_setup.rda")

# Set up parallel processing -----
## Unix and macOS only
registerDoMC(cores = 5)

# Set up model 
nn_model <- mlp(
  mode = "classification",
  hidden_units = tune(),
  penalty = tune()
) %>%
  set_engine("nnet")

# Params
nn_params <- hardhat::extract_parameter_set_dials(nn_model)

# Create grid 
nn_grid <- grid_regular(nn_params, levels = 5)

# Recipe 1 ####################################################################

load("recipes/recipe1")
# Set up workflow
nn_workflow1 <- workflow() %>% 
  add_model(nn_model) %>% 
  add_recipe(recipe1)

# Tune model
nn_tuned1 <- tune_grid(nn_workflow1, 
                       folds,
                       grid = nn_grid,
                       control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                              save_workflow = TRUE, # Lets you use extract_workflow
                                              verbose = TRUE,
                                              parallel_over = "everything")) 


#save as rda
save(nn_tuned1,
     file = "results/nn_tuned1.rda")

load('results/nn_tuned1.rda')

# .559
nn_tuned1 %>% 
  show_best()

# Recipe 2 ###############################################################

load("recipes/recipe2")

# Set up workflow
nn_workflow2 <- workflow() %>% 
  add_model(nn_model) %>% 
  add_recipe(recipe2)

# Tune model
nn_tuned2 <- tune_grid(nn_workflow2, 
                       folds,
                       grid = nn_grid,
                       control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                              save_workflow = TRUE, # Lets you use extract_workflow
                                              verbose = TRUE,
                                              parallel_over = "everything")) 


#save as rda
save(nn_tuned2,
     file = "results/nn_tuned2.rda")

load('results/nn_tuned2.rda')

# .520
nn_tuned2 %>% 
  show_best()
# SVM Polynomial

# Load packages
library(tidyverse)
library(tidymodels)
library(tictoc)
library(doMC)
library(kernlab)

# Handle common conflicts
tidymodels_prefer()

# Load in tuning data
load("results/initial_setup.rda")

# Set up parallel processing -----
## Unix and macOS only
registerDoMC(cores = 5)

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

# Recipe 1 #################################################################

load("recipes/recipe1")

# Set up workflow
svm_poly_workflow1 <- workflow() %>% 
  add_model(svm_poly_model) %>% 
  add_recipe(recipe1)


# Tune model
svm_poly_tuned1 <- tune_grid(svm_poly_workflow1, 
                             folds,
                             grid = svm_poly_grid,
                             control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                                    save_workflow = TRUE, # Lets you use extract_workflow
                                                    verbose = TRUE,
                                                    parallel_over = "everything")) 



#save as rda
save(svm_poly_tuned1,
     file = "results/svm_poly_tuned1.rda")

load("results/svm_poly_tuned1.rda")

# .581
svm_poly_table <- svm_poly_tuned1 %>% 
  show_best()

save(svm_poly_table, file = "results/svm_poly_table.rda")

# Recipe 2 ############################################################
load("recipes/recipe2")

# Set up workflow
svm_poly_workflow2 <- workflow() %>% 
  add_model(svm_poly_model) %>% 
  add_recipe(recipe2)


# Tune model
svm_poly_tuned2 <- tune_grid(svm_poly_workflow2, 
                             folds,
                             grid = svm_poly_grid,
                             control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                                    save_workflow = TRUE, # Lets you use extract_workflow
                                                    verbose = TRUE,
                                                    parallel_over = "everything")) 



#save as rda
save(svm_poly_tuned2,
     file = "results/svm_poly_tuned2.rda")
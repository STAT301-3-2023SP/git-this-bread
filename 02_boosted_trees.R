# Boosted Trees

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

# Create model
boost_model <- boost_tree(mode = "classification",
                          min_n = tune(),
                          mtry = tune(),
                          learn_rate = tune()) %>% 
  set_engine("xgboost", importance = "impurity")

# Params
boost_params <- parameters(boost_model) %>% 
  update(mtry = mtry(range = c(1,10))) %>% 
  update(learn_rate = learn_rate(range = c(-5, -0.2)))

# Create grid 
boost_grid <- grid_regular(boost_params, levels = 5)

# Recipe 1 ##############################################################

load("recipes/recipe1")

# Random forest
boost_workflow1 <- workflow() %>% 
  add_model(boost_model) %>% 
  add_recipe(recipe1)


# Random forest
boost_tuned1 <- tune_grid(boost_workflow1, 
                          folds,
                          grid = boost_grid,
                          control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                                 save_workflow = TRUE, # Lets you use extract_workflow
                                                 verbose = TRUE,
                                                 parallel_over = "everything")) 


#save as rda
save(boost_tuned1,
     file = "results2/boost_tuned1.rda")

load("results/boost_tuned1.rda")

# Recipe 2 #############################################################

load("recipes/recipe2")

# Random forest
boost_workflow2 <- workflow() %>% 
  add_model(boost_model) %>% 
  add_recipe(recipe2)

# Random forest
boost_tuned2 <- tune_grid(boost_workflow2, 
                          folds,
                          grid = boost_grid,
                          control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                                 save_workflow = TRUE, # Lets you use extract_workflow
                                                 verbose = TRUE,
                                                 parallel_over = "everything")) 


#save as rda
save(boost_tuned2,
     file = "results/boost_tuned2.rda")

load("results/boost_tuned2.rda")
# Mars

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


# Recipe 1 ###########################################################

# Load recipe 1
load("recipes/recipe1")

# Set up model -----
mars_model <- mars(
  mode = "classification",
  num_terms = tune(),
  prod_degree = tune()
) %>%
  set_engine("earth")

# Params
mars_params <- parameters(mars_model) %>% 
  update(num_terms = num_terms(range = c(1, 5)))

# Create grid 
mars_grid <- grid_regular(mars_params, levels = 5)

# Set up workflow
mars_workflow1 <- workflow() %>% 
  add_model(mars_model) %>% 
  add_recipe(recipe1)


# Random forest
mars_tuned1 <- tune_grid(mars_workflow1, 
                         folds,
                         grid = mars_grid,
                         control = control_grid(save_pred = TRUE, # Create an extra column for each prediction
                                                save_workflow = TRUE, # Lets you use extract_workflow
                                                verbose = TRUE,
                                                parallel_over = "everything")) 

#save as rda
save(mars_tuned1,
     file = "results/mars_tuned1.rda")

load("results/mars_tuned1.rda")

mars_tuned1 %>% 
  show_best()


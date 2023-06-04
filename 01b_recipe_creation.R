# Variable selection

#load package(s)
library(tidymodels)
library(tidyverse)
library(doMC)
library(parallel)
library(naniar)
library(knitr)
library(corrplot)
library(ggcorrplot)

#handle common conflicts
tidymodels_prefer()

#set seed
set.seed(3013)

load("results/initial_setup.rda")

# Recipe 1 ######################################################

recipe1 <- recipe(status ~ ., data = training_small) %>%
  step_rm(id, flag_mobil, flag_work_phone, flag_phone, flag_email, months_balance) %>% 
  # Remove variables with zero variance
  step_nzv(all_predictors()) %>% 
  # Impute missing values for numeric predictors
  step_impute_mean(all_numeric_predictors()) %>% 
  # impute missing categorical predictors
  step_impute_mode(all_factor_predictors()) %>% 
  # Remove highly correlated predictors 
  step_corr(all_numeric_predictors()) %>% 
  # Center and scale all predictors
  step_normalize(all_numeric_predictors()) %>% 
  step_YeoJohnson(all_numeric_predictors())

save(recipe1, file = "recipes/recipe1")

# Recipe 2 ######################################################

recipe2 <- recipe(status ~ name_income_type + name_education_type + name_family_status + name_housing_type, data = training_small) %>%
  # Remove variables with zero variance
  step_nzv(all_predictors()) %>% 
  # Impute missing values for numeric predictors
  step_impute_mean(all_numeric_predictors()) %>% 
  # impute missing categorical predictors
  step_impute_mode(all_factor_predictors()) %>% 
  step_dummy(all_nominal_predictors()) %>%
  # Remove highly correlated predictors 
  step_corr(all_numeric_predictors()) %>% 
  # Center and scale all predictors
  step_normalize(all_numeric_predictors()) %>% 
  step_YeoJohnson(all_numeric_predictors())

save(recipe2, file = "recipes/recipe2")





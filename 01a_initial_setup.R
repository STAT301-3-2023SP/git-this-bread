# Initial Setup


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

load('data/processed/credit_processed.rda')

# Initial split ######################################

credit_split <- initial_split(data = credit, prop = 0.80, strata = status)

credit_test <- testing(credit_split)
credit_train <- training(credit_split)

# Create subset of data ######################################

#create smaller subset
library(splitstackshape)

# Assuming 'credit' is the merged data frame
training_small <- stratified(credit, "status", size = 0.02, keep.rownames = FALSE)

training_small %>%
  group_by(status) %>%
  summarize(count = n())

# Create folds ###############################################

folds <- vfold_cv(training_small, v = 5, repeats = 3, 
                               strata = status)


# Save needed files ###############################################
save(training_small, credit_test, folds, file = "results/initial_setup.rda")

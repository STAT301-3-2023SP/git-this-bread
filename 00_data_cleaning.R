# Data Cleaning

# Load package(s) ####################################################
library(tidymodels)
library(tidyverse)
library(doMC)

# handle common conflicts
tidymodels_prefer()

# Set up parallel processing
registerDoMC(cores = 5)

# Load in Data ####################################################

application_record <- read_csv("data/raw/application_record.csv") %>%
  janitor::clean_names()

credit_record <- read_csv("data/raw/credit_record.csv") %>%
  janitor::clean_names()

# Merge data sets ####################################################
credit <- merge(application_record, credit_record, by = "id") %>% 
  mutate(status = factor(status, levels = c(0, 1, 2, 3, 4, 5, "C", "X"),
                       labels = c("bad", "bad", "bad", "bad","bad","bad", "good", "no loan")))

credit %>% 
  group_by(status) %>% 
  summarize(count = n())


save(credit, file = 'data/processed/credit_processed.rda')
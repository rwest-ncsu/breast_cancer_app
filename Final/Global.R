library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(readr)

data = read_csv("Breast_cancer_data.csv")
data = data %>% mutate(diagnosis = as.factor(diagnosis))
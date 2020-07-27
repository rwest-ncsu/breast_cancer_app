library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(readr)
library(plotly)
library(DT)
library(knitr)
library(tree)
library(gbm)
library(randomForest)
library(caret)
library(class)
library(shinybusy)

data = read_csv("Breast_cancer_data.csv")
data = data %>% dplyr::transmute(
  Diagnosis = factor(diagnosis, levels = c(0, 1), labels = c("Non-Cancerous", "Cancerous")),
  Radius = mean_radius,
  Texture = mean_texture,
  Perimeter = mean_perimeter,
  Area = mean_area,
  Smoothness = mean_smoothness)

set.seed(623)


train = sample(1:nrow(data), size=nrow(data)*0.7)
test = dplyr::setdiff(1:nrow(data), train)

data_train = data[train, ]
data_test = data[test, ]

varNames = names(data%>%dplyr::select(-Diagnosis))

modelChoices = c("Single Tree", "Bagged Tree", "Random Forest", "Boosted Tree", "KNN", "Logistic Regression")
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


data = read_csv("Breast_cancer_data.csv")
data = data %>% dplyr::transmute(
  Diagnosis = factor(diagnosis, levels = c(0, 1), labels = c("Non-Cancerous", "Cancerous")),
  Radius = mean_radius,
  Texture = mean_texture,
  Perimeter = mean_perimeter,
  Area = mean_area,
  Smoothness = mean_smoothness)



varNames = names(data%>%dplyr::select(-Diagnosis))
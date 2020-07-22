#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(readr)
 
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    data = read_csv("Breast_cancer_data.csv")
    
    set.seed(122)
    histdata = rnorm(500)
    
    output$plot1 = renderPlot({
        hist(histdata)
    })
    
    output$table1 = renderTable({
        head(data)
    })
})

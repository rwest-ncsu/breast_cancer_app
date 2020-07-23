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
    
    #Read in the data for the analysis
    data = read_csv("Breast_cancer_data.csv")
    data = data  %>%  mutate(diagnosis = as.factor(diagnosis))

    
    output$plot1 = renderPlot({
        
        
        if(input$plotType == "Bar"){
            #Create the single Bar plot
            ggplot(data=data, aes(x=diagnosis))+
                geom_bar(aes(fill=diagnosis))
        } else if(input$plotType == "Histogram"){
            #Create the Histogram plot 
            if(input$colorCodeHist){
                ggplot(data=data, aes(x=mean_radius))+
                    geom_histogram(aes(fill=diagnosis), position="dodge")    
            } else {
                ggplot(data=data, aes(x=mean_radius))+
                    geom_histogram(color="blue", bins = 50)    
            }
        } else if(input$plotType == "Scatter"){
            #Create Scatter Plots
            if(input$colorCodeScatter){
                ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=diagnosis))
            } else {
                ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="red")
            }
        }   
    })
    
    output$table1 = renderTable({
        head(data)
    })
    
    output$kmeansPlot = renderPlot({
        ggplot(data=data, aes(x=mean_radius, y=mean_texture))+
            geom_point(size=3)
    })
})

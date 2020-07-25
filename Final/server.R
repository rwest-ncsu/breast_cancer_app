#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(readr)
library(plotly)
source("Global.R")
 
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
        

    
    output$summaryPlot = renderPlotly({
        
        if(input$plotType == "Bar"){
            #Create the single Bar plot
            g = ggplot(data=data, aes(x=diagnosis))+
                geom_bar(aes(fill=diagnosis))
            ggplotly(g)
        } else if(input$plotType == "Histogram"){
            #Create the Histogram plot 
            if(input$colorCodeHist){
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(fill=diagnosis), position="dodge") 
                ggplotly(g)
            } else {
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(fill="blue", bins = 50) 
                ggplotly(g)
            }
        } else if(input$plotType == "Scatter"){
            #Create Scatter Plots
            if(input$colorCodeScatter){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=diagnosis))
                ggplotly(g)
            } else {
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="red")
                ggplotly(g)
            }
        } else if(input$plotType == "Box"){
            #Create Boxplots
            if(input$groupBox){
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(aes(x=diagnosis, color=diagnosis))
                ggplotly(g)
            } else {
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(color="blue")
                ggplotly(g)
            }
        }   
    })
    
    
    #Code for Numeric Summaries
    output$table1 = renderTable({
        head(data)
    })
    
    
    #Code for K-Means Plot
    output$kmeansPlot = renderPlot({
        ggplot(data=data, aes(x=mean_radius, y=mean_texture))+
            geom_point(size=3)
    })
})

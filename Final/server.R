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
        

    
    output$plot1 = renderPlot({
        
        
        if(input$plotType == "Bar"){
            #Create the single Bar plot
            ggplot(data=data, aes(x=diagnosis))+
                geom_bar(aes(fill=diagnosis))
        } else if(input$plotType == "Histogram"){
            #Create the Histogram plot 
            if(input$colorCodeHist){
                ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(fill=diagnosis), position="dodge")    
            } else {
                ggplot(data=data, aes_string(x=input$histVar))+
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
    
    #Code for 3D plots
    output$threeDPlot = renderPlotly({
        axx = list(
            nticks = 4,
            range = range(data[input$threeDX]),
            title = "X Axis"
        )
        
        axy = list(
            nticks = 4,
            range = range(data[input$threeDY]),
            title = input$threeDY
        )
        
        axz = list(
            nticks = 4,
            range = range(data[input$threeDZ]),
            title = input$threeDZ
        )
        
        x = data[[input$threeDX]]
        y = data[[input$threeDY]]
        z = data[[input$threeDZ]]
        
        fig = plot_ly(x = ~x, y = ~y, z = ~z, type = 'mesh3d') 
        fig = fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz))
        
        return(fig)
    })
    
    
    #
    output$table1 = renderTable({
        head(data)
    })
    
    output$kmeansPlot = renderPlot({
        ggplot(data=data, aes(x=mean_radius, y=mean_texture))+
            geom_point(size=3)
    })
})

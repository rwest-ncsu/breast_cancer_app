
#Load in necessary packages
library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(readr)
source("Global.R")


shinyUI(dashboardPage(
    
    #Title
    dashboardHeader(title="Breast Cancer Data"),
    
    #Define the sidebar menu items
    dashboardSidebar(
        sidebarMenu(
            menuItem("Information", tabName = "info"),
            menuItem("Summaries", tabName = "summaries"), 
            menuItem("Clustering", tabName = "cluster"),
            menuItem("Modeling", tabName = "model")
        )
    ), 
    
    
    #Define Body content
    dashboardBody(
        tabItems(
            
            #Info Page content
            tabItem(tabName = "info",
                box(
                    h4("This is a project centered around Breast Cancer Data")
                )   
            ), 
            
            #Summary Page Content
            tabItem(tabName = "summaries",
                tabsetPanel(
                    
                    #1st tab designated to viewing plots
                    tabPanel("Plots",
                        sidebarLayout(
                            
                            #Sidebar for selecting type of plot
                            sidebarPanel(
                                selectInput("plotType", 
                                            "Select a Plot",
                                            choices = c("Bar", "Histogram", "Scatter"), selected = "Scatter"),
                                conditionalPanel(condition="input.plotType == 'Histogram'",
                                                 selectInput("histVar", "Select a Variable for the Histogram",
                                                            choices = names(data%>%select(-diagnosis)),
                                                            selected = "mean_radius"),
                                                 checkboxInput("colorCodeHist", "Color code this Histogram?")),
                                conditionalPanel(condition="input.plotType == 'Scatter'",
                                                 selectInput("xScatter", "Choose an X axis",
                                                             choices = names(data%>%select(-diagnosis)),
                                                             selected = "mean_radius"),
                                                 selectInput("yScatter", "Choose a Y axis",
                                                             choices = names(data%>%select(-diagnosis)),
                                                             selected = "mean_texture"),
                                                 checkboxInput("colorCodeScatter", "Color code this Scatter Plot?"))
                                
                            ),
                            
                            mainPanel(
                                plotOutput("plot1")    
                            )
                        )
                    ),
                    
                    #2nd tab designated to Numeric Summaries
                    tabPanel("Numeric Summaries",
                             tableOutput("table1"))
                )
            ),
            
            #Clustering Page Content
            tabItem(tabName = "cluster",
                sidebarLayout(
                    
                    #Sidebar for Clustering page
                    sidebarPanel(
                        selectInput("xCluster", "Select X axis", 
                                    choices = names(data%>%select(-diagnosis)), 
                                    selected = "mean_radius"),
                        selectInput("yCluster", "Select Y axis",
                                    choices = names(data%>%select(-diagnosis)),
                                    selected="mean_texture"),
                        numericInput("kmeans", "Select K for the K-Means Algorithm", min=1, 
                                     max=12, step=1, value = 1)
                    ),
                    
                    mainPanel(
                        plotOutput("kmeansPlot")
                    )
                )
            ),
            
            #Modeling Page Content
            tabItem(tabName = "model",
                tabsetPanel(
                    
                    #1st Tab designated to K Nearest Neighbors
                    tabPanel("K Nearest Neighbors"),
                    
                    #2nd Tab designated to Logistic Regression
                    tabPanel("Logistic Regression"),
                    
                    #3rd Tab designated to Classification Trees
                    tabPanel("Classification Trees")
                )
            )
        )
    )
    
    
))

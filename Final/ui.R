
#Load in necessary packages
library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)


shinyUI(dashboardPage(
    
    #Title
    dashboardHeader(title="Data Science project Breast Cancer Data"),
    
    #Define the sidebar menu items
    dashboardSidebar(
        sidebarMenu(
            menuItem("Information", tabName = "info"),
            menuItem("Summaries", tabName = "summaries")    
        )
    ), 
    
    
    #Define Body content
    dashboardBody(
        tabItems(
            
            #Info page content
            tabItem(tabName = "info",
                box(
                    h4("This is a project centered around Breast Cancer Data")
                )   
            ), 
            
            #Summary Page Content
            tabItem(tabName = "summaries",
                fluidRow(
                    tableOutput("table1")
                )
            )
        )
    )
    
    
))

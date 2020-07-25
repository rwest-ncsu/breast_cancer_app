source("Global.R")


shinyUI(dashboardPage(
    
    #Title
    dashboardHeader(title="Breast Cancer Data"),
    
    #Define the sidebar menu items
    dashboardSidebar(
        sidebarMenu(
            menuItem("Information", tabName = "info"),
            menuItem("Summaries", tabName = "summaries"), 
            menuItem("PCA", tabName = "PCA"),
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
                ),
                dataTableOutput("readData")
            ), 
            
            #Summary Page Content
            tabItem(tabName = "summaries",
                tabsetPanel(
                    
                    #1st tab designated to viewing 2D plots
                    tabPanel("Plots",
                        sidebarLayout(
                            
                            #Sidebar for selecting type of plot
                            sidebarPanel(
                                selectInput("plotType", 
                                            "Select a Plot",
                                            choices = c("Bar", "Histogram", "Scatter", "Box"), selected = "Scatter"),
                                conditionalPanel(condition="input.plotType == 'Histogram'",
                                                 selectInput("histVar", "Select a Variable for the Histogram",
                                                            choices = varNames,
                                                            selected = "Radius"),
                                                 checkboxInput("colorCodeHist", "Color code this Histogram?"),
                                                 checkboxInput("histDensity", "Overlay a density to this Histogram?"),
                                                 sliderInput("nBins", "Select the number of bins for this Histogram",
                                                             min=10, max=75, step=1, value=30),
                                                 conditionalPanel(condition="input.histDensity == 1",
                                                                  sliderInput("alphaValue", "Set an Opacity for the Density",
                                                                              min=0.1, max=1, step=0.05, value=0.7),
                                                                  sliderInput("adjustValue", "Set an Adjustment Value for the Density",
                                                                              min=0.1, max=1, step=0.05, value=0.5))),
                                conditionalPanel(condition="input.plotType == 'Scatter'",
                                                 selectInput("xScatter", "Choose an X axis",
                                                             choices = varNames,
                                                             selected = "Radius"),
                                                 selectInput("yScatter", "Choose a Y axis",
                                                             choices = varNames,
                                                             selected = "Texture"),
                                                 checkboxInput("colorCodeScatter", "Color code this Scatter Plot by diagnosis?"),
                                                 checkboxInput("scatterTrend", "Add a trendline?")),
                                conditionalPanel(condition="input.plotType == 'Box'",
                                                 selectInput("boxVar", "Select a Variable for this Boxplot",
                                                             choices = varNames,
                                                             selected="Radius"),
                                                 checkboxInput("groupBox", "Group the Boxplot by Diagnosis?"))
                                
                            ),
                            
                            mainPanel(
                                plotlyOutput("summaryPlot")    
                            )
                        )
                    ),
                   
                    
                    #2nd tab designated to Numeric Summaries
                    tabPanel("Numeric Summaries",
                             
                             sidebarLayout(
                                 
                                #Contents of the sidebar
                                sidebarPanel(
                                    selectInput("numericVar", "Select a variable for numeric Summary",
                                                choices = varNames, 
                                                selected="Radius"),
                                    checkboxInput("groupByDiagnosis", "Group this summary by diagnosis?")
                                ),
                                
                                #Main panel
                                mainPanel(
                                    dataTableOutput("numericSummary")    
                                )
                             )
                    )
                )
            ),
            
            #PCA Page Content
            tabItem(tabName = "PCA",
                sidebarLayout(
                    
                    #Sidebar for PCA page
                    sidebarPanel(
                        selectInput("xCluster", "Select X axis", 
                                    choices = varNames, 
                                    selected = "Radius"),
                        selectInput("yCluster", "Select Y axis",
                                    choices = varNames,
                                    selected="Texture"),
                        numericInput("kmeans", "Select K for the K-Means Algorithm", min=1, 
                                     max=12, step=1, value = 1)
                    ),
                    
                    mainPanel(
                        plotOutput("PCAPlot")
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

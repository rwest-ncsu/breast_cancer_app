source("Global.R")


shinyUI(dashboardPage(
    
    #Title
    dashboardHeader(title="Breast Cancer Project"),
    
    #Define the sidebar menu items
    dashboardSidebar(
        sidebarMenu(
            menuItem("Information", tabName = "info"),
            menuItem("Summaries", tabName = "summaries"), 
            menuItem("PCA", tabName = "PCA"),
            menuItem("Modeling", tabName = "model"), 
            menuItem("Predictions", tabName = "predict")
        )#End Sidebar menu
    ),#End Sidebar 
    
    
    #Define Body content
    dashboardBody(
        tabItems(
            
            #Info Page content
            tabItem(tabName = "info",
                conditionalPanel(condition="input.viewData == 0",
                    box(width=12,
                        h3("This project focuses on a dataset pertaining to breast cancer. The primary goal of this app is binary classification of tumors as cancerous or non-cancerous. The data can be viewed, sorted, and saved below for your own analyses. Here is a quick run-down of the variables contained in this dataset:"),
                        br(), 
                        h4("Diagnosis: The target binary variable"), 
                        h4("Radius: Radius of the tumor"),
                        h4("Texture: Measure of grey-scale values on imaging software"),
                        h4("Perimeter: Approximate size of core tumor"),
                        h4("Area: Approximate area of core tumor"),
                        h4("Smoothness: Approximate local variation in radius lengths"), 
                        br(), 
                        h3("On the left, there are tabs that will allow you to explore and build models based on this dataset. Here's what each tab does:"),
                        br(),
                        h4("Summaries: This tab allows you to create your own visual and numeric explorations of the dataset. Hover over the plots to view exact datapoints"),
                        h4("PCA: This tab performs a Principal Components Analysis on our data. Essentially, PCA tries to get at the core of your data by finding the linear combination of variables that explains most of the variation in the entire dataset."),
                        h4("Modeling: This tab allows you to build 5 different supervised learning models to predict the Diagnosis of each patient."),
                        h4("Predictions: This tab gives you the ability to compare how well your models did on a test set. The splitting of training and testing data is done in the back-end by the server before this app loads. You'll need to create every type of model to see how well they stack against each other. You can also set values of each variables in the last subtab to predict if a new individual with these values would be diagnosed with a Cancerous or Non-cancerous tumor.")
                    )         
                        )
                ,
                checkboxInput("viewData", "View the data that this app uses?"),
                conditionalPanel(condition="input.viewData == 1",
                                 box(width = 12, 
                                    dataTableOutput("readData") 
                                    ),
                                 downloadButton("saveData", "Save this Data to a CSV?")),
                
            ),#End Info Tab item 
            
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
                                box(width = 12, 
                                    plotlyOutput("summaryPlot")
                                )    
                            )
                        ) #End sidebar layout
                    ),#End Tab Panel
                   
                    
                    #2nd tab designated to Numeric Summaries
                    tabPanel("Numeric Summaries",
                             
                            sidebarLayout(
                                 
                                #Contents of the sidebar
                                sidebarPanel(
                                    selectInput("numericVar", "Select a variable for numeric Summary",
                                                choices = varNames, selected="Radius"),
                                    checkboxInput("groupByDiagnosis", "Group this summary by diagnosis?")
                                ),
                                
                                #Main panel
                                mainPanel(
                                    box(width = 12, 
                                        tableOutput("numericSummary") 
                                    )  
                                )
                            ) #End Sidebar layout
                    ) #End numeric Summary tab
                ) #End Summary tabset panel
            ),#End Summary tab item
            
            #PCA Page Content
            tabItem(tabName = "PCA",
                sidebarLayout(
                    
                    #Sidebar for PCA page
                    sidebarPanel(
                        selectInput("PCAType", "Select a Plot to view:", 
                                    choices = c("Biplot", "Variance Proportion Plot"), 
                                    selected = "Biplot"),
                        conditionalPanel(condition="input.PCAType == 'Biplot'",
                                        selectInput("PCX", "Select a Principal Component for the X axis",
                                                    choices = c(1:5), selected=1),
                                        uiOutput("pcChoices"),
                                        )
                    ),
                    
                    mainPanel(
                        box(width = 12, 
                            plotOutput("PCAPlot")
                        ),
                        br(),
                        downloadButton("savePCA", "Save this plot to a PNG?")
                    )
                )#End sidebar layout
            ), #End PCA Tab item
            
            #Modeling Page Content
            tabItem(tabName = "model",
                tabsetPanel(
                    
                    #1st Tab designated to K Nearest Neighbors
                    tabPanel("K Nearest Neighbors",
                             sidebarLayout(
                                
                                sidebarPanel(
                                    h4("Run Cross Validation to pick a good K"),
                                    h4("Note: This will take a second"),
                                    actionButton("generateKNN", "Generate!")
                                ),
                                
                                mainPanel(
                                    add_busy_spinner(spin="fading-circle"),
                                    box(width = 12,
                                        h4("K Nearest Neighbors does best with Cross Validation to determine K since there is no rule-of-thumb for choosing K") 
                                    ),
                                    box(width = 12,
                                        plotOutput("knnPlot")    
                                    )
                                    
                                )
                             )
                        ),
                    
                    #2nd Tab designated to Logistic Regression
                    tabPanel("Logistic Regression", 
                             sidebarLayout(
                                 
                                sidebarPanel(
                                    
                                    actionButton("generateLogistic", "Create Model!")
                                ),
                                
                                mainPanel(
                                    add_busy_spinner(spin="fading-circle"),
                                    box(width=12, h4("Logistic Regression is a type of Generalized Linear Model where the response is a binary variable. In our case, it is whether a tumor is cancerous or not. Below are the coefficients from your model.")),
                                    box(width = 12,
                                        tableOutput("logisticCoefficients")
                                    )
                                    
                                )
                             )
                    ),
                    
                    #3rd Tab designated to Classification Trees
                    tabPanel("Classification Trees",
                             sidebarLayout(
                                 
                                 sidebarPanel(
                                    selectInput("treeType", "Select a type of Tree to use for your model",
                                                choices = c("Single", "Bagged", "Random Forest"),
                                                selected = "Single"),
                                    conditionalPanel(condition="input.treeType == 'Single'",
                                                     selectInput("singleIndex", "Select a split index for the algorithm",
                                                                 choices=c("deviance", "gini")),
                                                     actionButton("generateSingle", "Generate!")),
                                    conditionalPanel(condition="input.treeType == 'Bagged'",
                                                     sliderInput("baggedTrees", "How many trees do you want in your model?",
                                                                 min=10, max=500, step=10, value = 200),
                                                     actionButton("generateBagged", "Generate!")
                                                     ),
                                    conditionalPanel(condition="input.treeType == 'Random Forest'",
                                                     selectInput("RFmtry", "Select the number of variables to use",
                                                                 choices=c("1", "2", "3", "4", "5"),
                                                                 selected = "2"),
                                                     sliderInput("RFTrees", "How many trees do you want in your model?",
                                                                 min=10, max=500, step=10, value=200),
                                                     conditionalPanel(condition="input.RFmtry == '5'",
                                                                      h4("Notice: selecting all 5 variables is essentially a bagged tree")),
                                                     actionButton("generateRF", "Generate!"))
                                    
                                 ),#End Sidebar Panel
                                 
                                 mainPanel(
                                    add_busy_spinner(spin="fading-circle"),
                                    box(width = 12, 
                                        h4("Below is a summary of the model you chose")),
                                    box(width=12, 
                                        plotOutput("modelPlot"))
                                 )
                        ) #End sidebar layout
                    ) #End classification tree tab
                ) #End Model Tabset panel
            ),#End model tab item
            
            tabItem(tabName = "predict",
                tabsetPanel(
                    
                    tabPanel("Model Comparisons",
                             sidebarLayout(
                                 
                                sidebarPanel(
                                    h4("To the right are the Test Misclassification rates for the models you created (when you've run each one):")
                                ),
                                
                                mainPanel(
                                    box(width = 12,
                                        tableOutput("misClass")
                                    )
                                )
                                 
                             )
                    ),
                    
                    
                    tabPanel("Customized Predictions",
                             
                             sidebarLayout(
                                 
                                 sidebarPanel(
                                    selectInput("modelSelect", "Select a model to be used for prediction:", 
                                            choices = modelChoices,
                                            selected = "Single Tree"),
                                    sliderInput("radiusInput", "Select a value for Radius:", 
                                            min=4, max=35, step=0.01, value=14),
                                    sliderInput("textureInput", "Select a value for Texture:",
                                            min=7, max=45, step=0.01, value = 19), 
                                    sliderInput("perimeterInput", "Select a value for Perimeter:",
                                            min=40, max=195, step=0.01, value=92),
                                    sliderInput("areaInput", "Select a value for Area:", 
                                            min=135, max=2700, step=0.1, value=655),
                                    sliderInput("smoothnessInput", "Select a value for Smoothness:",
                                            min=0.04, max=0.17, step=0.001, value=0.096),
                                    actionButton("predict", "Run Prediction!"), 
                                    h4("If no prediction displays, it means you didn't create that model. Go to the 'Modeling' tab and hit 'Generate!'")
                                 ), 
                             
                                 mainPanel(
                                     box(width = 12, h4("The Predicted diagnosis is:")),
                                     box(width=12, verbatimTextOutput("showPrediction"))
                                 )
                             )
                             
                    )
                )
            )
            
            
        )#End Tab Items
    )#End Dashboard Body

))#End ShinyUI and Dashboard Page

source("Global.R")
 
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
        

    
    output$summaryPlot = renderPlotly({
        
        if(input$plotType == "Bar"){
            #Create the single Bar plot
            g = ggplot(data=data, aes(x=Diagnosis))+
                geom_bar(aes(fill=Diagnosis))
            ggplotly(g)
        } else if(input$plotType == "Histogram"){
            #Create the Histogram plot 
            if(input$colorCodeHist){
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(fill=Diagnosis), position="dodge") 
                ggplotly(g)
            } else {
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(fill="turquoise2", color="black", bins = 50) 
                ggplotly(g)
            }
        } else if(input$plotType == "Scatter"){
            #Create Scatter Plots
            if(input$colorCodeScatter & !input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=Diagnosis))
                ggplotly(g)
            } else if(!input$colorCodeScatter & !input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="turquoise2")
                ggplotly(g)
            } else if(input$colorCodeScatter & input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=Diagnosis))+
                    geom_smooth(aes(group=Diagnosis), se=TRUE)
                ggplotly(g)
            } else if(!input$colorCodeScatter & input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="turquoise2")+
                    geom_smooth(se=TRUE)
                ggplotly(g)
            }
            
        } else if(input$plotType == "Box"){
            #Create Boxplots
            if(input$groupBox){
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(aes(x=Diagnosis, color=Diagnosis))
                ggplotly(g)
            } else {
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(color="turquoise2")
                ggplotly(g)
            }
        }   
    })
    
    
    #Code for Numeric Summaries
    output$numericSummary = renderTable({
        
        if(input$groupByDiagnosis){
            diag0 = data %>% dplyr::select(input$numericVar, Diagnosis) %>% filter(Diagnosis==0)
            diag0 = diag0 %>% dplyr::summarize(
                Min = min(diag0[[input$numericVar]]),
                Max = max(diag0[[input$numericVar]]),
                IQR = IQR(diag0[[input$numericVar]]),
                MED = median(diag0[[input$numericVar]]),
                Mean = mean(diag0[[input$numericVar]]),
                SD = sd(diag0[[input$numericVar]])
            )
            diag0$Diagnosis = "Non Cancerous"
                
            diag1 = data %>% dplyr::select(input$numericVar, Diagnosis) %>% filter(Diagnosis==1)
            diag1 = diag1 %>% dplyr::summarize(
                Min = min(diag1[[input$numericVar]]),
                Max = max(diag1[[input$numericVar]]),
                IQR = IQR(diag1[[input$numericVar]]),
                MED = median(diag1[[input$numericVar]]),
                Mean = mean(diag1[[input$numericVar]]),
                SD = sd(diag1[[input$numericVar]])
            )
            diag1$Diagnosis = "Cancerous"
            
            tab = rbind(diag0, diag1)
            tab
         
        } else {
            tab = data %>% dplyr::select(input$numericVar) %>% dplyr::summarize(
                Min = min(data[[input$numericVar]]),
                Max = max(data[[input$numericVar]]),
                IQR = IQR(data[[input$numericVar]]),
                MED = median(data[[input$numericVar]]),
                Mean = mean(data[[input$numericVar]]),
                SD = sd(data[[input$numericVar]])
            ) 
        }
        
        tab
    })
    
    
    #Code for K-Means Plot
    output$kmeansPlot = renderPlot({
        ggplot(data=data, aes(x=Radius, y=Texture))+
            geom_point(size=3)
    })
})

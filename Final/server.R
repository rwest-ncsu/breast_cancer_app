source("Global.R")
 
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    output$readData = renderDataTable({
        datatable(data)
    })    

    
    output$summaryPlot = renderPlotly({
        
        if(input$plotType == "Bar"){
            #Create the single Bar plot
            g = ggplot(data=data, aes(x=Diagnosis))+
                geom_bar(aes(fill=Diagnosis))+
                scale_fill_manual(values=c("turquoise3", "tomato2"))
            ggplotly(g)
            
            
        } else if(input$plotType == "Histogram"){
            #Create the Histogram plot 
            if(input$colorCodeHist & input$histDensity){
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(fill=Diagnosis, y=..density..), position="dodge", color="black", bins = input$nBins)+
                    geom_density(aes(fill=Diagnosis), alpha=input$alphaValue, adjust=input$adjustValue)+
                    scale_fill_manual(values=c("turquoise3", "tomato2"))
                ggplotly(g)
            } else if(input$colorCodeHist & !input$histDensity){
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(fill=Diagnosis, y=..density..), color="black", bins = input$nBins, position="dodge")+
                    scale_fill_manual(values=c("turquoise3", "tomato2"))
                ggplotly(g)
            } else if(!input$colorCodeHist & input$histDensity){
                g = ggplot(data=data, aes_string(x=input$histVar))+
                    geom_histogram(aes(y=..density..), fill="turquoise3", color="black", bins = input$nBins)+
                    geom_density(fill="turquoise1", alpha=input$alphaValue, adjust=input$adjustValue)
                ggplotly(g)
            } else if(!input$colorCodeHist & !input$histDensity){
                g = ggplot(data=data, aes_string(x=input$histVar), aes(y=..density..))+
                    geom_histogram(aes(y=..density..), fill="turquoise3", color="black", bins = input$nBins) 
                ggplotly(g)
            }
            
            
        } else if(input$plotType == "Scatter"){
            #Create Scatter Plots
            if(input$colorCodeScatter & !input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=Diagnosis), alpha=0.8)+
                    scale_color_manual(values=c("turquoise3", "tomato2"))
                ggplotly(g)
            } else if(!input$colorCodeScatter & !input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="turquoise3")
                ggplotly(g)
            } else if(input$colorCodeScatter & input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(aes(color=Diagnosis), alpha=0.8)+
                    geom_smooth(aes(group=Diagnosis, color=Diagnosis), se=TRUE)+
                    scale_color_manual(values=c("turquoise3", "tomato2"))
                ggplotly(g)
            } else if(!input$colorCodeScatter & input$scatterTrend){
                g = ggplot(data=data, aes_string(x=input$xScatter, y=input$yScatter))+
                    geom_point(color="turquoise3")+
                    geom_smooth(se=TRUE, color="blue")
                ggplotly(g)
            }
            
            
        } else if(input$plotType == "Box"){
            #Create Boxplots
            if(input$groupBox){
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(aes(x=Diagnosis, color=Diagnosis))+
                    scale_color_manual(values=c("turquoise3", "tomato2"))
                ggplotly(g)
            } else {
                g = ggplot(data = data, aes_string(y=input$boxVar))+
                    geom_boxplot(color="turquoise3")
                ggplotly(g)
            }
        }   
    })
    
    
    #Code for Numeric Summaries
    output$numericSummary = renderDataTable({
        
        if(input$groupByDiagnosis){
            diag0 = data %>% dplyr::select(input$numericVar, Diagnosis) %>% filter(Diagnosis=="Non-Cancerous")
            diag0 = diag0 %>% dplyr::summarize(
                Min = min(diag0[[input$numericVar]]),
                Max = max(diag0[[input$numericVar]]),
                IQR = IQR(diag0[[input$numericVar]]),
                MED = median(diag0[[input$numericVar]]),
                Mean = round(mean(diag0[[input$numericVar]]), 3),
                SD = round(sd(diag0[[input$numericVar]]), 3)
            )
            diag0$Diagnosis = "Non-Cancerous"
                
            diag1 = data %>% dplyr::select(input$numericVar, Diagnosis) %>% filter(Diagnosis=="Cancerous")
            diag1 = diag1 %>% dplyr::summarize(
                Min = min(diag1[[input$numericVar]]),
                Max = max(diag1[[input$numericVar]]),
                IQR = IQR(diag1[[input$numericVar]]),
                MED = median(diag1[[input$numericVar]]),
                Mean = round(mean(diag1[[input$numericVar]]), 3),
                SD = round(sd(diag1[[input$numericVar]]), 3)
            )
            diag1$Diagnosis = "Cancerous"
            
            tab = rbind(diag0, diag1)
            DT::datatable(tab)
         
        } else {
            tab = data %>% dplyr::select(input$numericVar) %>% dplyr::summarize(
                Min = min(data[[input$numericVar]]),
                Max = max(data[[input$numericVar]]),
                IQR = IQR(data[[input$numericVar]]),
                MED = median(data[[input$numericVar]]),
                Mean = round(mean(data[[input$numericVar]]), 3),
                SD = round(sd(data[[input$numericVar]]), 3)
            ) 
        }
        
        DT::datatable(tab)
    })
    
    
    #Code for PCA Plot
    output$pcChoices = renderUI({
        firstChoice = c(1:5)
        selected = as.numeric(input$PCX)
        secondChoice = firstChoice[-selected]
        selectInput("PCY", "Select a Principal Component for the Y axis:",
                    choices=secondChoice)
        
    })
    
    PCs = prcomp(data %>% dplyr::select(-Diagnosis), scale = T, center=T)
    output$PCAPlot = renderPlot({
        if(input$PCAType == "Biplot"){
            biplot(PCs, xlabs=rep(".", nrow(data)), cex=1.2, choices = c(as.numeric(input$PCX), as.numeric(input$PCY)))
        }
        
        if(input$PCAType == "Variance Proportion Plot"){
            par(mfrow = c(1,2))
            plot(PCs$sdev^2/sum(PCs$sdev^2), xlab="Principal Component", ylab="Proportion of Variance Explained",
                 ylim=c(0,1), type="b")
            plot(cumsum(PCs$sdev^2/sum(PCs$sdev^2)), xlab="Principal Component", ylab="Cum. Proportion of Variance Explained", 
                 ylim=c(0,1), type="b")
        }
        
    })
})

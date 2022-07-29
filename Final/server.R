source("Global.R")


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
                    geom_smooth(se=TRUE, color="turquoise3")
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
    output$numericSummary = renderTable({
        
        if(input$groupByDiagnosis){
            diag0 = data %>% dplyr::select(input$numericVar, Diagnosis) %>% filter(Diagnosis=="Non-cancerous")
            diag0 = diag0 %>% dplyr::summarize(
                Min = min(diag0[[input$numericVar]]),
                Max = max(diag0[[input$numericVar]]),
                IQR = IQR(diag0[[input$numericVar]]),
                MED = median(diag0[[input$numericVar]]),
                Mean = round(mean(diag0[[input$numericVar]]), 3),
                SD = round(sd(diag0[[input$numericVar]]), 3)
            )
            diag0$Diagnosis = "Non-cancerous"
                
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
            tab
         
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
        
        tab
    }, rownames = TRUE, colnames = TRUE, striped=TRUE, width = NULL)
    
    
    #Code for PCA Plot
    output$pcChoices = renderUI({
        firstChoice = c(1:5)
        selected = as.numeric(input$PCX)
        secondChoice = firstChoice[-selected]
        selectInput("PCY", "Select a Principal Component for the Y axis:",
                    choices=secondChoice, selected = 2)
        
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
    
    
    #Build KNN model
    knnModel = eventReactive(input$generateKNN, {
        #knn(Diagnosis ~ ., train=data_train, test=data_test, cl=data_train$Diagnosis, k=input$kNNChoice)
        trctrl = trainControl(method="repeatedcv", number = 5, repeats = 1)
        train(Diagnosis ~ ., data=data_train, method="knn",
              trControl = trctrl,
              preProcess = c("center", "scale"),
              tuneGrid = data.frame(k = c(2, 4, 8, 16, 32)))
    })
    
    output$knnPlot = renderPlot(
        ggplot(data=knnModel())+
            labs(title = "KNN Algorithm: K against Accuracy", x="K", y="Accuracy")
    )
    
    
    #Build Logistic Regression Model
    logisticModel = eventReactive(input$generateLogistic, {
        glm(Diagnosis ~ ., data=data_train, family = "binomial")
    })
    
    output$logisticCoefficients = renderTable({
        tab = data.frame(logisticModel()$coefficients)
        rownames(tab) = c("Intercept", "Radius", "Texture", "Perimeter", "Area", "Smoothness")
        colnames(tab) =  "Coefficients"
        tab
    }, rownames = TRUE, striped = TRUE, colnames = TRUE, width = NULL)
    
    #Build single tree model
    treeModel = eventReactive(input$generateSingle, {
        tree(Diagnosis ~ ., data=data_train, split=input$singleIndex)
    })
    
    #Build bagged tree model 
    baggedModel = eventReactive(input$generateBagged, {
        randomForest(Diagnosis ~ ., data=data_train, ntree = input$baggedTrees, importance = T)
    })
    
    #Build Random Forest Model
    rfModel = eventReactive(input$generateRF, {
        randomForest(Diagnosis ~ ., data=data_train, ntree=input$RFTrees, mtry = as.numeric(input$RFmtry), importance=T)
    })
    
    #Build boosted tree model 
    boostedModel = eventReactive(input$generateBoost, {
        gbm(Diagnosis ~ ., distribution = "bernoulli", data = data_train, 
            n.trees = input$boostTrees, shrinkage = input$boostShrinkage, 
            interaction.depth = input$boostInteraction)
    })
    
    #Produce tree based model images
    output$singleTreePlot = renderPlot({
      plot(treeModel())
      text(treeModel())
    })
    
    output$baggedTreePlot = renderPlot({
      varImpPlot(baggedModel())
    })
    
    output$rfPlot = renderPlot({
      varImpPlot(rfModel())
    })
    
    #Handle the download button for PCA 
    output$savePCA = downloadHandler(
        filename = function(){
            if(input$PCAType=="Biplot"){
                paste0("PCA_Biplot.png")    
            } else {
                paste0("PCA_PropVariance.png")
            }  
        }, 
        
        content = function(file){
            png(file)
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
            dev.off()
        }
    )
    
    #Handle download button for Data
    output$saveData = downloadHandler(
        filename="BreastCancerData.csv",
        content = function(file){
            write.csv(data, file)
        }
    )
    
    #Build prediction data frame
    newData = eventReactive(input$predict, {
        data.frame(
            Radius = input$radiusInput,
            Texture = input$textureInput,
            Perimeter = input$perimeterInput,
            Area = input$areaInput,
            Smoothness = input$smoothnessInput
        )
    })
    
    #Output custom Prediction
    prediction = eventReactive(input$predict, {
        if(input$modelSelect == "Single Tree"){
            pred = predict(treeModel(), newdata = newData(), type="class")
        } else if(input$modelSelect =="Bagged Tree"){
            pred = predict(baggedModel(), newdata = newData(), type="class")
            pred = ifelse(pred == 2, "Cancerous", "Non-cancerous")
        } else if(input$modelSelect =="Random Forest"){
            pred = predict(rfModel(), newdata=newData(), type="class")
            pred = ifelse(pred == 2, "Cancerous", "Non-cancerous")
        } else if(input$modelSelect == "KNN"){
            pred = predict(knnModel(), newdata=newData())
            pred = ifelse(pred == 2, "Cancerous", "Non-cancerous")
        } else if(input$modelSelect=="Logistic Regression"){
            pred = predict(logisticModel(), newdata=newData(), type="response")
            pred = ifelse(pred >= 0.5, "Cancerous", "Non-cancerous")
        }
        return(as.character(pred))
    })
    
    output$showPrediction = renderText({
        prediction()
    })
    
    #Generate out of sample prediction errors
    treePred = eventReactive(input$generateSingle,{
        predict(treeModel(), newdata=data_test, type="class")
    })
        
    baggedPred = eventReactive(input$generateBagged, {
        predict(baggedModel(), newdata=data_test, type="class")
    })
        
    rfPred = eventReactive(input$generateRF,{
        predict(rfModel(), newdata=data_test, type="class")
    })
    
    knnPred = eventReactive(input$generateKNN, {
       predict(knnModel(), newdata=data_test)
    })
     
    logisticPred = eventReactive(input$generateLogistic, {
        logisticPred = predict(logisticModel(), newdata=data_test, type="response")
        logisticPred = ifelse(logisticPred >=0.5, "Cancerous", "Non-cancerous")
        return(logisticPred)
    })
    
    
    #Throw missclassification rates into a table to export
    predMatrix = reactive({
        data.frame(
            Tree = treePred(),
            Bagged = baggedPred(),
            RandomForest = rfPred(),
            KNN = knnPred(),
            Logistic = logisticPred()
        )
    })

    output$misClass = renderTable({
        misclassTable = apply(predMatrix(), MARGIN = 2,FUN=function(x){
            mean(x != data_test$Diagnosis)
        })
        misclassTable = as.matrix(misclassTable)
        colnames(misclassTable) = "Misclassification Rate"
        rownames(misclassTable) = c("Tree", "Bagged", "Random Forest", "KNN", "Logistic")
        misclassTable
    }, colnames = TRUE, rownames = TRUE, striped=TRUE, width = NULL)
    
})

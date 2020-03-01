# VisualizeTRACS: A Browser-based tool for TRACS data
# Visualize and explore your data from TRACS (https://github.com/developerpiru/TRACS)
# input: a TRACS output file (csv)
# See Github for more info & ReadMe: https://github.com/developerpiru/VisualizeTRACS

app_version = "3.0.0"

#function to check for required packages and install them if not already installed
installReqs <- function(package_name, bioc){
  if (requireNamespace(package_name, quietly = TRUE) == FALSE) {
    install.packages(package_name)
  }
}

#check if required libraries are installed, and install them if needed
installReqs("shiny")
installReqs("shinydashboard")
installReqs("scatterD3")
installReqs("plotly")
installReqs("DT")
installReqs('shinyjqui')
installReqs('colourpicker')

library(shiny)
library(shinydashboard)
library(scatterD3)
library(plotly)
library(DT)
library("shinyjqui")
library("colourpicker")

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output, session) {
  
  #reactive to get and store raw reads data
  getdata <- reactive({
    req(input$TRACSfile1)
    
    CELL_LINE_1_genedatapoints <<- read.csv(input$TRACSfile1$datapath,
                             header = TRUE,
                             sep = ",")

    #find the first quartile of library scores to update the numericInput for Library.ES
    lib_quants <<- as.integer(quantile(CELL_LINE_1_genedatapoints$Library.ES)["25%"])
    updateNumericInput(session, "Library.ES", label = NULL, value = lib_quants)
    
    return(CELL_LINE_1_genedatapoints)
    
  })
  
  output$htmltitle = renderPlotly({
    
    CELL_LINE_1_genedatapoints$filteredstat <- 'Unfiltered'
    
  })

  ##### START 3D Plot for CELL_LINE_1 #####
  #show all data in 3D plot for CELL_LINE_1
  #change selected\filtered gene point colour to red
  output$full3Dplot_CELL_LINE_1 = renderPlotly({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    CELL_LINE_1_genedatapoints$filteredstat <- 'Unfiltered'
    
    CELL_LINE_1_genedatapoints <- within(CELL_LINE_1_genedatapoints, filteredstat
                             [Initial.ES >= input$Initial.ES & 
                               Library.ES >= input$Library.ES &
                               #Final.ES <= input$Final.ES &
                               Final.ES <= input$Final.ES] <- 'Filtered')
                               #Lib.ER >= input$Library.ER &
                               #Lib.pval >= input$Library.pval&
                               #qval <= input$ER.qval] <- 'Filtered')
    
    
    CELL_LINE_1_genedatapoints$filteredstat <- as.factor(CELL_LINE_1_genedatapoints$filteredstat)
    
    p <- plot_ly(CELL_LINE_1_genedatapoints, x = ~Final.ES, y = ~Initial.ES, z = ~Library.ES,
                 marker = list(symbol = 'circle', size = 4),
                 color = ~filteredstat, 
                 colors = c(input$threeDfilteredColor, input$threeDUnfilteredColor)) %>%
      
      add_markers() %>%
      
      layout(title = "", 
             scene = list(xaxis = list(title = 'Final ES'),
                          yaxis = list(title = 'Initial ES'),
                          zaxis = list(title = 'Library ES')),
             showlegend = FALSE)
    
  }) ##### END 3D Plot for CELL_LINE_1 #####
  

  ##### START 2D Plotly for CELL_LINE_1 #####
  output$filteredPlotlyColour_CELL_LINE_1 <- renderPlotly({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    CELL_LINE_1_genedatapoints$filteredstat <- 'Unfiltered'
    
    #genes to keep
    CELL_LINE_1_genedatapoints <- within(CELL_LINE_1_genedatapoints, filteredstat
                                         [Initial.ES >= input$Initial.ES & #above initial ES
                                             Library.ES >= input$Library.ES & #above library ES
                                             Final.ES <= input$Final.ES & #below final ES
                                             EnrichmentRatio >= input$Min.ER & #below ER (for dropouts)
                                             #EnrichmentRatio < 0 & #below ER (for dropouts)
                                             EnrichmentRatio <= input$Max.ER & #below ER (for dropouts)
                                             pval <= input$pval & #below significant p adjusted value
                                             qval <= input$qval] <- 'Filtered') #below significant q value
    
    CELL_LINE_1_genedatapoints$filteredstat <- as.factor(CELL_LINE_1_genedatapoints$filteredstat)
    
    #create a list that contains data to draw a straight line (y = x)
    #for drawing sraight line
    line <- list(
      type = "line",
      line = list(color = "black"),
      xref = "x",
      yref = "y"
    )
    
    lines <- list()
    for (i in c(0, 3, 5, 7, 9, 13)) {
      line[["x0"]] <- 0
      line[["x1"]] <- max(CELL_LINE_1_genedatapoints$Initial.ES)
      line[["y0"]] <- 0
      line[["y1"]] <- max(CELL_LINE_1_genedatapoints$Initial.ES)
      lines <- c(lines, list(line))
    }
    
    #set fonts for plotly graph
    fontstyle <- list(
      family = "Arial",
      size = 14,
      color = "#000000"
    )
    xstyle <- list(
      title = "Initial ES",
      titlefont = fontstyle
    )
    ystyle <- list(
      title = "Final ES",
      titlefont = fontstyle
    )
    
    # use the key aesthetic/argument to help uniquely identify selected observations
    key <- CELL_LINE_1_genedatapoints$Gene
    plot_ly(CELL_LINE_1_genedatapoints, 
            x = ~Initial.ES, 
            y = ~Final.ES,
            size = 10,
            color = ~filteredstat,
            opacity = 0.7,
            key = ~key,
            colors = c(input$filteredColor, input$UnfilteredColor)) %>%
      layout(dragmode = "select", shapes=lines, xaxis = xstyle, yaxis = ystyle)
  })
  ##### END 2D Plotly for CELL_LINE_1 #####
   
  ##### START PLOTLY SELECT FUNCTION #####
  output$plotly_select <- DT::renderDataTable({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    #filter gene list for CELL_LINE_1
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_genedatapoints, Initial.ES >= input$Initial.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Library.ES >= input$Library.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Final.ES <= input$Final.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, EnrichmentRatio >= input$Min.ER & EnrichmentRatio <= input$Max.ER)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, pval <= input$pval)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, qval <= input$qval)

    #set rownames of CELL_LINE_1_filteredgenes
    rownames(CELL_LINE_1_filteredgenes) <- CELL_LINE_1_filteredgenes$Gene
    
    #get the selected points from plotly graph
    temp_df <<- as.data.frame(event_data("plotly_selected"))
    #if (is.null(display_list)) "Nothing selected yet" else display_list
    
    #set rownames of temp_df to the key values, which contain the gene names we want
    rownames(temp_df) <- temp_df$key
    #drop all columns except the last two; need to keep at least 2 columns for merge function
    temp_df <- temp_df[,c(-1,-2,-3)]
    
    #rename columns; last column is the Gene name we want to use to match up data with CELL_LINE_1_filteredgenes dataframe
    colnames(temp_df) <- c("0", "Gene")
    
    #use merge function to pullout values of selected genes
    display_table <- merge(CELL_LINE_1_filteredgenes, temp_df, by="Gene", all.x=F)
    
    #now drop the "0" column
    display_table <- display_table[,-7]
    
    #if (is.null(temp_df)){
    #  m <- data.frame(matrix(0, ncol = 2, nrow = 1))
    #  m[1,1] <- "Nothing selected yet"
    #  display_table <- m
    #}
    
    #make gene names a URL to genecards
    display_table$Gene <-  paste0("<a href='http://www.genecards.org/cgi-bin/carddisp.pl?gene=", display_table$Gene, "' target='_blank'>", display_table$Gene, "</a>")
    
    
    #display table
    DT::datatable(display_table, 
                  options = list(order = list(list(6, 'asc')), 
                                 aLengthMenu = c(10,25, 50, 100, 1000), 
                                 iDisplayLength = 25), escape = FALSE)
   
  }) ##### END PLOTLY SELECT FUNCTION #####
  
  ##### START TABLE FOR CELL_LINE_1 #####
  #data table to show filtered genes from CELL_LINE_1
  output$filteredtable_CELL_LINE_1 <- DT::renderDataTable({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    #filter gene list for CELL_LINE_1
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_genedatapoints, Initial.ES >= input$Initial.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Library.ES >= input$Library.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Final.ES <= input$Final.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, EnrichmentRatio >= input$Min.ER & EnrichmentRatio <= input$Max.ER)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, pval <= input$pval)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, qval <= input$qval)
 
    #make gene names a URL to genecards
    CELL_LINE_1_filteredgenes$Gene <-  paste0("<a href='http://www.genecards.org/cgi-bin/carddisp.pl?gene=", CELL_LINE_1_filteredgenes$Gene, "' target='_blank'>", CELL_LINE_1_filteredgenes$Gene, "</a>")
    
    #save to new table
    display_list <- CELL_LINE_1_filteredgenes

    DT::datatable(display_list, 
                  options = list(order = list(list(6, 'asc')), 
                                 aLengthMenu = c(10,25, 50, 100, 1000), 
                                 iDisplayLength = 25), escape = FALSE)
    
  }) ##### END TABLE FOR CELL_LINE_1 #####
  
  datasetOutput_SelectedData <- reactive({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    #filter gene list for CELL_LINE_1
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_genedatapoints, Initial.ES >= input$Initial.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Library.ES >= input$Library.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Final.ES <= input$Final.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, EnrichmentRatio >= input$Min.ER & EnrichmentRatio <= input$Max.ER)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, pval <= input$pval)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, qval <= input$qval)

    #save to new table
    display_list <- CELL_LINE_1_filteredgenes
    
    #display_list[8:9] <- list(NULL)
    #display_list <- display_list[,c(1:7,10:14)]
    
  })


  ##### START TABLE FOR DOWNLOADING FOR CELL_LINE_1 #####
  #process table for downloading
  datasetOutput_CELL_LINE_1 <- reactive({
    
    #retrieve data
    CELL_LINE_1_genedatapoints <- getdata()
    
    #filter gene list for CELL_LINE_1
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_genedatapoints, Initial.ES >= input$Initial.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Library.ES >= input$Library.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, Final.ES <= input$Final.ES)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, EnrichmentRatio >= input$Min.ER & EnrichmentRatio <= input$Max.ER)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, pval <= input$pval)
    CELL_LINE_1_filteredgenes <- subset(CELL_LINE_1_filteredgenes, qval <= input$qval)
    

    #save to new table
    display_list <- CELL_LINE_1_filteredgenes

    #display_list[8:9] <- list(NULL)
    #display_list <- display_list[,c(1:7,10:14)]
    
  })
  
  #download all genes table
  output$downloadData_CELL_LINE_1 <- downloadHandler(
    filename = function() {
      paste("VisualizeTRACS-filtered-output.csv")
    },
    content = function(file) {
      write.csv(datasetOutput_CELL_LINE_1(), file, row.names = FALSE)
    }
  )
  
  #download selected genes tabel from plotly selected data
  output$downloadSelectedData <- downloadHandler(
    filename = function() {
      paste("VisualizeTRACS-selected-output.csv")
    },
    content = function(file) {
      write.csv(datasetOutput_SelectedData(), file, row.names = FALSE)
    }
  )

##### END TABLE FOR DOWNLOADING FOR CELL_LINE_1 #####
  

  #button action to show all genes
  observeEvent(input$btnshowall, {
    
    updateNumericInput(session, "Library.ES", label = NULL, value = "0")
    updateNumericInput(session, "Initial.ES", label = NULL, value = "0")
    updateNumericInput(session, "Final.ES", label = NULL, value = "0")
    updateNumericInput(session, "Min.ER", label = NULL, value = "-100")
    updateNumericInput(session, "Max.ER", label = NULL, value = "100")
    updateNumericInput(session, "pval", label = NULL, value = "1")
    updateNumericInput(session, "qval", label = NULL, value = "1")

  })
  
  #button action to set defaults
  observeEvent(input$btndefault, {
    
    updateNumericInput(session, "Library.ES", label = NULL, value = lib_quants)
    updateNumericInput(session, "Initial.ES", label = NULL, value = "0")
    updateNumericInput(session, "Final.ES", label = NULL, value = "500000")
    updateNumericInput(session, "Min.ER", label = NULL, value = "-100")
    updateNumericInput(session, "Max.ER", label = NULL, value = "0")
    updateNumericInput(session, "pval", label = NULL, value = "1")
    updateNumericInput(session, "qval", label = NULL, value = "0.05")
    
  })

})
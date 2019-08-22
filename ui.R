#runApp("shinyappv2", host = "0.0.0.0", port = 80)

ui <- dashboardPage(
  dashboardHeader(title = "VisualizeTRACS v3.0"),
  
  dashboardSidebar(
    
      #buttons
      actionButton("btnshowall", "Show all genes"),
      actionButton("btndefault", "Default values"),
    
      #spheroid axis slider: x axis
      sliderInput("Final.ES", 
                  "Max Final Gene Enrichment Score (Final.ES)", 
                  min = 0,
                  max = 20000, 
                  value = 15000),
      
      #adherent axis slider: y axis
      sliderInput("Initial.ES", 
                  "Min Initial Gene Enrichment Score (Initial.ES)", 
                  min = 0,
                  max = 20000, 
                  value = 1),
      
      #library axis slider: z axis
      sliderInput("Library.ES", 
                  "Min Library Enrichment Score (Library.ES)", 
                  min = 0,
                  max = 20000, 
                  value = 200),
      
      #range for Enrichment Ratio ER)
      sliderInput("ER.range", 
                  "Range for Enrichment Ratio (ER = Log2[Final.ES/Initial.ES])", 
                  min = -30,
                  max = 30, 
                  value = c(-20,20))
      
    
  ), #end dashboard Sidebar
  
  dashboardBody(
    
      tags$head(tags$style(HTML('
        .main-header .logo {
              font-family: "Arial";
              font-weight: bold;
              font-size:20px;
        }
  
        .content-wrapper {
              background-color: #FFFFFF !important;
        }
      '))), 
    
    
      tabsetPanel(
        
        tabPanel("Load data", fluidRow(
          
          #Load TRACS analysis file
          fileInput("TRACSfile1", "Select TRACS analysis file",
                    multiple = FALSE,
                    accept = c("text/plain",
                               "text/comma-separated-values,text/plain",
                               ".csv"))
                )),
        
        # full 3D plot tab
        tabPanel("3D Plot", fluidRow(
          HTML("<h3><p align='center'>Plot of all genes</p></h3>"),
          column(12, plotlyOutput("full3Dplot_CELL_LINE_1", height = "500", width = "100%"))
                 )),
   
        # Plotly graph with polygon select
        tabPanel("Scatter plot", plotlyOutput("filteredPlotly_CELL_LINE_1", height = "800", width="100%"),
                 #verbatimTextOutput("plotly_select")
                 downloadButton("downloadSelectedData", "Download Table"),
                 DT::dataTableOutput("plotly_select")
        ),
        
        # Filtered table tab for CELL_LINE_1
        tabPanel("Data Table", 
                 HTML("<p align='center'>Download filtered table"),
                 downloadButton("downloadData_CELL_LINE_1", "Download Table"),
                 HTML("</p>"),
                 DT::dataTableOutput("filteredtable_CELL_LINE_1")
                  )
      )
    
  ), #end dashboardBody
  
  skin = "blue"
  
) #end dashboardPage
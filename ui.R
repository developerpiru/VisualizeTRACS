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

ui <- dashboardPage(
  dashboardHeader(title = "VisualizeTRACS"),
  
  dashboardSidebar(
    
    tags$style(".skin-purple .sidebar 
               a { 
                  color: #444; 
               }"),
    
    tags$style(".skin-purple .sidebar 
               a.sidebarlink:link, a.sidebarlink:visited { 
                                    color: #FFF;
               }"),
    tags$style(".skin-purple .sidebar
                a.sidebarlink:hover {
                                    color: #777;
               }"),
    
    tags$style(".skin-purple .sidebar
                .center {
                        text-align: center;
               }"),
    
    tags$style(".skin-purple .sidebar
                .borderbox {
                        border: 2px solid #666;
                        padding: 5px 5px 5px 5px;
                        margin: 5px;
               }"),
    
    conditionalPanel("input.navigationTabs == 'LoadDataTab'",
                     div(id = 'LoadDataTab_SideBar',
                         
                         tags$div('class'="center",
                                  h4("Welcome to VisualizeTRACS!"),
                                  HTML('This is the browser-based data visualization and exploration tool for TRACS<br><br>'),
                                  tags$p(
                                    tags$a(href="https://github.com/developerpiru/VisualizeTRACS",
                                           target="_blank",
                                           class ="sidebarlink",
                                           "Check GitHub for help & info")
                                  ))
                     )),
    
    conditionalPanel("input.navigationTabs == '3DPlotTab'",
                     div(id = '3DPlotTab_SideBar',
                         
                         tags$div('class'="center", 
                                  tags$br(),
                                  #buttons
                                  actionButton("btnshowall", "Show all genes"),
                                  actionButton("btndefault", "Default values")
                         ),
                         
                         h4("Filtering options"),
                         tags$div('class'="borderbox",
                                  #place holder for Library ES input
                                  uiOutput("Library.ES"),
                                  
                                  #Min Initial ES input
                                  numericInput("Initial.ES", 
                                               "Min Initial ES",
                                               value = 0),
                                  
                                  #Min Final ES input
                                  numericInput("Final.ES", 
                                               "Max Final ES",
                                               value = 500000),
                                  
                                  #Min ER
                                  numericInput("Min.ER", 
                                               "Min Enrichment Ratio",
                                               value = -100),
                                  
                                  #Max ER
                                  numericInput("Max.ER", 
                                               "Max Enrichment Ratio",
                                               value = 0),
                                  
                                  #p value
                                  numericInput("pval", 
                                               "Max P value (genes above this are dropped)", 
                                               value = 1),
                                  
                                  #q value
                                  numericInput("qval", 
                                               "Max q value (genes above this are dropped)", 
                                               value = 0.05)
                         ),
                         
                         h4("Colors"),
                         tags$div('class'="borderbox",
                                  colourInput("3DfilteredColor", "Filtered color", "#2714FC", allowTransparent = FALSE),
                                  colourInput("3DUnfilteredColor", "Unfiltered color", "#B8B4B4", allowTransparent = FALSE)
                         )
                         
                     )),
    
    conditionalPanel("input.navigationTabs == '2DPlotTab'",
                     div(id = '2DPlotTab_SideBar',
                         
                         h4("Colors"),
                         tags$div('class'="borderbox",
                                  colourInput("filteredColor", "Filtered color", "#2714FC", allowTransparent = FALSE),
                                  colourInput("UnfilteredColor", "Unfiltered color", "#B8B4B4", allowTransparent = FALSE)
                         )
                         
                     )),
    
    conditionalPanel("input.navigationTabs == 'DataTableTab'",
                     div(id = 'DataTableTab_SideBar',
                         
                         HTML("<p align='center'><br>"),
                         downloadButton("downloadData_CELL_LINE_1", "Download Filtered Genes"),
                         
                         #HTML("<p align='center'><br>"),
                         downloadButton("downloadSelectedData", "Download Selected Genes")
           
                     ))
  
    
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
        
        id = "navigationTabs",
        
        tabPanel("Load data", id = "LoadDataTab", value= "LoadDataTab", fluidRow(
          
          #Load TRACS analysis file
          fileInput("TRACSfile1", "Select TRACS output file",
                    multiple = FALSE,
                    accept = c(".csv"))
          
                )),
        
        # full 3D plot tab
        tabPanel("3D Plot", id = "3DPlotTab", value= "3DPlotTab", fluidRow(
          HTML("<h3><p align='center'>Plot of all genes</p></h3>"),
          column(12, jqui_resizable( #jqui resizable canvas,
            plotlyOutput("full3Dplot_CELL_LINE_1", height = "100%", width = "100%"))
                 ))),

        # Plotly graph with polygon select
        tabPanel("2D Plot", id = "2DPlot", value= "2DPlotTab", jqui_resizable( #jqui resizable canvas,
          plotlyOutput("filteredPlotlyColour_CELL_LINE_1", height = "800", width="100%"))
        ),
        
        # Filtered table tab for CELL_LINE_1
        tabPanel("Data Table", id = "DataTableTab", value= "DataTableTab", 
                 #HTML("</p>"),
                 DT::dataTableOutput("filteredtable_CELL_LINE_1")
                  )
      )
    
  ), #end dashboardBody
  
  skin = "blue"
  
) #end dashboardPage
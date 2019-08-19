# VisualizeTRACS

# Introduction
VisualizeTRACS is an R-based tool that allows you to manipulate and visualize data from TRACS. 

# Requirements
You must have the following components installed in order to run VisualizeTRACS:
- R 3.5+	
- library(shiny)
- library(shinydashboard)
- library(scatterD3)
- library(plotly)
- library(DT)

# Installation
Download install the latest version of R if you don't have it already from the CRAN project page: https://cran.r-project.org/.

At the R command prompt or in RStudio, run these commands to install the dependencies (listed above) if you don't already have them installed:

	install.packages("shiny")

	install.packages("shinydashboard")

	install.packages("scatterD3")

	install.packages("plotly")

	install.packages("DT")

# Run VisualizeTRACS
Then load the required libraries:

	library(shiny)
	library(shinydashboard)
	library(scatterD3)
	library(plotly)
	library(DT)

Then run the latest version of VisualizeTRACS using:

	runGitHub( "VisualizeTRACS", "developerpiru")

If you are using R, a browser window should open automatically showing the app. If you are using RStudio, click "Open in browser" in the window that opens.

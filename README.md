# VisualizeTRACS

# Introduction
VisualizeTRACS is an R-based tool that allows you to manipulate and visualize data from TRACS. 

# Requirements
You must have the following components installed in order to run VisualizeTRACS:
	1. R 3.5+
	2. library(shiny)
	3. library(shinydashboard)
	4. library(scatterD3)
	5. library(plotly)
	6. library(DT)

# Installation
At the R command prompt or in RStudio, run these commands to install dependencies:

	install.packages("shiny")

	install.packages("shinydashboard")

	install.packages("scatterD3")

	install.packages("plotly")

	install.packages("DT")


Then load the shiny library:

	library(shiny)

Then run the latest version of VisualizeTRACS using:

	runGitHub( "VisualizeTRACS", "developerpiru")

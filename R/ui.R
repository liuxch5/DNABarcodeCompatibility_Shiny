library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)

sidemenuWidth <- 300

sidebar <- dashboardSidebar(width = sidemenuWidth,
                            sidebarMenu(
                              menuItem(text = "Home", tabName = "home", icon=icon("home")),
                              menuItem("Tutorial", tabName = "tuto", icon=icon("graduation-cap")),
                              menuItem("Indexing", tabName = "index", icon=icon("wrench"),
                                       menuSubItem("Single indexing", tabName = "single"),
                                       menuSubItem("Dual indexing", tabName = "dual")
                              ),
                              menuItem("Help", tabName = "help", icon=icon("info -circle"))
                            )
)

body <- dashboardBody(
  tabItems(
    
    ##################
    #### TAB HOME ####
    ##################
    
    tabItem(tabName = "home",
            h2("DNABarcodeCompatibility: to find optimised sets of compatible barcodes for multiplex experiments performed on next generation sequencing platforms."),
            h3("Description"),
            p("The current Shiny-web interface is a front end for the DNABarcodeCompatibility package. This package provides tools to load DNA barcodes, and to generate, filter and optimise sets of barcode combinations for multiplex sequencing experiments. In particular, barcode combinations are selected to be compatible with respect to Illumina chemistry constraints, and can be filtered to keep those that are robust against substitution and insertion/deletion errors thereby facilitating the demultiplexing step. In addition, the package provides an optimiser function to further favor the selection of compatible barcode combinations with least heterogeneity in barcode usage."),
            h3("How to cite"),
            p("Céline Trébeau, Jacques Boutet de Monvel, Fabienne Wong Jun Tai, Raphaël Etournay. (2018, May 31). comoto-pasteur-fr/DNABarcodeCompatibility: First complete release (Version v0.0.0.9000). Zenodo.")
    ),
    
    ######################
    #### TAB TUTORIAL ####
    ######################
    
    tabItem(tabName = "tuto",
            h2("Tutorial"),
            tags$img(src="pictureShiny.png", height="80%", width="80%"),
            h4("1)	Select the platform"),
            h4("2)	Load the barcode sets (one for single indexing and two for dual indexing)"),
            h4("3)	Indicate the number of libraries to be sequenced"),
            h4("4)	Select the desired multiplex level"),
            h4("5)	Input additional barcode constraints (nucleotide content and pairwise distance)"),
            h4("PRESS Search"),
            h4("6)	Results are shown graphically"), 
            h4("7)	Results are shown in text mode")
    ),
    
    #############################
    #### TAB SINGLE INDEXING ####
    #############################
    
    tabItem(tabName = "single",
            h2("Single Indexing"),
            fluidRow(
              box(
                title = "Settings", status = "primary", solidHeader = TRUE, width = 3,
                selectInput(
                  inputId = "single_platform",
                  label = "Plaftform",
                  choices = c("Illumina iSeq100" = 1, "Illumina MiniSeq, NextSeq, NovaSeq" = 2, "Illumina MiSeq, HiSeq" = 4, "Other plaftorms" = 0)
                ), 
                fileInput(
                  inputId = "single_file",
                  label = "Input file",
                  buttonLabel = "Browse...",
                  placeholder = "No file selected"
                ),
                numericInput(
                  inputId = "single_sample_number",
                  label = "Sample Number",
                  value = 2,
                  min = 2,
                  max = 1000
                ),
                conditionalPanel(
                  "!is.numeric(input.single_sample_number) || input.single_sample_number>0",
                  span(
                    textOutput(outputId = "single_sample_number_error_message"),
                    style = "color:red"
                  )
                ), 
                selectInput(
                  inputId = "single_multiplex_level",
                  label = "Multiplexing level",
                  choices = c(0)
                ),
                actionButton("single_search", icon = icon("search"), "Search")
              ),
              box(
                title = "Advanced settings", status = "info", solidHeader = TRUE, width = 3,
                sliderInput(
                  inputId = "single_gc_content",
                  label = "GC content (%)",
                  min = 0,
                  max = 100,
                  value = c(0, 100)
                ),
                checkboxInput(inputId = "single_homopolymer",
                              label = "Remove homopolymer",
                              value = FALSE), 
                selectInput(
                  inputId = "single_distance_metric",
                  label = "Distance metric",
                  choices = c("No distance" = "none", "Hamming" = "hamming", "Seqlev" = "seqlev", "Phaseshift" = "phaseshift")
                ),
                numericInput(
                  inputId = "single_distance",
                  label = "Distance",
                  value = 3,
                  min = 0
                ),
                conditionalPanel(
                  "!is.numeric(input.single_distance) || input.single_distance<0",
                  span(
                    textOutput(outputId = "single_distance_error_message"),
                    style = "color:red"
                  )
                )
              ),
              tabBox(
                title = "Results",
                width = 6,
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "single_tabset",
                height = "250px",
                tabPanel("Visual",
                         value = "single_visual_result",
                         span(
                           textOutput(outputId = "single_visual_result_error_message"),
                           style = "color:red"
                         ),
                         htmlOutput(outputId = "single_visual_result")
                ),
                tabPanel("Table",
                         value = "single_table_result",
                         span(
                          textOutput(outputId = "single_table_result_error_message"),
                          style = "color:red"
                         ),
                         dataTableOutput(outputId = "single_table_result"),
                         hidden(downloadButton("single_download_results", "Download results"))
                ),
                tabPanel("Log",
                         value = "single_log",
                         span(
                           textOutput(outputId = "single_log_error_message"),
                           style = "color:red"
                         ),
                         verbatimTextOutput(
                           outputId = "single_log"
                         ),
                         hidden(downloadButton("single_download_log", "Download log"))
                )
              )
            ),
            fluidRow(
              box(
                title = "Input data",
                status = "primary",
                solidHeader = TRUE,
                width = 6,
                span(textOutput(outputId = "single_input_error_message"), style="color:red"),
                dataTableOutput(outputId = "single_loaded_data")
              )
            )
    ),
    
    ###########################
    #### TAB DUAL INDEXING ####
    ###########################
    
    ### Tab Dual indexing content ###
    tabItem(tabName = "dual",
            h2("Dual indexing"),
            fluidRow(
              box(
                title = "Settings", status = "primary", solidHeader = TRUE, width = 3,
                selectInput(
                  inputId = "dual_platform",
                  label = "Platform",
                  choices = c("Illumina iSeq100" = 1, "Illumina MiniSeq, NextSeq, NovaSeq" = 2, "Illumina MiSeq, HiSeq" = 4, "Other plaftorms" = 0)
                ), 
                fileInput(
                  inputId = "dual_file1",
                  label = "Input file 1",
                  buttonLabel = "Browse...",
                  placeholder = "No file selected"
                ),
                fileInput(
                  inputId = "dual_file2",
                  label = "Input file 2",
                  buttonLabel = "Browse...",
                  placeholder = "No file selected"
                ),
                numericInput(
                  inputId = "dual_sample_number",
                  label = "Sample Number",
                  value = 2,
                  min = 2,
                  max = 1000
                ),
                conditionalPanel(
                  "!is.numeric(input.dual_sample_number) & input.dual_sample_number>0",
                  span(
                    textOutput(outputId = "dual_sample_number_error_message"),
                    style = "color:red"
                  )
                ),
                selectInput(
                  inputId = "dual_multiplex_level",
                  label = "Multiplexing level",
                  choices = c(0)
                ),
                actionButton("dual_search", icon = icon("search"), "Search")
              ),
              box(
                title = "Advanced settings", status = "info", solidHeader = TRUE, width = 3,
                sliderInput(
                  inputId = "dual_gc_content",
                  label = "GC content (%)",
                  min = 0,
                  max = 100,
                  value = c(0, 100)
                ),
                checkboxInput(inputId = "dual_homopolymer",
                              label = "Remove homopolymer",
                              value = FALSE), 
                selectInput(
                  inputId = "dual_distance_metric",
                  label = "Distance metric",
                  choices = c("No distance" = "none", "Hamming" = "hamming", "Seqlev" = "seqlev", "Phaseshift" = "phaseshift")
                ),
                numericInput(
                  inputId = "dual_distance",
                  label = "Distance",
                  value = 3,
                  min = 0
                ),
                conditionalPanel(
                  "!is.numeric(input.dual_distance) || input.dual_distance<0",
                  span(
                    textOutput(outputId = "dual_distance_error_message"),
                    style = "color:red"
                  )
                )
              ),
              tabBox(
                title = "Results",
                width = 6,
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "dual_tabset",
                height = "250px",
                tabPanel("Visual",
                         value = "dual_visual_result",
                         span(
                           textOutput(outputId = "dual_visual_result_error_message"),
                           style = "color:red"
                         ),
                         htmlOutput(outputId = "dual_visual_result")),
                tabPanel(
                  "Table",
                  value = "dual_table_result",
                  span(
                    textOutput(outputId = "dual_table_result_error_message"),
                    style = "color:red"
                  ),
                  dataTableOutput(outputId = "dual_table_result"),
                  hidden(downloadButton("dual_download_results", "Download results"))
                ),
                tabPanel("Log",
                         value = "dual_log",
                         span(
                           textOutput(outputId = "dual_log_error_message"),
                           style = "color:red"
                         ),
                         verbatimTextOutput(outputId = "dual_log"),
                         hidden(
                           downloadButton("dual_download_log", "Download log")
                         ))
              )
            ),
            fluidRow(
              tabBox(
                id = "dual_input_tab",
                title = "Input data",
                width = 6,
                tabPanel(
                  title = "File 1",
                  value = "file1",
                  span(textOutput(outputId = "dual_input_error_message1"), style = "color:red"),
                  dataTableOutput(outputId = "dual_loaded_data1")
                ),
                tabPanel(
                  title = "File 2",
                  value = "file2",
                  span(textOutput(outputId = "dual_input_error_message2"), style = "color:red"),
                  dataTableOutput(outputId = "dual_loaded_data2")
                )
              )
              
            )
    ),
    
    ##################
    #### TAB HELP ####
    ##################
    
    tabItem(tabName = "help",
            h2("Help"),
            tags$iframe(src = "Documentation.html", seamless=NA, scrolling="auto", height=600, width="100%")
            
    )
  )
)

ui <- fluidPage(
  
  useShinyjs(),
  dashboardPage(
    dashboardHeader(title = "DNABarcodeCompatibility", titleWidth = sidemenuWidth),
    sidebar,
    body
  )
)


library(shiny)
library(tidyverse)
library(collapsibleTree)
library(shinythemes)
library(shinyWidgets)

load("census_practices.RData")
load("survey_farm.RData")
load("survey_practices.RData")

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    theme = shinytheme("simplex"),
    #themeSelector(),
    
    navbarPage("Practices Comparison", id = "comparison",
               tabPanel("Comparison", value = "comparison",
                        column(12, align="center", tableOutput("practices"),
                               actionBttn(
                                   inputId = "explore",
                                   label = "Explore",
                                   style = "stretch", 
                                   color = "warning"
                               ),
                               HTML("<br><br><br><br>")
                        )),
               tabPanel("Census", value = "census_chart",
                           sidebarLayout(
                               sidebarPanel(
                                   tags$h3("USDA Census of Agriculture"),
                                   tags$b("Spatial:"), " County, State, Nation",
                                   tags$br(),
                                   tags$b("Temporal:"), "Every 5 years",
                                   tags$br(), tags$br(),
                                   "USDA Census is comprehensive. It covers all
                                   the states, as well as all the 
                                   crops that could potentially be of interest.",
                                   tags$br(), tags$br(),
                                   "Practices of interest are listed in terms of 
                                   the number of acres covered by them, and in 
                                   terms of the numbers of farms utilizing them. 
                                   These two units are further reported based on
                                   several subgroups that can be seen in the chart
                                   to the right.",
                                   tags$br(), tags$br(),
                                   tags$a(href = "https://www.nass.usda.gov/Publications/AgCensus/2017/Full_Report/Volume_1,_Chapter_1_US/usappxa.pdf",
                                          "Methodology"),
                                   tags$br(),
                                   tags$a(href = "https://www.nass.usda.gov/Publications/AgCensus/2017/Full_Report/Volume_1,_Chapter_1_US/usv1.pdf",
                                          "Report")
                               ),
                               mainPanel(collapsibleTreeOutput("census",
                                                               height = "600px",
                                                               width = "1300px"))
                           )),
               tabPanel("Survey",
                           sidebarLayout(
                               sidebarPanel(
                                   tags$h3("USDA ARMS Survey"),
                                   tags$b("Spatial:"), " 48 contiguous States",
                                   tags$br(),
                                   tags$b("Temporal:"), "Yearly",
                                   tags$br(), tags$br(),
                                   "While farms growing all types of commodities 
                                   are sampled every year, each year ARMS 
                                   oversamples farms in one or more commodity 
                                   specialization in order to produce Costs and 
                                   Returns estimates.",
                                   tags$br(), tags$br(),
                                   "The States included in commodity-specific s
                                   urveys vary each year (depending on the crops 
                                   surveyed) to help minimize respondent burden.",
                                   tags$br(), tags$br(),
                                   tags$a(href = "https://www.ers.usda.gov/data-products/arms-farm-financial-and-crop-production-practices/documentation/",
                                          "Documentation")
                               ),
                               mainPanel(collapsibleTreeOutput("survey",
                                                               height = "600px",
                                                               width = "1500px"))
                           )),
               tabPanel("Farm type",
                        sidebarLayout(
                            sidebarPanel("This chart shows how the data in the 
                                         ARMS survey report was further 
                                         subdivided, in case it is relevant to 
                                         the research process."),
                            mainPanel(collapsibleTreeOutput("farm",
                                                            height = "600px",
                                                            width = "800px"))
                        ))
               )

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    output$practices <- renderTable({
        tibble("USDA Census Practices" = c(unique(census$variable1), "", "", "", "", "", "", "", ""), 
               "USDA ARMS Survey Practices" = unique(survey$practice))
    })
    
    observeEvent(input$explore, {
        updateTabsetPanel(session, "comparison",
                          selected = "census_chart")
    })
    
    output$census <- renderCollapsibleTree({
        collapsibleTree(
            census,
            hierarchy = c("variable1", "variable2",
                          "group1", "group2"),
            width = 1300,
            height = 500,
            fill = "#fdab3a",
            zoomable = TRUE, 
            collapsed = TRUE
        )
    })
    
    output$survey <- renderCollapsibleTree({
        collapsibleTree(
            survey,
            hierarchy = c("practice", "variable", "Unit"),
            width = 1500,
            height = 800,
            fill = "#fdab3a",
            zoomable = TRUE, 
            collapsed = TRUE
        )
    })
    
    output$farm <- renderCollapsibleTree({
        collapsibleTree(
            farm,
            hierarchy = c("farm", "farm_subtype"),
            width = 800,
            height = 700,
            fill = "#fdab3a",
            zoomable = TRUE, 
            collapsed = TRUE
        )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

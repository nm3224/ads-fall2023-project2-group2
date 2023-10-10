  source('global.R')
  shinyUI(
    div(
      navbarPage(strong('National Housing Assistance'),
                 tabPanel("INTRODUCTION",
                          mainPanel(width = 12,
                                    h1("Project2: National Housing Assistance"),
                                    h2('Abstract'),
                                    p('In this project, we explore the housing assistance data from both the owners and the renters dimension. To better illustrate our works, we select saerveral variables to conduct our analysis. The main structure of this Shiny App will contain ', span(strong('Statistics')),',',span(strong('Maps')),'and',span(strong('Data')),'.'),
                                    br(),
                                    p('-',span(strong('Statistics')), ': In this part, we conduct explanatory statistics. Among the region or state that user select, we will graph a bar chart and a pie chart showing', span(code('Total Approve Amount')),'vs.',span(code('Total Damage')),', and fraction of', span(code('Total Approve Amount')), 'it takes up in the selected area.'),
                                    p('-',span(strong('Maps')), ': To better visualize our data, we use R package', span(code('choroplethrZip')),'to draw a choropleth map to show the distribution of the occurance of Housing Assistance nationwide. Furthermore, users could apply different filters to see the specific maps that he/she is interested in.'),
                                    p('-',span(strong('Data')), ': We will store both the original datasets and the processed datasets in this tab. The datatable will be presented for searching. Also, users of this app could download these datasets to conduct their own analysis.'),
                                    br(),
                                    h2('Dataset'),
                                    p('FEMA assists individuals and households through the coordination and delivery of Individual Assistance (IA) programs. IA includes a number of other programs, including Individuals and Households Program (IHP) and that in turn includes Housing Assistance (HA) and Other Needs Assistance (ONA). There we use the data from', span(a('Housing Assistance Owners',href = 'https://www.fema.gov/openfema-data-page/housing-assistance-program-data-owners-v2')),"and", span(a('Housing Assistance Renters', href = 'https://www.fema.gov/openfema-data-page/housing-assistance-program-data-renters-v2')), 'datasets.')
                                    
                          ),
                          div(class = 'footer', 'Group 2')
                 ),
                 tabPanel(
                   'Frequency',
                   
                   sidebarLayout(
                     sidebarPanel(
                       radioButtons("year_selector", "Select Year Range or Single Year:",
                                    choices = c("Year Range" = "range", "Single Year" = "single"),
                                    selected = "range"),
                       uiOutput("yearInput")
                     ),
                     
                     mainPanel(
                       tabsetPanel(
                         tabPanel("Disaster Frequency by Year",
                                  plotlyOutput("disasterPlot")
                         ),
                         tabPanel("Disaster Frequency by State",
                                  leafletOutput("disasterMap")
                         ),
                         tabPanel("Most Prevalent Disaster by Year",
                                  plotlyOutput("prevalent_incident_year")
                         ),
                         tabPanel("Most Prevalent Disaster by State",
                                  plotlyOutput("prevalent_incident_state")
                         )
                       ),
                       br(),
                       br(),
                       plotlyOutput("incidentPieChart")
                     )
                   )
                 ),
                 tabPanel('Statistics',
                          mainPanel(width = 12,
                                    h2('Statistics Summary')
                          ),
                          wellPanel(
                            tabsetPanel(type="tabs",
                                        tabPanel(title="Bar Chart of Damage vs. Assistance",
                                                 br(),                                 
                                                 h1("should be a plots here")
                                        ),
                                        tabPanel(title="Pie Chart of Each Incident Damage and Total Approved Amout",
                                                 fluidRow(splitLayout(
                                                   cellWidths = c("50%","50%"),
                                                   plotlyOutput('out_piechart1'),
                                                   plotlyOutput('out_piechart2')
                                                 ))
                                        ),
                                        tabPanel(title="Empirial Distribution",
                                                 br(),                                 
                                                 h1("should be a plots here")
                                        )
                            )
                          ),
                          sidebarPanel(style = 'opacity: 0.5; controls:hover{opacity: 1}',id = "filter2", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 50, left = "auto", right = 20, bottom = "auto", width = 200, height = "auto",
                                        h3("State and Incident Filter"),
                                        checkboxGroupInput("state1", "STATE", inline = TRUE,choices=c('None', unique(data$state))),
                                        checkboxGroupInput("incident1",  "Incident Typer:", inline = TRUE,
                                                           choices = c("None",unique(data$incidentType))
                                        )
                          ),
                          absolutePanel(style = 'opacity: 0.5; controls:hover{opacity: 1}',id = "filter1", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 200, left = "auto", right = 220, bottom = "auto", width = 200, height = "auto",
                                        h3("Percentile Filter"),
                                        sliderInput("percentile1_d", "Select the percentile of Total Damage", min=0, max=100, value=0, step=0.5),
                                        sliderInput("percentile1_a", "Select the percentile of Approved Amount", min=0, max=100, value=0, step=0.5),
                          )
                 ),
                 tabPanel("Map",
                          mainPanel(width = 12,
                                    fluidRow(splitLayout(
                                      cellWidths = c("50%","50%"),
                                      leafletOutput("out2", height = "600"),
                                      leafletOutput("out3", height = "600")
                                      ))
                                    ),
                          absolutePanel(style = 'opacity: 0.5; controls:hover{opacity: 1}',id = "filter1", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 'auto', left = "auto", right = 'auto', bottom = "50", width = 800, height = "auto",
                                        h3("State Filter"),
                                        checkboxGroupInput("state2", "STATE", inline = TRUE,choices=c('None', unique(data$state))),

                          ),
                          absolutePanel(style = 'opacity: 0.5; controls:hover{opacity: 1}',id = "filter1", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 200, left = "auto", right = 20, bottom = "auto", width = 200, height = "auto",
                                        h3("Incident Filter"),
                                        checkboxGroupInput("incident2", "Incident Typer:",
                                                           choices = c("None",unique(data$incidentType))
                                        )
                          )
                 ),
                 tabPanel('Data')
      )
    )
  )
  













  source('global.R')
  shinyUI(
    div(
      navbarPage(strong('National Housing Assistance'), theme = 'black.css',
                 tabPanel("INTRODUCTION", style = "body{background-color: #11141d}",
                          mainPanel(width = 12,style = "overflow-y:scroll; height: 850px; max-height: 750px; font-size: 18px;",
                                    h1('Image Analytics for Catastrophic Home Insurance Premium Profitability'),
                                    h2("Project2: National Housing Assistance"),
                                    h3('Abstract'),
                                    p('In this project, we explore the housing assistance data from both the owners and the renters dimension. To better illustrate our works, we select saerveral variables to conduct our analysis. The main structure of this Shiny App will contain ', span(strong('Frequency')),',',span(strong('Maps')),span(strong('Data')),'and',span(strong('Reference')),'.'),
                                    br(),
                                    p('-',span(strong('Frequency')), ': In this part, we conduct our analysis based on the yearly frequency of the assistance nationwided by several bar charts and a map. Also, for each year, we will draw a pie chart recording the proportion that assistance caused by each kind of incident takes in that year. The filters we selected are', span(code('Year')),'and',span(code('Incident Type')),'.'),
                                    p('-',span(strong('Maps')), ': To better visualize our data, we use R package', span(code('choroplethrZip')),'to draw a choropleth map to show the distribution of the occurance of Housing Assistance nationwide. Furthermore, users could apply different filters to see the specific maps that he/she is interested in. Also, two pie chart will be generated to help users see the proportion of damage/assistance that each kind of incidents takes'),
                                    p('-',span(strong('Data')), ': We will store both the original datasets and the processed datasets in this tab. The datatable will be presented for searching. Also, users of this app could download these datasets to conduct their own analysis.'),
                                    p('-',span(strong('Reference')),'In this tab, we will list all reference that is used for our analysis.'),
                                    h3('Dataset'),
                                    p('FEMA assists individuals and households through the coordination and delivery of Individual Assistance (IA) programs. IA includes a number of other programs, including Individuals and Households Program (IHP) and that in turn includes Housing Assistance (HA) and Other Needs Assistance (ONA). There we use the data from', span(a('Housing Assistance Owners',href = 'https://www.fema.gov/openfema-data-page/housing-assistance-program-data-owners-v2')),"and", span(a('Housing Assistance Renters', href = 'https://www.fema.gov/openfema-data-page/housing-assistance-program-data-renters-v2')), 'datasets.'),
                                    h3('Goal'),
                                    p('The goal with our project will be giving a possible strategy to insurance company with regard to the Damage and Assistance that each kind of incidents brings.')
                                    
                          )
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
                                  plotlyOutput("disasterMap")
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
                 tabPanel("Map",
                          
                          mainPanel(width = 12,
                                    fluidRow(splitLayout(
                                      cellWidths = c("50%","50%"),
                                      leafletOutput("out2"),
                                      leafletOutput("out3")
                                    ))
                          ),
                          #absolutePanel(style = 'opacity: 0.5; controls:hover{opacity: 1}', fixed = FALSE, draggable = TRUE,
                           #plotlyOutput('out_piechart3'),
                           #plotlyOutput('out_piechart4')
                          #),

                          sidebarPanel(style = 'opacity: 0.5}',id = "filter1", class = "panel panel-default", fixed = TRUE,
                                          top = 'auto', left = "auto", right = 'auto', bottom = "50", width = '800', height = '100',
                                          h3("State & Incident Filter"),
                                          checkboxGroupInput("state2", "STATE", inline = TRUE,choices=c('None', unique(data$state))),
                                          checkboxGroupInput("incident2", "Incident Typer:", inline = TRUE,
                                                          choices = c("None",unique(data$incidentType))
                                                          
                                        )),

                          absolutePanel(style = 'opacity: 0.5; controls:hover{opacity: 1}',id = "filter1", class = "panel panel-default", fixed = FALSE, draggable = TRUE,
                                        top = '200', left = "auto", right = '20', bottom = "auto", width = '200', height = '600',
                                        plotlyOutput('out_piechart3'),
                                        plotlyOutput('out_piechart4')),
                                        
                          
                 ),
                 tabPanel('Data',
                          tabsetPanel(
                            tabPanel('Fema Declaration',
                                     dataTableOutput('fema_declaration')
                            ),
                            
                            tabPanel('Owner Summary',
                                     dataTableOutput('owners_summary')),
                            tabPanel('Owner Data',
                                     dataTableOutput('owners_data')),
                            tabPanel('Renter Data',
                                     dataTableOutput('renters_data')),
                          )),
                 tabPanel('Reference',
                          mainPanel(
                            br(),
                            h4('The Fema Housing Assistance Program Data - Owners Dataset:'),
                            p('https://www.fema.gov/openfema-data-page/housing-assistance-program-data-owners-v2'),
                            h4('The Fema Housing Assistance Program Data - Renters Dataset:'),
                            p('https://www.fema.gov/openfema-data-page/housing-assistance-program-data-renters-v2'),
                            h4('Shiny App Sampling and Learning:'),
                            p('https://shiny.posit.co/r/getstarted/shiny-basics/lesson1/index.html'),
                            h4('Shiny App Styling:'),
                            p('https://www.youtube.com/watch?v=jYAduvkp6_c'),
                            h4('Contributors:'),
                            p('Arnulfo Andres Trevino <aat2209@columbia.edu>'),
                            p('Jingxuan Wang <jw4311@columbia.edu>'),
                            p('Julia Blake <jmb2488@columbia.edu>'),
                            p('Noreen Mayat <nm3224@barnard.edu>'),
                            p('Yichuan Lin <yl5487@columbia.edu>'),
                            p('Yucheng Lu <yl5163@columbia.edu>')
                            
                          ))
      )
    )
  )
  
  
  
  
  
  
  
  
  
  
  
  
  

  source('global.R')
  
  shinyServer(function(input,output){
    
    # pie chart
    
    #################################
    output$out_piechart3 <- renderPlotly({
      filtered_data3 <- generate_summary_data_stat(input$state2, input$incident2, 0, 0)
      filtered_data_per_3 <- filtered_data3 %>% 
        mutate(percentage_dam = Total_Damage_Sum/sum(Total_Damage_Sum))
      pie_chart3 <- plot_ly(
        filtered_data_per_3,
        labels = ~IncidentType,
        values = ~percentage_dam,
        type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        hoverinfo = 'text',
        text = ~percentage_dam,
        showlegend = FALSE
      ) %>%
        layout(title = paste("Damage"),
               showlegend = TRUE)
      
      pie_chart3
    })
    
    output$out_piechart4 <- renderPlotly({
      filtered_data4 <- generate_summary_data_stat(input$state2, input$incident2, 0, 0)
      filtered_data_per_4 <- filtered_data4 %>% 
        mutate(percentage_apamt = Total_Approved_Amount_Sum/sum(Total_Approved_Amount_Sum))
      pie_chart4 <- plot_ly(
        filtered_data_per_4,
        labels = ~IncidentType,
        values = ~percentage_apamt,
        type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        hoverinfo = 'text',
        text = ~percentage_apamt,
        showlegend = FALSE
      ) %>%
        layout(title = paste("Appamt"),
               showlegend = TRUE)
      
      pie_chart4
    })
    ################################
    
    
    
    output$out2 <- renderLeaflet({
      # heat map
      
      summary_data_result <- generate_summary_data(input$state2, input$incident2)
      
      leaflet_map_total_damage <- leaflet(summary_data_result) %>%
        addTiles() %>%
        addHeatmap(
          lng = ~longitude,
          lat = ~latitude,
          intensity = ~Total_Damage_Sum,
          radius = 15,
          blur = 15,
          max = max(summary_data_result$Total_Damage_Sum),
          minOpacity = 0.5
        ) %>%
        addControl(
          html = "<h3>Total Damage Heatmap</h3>",
          position = "topright"
        )
      
      leaflet_map_total_damage
    })
    
    output$out3 <- renderLeaflet({
      summary_data_result <- generate_summary_data(input$state2, input$incident2)
      leaflet_map_total_approved_amount <- leaflet(summary_data_result) %>%
        addTiles() %>%
        addHeatmap(
          lng = ~longitude,
          lat = ~latitude,
          intensity = ~Total_Approved_Amount_Sum,
          radius = 15,
          blur = 15,
          max = max(summary_data_result$Total_Approved_Amount_Sum),
          minOpacity = 0.5
        ) %>%
        addControl(
          html = "<h3>Total Approved Amount Heatmap</h3>",
          position = "topright"
        )
      leaflet_map_total_approved_amount
    })
    
    
    
    # Frequency tab
    
    disaster_frequency <- disaster_declaration %>%
      group_by(year) %>%
      summarize(Frequency = n())    
    output$yearInput <- renderUI({
      if (input$year_selector == "range") {
        sliderInput("year_range", "Select Year Range:",
                    min = min(disaster_frequency$year),
                    max = max(disaster_frequency$year),
                    value = c(min(disaster_frequency$year), max(disaster_frequency$year)),
                    step = 1)
      } else {
        selectInput("single_year", "Select Single Year:",
                    choices = unique(disaster_frequency$year),
                    selected = max(disaster_frequency$year))
      }
    })
    values <- reactiveValues(selected_year = NULL)
    output$disasterPlot <- renderPlotly({
      filtered_data <- switch(
        input$year_selector,
        "range" = {
          selected_year_range <- input$year_range
          filter(disaster_frequency, year >=   selected_year_range[1] & year <= selected_year_range[2])
        },
        "single" = {
          disaster_frequency$year <- as.character(disaster_frequency$year)
          filter(disaster_frequency, year == as.character(input$single_year))
        }
      )
      num_years <- length(unique(filtered_data$year))
      bar_width <- ifelse(num_years > 4, 0.8, 0.2)
      plot_ly(source = "disaster_freq", height = 400, width = 600)%>%
        add_trace(data = filtered_data, 
                  x = ~year, 
                  y = ~Frequency, 
                  type = "bar",
                  marker = list(color = "#cab2d6"),
                  width = bar_width )%>%
        layout(title = "Disaster Frequency by Year",
               yaxis = list(title = "Frequency"))%>%
        event_register("plotly_click")
    })
    
    observeEvent(event_data(event ="plotly_click", source = "disaster_freq"),{
      clicked <- event_data(event ="plotly_click", source = "disaster_freq")
      if(!is.null(clicked)){
        values$selected_year <- clicked$x
      }
    })
    output$incidentPieChart <- renderPlotly({
      validate(need(values$selected_year, message = "In the disaster frequency by year, click on a bar to view incident breakdown"))
      filtered_data <- disaster_declaration %>%
        filter(year == values$selected_year) %>%
        group_by(incidentType) %>%
        summarize(Frequency = n())
      palette <- brewer.pal(length(filtered_data$incidentType), "Set3")
      plot_ly(height = 400, width = 600) %>%
        add_trace(data = filtered_data,
                  labels = ~incidentType,
                  values = ~Frequency,
                  type = "pie",
                  marker = list(colors = palette)) %>%
        layout(title = paste("Incident Frequency for Year", values$selected_year))
    })
    
    output$disasterMap <- renderPlotly({
      plot_ly(disaster_freq_state, type = "choropleth", locationmode = "USA-states",
              z = ~Frequency, locations = ~stateCode,
              text=disaster_freq_state$stateName,
              colorscale = "YlGnBu", colorbar = list(title = "Disaster Frequency"))%>%
        layout(geo = list(scope = "usa",projection=list(type='albers usa'), 
                          showlakes=TRUE, lakecolor=toRGB('white')))
    })
    
    output$prevalent_incident_year <- renderPlotly({
      filtered_data <- switch(
        input$year_selector,
        "range" = {
          selected_year_range <- input$year_range
          filter(top_incident, year >=   selected_year_range[1] & year <= selected_year_range[2])
        },
        "single" = {
          top_incident$year <- as.character(top_incident$year)
          filter(top_incident, year == as.character(input$single_year))
        }
      )
      num_years <- length(unique(filtered_data$year))
      bar_width <- ifelse(num_years > 4, 0.8, 0.2)
      palette <- brewer.pal(n = n_distinct(top_incident$incidentType), name = "Set2")
      plot_ly(data = filtered_data, height = 400, width = 600) %>%
        add_trace(x = ~year, 
                  y = ~Frequency, 
                  type = "bar",
                  color = ~incidentType, colors = palette,
                  width = bar_width) %>%
        layout(title = list(text = "Most Prevalent Disaster by Year"),
               yaxis = list(title = "Frequency"),
               legend = list(x = 0.05, y = 1, orientation = "h"))
      
    })
    
    output$prevalent_incident_state <- renderPlotly({
      palette <- brewer.pal(n = n_distinct(top_incident$incidentType), name = "Set2")
      plot_ly(data = top_disaster_state, height = 400, width = 600) %>%
        add_trace(x = ~stateName, 
                  y = ~Frequency, 
                  type = "bar",
                  color = ~incidentType, colors = palette,
                  width = 0.8) %>%
        layout(title = list(text = "Most Prevalent Disaster by State"),
               yaxis = list(title = "Frequency"),
               legend = list(x = 0.05, y = 1, orientation = "h"),
               xaxis = list(title = "", tickangle = 45))
      
    })
    
    # Data
    
    output$fema_declaration <- renderDataTable(disaster_declaration,
                                    options = list(pageLength = 10, lengthMenu = list(c(10)))
    )
    
    output$owners_summary <- renderDataTable(disaster_owner,
                                               options = list(pageLength = 10, lengthMenu = list(c(10)))
    )
    
    output$owners_data <- renderDataTable(data,
                                             options = list(pageLength = 10, lengthMenu = list(c(10)))
    )
    
    output$renters_data <- renderDataTable(data,
                                             options = list(disaster_renter = 10, lengthMenu = list(c(10)))
    )
  })
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

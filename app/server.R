  source('global.R')
  
  shinyServer(function(input,output){
    
    # pie chart
    
    output$out_piechart1 <- renderPlotly({
      filtered_data1 <- generate_summary_data_stat(input$state1, input$incident1, input$percentile1_d, input$percentile1_a)
      filtered_data_per_1 <- filtered_data1 %>% 
        mutate(percentage_dam = Total_Damage_Sum/sum(Total_Damage_Sum))
      pie_chart1 <- plot_ly(
        filtered_data_per_1,
        labels = ~IncidentType,
        values = ~percentage_dam,
        type = 'pie'
      ) %>%
        layout(title = paste("Percentage of Total Damage"),
               showlegend = TRUE)
      
      pie_chart1
    })
    
    output$out_piechart2 <- renderPlotly({
      filtered_data2 <- generate_summary_data_stat(input$state1, input$incident1, input$percentile1_d, input$percentile1_a)
      filtered_data_per_2 <- filtered_data2 %>% 
        mutate(percentage_apamt = Total_Approved_Amount_Sum/sum(Total_Approved_Amount_Sum))
      pie_chart2 <- plot_ly(
        filtered_data_per_2,
        labels = ~IncidentType,
        values = ~percentage_apamt,
        type = 'pie'
      ) %>%
        layout(title = paste("Percentage of Total Approved Amount"),
               showlegend = TRUE)
      
      pie_chart2
    })
    

    
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
          position = "topleft"
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
    
    output$disasterMap <- renderLeaflet({
      paletteNum <- colorNumeric('Blues', domain = disaster_freq_state$Frequency)
      
      leaflet() %>%
        addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
        addPolygons(
          data = merged_data,
          fillColor = ~paletteNum(disaster_freq_state$Frequency),
          fillOpacity = 0.7,
          smoothFactor = 0.3,
          weight = 1,
          color = "white",
          highlightOptions = highlightOptions(
            weight = 3,
            color = 'dodgerblue'
          ),
          popup = ~paste("State: ", NAME, "<br>Frequency: ", disaster_freq_state$Frequency)
        ) %>%
        addLegend(
          "bottomleft",
          pal = paletteNum,
          values = disaster_freq_state$Frequency,
          title = "Disaster Frequency",
          opacity = 0.5
        ) %>%
        setView(lng = -98.35, lat = 39.5, zoom = 4)
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
    

  })

















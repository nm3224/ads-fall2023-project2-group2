  library(shiny)
  library(DT)
  library(leaflet)
  library(leaflet.extras)
  library(DT)
  library(choroplethrZip)
  library(lubridate)
  library(dplyr)
  library(plotly)
  library(ggplot2)
  library(RColorBrewer)
  library(data.table)
  library(sf)
  
  
  

  
  # Frequency
  
  
  disaster_declaration <- read.csv("data/FemaWebDisasterDeclarations.csv")
  regions <- read.csv("data/US_States_and_Regions.csv")
  disaster_declaration <- disaster_declaration[,-c(2,5,10:13,18:20)]
  disaster_declaration$stateName <- trimws(disaster_declaration$stateName)
  disaster_declaration <- disaster_declaration[disaster_declaration$stateName %in% c(unique(regions$stateName)), ]
  disaster_declaration$incidentBeginDate <- as.POSIXct(disaster_declaration$incidentBeginDate, format = "%Y-%m-%dT%H:%M:%S.%OS")
  disaster_declaration$year <- year(disaster_declaration$incidentBeginDate)
  disaster_owner <- read.csv("data/HousingAssistanceOwners.csv")
  disaster_renter <- read.csv("data/HousingAssistanceRenters.csv")
  
  top_incident <- disaster_declaration%>%group_by(year, incidentType)%>%summarize(Frequency=n())%>%arrange(year, desc(Frequency))%>%slice_max(order_by = Frequency, n = 1)
  disaster_declaration_na <- colSums(is.na(disaster_declaration))
  top_states <- disaster_declaration%>%group_by(year, stateName)%>%summarize(Frequency=n())%>%arrange(year, desc(Frequency))%>%slice_max(order_by = Frequency, n = 1)
  #Most prevalent disaster by state
  top_disaster_state <- disaster_declaration%>%group_by(stateName, incidentType)%>%summarize(Frequency=n())%>%arrange(stateName, desc(Frequency))%>%slice_max(order_by = Frequency, n = 1)
  
  
  state_boundaries <- read_sf("data/state_boundaries/state_boundaries/cb_2019_us_state_5m.shp")
  state_boundaries <- st_transform(state_boundaries, crs = "+proj=longlat +datum=WGS84")
  merged_data <- merge(state_boundaries, disaster_declaration, by.x = "NAME", by.y = "stateName", all.x = FALSE)
  disaster_freq_state <- disaster_declaration%>%group_by(stateName)%>%summarize(Frequency=n())
  
  
  
  
  
  
  
  
  ## draw map
  
  data <- read.csv("data/owners_summary_zip.csv")
  
  summary_data <- data %>%
    group_by(latitude, longitude) %>%
    summarise(
      Total_Damage_Sum = sum(total_damage_sum, na.rm = TRUE),
      Total_Approved_Amount_Sum = sum(total_approved_amount_sum, na.rm = TRUE),
      .groups = 'drop'
    )
  
  try_fil <- data %>% filter(latitude>10) %>% filter(incidentType == c('Hurricane', 'Tornado'))
  
  
  
  # generate data after applying the filters for map tab
  generate_summary_data <- function(state_names, disaster_names) {

    if (all(state_names == "None") && all(disaster_names == "None")) {
      filtered_data <- data
    } else if (all(state_names == "None")) {
      filtered_data <- data %>% filter(incidentType %in% disaster_names)
    } else if (all(disaster_names == "None")) {
      filtered_data <- data %>% filter(state %in% state_names)
    } else {
      filtered_data <- data %>% filter(state %in% state_names & incidentType %in% disaster_names)
    }
    
    

    summary_data <- filtered_data %>%
      group_by(latitude, longitude) %>%
      summarise(
        Total_Damage_Sum = sum(total_damage_sum, na.rm = TRUE),
        Total_Approved_Amount_Sum = sum(total_approved_amount_sum, na.rm = TRUE),
        .groups = 'drop'
      )
    
    return(summary_data)
  }
  
  
  # generate data after applying the filters for statistics tab
  generate_summary_data_stat <- function(state_names, disaster_names, dam_per, apamt_per) {
    
    if (all(state_names == "None") && all(disaster_names == "None")) {
      filtered_data <- data
    } else if (all(state_names == "None")) {
      filtered_data <- data %>% filter(incidentType %in% disaster_names)
    } else if (all(disaster_names == "None")) {
      filtered_data <- data %>% filter(state %in% state_names)
    } else {
      filtered_data <- data %>% filter(state %in% state_names & incidentType %in% disaster_names)
    }
    
    
    
    summary_data <- filtered_data %>%
      filter(total_damage_sum >= quantile(filtered_data$total_damage_sum,dam_per/100)) %>%
      filter(total_approved_amount_sum >= quantile(filtered_data$total_approved_amount_sum,apamt_per/100)) %>%
      group_by(latitude, longitude) %>%
      summarise(
        Total_Damage_Sum = sum(total_damage_sum, na.rm = TRUE),
        Total_Approved_Amount_Sum = sum(total_approved_amount_sum, na.rm = TRUE),
        IncidentType = incidentType,
        .groups = 'drop'
      )
    
    return(summary_data)
  }
  

  
  
  
  
  
  
  
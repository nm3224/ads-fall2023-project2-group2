library(dplyr)
library(lubridate)

#Data Pre-processing
disaster_declaration <- read.csv("C:\\Users\\wangj\\Desktop\\ADS-Project2\\FemaWebDisasterDeclarations.csv")
regions <- read.csv("C:\\Users\\wangj\\Desktop\\ADS-Project2\\US_States_and_Regions.csv")
disaster_declaration <- disaster_declaration[,-c(2,5,10:13,18:20)]
disaster_declaration$stateName <- trimws(disaster_declaration$stateName)
disaster_declaration <- disaster_declaration[disaster_declaration$stateName %in% c(unique(regions$stateName)), ]
disaster_declaration$incidentBeginDate <- as.POSIXct(disaster_declaration$incidentBeginDate, format = "%Y-%m-%dT%H:%M:%S.%OS")
disaster_declaration$year <- year(disaster_declaration$incidentBeginDate)

#Disaster frequency by year
disaster_frequency <- disaster_declaration%>%group_by(year)%>%summarize(Frequency = n())

#Most prevalent disaster by year
top_incident <- disaster_declaration%>%group_by(year, incidentType)%>%summarize(Frequency=n())%>%arrange(year, desc(Frequency))%>%slice_max(order_by = Frequency, n = 1)

#Most prevalent disaster by state
top_disaster_state <- disaster_declaration%>%group_by(stateName, incidentType)%>%summarize(Frequency=n())%>%arrange(stateName, desc(Frequency))%>%slice_max(order_by = Frequency, n = 1)

#Disaster Frequency by State
disaster_freq_state <- disaster_declaration%>%group_by(stateName,stateCode)%>%summarize(Frequency=n())
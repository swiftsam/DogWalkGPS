####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Visualize Dog Walk GPS data
###
### Purpose
###  * Basic visualizations of gps data
### 
### Notes:
###  * Uses points.RData created by extract_points.R
###
### Primary Creator(s): Sam Swift (samswift@berkeley.edu)
####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(data.table)
library(ggmap)

# set file paths
kWorkingDir <- file.path("~","DogWalkGPS")

# load data
load(file.path(kWorkingDir, "points.RData"))

# histogram of walk length in minutes
ggplot(points[,max(minutes),by=id], aes(V1)) + 
  geom_histogram(breaks=30:90, fill="white", color="darkgreen") +
  scale_x_continuous(breaks=seq(30,90,5)) +
  theme_grey(base_size=16) +
  labs(x="Time")

# get google maps for carrboro and pittsburgh
carrboro   <- get_googlemap(center=c(lon=-79.074004, lat=35.914552), zoom=14)
greenfield <- get_googlemap(center=c(lon=-79.94133,  lat=40.425886), zoom=14)

# basic plots for each city
ggmap(carrboro) +
  geom_point(data=points[location=="Carrboro",],
             aes(y=lat, x=lon), 
             alpha=.3, shape=4)

ggmap(greenfield) +
  geom_point(data=points[location=="Pittsburgh"], 
             aes(y=lat, x=lon), 
             alpha=.5, shape=4)

# beginning of time-based plots
ggmap(carrboro) +
  geom_point(data=points[location=="Carrboro" & 
                           1800 <= elapsed & 
                           elapsed <= 1900,], 
             aes(y=lat, x=lon), 
             alpha=.7, shape=4)

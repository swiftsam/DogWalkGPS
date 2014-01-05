####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Process Dog Walk GPS data
###
### Purpose
###  * I've collected GPS logs of my dog walks for a couple of years.  This
###    script pulls the data out of the exported XML files and compiles it.
### 
### Notes:
###  * GPS logging was done with the Endomondo[1] app for android using primarily
###    my Droid Charge and then Galaxy S4
###  * XML exports were collected using the exportodmondo[2] app for android
###
###  [1] https://play.google.com/store/apps/details?id=com.endomondo.android.pro
###  [2] https://play.google.com/store/apps/details?id=com.scrapeleton.exportomondo
###
### Primary Creator(s): Sam Swift (samswift@berkeley.edu)
####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(XML)
library(data.table)
library(ggmap)

# set file paths
kWorkingDir <- file.path("~","DogWalkGPS")
kDataDir    <- file.path(kWorkingDir, "data")

# intialize output data.table
points <- data.table()

# extract the identifying info and points from each file
for(file in list.files(kDataDir)){
  message(file)
  file <- file.path(kDataDir,file)
  data <- xmlToList(xmlParse(file))
  
  # track IDs are contained within a URL in the XML files
  # the URL is of this format
  # http://www.endomondo.com/workouts/273983343/3087379
  # and we want the the second-to-last bit
  trk.id   <- as.integer(strsplit(data$trk$link$.attrs[["href"]],"/")[[1]][5])
  
  # track type (e.g. "WALKING" or "RUNNING")
  trk.type <- data$trk$type

  # loop over each point in the track and format data
  trkseg   <- data$trk$trkseg
  for(i in 1:length(trkseg)){
    trkpt <- trkseg[i]$trkpt
    row   <- data.table(id   = trk.id,
                        type = trk.type,
                        time = as.POSIXct(strptime(trkpt$time,
                                        format="%Y-%m-%dT%H:%M:%S",
                                        tz="GMT")),
                        lat  = as.numeric(trkpt$.attrs["lat"]),
                        lon  = as.numeric(trkpt$.attrs["lon"]))    
    points <- rbindlist(list(points, row))
  }
}

# set data.table keys
setkeyv(points, c("id","time"))

# calculate derived values
points[,elapsed := time - min(time), by=id]
points[,minutes := floor(elapsed / 60)]

# reverse geocode starting point of each walk
starting.locs <- points[, list(location = as.character(
  revgeocode(location = c(lon=lon[1], 
                          lat=lat[1]), 
             output   = "more")$locality)), 
                        by=id]

points <- merge(points, starting.locs, by="id")

save(points, file=file.path(kWorkingDir,"points.RData"))

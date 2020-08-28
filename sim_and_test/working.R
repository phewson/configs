getdfAllowedUnits <- function(){
  unitname <- c("sec", "min", "hour", "day")
  conversion <- c(1, 60, 3600, 86400)
  returnFrame <- data.frame(unitname, conversion)
  return(returnFrame)
}

occupancy <- function(startTimes, stopTimes, resolution = "min", initial = NULL, fillup = NULL, countlast = TRUE){
  #library.dynam("updateArray")
  #orginTime<-as.POSIXct('01/01/1970 00:00',format ="%m/%d/%Y %H:%M", tz = "GMT")
  
  # Check in input is in correct format
  if(!identical(class(startTimes), c("POSIXct","POSIXt")))
    stop(paste("startTimes is class ", class(startTimes),". Must be class POSIXct POSIXt.", sep = ""))
  
  # Check in output is in correct format
  if(!identical(class(stopTimes), c("POSIXct","POSIXt")))
    stop(paste("startTimes is class ", class(stopTimes),". Must be class POSIXct POSIXt.", sep = ""))
  
  # Check if both initial and fillup are specified
  if(!is.null(fillup) & !is.null(initial))
    stop("It does not make sense to det both initial and fillup parameters.")
  
  dfAllowedUnits <- getdfAllowedUnits()
  # Check if resolution is an allowed unit
  if (!(resolution %in% dfAllowedUnits$unitname)) {
    allowedunitspaste <-  paste(dfAllowedUnits$unitname, collapse = ", ")
    stop(paste('Resolution can only be set to the following:', allowedunitspaste))
  }
  
  # Calculate LOS (length-of-stay) for each item, remove any negatives. units requires an S added to resolution
  LOS <- as.numeric(stopTimes - startTimes, units = paste(resolution, "s", sep = ""))
  badrecords <- which(LOS <= 0 | is.na(LOS))
  if(length(badrecords) > 0) {
    warning(paste(length(badrecords), " removed because duration is either negative or NA", sep = ""))
    startTimes <- startTimes[-badrecords]
    stopTimes<- stopTimes[-badrecords]
  }
  
  earliestTime <-  min(startTimes)
  latestTime <-  max(stopTimes)
  
  # Get conversion factor
  conversion <- dfAllowedUnits[dfAllowedUnits$unitname == resolution, "conversion"]
  
  startMin <- ceiling((as.numeric(startTimes) -  as.numeric(min(startTimes)))/conversion)
  stopMin  <- ceiling((as.numeric(stopTimes) -   as.numeric(min(startTimes)))/conversion)
  totalMin <- length(startMin)
  
  # consider if the last time unit should be counted (i.e., count the minute that something departs?)
  if(countlast){
    countlastpassed <- 0
  } else {
    countlastpassed <- 1
  }
  
  countsfull<-.C("updateArray", size = as.integer(totalMin), starts = as.double(startMin), stops = as.double(stopMin), returnX = as.double(rep(0,max(stopMin) + 1)), countlast = as.integer(countlastpassed))
  print(str(countsfull))
  counts <- countsfull$returnX
  
  times <- seq(from = trunc(earliestTime, units = resolution), to = trunc(latestTime,units = resolution), length.out = length(counts))
  returnFrame <- as.data.frame(times)
  print(earliestTime)
  print(latestTime)
  print(totalMin)
  print(length(counts))
  print(length(times))
  return(returnFrame)
}
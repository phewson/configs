library(hillmakeR)
library(plyr)
library(ggplot2)

transactions <- read.csv("~/transactions.csv", stringsAsFactors=FALSE)
transactions <- subset(transactions, transactions$duration > 0)
transactions$starttime <- as.POSIXct(transactions$starttime, "%Y-%m-%d %H:%M:%S")
transactions$endtime <- as.POSIXct(transactions$endtime, "%Y-%m-%d %H:%M:%S")
source('~/bodgyfix.R')
occ <- with(transactions, occupancy(starttime, endtime, resolution="hour", fillup=0.95))
plot(occ$times, occ$counts)
rm(occ)
occ_by_customer_id <- ddply(
  transactions, "customer_id", 
  function(x) occupancy(startTimes=x$starttime, stopTimes=x$endtime,
                        resolution="hour", fillup=0.95)
)


pmWaw <- 
  ggplot(aes(x=times, y=counts), data = occ_by_customer_id[occ_by_customer_id$customer_id == "23",]) + geom_line() +
  facet_wrap( ~ customer_id)
pmWaw

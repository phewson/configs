# index="cloud_spark_859" | where device_mac_address != "" | table device_mac_address, unique_session_id, timestamp, type, view, page, termination_cause | sort device_mac_address, timestamp
library(bupaR)
library(readr)
library(tidyr)
library(stringr)
library(processanimateR)
library(eventdataR)

events <- read_csv("~/events_2020_2_14.csv")
events$type <- str_replace(events$type, "Start", "SessionStart")
events$type <- str_replace(events$type, "Stop", "SessionStop")


allocate_session_id <- function(device, session){
  n <- length(device)
  d_old <- device[n]
  u_old <- session[n]
  for (i in c((n-1):1)){
    d_new <- device[i]
    u_new <- session[i]
    if (!is.na(u_old)){
      if (is.na(u_new)){
        if (d_old == d_new){
          u_new <- u_old
          session[i] <- u_old
        }
      }
    }
    d_old <- d_new
    u_old <- u_new
    }
  return(session)
  }

test <- data.frame("d"=c(1, 1, 1, 2, 2, 2, 3, 3, 3), "u"=c(NA, 9, 9, NA, NA, 10, NA, NA, NA))
u2 <- allocate_session_id(test$d, test$u)
na.omit(u2) == c(9, 9, 9, 10, 10, 10)



events <- events %>% unite("tv", type:view, na.rm=TRUE, remove=TRUE) %>% 
  unite("tp", tv:page, na.rm=TRUE, remove=TRUE) %>% 
  unite("activity", tp:termination_cause, na.rm=TRUE, remove=TRUE)
events$timestamp <- as.POSIXct(events$timestamp, origin="1970-01-01")
events$uid <- allocate_session_id(events$device_mac_address, events$unique_session_id)

# events <- na.omit(events)
#ai <- tapply(events$activity_instance, events$uid, function(x) make.names(x,unique=T))


activities <- events %>% 
  mutate(status = "complete", 
         activity_instance = 1:nrow(.)) %>%
  eventlog(
    case_id = "uid",
    activity_id = "activity",
    activity_instance_id = "activity_instance",
    lifecycle_id = "status",
    timestamp = "timestamp",
    resource_id = "device_mac_address"
  )

q1 <- function(x, na.rm){return(quantile(x, probs=c(0.25), na.rm=TRUE, names=FALSE)[1])}
q3 <- function(x, na.rm){return(quantile(x, probs=c(0.75), na.rm=TRUE, names=FALSE)[1])}

activities %>% process_map(type = frequency("relative_case", color_scale = "Purples"))
activities %>% process_map(performance(median, "secs"))
activities %>% process_map(performance(q1, "secs"))
activities %>% process_map(performance(q3, "secs"))

activities %>% filter_activity_frequency(percentage = 0.7, reverse = FALSE) %>%
animate_process(type = frequency("absolute_case", color_scale="Reds"), mapping = token_aes(
  size = token_scale(12), shape = "image", 
  image = token_scale("https://upload.wikimedia.org/wikipedia/en/5/5f/Pacman.gif")))
  # shape = "rect", color = token_scale("red")))

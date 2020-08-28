# plumber.R
library(dplyr)
library(reshape2)
library(lubridate)
library(hms)
library(jsonlite)
library(hillmakeR)
library(mgcv)
library(sf)
library(gifski)
library(readr)
library(gganimate)
library(ggplot2)
library(tidyverse)
library(rgeos)
library(rgdal)
library(sp)

source('sim_and_test/bodgyfix.R')

standard_summary <- function(registrations, sessions){
  new_registrations <- length(registrations$regtime)
  unique_devices <- length(unique(sessions$device_mac_address))
  n_sessions <- length(sessions$starttime)
  data_up_down = round(sum(sessions$uploaded_data_gb, na.rm=TRUE) + sum(sessions$downloaded_data_gb, na.rm=TRUE), 2)
  total_duration = sum(as.numeric(sessions$duration), na.rm=TRUE) / 60
  standard <- c(new_registrations, unique_devices, n_sessions, data_up_down, total_duration)
  names(standard) <- c("new_registrations", "unique_devices", "n_sessions", "data_up_down", "total_duration")
  return(standard)
}

rightstr = function(text, num_char) {
  substr(text, nchar(text) - (num_char-1), nchar(text))
}

extract_plot <- function(fit){
  x <- fit$x
  lower <- exp(fit$fit - 1.96 * fit$se)
  upper <- exp(fit$fit + 1.96 * fit$se)
  y_p <- exp(fit$fit)    
  return(data.frame("x"=x, "y_p"=y_p, "y_l"=lower, "y_u"=upper))
}

make_poly <- function(x, lower, upper){
  n <- length(x)
  x <- c(x[1], x, x[n:1], x[1])
  y <- c(0, upper, lower[n:1], 0)
  return(cbind(x, y))
}

remove_orphans <- function(choose, df){
  if (choose == "r") {
    return(subset(df, endtimemod == 0))
  } else if (choose == "i") {
    return(df)
  } else if (choose == "imp") {
    sub_comp <- subset(df, endtimemod == 0)
    sub_mod <- subset(df, endtimemod == 1)
    n <- length(sub_mod$starttime)
    sim_durations <- sample(sub_comp$duration, size=n, replace=TRUE)
    sub_mod$endtime <- sub_mod$starttime + sim_durations
    return(data.frame(starttime = c(sub_comp$starttime, sub_mod$starttime), endtime=c(sub_comp$endtime, sub_mod$endtime)))
  }
}

#* @get /customer_ids
function(){
  con <- file("data/customer_ids.json")
  customer_ids <- fromJSON(readLines(con))
  close(con)
  return(customer_ids)
}

#* Get customer session data
#* @param customer_id Customer id number
#* @get /customer_sessions
function(customer_id="23"){
  con <- file(paste("data/sessions_", customer_id, ".json", sep=""))
  customer_data <- fromJSON(readLines(con))
  close(con)
  return(customer_data)
}

#* Get customer registration data
#* @param customer_id Customer id number
#* @get /customer_registrations
function(customer_id="23"){
  con <- file(paste("data/registrations_", customer_id, ".json", sep=""))
  customer_data <- fromJSON(readLines(con))
  close(con)
  return(customer_data)
}


#* Get customer occupancy
#* @param customer_id Customer id number
#* @param orphans How to handle orphans (r/i/imp)
#* @param ch_resolution time resolutions (hours/minutes)
#* @get /occupancy
function(customer_id="23", orphans="r", ch_resolution="hour"){
  con <- file(paste("data/sessions_", customer_id, ".json", sep=""))
  customer_data <- fromJSON(readLines(con))
  close(con)
  customer_data$starttime <- as.POSIXct(customer_data$starttime, "%Y-%m-%d %H:%M:%S")
  customer_data$endtime <- as.POSIXct(customer_data$endtime, "%Y-%m-%d %H:%M:%S")
  local_sessions <- remove_orphans(orphans, customer_data)
  local_sessions <- subset(local_sessions, starttime < endtime)
  occ <- occupancy(startTimes=local_sessions$starttime, stopTimes=local_sessions$endtime,
            resolution=ch_resolution, initial=0, countlast=FALSE)
  m1 <- gam(counts ~ s(hour(times)) + s(as.numeric(times)) + factor(wday(times, label=TRUE), ordered=FALSE), data=occ,
            family = poisson())
  predictions <- predict(m1, se=TRUE)
  pdf(NULL)
  fitted <- plot(m1)
  dev.off()
  day_effect <- c(1, exp(coef(m1)[2:7]))
  names(day_effect) <- c("Sun", rightstr(names(coef(m1)[2:7]), 3))
  trend <- extract_plot(fitted[[2]])
  hour_effect <- extract_plot(fitted[[1]])
  y_p <- exp(predictions$fit)
  y_l <- exp(predictions$fit - 1.96 * predictions$se)
  y_u <- exp(predictions$fit + 1.96 * predictions$se)
  # poly_interval <- make_poly(occ$times, y_u, y_l)
  model_preds <- data.frame("x"=occ$times, "y"=occ$counts, "y_l"=y_l, "y_p"=y_p, "y_u"=y_u)
  
  return(list("sessions"=local_sessions, "occ"=occ, 
              "model_preds"=model_preds, "hour_effect"=hour_effect,
              "day_effect"=day_effect, "names_day_effect"=names(day_effect), "trend"=trend))
}


#* Hotspot Activity
#* @get /hotspots
function(){
  load("~/phewson_configs/geolocated.Rdata")
  data_usage <- read.csv("~/phewson_configs/starbucks_data_usage.csv")
  new_reg <- read.csv("~/phewson_configs/new_registrations_by_hotspot.csv")
  starbucks.gl <- merge(starbucks.gl, data_usage, by.x="starbucks.LF_hotspot_id", by.y="hotspot_id")
  starbucks.gl <- merge(starbucks.gl, new_reg, by.x="starbucks.LF_hotspot_id", by.y="hotspot.id")
  starbucks.gl$lat <- sf::st_coordinates(starbucks.gl$geometry)[,2]
  starbucks.gl$lon <- sf::st_coordinates(starbucks.gl$geometry)[,1]
  sb <- with(starbucks.gl, data.frame(
     "lat"=lat, "lon"=lon, "downloaded"=sum.cf_session_downloaded_data_gb.,    
     "uploaded"=sum.cf_session_uploaded_data_gb., "new_reg" = count,
     "label"=paste("Geocoded: ", address.x, "Original: ", address.y, sep=" ")))
return(sb)
}


#* Get standard summary
#* @param customer_id Customer id number
#* @get /standard_analytics
function(customer_id="23", this_month_start="2020-01-01", chosen_start="2019-09-01",
         chosen_end="2020-02-01", three_months_ago="2019-09-01"){
  this_month_start <- as.POSIXct(this_month_start, "%Y-%m-%d")
  chosen_start <- as.POSIXct(chosen_start, "%Y-%m-%d")
  chosen_end <- as.POSIXct(chosen_end, "%Y-%m-%d")
  three_months_ago <- as.POSIXct(three_months_ago, "%Y-%m-%d")
  con <- file(paste("data/registrations_", customer_id, ".json", sep=""))
  registrations <- fromJSON(readLines(con))
  close(con)
  con <- file(paste("data/sessions_", customer_id, ".json", sep=""))
  sessions <- fromJSON(readLines(con))
  close(con)
  this_month <- if ((length(registrations[(registrations$regtime >= this_month_start),]) > 0) & 
                    (length(sessions[(sessions$starttime >= this_month_start),]) > 0)) {
    standard_summary(registrations[(registrations$regtime >= this_month_start),],
                     sessions[(sessions$starttime >= this_month_start),])} else {c(0,0,0,0,0)}
  chosen_period <- if ((length(registrations[(registrations$regtime >= chosen_start & registrations$regtime <= chosen_end),]) > 0) &
                       (length(sessions[(sessions$starttime >= chosen_start & sessions$starttime <= chosen_end),]) > 0)) {
    standard_summary(
        registrations[(registrations$regtime >= chosen_start & registrations$regtime <= chosen_end),], 
        sessions[(sessions$starttime >= chosen_start & sessions$starttime <= chosen_end),])} else {c(0,0,0,0,0)}
  three_month_registrations <- registrations[
    (registrations$regtime >= three_months_ago & registrations$regtime < this_month_start),]  
  three_month_sessions <- sessions[
    (sessions$starttime >= three_months_ago & sessions$starttime < this_month_start),]  
  
  monthly_reg_data <- three_month_registrations %>%
    group_by(paste(year(three_month_registrations$regtime), month(three_month_registrations$regtime))) %>%
    summarise("unique_devices" = n_distinct(device_mac_address))
  colnames(monthly_reg_data) = c("monthno", "n")
  
  monthly_session_data <- three_month_sessions %>%
    group_by(paste(year(three_month_sessions$starttime), month(three_month_sessions$starttime))) %>%
    count()
  colnames(monthly_session_data) = c("monthno", "n")
  
  monthly_data_usage <- three_month_sessions %>%
    group_by(paste(year(three_month_sessions$starttime), month(three_month_sessions$starttime))) %>%
    summarise(total_downloaded_data_gb = sum(downloaded_data_gb),
              total_uploaded_data=sum(uploaded_data_gb))
  dfm <- melt(monthly_data_usage, id.vars = 1)
  colnames(dfm) = c("monthno", "variable", "value")
  
  monthly_session_times <- three_month_sessions %>%
    group_by(paste(year(three_month_sessions$starttime), month(three_month_sessions$starttime))) %>%
    summarise(session_time = sum(duration, na.rm=TRUE))
  colnames(monthly_session_times) = c("monthno", "value")
  
  return(list("this_month"=this_month, "chosen_period"=chosen_period, "dfm"=dfm, 
              "monthly_reg_data"=monthly_reg_data, "monthly_session_data"=monthly_session_data,
              "monthly_session_times"=monthly_session_times))
}


#* @serializer contentType list(type="application/gif")
#* @get /gif
function(){
  starbucks_top_ten_new_reg <- read_csv("~/phewson_configs/starbucks_top_ten_new_reg.csv")
  dtg <- (year(starbucks_top_ten_new_reg$`_time`) - 2019) * 12 + month(starbucks_top_ten_new_reg$`_time`)
  starbucks_top_ten_new_reg$dtg <- dtg
  gap_smoother <- starbucks_top_ten_new_reg %>%
    group_by(hotspot.id) %>%
    # Do somewhat rough interpolation for ranking
    # (Otherwise the ranking shifts unpleasantly fast.)
    complete(dtg = full_seq(dtg, 1)) %>%
    mutate(count = spline(x = dtg, y = count, xout = dtg)$y) %>%
    group_by(dtg) %>%
    mutate(rank = min_rank(-count) * 1) %>%
    ungroup() %>%
    # Then interpolate further to quarter years for fast number ticking.
    # Interpolate the ranks calculated earlier.
    group_by(hotspot.id) %>%
    complete(dtg = full_seq(dtg, .5)) %>%
    mutate(count = spline(x = dtg, y = count, xout = dtg)$y) %>%
    # "approx" below for linear interpolation. "spline" has a bouncy effect.
    mutate(rank = spline(x = dtg, y = rank, xout = dtg)$y) %>%
    ungroup()  %>% 
    arrange(hotspot.id, dtg)
  
  get_months <- function(x){
    x <- x - 6
    return(c("Jul 2019", "Aug 2019", "Sep 2019", "Oct 2019", "Nov 2019", "Dec 2019", "Jan 2020")[x])}
  
  p <- ggplot(gap_smoother, aes(rank, group = hotspot.id, 
                                fill = as.factor(hotspot.id), color = as.factor(hotspot.id))) +
    geom_tile(aes(y = count,
                  height = count,
                  width = 0.9), alpha = 0.8, color = NA) +
    # text in x-axis (requires clip = "off" in coord_*)
    # paste(country, " ")  is a hack to make pretty spacing, since hjust > 1 
    #   leads to weird artifacts in text spacing.
    geom_text(aes(y = count, label = scales::comma(count)), hjust = 0, nudge_y = 300 ) +
    geom_text(aes(y = 0, label = paste(hotspot.id, " ")), vjust = 0.2, hjust = 1) +
    coord_flip(clip = "off", expand = FALSE) +
    scale_y_continuous(labels = scales::comma) +
    scale_x_reverse() +
    guides(color = FALSE, fill = FALSE) +
    labs(title='{closest_state %>% as.numeric %>% floor %>% get_months}',  x = "", y = "New Registrations") +
    # labs(title='{closest_state}', x = "", y = "New registrations") +
    theme(plot.title = element_text(hjust = 0, size = 22),
          axis.ticks.y = element_blank(),  # These relate to the axes post-flip
          axis.text.y  = element_blank(),  # These relate to the axes post-flip
          plot.margin = margin(1,1,1,4, "cm")) +
    transition_states(dtg, transition_length = 1, state_length = 0) +
    enter_grow() +
    exit_shrink() +
    ease_aes('linear')
  
  woo <- animate(p, fps = 20, duration = 5, width = 400, height = 600, end_pause = 30, renderer = gifski_renderer())
  anim_save(woo, file="woo.gif")
  return(readBin("woo.gif", "raw"))
}


#* Get oac
#* @param hotspot_id
#* @param granularity
#* @get /oac
function(hotspot_id="28", granularity="1"){
gran <- c(quo(supergroup), quo(group), quo(subgroup_label), quo(description), quo(top_10))[as.numeric(granularity)][[1]]
if (!file.exists("~/phewson_configs/chiltern.Rdata")) {
interim_2011_OAC_May_2014_ONSPD_Lookup <- read_csv("~/phewson_configs/sim_and_test/interim_2011_OAC_May_2014_ONSPD_Lookup.csv")
interim_OAC_2011_description <- read_csv("~/phewson_configs/sim_and_test/interim_OAC_2011_description.csv")
chiltern <- read_csv("~/phewson_configs/sim_and_test/chiltern_janfeb2019.csv", na=c("", "null"))
chiltern <- na.omit(chiltern)
# chiltern$form_data.zip_code <- gsub(" ", "", chiltern$form_data.zip_code)
chiltern <- merge(chiltern, interim_2011_OAC_May_2014_ONSPD_Lookup[,c(1, 4, 5, 11)], by.x="form_data.zip_code", by.y="PCDS", all.x=TRUE)
rm(interim_2011_OAC_May_2014_ONSPD_Lookup)
chiltern <- merge(chiltern, interim_OAC_2011_description, by.x="SUBGRP", by.y="SUBGRP", all.x=TRUE)
interim_OAC_2011_Top_10_Forenames <- read_csv("sim_and_test/interim_OAC_2011_Top_10_Forenames.csv")
interim_OAC_2011_Top_10_Forenames$top_10 <- with(interim_OAC_2011_Top_10_Forenames, paste(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, sep=", "))
interim_OAC_2011_Top_10_Forenames <- interim_OAC_2011_Top_10_Forenames[,c(1, 13)] 
chiltern <- merge(chiltern, interim_OAC_2011_Top_10_Forenames, by.x="SUBGRP", by.y="SUBGRP", all.x=TRUE)
chiltern$description <- iconv(chiltern$description, "UTF-8", "UTF-8",sub='')
save(chiltern, file="~/phewson_configs/chiltern.Rdata")
} else {load("~/phewson_configs/chiltern.Rdata")}

my_summarise <- function(df, group_var, hotspot_id) {
  df %>%
    filter(hotspot.id == hotspot_id) %>%
    group_by(!! group_var) %>%
    summarise(portal=sum(count)) %>% 
    arrange(desc(portal))
}
groups_by_hotspot <- my_summarise(chiltern, gran, hotspot_id)

#groups_by_hotspot <- chiltern %>% 
#  group_by(hotspot.id, gran[as.numeric(granularity)]) %>% 
#  summarise(sum(count))
colnames(groups_by_hotspot) <- c("Description", "Portal events")
return(groups_by_hotspot)
}


#* Get map data
#* @param hotspot_id
#* @get /map
function(hotspot_id=31){
if (!file.exists("~/phewson_configs/las.Rdata")){
  las <- readOGR("~/phewson_configs/sim_and_test/Local_Authority_Districts_April_2019_Boundaries_UK_BFE.shp")
  bas <- spTransform(las, "+init=epsg:4326")
  data <- bas@data
  bas <- gSimplify(bas, tol=0.001)
  bas <- SpatialPolygonsDataFrame(bas, data)
  save(bas, file="~/phewson_configs/las.Rdata")} else {}

if (!file.exists("~/phewson_configs/chiltern.Rdata")) {
    interim_2011_OAC_May_2014_ONSPD_Lookup <- read_csv("~/phewson_configs/sim_and_test/interim_2011_OAC_May_2014_ONSPD_Lookup.csv")
    interim_OAC_2011_description <- read_csv("~/phewson_configs/sim_and_test/interim_OAC_2011_description.csv")
    chiltern <- read_csv("~/phewson_configs/sim_and_test/chiltern_janfeb2019.csv", na=c("", "null"))
    chiltern <- na.omit(chiltern)
    # chiltern$form_data.zip_code <- gsub(" ", "", chiltern$form_data.zip_code)
    chiltern <- merge(chiltern, interim_2011_OAC_May_2014_ONSPD_Lookup[,c(1, 4, 5, 11)], by.x="form_data.zip_code", by.y="PCDS", all.x=TRUE)
    rm(interim_2011_OAC_May_2014_ONSPD_Lookup)
    chiltern <- merge(chiltern, interim_OAC_2011_description, by.x="SUBGRP", by.y="SUBGRP", all.x=TRUE)
    interim_OAC_2011_Top_10_Forenames <- read_csv("sim_and_test/interim_OAC_2011_Top_10_Forenames.csv")
    interim_OAC_2011_Top_10_Forenames$top_10 <- with(interim_OAC_2011_Top_10_Forenames, paste(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, sep=", "))
    interim_OAC_2011_Top_10_Forenames <- interim_OAC_2011_Top_10_Forenames[,c(1, 13)] 
    chiltern <- merge(chiltern, interim_OAC_2011_Top_10_Forenames, by.x="SUBGRP", by.y="SUBGRP", all.x=TRUE)
    chiltern$description <- iconv(chiltern$description, "UTF-8", "UTF-8",sub='')
    save(chiltern, file="~/phewson_configs/chiltern.Rdata")
  } else {load("~/phewson_configs/chiltern.Rdata")}
  
groups_by_la <- chiltern %>% 
  filter(hotspot.id == hotspot_id) %>%
  group_by(LA_CODE) %>% 
  summarise(sum(count))
colnames(groups_by_la) <- c("lad19cd", "registrations")
return(groups_by_la)
}



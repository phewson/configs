library(dplyr)
library(tidyr)
library(rAmCharts)
library(googledrive)
library(readr)
# drive_mkdir("annual_summary_2019")

drive_auth(use_oob = TRUE)

menu_obj <- list(list(class = "export-main",
                      menu = list(
                        list(label = "Download", menu = list("PNG", "JPG", "CSV")),
                        list(label = "Annotate", action = "draw",
                             menu = list(list(class = "export-drawing", menu = list("PNG", "JPG"))))
                      )))

calc_other <- function(df){
  return(rowSums(
    subset(df, 
           select=c("campsite", "hotel", "library_museum", "marina", "staff", "testing", "unknown", "venue"))))
}


new_registrations_2019 <- read_csv("2019/new_registrations_by_sector_month.csv")
new_registrations_wide <- new_registrations_2019 %>% spread(sector, count)
new_registrations_wide$month <- as.character(lubridate::month(new_registrations_wide$`_time`))
new_registrations_wide$other <- rowSums(
  subset(new_registrations_wide, 
         select=c("campsite", "hotel", "library_museum", "marina", "staff", "testing", "unknown", "venue")))

new_registrations <- amBarplot(
  x = "month", y = c("transport", "healthcare", "retail", "other"), data = new_registrations_wide, 
  groups_color=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c"), legend=TRUE,
  xlab="Month", ylab="New User Registrations", main="Summary of New User Registrations by Sector 2019") %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(new_registrations), file = "new_registrations_by_month.html")

drive_put("~/new_registrations_by_month.html", path="annual_summary_2019/")

annual_totals_new_registrations <- new_registrations_2019 %>%
  mutate(label = stringr::str_replace(sector, "campsite|hotel|library_museum|marina|staff|testing|unknown|venue", "other")) %>%
  group_by(label) %>%
  summarise(value=sum(count))
annual_totals_new_registrations$color <- c("#2db8c5", "#9d9d9c", "#fdc300", "#2daa56")
new_registrations_annual <- amPie(
  annual_totals_new_registrations, legend=TRUE, legendPosition="bottom",
  main="Annual Total New Registrations 2019") %>%
  addListener(
    name = "clickSlice", expression = paste(
      "function (event) {", "var obj = event.dataItem;", "alert('The value is: ' + obj.value);", "}")) %>% 
  setExport(enabled = TRUE, menu = menu_obj) 
new_registrations_annual@legend$valueWidth=75
htmlwidgets::saveWidget(plot(new_registrations_annual), file = "annual_total_new_registrations.html")
drive_put("~/annual_total_new_registrations.html", path="annual_summary_2019/")


####

unique_devices_2019 <- read_csv("2019/unique_devices_by_sector_month.csv")
annual_totals_devices <- unique_devices_2019 %>% spread(sector, `User Devices`)
annual_totals_devices$month <- as.character(lubridate::month(annual_totals_devices$`_time`))
annual_totals_devices$other <- rowSums(
  subset(annual_totals_devices, 
         select=c("campsite", "hotel", "library_museum", "marina", "staff", "testing", "unknown", "venue")))

unique_devices_by_month <- amBarplot(
  x = "month", y = c("transport", "healthcare", "retail", "other"), data = annual_totals_devices, 
  groups_color=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c"), legend=TRUE,
  xlab="Month device last seen", ylab="Unique devices", main="Summary of unique devices by month last seen") %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(unique_devices_by_month), file = "unique_devices_by_month_last_seen.html")

drive_put("~/unique_devices_by_month_last_seen.html", path="annual_summary_2019/")

annual_totals_unique_devices <- unique_devices_2019 %>%
  mutate(label = stringr::str_replace(sector, "campsite|hotel|library_museum|marina|staff|testing|unknown|venue", "other")) %>%
  group_by(label) %>%
  summarise(value=sum(`User Devices`))
annual_totals_unique_devices$color <- c("#2db8c5", "#9d9d9c", "#fdc300", "#2daa56")
unique_sessions_totals <- amPie(
  annual_totals_unique_devices, legend=TRUE, legendPosition="left",
  main="Annual Unique Devices Seen 2019") %>%
  addListener(
    name = "clickSlice", expression = paste(
      "function (event) {", "var obj = event.dataItem;", "alert('The value is: ' + obj.value);", "}")) %>% 
  setExport(enabled = TRUE, menu = menu_obj)
unique_sessions_totals@legend$valueWidth=75
htmlwidgets::saveWidget(plot(unique_sessions_totals), file = "annual_total_unique_devices.html")
drive_put("~/annual_total_unique_devices.html", path="annual_summary_2019/")


####

data_usage_2019 <- read_csv("2019/data_usage_by_sector_month.csv")

annual_totals_up <- data_usage_2019 %>% select(-"downloaded_gb") %>% spread(sector, "uploaded_gb")
annual_totals_down <- data_usage_2019 %>% select(-"uploaded_gb") %>% spread(sector, "downloaded_gb")
annual_totals <- data_usage_2019 %>% mutate(total=uploaded_gb + downloaded_gb) %>% select(-c("uploaded_gb", "downloaded_gb")) %>% spread(sector, "total")

annual_totals$other <- calc_other(annual_totals)
annual_totals <- select(annual_totals, select=c(`_time`, "transport", "retail", "healthcare", "other"))
colnames(annual_totals) <- c("date", "transport", "retail", "healthcare", "other")

annual_totals_up$other <- calc_other(annual_totals_up)
annual_totals_up <- select(annual_totals_up, select=c(`_time`, "transport", "retail", "healthcare", "other"))
colnames(annual_totals_up) <- c("date", "transport", "retail", "healthcare", "other")

annual_totals_down$other <- calc_other(annual_totals_down)
annual_totals_down <- select(annual_totals_down, select=c(`_time`, "transport", "retail", "healthcare", "other"))
colnames(annual_totals_down) <- c("date", "transport", "retail", "healthcare", "other")

data_by_month_comparative <- amStockMultiSet(list("total"=annual_totals, "up"=annual_totals_up, "down"=annual_totals_down),
                color=c("#2db8c5", "#fdc300", "#2daa56")) %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(data_by_month_comparative), file = "data_by_month_comparative.html")
drive_put("~/data_by_month_comparative.html", path="annual_summary_2019/")

annual_totals$month <- as.character(lubridate::month(annual_totals$date))
total_data <- amBarplot(
  x = "month", y = c("transport", "healthcare", "retail", "other"), data = annual_totals, 
  groups_color=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c"), legend=TRUE,
  xlab="Month", ylab="Data (Gb)", main="Total Data Usage by Sector 2019") %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(total_data), file = "data_usage_by_month.html")

drive_put("~/data_usage_by_month.html", path="annual_summary_2019/")

annual_totals_up$month <- as.character(lubridate::month(annual_totals_up$date))
total_data_up <- amBarplot(
  x = "month", y = c("transport", "healthcare", "retail", "other"), data = annual_totals_up, 
  groups_color=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c"), legend=TRUE,
  xlab="Month", ylab="Data (Gb)", main="Total Data Uploaded by Sector 2019") %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(total_data), file = "data_uploaded_by_month.html")

drive_put("~/data_uploaded_by_month.html", path="annual_summary_2019/")


annual_totals_down$month <- as.character(lubridate::month(annual_totals_down$date))
total_data_down <- amBarplot(
  x = "month", y = c("transport", "healthcare", "retail", "other"), data = annual_totals_down, 
  groups_color=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c"), legend=TRUE,
  xlab="Month", ylab="New User Registrations", main="Total Data Downloaded by Sector 2019") %>% 
  setExport(enabled = TRUE, menu = menu_obj)
htmlwidgets::saveWidget(plot(total_data), file = "data_downloaded_by_month.html")

drive_put("~/data_downloaded_by_month.html", path="annual_summary_2019/")


annual_totals_data <- data_usage_2019 %>%
    mutate(label = stringr::str_replace(sector, "campsite|hotel|library_museum|marina|staff|testing|unknown|venue", "other")) %>%
  group_by(label) %>%
  summarise(uploaded=round(sum(uploaded_gb),1), downloaded=round(sum(downloaded_gb),1), total=round(sum(uploaded_gb+downloaded_gb),1))

annual_totals_data$color <- c("#2db8c5", "#9d9d9c", "#fdc300", "#2daa56")
old_colnames <- colnames(annual_totals_data)
colnames(annual_totals_data)[2] <- "value"
data_annual_up <- amPie(
  annual_totals_data, legend=TRUE, legendPosition="bottom",
  main="Annual Total Uploaded Data 2019 (Gb)") %>%
  addListener(
    name = "clickSlice", expression = paste(
      "function (event) {", "var obj = event.dataItem;", "alert('The value is: ' + obj.value);", "}")) %>% 
  setExport(enabled = TRUE, menu = menu_obj) 
data_annual_up@legend$valueWidth=75
htmlwidgets::saveWidget(plot(data_annual_up), file = "annual_totals_upload.html")
drive_put("~/annual_totals_upload.html", path="annual_summary_2019/")
colnames(annual_totals_data) <- old_colnames

annual_totals_data$color <- c("#2db8c5", "#9d9d9c", "#fdc300", "#2daa56")
colnames(annual_totals_data)[3] <- "value"
data_annual_down <- amPie(
  annual_totals_data, legend=TRUE, legendPosition="bottom",
  main="Annual Total Downloaded Data 2019 (Gb)") %>%
  addListener(
    name = "clickSlice", expression = paste(
      "function (event) {", "var obj = event.dataItem;", "alert('The value is: ' + obj.value);", "}")) %>% 
  setExport(enabled = TRUE, menu = menu_obj)
data_annual_down@legend$valueWidth=75
htmlwidgets::saveWidget(plot(data_annual_down), file = "annual_totals_download.html")
drive_put("~/annual_totals_download.html", path="annual_summary_2019/")

colnames(annual_totals_data) <- old_colnames
annual_totals_data$color <- c("#2db8c5", "#9d9d9c", "#fdc300", "#2daa56")
colnames(annual_totals_data)[4] <- "value"
data_annual_total <- 
  

data_annual_total <- amPie(
  annual_totals_data, legend=TRUE, legendPosition="bottom",
  main="Annual Total Data Usage 2019 (Gb)") %>%  addListener(
    name = "clickSlice", expression = paste(
      "function (event) {", "var obj = event.dataItem;", "alert('The value is: ' + obj.value);", "}")) %>% 
  setExport(enabled = TRUE, menu = menu_obj)
data_annual_total@legend$valueWidth=75
htmlwidgets::saveWidget(plot(data_annual_total), file = "annual_totals_data_usage.html")
drive_put("~/annual_totals_data_usage.html", path="annual_summary_2019/")

drive_put("~/2019/data_usage_by_sector_month.csv", path="annual_summary_2019/")
drive_put("~/2019/new_registrations_by_sector_month.csv", path="annual_summary_2019/")
drive_put("~/2019/unique_devices_by_sector_month.csv", path="annual_summary_2019/")


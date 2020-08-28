library(readr)
library(hereR)
library(ggmap)

starbucks <- read_csv("~/starbucks.csv")
address <- paste("Starbucks", system("sed 's/-//g' | sed -e 's/.*Starbucks\\(.*\\)\\|$/\\1/'", input = starbucks$LF_hotspot_zone_name, intern=TRUE), 
                 starbucks$city, starbucks$country, sep = ", ")
address <- data.frame(starbucks$LF_hotspot_id, address)
address <- subset(address, starbucks$city != "None")
address$id <- c(1:dim(address)[1])
hereR::set_key("2Gu9FZ2CR8kLTr7RjXgXzSYaMbhg4lWXVhkf_cAmcqo")
starbucks.gl <- hereR::geocode(as.character(address$address))
starbucks.gl <- merge(starbucks.gl, address, by="id")
save(starbucks.gl, file="geolocated.Rdata")
load("geolocated.Rdata")


starbucks.gl$dummy <- rpois(dim(starbucks.gl)[1], 5)

# starbucks_df <- as.data.frame(cbind(sf::st_coordinates(starbucks.gl$geometry), starbucks.gl$dummy))
# 
# sb_map_prep <- get_stamenmap(bbox = c(left = -7.5, bottom = 48, right = 6, top = 60),
#                              maptype="watercolor", zoom=5)
# sb_map <- ggmap(sb_map_prep, extent = 'device')
# # sb_map <- qmap("mp", zoom = 1, color = "bw", legend = "topleft")
# sb_map + geom_point(aes(x = X, y = Y, color=V3, fill=V3), 
#                     data = starbucks_df)
# sb_map + stat_density_2d(
#     #aes(x=X, y=Y, fill=V3), 
#     size = .1, bins = 4, na.rm=TRUE, alpha=1/2,
#     geom = "polygon", contour=TRUE
#   )
# 
# 
# sb_map + stat_bin2d(
#     bins = 30, alpha = 1/2, show.legend=TRUE
#   )


library(leaflet)
# m <- leaflet() %>% setView(lng = -2.9, lat = 50.7, zoom = 5)
# m %>% addTiles()
# m %>% addProviderTiles(providers$CartoDB.Positron)

pal <- colorNumeric("PuRd", domain = c(0, max(starbucks.gl$dummy)))

leaflet(starbucks.gl) %>% addTiles() %>% addProviderTiles(providers$CartoDB.Positron) %>% setView(lng = -2.9, lat = 50.7, zoom = 5) %>%
  addCircleMarkers(
    radius = ~ifelse(type == "ship", 6, 10),
    color = ~pal(geolocated$dummy),
    stroke = FALSE, fillOpacity = 0.5, popup=htmltools::htmlEscape(starbucks.gl$address)
  )


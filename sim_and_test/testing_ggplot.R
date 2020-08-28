
## df$date <- as.Date(paste(as.numeric(as.character(df$year)), df$month, "01", sep="/"), "%Y/%m/%d")
## last_year = rep(1, 60)
## last_year[df$date > (max(df$date) %m-%  years(1))] <- 0
## last_year


variable=rep(
    c("unique_sessions", "unique_devices",
      "corrected_downloaded_gb", "corrected_uploaded_gb"), 15)

customer_data <- data.frame(
    customer_id=rep(1, 60),
    year=c(rep(2018, 4), rep(2019, 48), rep(2020, 8)),
    month=c(rep(12, 4), sort(rep(1:12, 4)), rep(1, 4), rep(2, 4)),
    variable=variable,
    value = c(rnorm(12, 1000, 10), rnorm(48, 2000, 10))
    )

target = c("a", "b")
labels=c("Thing A", "Thing B")

tydf <- clean(df) %>% filter(date >= ddates$this_year_starts)
ddates <- key_dates(tydf$date)
subtitle=paste(
    "From ", ddates$this_year_starts, " to ", ddates$this_year_starts, sep="")
perfplot(tydf, paste(target, ".0", sep=""), paste(labels, ".0", sep=""), title, CORPCOLS[c(1,2)], subtitle, "Data (Gb)")

tydf <- clean(df) %>% filter(date >= ddates$previous_year_starts)
subtitle=paste(
    "Current year ", ddates$this_year_starts, " to ", ddates$this_year_ends,
    "\n", "Previous year ", ddates$previous_year_starts, " to ",
    ddates$previous_year_ends, sep="")
perfplot(clean(df), adj_target(target), adj_labels(labels), title, CORPCOLS[c(1, 2,  3, 4)], subtitle, "Data (Gb)")


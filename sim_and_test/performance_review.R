library(knitr)
library(markdown)
library(rmarkdown)
library(jsonlite)
library(tibble)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(lubridate)

CORPCOLS=c("#2db8c5", "#fdc300", "#2daa56", "#9d9d9c")

key_dates <- function(dates){
    this_year_ends <- max(dates) %m+% months(1) %m-% days(1)
    this_year_starts <- max(dates) %m-% months(11)
    previous_year_ends <- max(dates) %m-% months(11) %m-% days(1)
    previous_year_starts <- max(dates) %m-% months(23)
    earliest <- min(dates)
    return(
        list(this_year_ends=this_year_ends, this_year_starts=this_year_starts,
             previous_year_ends=previous_year_ends,
             previous_year_starts=previous_year_starts, earliest=earliest))
    }

clean <- function(df){
    df$year <- as.numeric(
      df$year)
    df$value <- as.numeric(
        df$value)
    df$date <- as.Date(
        paste(df$year, df$month, "01", sep="/"), "%Y/%m/%d")
    df$last_year <- last_year(
        df$date)
    df$variable <- interaction(
        df$variable, df$last_year)
    df$display_date <- as.Date(
      paste(df$year + df$last_year, df$month, "01", sep="/"), "%Y/%m/%d")
  return(df)
}

json_to_df <- function(data_json){
  df <- enframe(unlist(data_json))
  rgx_split <- "\\."
  df <- df %>% 
  separate(name, into = c("customer_id", "year", "month", "variable"), sep = rgx_split, fill = "right")
  return(clean(df))
}  


last_year <- function(date){
   last_year = rep(1, length(date))
   last_year[date > (max(date) %m-%  years(1))] <- 0
   return(last_year)
}
 
adj_target <- function(varnames){
    names <- rep(varnames, 2)
    marker <- sort(rep(c(0, 1), length(varnames)))
    return(as.character(interaction(names, marker)))
    }

adj_labels <- function(labels){
    labels <- c(labels, paste(labels, "previous year", sep=": "))
    return(labels)
    }


perfplot <- function(df, target, labels, title, corpcols, subtitle, ylab, my_units){
  df %>% filter(variable %in% target) %>%
      ggplot(
          aes(x = display_date, y = value, group=variable, fill=variable)
      ) +
      geom_bar(
          stat = "identity", position = position_dodge(preserve="single")
      ) +
      scale_fill_manual(
          values=corpcols, name="", breaks=target, labels=labels) +
      labs(
          title = title, x = "Month", subtitle=subtitle
      ) +
      scale_y_continuous(
          name=ylab, labels = scales::comma
      ) +
      geom_label_repel(
          aes(label = paste(scales::comma(value, accuracy=1), my_units, sep=""),
              y = value, group=variable),
          position = position_dodge(preserve="single", width=10)
      ) +
      scale_x_date(date_labels = ("%Y/%m")) +
      theme_bw()
}

totplot <- function(totals, target, labels, title, subtitle, ylab, my_units, corpcols){
    totals %>% filter(var %in% target) %>%
      ggplot(
          aes(x = previous_year, y = value, group=var, fill=var)
      ) +
      geom_bar(
          stat = "identity", position = position_dodge(preserve="single", width=0.9)
      )  +
      scale_fill_manual(
          values=corpcols, name="", breaks=target, labels=labels) +
      labs(
          title = title, x = "", subtitle=subtitle
      ) + 
      scale_y_continuous(
          name="daf", labels = scales::comma
      ) +
      geom_label_repel(
          aes(label = paste(scales::comma(value, accuracy=1), my_units, sep=""),
              y = value, group=var),
          position = position_dodge(0.9)#preserve="single", width=0.9)
      ) +
        theme_bw()
}


monthly_performance <- fromJSON("~/performance.json", flatten=TRUE)
monthly_performance <- json_to_df(monthly_performance)
customers <- unique(monthly_performance$customer_id)

customers <- customers[customers != 94]
for (c_id in customers){
  rmarkdown::render('/home/vagrant/phewson_configs/sim_and_test/cust_review.Rmd',
                    output_file =  paste("report_", c_id, '_', Sys.Date(), ".html", sep=''), 
                    output_dir = '/home/vagrant/test/reports')
}

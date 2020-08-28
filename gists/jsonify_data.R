library(jsonlite)

now <- function(){return(format(Sys.time(), "%Y-%m-%d %H:%M:%S"))}
now_realised <- now()
sessions <- read.csv("~/sessions.csv", stringsAsFactors=FALSE)
registrations <- read.csv("~/new_registrations.csv", stringsAsFactors=FALSE)
sessions$starttime <- as.POSIXct(sessions$starttime, "%Y-%m-%d %H:%M:%S")
sessions$endtimemod <- ifelse(sessions$endtime == "", 1, 0)
sessions$endtime[sessions$endtime == ""] <- now_realised
sessions$endtime <- as.POSIXct(sessions$endtime, "%Y-%m-%d %H:%M:%S")
registrations$regtime <- as.POSIXct(registrations$regtime, "%Y-%m-%d %H:%M:%S")

customer_ids = sort(unique(sessions$customer_id))
con <- file("data/customer_ids.json")
writeLines(toJSON(customer_ids), con)
close(con)

for (i in c(1:length(customer_ids))){
  customer_json <- toJSON(subset(sessions, customer_id==customer_ids[i]))
  con <- file(paste("data/sessions_", customer_ids[i], ".json", sep = ""))
  writeLines(customer_json, con)
  close(con)
}

for (i in c(1:length(customer_ids))){
  customer_json <- toJSON(subset(registrations, customer_id==customer_ids[i]))
  con <- file(paste("data/registrations_", customer_ids[i], ".json", sep = ""))
  writeLines(customer_json, con)
  close(con)
}


time <- sort(as.numeric(customer_data$starttime - min(customer_data$starttime)) / as.numeric(max(customer_data$starttime)))

get_parobj <- function(times){
tvec <- cumsum(times)
tmax <- max(tvec)
#  set up an order 4 B-spline basis over [0,tmax] with
#  21 equally spaced knots
tbasis <- create.bspline.basis(c(0,tmax), 23)
#  set up a functional parameter object for W(t),
#  the log intensity function.  The first derivative
#  is penalized in order to smooth toward a constant
lambda <- 10
Wfd0 <- fd(matrix(0,23,1),tbasis)
WfdParobj <- fdPar(Wfd0, 1, lambda)
return(WfdParobj)
}

tvec <- cumsum(time)
tmax <- max(tvec)
mu=0.003
fitthing <- intensity.fd(time, WfdParobj=get_parobj(time))
Wfdobj <- fitthing$Wfdobj

events <- c(0,time)
intenvec <- exp(eval.fd(events,Wfdobj))
#  plot intensity function
plot(events, intenvec, type="b")
lines(c(0,tmax),c(mu,mu),lty=4)

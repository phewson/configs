library(whisker)

OCTETS <- 1073741824

#' Load an event template
#'
#' @param filename A filename containing a mustache template
#' @return A mustache template
load_event_template <- function(filename="sim_and_test/session_event.mustache"){
    file_conn<-file(filename)
    session_mustache <- readLines(file_conn)
    close(file_conn)
    return(session_mustache)
}

#' Save simulation results
#'
#' @param simulations An R object containing simulations (filled in from mustache template)
#' @param outfile A filename to store the simulations
#' @return None
write_simulations <- function(simulations, outfile="simulations.json"){
  file_conn<-file(outfile)
  writeLines(simulations, file_conn)
  close(file_conn)
}


#' Populate a list for use by whisker
#'
#' @param type Event type (Stop or Start)
#' @param username,
#' @param realm,
#' @param session_id,
#' @param unique_session_id,
#' @param ip_address,
#' @param src_ip_address,
#' @param port_id,
#' @param port_type,
#' @param timestamp Input in text format YYYY-mm-dd HH:MM:SS
#' @param session_time,
#' @param input_gigawords,
#' @param input_octets,
#' @param output_gigawords,
#' @param output_octets,
#' @param device_mac_address,
#' @param nas_mac_address,
#' @param termination_cause,
#' @param framed_protocol,
#' @param framed_ip_address,
#' @param hotspot_id,
#' @param interface_id,
#' @param customer_id,
#' @param 
#' @return A list which can be input to whisker to populate a template
create_event <- function(type="Start",
  session_id="12888a5e-b910-41cb-a9bb-868b76ca35d1", unique_session_id="00e5a32be2ec90fc89a92bad88a8d67",
  device_mac_address="903C92E9487C", input_date="2019-02-14 09:30:00",
  username="NHIS001/a", realm="NHIS001", ip_address="213.106.91.138", src_ip_address="213.106.91.138",
  port_id="eth1.47", port_type="", session_time=9600,
  input_gigawords=0, input_octets=0, output_gigawords=0, output_octets=0,
  nas_mac_address="", termination_cause="",
  framed_protocol="", framed_ip_address="10.167.3.22", hotspot_id=2, interface_id=11, customer_id=21, ssid=""){
  
  return(list("timestamp_text"=input_date,
       "type"=type,
       "username"=username,
       "realm"=realm,
       "session_id"=session_id,
       "unique_session_id"=unique_session_id,
       "ip_address"=ip_address,
       "src_ip_address"=src_ip_address,
       "port_id"=port_id,
       "port_type"=port_type,
       "timestamp_numeric"=as.numeric(as.POSIXct(input_date, format="%Y-%m-%d %H:%M:%S")),
       "session_time"=session_time,
       "input_gigawords"=input_gigawords,
       "input_octets"=input_octets,
       "output_gigawords"=output_gigawords,
       "output_octets"=output_octets,
       "device_mac_address"=device_mac_address,
       "nas_mac_address"=nas_mac_address,
       "termination_cause"=termination_cause,
       "framed_protocol"=framed_protocol,
       "framed_ip_address"=framed_ip_address,
       "hotspot_id"=hotspot_id,
       "interface_id"=interface_id,
       "customer_id"=customer_id,
       "ssid"=ssid))
}


stop_cause <- c("Idle-Timeout", "Session-Timeout", "Suspect-Logout", "User-Request")


session_mustache <- load_event_template()



get_df <- function(starts, stops, start_date, uid){
type_v <- c(rep("Start", starts), rep("Stop", stops))
input_dates <- seq(ISOdate(2019, 11, start_date), by = "s", length.out = starts+stops)
octets_out <- c(rep(0, starts), seq(from=1, by=2, length=stops)*OCTETS)
octets_in <- c(rep(0, starts), seq(from=5, by=5, length=stops)*OCTETS)
session_time <- c(rep(0, starts), seq(from=4800, by=4800, length=stops))
unique_session_id <- rep(uid, starts+stops)
device_mac_address <- rep(uid, starts+stops)
return(data.frame(type_v=type_v, input_dates=as.character(input_dates), octets_out=octets_out, octets_in=octets_in, 
                  session_time=session_time,
                  unique_session_id=unique_session_id, device_mac_address=device_mac_address))
}

sims <- rbind(get_df(1, 9, 11, "one_start"), get_df(1, 0, 12, "orphan"), get_df(9, 1, 13, "one_stop"),
              get_df(4, 4, 14, "multiples"))


n <- dim(sims)[1]
output <- vector("character", n)
for (i in 1:n){
    output[i] <- whisker.render(
        session_mustache, create_event(
          type=sims$type_v[i], input_date=sims$input_dates[i], input_octets=sims$octets_in[i],
          output_octets=sims$octets_out[i], session_time=sims$session_time[i], 
          unique_session_id=sims$unique_session_id[i], device_mac_address=sims$device_mac_address[i]))
}

write_simulations(output)

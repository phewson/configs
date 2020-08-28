library(hash)
library(ggQC)
library(ggplot2)
library(readr)



# 11009 line changes
# 15178 line changes

over_100_reps <- read.csv("high_freq_macs.csv")
mac.vendor <- read_fwf("~/mac-vendor.txt", fwf_positions(c(1, 8), c(6, NA), c("key", "values")))
mac_lookup <- hash(mac.vendor$key, mac.vendor$values)

oui <- read.delim("manuf.txt", sep="\t", skip=66, header = FALSE, stringsAsFactors=FALSE)
oui <- rbind(c("00:00:00", "Xerox", "Xerox Corporation"), oui)
colnames(oui) <- c("nas_code","manufacturer", "man_details")
f <- function(x){
  manufacturer_code <- substr(x, 1, 6)
  if(has.key(manufacturer_code, mac_lookup)) {
    return(mac_lookup[[manufacturer_code]]) 
  } else {return("None")
      }
}
  
Manufacturer <- vapply(over_100_reps$device_mac_address, f, FUN.VALUE="text")
macs_over_100 <- as.data.frame(xtabs(~Manufacturer))


ggplot(macs_over_100, aes(x=Manufacturer, y=Freq)) +
  stat_pareto(point.color = "#2daa56", point.size = 3, line.color = "#3c3c3b", bars.fill = c("#2db8c5", "#fdc300")) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, size=6, hjust=1)) +
  labs(title = "Devices with over 100 Start sessions within a minute in Starbucks in November")


library(readr)
case_study <- read_csv("case_study.csv")
case_study$termination_cause[is.na(case_study$termination_cause)] <- "."
par(mfrow=c(2,1))
with(case_study, plot(humantime, count, pch=16, col=as.factor(termination_cause), bty="n", xlab="Time (1st Nov 2019)", 
                      ylab="Number events", main="Session 6e59d1b7816919e411310109897be9a6"))
with(case_study, arrows(humantime, rep(0, length(humantime)), humantime, count, length=0.000001))
legend("topright", ncol=3, pch=16, col=c("black", "green", "red"), 
       legend=c("Start", "Stop: Suspect", "Stop: Cron Timeout"), bty="n")

# with(case_study, text(humantime, count, count, pos=4, adj=c(0, 1)))
#legend("topright", pch=16, col=c("black", "green", "red"), legend=c("Start", "Stop: Suspect", "Stop: Cron Timeout"), bty="n")
with(case_study, plot(humantime, tot_time / 3600, ylab="Session time (hours)", xlab="Time (1st Nov 2019)",
                      main="Reported session time", pch=16, col=as.factor(termination_cause), bty="n"))
with(case_study, arrows(humantime, rep(0, length(humantime)), humantime, tot_time/3600, length=0.000001))
# legend("topleft", ncol=3, pch=16, col=c("black", "green", "red"), legend=c("Start", "Stop: Suspect", "Stop: Cron Timeout"), bty="n", cex=0.7)

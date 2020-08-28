# index="cloud_spark_*" AND type="Portal" | rename user_agent.* as user_agent_* | stats dc(user_agent_browser_name) as n, values(user_agent_Browser) as Browser, values(user_agent_Browser) as Comment, values(user_agent_Device_Type) as Device_Type, values(user_agent_Parent) as Parent, values(user_agent_Version) as Version, 
# values(user_agent_Platform) as Platform by user_agent_browser_name
# not needed?export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/include/boost/"
# not needed? sudo ldconfig
# sudo apt-get install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
# wget https://github.com/ua-parser/uap-core/blob/master/regexes.yaml
library(readr)
library(tidyr)
library(googledrive)
drive_auth(use_oob = TRUE)

ua <- read_csv("phewson_configs/ua.csv")
library(uaparserjs)
out <- ua_parse(urltools::url_decode(ua$user_agent_browser_name))
detach(package: uaparserjs)
library(uaparser)
out_new <- parse_agents(urltools::url_decode(ua$user_agent_browser_name))

barry <- as.data.frame(xtabs(ua$n ~ paste(ua$user_agent_browser_name, "xXx", 
  ua$Browser, "xXx", out$ua.family, "xXx", out_new$browser,
  "xXx", ua$Version, "xXx", out$ua.major, out$ua.minor, "xXx", out_new$browser_major, out_new$browser_minor,
  "xXx", ua$Platform, "xXx", out$os.family, out$device.family,  out$os.major, out$os.minor, 
  "xXx", out_new$os, out_new$os_major, out_new$os_minor, 
  "xXx", ua$Device_Type, "xXx", out$device.family, out$device.brand, out$device.model,
  "xXx", out_new$device), na.action=NULL))
colnames(barry)[1] <- "uas"
barry <- separate(barry, "uas", into=c("UserAgent", "SparkBrowser", "PostprocessBrowser", "ScriptBrowser", 
                                       "SparkVersion", "PostprocessVersion", "ScriptVersion",
                                       "SparkPlatform", "PostdecodePlatform", "ScriptPlatform",
                                       "SparkDeviceType", "PostDecodeDeviceType", "ScriptDeviceType"), sep = "xXx", remove = TRUE,
         convert = FALSE, extra = "warn", fill = "warn")
write.csv(barry[order(-barry$Freq),], file="~/user_agents_prod_2019_02_14.csv", row.names=FALSE)

drive_put("~/user_agents_prod_2019_02_14.csv", path="user_agents/")


barry[grep("unknown", barry$SparkPlatform) && grep("Other", barry$ScriptBrowser),]


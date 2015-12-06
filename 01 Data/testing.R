require(jsonlite)
require(RCurl)
require(dplyr)
df09 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from DataGov_GDX_FY9"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

df08 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from DataGov_GDX_FY08"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

df09 <- df09 %>% mutate(Year = 2009)
df08 <- df08 %>% mutate(Year = 2008)
df08 <- rename(df08,COMPENSATION_PENSION = COMPENSATION_PENSIONS)
df09$FIPS <- NULL

df09$VETERAN_POPULATION <- as.numeric(as.character(df09$VETERAN_POPULATION))
df09$UNIQUE_PATIENTS <- as.numeric(as.character(df09$UNIQUE_PATIENTS))

dfnew <- bind_rows(df09, df08)

require(jsonlite)
require(RCurl)
require(dplyr)
require(ggplot2)
dfnewv2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from dfnewv2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

dfnewv2$VETERAN_POPULATION=as.numeric(levels(dfnewv2$VETERAN_POPULATION))[dfnewv2$VETERAN_POPULATION]

dfnewv2 <- filter(dfnewv2, YEAR == 2008)

ggplot() + 
  coord_cartesian() + 
  scale_x_continuous() +
  scale_y_continuous() +
  layer(data=dfnewv2, 
        mapping=aes(x=VETERAN_POPULATION, y=TOTAL_EXPENDITURE, color=STATE, label=STATE), 
        stat="identity", 
        stat_params=list(), 
        geom="point",
        geom_params=list(), 
        position=position_identity()
  ) +
  stat_smooth(data=dfnewv2,
              mapping = aes(x=VETERAN_POPULATION, y=TOTAL_EXPENDITURE),
              method = "lm",
              fullrange = TRUE,
              se = FALSE
  ) +
  geom_text(data=dfnewv2,
            mapping = aes(x=VETERAN_POPULATION, y=TOTAL_EXPENDITURE,label=ifelse(TOTAL_EXPENDITURE>1500000,as.character(STATE),'')),
            hjust=0,
            just=0
  ) +
  theme(legend.position='none')

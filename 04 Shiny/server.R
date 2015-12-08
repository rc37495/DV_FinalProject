require("jsonlite")
require("RCurl")
require("ggplot2")
require("dplyr")
require("shiny")
require("shinydashboard")
require("leaflet")
require("DT")
require("RCurl")
require("plyr")
require("gridExtra")
require("reshape2")

shinyServer(function(input, output) {
  output$distbar <- renderPlot({
    dfnewv2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from dfnewv2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
    
    plotbar <- dfnewv2 %>% ggplot(aes(x = STATE, y = TOTAL_EXPENDITURE, fill = STATE)) + facet_wrap(~YEAR) + geom_bar(stat = "identity") + ggtitle("State Spending on Veterans from 2008 to 2009") + ylab("Total Expenditure")
    
    plotbar
  })
  output$distcat1 <- renderPlot({
    dfnewv2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from dfnewv2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
    
    dfnewv2$VETERAN_POPULATION=as.numeric(levels(dfnewv2$VETERAN_POPULATION))[dfnewv2$VETERAN_POPULATION]
    
    dfnewv2 <- filter(dfnewv2, YEAR == 2008)
    
    cat1 <- ggplot() + 
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
    
    cat1
  })
  output$distcat2 <- renderPlot({
    dfnewv2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from dfnewv2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
    
    dfnewv2$VETERAN_POPULATION=as.numeric(levels(dfnewv2$VETERAN_POPULATION))[dfnewv2$VETERAN_POPULATION]
    
    dfnewv2 <- filter(dfnewv2, YEAR == 2009)
    
    cat2 <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      layer(data=dfnewv2, 
            mapping=aes(x=VETERAN_POPULATION, y=TOTAL_EXPENDITURE, color=STATE), 
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
                mapping = aes(x=VETERAN_POPULATION, y=TOTAL_EXPENDITURE,label=ifelse(TOTAL_EXPENDITURE>1500000000,as.character(STATE),'')),
                hjust=0,
                just=0
      ) +
      theme(legend.position='none')
    
  cat2
  })
  output$distcross <- renderPlot({
    # Start your code here.
    
    # The following is equivalent to KPI Story 2 Sheet 2 and Parameters Story 3 in "Crosstabs, KPIs, Barchart.twb"
    
    df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from DFNEWV2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
    region <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from REGION"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
    
    # merge two datasets
    ds <- merge(df, region, by = "STATE")
    
    # make new dataset
    expenditure <- aggregate(TOTAL_EXPENDITURE ~ REGION,data=ds,sum)
    pension <- aggregate(COMPENSATION_PENSION ~ REGION,data=ds,sum)
    medical <- aggregate(MEDICAL_CARE ~ REGION,data=ds,sum)
    opex <- aggregate(GENERAL_OPERATING_EXPENSES ~ REGION,data=ds,sum)
    rehab <- aggregate(EDU_VOC_REHAB_EMP ~ REGION,data=ds,sum)
    nds <- join_all(list(expenditure, pension, medical, opex, rehab), by = "REGION", type = "full")
    
    # melt nds
    nds <- melt(nds, id.vars="REGION")
    
    # rename variable -> EXPENSE_TYPE and value -> EXPENSE, round to whole number
    nds <- rename(nds, c("variable"="EXPENSE_TYPE", "value"="EXPENSE"))
    nds[,'EXPENSE']=round(nds[,'EXPENSE'],0)
    
    # filter out territory region
    nds <- nds[nds$REGION != 'TERRITORY',]
    
    # rescale in preparation for heatmap
    nds <- ddply(nds, .(EXPENSE_TYPE), transform, rescale = scale(EXPENSE))
    
    # make crosstab
    plot <- ggplot(nds, aes(EXPENSE_TYPE, REGION)) + 
      labs(title='Expenditures by Region') +
      geom_tile(aes(fill = rescale), colour = "gray90") + 
      scale_fill_gradient(low = "green", high = "red") +
      geom_text(aes(label=EXPENSE)) +
      guides(fill=FALSE)
    
    
    # End your code here.
    return(plot)
  })
})
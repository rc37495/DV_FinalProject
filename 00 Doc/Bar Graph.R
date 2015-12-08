dfnewv2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from dfnewv2"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_rc37495', PASS='orcl_rc37495', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
 
dfnewv2 %>% ggplot(aes(x = STATE, y = TOTAL_EXPENDITURE, fill = STATE)) + facet_wrap(~YEAR) + geom_bar(stat = "identity") + ggtitle("State Spending on Veterans from 2008 to 2009") + ylab("Total Expenditure")

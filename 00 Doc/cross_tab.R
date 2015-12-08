require("jsonlite")
require("RCurl")
require("dplyr")
require("plyr")
require("reshape2")
require("ggplot2")

# get data from oracle
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

# rename variable -> EXPENSE_TYPE and value -> EXPENSE
nds <- rename(nds, c("variable"="EXPENSE_TYPE", "value"="EXPENSE"))

# filter out territory region
nds <- nds[nds$REGION != 'TERRITORY',]

# rescale in preparation for heatmap
nds <- ddply(nds, .(EXPENSE_TYPE), transform, rescale = scale(EXPENSE))

# make crosstab
crosstab <- ggplot(nds, aes(EXPENSE_TYPE, REGION)) + 
  labs(title='Expenditures by Region') +
  geom_tile(aes(fill = rescale), colour = "gray90") + 
  scale_fill_gradient(low = "green", high = "red") +
  geom_text(aes(label=EXPENSE)) +
  guides(fill=FALSE)

crosstab


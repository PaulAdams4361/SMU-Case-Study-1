library(dplyr) # we'll need this one to work with the dataframe(s)
library(sqldf)
library(ggplot2)
library(na.tools)

setwd("C:/Users/Pablo/Desktop/DS 6306 - Doing Data Science/Unit 7")
# read in the .CSV
breweryData <- read.csv("Breweries.csv")
beerData <- read.csv("Beers.csv")

# Make sure the data is valid; check the head (to find joins) and the tail
head(breweryData)
head(beerData)

# Count the number of breweries in each state (this is how many we must have on final output)
# No NAs
StateBrewCnt <- sqldf("select State, count(*) as Brewery_Count
                      from breweryData
                      group by State
                      order by Brewery_Count desc")


#breweryData %>%
#   count(State)  
#%>% as.data.frame(respite)

# What is the count, by state?
StateBrewCnt

# Alternatively, ordering by State in case this is of interest (no NAs):
BrewStateCnt <- sqldf("select State, count(*) as Brewery_Count
                      from breweryData
                      group by State
                      order by State asc")
BrewStateCnt


# BreweryData has a unique key Brew_ID. The beers served at each brewery also have a unique
# key called Brewery_ID that corresponds to the brewery that serves that beer.
# Join all together based on these keys. No data left behind.
beersAndPubs <- merge(breweryData,beerData, by.x = "Brew_ID", by.y = "Brewery_id")
head(beersAndPubs)
nrow(beersAndPubs)

# Change post-merge column names to something clean:
colnames(beersAndPubs)[1] = "Brewery_ID"
colnames(beersAndPubs)[2] = "Brewery_Name"
colnames(beersAndPubs)[5] = "Beer_Name"

# The first 6 observations of the merged data, unsorted
head(beersAndPubs,6)

# The last 6 observations of the merged data, unsorted
tail(beersAndPubs,6)

################################## Identifying and Refitting NA values with Medians ##################################

# Count the number of NAs in each column using sapply()
NAcnt <- sapply(beersAndPubs, function(cnt) sum(is.na(cnt)))
NAcnt

# This replaces the NA ABVs and IBUs in each state by the median of each State (not the national median)
beersAndPubs3 <- beersAndPubs %>% group_by(State) %>% mutate(ABV = na.median(ABV))
beersAndPubs3 <- beersAndPubs3 %>% group_by(State) %>% mutate(IBU = na.median(IBU))
# Any states that had no IBUs to compute a median for their NAs will now recieve a median from nationwide values)
beersAndPubs3 <- beersAndPubs3 %>% mutate(IBU = na.median(IBU)) %>% data.frame()


################################## Creating Summary Dataframes with Medians for IBU, ABV ##################################

###beersAndPubs is used here (for ABVs and IBUs) with NA values omitted to prevent dilluting 
###states by using national medians. Scatterplots will use medians
medianABVbyState <- beersAndPubs3 %>% group_by(State) %>% summarise(ABV = median(ABV)) %>% data.frame()
medianABVbyState <- data.frame(medianABVbyState[order(-medianABVbyState$ABV),])

medianIBUbyState <- beersAndPubs3 %>% group_by(State) %>% summarise(IBU = median(IBU)) %>% data.frame()
medianIBUbyState <- data.frame(medianIBUbyState[order(-medianIBUbyState$IBU),])
# Ordering the medians by state (you know this isn't including all beer because
# Oklahoma has pretty weak beer, by bottle)
medianABVbyState
medianIBUbyState


################################## Graphics and Visuals Section ##################################

#bar chart IBU by state
ggplot(data=medianIBUbyState, aes(x=reorder(State,-IBU),y=IBU,fill=State)) + geom_bar(stat="identity", show.legend = F) + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Median Bitterness, by U.S. State") + xlab("State")
ggplot(data=medianIBUbyState, aes(x=State,y=IBU,fill=State)) + geom_bar(stat="identity", show.legend = F) + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Median Bitterness, by U.S. State")

#bar chart ABV by state
ggplot(data=medianABVbyState, aes(x=reorder(State,-ABV),y=ABV,fill=State)) + geom_bar(stat="identity", show.legend = F) + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Median Alcohol by Volume, by U.S. State") + xlab("State")
ggplot(data=medianABVbyState, aes(x=State,y=ABV,fill=State)) + geom_bar(stat="identity", show.legend = F) + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Median Alcohol by Volume, by U.S. State")

# Probability density distribution for IBU
ggplot(na.omit(beersAndPubs3), aes(x=IBU)) + geom_density(color="darkblue", fill="skyblue2") + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Total Bitterness Distribution Across all States")

# Probability density distribution for ABV
ggplot(na.omit(beersAndPubs3), aes(x=ABV)) + geom_density(color="darkblue", fill="skyblue2") + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Total Alcohol by Volume Distribution Across all States")

# Boxplots
ggplot(data=na.omit(beersAndPubs3), aes(y=ABV)) + geom_boxplot(stat="boxplot", fill="skyblue2", color="darkblue") + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Total ABV Across all U.S. States") + xlab("All States")
ggplot(data=na.omit(beersAndPubs3), aes(y=IBU)) + geom_boxplot(stat="boxplot", fill="skyblue2", color="darkblue") + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Total Bitterness Across all U.S. States") + xlab("All States")

# Merging to scatterplot the ABV and IBU data, removing NAs
medianIBU_ABV <- merge(medianIBUbyState,medianABVbyState, by.x = "State", by.y = "State")
medianIBU_ABV

# Scatterplotting the data in general (non-median data)
ggplot(data=beersAndPubs3, aes(y=ABV,x=IBU,fill=IBU)) + geom_point(size=3, shape=21) + theme(panel.background = element_rect(fill = 'ivory1'),plot.title = element_text(hjust = 0.5)) + ggtitle("Total Alcohol by Volume vs. Bitterness Correlation")

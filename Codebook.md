# Codebook

## Purpose
This file will detail the variables, objects, or packages used within our analysis.

## Packages Used
1.  tidyverse
2.  ggplot2
3.  reshape2
4.  dplyr
5.  na.tools
6.  sqldf

## Variables Used
1.  **beerData** <- Dataframe of Beers.csv file
2.  **breweryData** <- Dataframe of Breweries.csv file
3.  **StateBrewCnt** <- Count of breweries per state
4.  **beersAndPubs** <- Merge of beerData and breweryData based on Brewery ID
5.  **na_count** <- Count of NAs within beersAndPubs dataframe
6.  **percentNA** <- Percent of NAs in each column relative to count of total rows
7.  **percentCountNA** <- na_count concatenated with percentNA in parantheses for bar chart
8.  **na_df** <- Converts the na_count vector to dataframe
9.  **medianABVbyState** <- Ordered dataframe for median ABV by state
10.  **medianIBUbyState** <- Ordered dataframe for median IBU by state
11.  **abv_style_df** <- Separates IBU and Style columns from beersAndPubs into separate dataframe
12.  **mn_abv** <- Calculated mean IBU per style

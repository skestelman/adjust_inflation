# adjust_US_inflation
Program to adjust for inflation in US data, v1.0
Last updated: Sept 13, 2019

# About
This program downloads BLS CPI data from 1920 to 2018, calculates monthly or annual inflation rates, and adjusts variables for inflation. 

# Syntax
<i>syntax varlist [if] [in], year(real) [month_3letter_or_annual(string) includestates(string)]</i>

<i>varlist</i>: list of variables you want to correct for inflation. Be careful to only include variables measured in USD.

<i>year</i>: enter the year you want your data in (e.g., to convert all dollar amounts to 2018 dollars, type year(2018)

<i>month_3letter_or_annual</i>": takes in the month the data were measured in, in case different observations were collected in different months. Some states report revenue measured at different points of the fiscal year, for exmaple. The default is the "annual" CPI. *



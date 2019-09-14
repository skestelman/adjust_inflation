********************************************************************************
* COPYRIGHT: STEPHANIE KESTELMAN
* DATE CREATED: AUG 7, 2017
* DATE EDITTED: MAR 6, 2018
* LAST EDIT: INCLUDE 2018 DATA

********************************************************************************


capture program drop adjust_inflation
program define adjust_inflation

syntax varlist , year(real) [month_3letter_or_annual(string) includestates(string)]

	qui{
	preserve /*Preserves data being adjusted*/
		
	* ADJUST FILE PATH AS NEEDED
	copy https://github.com/skestelman/adjust_US_inflation/tree/master/Inflation_dta/raw/CPI_1920_2018.xlsx ~/CPI_1920_2018.xlsx, replace

	*import excel using  "https://github.com/skestelman/adjust_US_inflation/tree/master/Inflation_dta/raw/CPI_1920_2018.xlsx", cellrange(A12:P120) firstrow clear
	
	import excel using ~/CPI_1920_2018.xlsx, cellrange(A12:P120) firstrow clear
	
	drop if missing(Annual)
	
	if "`month_3letter_or_annual'"==""{
		local month_3letter_or_annual = "annual"
	}
	
	local month = proper("`month_3letter_or_annual'")
	
	rename (Year `month') (year `month_3letter_or_annual')
	
	keep year `month_3letter_or_annual'
	
	*Get CPI for year we want to convert all other dollars into. E.g. if want to 
	*convert to 2014 dollars, select 2014. Calculate inflation rate + 1
	ds year, not
	foreach var in `r(varlist)'{
		g `var'base = `var' if year==`year'
		egen `var'_`year' = max(`var'base)
		g  `var'_inflation =`var'_`year'/`var'
	}
	drop *base *_`year'
	
	tempfile inflation
	save `inflation'
	restore /*Restores data being adjusted*/
	
	merge m:1 year using `inflation', keep(3) nogen

	*ADJUST FOR INFLATION IF IN THE LIST OF STATES TO INCLUDE. Some states conduct 
	*their data gathering in different months, so the inflation rate is slightly different. 
	*If all the same, can comment out the portion "if regexm("`includestates'", stateabbr)"
	if "`includestates'"!=""{
		foreach var in `varlist'{
			replace `var' = `month_3letter_or_annual'_inflation* `var' if regexm("`includestates'", stateabbr)
		}
	}
	
	else if "`includestates'"==""{
		foreach var in `varlist'{
			capture replace `var' = `month_3letter_or_annual'_inflation* `var'
			if _rc==0{
			di as error "Adjusted `var' to `year' dollars"
			}
		}
	}
	drop `month_3letter_or_annual' `month_3letter_or_annual'_inflation
	
	
	erase $rawdir_dump/TabFig2015prel.xls

		
	}
end


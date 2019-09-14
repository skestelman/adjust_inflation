********************************************************************************
* COPYRIGHT: STEPHANIE KESTELMAN
* DATE CREATED: AUG 7, 2017
* DATE EDITTED: MAR 6, 2018
* LAST EDIT: INCLUDE 2018 DATA

********************************************************************************


capture program drop adjust_inflation
program define adjust_inflation

syntax varlist [if] [in], year(real) [month_3letter_or_annual(string) ]

	qui{
	preserve /*Preserves data being adjusted*/
	
	* Import
	import delimited using  "https://skestelman.github.io/code/Inflation_dta/raw/CPI_1920_2018.csv", clear
		
	drop if missing(annual)
	
	* Apply default
	if "`month_3letter_or_annual'"==""{
		local month_3letter_or_annual = "annual"
	}
			
	keep year `month_3letter_or_annual'
	
	*Get CPI for year we want to convert all other dollars into. E.g. if want to 
	*convert to 2014 dollars, enter 2014. Calculate inflation rate + 1
	ds year, not
	foreach var in `r(varlist)'{
		g `var'base = `var' if year==`year'
		egen `var'_`year' = max(`var'base)
		g  `var'_inflation =`var'_`year'/`var'
	}
	drop *base *_`year'
	
	compress 
	
	tempfile inflation
	save `inflation'
	restore /*Restores data being adjusted*/
	
	* merge to regular data
	merge m:1 year using `inflation', keep(3) nogen
	
	* adjust for inflation each of the variables in the varlist
	foreach var in `varlist'{
		capture replace `var' = `month_3letter_or_annual'_inflation* `var' `if'
		if _rc==0{
		di as error "Adjusted `var' to `year' dollars `if'"
		}
	}
	drop `month_3letter_or_annual' `month_3letter_or_annual'_inflation
		
	}
end


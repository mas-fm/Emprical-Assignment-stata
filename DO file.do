/*PART0*Define Paths*/
log using "D:\User\Desktop\OUT\data_management_session.smcl", replace
cd "D:\User\Desktop\OUT"

/*PART1*Importing Bank-Level Data*/
local files "US_DATA_1_Assets_1 US_DATA_2_Assets_2 US_DATA_3_Liab_Equity US_DATA_4_Loans US_DATA_5_Deposits US_DATA_5_OBS US_DATA_7_Income_Statement_1 US_DATA_7_Income_Statement_2 US_DATA_8_NII US_DATA_10_Loan_Quality US_DATA_11_Growth US_DATA_12_Profitability_Spread state_abbrev"
foreach x of local files {
 import excel "D:\User\Desktop\DATA/`x'.xlsx", sheet("Sheet1") firstrow clear
  save "D:\User\Desktop\DATA/`x'.dta"
  }
   
 /*PART2*Merging Data*/
  use "D:\User\Desktop\DATA\US_DATA_1_Assets_1.dta"
  local files "US_DATA_2_Assets_2 US_DATA_3_Liab_Equity US_DATA_4_Loans US_DATA_5_Deposits US_DATA_5_OBS US_DATA_7_Income_Statement_1 US_DATA_7_Income_Statement_2 US_DATA_8_NII US_DATA_10_Loan_Quality US_DATA_11_Growth US_DATA_12_Profitability_Spread"
  foreach y of local files {
  merge 1:1 SNL_ID using D:\User\Desktop\DATA/`y'.dta
  drop _merge
  }
  save "D:\User\Desktop\DATA\US_DATA_1.dta"
  
  /*PART3*Reshaping Data*/
  reshape long Cash Securities Fed_Funds Trading_Assets Fixed_Asset Total_OREO Invest_in_Uncolidated_Subsid Total_Assets Total_Deposits Total_Liabilities Total_Equity_Capital Minority_Interest Total_Leases Less_Unearned_Income Total_Loans_Leases_HFS Net_Loans_Leases Transaction_Accts_Deposits Demand_Deposits NonTransaction_Accts_Deposits Brokered_Deposits Unused_Commitment Fin_Standby_LC Performance_Standby_LC Commercial_LC Interest_Income Interest_Expense Net_interest_Income LLP NonInterest_Expense Net_Income_Before_Tax_Extraord Net_Income NII_Other NII_Total NPLNL LLRGL NCO_Avg_Loan LLPNCO Asset_Growth Loan_Growth Deposit_Growth ROAA ROAE NIM Spread , i(SNL_ID) j(quarter)
  
  /*PART4*Dropping Extra Variables*/
  drop GL GM GN EP EQ ER ES ET EU EV EW EX EY EZ FA FB FC FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FR FS FT FU FV FW FX FY FZ GA GB GC GD GE GF GG GH GI GJ GK
  
  save "D:\User\Desktop\DATA\US_DATA_3.dta"
  
  /*PART5*Importing State-Level Data: Home Price Index*/
  import excel "D:\User\Desktop\DATA\HPI_EXP_state.xls", sheet("HPI_EXP_state") firstrow
  save "D:\User\Desktop\DATA\HPI_EXP_state.dta"
  
  /*PART6*Generating Matched Variables and Merging State-Level Home Price Index*/
  use "D:\User\Desktop\DATA\US_DATA_3.dta"
  xtset SNL_ID quarter
  gen qtr=quarter(dofq(quarter ))-1
  replace qtr=4 if qtr==0
  gen year = yofd(dofq( quarter ))+43
  replace year=year-1 if qtr==4
  gen state=STATE
  save "D:\User\Desktop\DATA\US_DATA_4.dta"
  use "D:\User\Desktop\DATA\HPI_EXP_state.dta"
  rename yr year
  save "D:\User\Desktop\DATA\HPI_EXP_state.dta", replace
  use "D:\User\Desktop\DATA\US_DATA_4.dta"
  merge m:1 qtr year state using "D:\User\Desktop\DATA\HPI_EXP_state.dta"
  save "D:\User\Desktop\DATA\US_DATA_5.dta"
  
 /*PART7*Importing State-Level Data: Personal Income Growth*/

   import excel "D:\User\Desktop\DATA\personal_income_growth.xls", sheet("Sheet1") firstrow
   reshape long Income_Growth , i( STATE ) j(quarter)
   save "D:\User\Desktop\DATA\personal_income_growth.dta"
   
  /*PART8*Merging State-Level Data*/

   use "D:\User\Desktop\DATA\US_DATA_5.dta"
   drop _merge
   merge m:m STATE quarter using "D:\User\Desktop\DATA\personal_income_growth.dta"
   save "D:\User\Desktop\DATA\US_DATA_6.dta"
   
  /*PART9*Cleaning the Dataset and Constructing Variables*/
  
  xtset
  drop if SNL_ID == .
  drop if year <=2009
  save "D:\User\Desktop\DATA\US_DATA_7.dta"
  gen Loan_Asset_Ratio= (Net_Loans_Leases/ Total_Assets)*100
  gen Avg_Loan=( Net_Loans_Leases+L.Net_Loans_Leases)/2
  gen LLPAGL=( LLP/ Avg_Loan)*100
  drop Loan_Growth
  gen Loan_Growth=(( Net_Loans_Leases-L.Net_Loans_Leases)/ L.Net_Loans_Leases)*100
  gen Capital_Asset_Ratio=( Total_Equity_Capital/ Total_Assets)*100
  gen Inefficiency=( NonInterest_Expense/ Net_Income)*100
  
   /*PART10*Summary Statistics*/
   ssc install estout, replace
   estpost summarize Loan_Asset_Ratio Avg_Loan LLPAGL Loan_Growth Capital_Asset_Ratio Inefficiency
   log close

   
   
   
  


  
   
  
  
  
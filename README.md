# README File

 * ### Explanation: 
  I first generated a personal token from github developer settings to use while scraping data.  
  I used the query link: "https://api.github.com/search/users?q=location:Sydney+followers:>100&per_page=100" to get the data needed.    
  I made seperate bash script codes for extracting the user data and for repository data and depositing in csv file, the codes are attached along.
  
 #### In the bash script:  
  >  I created the respective csv files to write the data scraped, along with the needed coloumns.  
  >  Using the curl function I scraped the data in form of JSON.  
  >  Then wrote whichever data was needed about the user/repository into the csv file, from the scraped JSON.  
  >  First user scraping was done and stored to user.csv.  
  >  Using each of the user logins, upto 500 latest repositories were scrapped and stored in repositories.csv
#### For analysis
  > I used excel sheet and RStudio to analyse the scraped data.  
  > In excel sheets I used pivot tables and basic formulas to obtain answers.  
  > Questions that needed more data manipulation, I turned to Rstudio due to familiarity.  


 * ### Interesting fact:
   
 * ### Recommendation

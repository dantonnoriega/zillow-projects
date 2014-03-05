* run zillow directory 

clear all
set more off

global github "D:\Dan's Workspace\GitHub Repository\zillow_projects\"
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

do "$github/(0) initialize_zillow.do"
do "$github/(1) zillow_trimdown.do"

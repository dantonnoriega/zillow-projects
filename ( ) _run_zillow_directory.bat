REM run zillow directory 
@echo off
cd /D D:\Dan's Workspace\GitHub Repository\zillow_projects

REM CANNOT HAVE SPACES AFTER VARIABLE NAMES
REM "STATA =" and "STATA=" are DIFFERENT!
set STATA=D:\Program Files (x86)\Stata13\
set GIT=D:\Dan's Workspace\GitHub Repository\zillow_projects

REM "%STATA%\StataMP-64" do "%GIT%\(0) initialize_zillow.do"
REM "%STATA%\StataMP-64" do "%GIT%\(1) zillow_trimdown.do"
 "%STATA%\StataMP-64" do "%GIT%\(2) zillow_76_to_text.do"
python "%GIT%\(3.0) tokenize_zillow_sample.py"
python "%GIT%\(3.1) tokenize_greenhomes.py"



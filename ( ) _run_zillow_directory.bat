REM run zillow directory 
@echo off
cd /D D:\Dan's Workspace\GitHub Repository\zillow_projects

REM CANNOT HAVE SPACES AFTER VARIABLE NAMES
REM "STATA =" and "STATA=" are DIFFERENT!
set STATA=D:\Program Files (x86)\Stata13\
set GIT=D:\Dan's Workspace\GitHub Repository\zillow_projects
set STATA
set GIT

REM "%STATA%\StataMP-64" do "%GIT%\(0) initialize_zillow.do"
REM "%STATA%\StataMP-64" do "%GIT%\(1) zillow_trimdown.do"
REM "%STATA%\StataMP-64" do "%GIT%\(2) zillow_76_to_text.do"
python "%GIT%\(3.1) zillow_tokenize_atype76.py"
python "%GIT%\(3.2) tokenize_greenhomes.py"
REM "%STATA%\StataMP-64" do "%GIT%\(4) zillow_wordlist.do"
REM "%STATA%\StataMP-64" "%GIT%\dict_wordlist_merge.do"



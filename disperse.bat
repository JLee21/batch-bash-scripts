@echo off
rem Check for a valid filename
cls

SET PUTTYSCP_BIN="C:\Program Files (x86)\PuTTY\pscp.exe"
SET PUTTY_BIN="C:\Program Files (x86)\PuTTY\putty.exe"
SET CMD_FILENAME=commands.sh
SET ALIAS_SOURCE_FILE="C:\RaspberryPi\.bash_aliases

SET ADDR=192.168.0.7
SET USERNAME=pi
SET PASSWORD=ahs08
SET ALIASEPATH_PI=/home/pi
rem /usr/lib/cgi-bin/
rem /var/www/
rem /home/pi/WebServer/Tornado/

SET ADDR1=192.168.0.18
SET USERNAME1=snoop
SET PASSWORD1=
SET ALIASEPATH_SNOOPSERVER=/usr/lib/cgi-bin/
rem /var/www 
rem /home/snoop/Tornado/

rem Upload the file to raspberry pi
%PUTTYSCP_BIN% -pw %PASSWORD% "%1" %USERNAME%@%ADDR%:%ALIASEPATH_PI%

rem Build a list of actions to do on the pi (chmod, execute GDB server)
if exist %~dp0%CMD_FILENAME% del %~dp0%CMD_FILENAME%
rem Change from Dos to Unix formating
cls
echo Sending %~1 to %ALIASEPATH_PI%
echo.
C:\RaspberryPi\dos2unix.exe %1

rem command.sh for clients
echo cd %ALIASEPATH_PI% 				>> %~dp0%CMD_FILENAME%
echo mkdir tmp  						>> %~dp0%CMD_FILENAME%
echo chmod 777 %~n1%~x1 				>> %~dp0%CMD_FILENAME%
echo gdbserver :3785 "%2" 				>> %~dp0%CMD_FILENAME%
echo chmod 777 %CMD_FILENAME% 			>> %~dp0%CMD_FILENAME%
echo bashrc 							>> %~dp0%CMD_FILENAME%
echo gdbserver :3785 %ALIASEPATH_PI% 	>> %~dp0%CMD_FILENAME%


echo Executing script to execute script
rem Upload the file to raspberry pi and Snoop Server
%PUTTYSCP_BIN% -pw %PASSWORD% "%1" %USERNAME%@%ADDR%:%ALIASEPATH_PI%
rem %PUTTYSCP_BIN% -pw %PASSWORD1% "%1" %USERNAME1%@%ADDR1%:%ALIASEPATH_SNOOPSERVER%
echo.
rem Execute the action list on clients
echo "Disperse to SnoopPi..."
echo.
%PUTTY_BIN% -pw %PASSWORD% -m %~dp0%CMD_FILENAME% %USERNAME%@%ADDR%
echo "Disperse to SnoopServer..."
rem %PUTTY_BIN% -pw %PASSWORD1% -m %~dp0%CMD_FILENAME% %USERNAME1%@%ADDR1%
echo.

echo.
echo %time%
exit /b %ERRORLEVEL%

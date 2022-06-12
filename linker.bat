@echo off

set MYDIR=%cd%


if [%1]==[] (goto unknown) else goto known

:known
set LINKTO=%1
goto link

:unknown
set /p LINKTO="Link computer id: "
goto link


:link

mklink /D "%MYDIR%/../computer/%LINKTO%" "%MYDIR%"


./linker.bat
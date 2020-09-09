@ECHO OFF
cd /d %~dp0


echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Usage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -pid      PID of the process to acquire. Required without process name.
echo      -process  name of the process to acquire. Required without PID.
echo      -content  only acquire processes that contain a particular regex content. Default: ^"^"
echo      -output   directory to write the results. Default .\Audits



set PID=
set PROCESS=
set INPUT=
set OUTPUT=
set CONTENT=


:again
rem if %1 is blank, we are finished
if "%1" == "" goto writescript

if "%1" == "-process" set PROCESS=%2
if "%1" == "-content" set CONTENT=%2
if "%1" == "-pid" set PID=%2
if "%1" == "-input" set INPUT=%~2
if "%1" == "-output" set OUTPUT=%~2

rem - shift the arguments and examine %1 again
shift
shift
goto again


:writescript

::we need to output so we need to fake an output path by specifying current working directory
if "%OUTPUT%" == "" set OUTPUT=%~dp0

::get the last character in the output path
set str=%OUTPUT:~-1%


::append out.txt to output and set it to outpath we dont add a backslash since one was already there
if "%str%" == "\" set OUTPATH=%OUTPUT%out.txt

::append \out.txt to output and set it to outpath
if not "%str%" == "\" set OUTPATH=%OUTPUT%\out.txt

::if the last character in the path equal to backslash then we set the output path to path minus the backslash
if "%str%" == "\" set OUTPUT=%OUTPUT:~0,-1%



if EXIST "%OUTPATH%" del "%OUTPATH%"

echo ^<?xml version=^"1.0^" encoding=^"utf-8^"?^> >>"%OUTPATH%"
echo ^<script xmlns:xsi=^"http://www.w3.org/2001/XMLSchema-instance^" xmlns:xsd=^"http://www.w3.org/2001/XMLSchema^" chaining=^"implicit^"^> >>"%OUTPATH%"
echo  ^<commands^> >>"%OUTPATH%"
echo    ^<command xsi:type=^"ExecuteModuleCommand^"^> >>"%OUTPATH%"

:scriptname
echo      ^<module name=^"w32processes-memoryacquire^" version=^"1.4.37.0^" /^> >>"%OUTPATH%"

:parameters
echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >>"%OUTPATH%" 
echo        ^<parameters^> >>"%OUTPATH%" 

if "%PROCESS%" == "" goto check_pid

:parameter

if not "%PROCESS%" == "" echo ^<param name=^"process name^"^>^<value xsi:type=^"xsd:string^"^>%PROCESS%^</value^>^</param^> >>"%OUTPATH%" 
if not "%PID%" == "" echo ^<param name=^"pid^"^>^<value xsi:type=^"xsd:unsignedInt^"^>%PID%^</value^>^</param^> >>"%OUTPATH%" 
if not "%CONTENT%" == "" echo ^<param name=^"Content Regex^"^>^<value xsi:type=^"ArrayOfString^"^>^<string^>%CONTENT%^</string^>^</value^>^</param^> >>"%OUTPATH%" 
if not "%INPUT%" == "" echo ^<param name=^"memory file^"^> ^<value xsi:type=^"xsd:string^"^>%INPUT%^</value^> ^</param^> >>"%OUTPATH%"



echo        ^</parameters^> >>"%OUTPATH%" 
echo      ^</config^> >>"%OUTPATH%"
echo    ^</command^> >>"%OUTPATH%"
echo  ^</commands^> >>"%OUTPATH%"
echo ^</script^> >>"%OUTPATH%"

goto execute

:check_pid
if not "%PID%" == "" goto parameter

:error
echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Useage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -pid      PID of the process to acquire. Required without process name.
echo      -process  name of the process to acquire. Required without PID.
echo      -content  only acquire processes that contain a particular regex content. Default: ^"^"
echo      -output   directory to write the results. Default .\Audits
goto done


:execute
if not "%OUTPUT%" == "" START Memoryze.exe -o ^"%OUTPUT%^"^ -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
if "%OUTPUT%" == "" START Memoryze.exe -o -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
:done
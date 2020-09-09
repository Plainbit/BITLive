@ECHO OFF
cd /d %~dp0

echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Usage: %0
echo      -offset   optional offset into physical memory. Exclude for all.
echo      -size     optional size of physical memory to acquire. Exclude for all.
echo      -output   directory to write the results. Default .\Audits

set OFFSET=
set SIZE=
set OUTPUT=


:again
rem if %1 is blank, we are finished
if "%1" == "" goto writescript

if "%1" == "-offset" set OFFSET=%2
if "%1" == "-size" set SIZE=%2
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
echo      ^<module name=^"w32memory-acquisition^" version=^"1.3.22.2^" /^> >>"%OUTPATH%"

:parameters
echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >>"%OUTPATH%" 
echo        ^<parameters^> >>"%OUTPATH%" 


if not "%OFFSET%" == "" echo ^<param name=^"offset^"^>^<value xsi:type=^"xsd:unsignedLong^"^>%OFFSET%^</value^>^</param^> >>"%OUTPATH%" 

if not "%SIZE%" == "" echo ^<param name=^"size^"^> ^<value xsi:type=^"xsd:unsignedLong^"^>%SIZE%^</value^> ^</param^> >>"%OUTPATH%"

echo        ^</parameters^> >>"%OUTPATH%" 
echo      ^</config^> >>"%OUTPATH%"
echo    ^</command^> >>"%OUTPATH%"
echo  ^</commands^> >>"%OUTPATH%"
echo ^</script^> >>"%OUTPATH%"

goto execute

:errorecho Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Useage: %0
echo      -offset   optional offset into physical memory. Exclude for all.
echo      -size     optional size of physical memory to acquire. Exclude for all.
echo      -output   directory to write the results. Default .\Audits
goto done


:execute
if not "%OUTPUT%" == "" START Memoryze.exe -o ^"%OUTPUT%^"^ -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
if "%OUTPUT%" == "" START Memoryze.exe -o -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
:done
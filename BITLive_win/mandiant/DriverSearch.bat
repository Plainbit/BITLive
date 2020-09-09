@ECHO OFF

cd /d %~dp0


echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Usage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -output   directory to write the results. Default .\Audits
echo      -imports  true^|false enumerates imports of loaded binaries. Default: false
echo      -exports  true^|false enumerates exports of loaded binaries. Default: false
echo      -digsig   true^|false verify if the driver is signed on disk. Default: false
echo      -MD5      true^|false hash the driver on disk. Default: false
echo      -SHA1     true^|false hash the driver on disk. Default: false
echo      -SHA256   true^|false hash the driver on disk. Default: false
echo      -strings  true^|false inspect all the strings of a process. Default: false


set INPUT=
set OUTPUT=
set IMPORTS=
set EXPORTS=
set DIGSIG=
set MD5=
set SHA1=
set SHA256=
set STRINGS=


:again
rem if %1 is blank, we are finished
if "%1" == "" goto writescript


if "%1" == "-input" set INPUT=%~2
if "%1" == "-output" set OUTPUT=%~2
if "%1" == "-strings" set STRINGS=%2
if "%1" == "-imports" set IMPORTS=%2
if "%1" == "-exports" set EXPORTS=%2
if "%1" == "-digsig" set DIGSIG=%2
if "%1" == "-MD5" set MD5=%2
if "%1" == "-SHA1" set SHA1=%2
if "%1" == "-SHA256" set SHA256=%2

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
echo      ^<module name=^"w32drivers-signature^" version=^"1.4.0.0^" /^> >>"%OUTPATH%"

:parameters
echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >>"%OUTPATH%" 
echo        ^<parameters^> >>"%OUTPATH%" 

if not "%STRINGS%" == "" echo ^<param name=^"strings^"^>^<value xsi:type=^"xsd:boolean^"^>%STRINGS%^</value^>^</param^> >>"%OUTPATH%" 
if "%STRINGS%" == "" echo ^<param name=^"strings^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%EXPORTS%" == "" echo ^<param name=^"enumerate exports^"^>^<value xsi:type=^"xsd:boolean^"^>%EXPORTS%^</value^>^</param^> >>"%OUTPATH%" 
if "%EXPORTS%" == "" echo ^<param name=^"enumerate exports^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%IMPORTS%" == "" echo ^<param name=^"enumerate imports^"^>^<value xsi:type=^"xsd:boolean^"^>%IMPORTS%^</value^>^</param^> >>"%OUTPATH%" 
if "%IMPORTS%" == "" echo ^<param name=^"enumerate imports^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%DIGSIG%" == "" echo ^<param name=^"Verify Digital Signatures^"^>^<value xsi:type=^"xsd:boolean^"^>%DIGSIG%^</value^>^</param^> >>"%OUTPATH%" 
if "%DIGSIG%" == "" echo ^<param name=^"Verify Digital Signatures^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%MD5%" == "" echo ^<param name=^"MD5^"^>^<value xsi:type=^"xsd:boolean^"^>%MD5%^</value^>^</param^> >>"%OUTPATH%" 
if "%MD5%" == "" echo ^<param name=^"MD5^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%SHA1%" == "" echo ^<param name=^"SHA1^"^>^<value xsi:type=^"xsd:boolean^"^>%SHA1%^</value^>^</param^> >>"%OUTPATH%" 
if "%SHA1%" == "" echo ^<param name=^"SHA1^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%SHA256%" == "" echo ^<param name=^"SHA256^"^>^<value xsi:type=^"xsd:boolean^"^>%SHA256%^</value^>^</param^> >>"%OUTPATH%" 
if "%SHA256%" == "" echo ^<param name=^"SHA256^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%INPUT%" == "" echo ^<param name=^"memory file^"^> ^<value xsi:type=^"xsd:string^"^>%INPUT%^</value^> ^</param^> >>"%OUTPATH%"

echo        ^</parameters^> >>"%OUTPATH%" 
echo      ^</config^> >>"%OUTPATH%"
echo    ^</command^> >>"%OUTPATH%"
echo  ^</commands^> >>"%OUTPATH%"
echo ^</script^> >>"%OUTPATH%"

goto execute

:error
echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Useage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -output   directory to write the results. Default .\Audits
echo      -imports  true^|false enumerates imports of loaded binaries. Default: false
echo      -exports  true^|false enumerates exports of loaded binaries. Default: false
echo      -digsig   true^|false verify if the driver is signed on disk. Default: false
echo      -MD5      true^|false hash the driver on disk. Default: false
echo      -SHA1     true^|false hash the driver on disk. Default: false
echo      -SHA256   true^|false hash the driver on disk. Default: false
echo      -strings  true^|false inspect all the strings of a process. Default: false
goto done

:execute
if not "%OUTPUT%" == "" START Memoryze.exe -o ^"%OUTPUT%^"^ -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
if "%OUTPUT%" == "" START Memoryze.exe -o -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
:done
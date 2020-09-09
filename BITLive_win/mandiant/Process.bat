@ECHO OFF

cd /d %~dp0

set OUTPUT=%~dp0
echo %OUTPUT%

echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Usage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -output   directory to write the results. Default .\Audits
echo      -pid      PID of the process to inspect. Default: 4294967295 = All
echo      -process  optional name of the process to inspect. Default: Excluded
echo      -handles  true^|false inspect all the process handles. Default: false
echo      -sections true^|false inspect all process memory ranges. Default: false
echo      -ports    true^|false inspect all the ports of a process. Default: false
echo      -imports  true^|false enumerates imports of loaded binaries. Default: false
echo      -exports  true^|false enumerates exports of loaded binaries. Default: false
echo      -injected true^|false attempts to determine if a module was injected. Default: false
echo      -digsig   true^|false verify if the driver is signed on disk. Default: false
echo      -MD5      true^|false hash the driver on disk. Default: false
echo      -MemD5    true^|false hash the driver on disk. Default: false
echo      -SHA1     true^|false hash the driver on disk. Default: false
echo      -SHA256   true^|false hash the driver on disk. Default: false
echo      -strings  true^|false inspect all the strings of a process. Default: false
echo      -content  only return processes with a particular regex content. Default: ^"^"

set INPUT=
set OUTPUT=
set PID=
set PROCESS=
set HANDLES=
set SECTIONS=
set PORTS=
set IMPORTS=
set EXPORTS=
set INJECTED=
set DIGSIG=
set MD5=
set MemD5=
set SHA1=
set SHA256=
set STRINGS=
set CONTENT=

:again
rem if %1 is blank, we are finished
if "%1" == "" goto writescript

if "%1" == "-input" set INPUT=%~2
if "%1" == "-output" set OUTPUT=%~2
if "%1" == "-pid" set PID=%2
if "%1" == "-process" set PROCESS=%2
if "%1" == "-handles" set HANDLES=%2
if "%1" == "-sections" set SECTIONS=%2
if "%1" == "-ports" set PORTS=%2
if "%1" == "-imports" set IMPORTS=%2
if "%1" == "-exports" set EXPORTS=%2
if "%1" == "-injected" set INJECTED=%2
if "%1" == "-digsig" set DIGSIG=%2
if "%1" == "-MD5" set MD5=%2
if "%1" == "-MemD5" set MemD5=%2
if "%1" == "-SHA1" set SHA1=%2
if "%1" == "-SHA256" set SHA256=%2
if "%1" == "-strings" set STRINGS=%2
if "%1" == "-content" set CONTENT=%2

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
echo      ^<module name=^"w32processes-memory^" version=^"1.4.37.0^" /^> >>"%OUTPATH%"

:parameters
echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >>"%OUTPATH%" 
echo        ^<parameters^> >>"%OUTPATH%" 

if not "%PID%" == "" echo ^<param name=^"pid^"^> ^<value xsi:type=^"xsd:unsignedInt^"^>%PID%^</value^> ^</param^> >>"%OUTPATH%"
if "%PID%" == "" echo ^<param name=^"pid^"^> ^<value xsi:type=^"xsd:unsignedInt^"^>4294967295^</value^> ^</param^> >>"%OUTPATH%"

if not "%PROCESS%" == "" echo ^<param name=^"process name^"^> ^<value xsi:type=^"xsd:string^"^>%PROCESS%^</value^> ^</param^> >>"%OUTPATH%"

if not "%HANDLES%" == "" echo ^<param name=^"handles^"^>^<value xsi:type=^"xsd:boolean^"^>%HANDLES%^</value^>^</param^> >>"%OUTPATH%" 
if "%HANDLES%" == "" echo ^<param name=^"handles^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%SECTIONS%" == "" echo ^<param name=^"sections^"^>^<value xsi:type=^"xsd:boolean^"^>%SECTIONS%^</value^>^</param^> >>"%OUTPATH%" 
if "%SECTIONS%" == "" echo ^<param name=^"sections^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%PORTS%" == "" echo ^<param name=^"ports^"^>^<value xsi:type=^"xsd:boolean^"^>%PORTS%^</value^>^</param^> >>"%OUTPATH%" 
if "%PORTS%" == "" echo ^<param name=^"ports^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 
          
if not "%STRINGS%" == "" echo ^<param name=^"strings^"^>^<value xsi:type=^"xsd:boolean^"^>%STRINGS%^</value^>^</param^> >>"%OUTPATH%" 
if "%STRINGS%" == "" echo ^<param name=^"strings^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%CONTENT%" == "" echo ^<param name=^"Content Regex^"^>^<value xsi:type=^"ArrayOfString^"^>^<string^>%CONTENT%^</string^>^</value^>^</param^> >>"%OUTPATH%" 

if not "%EXPORTS%" == "" echo ^<param name=^"enumerate exports^"^>^<value xsi:type=^"xsd:boolean^"^>%EXPORTS%^</value^>^</param^> >>"%OUTPATH%" 
if "%EXPORTS%" == "" echo ^<param name=^"enumerate exports^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%IMPORTS%" == "" echo ^<param name=^"enumerate imports^"^>^<value xsi:type=^"xsd:boolean^"^>%IMPORTS%^</value^>^</param^> >>"%OUTPATH%" 
if "%IMPORTS%" == "" echo ^<param name=^"enumerate imports^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%INJECTED%" == "" echo ^<param name=^"detect injected dlls^"^>^<value xsi:type=^"xsd:boolean^"^>%INJECTED%^</value^>^</param^> >>"%OUTPATH%" 
if "%INJECTED%" == "" echo ^<param name=^"detect injected dlls^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%DIGSIG%" == "" echo ^<param name=^"Verify Digital Signatures^"^>^<value xsi:type=^"xsd:boolean^"^>%DIGSIG%^</value^>^</param^> >>"%OUTPATH%" 
if "%DIGSIG%" == "" echo ^<param name=^"Verify Digital Signatures^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%MD5%" == "" echo ^<param name=^"MD5^"^>^<value xsi:type=^"xsd:boolean^"^>%MD5%^</value^>^</param^> >>"%OUTPATH%" 
if "%MD5%" == "" echo ^<param name=^"MD5^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 

if not "%MemD5%" == "" echo ^<param name=^"MemD5^"^>^<value xsi:type=^"xsd:boolean^"^>%MemD5%^</value^>^</param^> >>"%OUTPATH%" 
if "%MemD5%" == "" echo ^<param name=^"MemD5^"^>^<value xsi:type=^"xsd:boolean^"^>false^</value^>^</param^> >>"%OUTPATH%" 


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
echo    Usage: %0
echo      -input    name of snapshot. Exclude for live memory.
echo      -output   directory to write the results. Default .\Audits
echo      -pid      PID of the process to inspect. Default: 4294967295 = All
echo      -process  optional name of the process to inspect. Default: Excluded
echo      -handles  true^|false inspect all the process handles. Default: false
echo      -sections true^|false inspect all process memory ranges. Default: false
echo      -ports    true^|false inspect all the ports of a process. Default: false
echo      -imports  true^|false enumerates imports of loaded binaries. Default: false
echo      -exports  true^|false enumerates exports of loaded binaries. Default: false
echo      -injected true^|false attempts to determine if a module was injected. Default: false
echo      -digsig   true^|false verify if the driver is signed on disk. Default: false
echo      -MD5      true^|false hash the driver on disk. Default: false
echo      -MemD5    true^|false hash the driver on disk. Default: false
echo      -SHA1     true^|false hash the driver on disk. Default: false
echo      -SHA256   true^|false hash the driver on disk. Default: false
echo      -strings  true^|false inspect all the strings of a process. Default: false
echo      -content  only return processes with a particular regex content. Default: ^"^"
goto done



:execute
if not "%OUTPUT%" == "" START Memoryze.exe -o ^"%OUTPUT%^"^ -script ^"%OUTPATH%^"^  -encoding none -allowmultiple
if "%OUTPUT%" == "" START Memoryze.exe -o -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
:done
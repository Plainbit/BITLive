@ECHO OFF
cd /d %~dp0


echo Memoryze.exe by MANDIANT (c) 2011 - http://www.mandiant.com/products/free_software/memoryze/
echo    Usage: %0
echo      -input      name of snapshot. Exclude for live memory.
echo      -idt        true^|false verify certain IDT entries. Default: false
echo      -ssdt       true^|false verify System Call Table. Default: false
echo      -functions  true^|false verify System Call Table fuctions. Default: false
echo      -drivers    true^|false verify all drivers' IRP tables. Default: false
echo      -output     directory to write the results. Default .\Audits



set IDT=
set SSDT_INDEX=
set SSDT_INLINE=
set DRIVERS=
set INPUT=
set OUTPUT=


:again
rem if %1 is blank, we are finished
if "%1" == "" goto writescript

if "%1" == "-idt" set IDT=%2
if "%1" == "-ssdt" set SSDT_INDEX=%2
if "%1" == "-functions" set SSDT_INLINE=%2
if "%1" == "-drivers" set DRIVERS=%2
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
echo      ^<module name=^"w32kernel-hookdetection^" version=^"1.3.22.2^" /^> >>"%OUTPATH%"

:parameters
echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >>"%OUTPATH%" 
echo        ^<parameters^> >>"%OUTPATH%" 


if not "%IDT%" == "" echo ^<param name=^"idt^"^>^<value xsi:type=^"xsd:boolean^"^>%IDT%^</value^>^</param^> >>"%OUTPATH%" 
if "%IDT%" == "" echo ^<param name=^"idt^"^>^<value xsi:type=^"xsd:boolean^"^>true^</value^>^</param^> >>"%OUTPATH%" 

if not "%SSDT_INDEX%" == "" echo ^<param name=^"ssdt_index^"^>^<value xsi:type=^"xsd:boolean^"^>%SSDT_INDEX%^</value^>^</param^> >>"%OUTPATH%" 
if "%SSDT_INDEX%" == "" echo ^<param name=^"ssdt_index^"^>^<value xsi:type=^"xsd:boolean^"^>true^</value^>^</param^> >>"%OUTPATH%" 

if not "%SSDT_INLINE%" == "" echo ^<param name=^"ssdt_inline^"^>^<value xsi:type=^"xsd:boolean^"^>%SSDT_INLINE%^</value^>^</param^> >>"%OUTPATH%" 
if "%SSDT_INLINE%" == "" echo ^<param name=^"ssdt_inline^"^>^<value xsi:type=^"xsd:boolean^"^>true^</value^>^</param^> >>"%OUTPATH%" 
          
if not "%DRIVERS%" == "" echo ^<param name=^"drivers^"^>^<value xsi:type=^"xsd:boolean^"^>%DRIVERS%^</value^>^</param^> >>"%OUTPATH%" 
if "%DRIVERS%" == "" echo ^<param name=^"drivers^"^>^<value xsi:type=^"xsd:boolean^"^>true^</value^>^</param^> >>"%OUTPATH%" 

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
echo      -input      name of snapshot. Exclude for live memory.
echo      -idt        true^|false verify certain IDT entries. Default: false
echo      -ssdt       true^|false verify System Call Table. Default: false
echo      -functions  true^|false verify System Call Table fuctions. Default: false
echo      -drivers    true^|false verify all drivers' IRP tables. Default: false
echo      -output     directory to write the results. Default .\Audits
goto done


:execute
if not "%OUTPUT%" == "" START Memoryze.exe -o ^"%OUTPUT%^"^ -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
if "%OUTPUT%" == "" START Memoryze.exe -o -script ^"%OUTPATH%^"^ -encoding none -allowmultiple
:done
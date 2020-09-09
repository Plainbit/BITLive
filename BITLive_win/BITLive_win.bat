@echo off
cls
title BITLive Forensic Shell
prompt $T$S$P$G$S

echo ------------------------------------------------- 
echo          PLAINBIT Live Response Kit v1.7       
echo ------------------------------------------------- 

:: -----------------------------------------------------
:: VARIABLEs
:: -----------------------------------------------------
set _CPU=""
set _CASE=""
set _EXAMINER=""
set _OSARCH=""
set _CASE_DIR=""
set _TARGET_DIR=""

set _NOWTIME=""
set _IS_MEMORY=""
set _IS_NONVOLATILE=""
set _IS_PACKET=""
set _MD5=""
set _LOG=""

:: -----------------------------------------------------
:: Check the windows version
:: -----------------------------------------------------
for /f "tokens=2 delims=[]" %%i in ('ver') do set VERSION=%%i
for /f "tokens=2-3 delims=. " %%i in ("%VERSION%") do set VERSION=%%i.%%j
if "%VERSION%" == "5.00" if "%VERSION%" == "5.0" echo Windows 2000 is not supported! 
if "%VERSION%" == "5.1" (
	echo - OS: Windows XP
	set PATH=0S-winxp\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "5.2" (
	echo Windows Server 2003
	set PATH=0S-win2k3\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.0" (
	echo Windows Vista or Windows Server 2008
	set PATH=0S-winvista\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.1" (
	echo Windows 7 or Windows Server 2008 R2
	set PATH=0S-win7\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.2" (
	echo Windows 8
	set PATH=0S-win8\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.3" (
	echo Windows 8.1
	set PATH=0S-win8\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "10.0" (
	echo - OS: Windows 10
	set PATH=0S-win10\;
	GOTO:CPU_TYPE
)
GOTO:END

:: -----------------------------------------------------
:: Check the CPU Architecture
:: -----------------------------------------------------
:CPU_TYPE
if /i "%PROCESSOR_ARCHITECTURE:~-2%"=="86" (
	echo - CPU: 32 bit
	set PATH=%PATH%nirsoft\;sysinternals\;
)
if /i "%PROCESSOR_ARCHITECTURE:~-2%"=="64" (
	echo - CPU: 64 bit
	set PATH=%PATH%x64\nirsoft\;x64\sysinternals\;
)

echo - Username: %username%
echo - Computername: %computername%

:: PATH RESET
set PATH=%PATH%mandiant\;microsoft\;others\;unxutils\;velocidex\;vidstromlabs\;winfingerprint\;wireshark\;
echo.
	
:: -----------------------------------------------------
:: Enter the case name
:: -----------------------------------------------------
:ENTER_CASE
	set /p _CASE=# Please enter the case name : || GOTO:ENTER_CASE

:: -----------------------------------------------------
:: Create CASE directory
:: -----------------------------------------------------
	set _CASE_DIR=%~d0\%_CASE%
	if not exist %_CASE_DIR% mkdir %_CASE_DIR%
	echo - Case Root: %_CASE_DIR%
	echo.
	
:: -----------------------------------------------------
:: Enter the examiner name
:: -----------------------------------------------------
:ENTER_EXAMINER
	set /p _EXAMINER=# Please enter the examiner's name : || GOTO:ENTER_EXAMINER
	echo - Examiner: %_EXAMINER%
	echo.
	
:: -----------------------------------------------------
:: Check whether physical memory is acquire or not...
:: -----------------------------------------------------
:ACQUIRE_MEMORY
	set /p _IS_MEMORY=# Do you want to acquire physical memory? (y or n) || GOTO:ACQUIRE_MEMORY
	if /i "%_IS_MEMORY%" == "Y" GOTO:ACQUIRE_NONVOLATILE
	if /i "%_IS_MEMORY%" == "N" GOTO:ACQUIRE_NONVOLATILE
	GOTO:ACQUIRE_MEMORY

:: -----------------------------------------------------
:: Check whether non-volatile data is acquire or not...
:: -----------------------------------------------------
:ACQUIRE_NONVOLATILE
	set /p _IS_NONVOLATILE=# Do you want to acquire Non-volatile data? (y or n) || GOTO:ACQUIRE_NONVOLATILE
	if /i "%_IS_NONVOLATILE%" == "Y" GOTO:START
	if /i "%_IS_NONVOLATILE%" == "N" GOTO:START
	GOTO:ACQUIRE_NONVOLATILE

:START
echo.
:: -----------------------------------------------------
:: Create TARGET directory (using current time)
:: -----------------------------------------------------
	set _TIME=%TIME::=%
	set _NOWTIME=%DATE%_%_TIME%
	set _TARGET_DIR=%_CASE_DIR%\%COMPUTERNAME%
	if not exist %_TARGET_DIR% mkdir %_TARGET_DIR%

:: -----------------------------------------------------
:: Create LOG file
:: -----------------------------------------------------
	set _LOG=%_TARGET_DIR%\BITLive_win.log
	if not exist %_LOG% (
	echo ************************************************* > %_LOG%
	echo *         PLAINBIT Live Response Kit v1.7       * >> %_LOG%
	echo ************************************************* >> %_LOG%
	echo CASE : %_CASE% >> %_LOG%
	echo EXAMINER : %_EXAMINER% >> %_LOG%
	echo START TIME : %DATE% %TIME% >> %_LOG%
	echo. >> %_LOG%
)

:: -----------------------------------------------------
:: FIRST OF ALL, Acquire PREFETCH files and RecentFileCache.bcf, Amcache.hve
:: -----------------------------------------------------
	echo.
	echo ## FIRST OF ALL, START ACQUIRING PREFETCH AND RECENTFILECACHE
	set _NONVOLATILE_DIR=%_TARGET_DIR%\non_volatile
	mkdir %_NONVOLATILE_DIR%
	echo Created "non_volatile" directory in %_TARGET_DIR%\
	echo Created "non_volatile" directory in %_TARGET_DIR%\ >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo # Prefetch, Superfetch                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Prefetch files ...
	echo %DATE% %TIME% - Acquiring Prefetch files ... >> %_LOG%
	forecopy_handy -p %_NONVOLATILE_DIR%
	set _APPCOMPAT_DIR=%_NONVOLATILE_DIR%\appcompat
	mkdir %_APPCOMPAT_DIR%
	echo ----------------------------------------- >> %_LOG%
	echo # RecentFileCache.bcf, Amcache.hve        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring RecentFileCache.bcf, Amcache.hve ...
	echo %DATE% %TIME% - Acquiring RecentFileCache.bcf, Amcache.hve ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\AppCompat\Programs" %_APPCOMPAT_DIR%
	
:: -----------------------------------------------------
:: Acquire VOLATILE data 
:: -----------------------------------------------------
	set _VOLATILE_DIR=%_TARGET_DIR%\volatile
	mkdir %_VOLATILE_DIR%
	echo.
	echo ## START ACQUIRING VOLATILE
	echo Created "volatile" directory in %_TARGET_DIR%\
	echo Created "volatile" directory in %_TARGET_DIR%\ >> %_LOG%

:: NETWORK INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # NETWORK INFORMATION                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _NETWORK_DIR=%_VOLATILE_DIR%\network_information
	mkdir %_NETWORK_DIR%
	echo.
	echo # START ACQUIRING NETWORK INFORMATION
	echo Created "network_information" directory in %_VOLATILE_DIR%\
	echo Created "network_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring arp cache table ...
	echo %DATE% %TIME% - Acquiring arp cache table ... >> %_LOG%
	arp -a > %_NETWORK_DIR%\arp-a.txt
	echo %DATE% %TIME% - Acquiring network Status ...
	echo %DATE% %TIME% - Acquiring network Status ... >> %_LOG%
	netstat -nao > %_NETWORK_DIR%\netstat-nao.txt
	echo %DATE% %TIME% - Acquiring routing Table ...
	echo %DATE% %TIME% - Acquiring routing Table ... >> %_LOG%
	route PRINT > %_NETWORK_DIR%\route_PRINT.txt
	echo %DATE% %TIME% - Acquiring currently opened TCP/IP and UDP ports ...
	echo %DATE% %TIME% - Acquiring currently opened TCP/IP and UDP ports ... >> %_LOG%
	cports /scomma %_NETWORK_DIR%\cports.csv
	echo %DATE% %TIME% - Acquiring url protocols ...
	echo %DATE% %TIME% - Acquiring url protocols ... >> %_LOG%
	urlprotocolview /stext %_NETWORK_DIR%\urlprotocolview.txt
	echo %DATE% %TIME% - Acquiring network connected sessions ...
	echo %DATE% %TIME% - Acquiring network connected sessions ... >> %_LOG%
	net sessions > %_NETWORK_DIR%\net_sessions.txt
	echo %DATE% %TIME% - Acquiring network opened files ...
	echo %DATE% %TIME% - Acquiring network opened files ... >> %_LOG%
	net file > %_NETWORK_DIR%\net_file.txt
	echo %DATE% %TIME% - Acquiring network shared information ...
	echo %DATE% %TIME% - Acquiring network shared information ... >> %_LOG%
	net share > %_NETWORK_DIR%\net_share.txt
	echo %DATE% %TIME% - Acquiring NBT(NetBIOS over TCP/IP)'s cache ...
	echo %DATE% %TIME% - Acquiring NBT(NetBIOS over TCP/IP)'s cache ... >> %_LOG%
	nbtstat -c > %_NETWORK_DIR%\nbtstat-c.txt
	echo %DATE% %TIME% - Acquiring NBT(NetBIOS over TCP/IP)'s sessions ...
	echo %DATE% %TIME% - Acquiring NBT(NetBIOS over TCP/IP)'s sessions ... >> %_LOG%
	nbtstat -s > %_NETWORK_DIR%\nbtstat-s.txt
	echo %DATE% %TIME% - Acquiring All endpoints information ...
	echo %DATE% %TIME% - Acquiring All endpoints information ... >> %_LOG%
	tcpvcon -a -c /accepteula > %_NETWORK_DIR%\tcpvcon-a-c.txt
	echo %DATE% %TIME% - Acquiring list of all files that are currently opened by other computers ...
	echo %DATE% %TIME% - Acquiring list of all files that are currently opened by other computers ... >> %_LOG%
	networkopenedfiles /scomma %_NETWORK_DIR%\networkopenedfiles.csv
	echo %DATE% %TIME% - Acquiring history of connections to wireless networks ...
	echo %DATE% %TIME% - Acquiring history of connections to wireless networks ... >> %_LOG%
	wifihistoryview /scomma %_NETWORK_DIR%\wifihistoryview.txt
	echo %DATE% %TIME% - Acquiring the activity of wireless networks ...
	echo %DATE% %TIME% - Acquiring the activity of wireless networks ... >> %_LOG%
	wirelessnetview /scomma %_NETWORK_DIR%\wirelessnetview.csv
	echo %DATE% %TIME% - Acquiring the list of all routes on current network ...
	echo %DATE% %TIME% - Acquiring the list of all routes on current network ... >> %_LOG%
	netrouteview /scomma %_NETWORK_DIR%\netrouteview.csv
	echo %DATE% %TIME% - Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ...
	echo %DATE% %TIME% - Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ... >> %_LOG%
	networkusageview /scomma %_NETWORK_DIR%\networkusageview.csv
	
:: PHYSICAL MEMORY
	if /i "%_IS_MEMORY%" == "N" GOTO:PROCESS
	echo ----------------------------------------- >> %_LOG%
	echo # PHYSICAL MEMORY                         >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _MEMORY_DIR=%_TARGET_DIR%\memory
	mkdir %_MEMORY_DIR%
	echo.
	echo ## START ACQUIRING PHYSICAL MEMORY
	echo Created "memory" directory in %_TARGET_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring physical memory ...
	echo %DATE% %TIME% - Acquiring physical memory ... >> %_LOG%
	winpmem_v3.3.rc3.exe --mode PTERemapping --format raw -o %_MEMORY_DIR%\winpmem_dump.raw
	::
	:: MANDIANT MEMORIZE
	:: echo ^<?xml version=^"1.0^" encoding=^"utf-8^"?^> > %_MEMORY_DIR%\config.txt
	:: echo ^<script xmlns:xsi=^"http://www.w3.org/2001/XMLSchema-instance^" xmlns:xsd=^"http://www.w3.org/2001/XMLSchema^" chaining=^"implicit^"^> >> %_MEMORY_DIR%\config.txt
	:: echo  ^<commands^> >> %_MEMORY_DIR%\config.txt
	:: echo    ^<command xsi:type=^"ExecuteModuleCommand^"^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^<module name=^"w32memory-acquisition^" version=^"1.3.22.2^" /^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >> %_MEMORY_DIR%\config.txt
	:: echo        ^<parameters^> >> %_MEMORY_DIR%\config.txt 
	:: echo        ^</parameters^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^</config^> >> %_MEMORY_DIR%\config.txt
	:: echo    ^</command^> >> %_MEMORY_DIR%\config.txt
	:: echo  ^</commands^> >> %_MEMORY_DIR%\config.txt
	:: echo ^</script^> >> %_MEMORY_DIR%\config.txt
	:: START /WAIT Memoryze.exe -o %_MEMORY_DIR% -script %_MEMORY_DIR%\config.txt -encoding none -allowmultiple

:PROCESS
:: PROCESS INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # PROCESS INFORMATION                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _PROCESS_DIR=%_VOLATILE_DIR%\process_information
	mkdir %_PROCESS_DIR%
	echo.
	echo # START ACQUIRING PROCESS INFORMATION
	echo Created "process_information" directory in %_VOLATILE_DIR%\
	echo Created "process_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring list of all processes_1 ...
	echo %DATE% %TIME% - Acquiring list of all processes_1 ... >> %_LOG%
	pslist /accepteula > %_PROCESS_DIR%\pslist.txt
	echo %DATE% %TIME% - Acquiring list of all processes_2 ...
	echo %DATE% %TIME% - Acquiring list of all processes_2 ... >> %_LOG%
	cprocess /stext %_PROCESS_DIR%\cprocess.txt
	echo %DATE% %TIME% - Acquiring list of all processes_3 ...
	echo %DATE% %TIME% - Acquiring list of all processes_3 ... >> %_LOG%
	procinterrogate -ps > %_PROCESS_DIR%\procinterrogate-ps.txt
	echo %DATE% %TIME% - Acquiring list of all processes_4 ...
	echo %DATE% %TIME% - Acquiring list of all processes_4 ... >> %_LOG%
	procinterrogate -list -md5 -ver -o %_PROCESS_DIR%\procinterrogate-list-md5-ver-o.txt
	echo %DATE% %TIME% - Acquiring list of task details ...
	echo %DATE% %TIME% - Acquiring list of task details ... >> %_LOG%
	tasklist -V > %_PROCESS_DIR%\tasklist-V.txt
	echo %DATE% %TIME% - Acquiring command lines for each process ...
	echo %DATE% %TIME% - Acquiring command lines for each process ... >> %_LOG%
	tlist -c > %_PROCESS_DIR%\tlist-c.txt
	echo %DATE% %TIME% - Acquiring task tree ...
	echo %DATE% %TIME% - Acquiring task tree ... >> %_LOG%
	tlist -t > %_PROCESS_DIR%\tlist-t.txt
	echo %DATE% %TIME% - Acquiring services active in each process ...
	echo %DATE% %TIME% - Acquiring services active in each process ... >> %_LOG%
	tlist -s > %_PROCESS_DIR%\tlist-s.txt
	echo %DATE% %TIME% - Acquiring list of loaded DLLs ...
	echo %DATE% %TIME% - Acquiring list of loaded DLLs ... >> %_LOG%
	listdlls /accepteula > %_PROCESS_DIR%\listdlls.txt
	echo %DATE% %TIME% - Acquiring list of injected DLLs for any process ...
	echo %DATE% %TIME% - Acquiring list of injected DLLs for any process ... >> %_LOG%
	injecteddll /stext %_PROCESS_DIR%\injecteddll.txt
	echo %DATE% %TIME% - Acquiring list of all DLL files loaded by all running processes ...
	echo %DATE% %TIME% - Acquiring list of all DLL files loaded by all running processes ... >> %_LOG%
	loadeddllsview /scomma %_PROCESS_DIR%\loadeddllsview.csv
	echo %DATE% %TIME% - Acquiring list of all loaded device drivers ...
	echo %DATE% %TIME% - Acquiring list of all loaded device drivers ... >> %_LOG%
	driverview /scomma %_PROCESS_DIR%\driverview.csv
	echo %DATE% %TIME% - Acquiring opened handles for any process ...
	echo %DATE% %TIME% - Acquiring opened handles for any process ... >> %_LOG%
	handle /accepteula > %_PROCESS_DIR%\handle.txt
	echo %DATE% %TIME% - Acquiring list of all opened files ...
	echo %DATE% %TIME% - Acquiring list of all opened files ... >> %_LOG%
	openedfilesview /scomma %_PROCESS_DIR%\openfilesview.csv

:: LOGON USER INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # LOGON USER INFORMATION                  >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _LOGONUSER_DIR=%_VOLATILE_DIR%\logon_user_information
	mkdir %_LOGONUSER_DIR%
	echo.
	echo # START ACQUIRING LOGON USER INFORMATION
	echo Created "logon_user_information" directory in %_VOLATILE_DIR%\
	echo Created "logon_user_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring logged on users ...
	echo %DATE% %TIME% - Acquiring logged on users ... >> %_LOG%
	psloggedon /accepteula > %_LOGONUSER_DIR%\psloggedon.txt
	echo %DATE% %TIME% - Acquiring logon sessions ...
	echo %DATE% %TIME% - Acquiring logon sessions ... >> %_LOG%
	logonsessions /accepteula > %_LOGONUSER_DIR%\logonsessions.txt
	echo %DATE% %TIME% - Acquiring user logged on in the past ...
	echo %DATE% %TIME% - Acquiring user logged on in the past ... >> %_LOG%
	netusers /local /history > %_LOGONUSER_DIR%\netusers_local_history.txt
	echo %DATE% %TIME% - Acquiring user account details ...
	echo %DATE% %TIME% - Acquiring user account details ... >> %_LOG%
	net user > %_LOGONUSER_DIR%\net_user.txt
	echo %DATE% %TIME% - Acquiring date/time that users logged on/off ...
	echo %DATE% %TIME% - Acquiring date/time that users logged on/off ... >> %_LOG%
	winlogonview /scomma %_LOGONUSER_DIR%\winlogonview.csv
	
:: SYSTEM INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # SYSTEM INFORMATION                      >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _SYSTEM_DIR=%_VOLATILE_DIR%\system_information
	mkdir %_SYSTEM_DIR%
	echo.
	echo # START ACQUIRING SYSTEM INFORMATION
	echo Created "system_information" directory in %_VOLATILE_DIR%\
	echo Created "system_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring local and remote system information ...
	echo %DATE% %TIME% - Acquiring local and remote system information ... >> %_LOG%
	psinfo /accepteula > %_SYSTEM_DIR%\psinfo.txt
	echo %DATE% %TIME% - Acquiring disk volume information ...
	echo %DATE% %TIME% - Acquiring disk volume information ... >> %_LOG%
	psinfo -d > %_SYSTEM_DIR%\psinfo_d.txt
	echo %DATE% %TIME% - Acquiring list of installed software ...
	echo %DATE% %TIME% - Acquiring list of installed software ... >> %_LOG%
	psinfo -s > %_SYSTEM_DIR%\psinfo_s.txt
	echo %DATE% %TIME% - Acquiring list of installed hotfixes ...
	echo %DATE% %TIME% - Acquiring list of installed hotfixes ... >> %_LOG%
	psinfo -h > %_SYSTEM_DIR%\psinfo_h.txt
	echo %DATE% %TIME% - Acquiring the history of Windows updates ...
	echo %DATE% %TIME% - Acquiring the history of Windows updates ... >> %_LOG%
	winupdatesview /scomma %_SYSTEM_DIR%\winupdatesview.csv
	echo %DATE% %TIME% - Acquiring applied group policies ...
	echo %DATE% %TIME% - Acquiring applied group policies ... >> %_LOG%
	gplist > %_SYSTEM_DIR%\gplist.txt
	echo %DATE% %TIME% - Acquiring applied RSoP group policies ...
	echo %DATE% %TIME% - Acquiring applied RSoP group policies ... >> %_LOG%
	gpresult /Z > %_SYSTEM_DIR%\gpresult_Z.txt
	echo %DATE% %TIME% - Acquiring configured services ...
	echo %DATE% %TIME% - Acquiring configured services ... >> %_LOG%
	psservice /accepteula > %_SYSTEM_DIR%\psservice.txt
	echo %DATE% %TIME% - Acquiring time ranges that your computer was turned on ...
	echo %DATE% %TIME% - Acquiring time ranges that your computer was turned on ... >> %_LOG%
	turnedontimesview /scomma %_SYSTEM_DIR%\turnedontimesview.csv
	echo %DATE% %TIME% - Acquiring last activity on this system ...
	echo %DATE% %TIME% - Acquiring last activity on this system ... >> %_LOG%
	lastactivityview /scomma %_SYSTEM_DIR%\lastactivityview.csv
	echo %DATE% %TIME% - Acquiring a list of programs and batch files that you previously executed ...
	echo %DATE% %TIME% - Acquiring a list of programs and batch files that you previously executed ... >> %_LOG%
	executedprogramslist /scomma %_SYSTEM_DIR%\executedprogramslist.csv
	echo %DATE% %TIME% - Acquiring list of files that you previously opened with the standard open/save dialog-box ...
	echo %DATE% %TIME% - Acquiring list of files that you previously opened with the standard open/save dialog-box ... >> %_LOG%
	opensavefilesview /scomma %_SYSTEM_DIR%\opensavefilesview.csv
	echo %DATE% %TIME% - Acquiring information about all programs installed on your system ...
	echo %DATE% %TIME% - Acquiring information about all programs installed on your system ... >> %_LOG%
	uninstallview /scomma %_SYSTEM_DIR%\uninstallview.csv
	echo %DATE% %TIME% - Acquiring user log on/log off ...
	echo %DATE% %TIME% - Acquiring user log on/log off ... >> %_LOG%
	winlogonview /scomma %_SYSTEM_DIR%\winlogonview.csv
	echo %DATE% %TIME% - Acquiring the list of all software packages installed on your system with Windows Installer ...
	echo %DATE% %TIME% - Acquiring the list of all software packages installed on your system with Windows Installer ... >> %_LOG%
	installedpackagesview /scomma %_SYSTEM_DIR%\installedpackagesview.csv
	echo %DATE% %TIME% - Acquiring the list of all registered dll/ocx/exe files (COM registration) ...
	echo %DATE% %TIME% - Acquiring the list of all registered dll/ocx/exe files (COM registration) ... >> %_LOG%
	regdllview /scomma %_SYSTEM_DIR%\regdllview.csv
	echo %DATE% %TIME% - Acquiring all search queries with the most popular search engines (Google, Yahoo and MSN) and with popular social networking sites (Twitter, Facebook, MySpace) ...
	echo %DATE% %TIME% - Acquiring all search queries with the most popular search engines (Google, Yahoo and MSN) and with popular social networking sites (Twitter, Facebook, MySpace) ... >> %_LOG%
	mylastsearch /scomma %_SYSTEM_DIR%\mylastsearch.csv
	echo %DATE% %TIME% - Acquiring the history data of different Web browsers (Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera) ...
	echo %DATE% %TIME% - Acquiring the history data of different Web browsers (Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera) ... >> %_LOG%
	browsinghistoryview /HistorySource 1 /VisitTimeFilterType 1 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /LoadSafari 1 /scomma %_SYSTEM_DIR%\browsinghistoryview.csv

:: NETWORK INTERFACE INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # NETWORK INTERFACE INFORMATION           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _INTERFACE_DIR=%_VOLATILE_DIR%\interface_information
	mkdir %_INTERFACE_DIR%
	echo.
	echo # START ACQUIRING INTERFACE INFORMATION
	echo Created "interface_information" directory in %_VOLATILE_DIR%\
	echo Created "interface_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring promiscuous mode information ...
	echo %DATE% %TIME% - Acquiring promiscuous mode information ... >> %_LOG%
	promiscdetect > %_INTERFACE_DIR%\promiscdetect.txt
	echo %DATE% %TIME% - Acquiring detaild information for each interface ...
	echo %DATE% %TIME% - Acquiring detaild information for each interface ... >> %_LOG%
	ipconfig /all > %_INTERFACE_DIR%\ipconfig_all.txt 
	echo %DATE% %TIME% - Acquiring contents of the DNS resolver cache ...
	echo %DATE% %TIME% - Acquiring contents of the DNS resolver cache ... >> %_LOG%
	ipconfig /displaydns > %_INTERFACE_DIR%\ipconfig_displaydns.txt 
	echo %DATE% %TIME% - Acquiring MAC address for each interface ...
	echo %DATE% %TIME% - Acquiring MAC address for each interface ... >> %_LOG%
	getmac > %_INTERFACE_DIR%\getmac.txt 
	echo %DATE% %TIME% - Acquiring list of all network interfaces ...
	echo %DATE% %TIME% - Acquiring list of all network interfaces ... >> %_LOG%
	networkinterfacesview /stext %_INTERFACE_DIR%\networkinterfacesview.txt
	echo %DATE% %TIME% - Acquiring list of all network interfaces ...
	echo %DATE% %TIME% - Acquiring list of all network interfaces ... >> %_LOG%
	wifiinfoview /scomma %_INTERFACE_DIR%\wifiinfoview.csv

:: PASSWORD
	echo ----------------------------------------- >> %_LOG%
	echo # STORED PASSWORD INFORMATION             >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _PASSWORD_DIR=%_VOLATILE_DIR%\password_information
	mkdir %_PASSWORD_DIR%
	echo.
	echo # START ACQUIRING PASSWORD INFORMATION
	echo Created "password_information" directory in %_VOLATILE_DIR%\
	echo Created "password_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring passwords stored by Internet Explorer ...
	echo %DATE% %TIME% - Acquiring passwords stored by Internet Explorer ... >> %_LOG%
	iepv /stext %_PASSWORD_DIR%\iepv.txt
	echo %DATE% %TIME% - Acquiring passwords stored by Chrome ...
	echo %DATE% %TIME% - Acquiring passwords stored by Chrome ... >> %_LOG%
	chromepass.exe /stext %_PASSWORD_DIR%\chromepass.txt
	echo %DATE% %TIME% - Acquiring passwords stored by Firefox ...
	echo %DATE% %TIME% - Acquiring passwords stored by Firefox ... >> %_LOG%
	passwordfox.exe /stext %_PASSWORD_DIR%\passwordfox.txt
	echo %DATE% %TIME% - Acquiring password for various email clients ...
	echo %DATE% %TIME% - Acquiring password for various email clients ... >> %_LOG%
	mailpv /stext %_PASSWORD_DIR%\mailpv.txt
	echo %DATE% %TIME% - Acquiring passwords stored behind the bullets in the standard password text-box ...
	echo %DATE% %TIME% - Acquiring passwords stored behind the bullets in the standard password text-box ... >> %_LOG%
	bulletspassview /stext %_PASSWORD_DIR%\bulletspassview.txt
	echo %DATE% %TIME% - Acquiring network passwords stored on your system for the current logged-on user ...
	echo %DATE% %TIME% - Acquiring network passwords stored on your system for the current logged-on user ... >> %_LOG%
	netpass /stext %_PASSWORD_DIR%\netpass.txt
	echo %DATE% %TIME% - Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ...
	echo %DATE% %TIME% - Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ... >> %_LOG%
	webbrowserpassview /scomma %_PASSWORD_DIR%\webbrowserpassview.csv
	echo %DATE% %TIME% - Acquiring all wireless network security keys/passwords (WEP/WPA) ...
	echo %DATE% %TIME% - Acquiring all wireless network security keys/passwords (WEP/WPA) ... >> %_LOG%
	wirelesskeyview /stext %_PASSWORD_DIR%\wirelesskeyview.txt
	echo %DATE% %TIME% - Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ...
	echo %DATE% %TIME% - Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ... >> %_LOG%
	rdpv /stext %_PASSWORD_DIR%\rdpv.txt
	echo %DATE% %TIME% - Acquiring passwords from instant messenger applications ...
	echo %DATE% %TIME% - Acquiring passwords from instant messenger applications ... >> %_LOG%
	mspass.exe /stext %_PASSWORD_DIR%\messengerpass.txt

:: MISCs
	echo ----------------------------------------- >> %_LOG%
	echo # MISCs                                   >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _MISC_DIR=%_VOLATILE_DIR%\misc_information
	mkdir %_MISC_DIR%
	echo.
	echo # START ACQUIRING MISCELLANEOUS INFORMATION
	echo Created "misc_information" directory in %_VOLATILE_DIR%\
	echo Created "misc_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring all Web browser addons/plugins ...
	echo %DATE% %TIME% - Acquiring all Web browser addons/plugins ... >> %_LOG%
	browseraddonsview /scomma %_MISC_DIR%\browseraddonsview.csv
	echo %DATE% %TIME% - Acquiring list of all tasks from the Task Scheduler ...
	echo %DATE% %TIME% - Acquiring list of all tasks from the Task Scheduler ... >> %_LOG%
	taskschedulerview /scomma %_MISC_DIR%\taskschedulerview.csv
	echo %DATE% %TIME% - Acquiring schedule tasks ...
	echo %DATE% %TIME% - Acquiring schedule tasks ... >> %_LOG%
	at > %_MISC_DIR%\at.txt 
	echo %DATE% %TIME% - Acquiring detailed property list for all tasks ...
	echo %DATE% %TIME% - Acquiring detailed property list for all tasks ... >> %_LOG%
	schtasks /query /fo list /v > %_MISC_DIR%\schtasks_query_fo_list_v.txt 
	echo %DATE% %TIME% - Acquiring clipboard text ...
	echo %DATE% %TIME% - Acquiring clipboard text ... >> %_LOG%
	pclip > %_MISC_DIR%\pclip.txt
	echo %DATE% %TIME% - Acquiring autoruns information ...
	echo %DATE% %TIME% - Acquiring autoruns information ... >> %_LOG%
	autorunsc /accepteula > %_MISC_DIR%\autorunsc.txt


:: -----------------------------------------------------
:: Acquire NON-VOLATILE data
:: -----------------------------------------------------
if /i "%_IS_NONVOLATILE%" == "N" GOTO:PACKET
	echo.
	echo ## START ACQUIRING NON-VOLATILE

:: MBR (Master Boot Record)
	set _MBR=%_NONVOLATILE_DIR%\mbr
	mkdir %_MBR%
	echo ----------------------------------------- >> %_LOG%
	echo # MBR                                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring MBR ...
	echo %DATE% %TIME% - Acquiring MBR ... >> %_LOG%
	dd if=\\.\PhysicalDrive0 of=%_MBR%\MBR bs=512 count=1
	
:: VBR (Volume Boot Record)
	set _VBR=%_NONVOLATILE_DIR%\vbr
	mkdir %_VBR%
	echo ----------------------------------------- >> %_LOG%
	echo # VBR                                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring VBR ...
	echo %DATE% %TIME% - Acquiring VBR ... >> %_LOG%
	forecopy_handy -f %SystemDrive%\$Boot %_VBR%
	
:: $MFT
	echo ----------------------------------------- >> %_LOG%
	echo # $MFT                                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring $MFT ...
	echo %DATE% %TIME% - Acquiring $MFT ... >> %_LOG%
	forecopy_handy -m %_NONVOLATILE_DIR%

:: $LogFile
	set _FSLOG=%_NONVOLATILE_DIR%\fslog
	mkdir %_FSLOG%
	echo ----------------------------------------- >> %_LOG%
	echo # $LogFile                                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring $LogFile ...
	echo %DATE% %TIME% - Acquiring $LogFile ... >> %_LOG%
	forecopy_handy -f %SystemDrive%\$LogFile %_FSLOG%
	
:: REGISTRY
	echo ----------------------------------------- >> %_LOG%
	echo # REGISTRY                                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Registry Hives ...
	echo %DATE% %TIME% - Acquiring Registry Hives ... >> %_LOG%
	forecopy_handy -g %_NONVOLATILE_DIR%

:: EVENT LOGS
	echo ----------------------------------------- >> %_LOG%
	echo # EVENT LOGS                              >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Event Logs ...
	echo %DATE% %TIME% - Acquiring Event Logs ... >> %_LOG%
	forecopy_handy -e %_NONVOLATILE_DIR%

:: RECENT LNKs and JUMPLIST
	echo ----------------------------------------- >> %_LOG%
	echo # RECENT FOLDER                           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Recent LNKs and JumpLists ...
	echo %DATE% %TIME% - Acquiring Recent LNKs and JumpLists ... >> %_LOG%
	forecopy_handy -r "%AppData%\microsoft\windows\recent" %_NONVOLATILE_DIR%

:: SYSTEM32/drivers/etc files
	echo ----------------------------------------- >> %_LOG%
	echo # system32/drivers/etc                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring system32/drivers/etc ...
	echo %DATE% %TIME% - Acquiring system32/drivers/etc ... >> %_LOG%
	forecopy_handy -t %_NONVOLATILE_DIR%
	
:: systemprofile (\Windows\system32\config\systemprofile)
	echo ----------------------------------------- >> %_LOG%
	echo # system32/config/systemprofile           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring system32/config/systemprofile ...
	echo %DATE% %TIME% - Acquiring system32/config/systemprofile ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %_NONVOLATILE_DIR%

:: IE Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # IE Artifacts                            >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring IE Artifacts ...
	echo %DATE% %TIME% - Acquiring IE Artifacts ... >> %_LOG%
	forecopy_handy -i %_NONVOLATILE_DIR%
	
:: Firefox Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # Firefox Artifacts                       >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Firefox Artifacts ...
	echo %DATE% %TIME% - Acquiring Firefox Artifacts ... >> %_LOG%
	forecopy_handy -x %_NONVOLATILE_DIR%	

:: Chrome Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # Chrome Artifacts                        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Chrome Artifacts ...
	echo %DATE% %TIME% - Acquiring Chrome Artifacts ... >> %_LOG%
	forecopy_handy -c %_NONVOLATILE_DIR%
	
:: IconCache
	set _ICONCACHE=%_NONVOLATILE_DIR%\iconcache
	mkdir %_ICONCACHE%
	echo ----------------------------------------- >> %_LOG%
	echo # IconCache                               >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring IconCache.db ...
	echo %DATE% %TIME% - Acquiring IconCache.db ... >> %_LOG%
	forecopy_handy -f %LocalAppData%\IconCache.db %_ICONCACHE%	
	
:: Thumbcache
	echo ----------------------------------------- >> %_LOG%
	echo # Thumbcache                              >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Thumbcache_###.db ...
	echo %DATE% %TIME% - Acquiring Thumbcache_###.db ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\microsoft\windows\explorer" %_NONVOLATILE_DIR%	
	
:: Downloaded Program Files
	echo ----------------------------------------- >> %_LOG%
	echo # Downloaded Program Files                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Downloaded Program Files ...
	echo %DATE% %TIME% - Acquiring Downloaded Program Files ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\Downloaded Program Files" %_NONVOLATILE_DIR%	
	
:: Java IDX cache
	echo ----------------------------------------- >> %_LOG%
	echo # Java IDX Cache                          >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Java IDX Cache ...
	echo %DATE% %TIME% - Acquiring Java IDX Cache ... >> %_LOG%
	forecopy_handy -r "%UserProfile%\AppData\LocalLow\Sun\Java\Deployment" %_NONVOLATILE_DIR%	
	
:: WER (Windows Error Reporting)
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Error Reporting                 >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Error Reporting ...
	echo %DATE% %TIME% - Acquiring Windows Error Reporting ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\Microsoft\Windows\WER" %_NONVOLATILE_DIR%
	
:: Windows Timeline
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Timeline                        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Timeline ...
	echo %DATE% %TIME% - Acquiring Windows Timeline ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\ConnectedDevicesPlatform" %_NONVOLATILE_DIR%
	
:: Windows Search Database
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Search Database                 >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Search Database ...
	echo %DATE% %TIME% - Acquiring Windows Search Database ... >> %_LOG%
	forecopy_handy -r "%ProgramData%\Microsoft\Search\Data\Applications\Windows" %_NONVOLATILE_DIR%

:: Calculate MD5
	::echo %DATE% %TIME% - Calculating MD5 values of acquiring files ...
	::echo %DATE% %TIME% - Calculating MD5 values of acquiring files ... >> %_LOG%
	::set _MD5=%_TARGET_DIR%\MD5.log
	::echo The md5 values of acquiring files > %_MD5%
	::echo ****************************************************** >> %_MD5%
	::md5deep -r %_TARGET_DIR% >> %_MD5%


:: -----------------------------------------------------
:: END
:: -----------------------------------------------------
:END
echo END TIME : %DATE% %TIME% >> %_LOG%
echo.
echo It's done!
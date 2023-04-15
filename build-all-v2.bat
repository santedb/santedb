@echo off
setlocal EnableExtensions


set shouldexit=0
set branchBuild=%2
set version=%1
set output="%cd%\dist\%version%"

if exist %output% (
	rmdir /s /q %output%
	mkdir %output%
)

set configuration=Release
set third_party="%cd%\third-party"
echo Determing Toolchain Environment
set netstandardopt=
set netopt=
set keepbuild=
set addlcerts=
set pubassets=
set partial_build=
set build_icdr=
set build_sdk=
set build_dcg=
set build_core=
set build_mpi=
set build_applets=
set build_www=
set build_dcdr=

for %%P in (%*) do (
	
	if [%%P] == [help] (
		echo Use: build-all.bat VERSION BRANCH [options] [projects]
		echo Example: build-all.bat 2.6 version/2.0
		echo Build Options:
		echo    nosign    -	Don't append digital signatures to the outputs
		echo    notag     -	Don't create a version tag in GIT
		echo    sign      -	Sign with a custom key
		echo    pubnuget  -	Publish packages to nuget
		echo    debug     -	Build in DEBUG mode
		echo    nodocker  -	Do not build the docker containers
		echo    keepbuild -	Keep the temporary build directory
		echo Projects:
		echo    icdr      - 	Build iCDR Server
		echo    dcg	      -	Build Disconnected Gateway
		echo    www       -	Build the WWW server
		echo    core      -	Build the core APIs
		echo    sdk	      -	Build the SDK
		echo    applets   -	Build applets
		echo    mpi	      -	Build SanteMPI
		echo    dcdr      - Build dCDR APIs
		goto :end
	)
	if [%%P] == [nosign] (
		set nosign=1
	)
	if [%%P] == [icdr] (
		set partial_build=1
		set build_core=1
		set build_icdr=1
	)
	if [%%P] == [dcg] (
		set partial_build=1
		set build_core=1
		set build_dcg=1
		set build_dcdr=1
	)
	if [%%P] == [www] (
		set build_core=1
		set partial_build=1
		set build_www=1
		set build_dcdr=1
	)
	if [%%P] == [core] (
		set partial_build=1
		set build_core=1
	)
	if [%%P] == [sdk] (
		set partial_build=1
		set build_core=1
		set build_sdk=1
		set build_dcdr=1
	)
	if [%%P] == [applets] (
		set partial_build=1
		set build_applets=1
	)
	if [%%P] == [mpi] (
		set partial_build=1
		set build_core=1
		set build_icdr=1
		set build_mpi=1
	)
	if [%%P] == [dcdr] (
		set partial_build=1
		set build_dcdr=1
	)
	if [%%P] == [notag] (
		set notag=1
	)
	if [%%P] == [sign] (
		set /p signkey=Enter the hash for your signing key:
	)
	if [%%P] == [pubnuget] (
		set /p nugetkey=Enter your nuget key:
	)
	if [%%P] == [debug] (
		set configuration=Debug
	)
	if [%%P] == [nodocker] (
		set nodocker=1
	)
	if [%%P] == [keepbuild] (
		set keepbuild=1
	)
	if [%%P] == [pubassets] (
		set /p pubassets=Enter publish location for help:
		set /p pubassetsuser=Enter user to publish for help:
	)
)

if [%partial_build%] == [] (
	set build_icdr=1
	set build_dcg=1
	set build_www=1
	set build_core=1
	set build_sdk=1
	set build_mpi=1
	set build_applets=1
	set build_dcdr=1
	
)

if [%zip%]==[] (
	if exist "C:\program files\7-zip\7z.exe" (
		set zip="C:\program files\7-zip\7z.exe"
	) else (
		echo Unable to find 7-zip - install it or set the zip environment variable
		set shouldexit=1
	)
)
if [%msbuild%] == [] (
	if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MsBuild.exe" (
	        	echo will use VS 2022 Pro build tools
        		set msbuild="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin"
	) else (
		if exist "c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin\MSBuild.exe" (
	        	echo will use VS 2019 Community build tools
        		set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin"
		) else ( 
			if exist "c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
        			set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin"
	        		echo will use VS 2019 Pro build tools
			) else (
				echo Unable to locate VS 2019 or 2022 build tools, will use default build tools on path
				set shouldexit=1
			)
		)
	)
)

if [%pakman%]==[] (
	if exist "c:\Program Files\SanteSuite\SanteDB\SDK\pakman.exe" (
		set pakman="c:\Program Files\SanteSuite\SanteDB\SDK\pakman.exe"
	) else ( 
		echo Can't find PAKMAN from SanteDB SDK set the pakman variable manually
		set shouldexit=1
	)
)

if [%inno%] == [] (
	if exist "c:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
		set inno="c:\Program Files (x86)\Inno Setup 6\ISCC.exe"
	) else (
		if exist "c:\Program Files (x86)\Inno Setup 5\ISCC.exe" (
			set inno="c:\Program Files (x86)\Inno Setup 5\ISCC.exe"
		) else (
			echo Can't Find INNO Setup Tools set inno environment variable manually
			set shouldexit=1
		)
	)
)

if [%signtool%] == [] (
	if exist "C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe" (
		set signtool="C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe"
	) else (
		echo Can't find signtool.exe set signtool environment variable manually
		set shouldexit=1
	)
)

if [%nuget%] == [] (
	if exist "%cd%\.nuget\nuget.exe" (
		set nuget="%cd%\.nuget\nuget.exe"
	) else (
		echo Can't find NUGET.EXE specify it with nuget parameter
		set shouldexit=1
	)
)

if [%version%]==[] (
	echo Must specify version number as first parameter to this script
	set shouldexit=1
)

if [%branchBuild%]==[] (
	echo No branch specified setting branch to DEVELOP
	set branchBuild=develop
)

if exist "%cd%\inter.cer" (
	set addlcerts=%cd%\inter.cer
)

if not exist "%third_party%\SqlCipher.dll" (
	echo Missing %third_party%\SqlCipher.dll - Please compile SQLCipher and place in this location - build from C++ from https://github.com/santedb/SqlCipher-Amalgamated
	set shouldexit=1
)

if not exist "%third_party%\netfx.exe" (
	echo Missing %third_party%\netfx.exe - Please obtain .NET Redistributable and place in this location https://dotnet.microsoft.com/download/dotnet-framework/thank-you/net472-web-installer
	set shouldexit=1
)

if not exist "%third_party%\vc2010.exe" (
	echo Missing %third_party%\vc2010.exe - Please obtain Visual C++ 2010 redistributable https://download.microsoft.com/download/A/8/0/A80747C3-41BD-45DF-B505-E9710D2744E0/vcredist_x64.exe
	set shouldexit=1
)

if not exist "%third_party%\vcredist_x86.exe" (
	echo Missing %third_party%\vcredist_x86.exe - Please obtain Visual C++ 2015/2017/2019 Common Redistributable and place at this location https://aka.ms/vs/16/release/vc_redist.x86.exe
	set shouldexit=1
)

if not exist "%third_party%\dos2unix.exe" (
	echo Mssing %third_party%\dos2unix.exe - Please obtain the DOS2UNIX binary from https://waterlan.home.xs4all.nl/dos2unix.html#DOS2UNIX
	set shouldexit=1
)

if [%shouldexit%] == [1] (
	echo Please correct issues and re-run
	goto :end
)

if [%commkey%] == [] (
	set commkey=f3bea1ee156254656669f00c03eeafe8befc4441
)

set target=NugetRelease
if [%configuration%] == [Debug] (
	set target=NugetStaging
	set nosign=1
	set notag=1
	set nodocker=1
	set netstandardopt=--include-symbols
	set netopt=-symbols
)

echo ========= Build Settings =============
echo Mode = %configuration%
echo Version = %version%
echo From Branch = %branchBuild%
echo Output = %output%
echo Special netstandard options = %netstandardopt%
echo Special net options = %netopt%

if [%nosign%] == [1] (
	echo Sign = DISABLED
) else (
	echo Sign = ENABLED
	echo Vendor Key = %signkey% - set from signkey environment variable
	echo Community Key = %commkey%
	echo Additional Certificate Chain = %addlcerts% (set from inter.cer file)
)
if ([%nodocker%] == [1] (
	echo Docker = DISABLED
)
if [%notag%] == [1] (
	echo Tagging = DISABLED
) else (
	echo Tagging = ENABLED
	echo Tag Release = v%version%
)
echo ========= TOOLCHAIN ===========
echo MSBUILD = %msbuild%
echo INNO SETUP = %inno%
echo SIGNTOOL = %signtool%
echo SanteDB SDK PAKMAN = %pakman%
echo Nuget Path = %nuget%
echo 7-zip = %zip%
echo ----------------------
echo ENSURE NUGET HAS A LOCAL PACKAGE REPOSITORY %localappdata%\%target% BEFORE YOU CONTINUE
echo ----------------------
echo ===== PROJECTS TO BUILD ======
if [%build_core%] == [1] (
	echo * CORE APIs
)
if [%build_sdk%] == [1] (
	echo * SDK
)	
if [%build_icdr%] == [1] (
	echo * iCDR
)
if [%build_mpi%] == [1] (
	echo * SanteMPI
)
if [%build_dcg%] == [1] (
	echo * Disconnected Gateway
)
if [%build_www%] == [1] (
	echo * WWW Service
)
if [%build_applets%] == [1] (
	echo * Applets
)
if [%build_dcdr%] == [1] (
	echo * dCDR
)

echo Confirm Build Settings (CTRL+C to cancel)
pause
echo Will build release of SanteDB (entire Suite)

rem ------------------------------ CREATE BUILD DIRECTORY 
set "buildPath=%tmp%\sdb~%RANDOM%"
echo Will build in %buildPath%
if not exist "%buildPath%" (
	mkdir %buildPath%
)

pushd "%buildPath%"
echo Cleaning SanteDB NUGET Release Directory
rmdir /s /q "%localappdata%\%target%"
echo Creating SanteDB NUGET Release Directory at %localappdata%\%target%
mkdir "%localappdata%\%target%"

if [%build_core%] == [1] (
	echo Building Core FROM %cd%
	call :SUB_DO_BUILD_CORE
)
if [%build_applets%] == [1] (
	echo Building Applets FROM %cd%
	call :SUB_DO_BUILD_APPLETS
)
if [%build_sdk%] == [1] (
	echo Building SDK FROM %cd%
	call :SUB_DO_BUILD_SDK
)
if [%build_icdr%] == [1] (
	echo Building Server FROM %cd%
	call :SUB_DO_BUILD_SERVER
)
if [%build_mpi%] == [1] (
	echo Building MPI FROM %cd%
	call :SUB_DO_BUILD_SANTEMPI
)
if [%build_www%] == [1] (
	echo Building WWW FROM %cd%
	call :SUB_DO_BUILD_WWW
)
popd 

rem Publishing
if [%pubassets%]==[] (
	echo Won't Publish Assets
) else (
	pushd %output% 
	pushd ..
	scp -r %version% %pubassetsuser%@%pubassets%:/var/www/html/santesuite/org/prod/assets/uploads/santedb/community/releases/
	popd
	popd
)
goto :end


rem ----------------------------- START BUILD WEB DCDR
:SUB_DO_BUILD_WWW

echo Cloning SanteDB WWW
git clone https://github.com/santedb/santedb-www
pushd santedb-www
git checkout %branchBuild%


copy "%third_party%\SqlCipher.dll" ".\Solution Items\SQLCipher.dll"
copy "%third_party%\vcredist_x86.exe" ".\installsupp\vcredist_x86.exe"
copy "%third_party%\netfx.exe" ".\installsupp\netfx.exe"

call :SUB_NETBUILD santedb-www.sln

call :SUB_BUILD_INSTALLER santedb-www.iss
copy installsupp\install.sh bin\Release
copy %addlcerts% bin\Release\inter.cer

call :SUB_BUILD_TARBALL santedb-www bin\Release

call :SUB_SIGNASM_SDB_COMM SanteDB SanteMPI SanteGuard
call :SUB_BUILD_DOCKER santedb-www

exit /B

rem ----------------------------- START SANTEMPI SERVER BUILD
:SUB_DO_BUILD_SANTEMPI

echo Cloning SanteMPI project
git clone https://github.com/santedb/santempi
pushd santempi
git checkout %branchBuild%

git submodule init
git submodule update --remote

echo %version% > release-version

call :SUB_BUILD_APPLET applet org.santedb.smpi
if [%nosign%] == [1] (
	%pakman% --compose --version=%version% --source=santempi.sln.xml -o "%output%\applets\sln\santempi.sln.pak" 
) else (
	%pakman% --compose --version=%version% --source=santempi.sln.xml -o "%output%\applets\sln\santempi.sln.pak"  --embedcert --sign --certHash=%commkey% 
)

call :SUB_NETBUILD santempi.sln

if not exist "dist" (
	mkdir dist
)

mkdir bin\Release\matching
copy SanteMPI\match\DefaultPatientMatching.xml bin\Release\matching
copy %output%\applets\sln\santempi.sln.pak .\dist\

call :SUB_BUILD_INSTALLER install\santempi-install.iss

if not exist "bin\Release\dist" (
	mkdir bin\Release\dist
)

copy dist\santempi.sln.pak bin\Release\applets
xcopy ..\santedb-server\bin\Release\*.* bin\Release /S /Y
copy %output%\applets\sln\santedb.core.sln.pak bin\release\applets /y
copy %output%\applets\sln\santedb.admin.sln.pak bin\release\applets /y
copy %output%\applets\sln\santempi.sln.pak bin\release\applets /y

call :SUB_BUILD_TARBALL santempi bin\Release


rem We re-sign for docker since mono doesn't have all authenticode certs
call :SUB_SIGNASM_SDB_COMM SanteDB SanteMPI SanteGuard
call :SUB_BUILD_DOCKER santedb-mpi

popd
exit /B


rem ----------------------------- START SANTEDB SERVER BUILD
:SUB_DO_BUILD_SERVER

echo Cloning Server project
git clone https://github.com/santedb/santedb-server
pushd santedb-server
git checkout %branchBuild%

git submodule init
git submodule update --remote

for /D %%G in (.\*) do (
	pushd %%G
	if exist ".git" (
		echo Pulling %branchBuild% on %%G
		git checkout %branchBuild%
		git pull
	)
	popd
)
	
copy %third_party%\netfx.exe ".\installer\netfx.exe"
copy %third_party%\vc2010.exe ".\installer\vc2010.exe"

copy %output%\applets\sln\santedb.core.sln.pak SanteDB\Applets /y
copy %output%\applets\sln\santedb.admin.sln.pak SanteDB\Applets /y

echo %version% > release-version
call :SUB_NETBUILD santedb-server-ext.sln

call :SUB_BUILD_INSTALLER installer\santedb-icdr.iss
call :SUB_BUILD_INSTALLER installer\sdbac.iss


echo Copying LINUX Install Script
copy .\installer\install.sh bin\Release\install.sh
copy %addlcerts% bin\Release\inter.cer
call :SUB_BUILD_TARBALL santedb-server bin\Release


mkdir "sdbac-tmp"
copy "%cd%\bin\release\MohawkCollege.Util.Console.Parameters.dll" "sdbac-tmp"
copy "%cd%\bin\release\Newtonsoft.Json.dll" "sdbac-tmp"
copy "%cd%\bin\release\RestSrvr.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Configuration.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Core.Api.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Core.Applets.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Core.Model.AMI.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Core.Model.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Docker.Core.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Messaging.AMI.Client.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Messaging.HDSI.Client.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Rest.Common.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Server.AdminConsole.Api.dll" "sdbac-tmp"
copy "%cd%\bin\release\SanteDB.Server.Core.dll" "sdbac-tmp"
copy "%cd%\bin\release\sdbac.exe" "sdbac-tmp"
copy "%cd%\bin\release\sdbac.exe.config" "sdbac-tmp"
copy "%cd%\bin\release\SharpCompress.dll" "sdbac-tmp"
copy "%cd%\bin\release\System.Buffers.dll" "sdbac-tmp"
copy "%cd%\bin\release\System.Collections.Concurrent.dll" "sdbac-tmp"
copy "%cd%\bin\release\System.Collections.dll" "sdbac-tmp"
copy "%cd%\bin\release\System.Memory.dll" "sdbac-tmp"
copy "%cd%\bin\release\System.Runtime.CompilerServices.Unsafe.dll" "sdbac-tmp"
call :SUB_BUILD_TARBALL sdbac sdbac-tmp

pushd santedb-docker
pushd SanteDB.Docker.Server
call :SUB_SIGNASM_SDB_COMM SanteDB SanteMPI SanteGuard
pushd bin
pushd release
ren Data data
popd
popd
call :SUB_BUILD_DOCKER santedb-icdr
popd
popd
popd
exit /B


rem ----------------------------- START SANTEDB SDK BUILD
:SUB_DO_BUILD_SDK

echo Cloning SDK project
git clone https://github.com/santedb/santedb-sdk
pushd santedb-sdk
git checkout %branchBuild%

git submodule init
git submodule update --remote

for /D %%G in (.\*) do (
	pushd %%G
	if exist ".git" (
		echo Pulling %branchBuild% on %%G
		git checkout %branchBuild%
		git pull
	)
	popd
)

copy %third_party%\SqlCipher.dll ".\Solution Items\SQLCipher.dll"
copy %third_party%\vcredist_x86.exe ".\tools\vcredist_x86.exe"

echo %version% > release-version
call :SUB_NETBUILD santedb-sdk-ext.sln

rem Copy applet files
copy %output%\applets\*.pak bin\Release /y
copy %output%\applets\sln\*.pak bin\Release /y
call :SUB_BUILD_INSTALLER santedb-sdk.iss
call :SUB_BUILD_TARBALL santedb-sdk bin\Release

popd
exit /B


rem ----------------------------- START SANTEDB CORE API BUILD
:SUB_DO_BUILD_CORE 
echo Cloning core project
git clone https://github.com/santedb/santedb

pushd santedb
git checkout %branchBuild%
git submodule init
git submodule update --remote

echo Building RestSrvr

pushd restsrvr
call :SUB_NETSTANDARD_BUILD RestSrvr
popd 


echo Building SanteDB i18n
pushd santedb-i18n
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.i18n"
popd 

echo Building SanteDB Model
pushd santedb-model
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Model"
popd 

echo Building SanteDB API
pushd santedb-api
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Api" "SanteDB.Core.TestFramework"
popd 

echo Building SanteDB Docker Core
pushd santedb-docker
call :SUB_NETSTANDARD_BUILD "SanteDB.Docker.Core"
popd 

echo Building SanteDB Applet Core
pushd santedb-applets
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Applets"
popd 

echo Building SanteDB Rest-Service Core
pushd santedb-restsvc
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Model.AMI" "SanteDB.Core.Model.HDSI" "SanteDB.Core.Model.ViewModelSerializers" "SanteDB.Rest.Common" "SanteDB.Rest.AMI" "SanteDB.Rest.HDSI" "SanteDB.Rest.WWW"
popd 

echo Building JavaScript BRE
pushd santedb-bre-js
call :SUB_NETSTANDARD_BUILD "SanteDB.BusinessRules.JavaScript"
popd

echo Building FHIR Module
pushd santedb-fhir
call :SUB_NETSTANDARD_BUILD "SanteDB.Messaging.FHIR"
popd

echo Build MDM Module
pushd santedb-mdm
call :SUB_NETSTANDARD_BUILD "SanteDB.Persistence.MDM"
popd

echo Building HL7 Module
pushd santedb-hl7
call :SUB_NETSTANDARD_BUILD "SanteDB.Messaging.HL7"
popd

echo Building OpenAPI Module
pushd santedb-openapi
call :SUB_NETSTANDARD_BUILD "SanteDB.Messaging.OpenAPI"
popd

echo Building BIS Module
pushd santedb-bis
call :SUB_NETSTANDARD_BUILD "SanteDB.BI" "SanteDB.Rest.BIS"
popd

echo Build ORM Module
pushd santedb-orm
call :SUB_NETSTANDARD_BUILD "SanteDB.OrmLite"
popd

echo Building Data Persistence Modules
pushd santedb-data
call :SUB_NETSTANDARD_BUILD "SanteDB.Persistence.Data" "SanteDB.Persistence.Auditing.ADO" "SanteDB.Persistence.PubSub.ADO" "SanteDB.Core.TestFramework.FirebirdSQL" "SanteDB.Core.TestFramework.SQLite"
popd

echo Build SanteDB CDSS Module
pushd santedb-cdss
call :SUB_NETSTANDARD_BUILD "SanteDB.Cdss.Xml"
popd

echo Build SanteDB Client APIS
pushd santedb-client
call :SUB_NETSTANDARD_BUILD "SanteDB.Messaging.AMI.Client" "SanteDB.Messaging.HDSI.Client"
popd

echo Build SanteDB REDIS Cache
pushd santedb-cache-redis
call :SUB_NETSTANDARD_BUILD "SanteDB.Caching.Redis"
popd

echo Build SanteDB MEM Cache
pushd santedb-cache-memory
call :SUB_NETSTANDARD_BUILD "SanteDB.Caching.Memory"
popd

echo Build SanteDB Match Module
pushd santedb-match
call :SUB_NETSTANDARD_BUILD "SanteDB.Matcher"
popd

if [%build_dcdr%] == [1] (
	echo Building dCDR APIs
	pushd santedb-dc-core
	call :SUB_NETSTANDARD_BUILD "SanteDB.DisconnectedClient.i18n" "SanteDB.DisconnectedClient.Core" "SanteDB.DisconnectedClient.Core.SQLite" "SanteDB.DisconnectedClient.Ags" "SanteDB.DisconnectedClient.UI"
	popd
)

if [%pubassets%] == [] (
	echo Not Publishing Help!
) else (
	pushd Help
	dotnet build santedb.shfbproj  --configuration %configuration% /p:VersionNumber=%version%
	if exist "output\index.html" (
		pushd output
		scp -r * %pubassetsuser%@%pubassets%:/var/www/html/santesuite/org/prod/assets/doc/net
		popd
	)
	popd
)

popd

exit /B

rem ----------------------------- BUILD CORE APPLETS
:SUB_DO_BUILD_APPLETS

git clone https://github.com/santedb/applets
pushd applets
git checkout %branchBuild%
echo Building Core Applets in %cd%

pushd locales
for /D %%G in (.\*) do (
	call :SUB_BUILD_APPLET %%G org.santedb.i18n.%%~nxG
)
popd 

for /D %%G in (.\*) do (
	call :SUB_BUILD_APPLET %%G org.santedb.%%~nxG
)
	
if not exist "%output%\applets\sln" (
	mkdir "%output%\applets\sln"
)

if [%nosign%] == [1] (
	%pakman% --compose --source=santedb.core.sln.xml --version=%version% -o "%output%\applets\sln\santedb.core.sln.pak" 
	%pakman% --compose --source=santedb.admin.sln.xml --version=%version% -o "%output%\applets\sln\santedb.admin.sln.pak" 
) else (
	%pakman% --compose --source=santedb.core.sln.xml --version=%version% -o "%output%\applets\sln\santedb.core.sln.pak" --sign --certHash=%commkey% --embedcert
	%pakman% --compose --source=santedb.admin.sln.xml --version=%version% -o "%output%\applets\sln\santedb.admin.sln.pak" --sign --certHash=%commkey% --embedcert
)

call :SUB_GIT_TAG

rem out of applets
popd

if exist "santedb" (
	pushd santedb
	pushd santedb-hl7
	pushd SanteDB.Messaging.HL7
	call :SUB_BUILD_APPLET applet org.santedb.hl7
	popd
	popd
	pushd santedb-fhir
	pushd SanteDB.Messaging.FHIR
	call :SUB_BUILD_APPLET applet org.santedb.fhir
	popd
	popd
	popd
)

exit /B

:SUB_BUILD_DOCKER

echo Will build docker container %1 from %cd%
set pkgname=%1

if [%nodocker%] == [1] (
	echo DOCKER BUILDS DISABLED
) else (
	docker build --no-cache -t santesuite/%pkgname%:%version% .
	docker build --no-cache -t santesuite/%pkgname% .
)

exit /B

:SUB_BUILD_TARBALL

echo Will build tarballs %1 from %cd%\%2
set pkgname=%1

mkdir "%pkgname%-%version%"
copy "%2\*.dll" "%pkgname%-%version%" /y
copy "%2\*.exe" "%pkgname%-%version%" /y
copy "%2\*.pak" "%pkgname%-%version%" /y
copy "%2\*.xml" "%pkgname%-%version%" /y
copy "%2\*.bat" "%pkgname%-%version%" /y
copy "%2\*.sh" "%pkgname%-%version%" /y
copy "%2\*.fdb" "%pkgname%-%version%" /y
copy "%2\*.cer" "%pkgname%-%version%" /y

copy "%2\lib\win32\x86\git2-106a5f2.dll" "%pkgname%-%version%" /y
xcopy /I /S  /Y "%2\Schema\*.*" "%pkgname%-%version%\schema"
xcopy /I /S /Y "%2\Config\*.*" "%pkgname%-%version%\config"
xcopy /I  /S /Y "%2\Sample\*.*" "%pkgname%-%version%\sample"
xcopy /I /S /Y "%2\Engine\*.*" "%pkgname%-%version%\engine"
xcopy /I /S /Y "%2\Sample\*.*" "%pkgname%-%version%\sample"
xcopy /I /S /Y "%2\plugins\*.*" "%pkgname%-%version%\plugins"
xcopy /I /S /Y "%2\matching\*.*" "%pkgname%-%version%\matching"
xcopy /I /S /Y "%2\data\*.*" "%pkgname%-%version%\data"
xcopy /I /S /Y "%2\applets\*.*" "%pkgname%-%version%\applets"

move %pkgname%-%version%\Data %pkgname%-%version%\_data
move %pkgname%-%version%\_data %pkgname%-%version%\data

move %pkgname%-%version%\Config %pkgname%-%vesion%\_config
move %pkgname%-%version%\_config %pkgname%-%vesion%\config

FOR /R "%pkgname%-%version%" %%G IN (*.sh) DO (
	echo Converting line endings in %%G
	"%third_party%\dos2unix.exe" "%%G"
)


%zip% a -r -ttar "%output%\%pkgname%-%version%.tar" "%pkgname%-%version%"
%zip% a -r -tzip "%output%\%pkgname%-%version%.zip" "%pkgname%-%version%"
%zip% a -tbzip2 "%output%\%pkgname%-%version%.tar.bz2" "%output%\%pkgname%-%version%.tar"
%zip% a -tgzip "%output%\%pkgname%-%version%.tar.gz" "%output%\%pkgname%-%version%.tar"

rmdir /s /q %pkgname%-%version%
exit /B

:SUB_BUILD_INSTALLER

echo Will build installer using %1 in %cd%

%inno% "/o%output%\" "%1" /d"MyAppVersion=%version%"

exit /B

:SUB_BUILD_APPLET

echo Building applet in %1 as %2
pushd %1
if not exist "%output%\applets" (
	mkdir "%output%\applets"
)

if exist "manifest.xml" (
	if [%nosign%] == [1] (
		%pakman% --compile --source=.\ --version=%version% --optimize --output="%output%\applets\%2.pak" --install 
	) else ( 
		%pakman% --compile --source=.\ --version=%version% --optimize --output="%output%\applets\%2.pak" --sign --certHash=%commkey% --embedcert --install 
	)
)
popd

exit /B 

:SUB_NETSTANDARD_BUILD 

echo Build in %cd% the projects %1
call :SUB_PRE_BUILD
for %%P IN (%*) do (
	if exist %%P (
		pushd %%P
		echo Will build project in %cd%
		call :SUB_NETSTANDARD_BUILD_PROJ
		call :SUB_SIGNASM SanteDB SanteMPI SanteGuard
		call :SUB_NETSTANDARD_PACK
		popd 
	) else (
		echo No directory for %%P in %cd%
	)
)
call :SUB_GIT_TAG
set proj=
exit /B

:SUB_PRE_BUILD
echo Preparing assets : LICENSE, NOTICE, etc. for %cd%

git checkout %branchbuild%
git pull

copy ..\LICENSE /y
copy ..\License.rtf /y
copy ..\SanteDB.licenseheader /y

exit /B

:SUB_NETSTANDARD_BUILD_PROJ

echo Building %cd% 

dotnet restore /p:VersionNumber=%version%
dotnet build --configuration %configuration% /p:VersionNumber=%version%

exit /B


:SUB_NETBUILD

echo Build in %cd% the solution %1

git checkout %branchbuild%
git pull

call :SUB_NETBUILD_PROJ %1
call :SUB_SIGNASM SanteDB SanteMPI SanteGuard

FOR /R "%cd%" %%G IN (*.nuspec) DO (
	echo Packing NUGET module %%~pG
	pushd "%%~pG"
	call :SUB_NETPACK %%G
	popd
)


call :SUB_GIT_TAG

exit /B


:SUB_NETBUILD_PROJ

echo Building .NET Framework Project %1
%msbuild%\msbuild %1 /t:clean /p:VersionNumber=%version%
%msbuild%\msbuild %1 /t:restore /p:VersionNumber=%version%
%msbuild%\msbuild %1 /t:rebuild /p:configuration=%configuration% /m:1 /p:VersionNumber=%version%

exit /B

:SUB_SIGNASM

if [%nosign%] == [] (
	if [%signkey%]==[] (
		call :SUB_SIGNASM_SDB_COMM %*
	) else (
		for %%P IN (%*) do (
			if exist "..\bin" (
				for /R "..\bin" %%Q IN (%%P*.dll) DO (
					echo Signing %%Q with vendor key
					if [%addlcerts%] == [] (
						%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
					) else (
						echo Signing with additional certs from %addlcerts%
						%signtool% sign /sha1 %signkey% /ac "%addlcerts%" /d "SanteDB Core APIs"  "%%Q" 
					)
				)
				for /R "..\bin" %%Q IN (*.exe) DO (
					echo Signing %%Q with vendor key
					if [%addlcerts%] == [] (
						%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
					) else (
						echo Signing with additional certs from %addlcerts%
						%signtool% sign /sha1 %signkey% /ac "%addlcerts%" /d "SanteDB Core APIs"  "%%Q"
					)
				)
			) else (
				for /R ".\bin" %%Q IN (%%P*.dll) DO (
					echo Signing %%Q with vendor key
					if [%addlcerts%] == [] (
						%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
					) else (
						echo Signing with additional certs from %addlcerts%
						%signtool% sign /sha1 %signkey% /ac "%addlcerts%" /d "SanteDB Core APIs"  "%%Q"
					)
				)
				for /R ".\bin" %%Q IN (*.exe) DO (
					echo Signing %%Q with vendor key
					if [%addlcerts%] == [] (
						%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
					) else (
						echo Signing with additional certs from %addlcerts%
						%signtool% sign /sha1 %signkey% /ac "%addlcerts%" /d "SanteDB Core APIs"  "%%Q"
					)
				)
			)
		)
	)
)

exit /B

rem Sign Assembly with Community Certificate
:SUB_SIGNASM_SDB_COMM

if [%nosign%] == [] (
	for %%P IN (%*) do (
		if exist "..\bin" (
			for /R "..\bin" %%Q IN (%%P*.dll) DO (
				echo Signing %%Q with community key
				%signtool% sign /sha1 %commkey% /d "SanteDB Core APIs"  "%%Q"
			)
			for /R "..\bin" %%Q IN (*.exe) DO (
				echo Signing %%Q with community key
				%signtool% sign /sha1 %commkey% /d "SanteDB"  "%%Q"
			)
		) else (
			for /R ".\bin" %%Q IN (%%P*.dll) DO (
				echo Signing %%Q with community key
				%signtool% sign /sha1 %commkey% /d "SanteDB APIs"  "%%Q"
			)
			for /R ".\bin" %%Q IN (*.exe) DO (
				echo Signing %%Q with community key
				%signtool% sign /sha1 %commkey% /d "SanteDB"  "%%Q"
			)
		)
	)
)
exit /B

:SUB_NETSTANDARD_PACK

echo Packing %cd% to %localappdata%\%target%

dotnet pack --no-build --configuration %configuration% --output "bin\publish"  /p:VersionNumber=%version% %netstandardopt%
copy bin\publish\*.nupkg "%localappdata%\%target%"
copy bin\publish\*.snupkg "%localappdata%\%target%"

if not exist "%output%\nuget" (
	mkdir "%output%\nuget"
)
copy bin\publish\*.nupkg "%output%\nuget"
copy bin\publish\*.snupkg "%output%\nuget"

if [%nugetkey%]==[] (
	echo Will not push to NUGET if you want to push to NUGET set nugetkey environment variable
) else (
	echo Publishing NUPKG
	for /R %%F IN (*.nupkg) DO (
		 dotnet nuget push "%%F" -s https://api.nuget.org/v3/index.json -k %nugetkey%
	)
) 
			
exit /B

:SUB_NETPACK

echo Packing %cd% to %localappdata%\%target%

%nuget% pack -OutputDirectory "bin\Publish" -prop Configuration=%configuration%  -msbuildpath %msbuild% -prop VersionNumber=%version% %netopt%
copy bin\publish\*.nupkg "%localappdata%\%target%"
copy bin\publish\*.snupkg "%localappdata%\%target%"

if not exist "%output%\nuget" (
	mkdir "%output%\nuget"
)
copy bin\publish\*.nupkg "%output%\nuget"
copy bin\publish\*.snupkg "%output%\nuget"

if [%nugetkey%]==[] (
	echo Will not push to NUGET if you want to push to NUGET set nugetkey environment variable
) else (
	FOR /R %%F IN (*.nupkg) do (
		%nuget% push "%%F" -Source https://api.nuget.org/v3/index.json -ApiKey %nugetkey%
	)
) 

exit /B

:SUB_GIT_TAG

if [%notag%] == [] (
	if [%branchBuild%] == [master] (
		git tag %version%
		git push --tags
	) else (
		echo Will merge %branchBuild% to master at %cd%
		git checkout %branchBuild%
		git pull
		echo %version% > release-version
		echo ^<Project^>^<PropertyGroup^>^<VersionNumber^>%version%^<^/VersionNumber^>^<^/PropertyGroup^>^<^/Project^> > Directory.Build.props
		git add *
		git commit -am "BuildBot: Added release version"
		git push
		git checkout master
		git merge %branchBuild% 
		git checkout --theirs *
		git add *
		git commit -am "BuildBot: Merged from %branchBuild% for release of version %version%"
		git tag v%version% -m "BuildBot: Version %version% release"
		git push
		git push --tags
		git checkout %branchBuild%
	)
) else (
	echo ------ MERGING and TAGGING DISABLED
)
exit /B
:end 

if [%keepbuild%] == [1] (
	echo Build is kept at %buildPath%
) else (
	if exist "%buildPath%" (
		echo Cleaning up build directory %buildPath%
		popd
		popd
		popd
		rmdir /s /q "%buildPath%"
	)
)

echo Build Release Complete
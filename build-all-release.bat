@echo off
setlocal EnableExtensions


set shouldexit=0
set branchBuild=%2
set version=%1
set signkey=%3
set output="%cd%\dist\%version%"
set third_party="%cd%\third-party"
echo Determing Toolchain Environment

for %%P in (%*) do (
	
	if [%%P] == [nosign] (
		set nosign=1
	)
	if [%%P] == [notag] (
		set notag=1
	)
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
	if exist "c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin\MSBuild.exe" (
			set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin"
	) else ( 
		if exist "c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
				set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin"
		) else (
			echo Unable to locate VS 2019 build tools, set msbuild environment variable manually
			set shouldexit=1
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
	if exist "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64\signtool.exe" (
		set signtool="C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64\signtool.exe"
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

if not exist "%third_party%\SqlCipher.dll" (
	echo Missing %third_party%\SqlCipher.dll - Please compile SQLCipher and place in this location
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

if [%shouldexit%] == [1] (
	echo Please correct issues and re-run
	goto :end
)

if [%commkey%] == [] (
	set commkey=f3bea1ee156254656669f00c03eeafe8befc4441
)

echo ========= Build Settings =============
echo Version = %version%
echo From Branch = %branchBuild%
echo Output = %output%
if [%nosign%] == [1] (
	echo Sign = DISABLED
) else (
	echo Sign = ENABLED
	echo Vendor Key = %signkey%
	echo Community Key = %commkey%
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
echo ENSURE NUGET HAS A LOCAL PACKAGE REPOSITORY %localappdata%\NugetRelease BEFORE YOU CONTINUE
echo ----------------------
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
rmdir /s /q "%localappdata%\NugetRelease"
echo Creating SanteDB NUGET Release Directory at %localappdata%\NugetRelease
mkdir "%localappdata%\NugetRelease"

echo Building Core FROM %cd%
call :SUB_DO_BUILD_CORE
echo Building Applets FROM %cd%
call :SUB_DO_BUILD_APPLETS
echo Building SDK FROM %cd%
call :SUB_DO_BUILD_SDK
echo Building Server FROM %cd%
call :SUB_DO_BUILD_SERVER
echo Building Server FROM %cd%
call :SUB_DO_BUILD_SANTEMPI
popd 

goto :end


rem ----------------------------- START SANTEMPI SERVER BUILD
:SUB_DO_BUILD_SANTEMPI

echo Cloning SanteMPI project
git clone https://github.com/santedb/santempi
pushd santempi
git checkout %branchBuild%

git submodule init
git submodule update --remote

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

copy %output%\applets\sln\santempi.sln.pak .\dist\

call :SUB_BUILD_INSTALLER install\santempi-install.iss
call :SUB_BUILD_TARBALL santempi bin\Release


rem We re-sign for docker since mono doesn't have all authenticode certs
call :SUB_SIGNASM_SDB_COMM
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

copy %third_party%\netfx.exe ".\installer\netfx.exe"
copy %third_party%\vc2010.exe ".\installer\vc2010.exe"

copy %output%\applets\sln\*.pak SanteDB\Applets /y

call :SUB_NETBUILD santedb-server-ext.sln

call :SUB_BUILD_INSTALLER installer\santedb-icdr.iss
call :SUB_BUILD_TARBALL santedb-server bin\Release

pushd santedb-docker
pushd SanteDB.Docker.Server
call :SUB_SIGNASM_SDB_COMM
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

copy %third_party%\SqlCipher.dll ".\Solution Items\SQLCipher.dll"
copy %third_party%\vcredist_x86.exe ".\tools\vcredist_x86.exe"

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

echo Building SanteDB Model
pushd santedb-model
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Model"
popd 

echo Building SanteDB API
pushd santedb-api
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Api"
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
call :SUB_NETSTANDARD_BUILD "SanteDB.Core.Model.AMI","SanteDB.Core.Model.HDSI" "SanteDB.Core.Model.ViewModelSerializers" "SanteDB.Rest.Common" "SanteDB.Rest.AMI" "SanteDB.Rest.HDSI"
popd 

echo Building JavaScript BRE
pushd santedb-bre-js
call :SUB_NETSTANDARD_BUILD "SanteDB.BusinessRules.JavaScript"
popd

echo Building FHIR Module
pushd santedb-fhir
call :SUB_NETSTANDARD_BUILD "SanteDB.Messaging.FHIR"
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

echo Build MDM Module
pushd santedb-mdm
call :SUB_NETSTANDARD_BUILD "SanteDB.Persistence.MDM"
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

echo Building dCDR APIs
pushd santedb-dc-core
call :SUB_NETSTANDARD_BUILD "SanteDB.DisconnectedClient.i18n" "SanteDB.DisconnectedClient.Core" "SanteDB.DisconnectedClient.Core.SQLite" "SanteDB.DisconnectedClient.Ags" "SanteDB.DisconnectedClient.UI"
popd

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

popd

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

exit /B

:SUB_BUILD_DOCKER

echo Will build docker container %1 from %cd%
set pkgname=%1

docker build --no-cache -t santesuite/%pkgname%:%version% .
docker build --no-cache -t santesuite/%pkgname% .

exit /B

:SUB_BUILD_TARBALL

echo Will build tarballs %1 from %cd%\%2
set pkgname=%1

mkdir "%pkgname%-%version%"
copy "%2\*.dll" "%pkgname%-%version%" /y
copy "%2\*.exe" "%pkgname%-%version%" /y
copy "%2\*.pak" "%pkgname%-%version%" /y
copy "%2\*.xml" "%pkgname%-%version%" /y
copy "%2\*.fdb" "%pkgname%-%version%" /y
copy "%2\lib\win32\x86\git2-106a5f2.dll" "%pkgname%-%version%" /y
xcopy /I /Y "%2\Schema\*.*" "%pkgname%-%version%\Schema"
xcopy /I /Y "%2\Config\*.*" "%pkgname%-%version%\Config"
xcopy /I /Y "%2\Sample\*.*" "%pkgname%-%version%\Sample"
xcopy /I /Y "%2\Engine\*.*" "%pkgname%-%version%\Engine"
xcopy /I /Y "%2\Sample\*.*" "%pkgname%-%version%\Sample"
xcopy /I /Y "%2\plugins\*.*" "%pkgname%-%version%\plugins"
xcopy /I /Y "%2\matching\*.*" "%pkgname%-%version%\matching"
xcopy /I /Y "%2\data\*.*" "%pkgname%-%version%\data"
xcopy /I /Y "%2\applets\*.*" "%pkgname%-%version%\applets"

%zip% a -r -ttar "%output%\%pkgname%-%version%.tar" "%pkgname%-%version%"
%zip% a -r -tzip "%output%\%pkgname%-%version%.zip" "%pkgname%-%version%"
%zip% a -tbzip2 "%output%\%pkgname%-%version%.tar.bz2" "%output%\%pkgname%-%version%.tar"
%zip% a -tgzip "%output%\%pkgname%-%version%.tar.gz" "%output%\%pkgname%-%version%.tar"

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
		call :SUB_SIGNASM
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
dotnet build --configuration Release /p:VersionNumber=%version%

exit /B


:SUB_NETBUILD

echo Build in %cd% the solution %1

git checkout %branchbuild%
git pull

call :SUB_NETBUILD_PROJ %1
call :SUB_SIGNASM SanteDB

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
%msbuild%\msbuild %1 /t:rebuild /p:configuration=Release /m:1 /p:VersionNumber=%version%

exit /B

:SUB_SIGNASM

if [%nosign%] == [] (
	if [%signkey%]==[] (
		call :SUB_SIGNASM_SDB_COMM %1
	) else (
		if exist "..\bin" (
			for /R "..\bin\Release" %%Q IN (%1*.dll) DO (
				echo Signing %%Q with vendor key
				%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
			)
		) else (
			for /R ".\bin\Release" %%Q IN (%1*.dll) DO (
				echo Signing %%Q with vendor key
				%signtool% sign /sha1 %signkey% /d "SanteDB Core APIs"  "%%Q"
			)
		)
	)
)

exit /B

rem Sign Assembly with Community Certificate
:SUB_SIGNASM_SDB_COMM

if [%nosign%] == [] (
	if exist "..\bin" (
		for /R "..\bin\Release" %%Q IN (%1*.dll) DO (
			echo Signing %%Q with community key
			%signtool% sign /sha1 %commkey% /d "SanteDB Core APIs"  "%%Q"
		)
	) else (
		for /R ".\bin\Release" %%Q IN (%1*.dll) DO (
			echo Signing %%Q with community key
			%signtool% sign /sha1 %commkey% /d "SanteDB Core APIs"  "%%Q"
		)
	)
)
exit /B

:SUB_NETSTANDARD_PACK

echo Packing %cd% to %localappdata%\NugetRelease

del bin\publish\*.nupkg /S /Q
dotnet pack --no-build --configuration Release --output "bin\publish"  /p:VersionNumber=%version%
copy bin\publish\*.nupkg "%localappdata%\NugetRelease"

if not exist "%output%\nuget" (
	mkdir "%output%\nuget"
)
copy bin\publish\*.nupkg "%output%\nuget"

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

echo Packing %cd% to %localappdata%\NugetRelease

%nuget% pack -OutputDirectory "bin\Publish" -prop Configuration=Release  -msbuildpath %msbuild% -prop VersionNumber=%version%
copy bin\publish\*.nupkg "%localappdata%\NugetRelease"

if not exist "%output%\nuget" (
	mkdir "%output%\nuget"
)
copy bin\publish\*.nupkg "%output%\nuget"

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
		git add *
		git commit -am "Release %version% built from %branchBuild%"
		git checkout master
		git merge %branchBuild%
		git tag v%version% -m "Version %version% release"
		git push
		git push --tags
		git checkout %branchBuild%
	)
) else (
	echo ------ MERGING and TAGGING DISABLED
)
exit /B
:end 

if exist "%buildPath%" (
	echo Cleaning up build directory %buildPath%
	rmdir /s /q "%buildPath%"
)

echo Build Release Complete
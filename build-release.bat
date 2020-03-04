@echo off
echo Will build and push NUGET

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe" (
        echo will use VS 2017 Enterprise build tools
        set msbuild="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin"
) else (
	if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" (
        	echo will use VS 2017 Professional build tools
	        set msbuild="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin"
	) else (
		if exist "c:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" (
	        	echo will use VS 2017 Community build tools
        		set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
		) else ( 
			if exist "c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
        			set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin"
	        		echo will use VS 2019 Pro build tools
			) else (
				echo Unable to locate VS 2017 or 2019 build tools, will use default build tools 
			)
		)
	)
)

rem delete existing packages 
del *.nupkg /s /q

if [%1] == [] (
	echo Must specify version number
	goto end
)

if defined msbuild (
	echo "Will release %1"
	if exist "%cd%\.nuget\nuget.exe" (
		set nuget="%cd%\.nuget\nuget.exe"
	)
	if defined nuget  (
	echo Will use NUGET %nuget%
	echo Will use MSBUILD in %msbuild%

	if exist "%nuget%" (
	FOR %%P IN (restsrvr,santedb-model,santedb-api,santedb-applets,santedb-restsvc,santedb-bre-js,santedb-bis,santedb-orm,santedb-cdss,santedb-client,reportr,santedb-match,santedb-dc-core) DO (
if exist "%%P" (
		pushd "%%P"
		echo Preparing assets : LICENSE, NOTICE, etc.
		copy ..\LICENSE /y
		copy ..\License.rtf /y
		echo Building %%P

		IF EXIST ".git" (
			git checkout master
			git pull
		)

		FOR %%G IN (*.sln) DO (
			echo Building %%~pG 
			pushd "%%~pG"
			%msbuild%\msbuild "%%G" /t:restore /t:rebuild /p:configuration=Release /m
			popd
		)

		FOR /R %%G IN (*.nuspec) DO (
			echo Packing %%~pG
			pushd "%%~pG"
			if exist "packages.config" (
				%nuget% restore -SolutionDirectory ..\  -msbuildpath %msbuild%
			)
			if [%2] == [] (
				%nuget% pack -OutputDirectory "%localappdata%\NugetRelease" -prop Configuration=Release -msbuildpath %msbuild%
			) else (
				echo Publishing NUPKG
				%nuget% pack -prop Configuration=Release 
				FOR /R %%F IN (*.nupkg) do (
					 %nuget% push "%%F" -Source https://api.nuget.org/v3/index.json -ApiKey %2 
				)
			) 
			popd
		)

		IF EXIST ".git" (
			ECHO Pushing %%G
			git add *
			git commit -am "Release of version %1"
			git tag -a v%1 -m "Release of version %1"
			git push
			git push --tags
		)	
		popd
	)
	)
)
)	
)


:end
@echo off

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

if defined msbuild (
	if exist "%cd%\.nuget\nuget.exe" (
		set nuget="%cd%\.nuget\nuget.exe"
	)
	if defined nuget  (
	echo Will use NUGET %nuget%
	echo Will use MSBUILD in %msbuild%

	if exist "%nuget%" (
	FOR %%P IN (restsrvr, santedb-model,santedb-api,santedb-applets,santedb-bre-js,santedb-restsvc,santedb-bis,santedb-orm,santedb-cdss,santedb-client,reportr,santedb-match,santedb-dc-core) DO (
		echo Building %%P
		pushd "%%P"

		FOR /R %%G IN (*.sln) DO (
			echo Entering %%~pG
			pushd "%%~pG"
			echo Now in %cd%
			%msbuild%\msbuild "%%G" /t:restore /t:rebuild /p:configuration=Debug  /m
			popd
		)

		FOR /R %%G IN (*.nuspec) DO (
			echo Packing %%~pG
			pushd "%%~pG"
			if exist "packages.config" (
				%nuget% restore -SolutionDirectory ..\
			)
			%nuget% pack -OutputDirectory "%localappdata%\NugetStaging" -prop Configuration=Debug -Symbols -msbuildpath %msbuild%
			popd
		)	
		popd
	)
	)
)	
)

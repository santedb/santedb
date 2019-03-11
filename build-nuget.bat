@echo off

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe" (
        echo will use VS 2017 build tools
        set msbuild="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
) else (
	if exist "c:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" (
        echo will use VS 2017 build tools
        set msbuild="c:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
	) else ( echo Unable to locate VS 2017 build tools, will use default build tools )
)

if defined msbuild (
	if exist "%cd%\.nuget\nuget.exe" (
		set nuget="%cd%\.nuget\nuget.exe"
	)
	if defined nuget  (
	echo Will use NUGET %nuget%
	echo Will use MSBUILD in %msbuild%

	if exist "%nuget%" (
	FOR %%P IN (restsrvr, santedb-model,santedb-api,santedb-applets,santedb-bre-js,santedb-orm,santedb-cdss,santedb-restsvc,santedb-client,reportr,santedb-dc-core) DO (
		echo Building %%P
		pushd %%P

		FOR /R %%G IN (*.sln) DO (
			echo Building %%~pG 
			pushd %%~pG
			%msbuild% %%G /t:restore /t:rebuild /p:configuration=Release /m
			popd
		)

		FOR /R %%G IN (*.nuspec) DO (
			echo Packing %%~pG
			pushd %%~pG
			if exist "packages.config" (
				%nuget% restore -SolutionDirectory ..\
			)
			if [%1] == [] (
				%nuget% pack -OutputDirectory %localappdata%\NugetStaging -prop Configuration=Release 
			) else (
				echo Publishing NUPKG
				%nuget% pack -prop Configuration=Release 
				FOR /R %%F IN (*.nupkg) do (
					%nuget% push %%F -Source https://api.nuget.org/v3/index.json -ApiKey %1
				)
			) 
			popd
		)	
		popd
	)
	)
)	
)

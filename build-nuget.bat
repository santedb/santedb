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
	set nuget="%cd%\.nuget\nuget.exe"
	echo Will use NUGET %nuget%
	echo Will use MSBUILD in %msbuild%

	FOR %%P IN (santedb-model,santedb-api,santedb-applets,santedb-bre-js,santedb-orm,santedb-cdss,santedb-client,reportr,santedb-dc-core) DO (
		echo Building %%P
		pushd %%P

		FOR /R %%G IN (*.sln) DO (
			echo Building %%~pG 
			pushd %%~pG
			%msbuild% %%G /t:restore /p:configuration=release /m
			%msbuild% %%G /t:rebuild /p:configuration=release /m
			popd
		)

		FOR /R %%G IN (*.nuspec) DO (
			echo Packing %%~pG
			pushd %%~pG
			if exist "packages.config" (
				%nuget% restore -SolutionDirectory ..\
			)
			%nuget% pack -OutputDirectory %localappdata%\NugetStaging -prop Configuration=Release
			popd
		)	
		popd
	)

)

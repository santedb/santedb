@ECHO OFF
DEL *.nuspec /S /Q
FOR %%P IN (restsrvr,santedb-model,santedb-api,santedb-applets,santedb-restsvc,santedb-bre-js,santedb-bis,santedb-orm,santedb-cdss,santedb-client,reportr,santedb-match,santedb-dc-core) DO (
	IF EXIST "%%P" (
		
		ECHO Packaging %%P
		PUSHD "%%P"
		
		FOR /R %%G IN (*.csproj) DO (
			ECHO Entering %%~pG
			PUSHD "%%~pG"
			dotnet pack --output "%localappdata%\NugetStaging" --configuration DEBUG --include-symbols 
			POPD
		)
		POPD

	)
)

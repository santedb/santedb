@echo off
echo Will build and push NUGET

FOR %%P IN (restsrvr,santedb-model,santedb-api,santedb-applets,santedb-restsvc,santedb-bre-js,santedb-bis,santedb-orm,santedb-cdss,santedb-client,reportr,santedb-match,santedb-dc-core) DO (
	IF EXIST "%%P" (
		PUSHD "%%P"
		ECHO Preparing assets : LICENSE, NOTICE, etc.
		COPY ..\LICENSE /y
		COPY ..\License.rtf /y
		ECHO Building %%P

		IF EXIST ".git" (
			git checkout master
			git pull
		)

		FOR /R %%G IN (*.csproj) DO (
			ECHO Packing %%~pG
			PUSHD "%%~pG"
				ECHO Publishing NUPKG
				DEL bin\publish\*.nupkg /S /Q
				dotnet pack --configuration Release --output "bin\publish"
				FOR /R %%F IN (*.nupkg) DO (
					 dotnet nuget push "%%F" -s github-santedb  --skip-duplicate --no-symbols true
				)
			POPD
		)

		
		POPD
	)
)

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
			git pull
		)

		FOR /R %%G IN (*.csproj) DO (
			ECHO Packing %%~pG
			PUSHD "%%~pG"

			IF [%2] == [] (
				dotnet pack --output "%localappdata%\NugetRelease" --configuration Release 
			) ELSE (
				ECHO Publishing NUPKG
				DEL bin\publish\*.nupkg /S /Q
				dotnet pack --configuration Release --output "bin\publish" 
				FOR /R %%F IN (*.nupkg) DO (
					 dotnet nuget push "%%F" -s https://api.nuget.org/v3/index.json -k %2 
				)
			) 
			POPD
		)

		IF EXIST ".git" (
			ECHO Pushing %%G
			git add *
			git commit -am "Release of version %1"
			git push
			git checkout master
			git pull
			git merge develop
			git tag -a v%1 -m "Release of version %1"
			git push
			git push --tags
			git checkout develop
		)	
		POPD
	)
)

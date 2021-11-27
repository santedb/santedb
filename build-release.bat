@echo off
echo Will build and push NUGET
set signtool="C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64\signtool.exe"

FOR %%P IN (restsrvr,santedb-model,santedb-api,santedb-docker,santedb-applets,santedb-restsvc,santedb-bre-js,santedb-mdm,santedb-fhir,santedb-hl7,santedb-openapi,santedb-bis,santedb-orm,santedb-cdss,santedb-client,santedb-cache-memory,santedb-cache-redis,santedb-cache-redis,reportr,santedb-match,santedb-dc-core) DO (
	IF EXIST "%%P" (
		PUSHD "%%P"
		ECHO Preparing assets : LICENSE, NOTICE, etc.
		COPY ..\LICENSE /y
		COPY ..\License.rtf /y
		COPY ..\SanteDB.licenseheader /y
		ECHO Building %%P

		IF EXIST ".git" (
			git pull
		)

		FOR /R %%G IN (*.csproj) DO (
			ECHO Packing %%~pG
			PUSHD "%%~pG"
			dotnet restore /p:VersionNumber=%1
			dotnet build --configuration Release /p:VersionNumber=%1
			echo Signing Assemblies in %%~pP
			IF EXIST "..\bin" (
				FOR /R "..\bin\Release" %%Q IN (SanteDB.*.dll) DO (
					echo Signing %%Q
					%signtool% sign /sha1 a11164321e30c84bd825ab20225421434622c52a /d "SanteDB Core APIs"  "%%Q"
				)
			) ELSE (
				FOR /R ".\bin\Release" %%Q IN (SanteDB.*.dll) DO (
					echo Signing %%Q
					%signtool% sign /sha1 a11164321e30c84bd825ab20225421434622c52a /d "SanteDB Core APIs"  "%%Q"
				)
			)
			echo Signature Complete

			IF [%2] == [] (
				dotnet pack --no-build --output "%localappdata%\NugetRelease" --configuration Release /p:VersionNumber=%1
			) ELSE (
				ECHO Publishing NUPKG
				DEL bin\publish\*.nupkg /S /Q
				dotnet pack --no-build --configuration Release --output "bin\publish"  /p:VersionNumber=%1
				copy bin\publish\*.nupkg "%localappdata%\NugetRelease"
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

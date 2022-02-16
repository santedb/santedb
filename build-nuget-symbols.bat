@ECHO OFF
DEL *.nuspec /S /Q
FOR %%P IN (restsrvr,santedb-model,santedb-api,santedb-docker,santedb-applets,santedb-restsvc,santedb-bre-js,santedb-fhir,santedb-mdm,santedb-hl7,santedb-openapi,santedb-bis,santedb-orm,santedb-cdss,santedb-client,santedb-cache-memory,santedb-cache-redis,santedb-cache-redis,reportr,santedb-match,santedb-dc-core) DO (
	IF EXIST "%%P" (
		
		ECHO Packaging %%P
		PUSHD "%%P"
		rem echo ^<Project^>^<PropertyGroup^>^<VersionNumber^>%1^<^/VersionNumber^>^<^/PropertyGroup^>^<^/Project^> > Directory.Build.props

		FOR /R %%G IN (*.csproj) DO (
			ECHO Entering %%~pG
			PUSHD "%%~pG"
			IF [%1] == []  (
				dotnet pack --output "%localappdata%\NugetStaging" --configuration DEBUG --include-symbols
			) ELSE (
				echo Building as %1
				dotnet pack --output "%localappdata%\NugetStaging" --configuration DEBUG --include-symbols /p:VersionNumber=%1
			)
			POPD
		)
		POPD

	)
)

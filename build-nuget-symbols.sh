#!/bin/bash

echo Building Modules
for D in {"restsrvr","santedb-model","santedb-api","santedb-applets","santedb-bre-js","santedb-bis","santedb-orm","santedb-cdss","santedb-restsvc","santedb-client","reportr","santedb-match","santedb-dc-core"}; do 
	echo "Entering ${D}"
	if [ -d "${D}" ]; then
		cd "${D}"
		
		dotnet pack --output "." --configuration DEBUG --include-symbols 
		mv *.nupkg ~/.nugetstaging
		mv *.snupkg ~/.nugetstaging
	

		cd ..

	fi
done

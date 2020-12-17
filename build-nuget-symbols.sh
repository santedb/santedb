#!/bin/bash

echo Building Modules
for D in {"restsrvr","santedb-model","santedb-api","santedb-applets","santedb-bre-js","santedb-bis","santedb-orm","santedb-cdss","santedb-restsvc","santedb-client","reportr","santedb-match","santedb-dc-core"}; do 
	echo "Entering ${D}"
	if [ -d "${D}" ]; then
		cd "${D}"

		
		for S in *.sln; do
			if [ -f "${S%.sln}-linux.sln" ]; then
				dotnet pack "${S%.sln}-linux.sln" --output "../../SanteDBNugetLocal" --configuration DEBUG --include-symbols
			else
		 		dotnet pack "${S}" --output "../../SanteDBNugetLocal" --configuration DEBUG --include-symbols 
			fi
			break
		done
	

		cd ..

	fi
done

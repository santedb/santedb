#!/bin/bash

echo Building Modules
for D in {"restsrvr","santedb-model","santedb-api","santedb-applets","santedb-bre-js","santedb-orm","santedb-cdss","santedb-restsvc","santedb-client","reportr","santedb-dc-core"}; do 
	echo "${D}"
	if [ -d "${D}" ]; then
		cd "${D}"
		
		for S in *.sln; do
			if [ -f "${S%.sln}-linux.sln" ]; then
				msbuild "${S%.sln}-linux.sln" /t:restore /t:rebuild /p:Configuration=Debug /m
			else 
				msbuild "${S}" /t:restore /t:rebuild /p:Configuration=Debug /m 
			fi
		done 

		# build nuget
		for S in *; do
			if [ -d "${S}" ]; then
				cd "${S}"
				
				for N in *.nuspec; do
					if [ -f "${N}" ]; then
						nuget pack -OutputDirectory ~/.nugetstaging -prop Configuration=Debug -Symbols
					fi 
				done 

				cd ..
			fi 
		done
		cd ..
	fi
done

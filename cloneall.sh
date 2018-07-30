#!/bin/bash
echo "Cloning Projects..."
git clone https://github.com/santedb/applets
git clone https://github.com/santedb/reportr
git clone https://github.com/santedb/santedb
git clone https://github.com/santedb/santedb-api
git clone https://github.com/santedb/santedb-applets
git clone https://github.com/santedb/santedb-bre-js
git clone https://github.com/santedb/santedb-cdss
git clone https://github.com/santedb/santedb-client
git clone https://github.com/santedb/santedb-dc-core
git clone https://github.com/santedb/santedb-model
git clone https://github.com/santedb/santedb-orm
git clone https://github.com/santedb/santedb-sdk
git clone https://github.com/santedb/santedb-server

echo Initializing submodules
for D in *; do 
	if [ -d "${D}" ]; then
		cd "${D}"
		if [ -f .gitmodules ]; then
			git submodule init
			git submodule update --remote
			for S in *; do
				if [ -d "${S}" ]; then
					cd "${S}"
					if [ -f .git ]; then
						git checkout master
						git pull
					fi
					cd ..
				fi
			done 
		fi
		cd ..
	fi
done

@echo off

cd ..
echo Cloning Projects to parent directory %cd%
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
git clone https://github.com/santedb/santedb-match

echo Initializing submodules
for /D %%D in (.\*) do (
	pushd %%D
	if exist ".gitmodules" (
		echo Initialize Submodules for %%d
		git submodule init
		git submodule update --remote
		for /D %%S in (.\*) do (
			pushd %%S
			if exist ".git" (
				echo Setting branch for %%s
				git checkout master
				git pull
			)
			popd
		)
	)
	popd
)

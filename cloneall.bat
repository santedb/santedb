@echo off

cd ..
echo Cloning Projects to parent directory %cd%
git clone https://github.com/santedb/applets
git clone https://github.com/santedb/santedb-sdk
git clone https://github.com/santedb/santedb-server
git clone https://github.com/santedb/santedb-www
git clone https://github.com/santedb/santedb-dcg
git clone https://github.com/santedb/santempi

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

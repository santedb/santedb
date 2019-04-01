@ECHO OFF
	ECHO WILL UNDO SUBMODULES
	SET cwd = %cd%
	FOR /D %%G IN (.\*) DO (
		PUSHD %%G
		IF EXIST ".git" (
			ECHO Pulling %%G
			git checkout -- *
			git pull
		)
		POPD
	)

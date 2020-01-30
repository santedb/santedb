@echo off
setlocal EnableExtensions enabledelayedexpansion

set search=%1
set replace=%2

echo Transitioning vesions from %1 to %2
for %%f in (.nuspec,.csproj,AssemblyInfo.cs)  DO (
	for /R "." %%j in (*%%f) do (
	    if x%%j:git==x%%j  (
		    echo Skipping %%j
	    ) else (
		
			if exist %%j (
				echo Processing %%j
				for /f "delims=" %%i in ('type "%%~j" ^& break ^> "%%~j"') do (
					set "line=%%i"
				    setlocal EnableDelayedExpansion
					set "line=!line:%search%=%replace%!"
					>>"%%~j" echo(!line!
					endlocal
				)
			)
		)
	)
)
endlocal
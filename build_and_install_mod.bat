@echo off
setlocal

:: Check for required arguments
if "%~1"=="" (
    echo Please provide the name of your mod as the first argument.
    exit /b 1
)
if "%~2"=="" (
    echo Please provide the path to the game's executable folder as the second argument.
    exit /b 1
)
if "%~3"=="" (
    echo Please provide the configuration. Example: Game__Shipping__Win64
    exit /b 1
)

:: Set variables
set MOD_NAME=%~1
set GAME_EXECUTABLE_FOLDER=%~2
set MODS_FOLDER=%GAME_EXECUTABLE_FOLDER%\Mods
set CONFIGURATION=%~3

:: Step 1: Build xmake
echo Running xmake...
xmake f -m "%CONFIGURATION%" --runtimes="MD" -y
xmake

:: Step 2: Check if the build was successful
if not exist Output\%CONFIGURATION%\%MOD_NAME%\%MOD_NAME%.dll (
    echo Failed to build the mod. Please check the build output for errors.
    exit /b 1
)

:: Step 3: Create mod directory structure in the game's Mods folder and move the DLL
echo Deploying the mod...
if not exist "%MODS_FOLDER%\%MOD_NAME%\dlls\" (
    mkdir "%MODS_FOLDER%\%MOD_NAME%\dlls\"
)
copy /Y "Output\%CONFIGURATION%\%MOD_NAME%\%MOD_NAME%.dll" "%MODS_FOLDER%\%MOD_NAME%\dlls\main.dll"

:: Step 4: Create an enabled.txt file inside the mod folder
set ENABLED_TXT=%MODS_FOLDER%\%MOD_NAME%\enabled.txt
echo Creating enabled.txt...
echo.> "%ENABLED_TXT%"

echo Mod deployment complete! Please launch your game to test the mod.

:end
endlocal
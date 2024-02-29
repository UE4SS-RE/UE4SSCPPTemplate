@echo off
setlocal

:: Check for required arguments
if "%~1"=="" (
    echo Please provide the name of your mod as the first argument.
    exit /b 1
)

:: Set variables
set MOD_NAME=%~1
set MOD_NAME_UPPER=%MOD_NAME%
call :ToUpper MOD_NAME_UPPER

:ToUpper
if not defined %~1 EXIT /b
for %%a in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I"
        "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R"
        "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z" "ä=Ä"
        "ö=Ö" "ü=Ü") do (
    call set %~1=%%%~1:%%~a%%
)

:: Step 1: Initialise or update RE-UE4SS repository on the latest release tag
if not exist RE-UE4SS (
    echo Cloning RE-UE4SS repository...
    git clone https://github.com/UE4SS-RE/RE-UE4SS.git
)

cd RE-UE4SS
git fetch --tags
for /f "delims=" %%a in ('git tag -l --sort=-v:refname ^| head -n 1') do set LATEST_TAG=%%a
git checkout %LATEST_TAG%
git submodule update --init --recursive 
cd ..

:: Step 2: Create mod directory and files
echo Creating mod directory and files...
mkdir %MOD_NAME%
cd %MOD_NAME%

:: Create xmake.lua
echo Creating xmake.lua...
copy ..\xmake_template.lua xmake.lua
powershell -Command "(Get-Content xmake.lua) -replace 'MyAwesomeMod', '%MOD_NAME%' | Set-Content xmake.lua"

:: Create dllmain.cpp
echo Creating dllmain.cpp...
copy ..\dllmain_template.cpp dllmain.cpp
powershell -Command "(Get-Content dllmain.cpp) -replace 'MyAwesomeMod', '%MOD_NAME%' | Set-Content dllmain.cpp"
powershell -Command "(Get-Content dllmain.cpp) -replace 'MY_AWESOME_MOD_API', '%MOD_NAME_UPPER%_API' | Set-Content dllmain.cpp"

:: Return to MyMods directory
cd ..

:: Step 3: Update the main xmake.lua
echo Adding mod to main xmake.lua...
echo includes("%MOD_NAME%")>> xmake.lua

:: Step 4: Create VS solution
echo Creating VS solution...
xmake project -k vsxmake2022 -y

echo Mod setup complete!

:end
endlocal

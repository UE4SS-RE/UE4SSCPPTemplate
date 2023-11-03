if not exist "BuildFiles" mkdir BuildFiles
cd BuildFiles
cmake -B Output -G"Visual Studio 17 2022" ..
cmake --build . --config Game__Shipping__Win64
pause
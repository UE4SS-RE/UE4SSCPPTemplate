cmake_minimum_required(VERSION 3.18)

set(TARGET MyExampleMod)
project(${TARGET})

add_library(${TARGET} SHARED "src/dllmain.cpp")
target_include_directories(${TARGET} PRIVATE .)

target_link_libraries(${TARGET} PRIVATE UE4SS)

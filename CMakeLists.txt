cmake_minimum_required(VERSION 3.31)

project(STCg12 VERSION 1.0.1.0 LANGUAGES C)

add_executable(stcg12)

if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    target_compile_definitions(stcg12 PRIVATE DEBUG)
endif()

set_target_properties(stcg12 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
target_compile_options(stcg12 PRIVATE -save-temps)
target_compile_features(stcg12 PRIVATE c_std_17)

target_sources(stcg12 PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/c/stcg12.c")


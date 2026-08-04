cmake_minimum_required(VERSION 3.24)

project(hello_cuda VERSION 1.0.0 LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_EXTENSIONS OFF)

option(HELLO_CUDA_BUILD_TESTS "Compilar testes unitários" ON)

add_executable(hello_cuda src/main.cu)
target_include_directories(hello_cuda PRIVATE include)

if(MSVC)
    target_compile_options(hello_cuda PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:/W4>
        $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/W4>)
else()
    target_compile_options(hello_cuda PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:-Wall;-Wextra;-Wpedantic>
        $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=-Wall,-Wextra,-Wpedantic>)
endif()

set_target_properties(hello_cuda PROPERTIES
    CUDA_SEPARABLE_COMPILATION OFF
)

if(HELLO_CUDA_BUILD_TESTS)
    include(CTest)
    add_executable(indexing_test tests/indexing_test.cpp)
    target_include_directories(indexing_test PRIVATE include)

    if(NOT MSVC)
        target_compile_options(indexing_test PRIVATE
            -Wall -Wextra -Wpedantic -Werror)
    endif()

    add_test(NAME indexing_test COMMAND indexing_test)
endif()

cmake_minimum_required(VERSION 3.21)

project(
    Calculetor
    VERSION 1.0.0
    LANGUAGES CXX
)

# =========================
# GLOBAL CONFIG
# =========================

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Default build type (single-config generators)
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}")

# =========================
# COMPILER CHECK
# =========================

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|MSVC")
    message(FATAL_ERROR "Unsupported compiler")
endif()

# =========================
# OPTIONS
# =========================

option(ENABLE_SANITIZER "Enable AddressSanitizer (Debug only)" OFF)
option(ENABLE_TESTS "Build tests" OFF)

# =========================
# SOURCES (EXPLICIT!)
# =========================

set(APP_SOURCES
    index.cpp
)

add_executable(app ${APP_SOURCES})

target_include_directories(app
    PRIVATE
        ${PROJECT_SOURCE_DIR}/header
)

# =========================
# WARNINGS (TARGET BASED)
# =========================

include(cmake/CompilerWarnings.cmake)
set_project_warnings(app)

# =========================
# OPTIMIZATION FLAGS
# =========================

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(app PRIVATE
        $<$<CONFIG:Release>:-O3>
        $<$<CONFIG:Release>:-march=native>
        $<$<CONFIG:Release>:-DNDEBUG>
    )
endif()

# =========================
# LTO (IPO)
# =========================

include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported)

if(ipo_supported)
    set_property(TARGET app PROPERTY
        INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
endif()

# =========================
# SANITIZER (SAFE)
# =========================

if(ENABLE_SANITIZER AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(app PRIVATE
            -fsanitize=address
            -fno-omit-frame-pointer
        )
        target_link_options(app PRIVATE -fsanitize=address)
    endif()
endif()

# =========================
# SUMMARY
# =========================

message(STATUS "==== Configuration Summary ====")
message(STATUS "Sanitizer: ${ENABLE_SANITIZER}")
message(STATUS "Tests: ${ENABLE_TESTS}")

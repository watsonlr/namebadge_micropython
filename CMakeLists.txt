# Top-level CMakeLists.txt for BYUI eBadge MicroPython REPL App

cmake_minimum_required(VERSION 3.16)

# Include MicroPython as a component from the ESP-IDF ports
set(EXTRA_COMPONENT_DIRS
    "${CMAKE_CURRENT_LIST_DIR}/components"
    "$ENV{IDF_PATH}/examples/system/console/advanced/components"
)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

project(namebadge_micropython)

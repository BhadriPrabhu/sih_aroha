cmake_minimum_required(VERSION 3.16)
project(aroha_facility_server CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
file(GLOB_RECURSE SRC_FILES
    "app/*.cc"
    "app/*.cpp"
    "utils/*.cc"
    "utils/*.cpp"
)

# Header directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/app
    ${CMAKE_CURRENT_SOURCE_DIR}/app/controllers
    ${CMAKE_CURRENT_SOURCE_DIR}/app/dto
    ${CMAKE_CURRENT_SOURCE_DIR}/app/plugins
    ${CMAKE_CURRENT_SOURCE_DIR}/app/repositories
    ${CMAKE_CURRENT_SOURCE_DIR}/app/services
    ${CMAKE_CURRENT_SOURCE_DIR}/app/utils
    ${CMAKE_CURRENT_SOURCE_DIR}/config
    ${CMAKE_CURRENT_SOURCE_DIR}/utils
)

# Find Drogon dependency (includes SQLite3 support)
find_package(Drogon REQUIRED)

# Executable target
add_executable(${PROJECT_NAME} main.cc ${SRC_FILES})

target_link_libraries(${PROJECT_NAME} PRIVATE
    Drogon::Drogon
)

# Installation target
install(TARGETS ${PROJECT_NAME} DESTINATION bin)

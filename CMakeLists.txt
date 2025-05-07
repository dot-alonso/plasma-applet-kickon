cmake_minimum_required(VERSION 3.16)

project(kickon)
set(KF6_MIN_VERSION "6.0.0")
find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_MODULE_PATH})
find_package(Plasma REQUIRED)

add_subdirectory(src)
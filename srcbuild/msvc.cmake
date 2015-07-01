###############################################################################
# Cache file for MS Visual Studio
#
# It assumes that a MANTID_THIRD_PARTY environment variable points at the
# directory containing the 3rd party libraries and includes, i.e the directory
# containing include & lib
###############################################################################

###############################################################################
# CMake config
# We need to tell CMake how to find our libraries and includes
###############################################################################
# Includes
set (BASE_INCLUDE_DIR $ENV{MANTID_THIRD_PARTY}/include)
set (PYTHON_INCLUDE_DIR ${BASE_INCLUDE_DIR}/Python27/Include CACHE PATH "")
set (ZLIB_INCLUDE_DIR ${BASE_INCLUDE_DIR}/zlib123 CACHE PATH "")
set (HDF5_INCLUDE_DIRS ${BASE_INCLUDE_DIR}/hdf5;${BASE_INCLUDE_DIR}/hdf5/cpp;${BASE_INCLUDE_DIR}/hdf5/hl CACHE PATH "")
set (CMAKE_INCLUDE_PATH "${PYTHON_INCLUDE_DIR};${ZLIB_INCLUDE_DIR};${HDF5_INCLUDE_DIRS}" CACHE PATH "")

# Libraries
set (BASE_LIB_DIR $ENV{MANTID_THIRD_PARTY}/lib/win64)
# Python
set (PYTHON_LIBRARY ${BASE_LIB_DIR}/Python27/libs/python27.lib CACHE FILEPATH "")
set (PYTHON_DEBUG_LIBRARY ${BASE_LIB_DIR}/Python27/libs/python27_d.lib CACHE FILEPATH "")
# ZLIB
set ( ZLIB_LIBRARY ${BASE_LIB_DIR}/zlib.lib CACHE FILEPATH "")
# HDF5. It didn't seem possible to get this working with a hdf5-config file. It looks like find_package does something
# slightly different depending on whether the CONFIGS argument is passed or not. If the argument is not present (like in ParaView) then
# the result gives back the .dll files, which cannot be linked to
set (HDF5_C_LIBRARY ${BASE_LIB_DIR}/hdf5dll.lib CACHE FILEPATH "")
set (HDF5_HL_LIBRARY ${BASE_LIB_DIR}/hdf5_hldll.lib CACHE FILEPATH "")
set (HDF5_CXX_LIBRARY ${BASE_LIB_DIR}/hdf5_cppdll.lib CACHE FILEPATH "")
set (HDF5_HL_CPP_LIBRARY ${BASE_LIB_DIR}/hdf5_hl_cppdll.lib CACHE FILEPATH "")
set (HDF5_LIBRARIES "${HDF5_C_LIBRARY};${HDF5_HL_LIBRARY};${HDF5_CXX_LIBRARY};${HDF5_HL_CPP_LIBRARY}" CACHE PATH "")

###############################################################################
# General build flags
###############################################################################
set (BUILD_TESTING OFF CACHE BOOL "")
set (BUILD_EXAMPLES OFF CACHE BOOL "")
set (CMAKE_BUILD_TYPE Release CACHE BOOL "")

###############################################################################
# ParaView components
###############################################################################
set (PARAVIEW_BUILD_QT_GUI ON CACHE BOOL "")
set (PARAVIEW_ENABLE_MATPLOTLIB ON CACHE BOOL "")
set (PARAVIEW_ENABLE_PYTHON ON CACHE BOOL "")

###############################################################################
# System libraries
###############################################################################
set (VTK_USE_SYSTEM_HDF5 ON CACHE BOOL "")
set (VTK_USE_SYSTEM_JPEG OFF CACHE BOOL "")
set (VTK_USE_SYSTEM_JSONCPP OFF CACHE BOOL "")
set (VTK_USE_SYSTEM_ZLIB ON CACHE BOOL "")
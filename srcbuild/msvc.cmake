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
set (PYTHON_INCLUDE_DIR ${BASE_INCLUDE_DIR}/Python27/Include)
set (HDF5_INCLUDE_DIRS ${BASE_INCLUDE_DIR}/hdf5;${BASE_INCLUDE_DIR}/hdf5/cpp;${BASE_INCLUDE_DIR}/hdf5/hl)
set (ZLIB_INCLUDE_DIR ${BASE_INCLUDE_DIR}/zlib123)
set (EXTRA_INCLUDE_DIRS ${BASE_INCLUDE_DIR};${HDF5_INCLUDE_DIRS};${JSONCPP_INCLUDE_DIR};${ZLIB_INCLUDE_DIR})

# Libraries
set (BASE_LIB_DIR $ENV{MANTID_THIRD_PARTY}/lib/win64)
set (PYTHON_LIBS_DIR ${BASE_LIB_DIR}/Python27/libs)
set (EXTRA_LIB_DIRS ${BASE_LIB_DIR};${PYTHON_LIBS_DIR})

# Add to CMake search path for find_package & find_library
set (CMAKE_INCLUDE_PATH ${EXTRA_INCLUDE_DIRS} CACHE PATH "" )
set (CMAKE_LIBRARY_PATH ${EXTRA_LIB_DIRS} CACHE PATH "" )

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
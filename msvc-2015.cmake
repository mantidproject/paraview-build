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
set ( CMAKE_INCLUDE_PATH "$ENV{MANTID_THIRD_PARTY}/include" )
set ( CMAKE_LIBRARY_PATH "$ENV{THIRD_PARTY_DIR}/lib" )
set ( CMAKE_PREFIX_PATH "$ENV{THIRD_PARTY_DIR};$ENV{THIRD_PARTY_DIR}/lib/python2.7;$ENV{THIRD_PARTY_DIR}/lib/qt4" )

set ( BASE_INCLUDE_DIR "$ENV{MANTID_THIRD_PARTY}/include" )
set ( BASE_LIB_DIR "$ENV{MANTID_THIRD_PARTY}/lib" )
set ( PYTHON_DIR ${BASE_LIB_DIR}/python2.7 )

# It didn't seem possible to get this working with a *-config files. It looks like find_package does something
# slightly different depending on whether the CONFIGS argument is passed or not. If the argument is not present (like in ParaView) then
# the result gives back the .dll files, which cannot be linked to. We resort to specifying the paths manually.

# Python
set (PYTHON_INCLUDE_DIR "${BASE_LIB_DIR}/python2.7/Include" CACHE PATH "")
set (PYTHON_LIBRARY ${PYTHON_DIR}/libs/python27.lib CACHE FILEPATH "")
# # zlib
set (ZLIB_INCLUDE_DIR ${BASE_INCLUDE_DIR} CACHE PATH "")
set (ZLIB_LIBRARY ${BASE_LIB_DIR}/zlib.lib CACHE FILEPATH "")
# # jsoncpp
set (JSONCPP_INCLUDE_DIR ${BASE_INCLUDE_DIR} CACHE PATH "")
set (JSONCPP_LIBRARY ${BASE_LIB_DIR}/jsoncpp.lib CACHE FILEPATH "")
set (JSONCPP_LIBRARY_DEBUG ${BASE_LIB_DIR}/jsoncpp_d.lib CACHE FILEPATH "")
# # hdf5
set (HDF5_INCLUDE_DIRS "${BASE_INCLUDE_DIR}" CACHE PATH "")
set (HDF5_C_LIBRARY ${BASE_LIB_DIR}/hdf5.lib CACHE FILEPATH "")
set (HDF5_HL_LIBRARY ${BASE_LIB_DIR}/hdf5_hl.lib CACHE FILEPATH "")
set (HDF5_CXX_LIBRARY ${BASE_LIB_DIR}/hdf5_cpp.lib CACHE FILEPATH "")
set (HDF5_HL_CPP_LIBRARY ${BASE_LIB_DIR}/hdf5_hl_cpp.lib CACHE FILEPATH "")
set (HDF5_LIBRARIES "${HDF5_C_LIBRARY};${HDF5_HL_LIBRARY};${HDF5_CXX_LIBRARY};${HDF5_HL_CPP_LIBRARY}" CACHE PATH "")

###############################################################################
# System libraries
###############################################################################
# We don't ship jpeg with Windows.
set (VTK_USE_SYSTEM_JPEG OFF CACHE BOOL "")
# Specify shared system jsoncpp library. 
set (VTK_SYSTEM_JSONCPP_SHARED ON CACHE BOOL "")


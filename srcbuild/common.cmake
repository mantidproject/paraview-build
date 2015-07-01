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
set (VTK_USE_SYSTEM_ZLIB ON CACHE BOOL "")

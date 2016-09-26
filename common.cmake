###############################################################################
# General build flags
###############################################################################
set (BUILD_TESTING OFF CACHE BOOL "")
set (BUILD_EXAMPLES OFF CACHE BOOL "")
set (CMAKE_CXX_STANDARD 14 CACHE STRING "")
set (CMAKE_CXX_STANDARD_REQUIRED 11 CACHE STRING "")
set (CMAKE_BUILD_TYPE Release CACHE STRING "")

###############################################################################
# ParaView components
###############################################################################
set (PARAVIEW_BUILD_QT_GUI ON CACHE BOOL "")
set (PARAVIEW_ENABLE_MATPLOTLIB ON CACHE BOOL "")
set (PARAVIEW_ENABLE_PYTHON ON CACHE BOOL "")
set (VTK_RENDERING_BACKEND OpenGL2 CACHE STRING "")
set (VTK_SMP_IMPLEMENTATION_TYPE TBB CACHE STRING "")
set (VTK_NO_PYTHON_THREADS OFF CACHE BOOL "")
set (VTK_PYTHON_FULL_THREADSAFE ON CACHE BOOL "")

###############################################################################
# System libraries
###############################################################################
set (VTK_USE_SYSTEM_HDF5 ON CACHE BOOL "")
set (VTK_USE_SYSTEM_JSONCPP ON CACHE BOOL "")
set (VTK_USE_SYSTEM_PYGMENTS ON CACHE BOOL "")
set (VTK_USE_SYSTEM_SIX ON CACHE BOOL "")
set (VTK_USE_SYSTEM_ZLIB ON CACHE BOOL "")

@echo off
setlocal enableextensions enabledelayedexpansion
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script for doing a ParaView source build on Windows
::
:: BUILD_THREADS is set in the Jenkins node configuration
::
:: It should be invoked as
::   - buildscript.bat [<build-dir>]
:: where
::   - <build-dir> is an optional build directory (default=C:\Builds)
::
:: This will create a directory for the PARAVIEW_DIR configuration
:: variable like:
::
::   <build-dir>/ParaView-X.Y.Z
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set the ParaView version to build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PV_SHA1=b40280a2f274aa27aac707abf9097317f731dcc1
set PV_SHA1_SHORT=%PV_SHA1:~0,6%
set PV_VERSION=v4.3.%PV_SHA1_SHORT%
set PV_VERSION3=%PV_VERSION:v=%
echo Building ParaView %PV_VERSION%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set locations for sources and build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SRC_DIR=C:\Sources
if not exist %SRC_DIR% do mkdir %SRC_DIR%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Find Git
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for %%X in (git.cmd) do (set FOUND=%%~$PATH:X)
if defined FOUND (
  set GitCmd=git.cmd
) else (
    for %%X in (git.exe) do (set FOUND=%%~$PATH:X)
    if defined FOUND (
        set GitCmd=!FOUND!
    ) else (
        echo Cannot find git. Make sure the cmd folder is in your path.
        exit /B 1
    )
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Fetch/Update 3rd party
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set THIRD_PARTY=%SRC_DIR%\Third_Party
if not exist %THIRD_PARTY% mkdir %THIRD_PARTY%

set MANTID_GIT_ROOT=git://github.com/mantidproject
:: Includes
if EXIST %THIRD_PARTY%\include (
  call:update-includes
) else (
  call:clone-includes
)
::Libraries
if EXIST %THIRD_PARTY%\lib (
  call:update-libs
) else (
  call:clone-libs
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Fetch ParaView
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PARAVIEW_SRC=ParaView-%PV_VERSION%-source
call:fetch-paraview

:: done
goto:eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Helper blocks
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:update-includes
echo Updating third party includes in '%THIRD_PARTY%\include'
set PWD=%CD%
cd /D %THIRD_PARTY%\include
call "%GitCmd%" pull
cd /D %PWD%
goto:eof

:clone-includes
set INCS_URL=%MANTID_GIT_ROOT%/3rdpartyincludes
echo Fetching third party includes from '%INCS_URL%' to '%THIRD_PARTY%\include'
set PWD=%CD%
cd /D %THIRD_PARTY%
call "%GitCmd%" clone --depth=1 %INCS_URL% include
cd /D %PWD%
goto:eof

:update-libs
echo Updating third party libraries in '%THIRD_PARTY%\lib'
set PWD=%CD%
cd /D %THIRD_PARTY%\lib
call "%GitCmd%" pull
cd /D %PWD%
goto:eof

:clone-libs
set LIBS_URL=%MANTID_GIT_ROOT%/3rdpartylibs-win64
echo Fetching third party libraries from '%LIBS_URL%' to '%THIRD_PARTY%\lib'
set PWD=%CD%
cd /D %THIRD_PARTY%
call "%GitCmd%" clone --depth=1 %LIBS_URL% lib
cd /D %PWD%
goto:eof

:fetch-paraview
set PV_GIT_URL=git://paraview.org/ParaView.git
echo Fetching ParaView from '%PV_GIT_URL%' to '%SRC_DIR%\%PARAVIEW_SRC%'
set PWD=%CD%
cd /D %SRC_DIR%
if not EXIST %SRC_DIR%\%PARAVIEW_SRC% (
  call "%GitCmd%" clone %PV_GIT_URL% %PARAVIEW_SRC%
)
cd %PARAVIEW_SRC%
call "%GitCmd%" checkout %PV_SHA1%
call "%GitCmd%" submodule init
call "%GitCmd%" submodule update
cd /D %PWD%
goto:eof


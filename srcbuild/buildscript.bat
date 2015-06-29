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

set SCRIPT_DIR=%~dp0

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
:: This variables is required by the msvc.cmake file
set MANTID_THIRD_PARTY=%SRC_DIR%\Third_Party
if not exist %MANTID_THIRD_PARTY% mkdir %MANTID_THIRD_PARTY%

set MANTID_GIT_ROOT=git://github.com/mantidproject
call:fetch-includes
call:fetch-libs

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Fetch ParaView
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PARAVIEW_SRC=ParaView-%PV_VERSION%-source
call:fetch-paraview

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build ParaView
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set path for Third party to find python & qmake.exe
set THIRD_PARTY_LIB=%MANTID_THIRD_PARTY%\lib\win64
set PATH=%THIRD_PARTY_LIB%;%THIRD_PARTY_LIB%\Python27;%PATH%

set BUILD_DIR=C:\Builds
if not EXIST %BUILD_DIR% mkdir %BUILD_DIR%
cd /D %BUILD_DIR%
set PV_BUILD_DIR=ParaView-%PV_VERSION3%
if not EXIST %PV_BUILD_DIR% mkdir %PV_BUILD_DIR%
cd %PV_BUILD_DIR%

set CACHE_FILE=%SCRIPT_DIR%msvc.cmake
echo Using CMake cache file '%CACHE_FILE%'
set CMAKE_CMD="C:\Program Files (x86)\CMake 2.8\bin\cmake.exe"
%CMAKE_CMD% --version

::Configure
%CMAKE_CMD% -G "Visual Studio 11 Win64" -C%CACHE_FILE% %SRC_DIR%\%PARAVIEW_SRC%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

::Build
msbuild /nologo /m:%BUILD_THREADS% /nr:false /p:Configuration=Release ParaView.sln
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

:: done
goto:eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Helper blocks
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fetch-includes
set INCS_URL=%MANTID_GIT_ROOT%/3rdpartyincludes
echo Fetching third party includes from '%INCS_URL%' to '%MANTID_THIRD_PARTY%\include'
set PWD=%CD%
cd /D %MANTID_THIRD_PARTY%
if not EXIST %MANTID_THIRD_PARTY%\include (
  call "%GitCmd%" clone --depth=1 %INCS_URL% include
) else (
  cd include
  call "%GitCmd%" pull
)
cd /D %PWD%
goto:eof

:fetch-libs
set LIBS_URL=%MANTID_GIT_ROOT%/3rdpartylibs-win64
echo Fetching third party libraries from '%LIBS_URL%' to '%MANTID_THIRD_PARTY%\lib\win64'
set PWD=%CD%
cd /D %MANTID_THIRD_PARTY%
if not EXIST %MANTID_THIRD_PARTY%\lib\win64 (
  call "%GitCmd%" clone --depth=1 %LIBS_URL% lib\win64
) else (
  cd lib\win64
  call "%GitCmd%" pull
)
cd /D %PWD%
goto:eof

:fetch-paraview
set PV_GIT_URL=git://paraview.org/ParaView.git
echo Fetching ParaView from '%PV_GIT_URL%' to '%SRC_DIR%\%PARAVIEW_SRC%'
set PWD=%CD%
cd /D %SRC_DIR%
if not EXIST %SRC_DIR%\%PARAVIEW_SRC% (
  call "%GitCmd%" clone %PV_GIT_URL% %PARAVIEW_SRC%
  cd %PARAVIEW_SRC%
) else (
  cd %PARAVIEW_SRC%
  call "%GitCmd%" fetch
)
call "%GitCmd%" checkout %PV_SHA1%
call "%GitCmd%" submodule init
call "%GitCmd%" submodule update
cd /D %PWD%
goto:eof


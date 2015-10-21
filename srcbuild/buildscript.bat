@echo off
setlocal enableextensions enabledelayedexpansion
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script for doing a ParaView source build on Windows
::
:: BUILD_THREADS is set in the Jenkins node configuration
::
:: It should be invoked as
::   - buildscript.bat [third-party-dir]
::
:: This will create a directory for the PARAVIEW_DIR configuration
:: variable like:
::
::   ~d0\Builds\ParaView-X.Y.Z
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
:: Setup visual studio
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" amd64

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set locations for sources and build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SRC_DIR=%~d0\Sources
if not exist %SRC_DIR% (mkdir %SRC_DIR%)

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
if "%1"=="" (
  set MANTID_THIRD_PARTY=%SRC_DIR%\Third_Party
  if not exist %MANTID_THIRD_PARTY% do mkdir %MANTID_THIRD_PARTY%
  call:fetch-thirdparty
) else (
  set MANTID_THIRD_PARTY=%1
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Fetch ParaView
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PARAVIEW_SRC=ParaView-%PV_VERSION%-source
call:fetch-paraview

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Apply patches not yet in ParaView source
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
cd %SRC_DIR%\%PARAVIEW_SRC%
"%GitCmd%" apply %SCRIPT_DIR%\patches\paraview-msvc2015.patch

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build ParaView
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set path for Third party to find python & qmake.exe
set THIRD_PARTY_LIB=!MANTID_THIRD_PARTY!\lib
set PATH=!MANTID_THIRD_PARTY!\bin;!THIRD_PARTY_LIB!\qt4\bin;!THIRD_PARTY_LIB!\python2.7;%PATH%

set BUILD_DIR=%~d0\Builds
if not EXIST %BUILD_DIR% mkdir %BUILD_DIR%
cd /D %BUILD_DIR%
set PV_BUILD_DIR=ParaView-%PV_VERSION3%
if not EXIST %PV_BUILD_DIR% mkdir %PV_BUILD_DIR%
cd %PV_BUILD_DIR%

set COMMON_CACHE_FILE=%SCRIPT_DIR%common.cmake
set WINDOWS_CACHE_FILE=%SCRIPT_DIR%msvc-2015.cmake
echo Using CMake cache file '%CACHE_FILE%'
set CMAKE_CMD="C:\Program Files (x86)\CMake\bin\cmake.exe"
%CMAKE_CMD% --version

::Configure
%CMAKE_CMD% -G "Visual Studio 14 2015 Win64" -C%COMMON_CACHE_FILE% -C%WINDOWS_CACHE_FILE% %SRC_DIR%\%PARAVIEW_SRC%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

::Build
if not DEFINED BUILD_THREADS set BUILD_THREADS=8
msbuild /nologo /m:!BUILD_THREADS! /nr:false /p:Configuration=Release ALL_BUILD.vcxproj
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

:: done
goto:eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Helper blocks
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fetch-thirdparty
echo Fetching third party not implemented yet!!
exit /b 1
goto:eof

:fetch-paraview
set PV_GIT_URL=https://gitlab.kitware.com/paraview/paraview.git
echo Fetching ParaView from '%PV_GIT_URL%' to '%SRC_DIR%\%PARAVIEW_SRC%'
set PWD=%CD%
cd /D %SRC_DIR%
if EXIST %SRC_DIR%\%PARAVIEW_SRC% (
  cd %PARAVIEW_SRC%
  :: remove any changes from previous patches
  call "%GitCmd%" reset --hard
  call "%GitCmd%" submodule foreach git reset --hard
) else (
  call "%GitCmd%" clone %PV_GIT_URL% %PARAVIEW_SRC%
  cd %PARAVIEW_SRC%
)

call "%GitCmd%" config --global url."http://paraview.org".insteadOf git://paraview.org
call "%GitCmd%" config --global url."http://public.kitware.com".insteadOf git://public.kitware.com
call "%GitCmd%" config --global url."http://vtk.org".insteadOf git://vtk.org
call "%GitCmd%" submodule update --init --recursive
call "%GitCmd%" checkout %PV_SHA1%
cd VTK
call "%GitCmd%" config user.name "Bob T. Builder"
call "%GitCmd%" config user.email "builder@ornl.gov"
call "%GitCmd%" cherry-pick 72b9f62ee6231b3a1afc982d295f92d13297fc62
:: The following commits are purely for VS2015 support
call "%GitCmd%" cherry-pick -m 1 baae0322cc2beec0d68a6807f5769721ed2c4a19
call "%GitCmd%" cherry-pick ea06eda9f11a7ec0d212f44bc30b5ec5dc74f304
cd ..
call "%GitCmd%" config user.name "Bob T. Builder"
call "%GitCmd%" config user.email "builder@ornl.gov"
call "%GitCmd%" cherry-pick acda54cbc1985585a87a9e0a58a6d1da0623a40f dd2e33d6db155c9f1476fb224fe5e4f866bfedf0 fe40cbfe532fd6e419530bdc83f8d8eeae28967c
cd /D %PWD%
goto:eof

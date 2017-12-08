@echo off
setlocal enableextensions enabledelayedexpansion
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script for doing a ParaView source build on Windows. It assumes cmake
:: is installed and on the PATH
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
set MANTID_THIRD_PARTY=%1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set the ParaView version to build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PV_VERSION=v5.4.1
set PV_VERSION3=%PV_VERSION:v=%
echo Building ParaView %PV_VERSION%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup visual studio
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set CMAKE_GENERATOR=Visual Studio 14 2015 Win64
set BUILD_DIR_SUFFIX=-msvc2015-%PV_VERSION%
call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" amd64

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set locations for sources and build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SRC_DIR=%~d0\Sources
if not exist %SRC_DIR% mkdir %SRC_DIR%

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
:: MANTID_THIRD_PARTY is required by the msvc.cmake file
cd /d %SRC_DIR%
if "%MANTID_THIRD_PARTY%" == "" (
  set MANTID_THIRD_PARTY=%SRC_DIR%\thirdparty%BUILD_DIR_SUFFIX%
  if not exist !MANTID_THIRD_PARTY! mkdir !MANTID_THIRD_PARTY!
  call:fetch-thirdparty !MANTID_THIRD_PARTY!
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
"%GitCmd%" config user.name "Bob T. Builder"
"%GitCmd%" config user.email "builder@ornl.gov"
"%GitCmd%" apply --ignore-whitespace %SCRIPT_DIR%\patches\1565.diff
"%GitCmd%" apply --ignore-whitespace %SCRIPT_DIR%\patches\1850.diff
"%GitCmd%" apply --ignore-whitespace %SCRIPT_DIR%\patches\1866.diff
"%GitCmd%" apply --ignore-whitespace %SCRIPT_DIR%\patches\1882.diff
"%GitCmd%" apply --ignore-whitespace %SCRIPT_DIR%\patches\remove-vtkguisupportqt-dep.diff
cd %SRC_DIR%\%PARAVIEW_SRC%\VTK
"%GitCmd%" config user.name "Bob T. Builder"
"%GitCmd%" config user.email "builder@ornl.gov"
if ERRORLEVEL 1 exit /B %ERRORLEVEL%
"%GitCmd%" apply --whitespace=fix %SCRIPT_DIR%\patches\2527.diff
"%GitCmd%" apply --whitespace=fix %SCRIPT_DIR%\patches\2632.diff
"%GitCmd%" apply --whitespace=fix %SCRIPT_DIR%\patches\2693.diff
"%GitCmd%" apply --whitespace=fix %SCRIPT_DIR%\patches\3134.diff

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
if not "%CLEAN%" == "%CLEAN:true=%" (
  echo Removing %PV_BUILD_DIR%
  rmdir /S /Q %PV_BUILD_DIR%
)
if not EXIST %PV_BUILD_DIR% (
  mkdir %PV_BUILD_DIR%
)
cd %PV_BUILD_DIR%

set COMMON_CACHE_FILE=%SCRIPT_DIR%common.cmake
set WINDOWS_CACHE_FILE=%SCRIPT_DIR%msvc-2015.cmake
echo Using CMake cache files '%COMMON_CACHE_FILE%' '%WINDOWS_CACHE_FILE%'
cmake --version

if not EXIST vtkMDHWSignalArray (
  mkdir vtkMDHWSignalArray
)
copy %SCRIPT_DIR%vtkMDHWSignalArray\vtkMDHWSignalArray.h vtkMDHWSignalArray
set SIGNALNAME=vtkArrayDispatch_extra_arrays=vtkMDHWSignalArray^^^<double^^^>
echo SIGNALNAME %SIGNALNAME%
set SIGNALHEADER=vtkArrayDispatch_extra_headers=%BUILD_DIR%\%PV_BUILD_DIR%\vtkMDHWSignalArray\vtkMDHWSignalArray.h
echo SIGNALHEADER %SIGNALHEADER%
::Configure
cmake -G "%CMAKE_GENERATOR%" -D%SIGNALNAME% -D%SIGNALHEADER% -C%COMMON_CACHE_FILE% -C%WINDOWS_CACHE_FILE% %SRC_DIR%\%PARAVIEW_SRC%
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
set TP_DEST_DIR=%1
set TP_GIT_URL=https://github.com/mantidproject/thirdparty-msvc2015.git
set TP_BRANCH=21_json_1_7_3
set _curdir=%CD%
if not exist %TP_DEST_DIR%\.git (
  call "%GitCmd%" clone %TP_GIT_URL% %TP_DEST_DIR%
  cd /D %TP_DEST_DIR%
) else (
  cd /D %TP_DEST_DIR%
  call "%GitCmd%" pull --rebase
)
call "%GitCmd%" checkout %TP_BRANCH%
call "%GitCmd%" reset --hard origin/%TP_BRANCH%
call "%GitCmd%" lfs checkout
cd %_curdir%
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
  call "%GitCmd%" clean -xf
  call "%GitCmd%" submodule foreach git clean -xf
) else (
  call "%GitCmd%" clone %PV_GIT_URL% %PARAVIEW_SRC%
  cd %PARAVIEW_SRC%
)

call "%GitCmd%" config --global url."http://paraview.org".insteadOf git://paraview.org
call "%GitCmd%" config --global url."http://public.kitware.com".insteadOf git://public.kitware.com
call "%GitCmd%" config --global url."http://vtk.org".insteadOf git://vtk.org
call "%GitCmd%" submodule update --init --recursive
call "%GitCmd%" checkout %PV_VERSION%
cd /D %PWD%
goto:eof

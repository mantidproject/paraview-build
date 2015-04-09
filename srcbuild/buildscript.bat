::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script for doing a ParaView source build on Windows
::
:: BUILD_THREADS is set in the Jenkins node configuration
::
:: This will create a directory for the PARAVIEW_DIR configuration
:: variable like: C:\Builds\ParaView-X.Y.Z
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Set the ParaView version to build
set PV_VERSION=v4.3.1
:: Can't build this on Windows from string substitution
set PV_VERSION2=v4.3
set PV_VERSION3=%PV_VERSION:v=%

:: Set the system PATH for Qt and Python

set THIRD_PARTY=C:\Third_Party
set THIRD_PARTY_LIB=%THIRD_PARTY%\lib\win64
set PATH=%THIRD_PARTY_LIB%;%THIRD_PARTY_LIB%\Python27;%PATH%
:: Set Python paths since system has hard time figuring this out.
set PYTHON_LIB=%THIRD_PARTY_LIB%\Python27\libs\python27.lib
set PYTHON_INC=%THIRD_PARTY%\include\Python27\Include
set PYTHON_DEB=%THIRD_PARTY_LIB%\Python27\libs\python27_d.lib

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Print some things for cross-checking
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set CMAKE_CMD="C:\Program Files (x86)\CMake 2.8\bin\cmake.exe"
%CMAKE_CMD% --version

:: Setup the source and build directories

set BUILD_DIR=C:\Builds\ParaView-%PV_VERSION3%
set SRC_DIR=C:\Sources
if not exist %BUILD_DIR% (
    md %BUILD_DIR%
)

if not exist %SRC_DIR% (
    md %SRC_DIR%
)

:: Grab source package and unpack
cd %SRC_DIR%
set PARAVIEW_SRC=ParaView-%PV_VERSION%-source
if not exist %PARAVIEW_SRC% (
  "C:\Program Files\cURL\bin\curl.exe" -O http://www.paraview.org/files/%PV_VERSION2%/%PARAVIEW_SRC%.tar.gz
  "C:\Program Files\7-Zip\7z.exe" x -y %PARAVIEW_SRC%.tar.gz
  "C:\Program Files\7-Zip\7z.exe" x -y %PARAVIEW_SRC%.tar
)

:: Go to build area, setup and run
cd %BUILD_DIR%

set BUILD_CONFIG=Release
set BUILDOPTS=-DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=%BUILD_CONFIG%
set PVOPTS=-DPARAVIEW_BUILD_QT_GUI=ON -DPARAVIEW_ENABLE_MATPLOTLIB=ON -DPARAVIEW_ENABLE_PYTHON=ON
set PYTHON_SETUP=-DPYTHON_DEBUG_LIBRARY:FILEPATH=%PYTHON_DEB% -DPYTHON_INCLUDE_DIR:PATH=%PYTHON_INC% -DPYTHON_LIBRARY:FILEPATH=%PYTHON_LIB%
set PYOPTS=-DVTK_USE_SYSTEM_PYGMENTS=ON

%CMAKE_CMD% -G "Visual Studio 11 Win64" %BUILDOPTS% %PVOPTS% %PYTHON_SETUP% %PYOPTS% %SRC_DIR%\%PARAVIEW_SRC%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

msbuild /nologo /m:%BUILD_THREADS% /nr:false /p:Configuration=%BUILD_CONFIG% ParaView.sln
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

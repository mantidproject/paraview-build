paraview-build
==============

Home for ParaView build scripts and things for making kits and build versions for Mantid

Notes for building with python3
-------------------------------
To stand a chance you need to add
```
-DPYTHON_EXECUTABLE=/usr/bin/python3 -DVTK_USE_SYSTEM_TWISTED=on -DPARAVIEW_ENABLE_WEB=off
```
to your `cmake` command

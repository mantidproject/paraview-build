set(VTK_USE_SYSTEM_JPEG ON CACHE PATH "")
#ubuntu < 15.04, RHEL 7 and Fedora 23 come with jsoncpp 0.6, which is too old. 
set(VTK_USE_SYSTEM_JSONCPP OFF CACHE PATH "")


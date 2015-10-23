#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "ilbcrfc3951" for configuration "Release"
set_property(TARGET ilbcrfc3951 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(ilbcrfc3951 PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libilbcrfc3951.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS ilbcrfc3951 )
list(APPEND _IMPORT_CHECK_FILES_FOR_ilbcrfc3951 "${_IMPORT_PREFIX}/lib/libilbcrfc3951.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

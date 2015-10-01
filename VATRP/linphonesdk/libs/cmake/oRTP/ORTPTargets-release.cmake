#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "BelledonneCommunications::ortp" for configuration "Release"
set_property(TARGET BelledonneCommunications::ortp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(BelledonneCommunications::ortp PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libortp.9.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libortp.9.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS BelledonneCommunications::ortp )
list(APPEND _IMPORT_CHECK_FILES_FOR_BelledonneCommunications::ortp "${_IMPORT_PREFIX}/lib/libortp.9.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

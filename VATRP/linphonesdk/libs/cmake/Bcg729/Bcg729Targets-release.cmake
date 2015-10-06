#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "BelledonneCommunications::bcg729" for configuration "Release"
set_property(TARGET BelledonneCommunications::bcg729 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(BelledonneCommunications::bcg729 PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbcg729.0.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libbcg729.0.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS BelledonneCommunications::bcg729 )
list(APPEND _IMPORT_CHECK_FILES_FOR_BelledonneCommunications::bcg729 "${_IMPORT_PREFIX}/lib/libbcg729.0.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

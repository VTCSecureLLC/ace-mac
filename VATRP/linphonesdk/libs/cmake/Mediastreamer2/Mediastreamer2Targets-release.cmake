#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "BelledonneCommunications::mediastreamer_base" for configuration "Release"
set_property(TARGET BelledonneCommunications::mediastreamer_base APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(BelledonneCommunications::mediastreamer_base PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libmediastreamer_base.5.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libmediastreamer_base.5.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS BelledonneCommunications::mediastreamer_base )
list(APPEND _IMPORT_CHECK_FILES_FOR_BelledonneCommunications::mediastreamer_base "${_IMPORT_PREFIX}/lib/libmediastreamer_base.5.dylib" )

# Import target "BelledonneCommunications::mediastreamer_voip" for configuration "Release"
set_property(TARGET BelledonneCommunications::mediastreamer_voip APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(BelledonneCommunications::mediastreamer_voip PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libmediastreamer_voip.5.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libmediastreamer_voip.5.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS BelledonneCommunications::mediastreamer_voip )
list(APPEND _IMPORT_CHECK_FILES_FOR_BelledonneCommunications::mediastreamer_voip "${_IMPORT_PREFIX}/lib/libmediastreamer_voip.5.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

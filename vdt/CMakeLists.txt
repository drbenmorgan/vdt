# Rules for making the so library with the vector and libm-like signatures

# Define this directory's flags:
set(CMAKE_CXX_FLAGS  ${LIB_FLAGS})

#-----------------------------------------------------------------------
# Build the VDT library
#
set(VDT_PUBLIC_HEADERS
  asin.h
  atan.h
  atan2.h
  cos.h
  exp.h
  identity.h
  inv.h
  log.h
  sin.h
  sincos.h
  sqrt.h
  tan.h
  vdtMath.h
  vdtcore_common.h
  )

# - Configure the source file
configure_file(vdtMath.cc.in ${PROJECT_BINARY_DIR}/vdtMath.cc @ONLY)

# The library and its properties
add_library(vdt ${PROJECT_BINARY_DIR}/vdtMath.cc ${VDT_PUBLIC_HEADERS})
target_include_directories(vdt PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/vdt>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/vdt>
  )

set_target_properties(vdt
  PROPERTIES
    VERSION ${vdt_VERSION}
    SOVERSION ${vdt_VERSION_MAJOR}
  )

# Installation of the lib
install(TARGETS vdt
  EXPORT vdtTargets
  DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES ${VDT_PUBLIC_HEADERS}
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vdt)


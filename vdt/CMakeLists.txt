# Rules for making the so library with the vector and libm-like signatures

# Define this directory's flags:
set(CMAKE_CXX_FLAGS  ${LIB_FLAGS})
include_directories(${PROJECT_SOURCE_DIR}/vdt)
include_directories(${PROJECT_BINARY_DIR})


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

# The library
add_library(vdt ${PROJECT_BINARY_DIR}/vdtMath.cc ${VDT_PUBLIC_HEADERS})

# Installation of the lib
install(TARGETS vdt DESTINATION lib)
install(FILES ${VDT_PUBLIC_HEADERS} DESTINATION include/vdt)


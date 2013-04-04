# Rules for making the so library with the vector and libm-like signatures

# Define this directory's flags:
set(CMAKE_CXX_FLAGS  ${LIB_FLAGS})
include_directories(${PROJECT_SOURCE_DIR}/vdt)

#-----------------------------------------------------------------------
# Generate the code for the lib
#
find_package(PythonInterp REQUIRED)
if(VDT_ENABLE_PRELOAD)
  set(SIGGENOPTS "-p")
else()
  set(SIGGENOPTS)
endif()

add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/vdtMath_signatures.cc
  COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/vdt/signatures_generator.py ${SIGGENOPTS}
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
  COMMENT "Generating VDT signatures"
  )

set(VDT_HEADERS
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

# The library
add_library(vdt ${PROJECT_BINARY_DIR}/vdtMath_signatures.cc ${VDT_HEADERS})

# Installation of the lib
install(TARGETS vdt DESTINATION lib)
install(FILES ${VDT_HEADERS} DESTINATION include/vdt)


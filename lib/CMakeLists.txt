# Rules for making the so library with the vector and libm-like signatures

# Define this directory's flags:
set(CMAKE_CXX_FLAGS  ${LIB_FLAGS})
include_directories(${INC_DIR})

# Generate the code for the lib
find_package(PythonInterp REQUIRED)
if(PRELOAD)
  set(SIGGENOPTS "-p")
else()
  set(SIGGENOPTS)
endif()

add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/vdtMath_signatures.cc
  COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/src/signatures_generator.py ${SIGGENOPTS}
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
  COMMENT "Generating VDT signatures"
  )

# The library
add_library(vdt ${PROJECT_BINARY_DIR}/vdtMath_signatures.cc ${INC_DIR}/vdtMath.h)

# Installation of the lib
install(TARGETS vdt DESTINATION lib)
        
# Build Vc wrapper (without c++11)
if(USE_VC)
  set(CMAKE_CXX_FLAGS  "${LIB_FLAGS} -fabi-version=6")
  include_directories(${PROJECT_SOURCE_DIR}/Vc)
  include_directories(${PROJECT_SOURCE_DIR}/Vc/include)
  add_library(VcWrapper 
    ${SRC_DIR}/vdtdiag_vcWrapper.cc 
    ${SRC_DIR}/vdtdiag_vcWrapper.h
    )
  target_link_libraries(VcWrapper libVc.a)
endif()

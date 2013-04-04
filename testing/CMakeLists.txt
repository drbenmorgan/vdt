# Define this directory's flags:
set(CMAKE_CXX_FLAGS ${DIAG_FLAGS})

include_directories(diagnostic)
include_directories(${PROJECT_SOURCE_DIR}/vdt)

# Unit Tests
add_subdirectory(units)

# Performance Tests
add_exe_and_link(vdtPerfBenchmark vdtPerfBenchmark.cpp ${LIBTIMING})
add_exe_and_link(vdtArithmBenchmark vdtArithmBenchmark.cpp None)
add_exe_and_link(vdtArithmComparison vdtArithmComparison.cpp None)

# Build Vc wrapper (without c++11)
if(VDT_WITH_VC)
  configure_file(externalLibcfg.h.cmake ${PROJECT_BINARY_DIR}/externalLibcfg.h)
  # Generate the wrapper sources
  add_custom_command(
    OUTPUT 
      ${PROJECT_BINARY_DIR}/vdtdiag_vcWrapper.h
      ${PROJECT_BINARY_DIR}/vdtdiag_vcWrapper.cc
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating VDT Vc wrapper for testing"
    )

  set(CMAKE_CXX_FLAGS  "${LIB_FLAGS} -fabi-version=6")
  include_directories(${PROJECT_SOURCE_DIR}/Vc)
  include_directories(${PROJECT_SOURCE_DIR}/Vc/include)

  add_library(VcWrapper 
    ${PROJECT_BINARY_DIR}/vdtdiag_vcWrapper.cc 
    ${PROJECT_BINARY_DIR}/vdtdiag_vcWrapper.h
    )
  target_link_libraries(VcWrapper libVc.a)
endif()


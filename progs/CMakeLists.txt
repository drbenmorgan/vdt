# Define this directory's flags:
set(CMAKE_CXX_FLAGS ${DIAG_FLAGS})

include_directories(${PROJECT_SOURCE_DIR}/include/diagnostic)
include_directories(${PROJECT_SOURCE_DIR}/include )

# Benchmarks
add_exe_and_link(vdtPerfBenchmark vdtPerfBenchmark.cpp ${LIBTIMING})
add_exe_and_link(vdtArithmBenchmark vdtArithmBenchmark.cpp None)
add_exe_and_link(vdtArithmComparison vdtArithmComparison.cpp None)

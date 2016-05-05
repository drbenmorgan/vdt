# Enable this directory's flags:
set(CMAKE_CXX_FLAGS ${DIAG_FLAGS})

# Utils
add_executable(fpDifferentBit fpDifferentBit.cpp)
add_test(NAME vdt_unit_fpDifferentBit COMMAND fpDifferentBit)

add_executable(printInstSet printInstSet.cpp)
add_test(NAME vdt_unit_printInstSet COMMAND printInstSet)

add_executable(test_randomPool test_randomPool.cpp)
add_test(NAME vdt_unit_randomPool COMMAND printInstSet)

add_exe_and_link(test_fcnResponse test_fcnResponse.cpp None)
add_test(NAME vdt_unit_fcnResponse COMMAND test_fcnResponse)

# - Comparison does take some time
add_exe_and_link(test_fcnComparison test_fcnComparison.cpp None)
add_test(NAME vdt_unit_fcnComparison COMMAND test_fcnComparison)

add_exe_and_link(test_fcnPerformance test_fcnPerformance.cpp rt)
add_test(NAME vdt_unit_fcnPerformance COMMAND test_fcnPerformance)

# Funtions
set(vdt_FUNCTION_UNIT_TESTS
  exp
  log
  sqrt
  sin
  cos
  inv
  tan
  asin
  acos
  atan
  atan2
  )

foreach(_funit_test ${vdt_FUNCTION_UNIT_TESTS})
  add_exe_and_link(${_funit_test}_test ${_funit_test}_test.cpp None)
  add_test(NAME vdt_unit_test_${_funit_test} COMMAND ${_funit_test}_test)
endforeach()


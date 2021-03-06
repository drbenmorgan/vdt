# - CMake build for the VDT Math Library

#-----------------------------------------------------------------------
# Project configuration
#
cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
project(vdt)

set(VDT_VERSION_MAJOR 0)
set(VDT_VERSION_MINOR 3)
set(VDT_VERSION_PATCH 7)
set(VDT_VERSION "${VDT_VERSION_MAJOR}.${VDT_VERSION_MINOR}.${VDT_VERSION_PATCH}")

#-----------------------------------------------------------------------
# CMake configuration
#
list(INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")
include(VDTUtility)

#-----------------------------------------------------------------------
# configuration options -- you may change them when running cmake
# with 'cmake -D <OPT>=<value> .'

# - Build shared libs
option(BUILD_SHARED_LIBS "Build VDT as a shared library" ON)

# - Testing
option(VDT_ENABLE_TESTING "Build unit and performance tests" ON)

# - Provide preloading interface
option(VDT_ENABLE_PRELOAD "Create symbols to preload the library" OFF)

# - Instruction set choices
option(VDT_WITH_AVX  "Build with AVX instruction set" OFF)
option(VDT_WITH_AVX2 "Build with AVX2 instruction set" OFF)
option(VDT_WITH_SSE  "Build with SSE instruction set" ON)
option(VDT_WITH_NEON "Build with NEON instruction set" OFF)

# - Vc library option
option(VDT_WITH_VC "Build with Vc library" OFF)

#-----------------------------------------------------------------------
# Compiler detection and setup
# determine compiler type and version
set(COMPILER_IS_47_GCC false)
set(COMPILER_IS_OLD_GCC false)
set(COMPILER_IS_ICC false)

if(CMAKE_CXX_COMPILER MATCHES "/(icpc|icc)$")
  set(COMPILER_IS_ICC true)
elseif(CMAKE_COMPILER_IS_GNUCXX)
  # check the GCC version (taken from Vc library)
   exec_program(${CMAKE_C_COMPILER} ARGS -dumpversion OUTPUT_VARIABLE _gcc_version)
   # some distributions patch their GCC to return nothing or only major
   # and minor version on -dumpversion.
   # In that case we must extract the version number from --version.
   if(NOT _gcc_version OR _gcc_version MATCHES "^[0-9]\\.[0-9]+$")
      exec_program(${CMAKE_C_COMPILER} ARGS --version OUTPUT_VARIABLE _gcc_version)
      string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" _gcc_version "${_gcc_version}")
   endif()
  message(STATUS "Found gcc version ${_gcc_version}")

  if("${_gcc_version}" VERSION_LESS "4.7.0")
    set(COMPILER_IS_OLD_GCC true)
    message(STATUS "You are running gcc older than 4.7, turning off Vc, AVX options")
    change_option(VDT_WITH_VC 0)
    change_option(VDT_WITH_AVX 0)
    change_option(VDT_WITH_AVX2 0)
  else()
    set(CMAKE_COMPILER_IS_NEW_ICC "TRUE")
    message(STATUS "Found ICC greater than ${ICC_THRESHOLD_VERSION}")
  endif()

elseif(CMAKE_COMPILER_IS_GNUCXX)
    if("${COMPILER_VERSION}" VERSION_LESS ${GCC_THRESHOLD_VERSION})
    set(CMAKE_COMPILER_IS_OLD_GCC "TRUE")
    message(STATUS "Found GCC older than ${GCC_THRESHOLD_VERSION}")
  else()
    set(CMAKE_COMPILER_IS_NEW_GCC "TRUE")
    message(STATUS "Found GCC greater than ${GCC_THRESHOLD_VERSION}")
  endif()
endif()

# process options that can be processed here
# SIMD instructions set
if(VDT_WITH_NEON)
  set(SSE_AVX "-mfpu=neon ")
else()
  if(VDT_WITH_SSE AND (NOT (VDT_WITH_AVX OR VDT_WITH_AVX2)))
    set(SSE_AVX "-msse")
  endif()

  if(VDT_WITH_AVX AND (NOT VDT_WITH_AVX2))
    set (SSE_AVX "-mavx")
    if(COMPILER_IS_ICC)
      set(SSE_AVX "-xavx")
    endif()
  endif()

  if(VDT_WITH_AVX2)
    set(SSE_AVX "-mavx2")
    if(COMPILER_IS_ICC)
      set(SSE_AVX "-xavx2")
    endif()
  endif()
endif()

# To use svml at CERN
set(INTEL_SVML_FLAGS "")
if(SVML)
  message(STATUS "Linking SVML library")
  set(INTEL_SVML_FLAGS "-mveclibabi=svml -L/afs/cern.ch/sw/IntelSoftware/linux/x86_64/Compiler/11.1/072/lib/intel64/ -lsvml -lirc")
endif()

# Vc setup
if(VDT_WITH_VC)
  #check for files
  set(VC_LIB_NAME "${PROJECT_SOURCE_DIR}/Vc/libVc.a")
  set(VC_HEADER_NAME "${PROJECT_SOURCE_DIR}/Vc/include/Vc/Vc")

  if(NOT EXISTS ${VC_LIB_NAME})
    change_option(VDT_WITH_VC 0)
  endif()

  if(EXISTS ${VC_LIB_NAME})
    if(NOT EXISTS ${VC_HEADER_NAME})
      change_option(VDT_WITH_VC 0)
    endif()
  endif()

  link_directories(${PROJECT_SOURCE_DIR}/Vc)
endif()

# set compiler options
# Compiler optimisations
set(VECT_OPT "-O3 -ffast-math -ftree-vectorize")
if(CMAKE_COMPILER_IS_GNUCXX)
  set(VECTORIZER_VERBOSITY "-ftree-vectorizer-verbose=0")
endif()

if("4.7.0" VERSION_LESS "${_gcc_version}")
 set(CPP11_OPT "-std=gnu++0x")
else()
 set(CPP11_OPT "-std=c++11")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
set(INLINE_OPT " --param vect-max-version-for-alias-checks=50 --param inline-unit-growth=150")
set(VERBOSITY_OPT "-Winline")
endif()

# compiler dependent changes
if(COMPILER_IS_ICC)
  set(VECT_OPT "-O2")
  set(VECTORIZER_VERBOSITY "")
  set(INLINE_OPT "")
elseif(COMPILER_IS_OLD_GCC)
  set(VECT_OPT "-O2")
  set(VECTORIZER_VERBOSITY "")
  set(INLINE_OPT "")
  set(VERBOSITY_OPT "")
  set(CPP11_OPT "")
endif()

set(WARNING_FLAGS "-W -Wall -Werror -Wno-error=unused-parameter")

set(COMMON_FLAGS "${INTEL_SVML_FLAGS} ${SSE_AVX} ${INLINE_OPT} ${WARNING_FLAGS}")
set(LIB_FLAGS "${VERBOSITY_OPT} ${VECT_OPT} ${VECTORIZER_VERBOSITY} ${COMMON_FLAGS}")

# Locations
# Location of executables, libraries, archives
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)

#-----------------------------------------------------------------------
# Build submodules
#
add_subdirectory(vdt)

#-----------------------------------------------------------------------
# Build testing
#
if(VDT_ENABLE_TESTING AND NOT COMPILER_IS_OLD_GCC)
  set(LIBTIMING "")
  set(LIBTIMINGAPPLE "")
  # Library for time measurement: OSx and Linux
  set (LIBTIMING "rt")
  # do not set it if on OSx
  #if(APPLE)
  #  set(LIBTIMINGAPPLE "-framework Carbon")
  #endif()

  set(DIAG_FLAGS "${CPP11_OPT} ${COMMON_FLAGS} ${LIBTIMINGAPPLE} ${VECT_OPT}")
  enable_testing()
  add_subdirectory(testing)
else()
  change_option(VDT_ENABLE_TESTING 0)
endif()

#-----------------------------------------------------------------------
# Configure and install support files

# - Install Tree
# PkgConfig
configure_file(
  cmake/vdt.pc.in
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/vdt.pc
  @ONLY
  )
install(FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/vdt.pc
  DESTINATION lib/pkgconfig
  )

# CMake
configure_file(
  cmake/vdt-config-version.cmake.in
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/vdt-${VDT_VERSION}/vdt-config-version.cmake
  @ONLY
  )
configure_file(
  cmake/vdt-config.cmake.in
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/vdt-${VDT_VERSION}/vdt-config.cmake
  @ONLY
  )

install(FILES
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/vdt-${VDT_VERSION}/vdt-config-version.cmake
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/vdt-${VDT_VERSION}/vdt-config.cmake
  DESTINATION lib/cmake/vdt-${VDT_VERSION}
  )

install(EXPORT vdt-libraries DESTINATION lib/cmake/vdt-${VDT_VERSION})


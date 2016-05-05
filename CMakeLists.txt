# - CMake build for the VDT Math Library

#-----------------------------------------------------------------------
# Project configuration
#
cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
project(vdt VERSION 0.3.7)

#-----------------------------------------------------------------------
# Local CMake configuration
#
include(cmake/VDTUtility.cmake)

#-----------------------------------------------------------------------
# - Define a default build type when using a single-mode tool like make/ninja
# If you're using a build tool that supports multiple modes (Visual Studio,
# Xcode), this setting has no effect.
if(NOT CMAKE_CONFIGURATION_TYPES)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo
      CACHE STRING "Choose the type of build, options are: None Release MinSizeRel Debug RelWithDebInfo"
      FORCE
      )
  else()
    set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
      CACHE STRING "Choose the type of build, options are: None Release MinSizeRel Debug RelWithDebInfo"
      FORCE
      )
  endif()
endif()

#-----------------------------------------------------------------------
# Install locations
include(GNUInstallDirs)

# - Location of executables, libraries, archives
# TODO: Add support for multiconfig tools
set(VDT_BUILDPRODUCT_DIR ${PROJECT_BINARY_DIR}/BuildProducts)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${VDT_BUILDPRODUCT_DIR}/${CMAKE_INSTALL_BINDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${VDT_BUILDPRODUCT_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${VDT_BUILDPRODUCT_DIR}/${CMAKE_INSTALL_LIBDIR})

#-----------------------------------------------------------------------
# configuration options -- you may change them when running cmake
# with 'cmake -D <OPT>=<value> .'

# - Build shared libs
option(BUILD_SHARED_LIBS "Build VDT as a shared library" ON)

# - Testing
option(VDT_BUILD_TESTING "Build unit and performance tests" ON)

# - Documentation
option(VDT_BUILD_DOCS "Build documentation with Doxygen" ON)

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
# - Common defaults and settings

# - Define the C++ Standard to use (Simplest Possible)
# This will add any compiler flags needed to compile against the required
# standard without any vendor extensions
# NOTE: It *does not* guarantee that the compiler in use supports the
# complete standard. Nor does it inform clients of the project what
# standard was used. Both of these issues can be resolved using CMake's
# compile features, see
#
# - https://cmake.org/cmake/help/v3.3/manual/cmake-compile-features.7.html
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# - Basic flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Intel|(Apple)?Clang")
  set(CMAKE_CXX_FLAGS "-Wall -Werror -Wno-error=unused-parameter")
endif()

# - Specific compiler settings
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  # - GCC < 4.7 can't support VC or AVX
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
    message(WARNING "Current CXX compiler 'GNU' '${CMAKE_CXX_COMPILER_VERSION}'\ncannot support Vc or AVX, disabling these options")
    set(VDT_WITH_VC OFF CACHE FORCE)
    set(VDT_WITH_AVX OFF CACHE FORCE)
    set(VDT_WITH_AVX2 OFF CACHE FORCE)
    set(VECT_OPT "-O2")
  endif()

  set(VECTORIZER_VERBOSITY "")
  set(INLINE_OPT " --param vect-max-version-for-alias-checks=50 --param inline-unit-growth=150")
  set(VERBOSITY_OPT "-Winline")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(VECT_OPT "-O2")
  set(VECTORIZER_VERBOSITY "")
  set(INLINE_OPT "")
  set(COMPILER_IS_ICC false)
endif()

#-----------------------------------------------------------------------
# SIMD instruction settings
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
#set(INTEL_SVML_FLAGS "")
#if(SVML)
#  message(STATUS "Linking SVML library")
#  set(INTEL_SVML_FLAGS "-mveclibabi=svml -L/afs/cern.ch/sw/IntelSoftware/linux/x86_64/Compiler/11.1/072/lib/intel64/ -lsvml -lirc")
#endif()

# Vc setup
if(VDT_WITH_VC)
  find_package(Vc REQUIRED)
endif()

# set compiler options
# Compiler optimisations
set(VECT_OPT "-O3 -ffast-math -ftree-vectorize")
if(CMAKE_COMPILER_IS_GNUCXX)
  set(VECTORIZER_VERBOSITY "-ftree-vectorizer-verbose=0")
endif()

set(COMMON_FLAGS "${INTEL_SVML_FLAGS} ${SSE_AVX} ${INLINE_OPT} ${WARNING_FLAGS}")
set(LIB_FLAGS "${VERBOSITY_OPT} ${VECT_OPT} ${VECTORIZER_VERBOSITY} ${COMMON_FLAGS}")


#-----------------------------------------------------------------------
# Build submodules
#
add_subdirectory(vdt)

#-----------------------------------------------------------------------
# Configure/Build testing
if(VDT_BUILD_TESTING)
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
# Documentation
if(VDT_BUILD_DOCS)
  add_subdirectory(doc)
endif()

#-----------------------------------------------------------------------
# Configure/Install pkg-config and CMakeConfig support files
include(cmake/vdtCreateConfig.cmake)

#-----------------------------------------------------------------------
# Install additional docs
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/Licence.txt
              ${CMAKE_CURRENT_SOURCE_DIR}/ReleaseNotes.txt
        DESTINATION ${CMAKE_INSTALL_DOCDIR})

#-----------------------------------------------------------------------
# Create uninstall target
include(cmake/vdtUninstall.cmake)

#-----------------------------------------------------------------------
# CPack-age vdt
include(cmake/vdtCPack.cmake)


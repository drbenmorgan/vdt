#--- CMake Config Files -----------------------------------------------
# - Use CMake's module to help generating relocatable config files
include(CMakePackageConfigHelpers)

# - Versioning
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/vdtConfigVersion.cmake
  VERSION ${vdt_VERSION}
  COMPATIBILITY SameMajorVersion)

# - Install time config and target files
configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/vdtConfig.cmake.in
  "${PROJECT_BINARY_DIR}/vdtConfig.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/vdt"
  PATH_VARS
    CMAKE_INSTALL_BINDIR
    CMAKE_INSTALL_INCLUDEDIR
    CMAKE_INSTALL_LIBDIR
  )

# - install and export
install(FILES
  "${PROJECT_BINARY_DIR}/vdtConfigVersion.cmake"
  "${PROJECT_BINARY_DIR}/vdtConfig.cmake"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/vdt"
  )
install(EXPORT vdtTargets
  NAMESPACE vdt::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/vdt"
  )

#--- Pkg-Config File --------------------------------------------------
# - Derive relative pcfile -> prefix path to make pkg-config file
#   relocatable
file(RELATIVE_PATH vdt_PCFILEDIR_TO_PREFIX
  "${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig"
  "${CMAKE_INSTALL_PREFIX}"
  )
configure_file("${CMAKE_CURRENT_LIST_DIR}/vdt.pc.in"
  "${PROJECT_BINARY_DIR}/vdt.pc"
  @ONLY
  )
install(FILES "${PROJECT_BINARY_DIR}/vdt.pc"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
  )

# Useful Macros to be used later

macro(change_option NAME NEWVAL)
  unset(${NAME} CACHE)
  set(${NAME} ${NEWVAL} CACHE BOOL "Value changed by cmake - probably due to compiler incompatibilities")
endmacro()


macro(add_exe_and_link  EXENAME FILENAME ADDITIONAL_LIB)
  # no name is lib not present
  set(ADDITIONAL_LIB_NAME "")
  if(NOT APPLE) # in this case u have the framework carbon
    if(${ADDITIONAL_LIB} MATCHES "None")
    else(${ADDITIONAL_LIB} MATCHES "None")
      set(ADDITIONAL_LIB_NAME ${ADDITIONAL_LIB})
    endif()
  endif()

  #link Vc if present
  if(VDT_WITH_VC)
    add_executable(${EXENAME} ${FILENAME})
    target_link_libraries(${EXENAME} vdt VcWrapper ${ADDITIONAL_LIB_NAME})
  else()
    add_executable( ${EXENAME} ${FILENAME})
    target_link_libraries(${EXENAME} vdt ${ADDITIONAL_LIB_NAME})
  endif()
endmacro(add_exe_and_link)

# End macro definitions

        


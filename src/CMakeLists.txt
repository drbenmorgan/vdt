# Auto generate the code for the vector signatures and if needed preload


#generare Vc wrapper and config file
if(USE_VC)
  EXEC_PROGRAM("cd src;python vc_wrapper_generator.py;cd -")
endif()
configure_file(${INC_DIR}/externalLibcfg.h.cmake ${INC_DIR}/externalLibcfg.h)

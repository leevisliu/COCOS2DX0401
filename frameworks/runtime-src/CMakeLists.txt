set(RUNTIME_SRC_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/frameworks/runtime-src)

set(MY_CPP_HEADER
	${RUNTIME_SRC_ROOT}/Classes/GlobalDefine/Define.h
	${RUNTIME_SRC_ROOT}/prebuilt/MobileClientKernel.h
	${RUNTIME_SRC_ROOT}/Classes/ClientKernel.h
	
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/CMD_Data.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/LuaAssert.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ry_MD5.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ImageToByte.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ClientSocket.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/DownAsset.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/UnZipAsset.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/CurlAsset.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/LogAsset.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/QR_Encode.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/QrNode.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/AudioRecorder/AudioRecorder.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/FileAsset.h
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/Integer64.h
	${RUNTIME_SRC_ROOT}/Classes/AppDelegate.h
)


set(MY_CPP_SRC
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/CMD_Data.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/LuaAssert.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ry_MD5.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ImageToByte.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/ClientSocket.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/DownAsset.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/UnZipAsset.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/CurlAsset.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/LogAsset.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/QR_Encode.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/QrNode.cpp
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/AudioRecorder/AudioRecorder.cpp
	
	${RUNTIME_SRC_ROOT}/Classes/ClientKernel.cpp
	${RUNTIME_SRC_ROOT}/Classes/AppDelegate.cpp
)

set(MY_CPP_DIR
	${RUNTIME_SRC_ROOT}/Classes/
	${RUNTIME_SRC_ROOT}/Classes/GlobalDefine
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert
	${RUNTIME_SRC_ROOT}/Classes/LuaAssert/AudioRecorder
	${RUNTIME_SRC_ROOT}/prebuilt
)
/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "FileAsset.h"
#include "MobileClientKernel.h"
#include "LuaAssert/CurlAsset.h"
#include "LuaAssert/LogAsset.h"
#include "LuaAssert/QrNode.h"
#include "LuaAssert/AudioRecorder/AudioRecorder.h"
#include "external/xxtea/xxtea.h"
#include "ClientKernel.h"

#include "ImageToByte.h"
#include "LuaAssert.h"
#include "ClientSocket.h"
#include "Integer64.h"
#include "CMD_Data.h"
#include "ry_MD5.h"
#include "UnZipAsset.h"
#include "DownAsset.h"

USING_NS_CC;
using namespace std;

#define SCHEDULE Director::getInstance()->getScheduler()
AppDelegate* AppDelegate::m_instance = NULL;
AppDelegate::AppDelegate()
{
	m_instance = this;
	m_pClientKernel = new CClientKernel();
	m_BackgroundCallBack =  0;
}

AppDelegate::~AppDelegate()
{
	CC_SAFE_DELETE(m_pClientKernel);
}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}
static int toLua_AppDelegate_nativeIsDebug(lua_State* tolua_S)
{
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    lua_pushboolean(tolua_S, 1);
#else
    lua_pushboolean(tolua_S, 0);
#endif
    return 1;
}

static int toLua_AppDelegate_ReadByDecrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 2)
	{
		const char* filename = lua_tostring(tolua_S, 1);
		const char* szKey = lua_tostring(tolua_S, 2);
		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length() - 1] == '/')
		{
			sp = "";
		}
		else
		{
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath + sp + filename);
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		if (valueMap[szKey].isNull())
		{
			lua_pushstring(tolua_S, "");
		}
		else
		{
			ValueVector& dataArray = valueMap[szKey].asValueVector();
			int len = dataArray.size();
			if (len == 0)
			{
				lua_pushstring(tolua_S, "");
			}
			else
			{
				BYTE *pData = new BYTE[len + 1];
				memset(pData, 0, len + 1);
				for (int i = 0; i < len; i++)
				{
					pData[i] = dataArray.at(i).asByte();
				}
				//CCipher::decryptBuffer(pData,len);
				lua_pushstring(tolua_S, (char*)(pData + 4));
				CC_SAFE_DELETE(pData);
			}
		}
		return 1;
	}
	return 0;
}
static int toLua_AppDelegate_checkData(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 2)
	{
		CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
		if (help)
		{
			int x = lua_tointeger(tolua_S, 1);
			int y = lua_tointeger(tolua_S, 2);
			unsigned int data = help->getData(x, y);
			int r = data & 0xff;
			int g = (data >> 8) & 0xff;
			int b = (data >> 16) & 0xff;
			int a = (data >> 24) & 0xff;
			lua_pushinteger(tolua_S, r);
			lua_pushinteger(tolua_S, g);
			lua_pushinteger(tolua_S, b);
			lua_pushinteger(tolua_S, a);
		}
		return 4;
	}
	return 0;
}

static int toLua_AppDelegate_MD5(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		const char* szData = lua_tostring(tolua_S, 1);
		if (EMPTY_CHAR(szData) == false)
		{
			string md5pass = md5(szData);
			lua_pushstring(tolua_S, md5pass.c_str());
			return 1;
		}
	}
	return 0;
}

static int toLua_AppDelegate_SaveByEncrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 3)
	{
		const char* filename = lua_tostring(tolua_S, 1);
		const char* szKey = lua_tostring(tolua_S, 2);
		const char* szData = lua_tostring(tolua_S, 3);

		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length() - 1] == '/')
		{
			sp = "";
		}
		else
		{
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath + sp + filename);
		CCLOG("save_path:%s", filePath.c_str());
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		ValueVector dataArray;
		int len = strlen(szData);
		if (len > 0)
		{

			char *pData = new char[len + 4];
			memset(pData, 0, len + 4);
			memcpy(pData + 4, szData, len);
			//CCipher::encryptBuffer(pData,len+4);
			for (int i = 0; i < len + 4; i++)
			{
				int tmp = pData[i];
				dataArray.push_back(Value(tmp));
			}
			CC_SAFE_DELETE(pData);
		}
		valueMap[szKey] = Value(dataArray);
		FileUtils::getInstance()->writeToFile(valueMap, filePath);
	}
	return 0;
}

static int toLua_AppDelegate_LoadImageByte(lua_State* tolua_S)
{
	bool result = false;
	int argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		const char* szData = lua_tostring(tolua_S, 1);
		if (EMPTY_CHAR(szData) == false)
		{
			CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
			if (help)
				result = help->onLoadData(szData);
		}
	}
	lua_pushboolean(tolua_S, result ? 1 : 0);
	return 1;
}

static int toLua_AppDelegate_CleanImageByte(lua_State* tolua_S)
{
	CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
	if (help)
		help->onCleanData();
	return 0;
}
static int toLua_AppDelegate_downFileAsync(lua_State* tolua_S)
{

	int argc = lua_gettop(tolua_S);
	if (argc == 4)
	{

		const char* szUrl = lua_tostring(tolua_S, 1);
		const char* szSaveName = lua_tostring(tolua_S, 2);
		const char* szSavePath = lua_tostring(tolua_S, 3);
		int handler = toluafix_ref_function(tolua_S, 4, 0);
		if (handler != 0)
		{
			CDownAsset::DownFile(szUrl, szSaveName, szSavePath, handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}
		else
		{
			CCLOG("toLua_AppDelegate_setHttpDownCallback hadler or listener is null");
		}
	}
	else
	{
		CCLOG("toLua_AppDelegate_setHttpDownCallback arg error now is %d", argc);
	}

	return 0;
}

static int toLua_AppDelegate_unZipAsync(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 3)
	{
		const char* file = lua_tostring(tolua_S, 1);
		const char* path = lua_tostring(tolua_S, 2);
		int handler = toluafix_ref_function(tolua_S, 3, 0);
		if (handler != 0)
		{
			CUnZipAsset::UnZipFile(file, path, handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}
		else {
			if (handler == NULL)
				CCLOG("toLua_AppDelegate_unZipAsync error handler is null");
		}
	}
	else {
		CCLOG("toLua_AppDelegate_unZipAsync error argc is %d", argc);
	}
	return 0;
}
static int toLua_AppDelegate_setbackgroundcallback(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		int handler = toluafix_ref_function(tolua_S, 1, 0);

		if (handler != 0)
		{
			AppDelegate::getAppInstance()->setBackgroundListener(handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}

	}
	return 0;
}
static int toLua_AppDelegate_removebackgroundcallback(lua_State* tolua_S)
{
	AppDelegate::getAppInstance()->setBackgroundListener(0);
	return 0;
}

static int toLua_AppDelegate_onUpDateBaseApp(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S, 1);
	if (path != NULL)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
		WCHAR wszClassName[256] = {};
		MultiByteToWideChar(CP_ACP, 0, path, strlen(path) + 1, wszClassName, sizeof(wszClassName) / sizeof(wszClassName[0]));
		ShellExecute(NULL, L"open", L"explorer.exe", wszClassName, NULL, SW_SHOW);
#endif
		lua_pushboolean(tolua_S, 1);
		return 1;
	}
	return 0;
}

static int toLua_AppDelegate_createDirectory(lua_State* tolua_S)
{

	const char* path = lua_tostring(tolua_S, 1);
	if (path != NULL)
	{
		bool result = createDirectory(path);
		lua_pushboolean(tolua_S, result ? 1 : 0);
		return 1;
	}

	return 0;
}

static int toLua_AppDelegate_removeDirectory(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S, 1);
	if (path != NULL)
	{
		bool result = removeDirectory(path);
		lua_pushboolean(tolua_S, result ? 1 : 0);
		return 1;
	}

	return 0;
}

static int toLua_AppDelegate_containEmoji(lua_State* tolua_S)
{
	bool bContain = false;
	auto argc = lua_gettop(tolua_S);
	if (1 == argc)
	{
		std::string msg = lua_tostring(tolua_S, 1);
		std::u16string ut16;
		if (StringUtils::UTF8ToUTF16(msg, ut16))
		{
			if (false == ut16.empty())
			{
				size_t len = ut16.length();
				for (size_t i = 0; i < len; ++i)
				{
					char16_t hs = ut16[i];
					if (0xd800 <= hs && hs <= 0xdbff)
					{
						if (ut16.length() > (i + 1))
						{
							char16_t ls = ut16[i + 1];
							int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
							if (0x1d000 <= uc && uc <= 0x1f77f)
							{
								bContain = true;
								break;
							}
						}
					}
					else
					{
						if (0x2100 <= hs && hs <= 0x27ff)
						{
							bContain = true;
						}
						else if (0x2B05 <= hs && hs <= 0x2b07)
						{
							bContain = true;
						}
						else if (0x2934 <= hs && hs <= 0x2935)
						{
							bContain = true;
						}
						else if (0x3297 <= hs && hs <= 0x3299)
						{
							bContain = true;
						}
						else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
						{
							bContain = true;
						}
					}
				}
			}
		}
	}
	lua_pushboolean(tolua_S, bContain);
	return 1;
}

static int toLua_AppDelegate_nativeMessageBox(lua_State* tolua_S)
{
	return 1;
}
static int toLua_AppDelegate_reSizeGivenFile(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 4)
	{
		std::string path = lua_tostring(tolua_S, 1);
		std::string newpath = lua_tostring(tolua_S, 2);
		std::string notifyfun = lua_tostring(tolua_S, 3);
		if (FileUtils::getInstance()->isFileExist(path))
		{
			auto sp = Sprite::create(path);
			if (nullptr != sp)
			{
				int nSize = lua_tonumber(tolua_S, 4);
				auto size = sp->getContentSize();
				auto scale = nSize / size.width;
				sp->setScale(scale);
				sp->setAnchorPoint(Vec2(0.0f, 0.0f));

				auto render = RenderTexture::create(nSize, nSize);
				render->retain();
				render->beginWithClear(0, 0, 0, 0);
				sp->visit();
				render->end();
				Director::getInstance()->getRenderer()->render();
				render->saveToFile("tmp.png", true, [=](RenderTexture* render, const std::string& fullpath)
				{
					if (newpath != "")
					{
						Director::getInstance()->getTextureCache()->removeTextureForKey(path);
						FileUtils::getInstance()->renameFile(fullpath, newpath);

						lua_getglobal(tolua_S, notifyfun.c_str());
						if (!lua_isfunction(tolua_S, -1))
						{
							CCLOG("value at stack [%d] is not function", -1);
							lua_pop(tolua_S, 1);
						}
						else
						{
							lua_pushstring(tolua_S, fullpath.c_str());
							lua_pushstring(tolua_S, newpath.c_str());
							int iRet = lua_pcall(tolua_S, 2, 0, 0);
							if (iRet)
							{
								log("call lua fun error:%s", lua_tostring(tolua_S, -1));
								lua_pop(tolua_S, 1);
							}
						}
					}
					render->release();
				});
			}
		}

	}
	return 0;
}

#ifdef WIN32
static int win_gettimeofday(struct timeval * val, struct timezone *)
{
	if (val)
	{
		SYSTEMTIME wtm;
		GetLocalTime(&wtm);

		struct tm tTm;
		tTm.tm_year = wtm.wYear - 1900;
		tTm.tm_mon = wtm.wMonth - 1;
		tTm.tm_mday = wtm.wDay;
		tTm.tm_hour = wtm.wHour;
		tTm.tm_min = wtm.wMinute;
		tTm.tm_sec = wtm.wSecond;
		tTm.tm_isdst = -1;

		val->tv_sec = (long)mktime(&tTm);	   // time_t is 64-bit on win32
		val->tv_usec = wtm.wMilliseconds * 1000;
	}
	return 0;
}
#endif

static long long getCurrentTime()
{
	struct timeval tv;
#ifdef WIN32
	win_gettimeofday(&tv, NULL);
#else
	gettimeofday(&tv, NULL);
#endif 
	long long ms = tv.tv_sec;
	return ms * 1000 + tv.tv_usec / 1000;
}
static int toLua_AppDelegate_currentTime(lua_State* tolua_S)
{
	long long curtime = getCurrentTime();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	//CCLOG("currentTime:%I64d",curtime);
#else
	//CCLOG("currentTime:%lld",curtime);
#endif
	lua_pushnumber(tolua_S, curtime);
	return 1;
}

int register_all_packages(lua_State* tolua_S)
{

	register_all_cmd_data();
	register_all_Integer64();
	register_all_client_socket();
	register_all_curlasset();
	register_all_logasset();
	register_all_QrNode();
	register_all_recorder();

    lua_register(tolua_S,"isDebug",toLua_AppDelegate_nativeIsDebug);
	lua_register(tolua_S, "readByDecrypt", toLua_AppDelegate_ReadByDecrypt);
	lua_register(tolua_S, "checkData", toLua_AppDelegate_checkData);
	lua_register(tolua_S, "md5", toLua_AppDelegate_MD5);
	lua_register(tolua_S, "saveByEncrypt", toLua_AppDelegate_SaveByEncrypt);
	lua_register(tolua_S, "loadImageByte", toLua_AppDelegate_LoadImageByte);
	lua_register(tolua_S, "cleanImageByte", toLua_AppDelegate_CleanImageByte);
	lua_register(tolua_S, "downFileAsync", toLua_AppDelegate_downFileAsync);
	lua_register(tolua_S, "unZipAsync", toLua_AppDelegate_unZipAsync);
	lua_register(tolua_S, "setbackgroundcallback", toLua_AppDelegate_setbackgroundcallback);
	lua_register(tolua_S, "removebackgroundcallback", toLua_AppDelegate_removebackgroundcallback);
	lua_register(tolua_S, "onUpDateBaseApp", toLua_AppDelegate_onUpDateBaseApp);
	lua_register(tolua_S, "createDirectory", toLua_AppDelegate_createDirectory);
	lua_register(tolua_S, "removeDirectory", toLua_AppDelegate_removeDirectory);
	lua_register(tolua_S, "currentTime", toLua_AppDelegate_currentTime);

	lua_register(tolua_S, "reSizeGivenFile", toLua_AppDelegate_reSizeGivenFile);
	lua_register(tolua_S, "nativeMessageBox", toLua_AppDelegate_nativeMessageBox);
	lua_register(tolua_S, "containEmoji", toLua_AppDelegate_containEmoji);

    return 0; //flag for packages manager
}


static void decoder(Data &data)
{
    unsigned char sign[] = "Xt";
    unsigned char key[] = "aaa";

    // decrypt XXTEA
    if (!data.isNull()) {
        bool isEncoder = false;
        unsigned char *buf = data.getBytes();
        ssize_t size = data.getSize();
        ssize_t len = strlen((char *)sign);
        if (size <= len) {
            return;
        }

        for (int i = 0; i < len; ++i) {
            isEncoder = buf[i] == sign[i];
            if (!isEncoder) {
                break;
            }
        }

        if (isEncoder) {
            xxtea_long newLen = 0;
            unsigned char* buffer = xxtea_decrypt(buf + len,
                    (xxtea_long)(size - len),
                    (unsigned char*)key,
                    (xxtea_long)strlen((char *)key),
                    &newLen);
            data.clear();
            data.fastSet(buffer, newLen);
        }
    }
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if (!glview) {
        glview = cocos2d::GLViewImpl::create("glorygame");
        director->setOpenGLView(glview);
        director->startAnimation();
    }
	
    // set default FPS
    director->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    LuaStack *stack = engine->getLuaStack();
    lua_State *L = stack->getLuaState();
    lua_module_register(L);
    //register custom function
    register_all_packages(L);
	Device::setKeepScreenOn(true);

	if (((CClientKernel*)m_pClientKernel)->OnInit() == false)
	{
		CCLOG("[_DEBUG]	ClientKernel_onInit_FALSE!");
		return false;
	}
    // resource decode, game32.zip & game64.zip deal as resoruce.
    //FileUtils::getInstance()->setFileDataDecoder(decoder);
#if 0 // set to 1 for release mode
    // use luajit bytecode package
#if defined(__aarch64__) || defined(__arm64__) || defined(__x86_64__)
    stack->loadChunksFromZIP("res/game64.zip");
#else
    stack->loadChunksFromZIP("res/game32.zip");
#endif
    stack->executeString("require 'main'");
#else // #if 0
    // use discrete files
	string sPathWrite = FileUtils::getInstance()->getWritablePath();
	vector<string> sArray;
	sArray.push_back(sPathWrite);
	FileUtils::getInstance()->setSearchPaths(sArray);
    engine->executeScriptFile("base/src/main.lua");
#endif
	
	SCHEDULE->schedule(SEL_SCHEDULE(&AppDelegate::GlobalUpdate), this, 0, kRepeatForever, 0, false);
    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
}

void AppDelegate::GlobalUpdate(float dt)
{
	CClientKernel* pKernel = (CClientKernel*)AppDelegate::getAppInstance()->getClientKernel();
	if(pKernel)
		pKernel->GlobalUpdate(dt);
	else
		CCLOG("GlobalUpdate m_pClientKernel is null");
}


require("config")
require("cocos.init")
require("framework.init")

require("base.src.app.models.bit")
require("base.src.app.models.AppDF")
require("base.src.app.Toolkits.TimerProxy") --added ycc
appdf.req("base.src.app.views.layer.other.Toast")
cjson = require("cjson")

if device.platform ~= "windows" then
	cc.FileUtils:getInstance():addSearchPath(device.writablePath)
end
cc.FileUtils:getInstance():addSearchPath("client/res/")

--���ص���
LOCAL_DEVELOP = 0

local Version = import(".models.Version")

MyApp = MyApp or class("MyApp", cc.load("mvc").AppBase)
MyApp._instance = nil

function MyApp:onCreate()

    --����ʵ��
    MyApp._instance = self

    math.randomseed(os.time())
    --����·�����
	--cc.FileUtils:getInstance():addSearchPath(device.writablePath.."client/src/")
	cc.FileUtils:getInstance():addSearchPath("client/res/")
	--cc.FileUtils:getInstance():addSearchPath(device.writablePath.."game/")
	
	--�汾��Ϣ
	self._version = Version:create()
	--��Ϸ��Ϣ
	self._gameList = {}
	--���µ�ַ
	self._updateUrl = ""
	--����������ȡ��������Ϣ
	self._serverConfig = {}
end

--��ȡ����
function MyApp:getInstance()
    return MyApp._instance
end

--��ȡ�汾������
function MyApp:getVersionMgr()
	return self._version
end

--��ȡ��Ϸ�б�
function MyApp:getGameList()
    return self._gameList
end

--��ȡ���µ�ַ
function MyApp:getUpdateUrl()
    return self._updateUrl
end

--��ȡ��Ϸ��Ϣ
function MyApp:getGameInfo(wKindID)
    for k,v in pairs(self._gameList) do
		if tonumber(v._KindID) == tonumber(wKindID) then
			return v
		end
	end

	return nil
end

--�Ƿ��Ƿ�����Ϸ
function MyApp:isPrivateModeGame(wKindID)
    
    local gameInfo = self:getGameInfo(wKindID)
    if gameInfo == nil then
        return false
    end

    local isPriModeGame = cc.FileUtils:getInstance():isDirectoryExist(device.writablePath .. "game/" .. gameInfo._Module .. "/src/privateroom")
    return isPriModeGame
end

return MyApp

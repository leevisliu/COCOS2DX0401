-- ��������
--local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameScene = class("GameScene", ccui.Layout)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
local VoiceRecorderKit = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.game.VoiceRecorderKit")

local HELP_LAYER_NAME = "__introduce_help_layer__"
local HELP_BTN_NAME = "__introduce_help_button__"
local VOICE_BTN_NAME = "__voice_record_button__"
local VOICE_LAYER_NAME = "__voice_record_layer__"

-- ��ʼ������
function GameScene:ctor(delegate)
    
    --���κ󷽴���
    self:setTouchEnabled(true)
    self:setContentSize(cc.Director:getInstance():getVisibleSize())

    self._delegate = delegate
    self._gameFrame = GameFrameEngine:getInstance()

    local entergame = GlobalUserItem.tabEnterGame

	if nil ~= entergame then
        
        self:createGameLayer()
	else
		print("��Ϸ��¼����")

        self:getApp():popScene()
	end		

    ExternalFun.registerNodeEvent(self)
end

function GameScene:onExit()

    print("GameScene:onExit()")

    --�رն�ʱ��
    if self._gameLayer.KillGameClock then
        self._gameLayer:KillGameClock(true)
    end
end

--����
function GameScene:onKeyBack()

    if self._delegate then
        self._delegate:onKeyBack()
    end
end

function GameScene:setDelegate(delegate)
    
    self._delegate = delegate
end

function GameScene:createGameLayer()

    local entergame = GlobalUserItem.tabEnterGame

	local modulestr = entergame._KindName
	local GameLayer = appdf.req(appdf.GAME_SRC.. modulestr .. "src.views.GameLayer")
		
	self._gameLayer = GameLayer:create(self._gameFrame, self)				
    self._gameLayer:addTo(self)
end

------------------------------------------------------------------------------------------------------------
-- ���ݽӿ�

function GameScene:getApp()
    return self._delegate._delegate:getApp()
end

--��ȡ��Ϸ��
function GameScene:getGameLayer()
    
    return self._gameLayer
end

--��ȡ��ǰ��Ϸ��Ϣ
function GameScene:getEnterGameInfo()
    
    return GlobalUserItem.tabEnterGame
end

------------------------------------------------------------------------------------------------------------
-- ����ӿ�

--��ʾ�ȴ�����
function GameScene:showPopWait()

    showPopWait()
end

--ȡ���ȴ�����
function GameScene:dismissPopWait()

    dismissPopWait()
end

--����������ť
function GameScene:createHelpBtn(pos, zorder, url, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_HELP_BUTTON
	url = url or yl.HTTP_URL
	local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:popHelpLayer(url, zorder)
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("pub_btn_introduce_0.png", "pub_btn_introduce_1.png", "pub_btn_introduce_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(HELP_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

--����������
function GameScene:popHelpLayer( url, zorder)
	zorder = zorder or yl.ZORDER.Z_HELP_WEBVIEW
	local IntroduceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.IntroduceLayer")
	local lay = IntroduceLayer:create(self, url)
	lay:setName(HELP_LAYER_NAME)
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
		runScene:addChild(lay)
		lay:setLocalZOrder(zorder)
	end
end

--����������ť2
function GameScene:createHelpBtn2(pos, zorder, nKindId, nType, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_HELP_BUTTON
	url = url or yl.HTTP_URL
	local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:popHelpLayer2(nKindId, nType, zorder)
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("pub_btn_introduce_0.png", "pub_btn_introduce_1.png", "pub_btn_introduce_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(HELP_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

--����������2
function GameScene:popHelpLayer2( nKindId, nType, nZorder)
	nZorder = nZorder or yl.ZORDER.Z_HELP_WEBVIEW
	local IntroduceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.IntroduceLayer")
	local lay = IntroduceLayer:createLayer(self, nKindId, nType)
	if nil ~= lay then
		lay:setName(HELP_LAYER_NAME)
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then
			runScene:addChild(lay)
			lay:setLocalZOrder(nZorder)
		end
	end
end

--����¼����ť
function GameScene:createVoiceBtn(pos, zorder, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_VOICE_BUTTON
	local function btncallback(ref, tType)
		if tType == ccui.TouchEventType.began then
			self:startVoiceRecord()
        elseif tType == ccui.TouchEventType.ended 
        	or tType == ccui.TouchEventType.canceled then
            self:stopVoiceRecord()
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("btn_voice_chat_0.png", "btn_voice_chat_1.png", "btn_voice_chat_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(VOICE_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

--��ʼ¼��
function GameScene:startVoiceRecord()
	--�����ײ�����
	if GlobalUserItem.isAntiCheat() then
		local runScene = cc.Director:getInstance():getRunningScene()
		showToast(runScene, "�����׷����ֹ����", 3)
		return
	end
	
	local lay = VoiceRecorderKit.createRecorderLayer(self, self._gameFrame)
	if nil ~= lay then
		lay:setName(VOICE_LAYER_NAME)
		self:addChild(lay)
	end
end

--ֹͣ¼��
function GameScene:stopVoiceRecord()
	local voiceLayer = self:getChildByName(VOICE_LAYER_NAME)
	if nil ~= voiceLayer then
		voiceLayer:removeRecorde()
	end
end

--ȡ��¼��
function GameScene:cancelVoiceRecord()
	local voiceLayer = self:getChildByName(VOICE_LAYER_NAME)
	if nil ~= voiceLayer then
		voiceLayer:cancelVoiceRecord()
	end
end

return GameScene
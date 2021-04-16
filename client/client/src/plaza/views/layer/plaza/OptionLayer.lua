--设置页面
local OptionLayer = class("OptionLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ModifyPasswordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ModifyPasswordLayer")
local BindingMobileLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BindingMobileLayer")

local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
local LogonFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.LogonFrame")

function OptionLayer:ctor(delegate)
    
    self._delegate = delegate

    local csbNode = ExternalFun.loadCSB("Option/OptionLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --头像
    local headSprite = HeadSprite:createClipHead(GlobalUserItem, 120, "sp_avatar_mask_120.png")
    headSprite:setPosition(215, 404)
    headSprite:addTo(self._content)

    --昵称
    local txtNickName = self._content:getChildByName("txt_nickname")
    txtNickName:setString(GlobalUserItem.szNickName)

    --绑定手机
    self._txtBindMobile = self._content:getChildByName("txt_binding_mobile")

    --背景音乐开关
    local checkBgMusic = self._content:getChildByName("check_bgmusic")
    checkBgMusic:setSelected(GlobalUserItem.bVoiceAble)
    checkBgMusic:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setVoiceAble(ref:isSelected())

        if ref:isSelected() then
            ExternalFun.playPlazzBackgroudAudio()
        end
    end)

    self._content:getChildByName("txt_nickname"):setTextColor(cc.c3b(255, 255, 255));
    self._content:getChildByName("txt_binding_mobile"):setTextColor(cc.c3b(255, 255, 255));
    self._content:getChildByName("背景音乐："):setTextColor(cc.c3b(255, 255, 255));
    self._content:getChildByName("游戏音效："):setTextColor(cc.c3b(255, 255, 255));
    self._content:getChildByName("绑定手机号："):setTextColor(cc.c3b(255, 255, 255));

    --游戏音效开关
    local checkGameEffect = self._content:getChildByName("check_gameeffect")
    checkGameEffect:setSelected(GlobalUserItem.bSoundAble)
    checkGameEffect:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setSoundAble(ref:isSelected())
    end)

    --修改密码
    local btnModifyPwd = self._content:getChildByName("btn_modify_pwd")
    btnModifyPwd:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(ModifyPasswordLayer:create(), false)
    end)

    --切换账号
    local btnSwitchAccount = self._content:getChildByName("btn_switch_account")
    btnSwitchAccount:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        if self._delegate and self._delegate.onSwitchAccount then
            self._delegate:onSwitchAccount()
        end
    end)

    --绑定手机
    self._btnBindMobile = self._content:getChildByName("btn_bind")
    self._btnBindMobile:setVisible(false)
    self._btnBindMobile:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(BindingMobileLayer:create(1), false)
    end)

    --取消绑定手机
    self._btnUnBindMobile = self._content:getChildByName("btn_unbind")
    self._btnUnBindMobile:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(BindingMobileLayer:create(2), false)
    end)

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:setContentSize(52, 55);
    btnClose:setPosition(btnClose:getPositionX() - 54, btnClose:getPositionY() - 20);
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
        --网络处理
    self._logonFrame = LogonFrame:create(self, function(result, message)
        self:onLogonCallBack(result, message)
    end)
end

--退出场景
function OptionLayer:onExit()
    
    if self._logonFrame:isSocketServer() then
        self._logonFrame:onCloseSocket()
    end
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

function OptionLayer:onShow()

    --获取绑定手机
    if self._logonFrame and self._logonFrame.onGetPhoneNumber and GlobalUserItem.szBindMobile==nil and GlobalUserItem.bisUpdatePhoneData == false then
	   self._logonFrame:onGetPhoneNumber( GlobalUserItem.szAccount)
        GlobalUserItem.bisUpdatePhoneData = true
    showPopWait()
    else
        self:onUpdateBindingState()
    end
end

--更新绑定状态
function OptionLayer:onUpdateBindingState()

    if GlobalUserItem.bVisitor then
        self._txtBindMobile:setString("游客无需绑定")
        self._btnBindMobile:setVisible(false)
        self._btnUnBindMobile:setVisible(false)
    elseif GlobalUserItem.szBindMobile == nil or GlobalUserItem.szBindMobile == "" then
        self._txtBindMobile:setString("未绑定")
        self._btnBindMobile:setVisible(true)
        self._btnUnBindMobile:setVisible(false)
    else
        self._txtBindMobile:setString(GlobalUserItem.szBindMobile)
        self._btnBindMobile:setVisible(false)
        self._btnUnBindMobile:setVisible(true)
    end
end

-- LogonFrame 回调

function OptionLayer:onLogonCallBack(result, message)
    
    if result ~= 1 then
        dismissPopWait()
    end
    if type(message) == "string" and message ~= "" then
     GlobalUserItem.szBindMobile = message
--        showToast(nil, message, 2)
     GlobalUserItem.bisUpdatePhoneData = false
    else
    GlobalUserItem.szBindMobile = nil
    end

    if result == 1 then --成功
			
	end
        self:onUpdateBindingState()
end

return OptionLayer
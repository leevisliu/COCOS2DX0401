--绑定手机页面
local BindingMobileLayer = class("BindingMobileLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
local LogonFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.LogonFrame")

function BindingMobileLayer:ctor(action)

    local csbNode = ExternalFun.loadCSB("BindingMobile/BindingMobileLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:setContentSize(52, 55);
    btnClose:setPosition(btnClose:getPositionX() - 48, btnClose:getPositionY() - 26);
    btnClose:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    --发送验证码
    local btnSMSCode = self._content:getChildByName("btn_smscode")
    btnSMSCode:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        self:onSendSMSCode()
    end)

    --确定绑定
    local btnBind = self._content:getChildByName("btn_bind")
    btnBind:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
      
        self:onBindMobile()
    end)

    --取消绑定
    local btnUnBind = self._content:getChildByName("btn_unbind")
    btnUnBind:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
      
        self:onUnBindMobile()
    end)

    --输入框
    local spEditBg = self._content:getChildByName("sp_edit_mobile_bg")
    local sizeBg = spEditBg:getContentSize()
    self._editMobile = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
		:move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(30)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(11)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:addTo(spEditBg)

    spEditBg = self._content:getChildByName("sp_edit_smscode_bg")
    sizeBg = spEditBg:getContentSize()
    self._editSMSCode = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
		:move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(30)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(6)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:addTo(spEditBg)

    -- 判断类型
    if action == 1 then 
        
        btnBind:setVisible(true)
        btnUnBind:setVisible(false)
    else

        self._editMobile:setText(GlobalUserItem.szBindMobile)
        self._editMobile:setEnabled(false)

        btnBind:setVisible(false)
        btnUnBind:setVisible(true)
    end

    -- 内容跳入
    AnimationHelper.jumpIn(self._content, function()

        --编辑框在动画后有BUG，调整大小让编辑框可以显示文字
        self._editMobile:setContentSize(self._editMobile:getContentSize())
        self._editSMSCode:setContentSize(self._editSMSCode:getContentSize())
    end)
        --网络处理
    self._logonFrame = LogonFrame:create(self, function(result, message)
        self:onLogonCallBack(result, message)
    end)
end

--退出场景
function BindingMobileLayer:onExit()
    
    if self._logonFrame:isSocketServer() then
        self._logonFrame:onCloseSocket()
    end
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--发送验证码
function BindingMobileLayer:onSendSMSCode()

    local szMobile = string.gsub(self._editMobile:getText(), " ", "")

    if not ExternalFun.isPhoneNumber(szMobile) then
        showToast(nil, "请输入正确的手机号!", 1)
        return
    end

    showPopWait()


    --发送验证码
    if self._logonFrame and self._logonFrame.onGetCode then
	    self._logonFrame:onGetCode( szMobile)
    end
end

--绑定手机
function BindingMobileLayer:onBindMobile()

    local szMobile = string.gsub(self._editMobile:getText(), " ", "")
    local szSMSCode = string.gsub(self._editSMSCode:getText(), " ", "")
    local szBindingAccount = GlobalUserItem.szAccount
    if not ExternalFun.isPhoneNumber(szMobile) then
        showToast(nil, "请输入正确的手机号!", 1)
        return
    end

    if #szSMSCode ~= 6 then
        showToast(nil, "请输入正确的验证码!", 1)
        return
    end

    showPopWait()
       --发送验证码
    if self._logonFrame and self._logonFrame.onBindingPhone then
	    self._logonFrame:onBindingPhone( szMobile ,szSMSCode,szBindingAccount)
        --BindingMobileLayer:onExit()
        --return
    end
   
end

--取消绑定手机
function BindingMobileLayer:onUnBindMobile()

    local szMobile = string.gsub(self._editMobile:getText(), " ", "")
    local szSMSCode = string.gsub(self._editSMSCode:getText(), " ", "")
    local szBindingAccount = GlobalUserItem.szAccount

    if not ExternalFun.isPhoneNumber(szMobile) then
        showToast(nil, "请输入正确的手机号!", 1)
        return
    end

    if #szSMSCode ~= 6 then
        showToast(nil, "请输入正确的验证码!", 1)
        return
    end

       --发送绑定手机
    if self._logonFrame and self._logonFrame.onUnBindPhone then
	    self._logonFrame:onUnBindPhone( szMobile ,szSMSCode,szBindingAccount)
        --BindingMobileLayer:onExit()
    end
end

-- LogonFrame 回调

function BindingMobileLayer:onLogonCallBack(result, message)
    
    if result ~= 1 then
        dismissPopWait()
    end

    if type(message) == "string" and message ~= "" then
    GlobalUserItem.szBindMobile = nil
    GlobalUserItem.bisUpdatePhoneData = false
    showToast(nil, message, 2)
        if message == "验证码已经发送！" or  message == "验证码错误！" or  message == "取消绑定手机失败！" or  message == "绑定手机失败！"   then
            --失败不退出
        else
            dismissPopupLayer(self)
        end
    end
    if result == 1 then --成功
			
	end
end

return BindingMobileLayer
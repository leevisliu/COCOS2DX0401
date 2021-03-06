function showToast(context,message,delaytime,color)
	if (message == nil) or (delaytime<1) then
		return
	end

    if context == nil then
        context = cc.Director:getInstance():getRunningScene()
    end

	local msgtype = type(message)
	if msgtype == "userdata" or msgtype == "table" then
		return
	end

	if message == "" then
		return
	end
	local showMessage = message	
	
	local bg = context:getChildByName("toast_bg")
	local lab = nil
	if bg then
		bg:stopAllActions()
		lab = bg:getChildByName("toast_lab")
		if nil == lab then
			lab = cc.Label:createWithTTF(showMessage, "fonts/round_body.ttf", 24, cc.size(930,0))
			lab:setName("toast_lab")
			
			lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
			lab:addTo(bg)
		end
		lab:stopAllActions()
		bg:setOpacity(255)
		lab:setOpacity(255)
		bg:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), 
			cc.Spawn:create(cc.FadeTo:create(0.5,0),cc.CallFunc:create(function()
				lab:runAction(cc.FadeTo:create(0.5,0))
				end)), 
			cc.RemoveSelf:create(true)))		
	else
		bg = ccui.ImageView:create("General/toast_frame.png")
		bg:setOpacity(0)
		bg:move(appdf.WIDTH/2,appdf.HEIGHT/2)
		bg:addTo(context)
		bg:setName("toast_bg")
		--bg:setScale9Enabled(true)
		bg:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,255), 
			cc.DelayTime:create(delaytime), 
			cc.Spawn:create(cc.FadeTo:create(0.5,0),cc.CallFunc:create(function()
				lab:runAction(cc.FadeTo:create(0.5,0))
				end)), 
			cc.RemoveSelf:create(true)))

		lab = cc.Label:createWithTTF(showMessage, "fonts/round_body.ttf", 24, cc.size(930,0))
		lab:setName("toast_lab")
		
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		lab:addTo(bg)
	end

	if nil ~= lab and nil ~= bg then
		lab:setString(showMessage)
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		local labSize = lab:getContentSize()		

		if labSize.height < 30 then
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			--bg:setContentSize(cc.size(appdf.WIDTH, 64))
		else
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			--bg:setContentSize(cc.size(appdf.WIDTH, 64 + labSize.height))		
		end
		lab:move(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5)
	end
end

--???????????????toast(fadeto?????????????????????????????????????????????????????????)
function showToastNoFade(context,message,delaytime,color)
	if (message == nil) or (delaytime<1) then
		return
	end

    if context == nil then
        context = cc.Director:getInstance():getRunningScene()
    end

	local msgtype = type(message)
	if msgtype == "userdata" or msgtype == "table" then
		return
	end

	if message == "" then
		return
	end
	local showMessage = message	
	
	local bg = context:getChildByName("toast_bg")
	local lab = nil
	if bg then
		bg:stopAllActions()
		lab = bg:getChildByName("toast_lab")
	else
		bg = ccui.ImageView:create("General/toast_frame.png")
		bg:move(appdf.WIDTH/2,appdf.HEIGHT/2)
		bg:addTo(context)
		bg:setName("toast_bg")
		bg:setScale9Enabled(true)		

		lab = cc.Label:createWithTTF(showMessage, "fonts/round_body.ttf", 24, cc.size(930,0))
		lab:setName("toast_lab")
		
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		lab:addTo(bg)
	end

	if nil ~= lab and nil ~= bg then
		lab:setString(showMessage)
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		bg:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), cc.RemoveSelf:create(true)))

		local labSize = lab:getContentSize()
		if labSize.height < 30 then
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			--bg:setContentSize(cc.size(appdf.WIDTH, 64))
		else
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			--bg:setContentSize(cc.size(appdf.WIDTH, 64 + labSize.height))		
		end
		lab:move(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5)
	end
end
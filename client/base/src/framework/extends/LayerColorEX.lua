local LayerColor = cc.LayerColor

function LayerColor:setTouchEnabled(eable)
    self:disableNodeEvents(eable)
    return self
end

function LayerColor:registerScriptTouchHandler(func)
	
end

--[[
	常用定义
]]
appdf = appdf or {}

--屏幕高宽
appdf.WIDTH									= 1334
appdf.HEIGHT								= 750
appdf.g_scaleX                              = display.width / appdf.WIDTH           --X坐标的缩放比例值 added ycc
appdf.g_scaleY                              = display.height / appdf.HEIGHT         --Y坐标的缩放比例值 added ycc

appdf.DEF_FONT                              = "fonts/round_body.ttf"                --默认字体

appdf.BASE_SRC                              = "base.src."
appdf.CLIENT_SRC                            = "client.src."
appdf.GAME_SRC                              = "game."
--扩展目录
appdf.EXTERNAL_SRC							= "client.src.external."
--通用定义目录
appdf.HEADER_SRC							= "client.src.header."
--私人房目录
appdf.PRIVATE_SRC                           = "client.src.privatemode."

--下载信息
appdf.DOWN_PRO_INFO							= 1 									--下载进度
appdf.DOWN_COMPELETED						= 3 									--下载结果
appdf.DOWN_ERROR_PATH						= 4 									--路径出错
appdf.DOWN_ERROR_CREATEFILE					= 5 									--文件创建出错
appdf.DOWN_ERROR_CREATEURL					= 6 									--创建连接失败
appdf.DOWN_ERROR_NET		 				= 7 									--下载失败

--程序版本
appdf.BASE_C_VERSION = 5 --@app_version
--资源版本
appdf.BASE_C_RESVERSION = 5 --@client_version
--自带游戏
appdf.BASE_GAME = 
{
	--{kind = 510,version = "0"},     --李逵劈鱼
   -- {kind = 123,version = "0"},     --飞禽走兽
   -- {kind = 25,version = "0"},      --欢乐五张
}

--环境
appdf.ENV                                   = 1                                     --(1.本地 2.测试 3.线上)

appdf.HTTP_URLS = {
    "http://103.90.155.147:90/",                                                    --本地
   "http://103.90.155.147:90/",                                                          --测试
    "http://103.90.155.147:90/",                                                             --线上
}

appdf.SERVER_LIST = {
    "103.90.155.147",                                                                --本地
    "103.90.155.147",                                                             --测试
    "103.90.155.147",                                                            --线上
}

--http请求链接地址
appdf.HTTP_URL								= appdf.HTTP_URLS[appdf.ENV]            --网站地址

--登录服务器地址
appdf.LOGONSERVER                           = appdf.SERVER_LIST[appdf.ENV]          --登录地址

function appdf.req(path)
    if path and type(path) == "string" then
        return require(path)
    else
        print("require paht unknow")
    end
    
end
-- 字符分割
function appdf.split(str, flag)
	local tab = {}
	while true do

		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

--依据宽度截断字符
function appdf.stringEllipsis(szText, sizeE,sizeCN,maxWidth)
	--当前计算宽度
	local width = 0
	--截断位置
	local lastpos = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	 
	local i = 1
	 
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width +sizeCN <= maxWidth - 3*sizeE then
				width = width +sizeCN
				 i = i + 3
				 lastpos = i+2
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width +sizeE <= maxWidth - 3*sizeE then
				width = width +sizeE
				i = i + 1
				lastpos = i
			else
				bOK = true
				break
			end
		else
			i = i + 1
			lastpos = i
		end
	end
	 
	 	if lastpos ~= 0 then
			szResult = string.sub(szText, 1, lastpos)
			if(bOK) then
				szResult = szResult.."..."
			end
		end
		return szResult
end

--打印table
function appdf.printTable(dataBuffer)
	if not dataBuffer then
		print("printTable:dataBuffer is nil!")
		return
	end
	if type(dataBuffer) ~= "table" then
		print("printTable:dataBuffer is not table!")
		return
	end
	for k ,v in pairs(dataBuffer) do
		local typeinfo = type(v) 
		if typeinfo == "table" then
			appdf.printTable(v)
		elseif typeinfo == "userdata" then
			print("key["..k.."]value[userdata]")
		elseif typeinfo == "boolean" then
			print("key["..k.."]value["..(v and "true" or "false").."]")
		else
			print("key["..k.."]value["..v.."]")
		end
	end

end

--HTTP获取json
function appdf.onHttpJsionTable(url,methon,params,callback)
    dump(methon)
    dump(params)
    dump(url)
    --HTTP回调函数
    local bPost = ((methon == "POST") or (methon == "post"))
	if not bPost then
		url = url.."?"..params
    end

    local xhrc = network.createHTTPRequest(function(xhr)
	    	local datatable 
			local response = xhr.request -- 获得响应数据
			local ok
	        if response:getState() ~= cc.kCCHTTPRequestStateCompleted then
	            return
	        end
	        local status = response:getResponseStatusCode() 
		    if xhr.name == "completed" and (status >= 200 and status < 207) then
			    dump(xhr)
		   		if response then
		   		    ok, datatable = pcall(function()
		   		    	dump(response:getResponseString())
				       return cjson.decode(response:getResponseString())
				    end)
				    if not ok then
				    	print("onHttpJsionTable_cjson_error")
				    	datatable = nil
				    end
			    end
		    else
		    	print("onJsionTable http fail readyState:")
		    end
		    if type(callback) == "function" then
		    	callback(datatable,response)
		    end	

    	end,url,methon)

    if bPost then
        if data then
            xhrc:setPOSTData(params)
        end
    end

    if params ~= nil and params ~= "" then
        print("[appdf.onHttpJsionTable] "..url)
	else
		print("[appdf.onHttpJsionTable] "..url)
	end

    xhrc:start()
	return true
end

--创建版本
function appdf.ValuetoVersion(value)
	if not value then
		return {p=0,m=0,s=0,b=0}
	end
	local tmp 
	if type(value) ~= "number" then
		tmp = tonumber(value)
	else
		tmp = value
	end
	return
	{
		p = bit:_rshift(bit:_and(tmp,0xFF000000),24),
		m = bit:_rshift(bit:_and(tmp,0x00FF0000),16),
		s = bit:_rshift(bit:_and(tmp,0x0000FF00),8),
		b = bit:_and(tmp,0x000000FF)
	}
end

--创建颜色
function appdf.ValueToColor( r,g,b )
	r = r or 255
	g = g or 255
	b = b or 255
	if type(r) ~= "number" then
		r = 255
	end
	if type(g) ~= "number" then
		g = 255
	end
	if type(b) ~= "number" then
		b = 255
	end

	local c = 0
	c = bit:_lshift(bit:_and(0, 255),24)
	c = bit:_or(c, bit:_lshift(bit:_and(r, 255),16))
	c = bit:_or(c, bit:_lshift(bit:_and(g, 255),8))
	c = bit:_or(c, bit:_and(b, 255))

	return c
end

--版本值
function appdf.VersionValue(p,m,s,b)

	local v = 0
	if p ~= nil then
		v = bit:_or(v,bit:_lshift(p,24))
	end
	if m ~= nil then
		v = bit:_or(v,bit:_lshift(m,16))
	end
	if s ~= nil then
		v = bit:_or(v,bit:_lshift(s,8))
	end
	if b ~= nil then
		v = bit:_or(v,b)
	end

	return v
end

---根據名稱取node
function appdf.getNodeByName(node,name)
	local curNode = node:getChildByName(name)
	if curNode then
		return curNode
	else
		local  nodeTab = node:getChildren()
		if #nodeTab>0 then		
			for i=1,#nodeTab do
				local  result = appdf.getNodeByName(nodeTab[i],name)
				if result then					
					return result
				end 
			end
		end

	end
end

--判断是否对象
function appdf.isObject(obj)
    return (obj.__cname ~= nil)
end

BindTool = {}
BindTool.event = cc.Director:getInstance():getEventDispatcher()

BindTool.register = function(target, varName, default)
	target[varName] = default
	target["set" .. string.upper(string.sub(varName, 1, 1)) .. string.sub(varName, 2, -1)] = function(tar, values)
		tar[varName] = values
		local event = cc.EventCustom:new(tostring(target) .. varName)
		event._usedata = values
		luaPrint("触发自定义事件 "..varName)
		BindTool.event:dispatchEvent(event)
	end

	target["get" .. string.upper(string.sub(varName, 1, 1)) .. string.sub(varName, 2, -1)] = function(tar)
		return tar[varName]
	end
end

BindTool.bind = function(target, varName, func)
	local listener = cc.EventListenerCustom:create(tostring(target) .. varName,func)
	BindTool.event:addEventListenerWithFixedPriority(listener, 1)
	return listener
end

BindTool.unbind = function(handlerIndex)
	BindTool.event:removeEventListener(handlerIndex)
end

BindTool.dispatchEvent = function(varName,values)
	local event = cc.EventCustom:new(varName)
	event._usedata = values
	luaPrint("触发自定义事件 "..varName)
	BindTool.event:dispatchEvent(event)
end

BindTool.globalBind = function(varName, func)
	local listener = cc.EventListenerCustom:create(varName,func)
	BindTool.event:addEventListenerWithFixedPriority(listener, 1)
	return listener
end

local Event = class("Event")

function Event:ctor()
    self:init();
end

function Event:init()
    self._allEvents = {};
    self._customListener = {};
end

function Event:bindEvent(event, listener, messageType)
    if event == nil then
        luaPrint("bindEvent not found event name "..tostring(event));
        return;
    end

    if messageType == nil then
        messageType = "platform";
    end

    if self._allEvents[messageType] == nil then
        self._allEvents[messageType] = {}
    end

    -- if self._allEvents[event] == nil then
        -- self._allEvents[messageType][event] = {};
    -- end

    if listener and listener.onReceiveCmdRespone then
        self._allEvents[messageType][event] = listener;
        return {target = messageType, name = event};
    else
        luaPrint("event listener is nil or onReceiveCmdRespone function not implemented!");
    end

    return nil;
end

function Event:unBindEvent(event)
    if self._allEvents[event.target][event.name] ~= nil then
        self._allEvents[event.target][event.name] = nil;
    end
end

function Event:sendEvent(event,params,tag)
    if self._allEvents[tag] then
        local listeners = {};
        for k,listener in pairs(self._allEvents[tag]) do
            if k == event then
                table.insert(listeners, listener);
            end
        end

        for k,listener in pairs(listeners) do
            listener:onReceiveCmdRespone(params);
        end
    end
end

function Event:registerListener(target, event, func, messageType)
    if event == nil then
        luaPrint("registerListener not found event name "..tostring(event));
        return;
    end

    if messageType == nil then
        messageType = "platform";
    end

    if self._customListener[messageType] == nil then
        self._customListener[messageType] = {}
    end
    
    if self._customListener[messageType][event] == nil then
        self._customListener[messageType][event] = {}--防止事件注册了，对象销毁时，没注销事件，下次注册出意外        
    end

    if messageType and target and event and func then
        if self._customListener[messageType][event][tostring(target)] ~= nil then
            self._customListener[messageType][event][tostring(target)] = nil;
        end

        self._customListener[messageType][event][tostring(target)] = func;
        luaPrint("注册 event.messageType ---- "..messageType.."    ,event.name ---- "..event.."    ,event.target  ----- "..tostring(target))
        return {messageType = messageType, name = event, target = tostring(target)};
    else
        luaPrint("target is nil or event is nil or func not implemented!");
    end

    return nil;
end

function Event:unRegisterListener(event)
    if event and event.name and event.target and self._customListener[event.messageType] and self._customListener[event.messageType][event.name] and self._customListener[event.messageType][event.name][event.target] ~= nil then
        luaPrint("注销 event.messageType ---- "..event.messageType.."    ,event.name ---- "..event.name.."    ,event.target  ----- "..event.target)
        self._customListener[event.messageType][event.name][event.target] = nil;
    else
        luaPrint("注销   不存在的   event.messageType ---- "..event.messageType.."    ,event.name ---- "..event.name)
    end
end

function Event:dispatchEvent(messageType, event, value)
    if messageType == nil then
        messageType = "platform";
    end

    if self._customListener[messageType] and self._customListener[messageType][event] then
        local funcs = {};
        for k,func in pairs(self._customListener[messageType][event]) do
            -- luaPrint("找到 "..tostring(func))
            if event ~= "I_R_M_heart" then
                luaPrint("找到  event "..event)
            end
            
            if func then
                table.insert(funcs, func);
            end            
        end

        for k,v in pairs(funcs) do
            v(value);
        end
    else
        luaPrint("not found event : "..event)
    end
end

function Event:clearEventListener(is)
    if is == 1 then
        self._customListener["platform"] = {};
    end

    self._customListener["game"] = {};
end

function Event:iterListener()
    luaDump(self._customListener,"self._customListener");
end

return Event
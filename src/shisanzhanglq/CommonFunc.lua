
-- json资源读取类
UILoader = {}
function UILoader:load(fileName, root, nameTable)
	local node
	local pathInfo = io.pathinfo(fileName)
	if ".csb" == pathInfo.extname then
		node = cc.CSLoader:createNode(fileName)
	else
		node = ccs.GUIReader:getInstance():widgetFromJsonFile(fileName)
	end

	if root and nameTable then
		UILoader:loadByNode(node, root, nameTable)
	end

	return node
end

function UILoader:loadByNode(node, root, nameTable)
	for k, v in pairs(nameTable) do
		local name, uiName, size
		if type(v)=="table" then
			name = v[1]
			uiName = v[2] or name
			size = v[3]
		else
			name, uiName = v, v
		end

		if size and type(size)=="number" and size>0 then
			for i=1, size do
				local widget = UILoader:seekNodeByName(node, string.format(uiName, i))
				if widget then
					root[name] = root[name] or {}
					root[name][i] = widget
				end
			end
		else
			local widget = UILoader:seekNodeByName(node, uiName)
			if widget then
				root[name] = widget
			end
		end
	end
end

-- start --

--------------------------------
-- 按tag查找布局中的结点
-- @function [parent=#uiloader] seekNodeByTag
-- @param node parent 要查找布局的结点
-- @param number tag 要查找的tag
-- @return node#node

-- end --

function UILoader:seekNodeByTag(parent, tag)
	if not parent then
		return
	end

	if tag == parent:getTag() then
		return parent
	end

	local findNode
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()
	if childCount < 1 then
		return
	end
	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = self:seekNodeByTag(parent, tag)
			if findNode then
				return findNode
			end
		end
	end
end

-- start --

--------------------------------
-- 按name查找布局中的结点
-- @function [parent=#uiloader] seekNodeByName
-- @param node parent 要查找布局的结点
-- @param string name 要查找的name
-- @param number index 不为nil时和name格式化查找所有节点
-- @return node#node or table(node)
-- end --

function UILoader:seekNodeByName(parent, name, index)
	if not parent then
		return
	end

	if name == parent.name then
		return parent
	end

	if index then
		local result = {}
		for i=1, index do
			local node = self:seekNodeByName(parent, string.format(name, i))
			if node then
				table.insert(result, node)
			end
		end

		return result
	end

	local findNode
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()
	if childCount < 1 then
		return
	end
	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			if name == parent:getName() then
				return parent
			end
		end
	end

	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = self:seekNodeByName(parent, name)
			if findNode then
				return findNode
			end
		end
	end
end

local NodeEx = cc.Node

function NodeEx:schedule(callback, delay)
    self.__actions = self.__actions or {}
    if self.__actions[callback] then
        self:unschedule(callback)
    end
    
    local delayTime = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delayTime, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    self:runAction(action)
    
    self.__actions[callback] = action
end

function NodeEx:scheduleOnce(callback, delay)
    self.__actions = self.__actions or {}
    if self.__actions[callback] then
        self:unschedule(callback)
    end

    local delayTime = cc.DelayTime:create(delay)
    local action = cc.Sequence:create(delayTime, cc.CallFunc:create(callback))
    self:runAction(action)

    self.__actions[callback] = action
end

function NodeEx:unschedule(callback)
    if self.__actions and self.__actions[callback] then
        self:stopAction(self.__actions[callback])
        self.__actions[callback] = nil
    end
end

function NodeEx:setEnableWithTime(dt)
	dt = dt or 0.5
	self:setEnabled(false)
	self:scheduleOnce(function()
		self:setEnabled(true)
	end, dt)
end

function IsMyUser(user)
	return user.dwUserID == PlatformLogic.loginResult.dwUserID
end

-- 工厂类
function Factory(cls)
    assert(type(cls)=="table" and cls.__cname~=nil, "cls is not class")

    cls.create = function(cls, ...)
        return cls.new(...)
    end
end

function Array(cls, ...)
	local function makeArray(result, ...)
		local t = {...}
		local num = #t
		assert(num>0, "Array must have length!")
		if num==1 then
			for i=1, t[1] do
				result[i] = {}
				if type(cls)=="table" and cls.__cname~=nil then
					result[i] = cls.new()
                elseif cls=="table" then
                    result[i] = {}
				else
					result[i] = cls
				end
			end
		else
			for i=1, t[1] do
				result[i] = {}
				makeArray(result[i], select(2, ...))
			end
		end
	end

	local result = {}
	makeArray(result, ...)

	return result
end

function changeParent(node, parent, ...)
	node:retain()
    node:removeFromParent()
    parent:addChild(node, ...)
end


function printTrackback()
    local ret = ""
    local level = 2

    while true do
        --get stack info
        local info = debug.getinfo(level, "Sln")
        if not info then
            break
        else
            if ret ~= "" then
                ret = ret .. "\r\n"
            end
            ret = string.format("%s[%s]:%d in %s \"%s\"", ret, info.source, info.currentline, info.namewhat ~= "" and info.namewhat or "''", info.name or "")
        end

        --打印变量
        -- local i = 1
        -- while true do
        --  local name, value = debug.getlocal(level, i)

        --  if not name then break end

        --  ret = ret .. "\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"
        --  i = i + 1
        -- end

        level = level + 1
    end

    log(ret)
end

function log(...)
	-- if device.platform=="windows" then
	-- 	changeLogColor(11)
	-- 	luaPrint(...)
	-- 	changeLogColor(7)
	-- else
		luaPrint(...)
	-- end
end

function logTxt(...)
	if device.platform=="windows" then
		io.writefile("log.txt",...,'a')
	end
end

function dumpTxt(...)
	if device.platform=="windows" then
		logTxt(luaDump(...))
	end
end

-- 排列
function table.getCombination(t, dest, n, i)

    local function getCombination(t, array, m, i)
        array = array or {}
        if i+m-1>#t then
            return
        end
        if m==0 then
            table.insert(dest, clone(array))
            return
        end

        table.insert(array, t[i])
        getCombination(t, array, m-1, i+1)

        table.remove(array)
        getCombination(t, array, m, i+1)
    end

    getCombination(t, nil, n, i or 1)

end

function formatNumToString(num, iType)
    --type = 1  表示数字标签里有万亿 用":;" "<="代替 万 亿
    num = num or 0

    local s = FormatFloatToNum(num)
    local len = string.len(tostring(s))

    if len >= 6 and len < 9 then
        if iType ~= nil then
            s = string.format("%.2f:;", num / 10000)
         -- .. ":;"
        else
            s = string.format("%.2f万", num / 10000)
         -- .. "万"
        end
    elseif len >= 9 then
        if iType ~= nil then
            s = string.format("%.2f<=", num / 100000000)
         -- .. "<="
        else
            s = string.format("%.2f", num / 100000000)
         -- .. "亿"
        end
    else
        s = num
    end

    return s
end

function debugUI(node, text, pos)
	assert(node and tolua.cast(node, "cc.Node"), "debugUI(): node is unavailable")

	local drawer = cc.DrawNode:create()
	node:addChild(drawer)

	local color =  cc.c4f(1, 0, 0, 1)
	local size = node:getContentSize()
	drawer:drawRect(cc.p(0,0), cc.p(size.width, size.height), color)

	local anchor = node:getAnchorPoint()
	local x, y = anchor.x * size.width, anchor.y * size.height
	drawer:drawDot(cc.p(x, y), 5, color)

	if text then
		pos = pos or {}
		local size = node:getContentSize()
		local lb = cc.Label:create()
		lb:setName("debugLB")
		lb:setSystemFontSize(18)
		lb:setTextColor(cc.c4f(0, 0, 255, 255))
		lb:setString(text):move(size.width*(pos[1] or 0.5), size.height*(pos[2] or 0.5)):addTo(node, 999)
	end
end

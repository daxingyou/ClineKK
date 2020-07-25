local DuiZhanGameList = class("DuiZhanGameList", BaseWindow)

function DuiZhanGameList:ctor()
	self.super.ctor(self, true, true)

	self:initData()

	self:initUI()

	self:bindEvent()
end

function DuiZhanGameList:initData()
	self.updateBtn = {}
	self.skBtn = {}
	self.listViewBtn = {}
end

function DuiZhanGameList:bindEvent()
	self:pushGlobalEventInfo("notifySameGameUpdate",handler(self,self.syncSameGameUpdate))
	self:pushGlobalEventInfo("exitCreateRoom",handler(self, self.receiveExitCreateRoom))
	self:pushGlobalEventInfo("reDownload",handler(self, self.reDownload))--下载失败重新下载
end

function DuiZhanGameList:onEnterTransitionFinish()
	if not NO_UPDATE then
		for k,v in pairs(self.updateBtn) do
			--非未下载状态，同步下载状态
			local info = UpdateManager:getDownLoadInfo(v,v:getName())
			luaDump(info,"非未下载状态，同步下载状态")
			if info then
				if info.downloadState == STATUE_DOWNING then
					v:show()
					self:onClickBtn(v:getParent())
				elseif info.downloadState == STATUE_HAVEUPDATE then
					v:show()
				end
			else
				v:show()
			end
		end
	end

	self.super.onEnterTransitionFinish(self)

	self:receiveExitCreateRoom()
end

function DuiZhanGameList:onExit()
	for k,v in pairs(self.updateBtn) do
		dispatchEvent("removeUpdateNotify",{v:getName(),v})
	end

	clearCache(nil,true,true)

	self.super.onExit(self)
end

function DuiZhanGameList:initUI()
	local bg = ccui.ImageView:create("common/bg.png")
	bg:setPosition(getScreenCenter())
	self:addChild(bg)
	self.bg = bg

	local size = bg:getContentSize()

	local top = ccui.ImageView:create("hall/topBg.png")
	top:setAnchorPoint(0.5,1)
	top:setPosition(size.width/2,size.height)
	bg:addChild(top)
	self.topImage = top

	local titleBg = ccui.ImageView:create("hall/titleBg.png")
	titleBg:setAnchorPoint(0,1)
	titleBg:setPosition(0,top:getContentSize().height)
	top:addChild(titleBg)

	local title = ccui.ImageView:create("hall/duizhanTitle.png")
	title:setPosition(315,titleBg:getContentSize().height*0.62)
	titleBg:addChild(title)

	--规则
	-- local btn = ccui.Button:create("hall/guize.png","hall/guize-on.png")
	-- btn:setPosition(1130, top:getContentSize().height/2+10)
	-- btn:setTag(1)
	-- top:addChild(btn)
	-- btn:onClick(handler(self, self.onClick))

	--退出
	local btn = ccui.Button:create("hall/fanhui.png","hall/fanhui-on.png")
	btn:setPosition(top:getContentSize().width*0.85, top:getContentSize().height/2+10)
	btn:setTag(2)
	top:addChild(btn)
	btn:onClick(handler(self, self.onClick))

	if checkIphoneX() then
		btn:setPositionX(btn:getPositionX() + 150)
	end

	local node = require("layer.popView.UserInfoNode"):create()
	node:setPosition(top:getContentSize().width*0.35,top:getContentSize().height*0.65)
	top:addChild(node)

	local node = require("layer.popView.BottomNode"):create()
	node:setPosition(size.width/2,0)
	self.bg:addChild(node)
	self.bottomNode = node

	--游戏列表
	local len =self:createGameList()

	local ret = false

	if checkIphoneX() then
		if len > 5 then
			ret = true
		end
	else
		if len > 4 then
			ret = true
		end
	end

	if ret then
		--左滑按钮呢
		local btn = ccui.Button:create("hall/left.png","hall/left-on.png")
		btn:setPosition(btn:getContentSize().width, size.height/2)
		btn:setTag(0)
		-- btn:setScale(-1)
		self.bg:addChild(btn)
		btn:onClick(handler(self, self.onClick))
		btn:hide()
		self.leftBtn = btn
		btn.mx = -15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(safeX+btn:getContentSize().width)
		end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)

		--右滑按钮
		local btn = ccui.Button:create("hall/right.png","hall/right-on.png")
		btn:setPosition(size.width-btn:getContentSize().width, size.height/2)
		btn:setTag(1)
		self.bg:addChild(btn)
		btn:hide()
		btn:onClick(handler(self, self.onClick))
		self.rightBtn = btn
		btn.mx = 15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(winSize.width-safeX-btn:getContentSize().width)
		end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)
	end
end

function DuiZhanGameList:createGameList()
	local gameList = GamesInfoModule:findGameList("dz")

	self.gameList = gameList or {}
	luaDump(self.gameList)

	table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID; end)

	local mask = ccui.ImageView:create("hall/duorenMask.png")
	mask:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2)
	mask:setName("mask")
	self.bg:addChild(mask)

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.horizontal)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(mask:getContentSize().width, mask:getContentSize().height))
	listView:setPosition(mask:getContentSize().width/2,mask:getContentSize().height*0.5)
	listView:setScrollBarEnabled(false)
	mask:addChild(listView)
	self.listView = listView

	listView:onScroll(handler(self, self.onScrollEvent))
	local path = {"doudizhu","dezhoupuke","sanzhangpai","qiangzhuangpinshi","21dian","errenpinshi","10dianban"}
	local gameName = {"doudizhu","dezhoupuke","sanzhangpai","qiangzhuangniuniu","ershiyidian","errenniuniu","shidianban"}
	local sGameName = {"dz_ddz","dz_dzpk","dz_szp","dz_qzps","dz_esyd","dz_ernn","dz_sdb",}
	local counts = {1,1,1,1,1,1,1}

	if checkIphoneX() then
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(safeX*1.5, 355))
		self.listView:pushBackCustomItem(layout)
	end

	local count = 0

	for k,v in pairs(sGameName) do
		local ret = false
		for kk,vv in pairs(self.gameList) do
			if v == vv.szGameName then
				ret = true
				break
			end
		end

		if ret == true then
			count = count + 1
			local layout = self:createGameItem(path[k],gameName[k],counts[k])
			self.listView:pushBackCustomItem(layout)
		end
	end

	if checkIphoneX() then
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(safeX*1.5, 355))
		self.listView:pushBackCustomItem(layout)
	end

	return count
end

function DuiZhanGameList:createGameItem(name,gameName,count)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(320, 355))

	if not checkIphoneX() then
		layout:setContentSize(cc.size(310, 355))
	end

	local size = layout:getContentSize()

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(false)
	btn:setScale(0)
	btn:setName(gameName)
	layout:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickBtn(sender,1) end,1)

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- btn:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(btn:getContentSize().width,btn:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local path = "hall/effect/duizhan/"..name
	local ret = true
	local skeleton_animation = createSkeletonAnimation(name,path..".json", path..".atlas")

	if skeleton_animation == nil then
		skeleton_animation = createFrames("hall/frame/"..name.."_%d.png",count)
		ret = false
	else
		skeleton_animation:setAnimation(1,name, true)
	end

	skeleton_animation:setPosition(size.width/2, size.height/2)
	btn:addChild(skeleton_animation)

	table.insert(self.skBtn,btn)

	if ret == true then
		if name == "doudizhu" then
			skeleton_animation:setPositionY(size.height*0.53)
		elseif name == "qiangzhuangpinshi" or name == "errenpinshi" then
			skeleton_animation:setPositionY(size.height*0.43)
			if name == "qiangzhuangpinshi" then
				skeleton_animation:setPositionX(size.width/2-3)
			end
		elseif name == "sanzhangpai" then
			skeleton_animation:setPositionY(size.height*0.42)
			skeleton_animation:setPositionX(size.width/2+3)
		end
	else
		if name == "dezhoupuke" then
			skeleton_animation:setPositionY(size.height*0.55)
		elseif name == "sanzhangpai" then
			skeleton_animation:setPositionY(size.height*0.46)
			skeleton_animation:setPositionX(size.width/2-3)
		elseif name == "qiangzhuangpinshi" then
			skeleton_animation:setPositionY(size.height*0.44)
		elseif name == "21dian" then
			skeleton_animation:setPositionY(size.height*0.46)
		elseif name == "errenpinshi" then
			skeleton_animation:setPositionY(size.height*0.48)
		elseif name == "10dianban" then
			skeleton_animation:setPositionY(size.height*0.47)
		end
	end

	--下载按钮
	local downBtn = ccui.ImageView:create("hall/down.png")
	downBtn:setAnchorPoint(0.5,0)
	downBtn:setPosition(size.width-downBtn:getContentSize().width/2,downBtn:getContentSize().height/4)
	btn:addChild(downBtn)
	downBtn:setName(gameName)
	downBtn:hide()

	table.insert(self.updateBtn, downBtn)

	return layout
end

--下载点击
function DuiZhanGameList:onClickBtn(sender,isPlay)
	local gameName = sender:getName()
	local node = sender:getChildByName(gameName)

	luaPrint("download   "..gameName)

	if isPlay ~= nil then
		playEffect("sound/sound-hall-selected.mp3")
	end

	if self.callback then
		self.callback(node,gameName)
	else
		dispatchEvent("downloadGame",{node,gameName})
	end
end

function DuiZhanGameList:onClick(sender)
	local tag = sender:getTag()

	if tag == 2 then
		self:delayCloseLayer(0,function() dispatchEvent("exitCreateRoom",1) end)
	elseif tag == 0 or tag == 1 then
		self:listViewSlider(tag)
	end
end

--左右箭头处理
function DuiZhanGameList:listViewSlider(tag,flag)
	for k,v in pairs(self.listViewBtn) do
		v:stopAllActions()
		v.isclick = nil
		v:setPositionX(v.px)
		if v:getTag() == tag then
			v:hide()
		else
			v:show()
			local move = cc.MoveBy:create(v.mdt,cc.p(v.mx,0))
			local seq = cc.Sequence:create(move,move:reverse())
			local rep = cc.RepeatForever:create(seq)
			v:runAction(rep)
		end
	end

	if flag == nil then
		self.listView:scrollToPercentHorizontal(tag*100,0.4,true)
	end
end

function DuiZhanGameList:onScrollEvent(event)
	local ret = false

	if event.name == "BOUNCE_LEFT" or event.name == "SCROLL_TO_LEFT" then
		ret = true
	elseif event.name == "BOUNCE_RIGHT" or event.name == "SCROLL_TO_RIGHT" then
		ret = true
	end

	if ret then
		self:stopActionByTag(1111)
		self.event = event
		local func = function()
			if self.event then
				if self.event.name == "BOUNCE_LEFT" or self.event.name == "SCROLL_TO_LEFT" then
					self:listViewSlider(0,1)
					self.event = nil
				elseif self.event.name == "BOUNCE_RIGHT" or self.event.name == "SCROLL_TO_RIGHT" then
					self:listViewSlider(1,1)
					self.event = nil
				end
			end
		end

		performWithDelay(self,func,0.05):setTag(1111)	
	end
end

--设置下载回调
function DuiZhanGameList:setDownCallback(func)
	self.callback = func
end

--点击下载时，同步其他的按钮
function DuiZhanGameList:syncSameGameUpdate(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v ~= data[1] and v:getName() == data[2] then
			self:onClickBtn(v:getParent())
		end
	end
end

function DuiZhanGameList:receiveExitCreateRoom(data)
	if data then
		data = data._usedata
	end

	if data == nil then
		self:resetViewPos()

		self:playEffect()
	end
end

function DuiZhanGameList:resetViewPos()
	local y = 130;

	self.topImage:setPositionY(self.topImage:getPositionY()+y)
	self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

	for k,v in pairs(self.skBtn) do
		v:setScale(0)
		v:setTouchEnabled(false)
	end

	for k,v in pairs(self.listViewBtn) do
		v:hide()
	end

	self.listView:scrollToPercentHorizontal(0,0.05,false)

	self.isPlayEffect = false
end

function DuiZhanGameList:playEffect()
	if self.isPlayEffect == true then
		return
	end

	self.isPlayEffect = true

	local y = 130
	local unit = 30
	local dt =25/unit/4--#self.skBtn

	local callback = cc.CallFunc:create(function() self:listViewSlider(0) end)

	for k,v in pairs(self.skBtn) do
		local seq = cc.Sequence:create(cc.DelayTime:create(dt*(k-1)-0.05),cc.ScaleTo:create(dt,1.15),cc.ScaleTo:create(dt/3,1),cc.CallFunc:create(function() v:setTouchEnabled(true) end))
		if #self.skBtn <= 4 and k == #self.skBtn then
			seq = cc.Sequence:create(seq,callback)
		elseif #self.skBtn > 4  then
			if checkIphoneX() then
				if k == 5 then
					seq = cc.Sequence:create(seq,callback)
				end
			else
				if k == 4 then
					seq = cc.Sequence:create(seq,callback)
				end
			end
		end
		v:runAction(seq)
	end

	local seq = cc.Sequence:create(
		cc.DelayTime:create(7/unit),
		cc.MoveBy:create(15/unit,cc.p(0,-y-20)),
		cc.MoveBy:create(3/unit,cc.p(0,20))
	)
	self.topImage:runAction(seq)

	local seq = cc.Sequence:create(
		cc.DelayTime:create(7/unit),
		cc.MoveBy:create(15/unit,cc.p(0,y+20)),
		cc.MoveBy:create(3/unit,cc.p(0,-20))
	)
	self.bottomNode:runAction(seq)
end

function DuiZhanGameList:reDownload(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v:getName() == data then
			self:onClickBtn(v:getParent())
			break
		end
	end
end

return DuiZhanGameList

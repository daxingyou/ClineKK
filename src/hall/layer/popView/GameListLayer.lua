local GameListLayer = class("GameListLayer", BaseWindow)

function GameListLayer:ctor()
	self.super.ctor(self)

	self.listViewBtn = {}
	self.defaultType = 1
	self.gameBtn = {}

	self:initData()

	self:initUI()

	self:bindEvent()
end

function GameListLayer:initData()
	self.updateBtn = {}
	self.skBtn = {}
	self.mode = 0

	self.path = {"leyingguibinting","dianzijingcai","buyuheji","bairenpinshi","kuaile30miao","longhudou","hongheidazhan","tangguopaidui","lianhuanduobao","yaoyiyao","shuihuzhuan","woshihehuoren","feiqinzoushou","saoleihongbao","shisanzhang","doudizhu","dezhoupuke","sanzhangpai","21dian","10dianban","qiangzhuangpinshi","errenpinshi","chaojishuiguoji","benchibaoma", "shisanzhanglq"}
	self.gameName = {"leyingguibinting","competition","fishing","bairenniuniu","baijiale","longhudou","hongheidazhan","sweetparty","lianhuanduobao","yaoyiyao","shuihuzhuan","woshihehuoren","fqzs","saoleihongbao","shisanzhang","doudizhu","dezhoupuke","sanzhangpai","ershiyidian","shidianban","qiangzhuangniuniu","errenniuniu","superfruitgame","benchibaoma", "shisanzhanglq"}
	self.sGameName = {"leyingguibinting","dz_dj",{"lkpy_0","lkpy_4"},"game_brps","game_30miao","game_lhd","game_hhdz","game_tgpd","game_lhdb","game_yyy","game_shz","woshihehuoren","game_fqzs","game_slhb","dz_ssz","dz_ddz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","dz_shuiguoji","game_ppc", "dz_lq_ssz"}
	self.counts = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

	-- if runMode == "release" then
		self.path = {"leyingguibinting","doudizhu","buyuheji","likuipiyu","jinchanbuyu","bairenpinshi","kuaile30miao","tangguopaidui","lianhuanduobao","benchibaoma","qiangzhuangpinshi","sanzhangpai","longhudou","hongheidazhan","feiqinzoushou","yaoyiyao","chaojishuiguoji","saoleihongbao","shuihuzhuan","errenpinshi","shisanzhang"}
		self.gameName = {"leyingguibinting","doudizhu","fishing","likuipiyu","jinchanbuyu","bairenniuniu","baijiale","sweetparty","lianhuanduobao","benchibaoma","qiangzhuangniuniu","sanzhangpai","longhudou","hongheidazhan","fqzs","yaoyiyao","superfruitgame","saoleihongbao","shuihuzhuan","errenniuniu","shisanzhang"}
		self.sGameName = {"leyingguibinting","dz_ddz",{"lkpy_0","lkpy_4"},{"lkpy_1","lkpy_5"},{"lkpy_2","lkpy_6"},"game_brps","game_30miao","game_tgpd","game_lhdb","game_ppc","dz_qzps","dz_szp","game_lhd","game_hhdz","game_fqzs","game_yyy","dz_shuiguoji","game_slhb","game_shz","dz_ernn","dz_ssz"}
	-- end

	local gameList = GamesInfoModule._gameNames

	local len = #self.sGameName
	local l = #gameList

	local t1 = {}
	local t2 = {}
	local t3 = {}
	local t4 = {}
	local flag = false

	for i=1,len do
		local item = self.sGameName[i]
		for j=1,l do
			if type(item) == "string" then
				if (item == gameList[j].szGameName and string.find(gameList[j].szType,self.defaultType)) then--or (item == "leyingguibinting" and self.defaultType == 1) 去除合伙人和vip
					table.insert(t1,self.path[i])
					table.insert(t2,self.gameName[i])
					table.insert(t3,self.sGameName[i])
					table.insert(t4,self.counts[i])
					if item == "dz_ssz" then
						flag = true
					end
					break
				end
			elseif type(item) == "table" then
				if (item[1] == gameList[j].szGameName or item[2] == gameList[j].szGameName) and string.find(gameList[j].szType,self.defaultType) then
					table.insert(t1,self.path[i])
					table.insert(t2,self.gameName[i])
					table.insert(t3,self.sGameName[i])
					table.insert(t4,self.counts[i])
					break
				end
			end
		end
	end

	self.path = t1
	self.gameName = t2
	self.sGameName = t3
	self.counts = t4

	if not flag and (self.defaultType == 2) then
		table.insert(self.path,"shisanzhang")
		table.insert(self.gameName,"shisanzhang")
		table.insert(self.sGameName,"dz_ssz")
	end

	--去除合伙人和vip
	-- if self.defaultType == 1 then
	-- 	local index = 1 + math.ceil((#self.path-1)/2) + 1
	-- 	table.insert(self.path,index,"woshihehuoren")
	-- 	table.insert(self.gameName,index,"woshihehuoren")
	-- 	table.insert(self.sGameName,index,"woshihehuoren")
	-- end
end

function GameListLayer:bindEvent()
	self:pushGlobalEventInfo("notifySameGameUpdate",handler(self,self.syncSameGameUpdate))
	-- self:pushGlobalEventInfo("exitCreateRoom",handler(self, self.receiveExitCreateRoom))
	self:pushGlobalEventInfo("reDownload",handler(self, self.reDownload))--下载失败重新下载
	self:pushGlobalEventInfo("startDownload",handler(self, self.startDownload))
	self:pushGlobalEventInfo("restartDownload",handler(self, self.restartDownload))
	self:pushGlobalEventInfo("refreshVIPGameList",handler(self,self.refreshGameList))
	self:pushGlobalEventInfo("restartDownloadSuccess",handler(self, self.onReceiveRestartDownloadSuccess))
end

function GameListLayer:onEnterTransitionFinish()
	if not NO_UPDATE then
		for k,v in pairs(self.updateBtn) do
			--非未下载状态，同步下载状态
			local info = UpdateManager:getDownLoadInfo(v,v:getName())
			luaDump(info,"非未下载状态，同步下载状态")
			if info and info.gameName ~= "shisanzhang" then
				if info.downloadState == STATUE_DOWNING then
					v:show()
					self:onClickBtn(v:getParent())
				elseif info.downloadState == STATUE_HAVEUPDATE then
					v:show()
				end
			else
				-- v:show()
			end
		end
	end

	self.super.onEnterTransitionFinish(self)

	-- self:receiveExitCreateRoom()
end

function GameListLayer:onExit()
	for k,v in pairs(self.updateBtn) do
		dispatchEvent("removeUpdateNotify",{v:getName(),v})
	end

	clearCache(nil,true,true)

	self.super.onExit(self)
end

function GameListLayer:initUI()
	if self.mode == 0 then
		local node = require("layer.popView.AdNode"):create(self)
		node:setLocalZOrder(2)
		self:addChild(node)
	end

	local bg = ccui.ImageView:create("hall/celan.png")
	bg:setPosition(bg:getContentSize().width/2,winSize.height/2)
	self:addChild(bg)
	self.cebian = bg

	if self.mode == 0 then
		bg:setOpacity(0)
	end

	if checkIphoneX() then
		bg:setPositionX(bg:getPositionX()+safeX)
	end

	local y = bg:getContentSize().height*0.73-10

	if self.mode == 1 then
		for i=1,4 do
			local btn = ccui.Button:create("hall/game"..i..".png","hall/game"..i.."-on.png","hall/game"..i.."-dis.png")
			btn:setPosition(bg:getContentSize().width*0.48+27, y)
			bg:addChild(btn)
			btn:setTag(i)
			y = y - btn:getContentSize().height
			btn:setEnabled(i~=1)
			table.insert(self.gameBtn,btn)

			btn:onClick(function(sender) 
				self.defaultType = sender:getTag()
				for k,v in pairs(self.gameBtn) do
					v:setEnabled(v~=sender)
				end
				self:refreshGameList()
			end)
		end
	end

	self.listWidth = bg:getContentSize().width-20

	if checkIphoneX() then
		self.listWidth = bg:getContentSize().width-20 + safeX
	end

	--游戏列表
	self:createGameList()

	local size = winSize

	-- if ret then
		--左滑按钮呢
		local btn = ccui.Button:create("hall/left.png","hall/left-on.png")
		btn:setPosition(self.listWidth+btn:getContentSize().width, size.height*0.45)
		btn:setTag(0)
		-- btn:setScale(-1)
		self:addChild(btn)
		btn:onClick(handler(self, self.onClick))
		btn:setLocalZOrder(1)
		btn:hide()
		-- btn:setPositionX(self.danjingBtn:getContentSize().width+safeX*2)
		self.leftBtn = btn
		btn.mx = -15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(safeX+btn:getPositionX())
		end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)

		--右滑按钮
		local btn = ccui.Button:create("hall/right.png","hall/right-on.png")
		btn:setPosition(size.width-btn:getContentSize().width, size.height*0.45)
		btn:setTag(1)
		self:addChild(btn)
		btn:setLocalZOrder(1)
		-- btn:hide()
		btn:onClick(handler(self, self.onClick))
		self.rightBtn = btn
		btn.mx = 15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(winSize.width-safeX-btn:getContentSize().width)
		end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)
	-- end

	self:listViewSlider(0)
end

function GameListLayer:refreshGameList(data)
	for k,v in pairs(self.updateBtn) do
		dispatchEvent("removeUpdateNotify",{v:getName(),v})
	end

	self:initData()
	self:removeChildByName("mask",true)
	self:createGameList()
	self:listViewSlider(0)
	self:onEnterTransitionFinish()
end

function GameListLayer:createGameList()
	-- local gameList = GamesInfoModule._gameNames

	-- self.gameList = gameList or {}
	-- -- luaDump(self.gameList)

	-- table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID; end)

	local mask = ccui.ImageView:create("hall/mask.png")
	mask:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	mask:setName("mask")
	mask:setOpacity(0)
	self:addChild(mask)
	mask:setCascadeOpacityEnabled(false)

	local height = mask:getContentSize().height+20

	if checkIphoneX() then
		local framesize = cc.Director:getInstance():getWinSize()
		mask:ignoreContentAdaptWithSize(false)
		mask:setContentSize(cc.size(framesize.width,height))
		mask:setPositionX(winSize.width/2)
	end

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.horizontal)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(mask:getContentSize().width-self.listWidth-50, height))
	listView:setPosition(self.listWidth + listView:getContentSize().width/2+30,mask:getContentSize().height*0.45)
	listView:setScrollBarEnabled(false)
	mask:addChild(listView)
	self.listView = listView

	if checkIphoneX() then
		listView:setContentSize(cc.size(mask:getContentSize().width-self.listWidth-10-safeX, mask:getContentSize().height))
		listView:setPositionX(listView:getPositionX())
	end

	listView:onScroll(handler(self, self.onScrollEvent))

	local count = 0

	local len = math.ceil(#self.path/2)

	for i=1,len do
		local layout = self:createGroup(i,len)
		self.listView:pushBackCustomItem(layout)
	end

	return count
end

function GameListLayer:createGroup(tag,len)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(250, 450))

	-- if result[tag] == true then
		local node = self:createGameItem(self.path[tag],self.gameName[tag],self.counts[tag])
		node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.75)
		layout:addChild(node)
	-- end

	tag = tag + len

	if tag <= #self.path then
		local node = self:createGameItem(self.path[tag],self.gameName[tag],self.counts[tag])
		node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.25-10)
		layout:addChild(node)
	end

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- layout:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(layout:getContentSize().width,layout:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,1,1))

	return layout
end

function GameListLayer:createGameItem(name,gameName,count)
	local size = cc.size(250, 220)

	if name == "dianzijingcai" then
		-- size.height = 430
		-- size.width = 260
	elseif name == "guanggao1" then
		size.height = 420
		size.width = 320
	end

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	-- btn:setScale(0)
	btn:setName(gameName)
	btn:onTouchClick(function(sender) self:onClickBtn(sender,1) end,1)

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- btn:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(btn:getContentSize().width,btn:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local path = "hall/effect/"..name
	local ret = true
	local skeleton_animation = createSkeletonAnimation(name,path..".json", path..".atlas")

	if skeleton_animation == nil then
		skeleton_animation = ccui.ImageView:create("hall/frame/"..name..".png")--createFrames("hall/frame/"..name.."_%d.png",count)
		ret = false
	else
		skeleton_animation:setAnimation(1,name, true)
	end

	skeleton_animation:setPosition(size.width/2, size.height/2)
	btn:addChild(skeleton_animation)

	table.insert(self.skBtn,btn)

	if name == "shisanzhang" then
		local image = ccui.ImageView:create("hall/jijiangshangxian.png")
		image:setPosition(size.width/2, size.height/2-20)
		btn:addChild(image)
	end

	if ret == true then
		-- if name == "doudizhu" then
		-- 	skeleton_animation:setPositionY(size.height*0.53)
		-- elseif name == "qiangzhuangpinshi" or name == "errenpinshi" then
		-- 	skeleton_animation:setPositionY(size.height*0.42)
		-- elseif name == "sanzhangpai" then
		-- 	skeleton_animation:setPositionY(size.height*0.42)
		-- elseif name == "buyuheji" then
		-- 	skeleton_animation:setPositionY(size.height*0.47)
		-- elseif name == "bairenpinshi" then
		-- 	skeleton_animation:setPositionY(size.height*0.45)
		-- elseif name == "kuaile30miao" then
		-- 	skeleton_animation:setPositionY(size.height*0.45)
		-- elseif name == "yaoyiyao" or name == "feiqinzoushou" then
		-- 	skeleton_animation:setPositionY(size.height*0.47)
		-- elseif name == "benchibaoma" then
		-- 	skeleton_animation:setPositionY(size.height*0.47)
		-- elseif name == "dianzijingcai" then
		-- 	-- skeleton_animation:setPositionY(size.height*0.4)
		-- 	skeleton_animation:setPositionX(size.width/2-3)
		-- elseif name == "guanggao1" then
		-- 	skeleton_animation:setPositionY(size.height*0.5+20)
		-- 	skeleton_animation:setPositionX(size.width/2-10)
		-- elseif name == "dezhoupuke" then
		-- 	skeleton_animation:setPositionY(size.height*0.53)
		-- end
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

	if name ~= "guanggao1" and name ~= "leyingguibinting" and name ~= "woshihehuoren" then
		table.insert(self.updateBtn, downBtn)
	end

	return btn
end

--下载点击
function GameListLayer:onClickBtn(sender,isPlay)
	local gameName = sender:getName()
	local node = sender:getChildByName(gameName)

	luaPrint("download   "..gameName)

	if isPlay ~= nil then
		playEffect("sound/sound-hall-selected.mp3")
		node.isTip = true
		self["click"..gameName] = true
	end

	if gameName == "leyingguibinting" then
		VipInfo:sendGetVipInfo()
		return
	elseif gameName == "woshihehuoren" then
		display.getRunningScene():addChild(require("layer.popView.newExtend.hehuoren.Partner"):create())
		return
	elseif gameName == "shisanzhang" then
		addScrollMessage("即将上线")
		return
	end

	-- if gameName == "dianzijingcai" then
	-- 	addScrollMessage("当前暂无可投注赛事")
	-- else
		if not NO_UPDATE then
			local temp = GameConfig.serverVersionInfo.gameListInfo
			if globalUnit.isNewVersion == true then
				temp = GameConfig.serverZipVersionInfo.gameListInfo
			end

			for k,v in pairs(temp) do
				if v.gameName == gameName and v.isDownMD5 ~= true then
					local layer = LoadingLayer:createLoading(FontConfig.gFontConfig_24, GBKToUtf8("正在加载资源,请稍后"), LOADING)
					layer:removeTimer(10)
					-- layer:removeChildByName("loadImage")
					layer:updateLayerOpacity(0)
					local text = layer:getChildByName("enterText")
					text:setPositionY(winSize.height/2)
					text:setColor(FontConfig.colorWhite)
					UpdateManager:startDownload(gameName,true)
					return
				end
			end
		end

		if isPlay == 1 then
			globalUnit.gameName = gameName
		end

		if self.callback then
			self.callback(node,gameName)
		else
			dispatchEvent("downloadGame",{node,gameName})
		end
	-- end
end

function GameListLayer:onClick(sender)
	local tag = sender:getTag()

	if tag == 2 then
		self:delayCloseLayer(0,function() dispatchEvent("exitCreateRoom",1) end)
	elseif tag == 0 or tag == 1 then
		self:listViewSlider(tag)
	elseif tag == 3 then
		if copyToClipBoard(GameConfig.appVerUrl) then
			addScrollMessage("网址复制成功")
		end
	elseif tag == 4 then
		addScrollMessage("当前暂无可投注赛事")
	end
end

--左右箭头处理
function GameListLayer:listViewSlider(tag,flag)
	if #self.sGameName <= 6 then
		for k,v in pairs(self.listViewBtn) do
			v:hide()
		end
		return
	else
		for k,v in pairs(self.listViewBtn) do
			v:show()
		end
	end

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

function GameListLayer:onScrollEvent(event)
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
function GameListLayer:setDownCallback(func)
	self.callback = func
end

--点击下载时，同步其他的按钮
function GameListLayer:syncSameGameUpdate(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v ~= data[1] and v:getName() == data[2] then
			self:onClickBtn(v:getParent())
		end
	end
end

function GameListLayer:restartDownload(data)
	if not NO_UPDATE then
		for k,v in pairs(self.updateBtn) do
			--非未下载状态，同步下载状态
			local info = UpdateManager:getDownLoadInfo(v,v:getName())
			luaDump(info,"非未下载状态，同步下载状态")
			if info and info.gameName ~= "shisanzhang" then
				if info.downloadState == STATUE_DOWNING then
					v:show()
					self:onClickBtn(v:getParent())
				elseif info.downloadState == STATUE_HAVEUPDATE then
					v:show()
				end
			else
				-- v:show()
			end
		end
	end
end

function GameListLayer:receiveExitCreateRoom(data)
	if data then
		data = data._usedata
	end

	if data == nil then
		self:resetViewPos()

		self:playEffect()
	end
end

function GameListLayer:resetViewPos()
	local y = 130;

	-- self.topImage:setPositionY(self.topImage:getPositionY()+y)
	-- self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

	self.activeBtn:setScale(0)

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

function GameListLayer:playEffect()
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
		cc.ScaleTo:create(dt,1.15),cc.ScaleTo:create(dt/3,1)
		)

	self.activeBtn:runAction(seq)

	-- local seq = cc.Sequence:create(
	-- 	cc.DelayTime:create(7/unit),
	-- 	cc.MoveBy:create(15/unit,cc.p(0,-y-20)),
	-- 	cc.MoveBy:create(3/unit,cc.p(0,20))
	-- )
	-- self.topImage:runAction(seq)

	-- local seq = cc.Sequence:create(
	-- 	cc.DelayTime:create(7/unit),
	-- 	cc.MoveBy:create(15/unit,cc.p(0,y+20)),
	-- 	cc.MoveBy:create(3/unit,cc.p(0,-20))
	-- )
	-- self.bottomNode:runAction(seq)
end

function GameListLayer:reDownload(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v:getName() == data then
			self:onClickBtn(v:getParent())
			break
		end
	end
end

function GameListLayer:startDownload(data)
	if not NO_UPDATE then
		local data = data._usedata

		for k,v in pairs(self.updateBtn) do
			if v:getName() == data then
				--非未下载状态，同步下载状态
				local info = UpdateManager:getDownLoadInfo(v,v:getName())
				luaDump(info,"非未下载状态，同步下载状态")
				local ret = false
				if info then
					v.isTip = false
					if info.downloadState == STATUE_DOWNING then
						v:show()
						self:onClickBtn(v:getParent())
					elseif info.downloadState == STATUE_HAVEUPDATE then
						v:show()
						self:onClickBtn(v:getParent())
					elseif info.downloadState == STATUE_NOUPDATE then
						if self["click"..data] ~= true then
							return
						end
						ret = true
						LoadingLayer:removeLoading()
						self:onClickBtn(v:getParent(),1)
					end
				end

				if not ret then
					performWithDelay(self,function() LoadingLayer:removeLoading() end,0.5)
				end
				break
			end
		end
	end
end

function GameListLayer:onReceiveRestartDownloadSuccess(data)
	luaPrint("NO_UPDATE ",NO_UPDATE," isAutoXiufu ",isAutoXiufu)
	if NO_UPDATE == false and isAutoXiufu == true then
		isAutoXiufu = nil
		self:restartDownload(data)
	end
end

return GameListLayer

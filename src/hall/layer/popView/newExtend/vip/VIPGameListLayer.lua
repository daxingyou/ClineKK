local VIPGameListLayer = class("VIPGameListLayer", BaseWindow)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function VIPGameListLayer:ctor(gamePath,RoomStates)
	self.super.ctor(self)

	self.gamePath = gamePath;
	self.RoomStates = RoomStates;
	luaDump(self.gamePath,"self.gamePath")
	self:initData()

	self:initUI()

	self:bindEvent()
end

function VIPGameListLayer:create(gamePath,RoomStates)
	local layer = VIPGameListLayer.new(gamePath,RoomStates)
	return layer;
end

function VIPGameListLayer:initData()
	self.updateBtn = {}
	self.skBtn = {}
	self.listViewBtn = {}
	-- self.chooseRoomTable = {{0,0},{0},{0},{0},{0},{0},{0},{0,0,0,0},{0,0,0},
 --                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0,0,0,0,0}}
    self.sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_fqzs","game_yyy","game_slhb",
            "dz_ddz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","game_ppc"}
    self.gameNameAllList = {"百人牛牛","百家乐","龙虎斗","红黑大战","飞禽走兽","骰宝","扫雷红包","斗地主",
                            "德州扑克","扎金花","21点","十点半","抢庄牛牛","二人牛牛","奔驰宝马"};
    self.selectGame = "0000"
    -- if runMode == "release" then
    -- 	self.sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_fqzs","game_ppc",
    --         "dz_ssz","dz_ddz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","lkpy_0"}
    -- 	self.gameNameAllList = {"百人牛牛","百家乐","龙虎斗","红黑大战","骰宝","飞禽走兽","奔驰宝马","十三张","斗地主",
    --                         "德州扑克","扎金花","21点","十点半","抢庄牛牛","二人牛牛","捕鱼合集"};
    -- end
end

function VIPGameListLayer:getRoomBySGameName(sGameName)
	local roomList = VipRoomInfoModule:getRoomListBysGameName(sGameName)
	-- luaDump(roomList,"roomList1")
	luaPrint(self.RoomStates)
	for k,v in pairs(roomList) do
		local idx = string.sub(self.RoomStates,v,v)
		if idx == "1" then
			roomList[k] = 1;
		else
			roomList[k] = 0;
		end 
	end
	-- luaDump(roomList,"roomList2")
	return roomList;
	-- local index = 1;
 --    for k,roomTable in pairs(self.chooseRoomTable) do
 --        for j,v in pairs(roomTable) do
 --            local idx = string.sub(self.RoomStates,index,index) 
 --            self.chooseRoomTable[k][j] = tonumber(idx)
 --            index = index + 1;
 --        end
 --    end

 --    local num = 0
 --    for k,v in pairs(self.sGameName) do
 --    	if sGameName == v then
 --    		num = k
 --    	end
 --    end

 --    return self.chooseRoomTable[num]
end

function VIPGameListLayer:bindEvent()
	self.bindIds = {}
	-- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_GameList",function () self:refreshGameList() end);

	self:pushGlobalEventInfo("notifySameGameUpdate",handler(self,self.syncSameGameUpdate))
	-- self:pushGlobalEventInfo("exitCreateRoom",handler(self, self.receiveExitCreateRoom))
	self:pushGlobalEventInfo("reDownload",handler(self, self.reDownload))--下载失败重新下载
	self:pushGlobalEventInfo("startDownload",handler(self, self.startDownload))
	-- self:pushGlobalEventInfo("I_P_M_RoomList",handler(self, self.refreshGameList))
	self:pushGlobalEventInfo("restartDownload",handler(self, self.restartDownload))
end

function VIPGameListLayer:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
		return;
	end

	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end
end

function VIPGameListLayer:onExit()
	self.super.onExit(self)
	
	self:unBindEvent()
end

function VIPGameListLayer:onEnterTransitionFinish()
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
				-- v:show()
			end
		end
	end

	self.super.onEnterTransitionFinish(self)

	-- self:receiveExitCreateRoom()
end

function VIPGameListLayer:onExit()
	for k,v in pairs(self.updateBtn) do
		dispatchEvent("removeUpdateNotify",{v:getName(),v})
	end

	clearCache(nil,true,true)

	self.super.onExit(self)
end

function VIPGameListLayer:initUI()
	self:setLocalZOrder(999)
	--游戏列表
	self:createGameList()

	-- if checkIphoneX() then
	-- 	btn:setPositionX(safeX + btn:getContentSize().width/2)
	-- end

	local size = winSize

	-- if ret then
		--左滑按钮呢
		local btn = ccui.Button:create("newExtend/vip/viphall/zuo.png","newExtend/vip/viphall/zuo-on.png")
		btn:setPosition(20, self.maskLayout:getContentSize().height*0.65+20)
		btn:setTag(0)
		-- btn:setScale(-1)
		self.maskLayout:addChild(btn)
		btn:onClick(handler(self, self.onClick))
		btn:hide()
		--btn:setPositionX(self.activeBtn:getContentSize().width+safeX*2)
		self.leftBtn = btn
		btn.mx = -15
		btn.mdt = 15/80

		-- if checkIphoneX() then
		-- 	btn:setPositionX(safeX+btn:getPositionX())
		-- end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)

		--右滑按钮
		local btn = ccui.Button:create("newExtend/vip/viphall/you.png","newExtend/vip/viphall/you-on.png")
		btn:setPosition(self.maskLayout:getContentSize().width*0.99, self.maskLayout:getContentSize().height*0.65+20)
		btn:setTag(1)
		self.maskLayout:addChild(btn)
		btn:hide()
		btn:onClick(handler(self, self.onClick))
		self.rightBtn = btn
		btn.mx = 15
		btn.mdt = 15/80

		-- if checkIphoneX() then
		-- 	btn:setPositionX(winSize.width-safeX-btn:getContentSize().width)
		-- end

		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)
	-- end
	self:listViewSlider(0)
end

function VIPGameListLayer:createGameList()
	local gameList = GamesInfoModule._gameNames

	self.gameList = gameList or {}
	-- luaDump(self.gameList)

	table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID; end)

	local mask = ccui.Layout:create()
	-- mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
	-- mask:setBackGroundColor(cc.c3b(255, 0, 0))
	mask:setPosition(1280*0.07,0)
	mask:setContentSize(950,450)
	mask:setName("mask1")
	self:addChild(mask)
	self.maskLayout = mask;

	-- if checkIphoneX() then
	-- 	local framesize = cc.Director:getInstance():getWinSize()
	-- 	mask:ignoreContentAdaptWithSize(false)
	-- 	mask:setContentSize(cc.size(framesize.width,mask:getContentSize().height))
	-- 	mask:setPositionX(winSize.width/2)
	-- end

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.horizontal)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(mask:getContentSize().width*0.98, mask:getContentSize().height+50))
	listView:setPosition(mask:getContentSize().width*0.5,mask:getContentSize().height*0.65+15)
	listView:setScrollBarEnabled(false)
	mask:addChild(listView)
	self.listView = listView

	if checkIphoneX() then
		-- listView:setContentSize(cc.size(mask:getContentSize().width-self.activeBtn:getContentSize().width-safeX, mask:getContentSize().height))
		-- listView:setPosition(self.activeBtn:getContentSize().width+safeX+listView:getContentSize().width/2,mask:getContentSize().height*0.5)
	end

	listView:onScroll(handler(self, self.onScrollEvent))
	--local path = {"doudizhu","buyuheji","bairenpinshi","kuaile30miao","longhudou","hongheidazhan","yaoyiyao","feiqinzoushou","dezhoupuke","sanzhangpai","21dian","10dianban","qiangzhuangpinshi","errenpinshi","benchibaoma"}
	
	local count = 0

	local len = math.ceil(#self.gamePath/2)

	for i=1,len do
		local layout = self:createGroup(i,len)
		self.listView:pushBackCustomItem(layout)
	end

	-- if checkIphoneX() then
	-- 	local layout = ccui.Layout:create()
	-- 	layout:setContentSize(cc.size(safeX*1.5, 355))
	-- 	self.listView:pushBackCustomItem(layout)
	-- end

	return count
end

function VIPGameListLayer:createGroup(tag,len)
	local path = {"doudizhu","buyuheji","bairenpinshi","kuaile30miao","longhudou","hongheidazhan","yaoyiyao","feiqinzoushou","saoleihongbao","shisanzhang","dezhoupuke","sanzhangpai","21dian","10dianban","qiangzhuangpinshi","errenpinshi","chaojishuiguoji","benchibaoma","tangguopaidui","lianhuanduobao"}
	local gameName = {"doudizhu","fishing","bairenniuniu","baijiale","longhudou","hongheidazhan","yaoyiyao","fqzs","saoleihongbao","shisanzhang","dezhoupuke","sanzhangpai","ershiyidian","shidianban","qiangzhuangniuniu","errenniuniu","superfruitgame","benchibaoma","sweetparty","lianhuanduobao"}
	local sGameName = {"dz_ddz","lkpy_0","game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_fqzs","game_slhb","dz_ssz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","dz_shuiguoji","game_ppc","game_tgpd","game_lhdb"}
	local counts = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

	-- if runMode == "release" then
		 path = {"bairenpinshi","kuaile30miao","longhudou","hongheidazhan","yaoyiyao","saoleihongbao","qiangzhuangpinshi","feiqinzoushou","errenpinshi","benchibaoma","doudizhu","sanzhangpai"}
		 gameName = {"bairenniuniu","baijiale","longhudou","hongheidazhan","yaoyiyao","saoleihongbao","qiangzhuangniuniu","fqzs","errenniuniu","benchibaoma","doudizhu","sanzhangpai"}
		 sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_slhb","dz_qzps","game_fqzs","dz_ernn","game_ppc","dz_ddz","dz_szp"}
		 counts = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	-- end

	for k=#self.gamePath,1,-1 do
		local ishave = false
        for kk,vv in pairs(sGameName) do
            if self.gamePath[k] == sGameName[kk] then
                ishave = true;
                break;
            end
        end
        if ishave == false then
            table.remove(self.gamePath,k)
        end
	end

	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(290, 450))

	local index = -1;
	local tempGameName = self.gamePath[tag];
	for k,v in pairs(sGameName) do
		if tempGameName == v then
			index = k;
		end
	end
	
	local _path = path[index]
	local _gameName = gameName[index]
	local _counts = counts[index]
	local _sGameName = sGameName[index]
	-- luaPrint("------createGroup11111111111-----",tempGameName,_path,_gameName,_counts)
	if tempGameName then
		local node = self:createGameItem(_path,_gameName,_counts,_sGameName)
		node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.75)
		layout:addChild(node)
	end

	tag = tag + len

	if tag <= #path then

		local index = -1;
		local tempGameName = self.gamePath[tag];
		for k,v in pairs(sGameName) do
			if tempGameName == v then
				index = k;
			end
		end
		local _path = path[index]
		local _gameName = gameName[index]
		local _counts = counts[index]
		local _sGameName = sGameName[index]
		-- luaPrint("------createGroup2222222222-----",tempGameName,_path,_gameName,_counts)
		if tempGameName then
			local node = self:createGameItem(_path,_gameName,_counts,_sGameName)
			node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.25)
			layout:addChild(node)
		end
	end

	return layout
end

function VIPGameListLayer:createGameItem(name,gameName,count,sGameName)
	local size = cc.size(280, 220)

	local num = 0
    for k,v in pairs(self.sGameName) do
    	if sGameName == v then
    		num = k
    	end
    end
    
	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	-- btn:setScale(0)
	btn:setName(gameName)
	btn:setTag(num)
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

	if ret == true then
		if name == "doudizhu" then
		-- 	skeleton_animation:setPositionY(size.height*0.53)
		-- elseif name == "qiangzhuangpinshi" or name == "errenpinshi" then
		-- 	skeleton_animation:setPositionY(size.height*0.42)
		-- elseif name == "sanzhangpai" then
		-- 	skeleton_animation:setPositionY(size.height*0.42)
		elseif name == "buyuheji" then
			skeleton_animation:setPositionY(size.height*0.53)
		-- elseif name == "bairenpinshi" then
		-- 	skeleton_animation:setPositionY(size.height*0.45)
		-- elseif name == "kuaile30miao" then
		-- 	skeleton_animation:setPositionY(size.height*0.45)
		-- elseif name == "yaoyiyao" or name == "feiqinzoushou" then
		-- 	skeleton_animation:setPositionY(size.height*0.47)
		elseif name == "dezhoupuke" then
			skeleton_animation:setPositionY(size.height*0.53)
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
	skeleton_animation:setPositionY(skeleton_animation:getPositionY()+15)
	--下载按钮
	local downBtn = ccui.ImageView:create("hall/down.png")
	downBtn:setAnchorPoint(0.5,0)
	downBtn:setPosition(size.width-downBtn:getContentSize().width/2,downBtn:getContentSize().height/4)
	btn:addChild(downBtn)
	downBtn:setName(gameName)
	downBtn:hide()

	table.insert(self.updateBtn, downBtn)
	downBtn.isHideTip = true

	return btn
end

--下载点击
function VIPGameListLayer:onClickBtn(sender,isPlay)
	local gameName = sender:getName()
	local tag = sender:getTag()
	local node = sender:getChildByName(gameName)

	luaPrint("download   "..gameName)

	if isPlay ~= nil then
		playEffect("sound/sound-hall-selected.mp3")
		node.isTip = true
	end

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

	if self.callback then
		self.callback(node,gameName)
	else
		globalUnit.VipRoomList = self:getRoomBySGameName(self.sGameName[tag])
		luaDump(globalUnit.VipRoomList,"globalUnit.VipRoomList")
		dispatchEvent("downloadGame",{node,gameName})

		-- local roomList = self:getRoomBySGameName(self.sGameName[tag])
		-- self:createRoom(self.sGameName[tag],roomList,tag);
	end
end

function VIPGameListLayer:createRoom(gameName,roomList,num)
	
	self.selectGame = gameName;
	self:refreshGameList()
	self.maskLayout:setVisible(false)

	local mask2 = ccui.Layout:create()
	-- mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
	-- mask:setBackGroundColor(cc.c3b(255, 0, 0))
	--mask:setPosition(self:getContentSize().width/2,self:getContentSize().height/2-120)
	mask2:setContentSize(1020,450)
	mask2:setName("mask2")
	self:addChild(mask2)

	local guatiao = ccui.ImageView:create("newExtend/vip/viphall/guatiao.png")
    guatiao:setPosition(mask2:getContentSize().width-50,mask2:getContentSize().height-38)
    guatiao:setAnchorPoint(cc.p(0.5,0.5))
    mask2:addChild(guatiao)

    -- local Label_name = FontConfig.createWithSystemFont("二\n人\n牛\n牛",26 ,FontConfig.colorBlack);
    -- Label_name:setPosition(mask2:getContentSize().width-50,mask2:getContentSize().height-30)
    -- Label_name:setAnchorPoint(cc.p(0.5,0.5))
    -- mask2:addChild(Label_name)

    local Label_name = FontConfig.createWithSystemFont(self:changeNameErect(self.gameNameAllList[num]),26 ,FontConfig.colorBlack);
    Label_name:setPosition(guatiao:getContentSize().width/2,guatiao:getContentSize().height/2+5)
    Label_name:setContentSize(cc.size(50,140))
    Label_name:setAnchorPoint(cc.p(0.5,0.5))
    guatiao:addChild(Label_name)

    local teamCount = 0
    luaPrint("VIPGameListLayer:createRoom",gameName)
    if string.find(gameName,"game_") then -- 百人游戏
        for k,room in pairs(roomList) do
        	if room == 1 then
                if k > 2 then --TODO 现在有12个房间
                    break; 
                end 
                teamCount = teamCount +1
                local typeset_brnn = ccui.Button:create("newExtend/vip/typeset/"..k..".png","newExtend/vip/typeset/"..k.."-on.png")
                typeset_brnn:setPosition(mask2:getContentSize().width*0.1 + 300*(teamCount-1),mask2:getContentSize().height*0.5)
                typeset_brnn:setAnchorPoint(cc.p(0,0))
                typeset_brnn:setTag(k)
                typeset_brnn:onClick(handler(self, self.onClickRoomBtn))
                mask2:addChild(typeset_brnn)

                local size = typeset_brnn:getContentSize();
                local name = {"xianjinchang"}
                if gameName == "game_brps" then
	                name = {"xianjin4bei","xianjin10bei"}
	            end
	            local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[k]..".png")
			    biaoti:setPosition(size.width/2,size.height*0.7)
			    typeset_brnn:addChild(biaoti)

			    local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
			    gold:setPosition(size.width*0.75,size.height*0.3)
			    typeset_brnn:addChild(gold)

			    local ruchang = ccui.ImageView:create("newExtend/vip/typeset/ruchang.png")
			    ruchang:setPosition(size.width*0.68,size.height*0.51)
			    typeset_brnn:addChild(ruchang)

			    local minRoomKey = self.RoomMinNeedMoney[num][k]--RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                xianzhi:setPosition(size.width*0.4,size.height*0.52)
                typeset_brnn:addChild(xianzhi)

                local minRoomKey = self.RoomMinNeedMoney[num][k]--RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                xianzhi:setPosition(size.width*0.45,size.height*0.3)
                typeset_brnn:addChild(xianzhi)
			    
            end
        end
    elseif string.find(gameName,"dz_") then --对战游戏
        for k,room in pairs(roomList) do
            -- if RoomInfoModule:isCashRoom(room.uNameID,room.uRoomID) then --非体验场
            if  room == 1 then
            	teamCount = teamCount +1
            	local x = mask2:getContentSize().width*0.1 + 270*(teamCount-1);
            	local y = mask2:getContentSize().height/2;
            	if #roomList > 3 then
            		if teamCount > 3 then
            			y = 0--mask2:getContentSize().height*0.1;
            			x = mask2:getContentSize().width*0.1+270*(teamCount-4);
            		else
            			y = mask2:getContentSize().height*0.5;
            		end
            	end
            	if gameName == "dz_ddz" then
                    if k>2 then
                        return;
                    end
                end

                local typeset_dz = ccui.Button:create("newExtend/vip/typeset/"..k..".png","newExtend/vip/typeset/"..k.."-on.png")
                typeset_dz:setPosition(x,y)
                typeset_dz:setAnchorPoint(cc.p(0,0))
                typeset_dz:setTag(k)
                typeset_dz:onClick(handler(self, self.onClickRoomBtn))
                mask2:addChild(typeset_dz)

                local size = typeset_dz:getContentSize();

                local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
			    gold:setPosition(size.width*0.75,size.height*0.3)
			    typeset_dz:addChild(gold)

			    local ruchang = ccui.ImageView:create("newExtend/vip/typeset/difen.png")
			    ruchang:setPosition(size.width*0.68,size.height*0.51)
			    typeset_dz:addChild(ruchang)

                local minRoomKey = self.RoomMinNeedMoney[num][k]--RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                xianzhi:setPosition(size.width*0.45,size.height*0.3)
                typeset_dz:addChild(xianzhi)

                local difennum = self.RoomDifen[num][k]
                local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                difen:setPosition(size.width*0.4,size.height*0.52)
                typeset_dz:addChild(difen)

                
                local name = {"pingmin","xiaozi","laoban","fuhao"}
                if gameName == "dz_ddz" then
                	name = {"jindian","buxipai"}
                end
                local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[k]..".png")
			    biaoti:setPosition(size.width/2,size.height*0.7)
			    typeset_dz:addChild(biaoti)

			    if gameName == "dz_dzpk" then
                	ruchang:loadTexture("newExtend/vip/typeset/xianzhi.png")
                	ruchang:setPosition(size.width*0.35,size.height*0.51)
                	xianzhi:setPosition(size.width*0.6,size.height*0.52)
                	gold:loadTexture("newExtend/vip/typeset/xiaomangzhu.png")
                	gold:setPosition(size.width*0.4,size.height*0.32)
                	difen:setPosition(size.width*0.7,size.height*0.32)

                	local damangzhu = ccui.ImageView:create("newExtend/vip/typeset/damangzhu.png")
				    damangzhu:setPosition(size.width*0.4,size.height*0.22)
				    typeset_dz:addChild(damangzhu)

                	local difen1 = FontConfig.createWithCharMap(difennum*2, "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
	                difen1:setPosition(size.width*0.7,size.height*0.22)
	                typeset_dz:addChild(difen1)
                end

            end
        end
    elseif string.find(gameName,"lkpy_") then --捕鱼
    	-- luaDump(roomList,"roomList11111111111")
        for k,room in pairs(roomList) do
            -- if RoomInfoModule:isCashRoom(room.uNameID,room.uRoomID) then --非体验场
            if  room == 1 then
            	teamCount = teamCount +1
                local x = mask2:getContentSize().width*0.05 + 220*(teamCount-1);
            	local y = mask2:getContentSize().height/2;
            	if #roomList > 4 then
            		if teamCount > 4 then
            			y = 0--mask2:getContentSize().height*0.01;
            			x = mask2:getContentSize().width*0.05+220*(teamCount-5);
            		else
            			y = mask2:getContentSize().height*0.5;
            		end
            	end
            	local kk = k
                if kk>4 then
                	kk = kk-4
                end

                local typeset_dz = ccui.Button:create("newExtend/vip/typeset/"..kk..".png","newExtend/vip/typeset/"..kk.."-on.png")
                typeset_dz:setPosition(x,y)
                -- typeset_dz:setScale(0.9)
                typeset_dz:setAnchorPoint(cc.p(0,0))
                typeset_dz:setTag(k)
                typeset_dz:setName("fish")
                typeset_dz:onClick(handler(self, self.onClickRoomBtn))
                mask2:addChild(typeset_dz)

                local size = typeset_dz:getContentSize();

                local name = {"xinshouyucun","yongzhehaiwan","shenhailieshou","haiyangshenhua"}
                
                local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[kk]..".png")
                biaoti:setPosition(size.width/2,size.height*0.7)
                typeset_dz:addChild(biaoti)
                if k >4 then
                	name ="danren"
                else
                	name ="duoren"
                end
                local tip = ccui.ImageView:create("newExtend/vip/typeset/"..name..kk..".png")
                tip:setPosition(size.width/2,size.height*0.85)
                typeset_dz:addChild(tip)

                local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
                gold:setPosition(size.width*0.75,size.height*0.3)
                typeset_dz:addChild(gold)

                local ruchang = ccui.ImageView:create("newExtend/vip/typeset/bei.png")
                ruchang:setPosition(size.width*0.72,size.height*0.51)
                typeset_dz:addChild(ruchang)

                local minRoomKey = self.RoomMinNeedMoney[num][k]--RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                xianzhi:setPosition(size.width*0.45,size.height*0.3)
                typeset_dz:addChild(xianzhi)

                name = {"0.01-0.1","0.1-1","1-10","10-55"}

                local difennum = name[kk]
                local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                difen:setPosition(size.width*0.45,size.height*0.52)
                typeset_dz:addChild(difen)
                if k== 1 or k== 1+4 then
                    difen:setScale(0.7)
                end
            end
        end
    end
end

function VIPGameListLayer:onClickRoomBtn(sender)
	local tag = sender:getTag()
	local name = sender:getName()
	local num = #self.roomList 
	-- addScrollMessage("当前选择的游戏game = "..self.selectGame.." 当前选择的游戏index ="..tag.."roomListnum= "..num)
	
	if  num == 0 then
		return;
	end
	if name == "fish" then
		local roomid = {4,5,6,7,8,9,10,11}
		if tag<=4 then
			self.m_selectedNameID = 40010000;
		else
			self.m_selectedNameID = 40010004;
		end
		self.m_selectedRoomID = roomid[tag]
	else
		self.m_selectedRoomID = self.roomList[tag].uRoomID
	end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)
	if gold then
		globalUnit:setEnterGameID(self.m_selectedNameID.."_"..self.m_selectedRoomID)
		self:getMatchRoomMinRoomKey(gold,"最低需要"..goldConvert(gold).."金币以上！")
	else
		local msg = {}
		msg.iNameID = self.m_selectedNameID
		msg.iRoomID = self.m_selectedRoomID
		PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY)
	end
	
		
end

function VIPGameListLayer:getMatchRoomMinRoomKey(data,msg)
	self.m_nMatchMinRoomKey = data
	globalUnit.nMinRoomKey = data

	self:showCreateRoomLayer(msg)
end

function VIPGameListLayer:showCreateRoomLayer(msg)
	if PlatformLogic.loginResult.i64Money < self.m_nMatchMinRoomKey then
		addScrollMessage("抱歉，您的金币低于入场最低限制"..string.format("%.2f",goldConvert(globalUnit.nMinRoomKey)).."，不能进入该游戏房间！")
		return
	end

	dispatchEvent("matchRoom",self.m_selectedRoomID)
end

function VIPGameListLayer:refreshGameList()
	local VisibleCount = 0

	VisibleCount = #self.gameList

	if VisibleCount == 0 then
		dispatchEvent("requestGameList")
	else
		local ret = false
		local index = 0
		for k,v in pairs(self.gameList) do
			if string.find(v.szGameName,self.selectGame) then
				ret = true
				self.m_selectedNameID = v.uNameID
				index = k
				break
			end
		end

		if ret then
			-- //设置当前游戏
			GameCreator:setCurrentGame(self.m_selectedNameID);

			local roomList = RoomInfoModule:getRoomInfoByNameID(self.gameList[index].uNameID)

			self.roomList = roomList or {}
			-- luaDump(self.roomList,"self.roomList")
			table.sort(self.roomList, function(a,b) return a.uRoomID < b.uRoomID end)

			if #self.roomList == 0 then
				dispatchEvent("requestRoomList")
			else
				-- if self.touchLayer then
				-- 	self.touchLayer:removeSelf()
				-- 	self.touchLayer = nil
				-- end
			end
		end
	end
end

function VIPGameListLayer:onClick(sender)
	local tag = sender:getTag()

	if tag == 2 then
		self:delayCloseLayer(0,function() dispatchEvent("exitCreateRoom",1) end)
	elseif tag == 0 or tag == 1 then
		self:listViewSlider(tag)
	elseif tag == 3 then
		if copyToClipBoard(GameConfig.appVerUrl) then
            addScrollMessage("网址复制成功")
        end
	end
end

--左右箭头处理
function VIPGameListLayer:listViewSlider(tag,flag)
	if #self.gamePath <= 8 then
		return;
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

function VIPGameListLayer:onScrollEvent(event)
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
function VIPGameListLayer:setDownCallback(func)
	self.callback = func
end

--点击下载时，同步其他的按钮
function VIPGameListLayer:syncSameGameUpdate(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v ~= data[1] and v:getName() == data[2] then
			self:onClickBtn(v:getParent())
		end
	end
end

function VIPGameListLayer:restartDownload(data)
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
				-- v:show()
			end
		end
	end
end

function VIPGameListLayer:receiveExitCreateRoom(data)
	if data then
		data = data._usedata
	end

	if data == nil then
		self:resetViewPos()

		self:playEffect()
	end
end

function VIPGameListLayer:resetViewPos()
	local y = 130;

	-- self.topImage:setPositionY(self.topImage:getPositionY()+y)
	-- self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

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

function VIPGameListLayer:playEffect()
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

function VIPGameListLayer:reDownload(data)
	local data = data._usedata

	for k,v in pairs(self.updateBtn) do
		if v:getName() == data then
			self:onClickBtn(v:getParent())
			break
		end
	end
end

function VIPGameListLayer:startDownload(data)
	if not NO_UPDATE then
		local data = data._usedata
		for k,v in pairs(self.updateBtn) do
			if v:getName() == data then
				--非未下载状态，同步下载状态
				local info = UpdateManager:getDownLoadInfo(v,v:getName())
				luaDump(info,"非未下载状态，同步下载状态")
				if info then
					v.isTip = false
					if info.downloadState == STATUE_DOWNING then
						v:show()
						self:onClickBtn(v:getParent())
					elseif info.downloadState == STATUE_HAVEUPDATE then
						v:show()
						self:onClickBtn(v:getParent())
					elseif info.downloadState == STATUE_NOUPDATE then
						self:onClickBtn(v:getParent())
					end
				end
				performWithDelay(self,function() LoadingLayer:removeLoading() end,0.5)
				break
			end
		end
	end
end

--改变名字的竖直(21点特殊)
function VIPGameListLayer:changeNameErect(gameName)
  local name = ""
  if gameName == "21点" then
    name = "21\n点"
  else
    if #gameName > 3 then--两个字
      name = string.sub(gameName,1,3).."\n"..string.sub(gameName,4,6)
    end
    if #gameName > 6 then--三个字
      name = name.."\n"..string.sub(gameName,7,9)
    end
    if #gameName > 9 then--四个字
      name = name.."\n"..string.sub(gameName,10,12)
    end
  end
  return name;
end

return VIPGameListLayer

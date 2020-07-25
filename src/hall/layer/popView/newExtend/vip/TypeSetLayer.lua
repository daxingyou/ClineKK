local TypeSetLayer = class("TypeSetLayer", BaseWindow)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function TypeSetLayer:create(isLoad,gameRule,roomRule)
    return TypeSetLayer.new(isLoad,gameRule,roomRule);
end

function TypeSetLayer:ctor(isLoad,gameRule,roomRule)
    self.super.ctor(self, 0, true)

    self.isLoad = isLoad;
    self.gameRule = gameRule or 0;
    self.roomRule = roomRule or 0;
    
    self:initData();
    self:initUI();
    self:bindEvent();
end

function TypeSetLayer:initData()
    self.gameList = {};--游戏列表
    self.chooseGameName = ""--当前选择的游戏名字(game_ppc)

    self.sGameName = {};
    self.gameNameAllList = {};

    self.gameBtn = {};
    self.gameNode = {};
    self.allGameListLayout1 = {};--全部的layout
    self.allGameListLayout2 = {};--分开的layout
    self.allRoomListNode = {};
    self.isRoomMode = 0; --1多人 0单人
    self.count = 0;
end

function TypeSetLayer:bindEvent()
    -- self.bindIds = {}

    self:pushGlobalEventInfo("I_P_M_RoomList",handler(self, self.refreshGameList))
end

function TypeSetLayer:unBindEvent()
    if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function TypeSetLayer:onExit()
    self.super.onExit(self)

    self:unBindEvent()
end


function TypeSetLayer:initUI()
    self:setName("TypeSetLayer")
    self:setLocalZOrder(9999)
    self:initBg();
    self:initGameList();
end

function TypeSetLayer:initBg()
    local bg = ccui.ImageView:create("newExtend/vip/common/bgtype.png")
    bg:setPosition(getScreenCenter())
    self:addChild(bg)

    self.bg = bg
    
    self.size = bg:getContentSize()

    local ding = ccui.ImageView:create("newExtend/vip/common/ding.png")
    ding:setPosition(self.size.width/2,self.size.height-35)
    ding:setAnchorPoint(cc.p(0.5,0.5))
    bg:addChild(ding)

    -- local Image_ziBg = ccui.ImageView:create("newExtend/vip/common/dingzibg.png");
    -- Image_ziBg:setAnchorPoint(0,1);
    -- Image_ziBg:setPosition(-180,self.size.height);
    -- bg:addChild(Image_ziBg);

    local bttitle = ccui.ImageView:create("newExtend/vip/typeset/leixingshezhi.png")
    bttitle:setPosition(430,self.size.height-35)
    bttitle:setAnchorPoint(cc.p(0.5,0.5))
    bg:addChild(bttitle)

    local zhuozi = ccui.ImageView:create("newExtend/vip/typeset/kuang.png")
    zhuozi:setPosition(self.size.width/2,self.size.height*0.40+5)
    zhuozi:setAnchorPoint(cc.p(0.5,0.5))
    bg:addChild(zhuozi)

    -- local youximingchen = ccui.ImageView:create("newExtend/vip/typeset/youximingchen.png")
    -- youximingchen:setPosition(self.size.width*0.15-30,self.size.height*0.8-30)
    -- bg:addChild(youximingchen)

    local sskbg =  ccui.ImageView:create("newExtend/vip/common/sskuangbg.png");
    self.bg:addChild(sskbg);
    sskbg:setPosition(self.size.width*0.75,self.size.height*0.87-8);

    local node = cc.Node:create();
    node:setPosition(self.size.width*0.65-40,self.size.height*0.87-8)
    bg:addChild(node)

    local searchTextEdit,editbg = createEditBox(node," 输入游戏名称",cc.EDITBOX_INPUT_MODE_SINGLELINE,nil,nil,"newExtend/vip/common/shurukuang.png")
    self.searchTextEdit = searchTextEdit;

    local btn_search = ccui.Button:create("newExtend/vip/common/sousuo.png","newExtend/vip/common/sousuo-on.png","newExtend/vip/common/sousuo.png")
    btn_search:setPosition(self.size.width*0.85+5,self.size.height*0.87-8)
    btn_search:setTag(0);
    btn_search:onClick(function(sender) self:onClickBtn(sender); end)
    bg:addChild(btn_search)

    local btn1 = ccui.Button:create("newExtend/vip/common/quanbu.png","newExtend/vip/common/quanbu-on.png","newExtend/vip/common/quanbu2.png")
    btn1:setPosition(self.size.width*0.17,self.size.height*0.87-15)
    bg:addChild(btn1)
    btn1:setTag(1);
    btn1:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn1)

    local btn2 = ccui.Button:create("newExtend/vip/common/bairenchang.png","newExtend/vip/common/bairenchang-on.png","newExtend/vip/common/bairenchang2.png")
    btn2:setPosition(self.size.width*0.17+150,self.size.height*0.87-15)
    bg:addChild(btn2)
    btn2:setTag(2);
    btn2:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn2)

    local btn3 = ccui.Button:create("newExtend/vip/common/duizhanchang.png","newExtend/vip/common/duizhanchang-on.png","newExtend/vip/common/duizhanchang2.png")
    btn3:setPosition(self.size.width*0.17+300,self.size.height*0.87-15)
    bg:addChild(btn3)
    btn3:setTag(3);
    btn3:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn3)

    -- local btn4 = ccui.Button:create("newExtend/vip/common/buyu.png","newExtend/vip/common/buyu-on.png","newExtend/vip/common/buyu2.png")
    -- btn4:setPosition(self.size.width*0.17+450,self.size.height*0.87-15)
    -- bg:addChild(btn4)
    -- btn4:setTag(4);
    -- btn4:onClick(function(sender) self:onClickTypeBtn(sender); end)
    -- table.insert(self.gameBtn,btn4)

    local closeBtn = ccui.Button:create("newExtend/vip/common/fanhui.png","newExtend/vip/common/fanhui-on.png")
    closeBtn:setPosition(0,self.size.height-38)
    closeBtn:setAnchorPoint(cc.p(0,0.5))
    bg:addChild(closeBtn)
    closeBtn:onClick(function(sender) self:removeSelf(); end)

    local qingkongxuanze = ccui.Button:create("newExtend/vip/typeset/qingkongxuanze.png","newExtend/vip/typeset/qingkongxuanze-on.png")
    qingkongxuanze:setPosition(self.size.width*0.4,110)
    qingkongxuanze:setTag(1);
    bg:addChild(qingkongxuanze)
    qingkongxuanze:onClick(function(sender) self:onClickBtn(sender); end)

    local quanxuan = ccui.Button:create("newExtend/vip/typeset/quanxuan.png","newExtend/vip/typeset/quanxuan-on.png")
    quanxuan:setPosition(self.size.width*0.6,110)
    quanxuan:setTag(2);
    bg:addChild(quanxuan)
    quanxuan:onClick(function(sender) self:onClickBtn(sender); end)

    local queren = ccui.Button:create("newExtend/vip/typeset/queren.png","newExtend/vip/typeset/queren-on.png")
    queren:setPosition(self.size.width*0.8,110)
    queren:setTag(3);
    bg:addChild(queren)
    queren:onClick(function(sender) self:onClickBtn(sender); end)

    local node1 = cc.Node:create();--全部游戏的界面
    bg:addChild(node1)
    self.Node_gameAllList = node1
    table.insert(self.gameNode,node1)

    local node2 = cc.Node:create();--百人游戏的界面
    bg:addChild(node2)
    self.Node_gameBrList = node2
    table.insert(self.gameNode,node2)

    local node3 = cc.Node:create();--对战游戏的界面
    bg:addChild(node3)
    self.Node_gameDzList = node3
    table.insert(self.gameNode,node3)

    local node4 = cc.Node:create();--捕鱼游戏的界面
    bg:addChild(node4)
    self.Node_gameByList = node4
    table.insert(self.gameNode,node4)

    local modeBtn = ccui.Button:create("newExtend/vip/typeset/danren.png","newExtend/vip/typeset/danren-on.png")
    modeBtn:setTag(self.isRoomMode)
    modeBtn:setPosition(self.size.width*0.75,self.size.height*0.27)
    modeBtn:setAnchorPoint(0.5,0.5)
    bg:addChild(modeBtn)
    modeBtn:onTouchClick(
        function(sender)
                self:onClickModeBtn(sender)
        end)
    self.modeBtn = modeBtn
    self.modeBtn:setVisible(false)

    local playCounts = {4,6,8}
    local node = cc.Node:create()
    node:setPosition(winSize.width*0.5-180, winSize.height*0.27)
    bg:addChild(node)
    local btnPlayCount = {}
    local function onSel(index)
        luaPrint("sel", index)
		self.nSelPlayCount = index

		for j=1, #playCounts do
			if j~=index then
				btnPlayCount[j]:setEnabled(true)
			else
				btnPlayCount[j]:setEnabled(false)
			end
        end
        self:refreshGameList()
	end
	for i, playCount in ipairs(playCounts) do
		local x = (i-1)*175+self.size.width*0.2
		local y = 0
		
		local btn = ccui.Button:create("newExtend/vip/typeset/"..playCount.."ren.png","newExtend/vip/typeset/"..playCount.."ren-on.png","newExtend/vip/typeset/"..playCount.."ren-l.png")
		btn:setPosition(x, y)
		btn:onClick(function()
			onSel(i)
		end)
		node:addChild(btn)
		table.insert(btnPlayCount, btn)
    end
    onSel(1)
    node:setVisible(false)
    self.playCountNode = node

    local winsize =  cc.Director:getInstance():getWinSize();
    if checkIphoneX() then
        closeBtn:setPositionX(closeBtn:getPositionX()-(winsize.width-1280)/2);
        bttitle:setPositionX(bttitle:getPositionX()-(winsize.width-1280)/2);
    end

end

function TypeSetLayer:initGameList( ... )
    local gameList = GamesInfoModule._gameNames
   
    self.gameList = gameList or {}
    self.chooseGameTable = {}
    self.chooseRoomTable = {}
    for i=1,49 do--游戏个数50-1
        table.insert(self.chooseGameTable,0)
    end
    for i=1,199 do --房间个数200-1
        table.insert(self.chooseRoomTable,0)
    end
    -- self.chooseGameTable = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    -- self.chooseRoomTable = {{0,0},{0},{0},{0},{0},{0},{0},{0,0,0,0},{0,0,0},
    --                 {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    self.sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_fqzs","game_ppc","game_slhb","game_shz","game_tgpd","game_lhdb",
            "dz_ssz","dz_ddz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","dz_shuiguoji","lkpy_0","lkpy_4"}
    self.gameNameAllList = {"百人牛牛","百家乐","龙虎斗","红黑大战","骰宝","飞禽走兽","奔驰宝马","扫雷红包","水浒传","糖果派对","连环夺宝","十三张","斗地主",
                            "德州扑克","扎金花","21点","十点半","抢庄牛牛","二人牛牛","超级水果机","捕鱼达人","捕鱼达人"};
    self.RoomDifen = {{0,0},{0},{0},{0},{0},{0},{0},{0,0,0,0},{0},{0},{0},{1,5,10,20},{0.1,0.1,1,5},{0.5,2,5,10},{0.1,1,5,10},{1,5,10,20},{1,5,10,20},{1,5,10,20},{1,5,10,20},{9,90,900,20},{0,0,0,0},{0,0,0,0}}
    
    -- if runMode == "release" then
        self.sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_fqzs","game_ppc","game_slhb",
                "dz_ddz","dz_szp","dz_qzps","dz_ernn"}
        self.gameNameAllList = {"百人牛牛","百家乐","龙虎斗","红黑大战","骰宝","飞禽走兽","奔驰宝马","扫雷红包","斗地主","扎金花","抢庄牛牛","二人牛牛"};
        self.RoomDifen = {{0,0},{0},{0},{0},{0},{0},{0},{0,0,0,0},{1,1,2,5},{0.1,1,10,50},{1,10,20,50},{1,5,10,20}}
    -- end
    for k,roomTable in pairs(self.chooseGameTable) do
        local idx = string.sub(self.gameRule,k,k) 
        if tonumber(idx) then
            self.chooseGameTable[k] = idx;
        end
    end
    for k,roomTable in pairs(self.chooseRoomTable) do
        local idx = string.sub(self.roomRule,k,k) 
        if tonumber(idx) then
            self.chooseRoomTable[k] = tonumber(idx)
        end
    end
    --初始化数据
    -- self:onClickTypeBtn(self.gameBtn[4])
    self:onClickTypeBtn(self.gameBtn[3])
    self:onClickTypeBtn(self.gameBtn[2])
    self:onClickTypeBtn(self.gameBtn[1])
    --addScrollMessage("-self.isLoad-------"..tostring(self.isLoad)..#self.chooseGameTable..#self.gameRule..#self.chooseRoomTable..#self.roomRule)
    -- addScrollMessage("self.roomRule"..self.roomRule)
    if self.isLoad then--需要加载数据
        local gameRule = self.gameRule;
        -- addScrollMessage("self.gameRule"..#gameRule)
        for i=1,#self.gameRule do
            local idx = string.sub(self.gameRule,i,i) 
            self.chooseGameTable[i] = idx;
            if tonumber(idx) == 1 then --当前该游戏已经选择
                local sGameName = VipRoomInfoModule:getsGameNameByID(i)
                for k,layout in pairs(self.allGameListLayout1) do
                    local gameName1 = layout:getName();
                    local checkBox = layout:getChildByName("checkBox")
                    if checkBox and sGameName == gameName1 then
                        checkBox:setSelected(true)
                        break;
                    end
                end
                for k,layout in pairs(self.allGameListLayout2) do
                    local gameName1 = layout:getName();
                    local checkBox = layout:getChildByName("checkBox")
                    if checkBox and sGameName == gameName1 then
                        checkBox:setSelected(true)
                        break;
                    end
                end
            end
        end
        
        
        for k,roomTable in pairs(self.chooseRoomTable) do
            local idx = string.sub(self.roomRule,k,k) 
            self.chooseRoomTable[k] = tonumber(idx)
            if tonumber(idx) == 1 then
                local sGameName = VipRoomInfoModule:getsGameNameByID(k)
                local Node =  self.bg:getChildByName("Node_"..sGameName)
                if Node then
                    for k1,check in pairs(Node:getChildren()) do
                        local tag = check:getTag()
                        if k == tag then
                            check:setSelected(true)
                        end
                    end
                end
                
            end
        end
       
        
    end
end

function TypeSetLayer:refreshGameList( ... )
    luaPrint("TypeSetLayer:refreshGameList",self.chooseGameName)
    self:createNode(self.chooseGameName)
end

--创建item的位置，真实名字，游戏名字(2,百家乐,game_30miao)
function TypeSetLayer:createItem(seatNo,realName,gameName)
    local layout = ccui.Layout:create()
    --layout:setPosition(115,10+73*k)
    layout:setContentSize(cc.size(235, 71))
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    -- layout:setBackGroundColor(cc.c3b(255, 0, 0))
    layout:setName(gameName)--设置layout的name
    --self.Node_gamelist:addChild(layout)
    --table.insert(self.allGameListLayout,layout)
    local btn = ccui.Button:create("newExtend/vip/typeset/anniu2.png","newExtend/vip/typeset/anniu2-on.png","newExtend/vip/typeset/anniu1.png")
    btn:setPosition(120,35)
    btn:setAnchorPoint(cc.p(0.5,0.5));
    -- btn:setTitleText(realName);
    btn:setTag(seatNo)
    btn:setName("btn");
    btn:setTitleColor(cc.c3b(193, 204, 254))
    btn:setTitleFontSize(28)
    btn:onClick(handler(self, self.onClickGameBtn))

    local size = btn:getContentSize()
    local zhi = FontConfig.createWithSystemFont(realName,28,cc.c3b(193, 204, 254))
    zhi:setPosition(50,size.height/2)
    zhi:setAnchorPoint(0,0.5)
    btn:addChild(zhi)
    --btn:onClick(function(sender) self:onClickGameBtn(sender); end)
    layout:addChild(btn)
    local checkBox = ccui.CheckBox:create("newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan2.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png")
    checkBox:setPosition(20,35)
    checkBox:setTag(seatNo)
    checkBox:setName("checkBox");
    checkBox:onEvent(handler(self, self.onClickCheckBox))
    layout:addChild(checkBox)
    return layout;
end

--创建Node的位置，真实名字，游戏名字(2,百家乐,game_30miao)
function TypeSetLayer:createNode(gameName)
    for k,roomNode in pairs(self.allRoomListNode) do
        roomNode:setVisible(false);
    end
    if gameName == "lkpy_0" and self.isRoomMode == 0 then --捕鱼单人
        gameName = "lkpy_4"
    end
    if string.find(gameName,"lkpy") then
        local uNameID1 = self:getGameIDBySzGameName("lkpy_0");
        local uNameID2 = self:getGameIDBySzGameName("lkpy_4");
        if uNameID1 == nil  or uNameID2 == nil then
            self.modeBtn:setVisible(false)
            if uNameID1 == nil then
                gameName = "lkpy_4"
                self.isRoomMode = 0
            else
                gameName = "lkpy_0"
                self.isRoomMode = 1
            end
        end
    end
    if gameName == "dz_ssz" then
        if self.nSelPlayCount == 1 then
        elseif self.nSelPlayCount == 2 then
            gameName = "dz_ssz6r"
        else
            gameName = "dz_ssz8r"
        end
    end

    if gameName == "dz_lq_ssz" then
        if self.nSelPlayCount == 1 then
        elseif self.nSelPlayCount == 2 then
            gameName = "dz_lq_ssz6r"
        else
            gameName = "dz_lq_ssz8r"
        end
    end 
    
    local Node =  self.bg:getChildByName("Node_"..gameName)
    local Nodefirst =  self.bg:getChildByName("Node_game_brps")
    if Node then
        Node:setVisible(true)
        if #Node:getChildren() > 0 then
            return; --房间列表已经存在
        else
            local uNameID = self:getGameIDBySzGameName(gameName);
            if uNameID then
                GameCreator:setCurrentGame(uNameID);
                
                local roomList = RoomInfoModule:getRoomInfoByNameID(uNameID)
                if #roomList == 0 then
                    dispatchEvent("requestRoomList")

                else
                    self:createRoom(gameName,Node,roomList)
                end
            end
        end
    else
        Node = cc.Node:create();
        Node:setPosition(370,500)
        Node:setName("Node_"..gameName)
        self.bg:addChild(Node)
        if Nodefirst then
            Node:setPositionX(Nodefirst:getPositionX())
        end
        table.insert(self.allRoomListNode,Node);
        local uNameID = self:getGameIDBySzGameName(gameName);
        if uNameID then
            GameCreator:setCurrentGame(uNameID);
            local roomList = RoomInfoModule:getRoomInfoByNameID(uNameID)
            if #roomList == 0  then               
                dispatchEvent("requestRoomList")
            else
                self:createRoom(gameName,Node,roomList)
            end
        end
    end
end

function TypeSetLayer:createRoom(gameName,node,roomList)
    luaPrint("TypeSetLayer:createRoom",gameName)
     -- addScrollMessage(#self.allGameListLayout1)
    local isSelected = false;
    for k,layout in pairs(self.allGameListLayout1) do
        local gameName = layout:getName();
        if gameName == self.chooseGameName then
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                isSelected = checkBoxBtn:isSelected()
            end
        end
    end
    local num = 0
    for k,v in pairs(self.sGameName) do
        if string.find(gameName,v) then
            num = k
        end
    end
    local teamCount = 0
    -- addScrollMessage(num)
    if string.find(gameName,"game_") then -- 百人游戏
        if gameName == "game_slhb" then
            roomList = self:sortRoomList(roomList)
            luaDump(roomList,"game_slhb")
        end
        -- luaDump(roomList,"百人游戏")
        for k,room in pairs(roomList) do
            -- if k > 2 then --TODO 现在有12个房间
            --     break; 
            -- end 
            local isReRoom = false
            local roomNum = VipRoomInfoModule:getRoomListBysGameName(gameName)
            for m,n in pairs(roomNum) do
                if room.uRoomID == n then
                    isReRoom = true
                end
            end
            if RoomInfoModule:isCashRoom(room.uNameID,room.uRoomID) and isReRoom then --非体验场

                local index = k
                teamCount = teamCount +1
                index = teamCount
                local y = -30;
                if teamCount>3 then
                    index = teamCount-3;
                    y = -220; 
                end

                local checkBox = ccui.CheckBox:create("newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan2.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png")
                checkBox:setPosition(290*(index-1)-30,y)
                checkBox:setName("checkBox"..teamCount)
                checkBox:setTag(room.uRoomID)
                checkBox:onEvent(handler(self, self.onClickRoomCheck))
                checkBox:setSelected(isSelected)
                node:addChild(checkBox);

                local typeset_brnn = ccui.Button:create("newExtend/vip/typeset/"..teamCount..".png","newExtend/vip/typeset/"..teamCount.."-on.png")
                typeset_brnn:setPosition(35,0)
                typeset_brnn:setAnchorPoint(cc.p(0,0.5))
                typeset_brnn:setTag(room.uRoomID)
                typeset_brnn:onClick(handler(self, self.onClickRoomBtn))
                checkBox:addChild(typeset_brnn)
                -- typeset_brnn:setScale(0.6)

                local size = typeset_brnn:getContentSize();
                local name = {"xianjinchang"}
                local nameStr = {}
                if gameName == "game_brps" then
                    name = {"xianjin10bei"}
                elseif gameName == "game_slhb" then
                    name = {"10bao","7bao","add10","add7"}
                    nameStr = {"红包额度:10-50元","红包额度:10-50元","红包额度:10-500元","红包额度:10-500元"}
                elseif gameName == "game_lhdb" or gameName == "game_tgpd" or gameName == "game_shz" then
                    name = {"pingmin","xiaozi","laoban","fuhao"}
                end
                local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[teamCount]..".png")
                biaoti:setPosition(size.width/2,size.height*0.60)
                typeset_brnn:addChild(biaoti)
                -- biaoti:setScale(0.8)

                local xianzhitip = FontConfig.createWithSystemFont(nameStr[teamCount],24)
                xianzhitip:setPosition(size.width*0.5,size.height*0.38)
                typeset_brnn:addChild(xianzhitip)

                local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
                gold:setPosition(size.width*0.35,size.height*0.18)
                typeset_brnn:addChild(gold)

                -- local ruchang = ccui.ImageView:create("newExtend/vip/typeset/ruchang.png")
                -- ruchang:setPosition(size.width*0.68,size.height*0.51)
                -- typeset_brnn:addChild(ruchang)

                -- local minRoomKey = RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                -- local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                -- xianzhi:setPosition(size.width*0.4,size.height*0.52)
                -- typeset_brnn:addChild(xianzhi)

                local minRoomKey = RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                -- local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                -- xianzhi:setPosition(size.width*0.6,size.height*0.35)
                -- typeset_brnn:addChild(xianzhi)

                local xianzhi = FontConfig.createWithSystemFont(tostring(minRoomKey/100),30)
                xianzhi:setPosition(size.width*0.56,size.height*0.18)
                xianzhi:setAnchorPoint(0.5,0.5)
                typeset_brnn:addChild(xianzhi)
                -- xianzhi:setColor(cc.c3b(253,245,218));
            end
        end
        
    elseif string.find(gameName,"dz_") then --对战游戏
        -- if gameName == "dz_ddz" then
        for k,room in pairs(roomList) do
            local isReRoom = false
            local roomNum = VipRoomInfoModule:getRoomListBysGameName(gameName)
            for m,n in pairs(roomNum) do
                if room.uRoomID == n then
                    isReRoom = true
                end
            end
            if RoomInfoModule:isCashRoom(room.uNameID,room.uRoomID) and isReRoom then --非体验场
                local index = k;
                teamCount = teamCount +1
                index = teamCount
                local y = -30;
                if teamCount>3 then
                    index = teamCount-3;
                    y = -220; 
                end
                
                
                
                local checkBox = ccui.CheckBox:create("newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan2.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png")
                checkBox:setPosition(290*(index-1)-30,y)
                checkBox:setName("checkBox"..teamCount)
                checkBox:setTag(room.uRoomID)
                checkBox:setSelected(isSelected)
                checkBox:onEvent(handler(self, self.onClickRoomCheck))
                node:addChild(checkBox);

                local typeset_dz = ccui.Button:create("newExtend/vip/typeset/"..teamCount..".png","newExtend/vip/typeset/"..teamCount.."-on.png")
                typeset_dz:setPosition(35,0)
                typeset_dz:setAnchorPoint(cc.p(0,0.5))
                typeset_dz:setTag(room.uRoomID)
                typeset_dz:onClick(handler(self, self.onClickRoomBtn))
                checkBox:addChild(typeset_dz)
                -- typeset_dz:setScale(0.6)

                local size = typeset_dz:getContentSize();

                -- local dikuang = ccui.ImageView:create("newExtend/vip/typeset/dikuang.png")
                -- dikuang:setPosition(size.width*0.5,size.height*0.51)
                -- typeset_dz:addChild(dikuang)

                local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
                gold:setPosition(size.width*0.35,size.height*0.18)
                typeset_dz:addChild(gold)

                local ruchang = ccui.ImageView:create("newExtend/vip/typeset/difen.png")
                ruchang:setPosition(size.width*0.65,size.height*0.40)
                typeset_dz:addChild(ruchang)

                local minRoomKey = RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                -- local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                -- xianzhi:setPosition(size.width*0.6,size.height*0.35)
                -- typeset_dz:addChild(xianzhi)
                local xianzhi = FontConfig.createWithSystemFont(tostring(minRoomKey/100),30)
                xianzhi:setPosition(size.width*0.56,size.height*0.18)
                xianzhi:setAnchorPoint(0.5,0.5)
                typeset_dz:addChild(xianzhi)
                -- xianzhi:setColor(cc.c3b(253,245,0));

                local difennum = self.RoomDifen[num][teamCount]
                local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/typeset/difenzitiao.png", 20, 28, "+");
                difen:setPosition(size.width*0.35,size.height*0.40)
                typeset_dz:addChild(difen)

                
                local name = {"pingmin","xiaozi","laoban","fuhao"}
                if gameName == "dz_ddz" then
                    name = {"jindian1","buxipai1","buxipai2","buxipai3"}
                end
                
                local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[teamCount]..".png")
                biaoti:setPosition(size.width/2,size.height*0.65)
                typeset_dz:addChild(biaoti)
                if gameName == "dz_ddz" then
                    biaoti:setPosition(size.width/2,size.height*0.68)
                    -- biaoti:setScale(0.65)
                end

                if gameName == "dz_dzpk" then
                    -- ruchang:loadTexture("newExtend/vip/typeset/xianzhi.png")
                    -- ruchang:setPosition(size.width*0.35,size.height*0.51)
                    -- xianzhi:setPosition(size.width*0.63,size.height*0.52)
                    ruchang:loadTexture("newExtend/vip/typeset/xiaomangzhu.png")
                    ruchang:setPosition(size.width*0.4,size.height*0.25)
                    ruchang:setScale(0.8)
                    difen:setPosition(size.width*0.7,size.height*0.25)
                    difen:setScale(0.8)

                    local damangzhu = ccui.ImageView:create("newExtend/vip/typeset/damangzhu.png")
                    damangzhu:setPosition(size.width*0.4,size.height*0.18)
                    typeset_dz:addChild(damangzhu)
                    damangzhu:setScale(0.8)

                    local difen1 = FontConfig.createWithCharMap(difennum*2, "newExtend/vip/typeset/difenzitiao.png", 20, 28, "+");
                    difen1:setPosition(size.width*0.7,size.height*0.18)
                    typeset_dz:addChild(difen1)
                    difen1:setScale(0.8)
                elseif gameName == "dz_shuiguoji" then
                    difen:setVisible(false)
                    ruchang:setVisible(false)
                    local Maxxianzhi = FontConfig.createWithSystemFont("最大下注: "..difennum,24)
                    Maxxianzhi:setPosition(size.width*0.5,size.height*0.38)
                    typeset_dz:addChild(Maxxianzhi)
                end
            end
        end
        
    elseif string.find(gameName,"lkpy_") then --捕鱼
        for k,room in pairs(roomList) do
            luaDump(roomList,"roomList")
            if RoomInfoModule:isCashRoom(room.uNameID,room.uRoomID) then --非体验场
                local index = k;
                teamCount = teamCount +1
                index = teamCount
                local y = -30;
                if teamCount>3 then
                    index = teamCount-3;
                    y = -220; 
                end

                -- local tag = k
                -- if self.isRoomMode == 0 then
                --     tag = k+4
                -- end
                
                
                local checkBox = ccui.CheckBox:create("newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan2.png","newExtend/vip/typeset/gouxuan1.png","newExtend/vip/typeset/gouxuan1.png")
                checkBox:setPosition(290*(index-1)-30,y)
                checkBox:setName("checkBox"..teamCount)
                checkBox:setTag(room.uRoomID)
                checkBox:setSelected(isSelected)
                checkBox:onEvent(handler(self, self.onClickRoomCheck))
                node:addChild(checkBox);

                local typeset_dz = ccui.Button:create("newExtend/vip/typeset/"..teamCount..".png","newExtend/vip/typeset/"..teamCount.."-on.png")
                typeset_dz:setPosition(35,0)
                typeset_dz:setAnchorPoint(cc.p(0,0.5))
                typeset_dz:setTag(room.uRoomID)
                typeset_dz:onClick(handler(self, self.onClickRoomBtn))
                checkBox:addChild(typeset_dz)
                -- typeset_dz:setScale(0.6)

                local size = typeset_dz:getContentSize();

                -- local dikuang = ccui.ImageView:create("newExtend/vip/typeset/dikuang.png")
                -- dikuang:setPosition(size.width*0.5,size.height*0.51)
                -- typeset_dz:addChild(dikuang)

                local name = {"xinshouyucun","yongzhehaiwan","shenhailieshou","haiyangshenhua"}
                
                local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[teamCount]..".png")
                biaoti:setPosition(size.width/2,size.height*0.58)
                typeset_dz:addChild(biaoti)

                if self.isRoomMode == 0 then
                    name ="danren"
                else
                    name ="duoren"
                end
                local tip = ccui.ImageView:create("newExtend/vip/typeset/"..name..k..".png")
                tip:setPosition(size.width/2,size.height*0.80)
                typeset_dz:addChild(tip)

                local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
                gold:setPosition(size.width*0.35,size.height*0.18)
                typeset_dz:addChild(gold)

                -- local ruchang = ccui.ImageView:create("newExtend/vip/typeset/bei.png")
                -- ruchang:setPosition(size.width*0.82,size.height*0.22)
                -- typeset_dz:addChild(ruchang)

                local minRoomKey = RoomInfoModule:getRoomNeedGold(room.uNameID,room.uRoomID) --最小金币限制
                -- local xianzhi = FontConfig.createWithCharMap(tostring(minRoomKey/100), "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
                -- xianzhi:setPosition(size.width*0.6,size.height*0.35)
                -- typeset_dz:addChild(xianzhi)
                local xianzhi = FontConfig.createWithSystemFont(tostring(minRoomKey/100),30)
                xianzhi:setPosition(size.width*0.56,size.height*0.18)
                xianzhi:setAnchorPoint(0.5,0.5)
                typeset_dz:addChild(xianzhi)
                -- xianzhi:setColor(cc.c3b(253,245,218));

                -- name = {"0.01-0.1","0.1-1","1-10","10-55"}

                -- local difennum = name[k]
                -- local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/typeset/difenzitiao.png", 26, 44, "+");
                -- difen:setPosition(size.width*0.45,size.height*0.22)
                -- typeset_dz:addChild(difen)
                -- difen:setScale(0.9)
                local info = ccui.ImageView:create("newExtend/vip/typeset/fishbeishu/"..k..".png")
                info:setPosition(size.width*0.5,size.height*0.38)
                info:setScale(0.8)
                typeset_dz:addChild(info)
                
            end
        end
    end
    -- addScrollMessage("需要加载数据"..tostring(self.isLoad).."isSelected= "..tostring(isSelected))
    -- if self.isLoad and (isSelected or #self.allGameListLayout1==0 or (self.isshoudongquxiao ~= true))and self.isqingkong~= true then --需要加载数据
       
       
        for k,check in pairs(node:getChildren()) do
            local tag = check:getTag();
            if self.chooseRoomTable[tag] == 1 then
                check:setSelected(true);
            end
            -- local idx = string.sub(self.roomRule,tag,tag)
            -- if idx == "1" then
            --     check:setSelected(true);
            -- end
            
        end
    -- end

end

--isShowID 1显示全部游戏 2显示百人游戏 3 显示对战游戏 4显示捕鱼游戏
function TypeSetLayer:showGameList(isShowID)
    local parent = nil;
    local subFlag = "";
    if isShowID == 1 then
        parent = self.Node_gameAllList;
    elseif isShowID == 2 then
        subFlag = "game_"
        parent = self.Node_gameBrList;
    elseif isShowID == 3 then
        subFlag = "dz_"
        parent = self.Node_gameDzList;
    elseif isShowID == 4 then
        parent = self.Node_gameByList;
        subFlag = "lkpy_"
    end

    if parent and #parent:getChildren()>0 then
        local showGameBtn = nil;
        if isShowID == 1 then
            for k,layout in pairs(self.allGameListLayout1) do
                local gameBtn = layout:getChildByName("btn")
                if gameBtn:isEnabled() == false then
                    showGameBtn = gameBtn;
                    break;
                end
            end
        else
            for k,layout in pairs(self.allGameListLayout2) do
                local szName = layout:getName();
                if string.find(szName,subFlag) then
                    local gameBtn = layout:getChildByName("btn")
                    if gameBtn:isEnabled() == false then
                        showGameBtn = gameBtn;
                        break;
                    end
                end
            end
        end
        if showGameBtn then
            self:onClickGameBtn(showGameBtn)
        end
        return;
    end
    local isShowAllLayout = {};--需要显示的layout
    for k,szName in pairs(self.sGameName) do
        -- if szName == "lkpy_4" then
        --     break
        -- end
        --local name = layout:getName();
        if self:findNameByGameList(szName) then
            if isShowID == 1 then --全部的
                local layout = self:createItem(k,self.gameNameAllList[k],szName)
                table.insert(self.allGameListLayout1,layout)
                if szName == "lkpy_4" then
                    if self:findNameByGameList("lkpy_0") then
                        layout:setVisible(false)
                        self.bg:addChild(layout)
                    else
                        table.insert(isShowAllLayout,layout)
                    end
                else
                    table.insert(isShowAllLayout,layout)
                end
            else
                if string.find(szName,subFlag) then
                    local layout = self:createItem(k,self.gameNameAllList[k],szName)
                    table.insert(self.allGameListLayout2,layout)
                    if szName == "lkpy_4" then
                        if self:findNameByGameList("lkpy_0") then
                            layout:setVisible(false)
                            self.bg:addChild(layout)
                        else
                            table.insert(isShowAllLayout,layout)
                        end
                    else
                        table.insert(isShowAllLayout,layout)
                    end
                    
                    
                end
            end
        end
    end
    if #isShowAllLayout > 5 then
        local listView = ccui.ListView:create()
        listView:setAnchorPoint(cc.p(0.5,0.5))
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setScrollBarEnabled(false)
        --listView:setName("listView"..tag)
        listView:setContentSize(cc.size(255, 355))
        listView:setPosition(155,320)
        parent:addChild(listView)
        for k,layout in pairs(isShowAllLayout) do
            listView:pushBackCustomItem(layout)
        end
        if isShowID == 1 then --全部的
            self.gameListView = listView;
        end
    else
        for k,layout in pairs(isShowAllLayout) do
            layout:setPosition(35,500-72*k)
            parent:addChild(layout)
        end
    end

    --第一次进来默认选择第一个
    if #isShowAllLayout >0 then
        self:onClickGameBtn(isShowAllLayout[1]:getChildByName("btn"))
    else
        for k,roomNode in pairs(self.allRoomListNode) do
            roomNode:setVisible(false);
        end
    end
    

end

--查找游戏是否开启
function TypeSetLayer:getGameIDBySzGameName(name,num)
    local gameID = nil;
    
    if #self.gameList >= 0 then
        for k,game in pairs(self.gameList) do
            if name == game.szGameName then
                gameID = game.uNameID;
                break;
            end
        end
    end
    return gameID;
end

--查找游戏是否开启
function TypeSetLayer:findNameByGameList(name)
    local isFind = false;
    if #self.gameList >= 0 then
        for k,game in pairs(self.gameList) do
            if name == game.szGameName then
                isFind = true;
                break;
            end
        end
    end
    return isFind;
end

function TypeSetLayer:onClickGameBtn(sender)
    local tag = sender:getTag();

    -- addScrollMessage("当前选择的游戏是--"..tag..self.gameNameAllList[tag]..self.sGameName[tag])
    if self.gameBtn[1]:isEnabled() == false then --当前选择的是全部 
        for k,layout in pairs(self.allGameListLayout1) do
            local gameName = layout:getName();
            local gameBtn = layout:getChildByName("btn")
            --luaPrint("当前的gameName",gameName,gameBtn)
            if gameName == self.sGameName[tag] then
                self.chooseGameName = gameName
                gameBtn:setEnabled(false)
            else
                gameBtn:setEnabled(true)
            end
        end
    else
        local subFlag = "lkpy_";
        if self.gameBtn[2]:isEnabled() == false then
            subFlag = "game_"
        elseif self.gameBtn[3]:isEnabled() == false then
            subFlag = "dz_"
        end
        for k,layout in pairs(self.allGameListLayout2) do
            local gameName = layout:getName();
            if string.find(gameName,subFlag) then
                local gameBtn = layout:getChildByName("btn")
                if gameName == self.sGameName[tag] then
                    self.chooseGameName = gameName
                    gameBtn:setEnabled(false)
                else
                    gameBtn:setEnabled(true)
                end
            end
        end
    end

    if self.sGameName[tag] == "lkpy_0" then
        self.modeBtn:setVisible(true)
    else
        self.modeBtn:setVisible(false)
    end

    if self.sGameName[tag] == "dz_ssz" or self.sGameName[tag] == "dz_lq_ssz" then
        self.playCountNode:setVisible(true)
    else
        self.playCountNode:setVisible(false)
    end

    self:createNode(self.chooseGameName);
    
end

function TypeSetLayer:onClickCheckBox(event)
    local tag = event.target:getTag()

    local isShowAllLayout = self.allGameListLayout2;
    local isSelected = false;
    local gameBtn = nil;
    if self.gameBtn[1]:isEnabled() == false then --当前选择的是全部 
        isShowAllLayout = self.allGameListLayout1;
    end
    for k,layout in pairs(isShowAllLayout) do
        local gameName = layout:getName();
        local checkBoxBtn = layout:getChildByName("checkBox")
        if gameName == self.sGameName[tag] and checkBoxBtn then
            isSelected = checkBoxBtn:isSelected();
            gameBtn = layout:getChildByName("btn")
            local isShowAllLayout1 = self.allGameListLayout1;
            if self.gameBtn[1]:isEnabled() == false then --当前选择的是全部 
                isShowAllLayout1 = self.allGameListLayout2;
            end
            for k,layout1 in pairs(isShowAllLayout1) do
                local gameName1 = layout1:getName();
                local checkBoxBtn1 = layout1:getChildByName("checkBox")
                if gameName1 == self.sGameName[tag] and checkBoxBtn then
                    checkBoxBtn1:setSelected(isSelected)
                    break;
                end
            end
            break;
        end
    end
    self:onClickGameBtn(gameBtn);
    local Node =  self.bg:getChildByName("Node_"..self.chooseGameName)
    local Node1 = nil;
    if self.chooseGameName == "lkpy_0" then
        Node1 =  self.bg:getChildByName("Node_lkpy_4")
        if Node1 then
            for k,check in pairs(Node1:getChildren()) do
                check:setSelected(isSelected)
            end
        end
    end

    if self.chooseGameName == "dz_ssz" then
        Node1 =  self.bg:getChildByName("Node_dz_ssz6r")
        if Node1 then
            for k,check in pairs(Node1:getChildren()) do
                check:setSelected(isSelected)
            end
        end

        Node1 =  self.bg:getChildByName("Node_dz_ssz8r")
        if Node1 then
            for k,check in pairs(Node1:getChildren()) do
                check:setSelected(isSelected)
            end
        end
    end

    if self.chooseGameName == "dz_lq_ssz" then
        Node1 =  self.bg:getChildByName("Node_dz_lq_ssz6r")
        if Node1 then
            for k,check in pairs(Node1:getChildren()) do
                check:setSelected(isSelected)
            end
        end

        Node1 =  self.bg:getChildByName("Node_dz_lq_ssz8r")
        if Node1 then
            for k,check in pairs(Node1:getChildren()) do
                check:setSelected(isSelected)
            end
        end
    end

    if Node then
        for k,check in pairs(Node:getChildren()) do
            check:setSelected(isSelected)
        end
    end

    --
    -- if self.sGameName[tag] == "lkpy_0" then
        if isSelected then
            self.isshoudongquxiao = false 
        else
            self.isshoudongquxiao = true 
        end
        if self.chooseGameName == "lkpy_0" then
            if isSelected then
                self.isshoudongquxiaoBuYu = false 
            else
                self.isshoudongquxiaoBuYu = true 
            end
        end
           
    -- end
    --addScrollMessage("当前CheckBox的游戏是--"..tag..self.gameNameAllList[tag]..self.sGameName[tag]..tostring(isSelected))
    local roomList1 = VipRoomInfoModule:getRoomListBysGameName(self.chooseGameName)
    local game_id = VipRoomInfoModule:getIDBysGameName(self.chooseGameName)
    if isSelected then
        if game_id>0 then
            self.chooseGameTable[game_id] = 1;
        end
        for k,v in pairs(roomList1) do
            self.chooseRoomTable[v] = 1;
        end
    else
        if game_id>0 then
            self.chooseGameTable[game_id] = 0;
        end
        for k,v in pairs(roomList1) do
            self.chooseRoomTable[v] = 0;
        end
    end
end

function TypeSetLayer:setChooseEndCallback(callback)
    self.callback = callback;
end

function TypeSetLayer:onClickTypeBtn(sender)
    local tag = sender:getTag();
    for k,btn in pairs(self.gameBtn) do
        if tag == k then
            btn:setEnabled(false);
            self.gameNode[k]:setVisible(true)
            self:showGameList(k)
        else
            btn:setEnabled(true)
            self.gameNode[k]:setVisible(false)
        end
    end
end

function TypeSetLayer:onClickBtn(sender)
    local tag = sender:getTag();
    local isSelected = nil;
    if tag == 0 then
        local searchName = self.searchTextEdit:getText()
        if searchName == "" then
            addScrollMessage("未搜索到该游戏")
            return;
        end
        local index = -1;
        for k,gameName in pairs(self.gameNameAllList) do
            if string.find(gameName,searchName) then
                index = k;
                break;
            end
        end
        
        if index == -1 then
            addScrollMessage("未搜索到该游戏")
        else
            if self.gameListView and self.gameNameAllList[index] then
                addScrollMessage("搜索到.."..self.gameNameAllList[index].."..游戏")
                self:onClickTypeBtn(self.gameBtn[1])
                for k,layout in pairs(self.allGameListLayout1) do
                    local gameName = layout:getName();
                    if gameName == self.sGameName[index] then
                        local gameBtn = layout:getChildByName("btn")
                        self:onClickGameBtn(gameBtn)
                    end
                end
                
                local temp = index/#self.gameNameAllList*100
                if index < 3 then
                    temp = 0;
                end
                self.gameListView:scrollToPercentVertical(temp,0.1,true);
            end
        end
    elseif tag == 1 then
        isSelected = false;
        self.isqingkong = true;
        self.isshoudongquxiaoBuYu = true
        for k,v in pairs(self.chooseRoomTable) do
            self.chooseRoomTable[k] = 0;
        end
        for k,v in pairs(self.chooseGameTable) do
            self.chooseGameTable[k] = 0;
        end
    elseif tag == 2 then
        isSelected = true;
        self.isqingkong = false;
        for k,v in pairs(self.chooseRoomTable) do
            self.chooseRoomTable[k] = 1;
        end
        for k,v in pairs(self.chooseGameTable) do
            self.chooseGameTable[k] = 1;
        end
        luaDump(self.chooseRoomTable,"self.chooseRoomTable")
    elseif tag == 3 then

        local gameChoose = "";
        local roomChoose = "";
        local isSelectedgame = false;
        for k,v in pairs(self.chooseRoomTable) do
            roomChoose = roomChoose..v;
            if v==1 then
                local isRealyRoom = VipRoomInfoModule:getIsRealyRoomID(k)
                if isRealyRoom then
                    isSelectedgame = true;
                end
            end
        end
        
        if isSelectedgame == false then
            addScrollMessage("您还未选择游戏类型")
            return;
        end
        
        for k,v in pairs(self.chooseGameTable) do
            gameChoose = gameChoose..v
        end
        
        if self.callback then
            self.callback(gameChoose,roomChoose)
        end
        --addScrollMessage("gameChoose"..gameChoose.."roomChoose"..roomChoose)
        self:removeSelf();
        return;
        
    end

    if isSelected ~= nil then
        for k,layout in pairs(self.allGameListLayout1) do
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isSelected)
            end
        end
        for k,layout in pairs(self.allGameListLayout2) do
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isSelected)
            end
        end
        for k,roomNode in pairs(self.allRoomListNode) do
            for k,check in pairs(roomNode:getChildren()) do
                check:setSelected(isSelected)
            end
        end
    end
end

function TypeSetLayer:onClickRoomCheck(event)
    local tag = event.target:getTag()
    local roomNum = 0;
    if event.target:isSelected() then
        roomNum = 1;
    end
    self.chooseRoomTable[tag] = roomNum;

    local isFlag = true;
    local roomList = VipRoomInfoModule:getRoomListBysGameName(self.chooseGameName)
    for k,v in pairs(roomList) do
        if self.chooseRoomTable[v] == 0 then
            isFlag = false;
            break;
        end
    end
    
    for k,layout in pairs(self.allGameListLayout2) do
        local gameName = layout:getName();
        if gameName == self.chooseGameName then
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isFlag)
            end
        end
    end

    for k,layout in pairs(self.allGameListLayout1) do
        local gameName = layout:getName();
        if gameName == self.chooseGameName then
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isFlag)
            end
            local game_id = VipRoomInfoModule:getIDBysGameName(self.chooseGameName)
            local gameNum = 0;
            if isFlag then
                gameNum = 1;
            end
            if game_id>0 then
                self.chooseGameTable[game_id] = gameNum;
            end
        end
    end
    
end

function TypeSetLayer:onClickRoomBtn(sender)
    local tag = sender:getTag();
    local Node =  self.bg:getChildByName("Node_"..self.chooseGameName)
    
    local checkBox = nil;
    if Node then
        checkBox = Node:getChildByTag(tag)
    end
    if string.find(self.chooseGameName,"lkpy") and checkBox == nil then
        local Node1 = self.bg:getChildByName("Node_lkpy_4");
        if Node1 and checkBox == nil then
            checkBox = Node1:getChildByTag(tag)
        end
    end
    if string.find(self.chooseGameName,"dz_ssz") and checkBox == nil then
        local Node2 = self.bg:getChildByName("Node_dz_ssz6r");
        local Node3 = self.bg:getChildByName("Node_dz_ssz8r");
        if Node2 and checkBox == nil then
            checkBox = Node2:getChildByTag(tag)
        end
        if Node3 and checkBox == nil then
            checkBox = Node3:getChildByTag(tag)
        end
    end 
    
    if checkBox then
        checkBox:setSelected(not checkBox:isSelected())
        local roomNum = 0;
        if checkBox:isSelected() then
            roomNum = 1;
        end
        self.chooseRoomTable[tag] = roomNum;
    end
        
    local isFlag = true;
    local roomList = VipRoomInfoModule:getRoomListBysGameName(self.chooseGameName)
    for k,v in pairs(roomList) do
        if self.chooseRoomTable[v] == 0 then
            isFlag = false;
            break;
        end
    end

    for k,layout in pairs(self.allGameListLayout2) do
        local gameName = layout:getName();
        if gameName == self.chooseGameName then
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isFlag)
            end
        end
    end

    for k,layout in pairs(self.allGameListLayout1) do
        local gameName = layout:getName();
        if gameName == self.chooseGameName then
            local checkBoxBtn = layout:getChildByName("checkBox")
            if checkBoxBtn then
                checkBoxBtn:setSelected(isFlag)
            end
            local game_id = VipRoomInfoModule:getIDBysGameName(self.chooseGameName)
            local gameNum = 0;
            if isFlag then
                gameNum = 1;
            end
            if game_id>0 then
                self.chooseGameTable[game_id] = gameNum;
            end
        end
    end
    
end

--多人单人模式选择
function TypeSetLayer:onClickModeBtn(sender)
    if sender:getTag() == 1 then--多人模式
        sender:loadTextures("newExtend/vip/typeset/danren.png","newExtend/vip/typeset/danren-on.png")
        sender:setTag(0)
        -- sender:setPositionX(sender:getPositionX()-8)
        self.isRoomMode = 0

    else--单人模式
        sender:loadTextures("newExtend/vip/typeset/duoren.png","newExtend/vip/typeset/duoren-on.png")
        sender:setTag(1)
        -- sender:setPositionX(sender:getPositionX()+8)
        self.isRoomMode = 1
        
    end

    self:refreshGameList()
end

function TypeSetLayer:sortRoomList(roomList)
    local list = {}
    local list1 = {}
    for k,v in pairs(roomList) do
        if v.uRoomID >= 144 then
            table.insert(list,v)
        else
            table.insert(list1,v)
        end
    end
    for k,v in pairs(list1) do
        table.insert(list,v)
    end
    return list;
end

return TypeSetLayer
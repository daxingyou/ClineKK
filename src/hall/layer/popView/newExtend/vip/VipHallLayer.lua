local VipHallLayer = class("VipHallLayer", BaseWindow)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function VipHallLayer:create(data)
    return VipHallLayer.new(data);
end

function VipHallLayer:ctor(data)
    playEffect("hall/sound/vip.mp3")
    self.super.ctor(self, 0, true)
    self.tingData = data;
    -- luaDump(self.tingData,"tingData")
    self:initData();
    self:initUI();
    self:bindEvent();
end

function VipHallLayer:initData()
    self.gameList = {};--游戏列表
    self.chooseGameName = ""--当前选择的游戏名字(game_ppc)

    self.gameBtn = {};
    self.gameNode = {};
    self.gameText = {};
    self.allHallListLayout = {};--全部的layout
    self.allRoomListNode = {};
    self.tingid = 1 ;--当前选择厅id
    self.nowTingId = 0;
    -- self.chooseRoomTable = {{0,0},{0},{0},{0},{0},{0},{0},{0,0,0,0},{0,0,0},
                    -- {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    self.sGameName = {"lkpy_0","game_brps","game_30miao","game_lhd","game_hhdz","game_yyy","game_fqzs","game_ppc","game_slhb","game_tgpd","game_lhdb",
            "dz_ssz","dz_ddz","dz_dzpk","dz_szp","dz_esyd","dz_sdb","dz_qzps","dz_ernn","dz_shuiguoji"}
    self.gameNameAllList = {"捕鱼达人","百人牛牛","百家乐","龙虎斗","红黑大战","骰宝","飞禽走兽","奔驰宝马","扫雷红包","糖果派对","连环夺宝","十三张","斗地主",
                            "德州扑克","扎金花","21点","十点半","抢庄牛牛","二人牛牛","超级水果机"};

    -- if runMode == "release" then
        self.sGameName = {"game_brps","game_30miao","game_lhd","game_hhdz","game_fqzs","game_yyy","dz_ddz","dz_szp","game_slhb","dz_qzps",
            "dz_ernn","game_ppc"}
        self.gameNameAllList = {"百人牛牛","百家乐","龙虎斗","红黑大战","飞禽走兽","骰宝","斗地主","扎金花","扫雷红包","抢庄牛牛",
            "二人牛牛","奔驰宝马"};
    -- end
end

function VipHallLayer:bindEvent()
    self.bindIds = {}

    -- self:pushGlobalEventInfo("I_P_M_RoomList",handler(self, self.refreshGameList))
    self:pushEventInfo(VipInfo,"changeRuleInfo",handler(self, self.receiveChangeRuleInfo))
    self:pushEventInfo(VipInfo,"createReqMember",handler(self, self.receiveCreateReqMember))
    self:pushEventInfo(VipInfo,"guildSettop",handler(self, self.receiveGuildSettop))
    self:pushEventInfo(VipInfo,"guildChangeRuleReq",handler(self, self.recGuildChangeRuleReq))
    self:pushEventInfo(VipInfo,"roomGuildChange",handler(self, self.recRoomGuildChange))
    self:pushEventInfo(VipInfo,"guildDeleteNotify",handler(self, self.recguildDeleteNotify))
    self:pushEventInfo(VipInfo,"guildChangeNotify",handler(self, self.recguildChangeNotify))
    self:pushEventInfo(VipInfo,"guildKickNotify",handler(self, self.recguildKickNotify))

    self:pushGlobalEventInfo("onRoomLoginError", handler(self, self.onRoomLoginError))
    self:pushGlobalEventInfo("refreshVIPGameList", handler(self, self.refreshVIPGameList))

end

function VipHallLayer:unBindEvent()
    if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function VipHallLayer:onExit()
    self.super.onExit(self)

    self:unBindEvent()
end


function VipHallLayer:initUI()
    self:initBg();
end

function VipHallLayer:initBg()
    VipInfo:sendGuildSendMoneyReq();
    self:setLocalZOrder(999)
    local bg = ccui.ImageView:create("newExtend/vip/common/bgmohu.png")
    bg:setPosition(getScreenCenter())
    self:addChild(bg)

    self.bg = bg

    self.size = bg:getContentSize()

    -- local dibg = ccui.ImageView:create("newExtend/vip/common/bg1.png")
    -- dibg:setPosition(self.size.width/2+130,self.size.height/2)
    -- bg:addChild(dibg);

    local node1 = cc.Node:create();--左侧游戏列表
    bg:addChild(node1,10)
    self.Node_left = node1

    local node2 = cc.Node:create();--右侧游戏内容
    bg:addChild(node2,10)
    node2:setVisible(false)
    self.Node_right = node2

    -- local cebian = ccui.ImageView:create("newExtend/vip/common/cebian.png")
    -- cebian:setAnchorPoint(cc.p(0,0))
    -- bg:addChild(cebian)
    -- cebian:setPosition(cc.p(50,250))

    local ding = ccui.ImageView:create("newExtend/vip/common/ding.png")
    ding:setPosition(self.size.width/2,self.size.height-35)
    ding:setAnchorPoint(cc.p(0.5,0.5))
    bg:addChild(ding);

    -- local Image_ziBg = ccui.ImageView:create("newExtend/vip/common/dingzibg.png");
    -- Image_ziBg:setAnchorPoint(0,1);
    -- Image_ziBg:setPosition(-180,self.size.height);
    -- bg:addChild(Image_ziBg);
    
    

    local bttitle = ccui.ImageView:create("newExtend/vip/viphall/vip.png")
    bttitle:setPosition(400,self.size.height-35)
    bttitle:setAnchorPoint(cc.p(0.5,0.5))
    bg:addChild(bttitle)
    
    local zhuozi = ccui.ImageView:create("newExtend/vip/viphall/kuang.png")
    zhuozi:setPosition(self.size.width*0.63,0)
    zhuozi:setAnchorPoint(cc.p(0.5,0))
    bg:addChild(zhuozi)
    self.zhuozi = zhuozi;

    local Layout = ccui.Layout:create()
    -- Layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    -- Layout:setBackGroundColor(cc.c3b(255, 0, 0))
    Layout:setPosition(self.size.width*0.42,self.size.height*0.9)
    Layout:setContentSize(600,40)
    Layout:setClippingEnabled(true)
    node2:addChild(Layout)

    local text = cc.Label:createWithSystemFont("玩法:百人牛牛、飞禽走兽、奔驰宝马、斗地主、龙虎斗、十点半","Arial", 25);
    text:setPosition(0,20)
    text:setAnchorPoint(cc.p(0,0.5))
    text:setColor(cc.c3b(235, 227, 114));
    Layout:addChild(text)
    table.insert(self.gameText,text)

    if text:getContentSize().width > Layout:getContentSize().width then
        text:setPosition(640,20)
        local moveTo = cc.MoveTo:create(10,cc.p(-text:getContentSize().width,20));
        local callback = cc.CallFunc:create(function ()
                            text:setPosition(640,20)
                        end)
        text:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo,callback)))
    end

    local vipName = cc.Label:createWithSystemFont("厅名:某某是豆豆豆", "Arial" ,26 ,FontConfig.colorWhite);
    vipName:setPosition(self.size.width*0.42,self.size.height*0.96+5)
    vipName:setAnchorPoint(cc.p(0,0.5))
    node2:addChild(vipName)
    table.insert(self.gameText,vipName)

    local vipid = cc.Label:createWithSystemFont("厅ID:123456", "Arial" ,26 ,FontConfig.colorWhite);
    vipid:setPosition(self.size.width*0.56,self.size.height*0.96+5)
    vipid:setAnchorPoint(cc.p(0,0.5))
    node2:addChild(vipid)
    table.insert(self.gameText,vipid)

    local vipzhuid = cc.Label:createWithSystemFont("厅主ID:654321", "Arial" ,26 ,FontConfig.colorWhite);
    vipzhuid:setPosition(self.size.width*0.68,self.size.height*0.96+5)
    vipzhuid:setAnchorPoint(cc.p(0,0.5))
    node2:addChild(vipzhuid)
    table.insert(self.gameText,vipzhuid)

    local vipNum = cc.Label:createWithSystemFont("成员:23", "Arial" ,26 ,FontConfig.colorWhite);
    vipNum:setPosition(self.size.width*0.86,self.size.height*0.96+5)
    vipNum:setAnchorPoint(cc.p(0,0.5))
    node2:addChild(vipNum)
    table.insert(self.gameText,vipNum)

    local btn1 = ccui.Button:create("newExtend/vip/common/quanbu.png","newExtend/vip/common/quanbu-on.png","newExtend/vip/common/quanbu2.png")
    btn1:setPosition(self.size.width*0.32,self.size.height*0.83+20)
    node2:addChild(btn1)
    btn1:setTag(1);
    btn1:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn1)

    local btn2 = ccui.Button:create("newExtend/vip/common/bairenchang.png","newExtend/vip/common/bairenchang-on.png","newExtend/vip/common/bairenchang2.png")
    btn2:setPosition(self.size.width*0.32+150,self.size.height*0.83+20)
    node2:addChild(btn2)
    btn2:setTag(2);
    btn2:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn2)

    local btn3 = ccui.Button:create("newExtend/vip/common/duizhanchang.png","newExtend/vip/common/duizhanchang-on.png","newExtend/vip/common/duizhanchang2.png")
    btn3:setPosition(self.size.width*0.32+300,self.size.height*0.83+20)
    node2:addChild(btn3)
    btn3:setTag(3);
    btn3:onClick(function(sender) self:onClickTypeBtn(sender); end)
    table.insert(self.gameBtn,btn3)

    -- local btn4 = ccui.Button:create("newExtend/vip/common/buyu.png","newExtend/vip/common/buyu-on.png","newExtend/vip/common/buyu2.png")
    -- btn4:setPosition(self.size.width*0.32+450,self.size.height*0.83+20)
    -- node2:addChild(btn4)
    -- btn4:setTag(4);
    -- btn4:onClick(function(sender) self:onClickTypeBtn(sender); end)
    -- table.insert(self.gameBtn,btn4)

    local shezhiBtn = ccui.Button:create("newExtend/vip/common/shezhi.png","newExtend/vip/common/shezhi-on.png")
    shezhiBtn:setPosition(self.size.width-40,self.size.height-38)
    shezhiBtn:setTag(1);
    bg:addChild(shezhiBtn)
    shezhiBtn:onClick(function(sender) self:onClickBtn(sender); end)
    self.shezhiBtn = shezhiBtn;

    local closeBtn = ccui.Button:create("newExtend/vip/common/fanhui.png","newExtend/vip/common/fanhui-on.png")
    closeBtn:setPosition(0,self.size.height-38)
    closeBtn:setAnchorPoint(cc.p(0,0.5))
    closeBtn:setTag(0);
    bg:addChild(closeBtn)
    closeBtn:onClick(function(sender) self:onClickBtn(sender); end)


    local viptingguanli = ccui.Button:create("newExtend/vip/viphall/viptingguanli.png","newExtend/vip/viphall/viptingguanli-on.png")
    viptingguanli:setPosition(100,42)
    viptingguanli:setTag(2);
    bg:addChild(viptingguanli)
    viptingguanli:onClick(function(sender) self:onClickBtn(sender); end)
    self.viptingguanli = viptingguanli;

    local shenqingjiaru = ccui.Button:create("newExtend/vip/viphall/shenqingjiaru.png","newExtend/vip/viphall/shenqingjiaru-on.png")
    shenqingjiaru:setPosition(self.size.width/2+150,42)
    shenqingjiaru:setTag(3);
    bg:addChild(shenqingjiaru)
    shenqingjiaru:onClick(function(sender) self:onClickBtn(sender); end)
    self.shenqingjiaru = shenqingjiaru;

    local kaitongvipting = ccui.Button:create("newExtend/vip/viphall/kaitongvipting.png","newExtend/vip/viphall/kaitongvipting-on.png")
    kaitongvipting:setPosition(self.size.width/2-60,42)
    kaitongvipting:setTag(6);
    bg:addChild(kaitongvipting)
    kaitongvipting:onClick(function(sender) self:onClickBtn(sender); end)
    kaitongvipting:setVisible(false)
    self.kaitongvipting = kaitongvipting;

    
    local vipTip = cc.Label:createWithSystemFont("VIP厅内可用金币为除去\n绑定送金奖励后的金币", "Arial" ,20 ,FontConfig.colorWhite);
    vipTip:setPosition(self.size.width*0.5+350,self.size.height*0.86)
    vipTip:setAnchorPoint(cc.p(0,0.5))
    vipTip:setVisible(false)
    bg:addChild(vipTip)
    self.vipTip = vipTip;

    local winsize =  cc.Director:getInstance():getWinSize();
    if checkIphoneX() then
        closeBtn:setPositionX(closeBtn:getPositionX()-(winsize.width-1280)/2);
        bttitle:setPositionX(bttitle:getPositionX()-(winsize.width-1280)/2);
        self.Node_left:setPositionX(self.Node_left:getPositionX()-(winsize.width-1280)*0.4);
        viptingguanli:setPositionX(viptingguanli:getPositionX()-(winsize.width-1280)*0.4);
    end

    local node3 = cc.Node:create();--对战游戏的界面
    bg:addChild(node3)
    self.Node_gameDzList = node3
    table.insert(self.gameNode,node3)

    local node4 = cc.Node:create();--捕鱼游戏的界面
    bg:addChild(node4)
    self.Node_gameByList = node4
    table.insert(self.gameNode,node4)

    local isret = false
    for k,v in pairs(self.tingData) do
        if v.OwnerID == PlatformLogic.loginResult.dwUserID then
            isret = true;
        end
    end

    if isret == false then
        self.shenqingjiaru:setPosition(self.size.width/2+300,42)
        self.kaitongvipting:setVisible(true) 
    end

    self:showHallList()
    self:onClickItemBtn(self.allHallListLayout[1]:getChildByName("btn"))
    
end

function VipHallLayer:showShengqingBtn(enable)
    local isret = false
    for k,v in pairs(self.tingData) do
        if v.OwnerID == PlatformLogic.loginResult.dwUserID then
            isret = true;
        end
    end

    if isret == false then
        self.shenqingjiaru:setVisible(enable)
        self.kaitongvipting:setVisible(enable) 
    else
        self.shenqingjiaru:setVisible(enable)
    end
end

function VipHallLayer:createItem(index,tingTable)
    -- luaDump(tingTable,"tingTable")
    local layout = ccui.Layout:create()
    --layout:setPosition(115,10+73*k)
    layout:setContentSize(cc.size(200, 103))
   -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    layout:setName(index)
    --layout:setBackGroundColor(cc.c3b(255, 0, 0))

    local vipHallbutton = ccui.Button:create("newExtend/vip/viphall/tinganniu1.png","newExtend/vip/viphall/tinganniu1-on.png","newExtend/vip/viphall/tinganniu2.png")
    vipHallbutton:setAnchorPoint(cc.p(0,0))
    vipHallbutton:setName("btn")
    vipHallbutton:setTag(index)
    layout:addChild(vipHallbutton)
    vipHallbutton:onClick(function(sender) self:onClickItemBtn(sender) end)

    local vipName = cc.Label:createWithSystemFont(tingTable.GuildName, "Arial" ,24 ,cc.c3b(188,213,235));
    vipName:setPosition(90,85)
    vipName:setName("text1")
    vipName:setAnchorPoint(cc.p(0.5,0.5))
    layout:addChild(vipName)

    local vipid = cc.Label:createWithSystemFont("ID:"..tingTable.GuildID, "Arial" ,24 ,cc.c3b(188,213,235));
    vipid:setPosition(90,55)
    vipid:setName("text2")
    vipid:setAnchorPoint(cc.p(0.5,0.5))
    layout:addChild(vipid)

    if tingTable.OwnerID == PlatformLogic.loginResult.dwUserID then --厅主是自己
        local zhu = ccui.ImageView:create("newExtend/vip/viphall/zhu.png")
        zhu:setPosition(0,layout:getContentSize().height - 23)
        zhu:setAnchorPoint(cc.p(0,0.5))
        layout:addChild(zhu)
    end

    local ding = ccui.Button:create("newExtend/vip/viphall/ding.png","newExtend/vip/viphall/ding-on.png")
    ding:setPosition(layout:getContentSize().width-30,layout:getContentSize().height/2)
    ding:setName("ding")
    ding:setTag(index)
    layout:addChild(ding)
    ding:setVisible(false)
    ding:onClick(function(sender) self:onClickSort(sender); end)

    return layout;
end

function VipHallLayer:showHallList()
    self.Node_left:removeAllChildren();
    self.allHallListLayout = {}
    -- luaDump(self.tingData,"self.tingData")
    if #self.tingData > 4 then
        local listView = ccui.ListView:create()
        listView:setAnchorPoint(cc.p(0.5,0.5))
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setScrollBarEnabled(false)
        --listView:setName("listView"..tag)
        listView:setContentSize(cc.size(240, 510))
        listView:setPosition(110,335)
        self.Node_left:addChild(listView)
        for k,tingTable in pairs(self.tingData) do
            local layout = self:createItem(k,tingTable)
            table.insert(self.allHallListLayout,layout)
            listView:pushBackCustomItem(layout)
        end
    else
        for k,tingTable in pairs(self.tingData) do
            local layout = self:createItem(k,tingTable)
            table.insert(self.allHallListLayout,layout)
            layout:setPosition(20,600 - 108 *k) 
            self.Node_left:addChild(layout)
        end
    end

    self:getGameNameTable();
    
    -- self.gameNameTable = {"dz_ddz","game_ppc","game_brps","game_30miao","dz_szp"} --当前厅的游戏


    -- for k,layout in pairs(isShowAllLayout) do
    --     listView:pushBackCustomItem(layout)
    -- end
end

function VipHallLayer:getGameNameTable()
    self.gameNameTable = clone(self.sGameName) --当前厅的游戏
    -- addScrollMessage(self.tingid)
    local GameStates = self.tingData[self.tingid].GameStates;
    local RoomStates = self.tingData[self.tingid].RoomStates
    -- luaPrint("getGameNameTable "..#self.gameNameTable)
    for k=#self.gameNameTable,1,-1 do
        local sGameName = self.gameNameTable[k];
        -- luaPrint("sGameName= "..sGameName)
        local x = VipRoomInfoModule:getIDBysGameName(sGameName)
        if x > 0 then
            local idx = string.sub(GameStates,x,x)
            if idx == "0" then
                local roomList = VipRoomInfoModule:getRoomListBysGameName(sGameName)
                local ishave = false
                for kk,vv in pairs(roomList) do
                    local xx = string.sub(RoomStates,vv,vv)
                    if xx == "1" then
                        ishave = true;
                        break;
                    end
                end
                if ishave == false then
                    -- luaPrint("sGameName1 = "..self.gameNameTable[k])
                    table.remove(self.gameNameTable,k)
                end
            end
        end
    end

    local gameList = GamesInfoModule._gameNames

    self.gameList = gameList or {}

    -- luaDump(self.gameList,"self.gameList11")

    if #self.gameList > 0 then
        for k=#self.gameNameTable,1,-1 do
            local ishave = false
            for kk,vv in pairs(self.gameList) do
                if self.gameNameTable[k] == self.gameList[kk].szGameName then
                    ishave = true;
                    break;
                end
                if self.gameNameTable[k] == "lkpy_0" and "lkpy_4"== self.gameList[kk].szGameName then
                    ishave = true;
                    break;
                end
                if self.gameNameTable[k] == "dz_ssz" then
                    if "dz_ssz6r"== self.gameList[kk].szGameName or "dz_ssz8r"== self.gameList[kk].szGameName then
                        ishave = true;
                        break;
                    end
                end
                if self.gameNameTable[k] == "dz_lq_ssz" then
                    if "dz_lq_ssz6r"== self.gameList[kk].szGameName or "dz_lq_ssz8r"== self.gameList[kk].szGameName then
                        ishave = true;
                        break;
                    end
                end
            end
            if self.gameNameTable[k] == "lkpy_0" and ishave then
                --是否开启游戏
                local x1 = 0
                local x2 = 0
                local x3 = 0
                local x4 = 0
                for k,v in pairs(self.gameList) do
                    if "lkpy_0" == v.szGameName then
                        x1 = 1
                    end
                    if "lkpy_4"== v.szGameName then
                        x2 = 1
                    end
                end
                local roomList = VipRoomInfoModule:getRoomListBysGameName(self.gameNameTable[k])
                for m,n in pairs(roomList) do
                    local xx = string.sub(RoomStates,n,n)
                    if m<= 4 then
                        if xx == "1"  then
                            x3 = 1
                        end
                    else
                        if xx == "1"  then
                            x4 = 1
                        end
                    end
                end
                if (x1==1 and x2 == 0 and x3 == 0 and x4 == 1) or (x1==0 and x2 == 1 and x3 == 1 and x4 == 0) then
                    ishave = false
                end
            end
            if ishave == false then
                -- luaPrint("sGameName1 = "..self.gameNameTable[k])
                table.remove(self.gameNameTable,k)
            end
        end
    else
        dispatchEvent("requestGameList")
    end
    
    -- local glen = string.len(GameStates)
    
    -- for i=1,glen do
    --     local idx = string.sub(GameStates,i,i)
    --     local sGameName = VipRoomInfoModule:getsGameNameByID(i)
    --     if sGameName ~= "" then
    --         if idx == "1" then
    --             table.insert(self.gameNameTable,sGameName)
    --         else
    --             local roomList = VipRoomInfoModule:getRoomListBysGameName(sGameName)
    --             for k,v in pairs(roomList) do
    --                 local x = string.sub(RoomStates,v,v)
    --                 if x == "1" then
    --                     table.insert(self.gameNameTable,sGameName)
    --                     break;
    --                 end
    --             end
    --         end 
    --     end
    -- end



    -- if runMode == "release" then
    --     for k,v in pairs(self.gameNameTable) do
    --         if v == "game_slhb" then
    --             table.remove(self.gameNameTable,k)
    --         end
    --     end
    -- end
    -- for k=#self.gameNameTable,1,-1 do
    --     if v == "game_slhb" then
    --         table.remove(self.gameNameTable,k)
    --     end
    -- end

    -- self:SortGameName();
    -- for k,v in pairs(self.sGameName) do
    --     local idx = string.sub(GameStates,k,k)
    --     if idx == "1" then
    --         table.insert(self.gameNameTable,v)
    --     else
    --         for kk,room in pairs(self.chooseRoomTable[k]) do
    --             if room == 1 then
    --                 table.insert(self.gameNameTable,v)
    --                 break;
    --             end
    --         end
    --     end
    -- end
    -- local count = 0
    -- for k,v in pairs(self.gameNameTable) do
    --     if v=="lkpy_0"then
    --         count = count +1;
    --     end
        
    -- end
    -- if count == 2 then
    --     table.remove(self.gameNameTable,#self.gameNameTable)
    -- end
    -- luaDump(self.gameNameTable,"self.gameNameTable")
end

--扫雷红包插在对战前面
function VipHallLayer:SortGameName()
    local index = 0
    local ishave = false
    for k,v in pairs(self.gameNameTable) do
        if v == "game_slhb" then
            ishave = true
            table.remove(self.gameNameTable,k)
        end
    end
    if ishave then
         for k,v in pairs(self.gameNameTable) do
            if string.find(v,"dz_") then
                index = k;
                break
            end
        end
        if index> 0 then
            table.insert(self.gameNameTable,index,"game_slhb")
        else
            table.insert(self.gameNameTable,"game_slhb")
        end
    end
    
end

function VipHallLayer:onClickSort(sender)
    VipInfo:sendGuildSettop(self.tingData[self.tingid].GuildID)
    -- local tag = sender:getTag();
end

function VipHallLayer:onClickItemBtn(sender)
    local tag = sender:getTag();
    self.tingid = tag;
    globalUnit.nowTingId = self.tingData[self.tingid].GuildID;
    self.nowTingId = self.tingData[self.tingid].GuildID;
    self:getGameNameTable();
    for k,layout in pairs(self.allHallListLayout) do
        local btn = layout:getChildByName("btn")
        local ding = layout:getChildByName("ding")
        local text1 = layout:getChildByName("text1")
        local text2 = layout:getChildByName("text2")
        if k == tag then
            btn:setEnabled(false)
            text1:setColor(cc.c3b(114,46,33))
            text2:setColor(FontConfig.colorWhite)
            if globalUnit.selectTingID == nil or self.Node_right:isVisible() == false then
                self:onClickTypeBtn(self.gameBtn[1]) 
            end
            globalUnit.selectTingID = nil; 
            
            self:updateTextAndBtn(tag)
            if tag ~= 1 then
                ding:setVisible(true)
            end
        else
            btn:setEnabled(true)
            text1:setColor(cc.c3b(188,213,235))
            text2:setColor(cc.c3b(188,213,235))
            ding:setVisible(false)
        end
    end
end

function VipHallLayer:updateTextAndBtn(tag)
    if self.tingData[tag].OwnerID == PlatformLogic.loginResult.dwUserID then --厅主是自己
        self.viptingguanli:setTag(2)
        self.viptingguanli:loadTextures("newExtend/vip/viphall/viptingguanli.png","newExtend/vip/viphall/viptingguanli-on.png")
        -- self.shenqingjiaru:setTag(3)
        -- self.shenqingjiaru:loadTextures("newExtend/vip/viphall/shenqingjiaru.png","newExtend/vip/viphall/shenqingjiaru-on.png")
        self.shezhiBtn:setVisible(true)
    else
        self.viptingguanli:setTag(4)
        self.viptingguanli:loadTextures("newExtend/vip/viphall/tingxiangqing.png","newExtend/vip/viphall/tingxiangqing-on.png")
        -- self.shenqingjiaru:setTag(5)
        -- self.shenqingjiaru:loadTextures("newExtend/vip/viphall/kuaisukaishi.png","newExtend/vip/viphall/kuaisukaishi-on.png")
        self.shezhiBtn:setVisible(false)
    end
    --self.gameText[1]:setString("玩法:百人牛牛、飞禽走兽、奔驰宝马、斗地主、龙虎斗、十点半")
    self:showPlayAction();
    self.gameText[2]:setString("厅名:"..self.tingData[tag].GuildName)
    self.gameText[3]:setString("厅ID:"..self.tingData[tag].GuildID)
    self.gameText[4]:setString("厅主ID:"..self.tingData[tag].OwnerID)
    self.gameText[5]:setString("成员:"..self.tingData[tag].MemberCount)
end

function VipHallLayer:showPlayAction()
    local str = "玩法:";
    for i,v1 in pairs(self.gameNameTable) do
        local index = 0;
        for k,v2 in pairs(self.sGameName) do
            if v1 == v2 then
                index = k;
                break;
            end
        end
        if index ~= 0 then
            if i ~= #self.gameNameTable then
                str = str..self.gameNameAllList[index].."、"
            else
                str = str..self.gameNameAllList[index]
            end
        end
    end
    self.gameText[1]:setString(str)

    if self.gameText[1]:getContentSize().width > 640 then
        self.gameText[1]:stopAllActions();
        local time = self.gameText[1]:getContentSize().width/100
        self.gameText[1]:setPosition(640,20)
        local moveTo = cc.MoveTo:create(time,cc.p(-self.gameText[1]:getContentSize().width,20));
        local callback = cc.CallFunc:create(function ()
                            self.gameText[1]:setPosition(640,20)
                        end)
        self.gameText[1]:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo,callback)))
    else
        self.gameText[1]:stopAllActions();
        self.gameText[1]:setPosition(0,20)
    end
end

function VipHallLayer:showRightGameList(gameNameTable)
    self.Node_right:setVisible(true)
    self.zhuozi:removeAllChildren();
    self.VIPGameListLayer = require("hall.layer.popView.newExtend.vip.VIPGameListLayer"):create(gameNameTable,self.tingData[self.tingid].RoomStates)
    self.zhuozi:addChild(self.VIPGameListLayer)
    -- local layer = require("layer.popView.GameListLayer"):create(gameNameTable,self.tingData[self.tingid].RoomStates)
    -- layer:setName("GameListLayer")
    -- self:addChild(layer)
end

function VipHallLayer:setChooseRule(name,chooseGame,chooseRoom,tax,tingid)
    -- self.isChooseEnd = true;
    -- addScrollMessage("chooseGame,chooseRoom"..chooseGame..chooseRoom)
    VipInfo:sendChangeRule(self.tingData[tingid].GuildID,name,chooseGame,chooseRoom,tax)
    
end

function VipHallLayer:onRoomLoginError(data)
    local data = data._usedata
    if self.VIPGameListLayer then
        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if data == 1 then
            self.VIPGameListLayer:getChildByName("mask1"):setVisible(true)
            self:showShengqingBtn(true)
            if  layer1 then
                RoomLogic:close();
                Hall:exitGame(3);
                Hall:exitGame()
            elseif  layer then
                Hall:exitGame()
            end
        elseif data == 2 then
            self.VIPGameListLayer:getChildByName("mask1"):setVisible(true)
            self:showShengqingBtn(true)
        elseif data == 3 then
            if layer then
                RoomLogic:close()
                layer:show()
            end
        end
    end
end

function VipHallLayer:refreshVIPGameList()
    -- VipInfo:sendGetVipInfo()
    local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
    local layer1 = display.getRunningScene():getChildByName("OpenVipLayer")
    local layer2 = display.getRunningScene():getChildByName("TypeSetLayer")
    self:getGameNameTable();
    self:showRightGameList(self.gameNameTable);
    if layer then
        self.VIPGameListLayer:getChildByName("mask1"):setVisible(false)
        self:showShengqingBtn(false)
    end
    if layer1 and layer2 then
        layer2:removeSelf()
        layer1:onClickBtn();
    end
end

function VipHallLayer:onClickBtn(sender)
    local tag = sender:getTag();
    -- addScrollMessage(tostring(tag));
    if tag == 0 then --返回
        dispatchEvent("registerLayerUpCallBack");
        if self.VIPGameListLayer then
            local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
            local layer1 = display.getRunningScene():getChildByName("deskLayer")

            if  layer then
                if  layer1 then 
                    RoomLogic:close();
                    Hall:exitGame(3);
                end
                Hall:exitGame()
                Hall:exitGame()
                -- self.VIPGameListLayer:removeChildByName("mask2")
                self.VIPGameListLayer:getChildByName("mask1"):setVisible(true)
                self:showShengqingBtn(true)
            else
                self:delayCloseLayer(0);
                globalUnit.nowTingId = 0;
                globalUnit.VipRoomList = nil;
            end
        end
        
    elseif tag == 1 then --设置
        VipInfo:sendGuildChangeRuleReq()
        
        -- local layer = require("hall.layer.popView.newExtend.vip.TypeSetLayer"):create(true,self.tingData[self.tingid].GameStates,self.tingData[self.tingid].RoomStates)
        -- display.getRunningScene():addChild(layer)
        -- layer:setChooseEndCallback(function (chooseGame,chooseRoom)
        --     self:setChooseRule(chooseGame,chooseRoom,self.tingid)
        -- end)
    elseif tag == 2 then --管理
        display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.VipManagement"):create(self.tingData[self.tingid],self))
        -- VipInfo:sendGetGuildUserInfo(self.tingData[self.tingid].GuildID)
    elseif tag == 3 then --加入
        display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.JoinVipLayer"):create())
    elseif tag == 4 then --详情
        display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.VipDetaislLayer"):create(self.tingData[self.tingid],self))
    elseif tag == 5 then --快速开始

    elseif tag == 6 then --开通VIP厅
        VipInfo:sendCreateReqMember()
    end
end

function VipHallLayer:onClickTypeBtn(sender)
    local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer");
    local layer1 = display.getRunningScene():getChildByName("deskLayer")
    if layer1 then
        RoomLogic:close();
        Hall:exitGame(3)
        Hall:exitGame()
    elseif layer then
        Hall:exitGame()
    end
    self:showShengqingBtn(true)

    local tag = sender:getTag();
    -- luaDump(self.gameNameTable,"self.gameNameTable")
    for k,btn in pairs(self.gameBtn) do
        if tag == k then
            btn:setEnabled(false);
            if tag == 1 then
                self:showRightGameList(self.gameNameTable);
            else
                local temp = {};
                local subFlag = "lkpy_"
                if tag == 2 then
                    subFlag = "game_"
                elseif tag == 3 then
                    subFlag = "dz_"
                end
                for k,szName in pairs(self.gameNameTable) do
                    if string.find(szName,subFlag) then
                        table.insert(temp,szName)
                    end
                end
                self:showRightGameList(temp);
            end
        else
            btn:setEnabled(true)
        end
    end
end

function VipHallLayer:receiveChangeRuleInfo(data)
     local data = data._usedata;
    local code = data[2]
    if code== 0 then--修改成功
        addScrollMessage("修改成功")
        self.tingData[self.tingid].GameStates = data[1].GameStates;
        self.tingData[self.tingid].RoomStates = data[1].RoomStates;
        self.tingData[self.tingid].GuildName = data[1].GuildName;
        self.tingData[self.tingid].iTaxRate = data[1].iTaxRate;
        -- luaDump(self.tingData[self.tingid],"self.tingData[self.tingid]")
        self:showHallList()
        self:onClickTypeBtn(self.gameBtn[1])
        self:onClickItemBtn(self.allHallListLayout[self.tingid]:getChildByName("btn"))
        if display.getRunningScene():getChildByName("OpenVipLayer") then
            display.getRunningScene():getChildByName("OpenVipLayer"):removeSelf();
        end
    elseif code== 3 then
        addScrollMessage("厅名称已存在")
    else
        addScrollMessage("修改失败")
    end
end

function VipHallLayer:receiveCreateReqMember(data)
    local data = data._usedata;
    local code = data[2]
    if code== 0 then--查询成功
        local layer = require("hall.layer.popView.newExtend.vip.OpenOrJoinLayer"):create(data[1],1)
        layer:setName("OpenOrJoinLayer")
        display.getRunningScene():addChild(layer)
        -- display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.OpenOrJoinLayer"):create(data[1],1))
    end
end

function VipHallLayer:receiveGuildSettop(data)
    local data = data._usedata;
    local code = data[1]
    if code== 0 then--置顶成功
        addScrollMessage("置顶成功")
        local tempData = {};
        table.insert(tempData,self.tingData[self.tingid])
        for k,v in pairs(self.tingData) do
            if k ~= self.tingid then
                table.insert(tempData,v)
            end
        end
        self.tingData = tempData;
        self:showHallList();
        self:onClickItemBtn(self.allHallListLayout[1]:getChildByName("btn"))
    end
end

function VipHallLayer:recGuildChangeRuleReq(data)
    local data = data._usedata;
    if display.getRunningScene():getChildByName("OpenVipLayer") then
        return;
    end
    local Setlayer = require("hall.layer.popView.newExtend.vip.OpenVipLayer"):create(data,self.tingData[self.tingid])
    display.getRunningScene():addChild(Setlayer)
    Setlayer:setName("OpenVipLayer")
    Setlayer:setChooseEndCallback(function (name,chooseGame,chooseRoom,tax)
        self:setChooseRule(name,chooseGame,chooseRoom,tax,self.tingid)
    end)
end

function VipHallLayer:recRoomGuildChange(data)
    local code = data._usedata;
    
    if code == 1 then --///解散
        if Hall:getCurGameName() == "fishing" then
            addScrollMessage("厅主已解散该VIP厅，将自动退回到VIP大厅")
        else
            addScrollMessage("厅主已解散该VIP厅，将在本局比赛结束退回到VIP大厅")
        end
        self:clearSchedule();
        self.updateSchedule = schedule(self, function() self:callEverySecond(1); end, 1);
    elseif code == 2 then --///税率修改
        if Hall:getCurGameName() == "fishing" then
            addScrollMessage("厅主修改了VIP厅规则")
        else
            addScrollMessage("厅主修改了VIP厅规则，将在下局生效")
        end
    elseif code == 3 then --///关闭房间
        if Hall:getCurGameName() == "fishing" then
            addScrollMessage("厅主已去除该游戏，将自动退回VIP大厅")
        else
            addScrollMessage("厅主已去除该游戏，将在本局结束自动退回VIP大厅")
        end
        self:clearSchedule();
        self.updateSchedule = schedule(self, function() self:callEverySecond(3); end, 1);
    elseif code == 4 then --///被踢出厅
        if Hall:getCurGameName() == "fishing" then
            addScrollMessage("您被厅主踢出了VIP厅，将自动退回到VIP大厅")
        else
            addScrollMessage("您被厅主踢出了VIP厅，将在本局比赛结束退回到VIP大厅")
        end
        self:clearSchedule();
        self.updateSchedule = schedule(self, function() self:callEverySecond(4); end, 1);
        
    end
end

function VipHallLayer:callEverySecond(itype)
    -- local layer = display.getRunningScene():getChildByName("gameLayer")
    -- local layer1 = display.getRunningScene():getChildByName("mGameLayer")
    -- local layer2 = display.getRunningScene():getChildByName("loadLayer")
    -- if layer or layer1 or layer2 then
    if globalUnit.isEnterGame == true then 
        
    else
        self:clearSchedule();
        
        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame();
        end
        if itype == 1 or itype == 4 then
            if #self.tingData >1 then
                VipInfo:sendGetVipInfo()
            else
                self:delayCloseLayer(0);
            end
        elseif itype == 3 then
            VipInfo:sendGetVipInfo()
        end
    end
end

function VipHallLayer:clearSchedule()
    if self.updateSchedule then
        self:stopAction(self.updateSchedule);
        self.updateSchedule = nil;
    end
end

function VipHallLayer:recguildDeleteNotify(data)
    local data = data._usedata;
    -- local layer = display.getRunningScene():getChildByName("gameLayer")
    local layer1 = display.getRunningScene():getChildByName("mGameLayer")
    -- local layer2 = display.getRunningScene():getChildByName("loadLayer")
    local name = ""
    for k,v in pairs(self.tingData) do
        if data.GuildID == v.GuildID then
            name = v.GuildName
        end
    end

    addScrollMessage("厅主解散了"..name.."VIP厅")
    if globalUnit.isEnterGame == true then
        -- addScrollMessage("厅主解散了该VIP厅")
        self:clearSchedule();
        self.updateSchedule = schedule(self, function() self:callEverySecond(1); end, 1);
    else
        if globalUnit.isStartMatch or layer1 then
            LoadingLayer:removeLoading()
            Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end)
        end

        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame();
        end
        if #self.tingData >1 then
            VipInfo:sendGetVipInfo()
        else
            self:delayCloseLayer(0);
        end
        
    end
end

function VipHallLayer:recguildChangeNotify(data)
    local data = data._usedata;
    -- local layer = display.getRunningScene():getChildByName("gameLayer")
    local layer1 = display.getRunningScene():getChildByName("mGameLayer")
    -- local layer2 = display.getRunningScene():getChildByName("loadLayer")
    local name = ""
    for k,v in pairs(self.tingData) do
        if data.GuildID == v.GuildID then
            name = v.GuildName
        end
    end
    addScrollMessage("厅主修改了"..name.."VIP厅规则")

    if globalUnit.isEnterGame == true then
        -- addScrollMessage("厅主修改了房间")
        self:clearSchedule();
        self.updateSchedule = schedule(self, function() self:callEverySecond(3); end, 1);
    else
        if globalUnit.isStartMatch or layer1 then
            LoadingLayer:removeLoading()
            Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end)
        end

        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame()
        end
        
        VipInfo:sendGetVipInfo()
    end
    
end

function VipHallLayer:recguildKickNotify(data)
    local data = data._usedata;
    -- local layer = display.getRunningScene():getChildByName("gameLayer")
    local layer1 = display.getRunningScene():getChildByName("mGameLayer")
    -- local layer2 = display.getRunningScene():getChildByName("loadLayer")
    local name = ""
    for k,v in pairs(self.tingData) do
        if data.GuildID == v.GuildID then
            name = v.GuildName
        end
    end
    addScrollMessage("您被厅主踢出了"..name.."VIP厅")

    if globalUnit.isEnterGame == true then
        -- addScrollMessage("厅主修改了房间")
        self.updateSchedule = schedule(self, function() self:callEverySecond(4); end, 1);
    else
        if globalUnit.isStartMatch or layer1 then
            LoadingLayer:removeLoading()
            Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end)
        end

        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame()
        end
        
        if #self.tingData >1 then
            VipInfo:sendGetVipInfo()
        else
            self:delayCloseLayer(0);
        end
    end
    
end

function VipHallLayer:delayCloseLayer(dt,callback)
    self.super.delayCloseLayer(self,dt,callback)
    globalUnit.nowTingId = 0;
    globalUnit.VipRoomList = nil;
end

function VipHallLayer:refreshLayer(data)
    local isRemove = true; --是否移除当前厅
    self.tingData = data;
    local tag = 1;
    for k,v in pairs(self.tingData) do
        if v.GuildID == globalUnit.nowTingId then
            self.gameText[5]:setString("成员:"..v.MemberCount)
            isRemove = false;
            tag = k;
        end
    end
    self.tingid = tag;
     self:showHallList()
    if isRemove then
        self:onClickItemBtn(self.allHallListLayout[1]:getChildByName("btn"))
    else
        self:onClickItemBtn(self.allHallListLayout[tag]:getChildByName("btn"))
    end
    local isret = false
    for k,v in pairs(self.tingData) do
        if v.OwnerID == PlatformLogic.loginResult.dwUserID then
            isret = true;
        end
    end

    local size = self.bg:getContentSize()
    if isret == false then
        -- self.shenqingjiaru:setPosition(self.size.width/2+300,42)
        -- self.kaitongvipting:setVisible(true) 
    else
        self.kaitongvipting:setVisible(false)
        self.shenqingjiaru:setPosition(size.width/2+150,42)
    end
    performWithDelay(self,function()
        GamePromptLayer:remove();
    end,1)
    
end

return VipHallLayer
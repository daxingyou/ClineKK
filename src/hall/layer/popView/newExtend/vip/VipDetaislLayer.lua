--厅详情
local VipDetaislLayer = class("VipDetaislLayer", PopLayer)

function VipDetaislLayer:create(data,layer)
	return VipDetaislLayer.new(data,layer)
end

function VipDetaislLayer:ctor(data,layer)
	
	self.super.ctor(self,PopType.none)
	
    self.data = data; --收到的数据
    self.layer = layer

	self:initData()

	self:initUI()

	-- VipInfo:sendMemberuserList(self.data.GuildID)

    self:bindEvent()
end

function VipDetaislLayer:initData()
    self.Alldata = {{},{},{}};
    self.userList = {} --厅成员
    self.recodeReqList = {}
    self.allUsers = {}
    self.RoomID = ""
    self.tuijianList = {} --推荐成员详情
    self.Timet3 = os.time();--推荐成员详情

    self.dateT3 = 1;--推荐成员详情 第几天 前一天+1，后一天-1
    self.buttonIndex = 1;--默认第一个按钮
end

function VipDetaislLayer:bindEvent()
	self:pushEventInfo(VipInfo,"memberUserList",handler(self, self.receiveGetGuildUser))
    self:pushEventInfo(VipInfo,"quitGuildInfo",handler(self, self.receiveQuitGuildInfo))
    self:pushEventInfo(VipInfo,"guildCommendTime",handler(self, self.receiveGuildCommendTime))
    self:pushEventInfo(VipInfo,"guildCommendReq",handler(self, self.receiveGuildCommendReq))
    self:pushEventInfo(VipInfo,"guildCommend",handler(self, self.receiveGuildCommend))
    self:pushEventInfo(VipInfo,"guildCommendDetail",handler(self, self.receiveGuildCommendDetail))

    
end

function VipDetaislLayer:receiveGetGuildUser(data)
    local data = data._usedata;
    local code = data[2]
    
    if code== 0 or code== 1 then
        for k,v in pairs(data[1]) do
            table.insert(self.userList,v)
        end 
    end

    if code== 1 then--
        self:sortGuildUser()--厅主排序，第一位
        self.Alldata[1] = self.userList;
        self:receiveData()
        -- self.allUsers = clone(self.userList)
        for k,v in pairs(self.userList) do
            if v.UserID == PlatformLogic.loginResult.dwUserID and v.MemberType == 2 then
                self.ButtonTable[2]:setVisible(true)
                self.ButtonTable[3]:setVisible(true)
            end
        end
        self.userList= {}
    elseif code== 2 then
        addScrollMessage("厅不存在")
        local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
        local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame()
        end
        self.layer:delayCloseLayer(0)
        globalUnit.nowTingId = 0;
        globalUnit.VipRoomList = nil;
        self:removeSelf()
    end
end

function VipDetaislLayer:sortGuildUser()
    local guser = nil
    for k,v in pairs(self.userList) do
        if v.UserID == self.data.OwnerID then
            guser = v;
            table.remove(self.userList,k)
        end
    end
    if guser then
        table.insert(self.userList,1,guser)
    end
end

function VipDetaislLayer:receiveQuitGuildInfo(data)
    local data = data._usedata;
    local code = data[1]

    if code== 0 then--
       addScrollMessage("退出成功")
       local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
       local layer1 = display.getRunningScene():getChildByName("deskLayer")
        if layer1 then
            RoomLogic:close();
            Hall:exitGame(3)
            Hall:exitGame()
        elseif layer then
            Hall:exitGame()
        end
       self.layer:delayCloseLayer(0)
       globalUnit.nowTingId = 0;
        globalUnit.VipRoomList = nil;
       self:removeSelf()
    elseif code== 1 then--
        
    end
end

function VipDetaislLayer:receiveGuildCommendTime(data)
    local data = data._usedata;
    -- local code = data[1]
    
    self.bili:setString((data.CommendRate/10).."%")
    local time = data.iLeftTime;
    if time == 0 then
        self.imagetip:setVisible(true);
        self.querenButton:setEnabled(true)
        self.SYtimeText:setVisible(false)
    else
        self.imagetip:setVisible(false);
        self.querenButton:setEnabled(false)
        self.SYtimeText:setVisible(true)
        self.SYtime = time;
        if self.updateScheduler then
            self:stopAction(self.updateScheduler)
            self.updateScheduler = nil;
        end
        self.updateScheduler = schedule(self, function() self:startTimer(1.0) end, 1.0)
    end

end

function VipDetaislLayer:receiveGuildCommendReq(data)
    local data = data._usedata;
    local code = data[2]

    if code == 0 then--
        self:IsSureApply(data[1])
    elseif code == 1 then--
        addScrollMessage("不是股东")
    elseif code == 2 then--
        addScrollMessage("已经是厅成员")
    elseif code == 3 then--
        addScrollMessage("冷却时间内中")
    elseif code == 4 then--
        addScrollMessage("玩家不存在")
    elseif code == 5 then--
        addScrollMessage("连续错误3次进入冷却时间")
        VipInfo:sendGuildCommendTime(self.data.GuildID)
    end
    
end

function VipDetaislLayer:receiveGuildCommend(data)
    local data = data._usedata;
    if data == 0 then
        addScrollMessage("玩家邀请成功")
    end

end

function VipDetaislLayer:receiveGuildCommendDetail(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.tuijianList,v)
        end
    end

    if code== 1 then--
        if #self.tuijianList == 0 then
            addScrollMessage("没有记录");
        end
        self.Alldata[3] = self.tuijianList;
        self:receiveData()
        self.tuijianList = {}
        -- luaDump(self.data,"receiveGuildRecordReqself.data")
    elseif code== 2 then
        addScrollMessage("没有记录")
        self.data[3] = self.tuijianList;
        self:receiveData()
        self.tuijianList = {}
    end

    

end


function VipDetaislLayer:receiveGuildRecordReq(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.recodeReqList,v)
        end
    end
           
    if code== 1 then--
        -- self.recodeReqList;
        display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.RoomDetailLayer"):create(self.data.GuildName,self.data.GuildID,self.recodeReqList))
        self.recodeReqList = {}
    end
end

--接受到消息
function VipDetaislLayer:receiveData(data)
    self:updateData();

end

function VipDetaislLayer:updateData()
    -- if self.rankTableView then
    --     self.rankTableView:reloadData();
    -- else
        self:createTableView();
    -- end
    if self.buttonIndex == 3 then
        self.timeText3:setString(timeConvert(self["Timet"..self.buttonIndex],1));
    end
end

function VipDetaislLayer:initUI()
    self:setName("VipDetaislLayer");
	local winSize = cc.Director:getInstance():getWinSize();

	local bg = ccui.ImageView:create("newExtend/vip/common/bgtype.png");
	bg:setPosition(winSize.width/2,winSize.height/2);
	self:addChild(bg);
    self.bg = bg;

    iphoneXFit(self.bg,1);

	local size = bg:getContentSize();
    self.size = size;

	local ding = ccui.ImageView:create("newExtend/vip/common/ding.png");
	ding:setAnchorPoint(0,1);
	ding:setPosition(0,size.height);
	bg:addChild(ding);

    -- local Image_ziBg = ccui.ImageView:create("newExtend/vip/common/dingzibg.png");
    -- Image_ziBg:setAnchorPoint(0,1);
    -- Image_ziBg:setPosition(-180,size.height);
    -- bg:addChild(Image_ziBg);

	local bttitle = ccui.ImageView:create("newExtend/vip/detail/tigxiangqing.png");
	-- bttitle:setAnchorPoint(0,1)
	bg:addChild(bttitle);
	bttitle:setPosition(cc.p(430,winSize.height-35));

	local closeBtn = ccui.Button:create("newExtend/vip/common/fanhui.png","newExtend/vip/common/fanhui-on.png");
	closeBtn:setPosition(0,size.height-38);
    closeBtn:setAnchorPoint(cc.p(0,0.5))
	bg:addChild(closeBtn);
	closeBtn:onClick(function(sender) self:removeSelf() end)

    self.ButtonTable = {};
    local buttonStr1 = {"tingchengyuan1.png","chengyuantuijian.png","tuijianchengyuanxiangqing.png"};
    local buttonStr2 = {"tingchengyuan1-on.png","chengyuantuijian-on.png","tuijianchengyuanxiangqing-on.png"};
    local buttonStr3 = {"tingchengyuan2.png","chengyuantuijian2.png","tuijianchengyuanxiangqing2.png"};
    for i=1,3 do
        local btn = ccui.Button:create("newExtend/vip/management/"..buttonStr1[i],"newExtend/vip/management/"..buttonStr2[i],"newExtend/vip/management/"..buttonStr3[i]);
        bg:addChild(btn);
        table.insert(self.ButtonTable,btn);
        btn:setPosition(size.width*0.5-540+(i-1)*150,605);
        btn:setTag(i);
        btn:onClick(function (sender)
            self:onClickButton(sender);
        end);
        if i>1 then
            btn:setVisible(false)
        end
    end

	local di = ccui.ImageView:create("newExtend/vip/detail/di.png");
	di:setPosition(size.width*0.5+75,size.height*0.45-35);
	bg:addChild(di);
    self.di = di;

	local tiao = ccui.ImageView:create("newExtend/vip/detail/tiao.png");
	tiao:setPosition(size.width*0.5+200,680);
	bg:addChild(tiao);

	local tingName = FontConfig.createWithSystemFont("厅名称:"..self.data.GuildName, 24,cc.c3b(188, 200, 235));
	tingName:setPosition(tiao:getContentSize().width*0.25,tiao:getContentSize().height*0.5)
	tiao:addChild(tingName);

	local tingId = FontConfig.createWithSystemFont("厅ID:"..self.data.GuildID, 24,cc.c3b(188, 200, 235));
	tingId:setPosition(tiao:getContentSize().width*0.75,tiao:getContentSize().height*0.5)
	tiao:addChild(tingId);

	local exitVipButton = ccui.Button:create("newExtend/vip/detail/tuichuting.png","newExtend/vip/detail/tuichuting-on.png");
	bg:addChild(exitVipButton)
	exitVipButton:setPosition(size.width*0.3,105);
	exitVipButton:setTag(1);
	exitVipButton:onClick(function (sender)
		self:ButtonClick(sender)
	end);
    self.exitVipButton = exitVipButton;

	local myRecordButton = ccui.Button:create("newExtend/vip/detail/wodezhanji.png","newExtend/vip/detail/wodezhanji-on.png");
	bg:addChild(myRecordButton)
	myRecordButton:setPosition(size.width*0.7,105);
	myRecordButton:setTag(2);
	myRecordButton:onClick(function (sender)
		self:ButtonClick(sender)
	end);
    self.myRecordButton = myRecordButton;


    local sskbg =  ccui.ImageView:create("newExtend/vip/common/sskuangbg.png");
    self.bg:addChild(sskbg);
    sskbg:setPosition(size.width*0.5+400,610);
    self.sskbg =sskbg;

    local edit = cc.Node:create();--ccui.ImageView:create("newExtend/vip/detail/shurukuang.png")
    edit:setPosition(cc.p(size.width*0.5+230,610));
    bg:addChild(edit);
    self.edit = edit;
    
    local foundEdit,editbg = createEditBox(edit," 输入玩家ID",cc.EDITBOX_INPUT_MODE_PHONENUMBER,nil,nil,"newExtend/vip/common/shurukuang.png")
    -- foundEdit:setMaxLength(7);
    self.foundEdit = foundEdit;
	
	-- local foundEdit = ccui.EditBox:create(edit:getContentSize(),ccui.Scale9Sprite:create())
 --    foundEdit:setAnchorPoint(cc.p(0.5,0.5))
 --    foundEdit:setPosition(cc.p(edit:getContentSize().width*0.5,edit:getContentSize().height*0.5))
 --    foundEdit:setFontSize(28)
 --    foundEdit:setPlaceHolder("  输入玩家ID")
 --    foundEdit:setPlaceholderFontColor(cc.c3b(216,226,233))
 --    foundEdit:setPlaceholderFontSize(20)
 --    foundEdit:setMaxLength(20)
 --    edit:addChild(foundEdit)
 --    self.foundEdit = foundEdit;
 --    foundEdit:setInputFlag(cc.EDITBOX_INPUT_MODE_NUMERIC)
 --    foundEdit:setMaxLength(6);
 --    foundEdit:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end);

    local foundButton = ccui.Button:create("newExtend/vip/detail/sousuo.png","newExtend/vip/detail/sousuo-on.png");
    foundButton:setPosition(cc.p(size.width*0.5+530,610))
    bg:addChild(foundButton);
    foundButton:onClick(function ()
    	self:foundPlay();
    end);
    self.foundButton = foundButton;

    local node_tuijian = cc.Node:create();
    bg:addChild(node_tuijian);
    self.node_tuijian = node_tuijian;

    --确认
    self.querenButton = ccui.Button:create("newExtend/vip/detail/queren1.png","newExtend/vip/detail/queren1-on.png","newExtend/vip/detail/queren1-b.png");
    node_tuijian:addChild(self.querenButton)
    self.querenButton:setPosition(size.width*0.5,105);
    -- self.querenButton:setVisible(false);
    self.querenButton:setEnabled(false)
    self.querenButton:setTag(1);
    self.querenButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end,1);
    local btnSize = self.querenButton:getContentSize()

    local imagetip = ccui.ImageView:create("newExtend/vip/detail/queren.png");
    imagetip:setPosition(btnSize.width/2,btnSize.height*0.6);
    self.querenButton:addChild(imagetip);
    self.imagetip = imagetip;

    local time = FontConfig.createWithCharMap("", "newExtend/vip/management/zitiao.png", 20, 26, "0");
    time:setPosition(btnSize.width*0.5,btnSize.height*0.55)
    self.querenButton:addChild(time)
    time:setVisible(false)
    self.SYtimeText = time;

    self.ssTishi = ccui.ImageView:create("newExtend/vip/detail/shuruid.png");
    self.ssTishi:setPosition(size.width*0.5,540);
    node_tuijian:addChild(self.ssTishi);

    

    --帮助按钮
    self.helpButton = ccui.Button:create("newExtend/vip/management/bangzhu.png","newExtend/vip/management/bangzhu-on.png");
    self.helpButton:setPosition(size.width*0.5+350,105);
    node_tuijian:addChild(self.helpButton)
    self.helpButton:onClick(function ()
        luaPrint("帮助按钮",self.ssTishiyu:isVisible());
        if self.ssTishiyu then
            self.ssTishiyu:setVisible(not self.ssTishiyu:isVisible())
        end
    end);
    -- self.helpButton:setVisible(false);
    -- self.helpButton:addTouchEventListener(function (sender,eventType)
    --     if eventType == ccui.TouchEventType.began or eventType == ccui.TouchEventType.ended then
    --         luaPrint("帮助按钮",self.ssTishiyu:isVisible());
    --         if self.ssTishiyu then
    --             self.ssTishiyu:setVisible(not self.ssTishiyu:isVisible())
    --         end
    --     elseif eventType == ccui.TouchEventType.canceled then
    --         if self.ssTishiyu then
    --             self.ssTishiyu:setVisible(false)
    --         end
    --     end
    -- end);

    local shurukuang1 = ccui.ImageView:create("newExtend/vip/common/shurukuang1.png");
    shurukuang1:setPosition(size.width*0.5,475);
    node_tuijian:addChild(shurukuang1);
    local sskSize = shurukuang1:getContentSize();

    local posX = 60;
    for i=1,11 do
        -- local di = ccui.ImageView:create("newExtend/vip/detail/hengxian.png")
        -- di:setPosition(sskSize.width/2+100*(i-4),sskSize.height*0.3)
        -- shurukuang1:addChild(di)

        local zitiao = FontConfig.createWithCharMap("", "newExtend/vip/common/zitiao2.png", 22, 30, "0");
        zitiao:setPosition(di:getContentSize().width/2,30)
        zitiao:setPosition(sskSize.width/2+50*(i-6),sskSize.height*0.5)
        shurukuang1:addChild(zitiao)
        self["AtlasLabel_id"..i] = zitiao
    end

    local tempIndex = 0;
    local y = 390;
    for i=1,12 do
        local btn = nil;
        local index = i;
        index = i;
        if i == 4 or i == 7 or i == 10 then
            tempIndex = 0;
            y = y - 68
        end
        if i <= 9 then --1-9
            btn = ccui.Button:create("newExtend/vip/join/join_"..index..".png","newExtend/vip/join/join_"..index.."-on.png")
            btn:setTag(i)
            btn:addClickEventListener(function(sender) self:onClickShuzi(sender) end)
        end

        if i == 10 then
            btn = ccui.Button:create("newExtend/vip/join/join_qingchu.png","newExtend/vip/join/join_qingchu-on.png")
            btn:setTag(3)
            btn:addClickEventListener(function(sender) self:onClickBtn(sender) end)
        end

        if i == 11 then
            btn = ccui.Button:create("newExtend/vip/join/join_0.png","newExtend/vip/join/join_0-on.png")
            btn:setTag(0)
            btn:addClickEventListener(function(sender) self:onClickShuzi(sender) end)
        end

        if i == 12 then
            btn = ccui.Button:create("newExtend/vip/join/join_shanchu.png","newExtend/vip/join/join_shanchu-on.png")
            btn:setTag(2)
            btn:addClickEventListener(function(sender) self:onClickBtn(sender) end)
        end

        btn:setPosition(size.width/2+(tempIndex-1)*210,y)
        node_tuijian:addChild(btn)
        tempIndex = tempIndex + 1;
    end

    local zhancheng = ccui.ImageView:create("newExtend/vip/detail/tuijianzhancheng-zi.png");
    zhancheng:setPosition(size.width*0.5-450,105);
    node_tuijian:addChild(zhancheng);

    local bili = FontConfig.createWithSystemFont("", 30,cc.c3b(255, 246, 0));
    node_tuijian:addChild(bili);
    bili:setPosition(size.width*0.5-260,105);
    self.bili = bili;

    self.ssTishiyu = ccui.ImageView:create("newExtend/vip/detail/shuoming.png");
    self.ssTishiyu:setPosition(size.width*0.5+105,185);
    node_tuijian:addChild(self.ssTishiyu);
    self.ssTishiyu:setVisible(false);

    self.timeBg = ccui.ImageView:create("newExtend/vip/detail/riqixuanze.png");
    self.timeBg:setPosition(bg:getContentSize().width*0.5,105);
    bg:addChild(self.timeBg);
    self.timeBg:setName("timeBg");
    self.timeBg:setVisible(false);

    --时间
    self.timeText3 = FontConfig.createWithSystemFont(timeConvert(self.time,1), 24,cc.c3b(222, 195, 111));
    self.timeText3:setPosition(self.timeBg:getContentSize().width*0.5,self.timeBg:getContentSize().height*0.5);
    self.timeBg:addChild(self.timeText3);
    self.timeText3:setName("timeText3");

    self.lastButton = ccui.Button:create("newExtend/vip/detail/zuo.png","newExtend/vip/detail/zuo-on.png");
    self.lastButton:setPosition(self.timeBg:getContentSize().width*0.1,self.timeBg:getContentSize().height*0.5);
    self.timeBg:addChild(self.lastButton);
    self.lastButton:setTag(4);
    self.lastButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    self.nextButton = ccui.Button:create("newExtend/vip/detail/you.png","newExtend/vip/detail/you-on.png");
    self.nextButton:setPosition(self.timeBg:getContentSize().width*0.9,self.timeBg:getContentSize().height*0.5);
    self.timeBg:addChild(self.nextButton);
    self.nextButton:setTag(5);
    self.nextButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    local vipTip = cc.Label:createWithSystemFont("VIP厅内可用金币为除去\n绑定送金奖励后的金币", "Arial" ,20 ,FontConfig.colorWhite);
    vipTip:setPosition(self.size.width*0.5+380,self.size.height*0.06)
    vipTip:setAnchorPoint(cc.p(0,0.5))
    vipTip:setVisible(false)
    bg:addChild(vipTip)
    self.vipTip = vipTip;

    local winsize =  cc.Director:getInstance():getWinSize();
    if checkIphoneX() then
        -- closeBtn:setPositionX(closeBtn:getPositionX()-(winsize.width-1280)/2);
        -- bttitle:setPositionX(bttitle:getPositionX()-(winsize.width-1280)/2);
    end
    
	self:receiveData();

    self:onClickButton(self.ButtonTable[1]);


end

function VipDetaislLayer:foundPlay()
	if not self.foundEdit then
		luaPrint("页面出现错误");
		return;
	end

	local str = self.foundEdit:getText();
	-- luaPrint("foundPlay",tonumber(str));

	if str ~= tostring(tonumber(str)) or tonumber(str)%1 ~=0 then
		addScrollMessage("输入有误,请重新输入！");
        return;
	end
    self.isFound = true;
    self:foundResultData(tonumber(str));--查询

    self:receiveData();


end

function VipDetaislLayer:foundResultData(dwUserID)
   
    self.foundData = {{},{},{}};
    if self.buttonIndex == 2 then
        return;
    end

    -- for i,vv in pairs(self.Alldata) do
        for k,v in pairs(self.Alldata[self.buttonIndex]) do
            if v.UserID == dwUserID then
                table.insert(self.foundData[self.buttonIndex],v);
            end
        end
    -- end

    luaDump(self.foundData,"self.foundData00");
    
    -- self.userList = self.foundData;
   
end
function VipDetaislLayer:editboxHandle(strEventName,sender)
	local tag = sender:getTag();
	luaPrint("editboxHandle",tag,strEventName);
	if strEventName == "began" then
		luaPrint("began");
	elseif strEventName == "ended" then
		luaPrint("began");
	elseif strEventName == "return" then
		
		local str = sender:getText();
		luaPrint("return",str);
	elseif strEventName == "changed" then
		luaPrint("changed");
	end
end

function VipDetaislLayer:ButtonClick(sender)
	local tag = sender:getTag();
	luaPrint("ButtonClick",tag);
	if tag == 1 then
        
        local prompt = GamePromptLayer:create();
        prompt:showPrompt(GBKToUtf8("确认退出厅?"));
        prompt:setBtnVisible(true,true)
        prompt:setBtnClickCallBack(function() 
           VipInfo:sendUserQuitGuild(self.data.GuildID)
        end);

		--display.getRunningScene():addChild(require("vip.VipManagement"):create())
	elseif tag == 2 then
		-- display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.RoomDetailLayer"):create())
        -- VipInfo:sendGuildRecordReq(PlatformLogic.loginResult.dwUserID,self.data.GuildID,1)
        display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.RoomDetailLayer"):create(self.data.GuildName,self.data.GuildID))
        
	end
end

--创建tableview
function VipDetaislLayer:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end

    local dis = 0;
    if self.buttonIndex == 3 then
        dis = 0;
    end

    if self.buttonIndex == 2 then
        return;
    end

	self.rankTableView = cc.TableView:create(cc.size(1210,380-dis));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(self.size.width*0.5-600,300*0.30+50));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function VipDetaislLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function VipDetaislLayer:Rank_cellSizeForTable(view, idx)  

    -- local width = self.Panel_otherMsg:getContentSize().width;
    -- local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return 1210, 100;  

end  
  
function VipDetaislLayer:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
   local data = self.Alldata;
   if self.isFound then
       data = self.foundData 
    end 
    return #data[self.buttonIndex] 
end  
  
function VipDetaislLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(1200, 100));
        rankItem:setPosition(0,0);
        rankItem:setName("item");
        if rankItem then
            self:setRankInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("item");
        self:setRankInfo(rankItem,index);
    end
    
    return cell;
end 

function VipDetaislLayer:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local data = self.Alldata;
    if self.isFound then
       data = self.foundData 
    end  
    if self.buttonIndex == 1 or self.buttonIndex == 3 then
        local useName = rankItem:getChildByName("useName");--名字
        local useId = rankItem:getChildByName("useId"); --useId
        local headImage = rankItem:getChildByName("headImage");--头像
        headImage:loadTexture(getHeadPath(data[self.buttonIndex][index].iLogoID));--logoId
        useName:setString(FormotGameNickName(data[self.buttonIndex][index].NickName,nickNameLen));
        useId:setString("ID:"..data[self.buttonIndex][index].UserID);
        if self.buttonIndex == 1 then
            local useScore = rankItem:getChildByName("useScore");--useScore
            local tingzhu = rankItem:getChildByName("tingzhu");--头像
            --{ nickName = "常山赵子龙", dwUserID = 265895, score = 155220,},
            
            if data[self.buttonIndex][index].WalletMoney>=0 then
                useScore:setString(goldConvert(data[self.buttonIndex][index].WalletMoney));
            else
                useScore:setString(goldConvert(data[self.buttonIndex][index].WalletMoney));
            end
            
            if data[self.buttonIndex][index].UserID == self.data.OwnerID then
                tingzhu:setVisible(true)
            else
                tingzhu:setVisible(false)
            end
        elseif self.buttonIndex == 3 then
            local shuishou = rankItem:getChildByName("shuishou");
            local deshuishou = rankItem:getChildByName("deshuishou");
            
            shuishou:setString(goldConvert(data[self.buttonIndex][index].lTaxProduce,1));
            deshuishou:setString(goldConvert(data[self.buttonIndex][index].lTaxGet,1));
        end
    end
    
end

function VipDetaislLayer:createItem()

	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(cc.size(1210,100));
    --layout:setAnchorPoint(0.5,0.5);
    local size = cc.size(1210,100);

	--背景图片
	local itemBg = ccui.ImageView:create("newExtend/vip/detail/tiaobig.png");
    layout:addChild(itemBg);
    itemBg:setPosition(1200/2-5,size.height*0.5);

    if self.buttonIndex == 1  or self.buttonIndex == 3 then
        local headImage = ccui.ImageView:create("head/1.png");
        layout:addChild(headImage);
        headImage:setScale(0.5);
        headImage:setPosition(50,size.height*0.5);
        headImage:setName("headImage");

        

        local use = FontConfig.createWithSystemFont("昵称:", 24,cc.c3b(255, 255, 255));
        layout:addChild(use);
        use:setAnchorPoint(0.5,0.5);
        use:setPosition(size.width*0.15-10,size.height*0.5);
        use:setName("use");

        --名字
        local useName = FontConfig.createWithSystemFont("卡梅隆.安东尼", 24,cc.c3b(250, 200, 3));
        layout:addChild(useName);
        useName:setAnchorPoint(0,0.5);
        useName:setPosition(size.width*0.15+50,size.height*0.5);
        useName:setName("useName");

        --ID
        local useId= FontConfig.createWithSystemFont("ID:256987", 24,cc.c3b(255, 255, 255));
        layout:addChild(useId);
        useId:setAnchorPoint(0.5,0.5);
        useId:setPosition(size.width*0.5,size.height*0.5);
        useId:setName("useId");

        if self.buttonIndex == 1 then

            local tingzhu = ccui.ImageView:create("newExtend/vip/detail/zhu.png");
            layout:addChild(tingzhu);
            tingzhu:setPosition(20,size.height*0.7);
            tingzhu:setName("tingzhu");
            tingzhu:setVisible(false)

            local text= FontConfig.createWithSystemFont("金币:", 24,FontConfig.colorWhite);
            layout:addChild(text);
            text:setAnchorPoint(0.5,0.5);
            text:setPosition(size.width*0.80-30,size.height*0.5);
            text:setName("text");
            -- text:setColor(cc.c3b(225, 107, 36));--黄色

            --score
            local useScore= FontConfig.createWithSystemFont("+180", 24,FontConfig.colorBlack);
            layout:addChild(useScore);
            useScore:setAnchorPoint(0,0.5);
            useScore:setPosition(size.width*0.80+10,size.height*0.5);
            useScore:setName("useScore");
            useScore:setColor(cc.c3b(250, 200, 3));--黄色
        elseif self.buttonIndex == 3 then
            use:setPosition(size.width*0.15-10,size.height*0.7);
            useName:setPosition(size.width*0.15+30,size.height*0.7);
            useId:setPosition(size.width*0.15+20,size.height*0.3);

            --产生税收
            local shuishou = FontConfig.createWithSystemFont("876.64", 24,cc.c3b(250, 200, 3));
            layout:addChild(shuishou);
            shuishou:setAnchorPoint(0.5,0.5);
            shuishou:setPosition(size.width*0.50,size.height*0.5);
            shuishou:setName("shuishou");

            --获得税收
            local deshuishou = FontConfig.createWithSystemFont("756.64", 24,cc.c3b(250, 200, 3));
            layout:addChild(deshuishou);
            deshuishou:setAnchorPoint(0.5,0.5);
            deshuishou:setPosition(size.width*0.85,size.height*0.5);
            deshuishou:setName("deshuishou");
        end

    end

	return layout;
end

--刷新tableview
function VipDetaislLayer:updateTableView()

	self:createTableView();

end

function VipDetaislLayer:buttonCallBack(sender)
    local tag = sender:getTag()
    if tag == 1 then--确认
        luaPrint("确认");
        if self.RoomID == "" then
            addScrollMessage("请输入所邀请玩家ID")
            return;
        end
        local TargetUserID = tonumber(self.RoomID)
        VipInfo:sendGuildCommReq(self.data.GuildID,TargetUserID)
        -- self:IsSureApply()
        self.RoomID = ""
        for i=1,11 do
            self["AtlasLabel_id"..i]:setString("")
        end
    elseif tag == 4 then--前一天
        luaPrint("前一天");
        self.isFound = false;
        self["dateT"..self.buttonIndex] = self["dateT"..self.buttonIndex] +1
        if self["dateT"..self.buttonIndex] >7 then
            self["dateT"..self.buttonIndex] = 7;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            if self.buttonIndex == 3 then
                VipInfo:sendGuildCommendDetailHolder(self.data.GuildID,self["dateT"..self.buttonIndex])
            end
            self["Timet"..self.buttonIndex] = self["Timet"..self.buttonIndex] - 24*60*60;
        end
        -- self.currentPage = 1;
        -- self.isFound = false
    elseif tag == 5 then--下一天
        self.isFound = false;
        luaPrint("下一天");
        self["dateT"..self.buttonIndex] = self["dateT"..self.buttonIndex] -1
        if self["dateT"..self.buttonIndex] <1 then
            self["dateT"..self.buttonIndex] = 1;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            if self.buttonIndex == 3 then
                VipInfo:sendGuildCommendDetailHolder(self.data.GuildID,self["dateT"..self.buttonIndex])
            end
            self["Timet"..self.buttonIndex] = self["Timet"..self.buttonIndex] + 24*60*60;
        end

    end
end

function VipDetaislLayer:onClickButton(sender)
    local tag = sender:getTag();
    luaPrint("onClickButton",tag);
    self.buttonIndex = tag;
    if  self.buttonIndex == 1 then
        VipInfo:sendMemberuserList(self.data.GuildID)
        VipInfo:sendGuildSendMoneyReq();
    elseif  self.buttonIndex == 2 then
        -- VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
        VipInfo:sendGuildCommendTime(self.data.GuildID)
    elseif  self.buttonIndex == 3 then
        VipInfo:sendGuildCommendDetailHolder(self.data.GuildID,self["dateT"..self.buttonIndex])
    end
    
    
    self.isFound = false;
    for k,v in pairs(self.ButtonTable) do
        self.ButtonTable[k]:setEnabled(k~=tag)
    end

    self:updataTiao();

    self:updateTableView();

end

--条文字更新
function VipDetaislLayer:updataTiao()
    self:updataBtn();
    luaPrint("updataTiao",self.buttonIndex);
    if self.buttonIndex == 3 then
        local node = self.di:getChildByName("biaotilan");
        if node then
            node:removeFromParent();
        end
        local biaotilan = ccui.ImageView:create("newExtend/vip/detail/biaotilan.png");
        biaotilan:setPosition(self.di:getContentSize().width/2-80,self.di:getContentSize().height*0.92+5);
        self.di:addChild(biaotilan)
        biaotilan:setName("biaotilan");

        if self.buttonIndex == 3 then--推荐成员详情
            local strTable = {"chengyuanxinxi.png","chanshengshuishou.png","huodeshuishou.png"};
            local bit = {0.1,0.5,0.85};
            for i=1,#strTable do
                local sprite = ccui.ImageView:create("newExtend/vip/management/"..strTable[i]);
                sprite:setPosition(biaotilan:getContentSize().width*bit[i]+10,biaotilan:getContentSize().height*0.5);
                biaotilan:addChild(sprite);
            end
        end
    else
        local node = self.di:getChildByName("biaotilan");
        if node then
            node:removeFromParent();
        end
    end

end

--按钮显示控制
function VipDetaislLayer:updataBtn()
    self.exitVipButton:setVisible(self.buttonIndex == 1)
    self.myRecordButton:setVisible(self.buttonIndex == 1)
    -- self.querenButton:setVisible(self.buttonIndex == 2)
    self.node_tuijian:setVisible(self.buttonIndex == 2)
    self.timeBg:setVisible(self.buttonIndex == 3)
    self.foundButton:setVisible(self.buttonIndex ~= 2);
    self.sskbg:setVisible(self.buttonIndex ~= 2);
    self.edit:setVisible(self.buttonIndex ~= 2);
    if self.buttonIndex ~= 2 then
        if self.foundEdit == nil then
            local foundEdit,editbg = createEditBox(self.edit," 输入玩家ID",cc.EDITBOX_INPUT_MODE_PHONENUMBER,nil,nil,"newExtend/vip/detail/shurukuang.png")
            -- foundEdit:setMaxLength(7);
            
            self.foundEdit = foundEdit;
        end
    else
        if self.foundEdit then
            self.foundEdit:removeSelf()
            self.foundEdit = nil;
        end
    end
    if self.buttonIndex ~= 1 then
        self.vipTip:setVisible(false)
    end
    
end

function VipDetaislLayer:formatTime()
    -- luaPrint("+=============+++++++++++self.time="..self.time)
    local hour =string.format("%d",math.floor(self.SYtime/3600));
    local min = string.format("%d",math.floor((self.SYtime-3600*hour)/60));
    local sec = string.format("%d",math.floor(self.SYtime%60));
    
    if string.len(hour) < 2 then
        hour = "0"..hour;
    end

    if string.len(min) < 2 then
        min = "0"..min;
    end

    if string.len(sec) < 2 then
        sec = "0"..sec;
    end

    return  ""..hour..":"..min..":"..sec;
end

function VipDetaislLayer:startTimer(dt)
    self.SYtime = self.SYtime - dt;

    if self.SYtimeText then
        self.SYtimeText:setString(self:formatTime()); 
    end
    if self.SYtime <= 0 then
        self:stopAction(self.updateScheduler)
        self.updateScheduler = nil;
        self.imagetip:setVisible(true);
        self.querenButton:setEnabled(true)
        self.SYtimeText:setVisible(false)
    end
end

function VipDetaislLayer:onClickShuzi(sender)
    local tag = sender:getTag();
    if string.len(self.RoomID) < 11 then
        self.RoomID = self.RoomID..tag;
    else
        return;
    end
    if string.len(self.RoomID) >= 11 then
        self.AtlasLabel_id11:setString(tag)
        -- VipInfo:sendGetGuildInfo(self.RoomID)
    else
        local index = string.len(self.RoomID);
        self["AtlasLabel_id"..index]:setString(tag)
    end 
end

function VipDetaislLayer:onClickBtn(sender)
    local tag = sender:getTag();
    if tag == 1 then
        self:removeSelf();
    elseif tag == 2 then
        local index = string.len(self.RoomID);
        if index > 0 then
            self["AtlasLabel_id"..index]:setString("")
            self.RoomID = string.sub(self.RoomID,1,string.len(self.RoomID)-1)
        end
    elseif tag == 3 then
        self.RoomID = ""
        for i=1,11 do
            self["AtlasLabel_id"..i]:setString("")
        end
    end
end

function VipDetaislLayer:IsSureApply(data)
    local prompt = GamePromptLayer:create();
    prompt:showPrompt("",true,true);
    prompt.btnCancel:loadTextures("newExtend/vip/common/chongxinshuru.png","newExtend/vip/common/chongxinshuru-on.png")
    prompt.btnOk:loadTextures("newExtend/vip/common/querenyaoqing.png","newExtend/vip/common/querenyaoqing-on.png")
    prompt.btnOk:setPositionY(prompt.btnOk:getPositionY()+20)
    prompt.btnCancel:setPositionY(prompt.btnCancel:getPositionY()+20)
    prompt:setBtnClickCallBack(function() 
        VipInfo:sendGuildCommend(self.data.GuildID,data.UserID)
    end,nil);
    self.prompt = prompt;

    local size = prompt:getContentSize();

    local infoBg = ccui.ImageView:create("desk/bg.png");
    infoBg:setPosition(size.width*0.5,size.height*0.6);
    prompt:addChild(infoBg);

    local head = ccui.ImageView:create("head/1.png")
    head:setPosition(infoBg:getContentSize().width*0.15,infoBg:getContentSize().height*0.5+5)
    infoBg:addChild(head)
    head:setScale(0.5);
    head:loadTexture(getHeadPath(data.LogoID));

    local nickimg = ccui.ImageView:create("desk/nicheng.png")
    nickimg:setPosition(infoBg:getContentSize().width*0.4,infoBg:getContentSize().height*0.7)
    infoBg:addChild(nickimg)

    local nickName = FontConfig.createWithSystemFont(data.NickName, 24,cc.c3b(250, 200, 3));
    nickName:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.7)
    infoBg:addChild(nickName)
    nickName:setAnchorPoint(0,0.5)

    local idimg = ccui.ImageView:create("desk/id.png")
    idimg:setPosition(infoBg:getContentSize().width*0.42,infoBg:getContentSize().height*0.3)
    infoBg:addChild(idimg)

    local idstr = FontConfig.createWithSystemFont(data.UserID, 24,cc.c3b(250, 200, 3));
    idstr:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.3)
    infoBg:addChild(idstr)
    idstr:setAnchorPoint(0,0.5)
end

return VipDetaislLayer
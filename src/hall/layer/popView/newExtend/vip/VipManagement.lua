local VipManagement = class("VipManagement", PopLayer)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function VipManagement:create(data,layer)
	return VipManagement.new(data,layer)
end

function VipManagement:ctor(data,layer)
	
	self.super.ctor(self,PopType.none)

    self.Tingdata = data; --收到的数据
    self.layer = layer;

	self:initData()

	self:initUI()

    VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)

    self:bindEvent()
end

function VipManagement:bindEvent()
    self:pushEventInfo(VipInfo,"getGuildUser",handler(self, self.receiveGetGuildUser))
    self:pushEventInfo(VipInfo,"agreeJoinInfo",handler(self, self.receiveAgreeJoinInfo))
    self:pushEventInfo(VipInfo,"rejectJoinInfo",handler(self, self.receiveRejectJoinInfo))
    self:pushEventInfo(VipInfo,"kickGuildUser",handler(self, self.receiveKickGuildUser))
    self:pushEventInfo(VipInfo,"deleteGuildInfo",handler(self, self.receiveDeleteGuildInfo))
    
    self:pushEventInfo(VipInfo,"guildTaxDetail",handler(self, self.receiveGuildTaxDetail))
    self:pushEventInfo(VipInfo,"guildMemberDetail",handler(self, self.receiveGuildMemberDetail))
    self:pushEventInfo(VipInfo,"guildRecordReq",handler(self, self.receiveGuildRecordReq))
    self:pushEventInfo(VipInfo,"getCallTime",handler(self, self.receiveGetCallTime))
    self:pushEventInfo(VipInfo,"guildOneKeyCall",handler(self, self.receiveGuildOneKeyCall))

    --股东
    self:pushEventInfo(VipInfo,"guildHolderReq",handler(self, self.receiveGuildHolderReq))
    self:pushEventInfo(VipInfo,"guildHolderSet",handler(self, self.receiveGuildHolderSet))
    self:pushEventInfo(VipInfo,"guildCommendDetail",handler(self, self.receiveGuildCommendDetail))


end

function VipManagement:receiveGetGuildUser(data)
    local data = data._usedata;
    local code = data[2]
    
    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            if v.IsPass == 1 then
                table.insert(self.userList,v)
            else
                table.insert(self.AuserList,v)
            end
        end 
    end
    if self.buttonIndex == 1 or self.buttonIndex == 2 then
        self.isFound = false
    end
        
    if code== 1 then--
        self:sortGuildUser()--厅主排序，第一位
        self.data[1] = self.userList;
        self.data[2] = self.AuserList;
        self:receiveData()
        self.userList = {} --厅成员
        self.AuserList = {} --待审核成员
    end
end

function VipManagement:sortGuildUser()
    local guser = nil
    for k,v in pairs(self.userList) do
        if v.UserID == self.Tingdata.OwnerID then
            guser = v;
            table.remove(self.userList,k)
        end
    end
    if guser then
        table.insert(self.userList,1,guser)
    end
end

function VipManagement:receiveGuildTaxDetail(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.TaxDetailList,v)
        end
    end
    local str = ""    
    if code== 1 then--
        if #self.TaxDetailList == 0 then
            str =  "没有记录"
        end
        self.data[3] = self.TaxDetailList;
        self:receiveData()
        self.TaxDetailList = {}
    elseif code== 2 then--
        -- addScrollMessage("厅信息错误")
        str =  "厅信息错误"
        self.data[3] = self.TaxDetailList;
        self:receiveData()
        self.TaxDetailList = {}
    elseif code== 3 then--
        -- addScrollMessage("没有记录")
        str =  "没有记录"
        self.data[3] = self.TaxDetailList;
        self:receiveData()
        self.TaxDetailList = {}
    end
    if str~= "" and self.buttonIndex == 3 then
        addScrollMessage(str)
    end
end

function VipManagement:receiveGuildMemberDetail(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.MemberDetailList,v)
        end
    end
    local str = ""
    if code== 1 then--
        if #self.MemberDetailList == 0 then
            str =  "没有记录"
        end
        self.data[5] = self.MemberDetailList;
        self:isFounddata()
        self:receiveData()
        self.MemberDetailList = {}
    elseif code== 2 then--
        -- addScrollMessage("厅信息错误")
        str =  "厅信息错误"
        self.data[5] = self.MemberDetailList;
        self:receiveData()
        self.MemberDetailList = {}
    elseif code== 3 then--
        -- addScrollMessage("没有记录")
        str =  "没有记录"
        self.data[5] = self.MemberDetailList;
        self:receiveData()
        self.MemberDetailList = {}
    end
    if str~= "" and self.buttonIndex == 5 then
        addScrollMessage(str)
    end
end

function VipManagement:isFounddata()
    local newdata = {}
    local str = ""
    if self.foundEdit then
        str = self.foundEdit:getText();
    end
    local num = tonumber(str)
    if #self.data[5] > 0 then
        if num then
            for k,v in pairs(self.data[5]) do
                if v.UserID == num then
                    table.insert(newdata,v)
                end
            end

            if #newdata > 0 then
                self.data[5] = newdata;
            else
                self.data[5] = {}
                addScrollMessage("没有记录")
            end
        end
        
    end
end

function VipManagement:receiveGuildRecordReq(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.recodeReqList,v)
        end
    end

    if code== 1 then--
        if #self.recodeReqList == 0 then
            addScrollMessage("没有记录");
        end
        self.data[4] = self.recodeReqList;
        self:receiveData()
        self.recodeReqList = {}
        -- luaDump(self.data,"receiveGuildRecordReqself.data")
    elseif code== 2 then
        addScrollMessage("ID不存在")
        self.data[4] = self.recodeReqList;
        self:receiveData()
        self.recodeReqList = {}
    elseif code== 3 then
        addScrollMessage("没有记录")
        self.data[4] = self.recodeReqList;
        self:receiveData()
        self.recodeReqList = {}
    end
end

function VipManagement:receiveGetCallTime(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 then--
        local time = data[1].iLeftTime;
        if time == 0 then
            self.imagetip:setVisible(true);
            self.zhaojiButton:setEnabled(true)
            self.SYtimeText:setVisible(false)
        else
            self.imagetip:setVisible(false);
            self.zhaojiButton:setEnabled(false)
            self.SYtimeText:setVisible(true)
            self.SYtime = time;
            if self.updateScheduler then
                self:stopAction(self.updateScheduler)
                self.updateScheduler = nil;
            end
            self.updateScheduler = schedule(self, function() self:startTimer(1.0) end, 1.0)
        end
        
    end
end

function VipManagement:receiveGuildOneKeyCall(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 then--
        local time = data[1].iLeftTime;
        if time == 0 then
            self.imagetip:setVisible(true);
            self.zhaojiButton:setEnabled(true)
            self.SYtimeText:setVisible(false)
        else
            self.imagetip:setVisible(false);
            self.zhaojiButton:setEnabled(false)
            self.SYtimeText:setVisible(true)
            self.SYtime = time;
            if self.updateScheduler then
                self:stopAction(self.updateScheduler)
                self.updateScheduler = nil;
            end
            self.updateScheduler = schedule(self, function() self:startTimer(1.0) end, 1.0)
        end
        
    end
end

function VipManagement:receiveGuildHolderReq(data)
    local data = data._usedata;

    if display.getRunningScene():getChildByName("VipgudongSetLayer") then
        return;
    end

    local layer = require("hall.layer.popView.newExtend.vip.VipgudongSetLayer"):create(data,self.Tingdata.GuildID,self.gudongID)
    display.getRunningScene():addChild(layer)
    layer:setName("VipgudongSetLayer")
    -- layer:setUserNodeInfoCallback(function (NoteName,NotePhone)
    --     self:setUserNodeInfo(NoteName,NotePhone,index)
    -- end)

end

function VipManagement:receiveGuildHolderSet(data)
    local data = data._usedata;
    local code = data[2]
    if code== 0 then
        local layer = display.getRunningScene():getChildByName("VipgudongSetLayer");
        if layer then
            layer:updataLayer(data[1])
        end
        VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
    elseif code== 2 then
        addScrollMessage("税率非法")
    elseif code== 4 then
        addScrollMessage("推荐超过3人不能撤销")
    end
end

function VipManagement:receiveGuildCommendDetail(data)
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
        self.data[6] = self.tuijianList;
        self:receiveData()
        self.tuijianList = {}
        -- luaDump(self.data,"receiveGuildRecordReqself.data")
    elseif code== 2 then
        addScrollMessage("没有记录")
        self.data[6] = self.tuijianList;
        self:receiveData()
        self.tuijianList = {}
    end
end


function VipManagement:formatTime()
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

function VipManagement:startTimer(dt)
    self.SYtime = self.SYtime - dt;

    if self.SYtimeText then
        self.SYtimeText:setString(self:formatTime()); 
    end
    if self.SYtime <= 0 then
        self:stopAction(self.updateScheduler)
        self.updateScheduler = nil;
        self.imagetip:setVisible(true);
        self.zhaojiButton:setEnabled(true)
        self.SYtimeText:setVisible(false)
    end
end

--//通过申请
function VipManagement:receiveAgreeJoinInfo(data)
    local data = data._usedata;
    local code = data[1]
    if code == 0 then
        self.userList = {} --厅成员
        self.AuserList = {} --待审核成员
        VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
    end

end

--//拒绝申请
function VipManagement:receiveRejectJoinInfo(data)
    local data = data._usedata;
    local code = data[1]
    if code == 0 then
        self.userList = {} --厅成员
        self.AuserList = {} --待审核成员
        VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
    end
end

--//厅主踢人
function VipManagement:receiveKickGuildUser(data)
    local data = data._usedata;
    local code = data[1]
    if code == 0 then
        self.userList = {} --厅成员
        self.AuserList = {} --待审核成员
        VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
    end
end

--厅主解散厅
function VipManagement:receiveDeleteGuildInfo(data)
    local data = data._usedata;
    local code = data[1]

    if code== 0 then--
       addScrollMessage("解散成功")
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

function VipManagement:initData()
    self.data = {{},{},{},{},{},{}};

    self.userList = {} --厅成员
    self.AuserList = {} --待审核成员
    self.TaxDetailList = {} --税收详情
    self.MemberDetailList = {} --成员详情
    self.recodeReqList = {} --成员战绩
    self.tuijianList = {} --推荐成员详情

    self.buttonIndex = 1;--默认第一个按钮
    
    self.time = os.time();--1553101200;

    self.Timet3 = os.time();--税收详情
    self.Timet4 = os.time();--成员详情
    self.Timet5 = os.time();--成员战绩
    self.Timet6 = os.time();--成员战绩

    self.dateT3 = 1;--税收详情 第几天 前一天+1，后一天-1
    self.dateT4 = 1;--成员详情 第几天
    self.dateT5 = 1;--成员战绩 第几天
    self.dateT6 = 1;--成员战绩 第几天

    self.RembenUserID = 0;--当前查询ID

    self.currentPage = 1;--当前页数

    self.pageNums = 1;--总页数

    self.changeData = {};--转化过的数据

    self.allShuiShouScore = 0;--当日全部税收

    self.isFound = false; --查询

    self.foundData = {};--查询结果数组
    self.gudongID = 0;
end

function VipManagement:receiveData()

    self.changeData = self:fiveAdjustData(self.data);
    luaDump(self.changeData,"self.changeData")
    self.pageNums = #self.changeData[4];

    self:updateData();

end

function VipManagement:foundResultData(dwUserID)
    if self.isFound == false then
        return;
    end

    if self.buttonIndex == 3 then
        return;
    end

    self.foundData = {{},{},{},{},{},{}};

    -- for k,v in pairs(self.data) do
        for i,msg in pairs(self.data[self.buttonIndex]) do
            if msg.UserID == dwUserID then
                table.insert(self.foundData[self.buttonIndex],msg);
            end
        end
    -- end

    -- luaDump(self.foundData,"self.foundData00");

    self.foundData = self:fiveAdjustData(self.foundData);

    self.pageNums = #self.foundData[4];

    self.currentPage = 1;

    -- luaDump(self.foundData,"self.foundData");
end

--对第五个数据进行处理
function VipManagement:fiveAdjustData(Data)
    local num = 5; -- 表示一页显示的个数
    local data = Data[4];
    local logData = {};
    if #data > 0 then
        for k,v in pairs(data) do
            if logData[math.floor((k-1)/num)+1]  == nil then
                logData[math.floor((k-1)/num)+1] = {};
            end
            table.insert(logData[math.floor((k-1)/num)+1],v);
        end
    end

    local changeData = clone(Data);
    -- luaDump(logData,"logData");
    changeData[4] = {}
    changeData[4] = clone(logData);
    
    -- luaDump(changeData,"changeData");

    return changeData;
end

function VipManagement:initUI()
    self:setName("VipManagement");
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

	local bttitle = ccui.ImageView:create("newExtend/vip/detail/viptingguanli.png");
	-- title:setAnchorPoint(0,1)
	bg:addChild(bttitle);
	bttitle:setPosition(430,self.size.height-35)

	local closeBtn = ccui.Button:create("newExtend/vip/common/fanhui.png","newExtend/vip/common/fanhui-on.png");
	closeBtn:setPosition(0,size.height-38);
    closeBtn:setAnchorPoint(cc.p(0,0.5))
	bg:addChild(closeBtn);
	closeBtn:onClick(function(sender) globalUnit.selectTingID = self.Tingdata.GuildID;VipInfo:sendGetVipInfo();self:removeSelf(); end)

	local di = ccui.ImageView:create("newExtend/vip/detail/di.png");
	di:setPosition(size.width*0.5+75,size.height*0.45-35);
	bg:addChild(di);
    self.di = di;

    --按钮背景
    self.layout = ccui.Layout:create();
    self.layout:setContentSize(cc.size(1200,80));
    -- self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- self.layout:setBackGroundColor(cc.c3b(255, 255, 0))
    bg:addChild(self.layout);
    self.layout:setPosition(cc.p(size.width*0.5-590,0));
    self.layout:setLocalZOrder(999);
    self.layout:setTouchEnabled(true)


    self.ButtonTable = {};
    local buttonStr1 = {"tingchengyuan1.png","daishenhe1.png","shuishouxiangqing1.png","chengyuanzhanji1.png","putongchengyuanxiangqing.png","tuijianchengyuanxiangqing.png"};
    local buttonStr2 = {"tingchengyuan1-on.png","daishenhe1-on.png","shuishouxiangqing1-on.png","chengyuanzhanji1-on.png","putongchengyuanxiangqing-on.png","tuijianchengyuanxiangqing-on.png"};
    local buttonStr3 = {"tingchengyuan2.png","daishenhe2.png","shuishouxiangqing2.png","chengyuanzhanji2.png","putongchengyuanxiangqing2.png","tuijianchengyuanxiangqing2.png"};
    for i=1,6 do
        local btn = ccui.Button:create("newExtend/vip/management/"..buttonStr1[i],"newExtend/vip/management/"..buttonStr2[i],"newExtend/vip/management/"..buttonStr3[i]);
        bg:addChild(btn);
        table.insert(self.ButtonTable,btn);
        btn:setPosition(size.width*0.5-540+(i-1)*150,605);
        btn:setTag(i);
        btn:onClick(function (sender)
            self:onClickButton(sender);
        end);
    end

    --解散vip
    self.jiesanVipButton = ccui.Button:create("newExtend/vip/management/jiesanvip.png","newExtend/vip/management/jiesanvip-on.png");
    self.layout:addChild(self.jiesanVipButton)
    self.jiesanVipButton:setPosition(self.layout:getContentSize().width*0.75,105);
    self.jiesanVipButton:setVisible(false);
    self.jiesanVipButton:setTag(1);
    self.jiesanVipButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    --一键召集
    self.zhaojiButton = ccui.Button:create("newExtend/vip/management/anniu.png","newExtend/vip/management/anniu-on.png","newExtend/vip/management/anniu-b.png");
    self.layout:addChild(self.zhaojiButton)
    self.zhaojiButton:setPosition(self.layout:getContentSize().width*0.25,105);
    self.zhaojiButton:setVisible(false);
    self.zhaojiButton:setEnabled(false)
    self.zhaojiButton:setTag(8);
    self.zhaojiButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end,1);
    local btnSize = self.zhaojiButton:getContentSize()

    local imagetip = ccui.ImageView:create("newExtend/vip/management/yijianzhaoji.png");
    imagetip:setPosition(btnSize.width/2,btnSize.height*0.5);
    self.zhaojiButton:addChild(imagetip);
    self.imagetip = imagetip;

    local time = FontConfig.createWithCharMap("", "newExtend/vip/management/zitiao.png", 20, 26, "0");
    time:setPosition(btnSize.width*0.5,btnSize.height*0.55)
    self.zhaojiButton:addChild(time)
    time:setVisible(false)
    self.SYtimeText = time;

    --全部拒绝
    self.refuseVipButton = ccui.Button:create("newExtend/vip/management/quanbujujue.png","newExtend/vip/management/quanbujujue-on.png");
    self.layout:addChild(self.refuseVipButton)
    self.refuseVipButton:setPosition(self.layout:getContentSize().width*0.5-250,105);
    self.refuseVipButton:setVisible(false);
    self.refuseVipButton:setTag(2);
    self.refuseVipButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    --全部同意
    self.agreeVipButton = ccui.Button:create("newExtend/vip/management/quanbutongyi.png","newExtend/vip/management/quanbutongyi-on.png");
    self.layout:addChild(self.agreeVipButton)
    self.agreeVipButton:setPosition(self.layout:getContentSize().width*0.5+250,105);
    self.agreeVipButton:setVisible(false);
    self.agreeVipButton:setTag(3);
    self.agreeVipButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    self.timeBg = ccui.ImageView:create("newExtend/vip/detail/riqixuanze.png");
    self.timeBg:setPosition(self.layout:getContentSize().width*0.5,105);
    self.layout:addChild(self.timeBg);
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

    --上一页下一页
    self.lastPageButton = ccui.Button:create("newExtend/vip/detail/shangyiye.png","newExtend/vip/detail/shangyiye.png");
    self.layout:addChild(self.lastPageButton);
    self.lastPageButton:setPosition(80,105);
    self.lastPageButton:setVisible(false);
    self.lastPageButton:setTag(6);
    self.lastPageButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    self.nextPageButton = ccui.Button:create("newExtend/vip/detail/xiayiye.png","newExtend/vip/detail/xiayiye.png");
    self.layout:addChild(self.nextPageButton);
    self.nextPageButton:setPosition(320,105);
    self.nextPageButton:setVisible(false);
    self.nextPageButton:setTag(7);
    self.nextPageButton:onClick(function (sender)
        self:buttonCallBack(sender);
    end);

    self.pageText = FontConfig.createWithSystemFont("1/2", 24,cc.c3b(255, 255, 255));
    self.pageText:setPosition(195,105);
    self.layout:addChild(self.pageText);
    self.pageText:setVisible(false);

    self.tishiyu = ccui.ImageView:create("newExtend/vip/detail/zuiduochakan.png");
    self.tishiyu:setPosition(self.layout:getContentSize().width*0.85,40);
    self.layout:addChild(self.tishiyu);
    self.tishiyu:setVisible(false);

    --设置按钮
    local setButton = ccui.Button:create("newExtend/vip/management/shezhi.png","newExtend/vip/management/shezhi-on.png");
    setButton:setPosition(size.width-100,size.height-30);
    bg:addChild(setButton);
    setButton:onClick(function(sender) luaPrint("设置按钮"); end)
    setButton:setVisible(false)

    self.shuishouImage = ccui.ImageView:create("newExtend/vip/management/dangrihuode.png");
    self.shuishouImage:setAnchorPoint(0,0.5);
    self.shuishouImage:setPosition(size.width*0.5+290,612);
    bg:addChild(self.shuishouImage);
    self.shuishouImage:setVisible(false);

    local TJuseName = FontConfig.createWithSystemFont("当日共获得税收:", 22,cc.c3b(249, 230, 121));
    self.shuishouImage:addChild(TJuseName);
    TJuseName:setAnchorPoint(0,0.5);
    TJuseName:setPosition(50,22);

    --帮助按钮
    self.helpButton = ccui.Button:create("newExtend/vip/management/bangzhu.png","newExtend/vip/management/bangzhu-on.png");
    self.helpButton:setPosition(size.width*0.5+315,612);
    bg:addChild(self.helpButton)
    self.helpButton:setVisible(false);
    self.helpButton:onClick(function ()
        luaPrint("帮助按钮",self.ssTishiyu:isVisible());
        if self.ssTishiyu then
            self.ssTishiyu:setVisible(not self.ssTishiyu:isVisible())
        end
    end);

    

    self.ssTishiyu = ccui.ImageView:create("newExtend/vip/management/shuishouts.png");
    self.ssTishiyu:setPosition(size.width*0.5+315,680);
    bg:addChild(self.ssTishiyu);
    self.ssTishiyu:setVisible(false);

    --税收金币
    self.ssText = FontConfig.createWithSystemFont(goldConvert(self.allShuiShouScore,1), 24,cc.c3b(255, 234, 49));
    self.ssText:setAnchorPoint(0,0.5)
    self.ssText:setPosition(size.width*0.5+515,610);
    bg:addChild(self.ssText);
    self.ssText:setVisible(false);

    local sskbg =  ccui.ImageView:create("newExtend/vip/common/sskuangbg.png");
    self.bg:addChild(sskbg);
    sskbg:setPosition(size.width*0.5+450,610);
    self.sskbg = sskbg;

	self.edit = cc.Node:create();--ccui.ImageView:create("newExtend/vip/detail/shurukuang.png")
	self.edit:setPosition(cc.p(size.width*0.5+280,610));
	bg:addChild(self.edit);
	
	-- local foundEdit = ccui.EditBox:create(self.edit:getContentSize(),ccui.Scale9Sprite:create())
    local foundEdit,editbg = createEditBox(self.edit," 输入玩家ID",cc.EDITBOX_INPUT_MODE_PHONENUMBER,nil,nil,"newExtend/vip/common/shurukuang.png")
    -- foundEdit:setMaxLength(7);
    
    self.foundEdit = foundEdit;
    -- foundEdit:setAnchorPoint(cc.p(0.5,0.5))
    -- foundEdit:setPosition(cc.p(self.edit:getContentSize().width*0.5,self.edit:getContentSize().height*0.5))
    -- foundEdit:setFontSize(28)
    -- foundEdit:setPlaceHolder("  输入玩家ID")
    -- foundEdit:setPlaceholderFontColor(cc.c3b(216,226,233))
    -- foundEdit:setPlaceholderFontSize(20)
    -- foundEdit:setMaxLength(20)
    -- self.edit:addChild(foundEdit)
    
    -- foundEdit:setInputFlag(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    -- foundEdit:setMaxLength(6);
    -- foundEdit:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end);

    local foundButton = ccui.Button:create("newExtend/vip/detail/sousuo.png","newExtend/vip/detail/sousuo-on.png");
    foundButton:setPosition(cc.p(size.width*0.5+580,613))
    bg:addChild(foundButton);
    self.foundButton = foundButton;
    foundButton:onClick(function ()
    	self:foundPlay();
    end);

    

    self.foundTishi = ccui.ImageView:create("newExtend/vip/management/foundtishi.png");
    self.bg:addChild(self.foundTishi);
    self.foundTishi:setPosition(size.width*0.5,size.height*0.5);
    self.foundTishi:setVisible(false);

    self.tipLabel = FontConfig.createWithSystemFont("税收每日24点结算,发放至余额宝。", 24);
    self.tipLabel:setPosition(size.width-200,30);
    bg:addChild(self.tipLabel);
    self.tipLabel:setName("tipLabel");
    self.tipLabel:setVisible(false);
    
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

	-- self:createTableView();

 --    self:updataTiao();

    


end

function VipManagement:buttonCallBack(sender)
    local tag = sender:getTag()
    if tag == 1 then--解散vip
        luaPrint("解散vip");
        
        local prompt = GamePromptLayer:create();
        prompt:showPrompt(GBKToUtf8("确认解散vip厅?"));
        prompt:setBtnVisible(true,true)
        prompt:setBtnClickCallBack(function() 
           VipInfo:sendJiesanGuild(self.Tingdata.GuildID)
        end);
    elseif tag == 2 then--全部拒绝
        luaPrint("全部拒绝");
        VipInfo:sendRejectGuildJoinInfo(self.Tingdata.GuildID,0,1)
    elseif tag == 3 then--全部同意
        luaPrint("全部同意");
        VipInfo:sendAgreeGuildJoinInfo(self.Tingdata.GuildID,0,1)
    elseif tag == 4 then--前一天
        luaPrint("前一天");

        self["dateT"..self.buttonIndex] = self["dateT"..self.buttonIndex] +1
        if self["dateT"..self.buttonIndex] >7 then
            self["dateT"..self.buttonIndex] = 7;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            if self.buttonIndex == 3 then
                VipInfo:sendGuildTaxDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 5 then
                VipInfo:sendGuildMemberDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 4 then
                VipInfo:sendGuildRecordReq(self.RembenUserID,self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 6 then
                VipInfo:sendGuildCommendDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            end
            self["Timet"..self.buttonIndex] = self["Timet"..self.buttonIndex] - 24*60*60;
        end
        self.currentPage = 1;
        self.isFound = false
        -- self.time = self.time - 24*60*60;
        -- self:receiveData()
    elseif tag == 5 then--下一天
        luaPrint("下一天");
        self["dateT"..self.buttonIndex] = self["dateT"..self.buttonIndex] -1
        if self["dateT"..self.buttonIndex] <1 then
            self["dateT"..self.buttonIndex] = 1;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            if self.buttonIndex == 3 then
                VipInfo:sendGuildTaxDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 5 then
                VipInfo:sendGuildMemberDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 4 then
                VipInfo:sendGuildRecordReq(self.RembenUserID,self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            elseif self.buttonIndex == 6 then
                VipInfo:sendGuildCommendDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
            end
            self["Timet"..self.buttonIndex] = self["Timet"..self.buttonIndex] + 24*60*60;
        end
        self.currentPage = 1;
        self.isFound = false
        -- self.time = self.time + 24*60*60;
        -- self:receiveData()
    elseif tag == 6 then--上一页
        luaPrint("上一页");
        self.currentPage = self.currentPage-1
        if self.currentPage <=1 then
            self.currentPage = 1;
        end
        self:updateData()
    elseif tag == 7 then--下一页
        luaPrint("下一页");
        self.currentPage = self.currentPage+1
        if self.currentPage > self.pageNums then
            self.currentPage = self.pageNums;
        end
        self:updateData()
    elseif tag == 8 then--一键召集
        VipInfo:sendGuildOneKeyCall(self.Tingdata.GuildID)
    end
end

function VipManagement:updateData()
    -- if self.rankTableView then
    --     self.rankTableView:reloadData();
    -- else
        self:createTableView();
    -- end
    self:updataTiao();
    if self.pageNums == 0 then
        self.pageNums = 1;
    end
    self.pageText:setString(self.currentPage.."/"..self.pageNums);

    self.timeText3:setString(timeConvert(self["Timet"..self.buttonIndex],1));

    if self.buttonIndex == 3 then
        self.allShuiShouScore = 0;
        for k,v in pairs(self.data[3]) do
            self.allShuiShouScore = self.allShuiShouScore + v.lTaxGet;
        end
        self.ssText:setString(goldConvert(self.allShuiShouScore,1))
    end
end

--按钮显示控制
function VipManagement:updataBtn()
    self.jiesanVipButton:setVisible(self.buttonIndex == 1)
    self.zhaojiButton:setVisible(self.buttonIndex == 1)
    self.refuseVipButton:setVisible(self.buttonIndex == 2)
    self.agreeVipButton:setVisible(self.buttonIndex == 2)
    self.timeBg:setVisible(self.buttonIndex == 3 or self.buttonIndex == 4 or self.buttonIndex == 5 or self.buttonIndex == 6)
    self.lastPageButton:setVisible(self.buttonIndex == 4)
    self.nextPageButton:setVisible(self.buttonIndex == 4)
    self.pageText:setVisible(self.buttonIndex == 4)
    self.tishiyu:setVisible(self.buttonIndex == 4)
    self.helpButton:setVisible(self.buttonIndex == 3);
    self.shuishouImage:setVisible(self.buttonIndex == 3);
    self.tipLabel:setVisible(self.buttonIndex == 3);
    self.ssText:setVisible(self.buttonIndex == 3);
    self.edit:setVisible(self.buttonIndex ~= 3);
    self.sskbg:setVisible(self.buttonIndex ~= 3);
    -- if self.foundEdit:isVisible() ~= (self.buttonIndex ~= 3) then
    --     self.foundEdit:setVisible(self.buttonIndex ~= 3);
    -- end
    if self.buttonIndex ~= 3 then
        if self.foundEdit == nil then
            local foundEdit,editbg = createEditBox(self.edit," 输入玩家ID",cc.EDITBOX_INPUT_MODE_PHONENUMBER,nil,nil,"newExtend/vip/common/shurukuang.png")
            -- foundEdit:setMaxLength(7);
            
            self.foundEdit = foundEdit;
        end
    else
        if self.foundEdit then
            self.foundEdit:removeSelf()
            self.foundEdit = nil;
        end
    end

    self.foundButton:setVisible(self.buttonIndex ~= 3);
    self.ssTishiyu:setVisible(false);

    self.foundTishi:setVisible(self.buttonIndex == 4);
    if self.buttonIndex == 4 then
        self.foundTishi:setVisible(not(#self.data[self.buttonIndex] ~= 0));
        self.lastPageButton:setVisible(#self.data[self.buttonIndex] ~= 0 or self.RembenUserID ~= 0);
        self.nextPageButton:setVisible(#self.data[self.buttonIndex] ~= 0 or self.RembenUserID ~= 0)
        self.pageText:setVisible(#self.data[self.buttonIndex] ~= 0 or self.RembenUserID ~= 0)
        self.timeBg:setVisible(#self.data[self.buttonIndex] ~= 0 or self.RembenUserID ~= 0);
    end
    
    if self.buttonIndex ~= 1 then
        self.vipTip:setVisible(false)
    end
end


--条文字更新
function VipManagement:updataTiao()
    self:updataBtn();
    luaPrint("updataTiao",self.buttonIndex);
    if self.buttonIndex == 3 or self.buttonIndex == 4 or self.buttonIndex == 5 or self.buttonIndex == 6 then
        local node = self.di:getChildByName("biaotilan");
        if node then
            node:removeFromParent();
        end
        local biaotilan = ccui.ImageView:create("newExtend/vip/detail/biaotilan.png");
        biaotilan:setPosition(self.di:getContentSize().width/2-80,self.di:getContentSize().height*0.92+5);
        self.di:addChild(biaotilan)
        biaotilan:setName("biaotilan");

        if self.buttonIndex == 3 then--税收详情
            local strTable = {"youximingchen.png","shijijushu.png","chanshengshuishou.png","huodeshuishou.png"};
            local bit = {0.1,0.3,0.6,0.9};
            for i=1,#strTable do
                local sprite = ccui.ImageView:create("newExtend/vip/management/"..strTable[i]);
                sprite:setPosition(biaotilan:getContentSize().width*bit[i]+10,biaotilan:getContentSize().height*0.5);
                biaotilan:addChild(sprite);
            end
        elseif self.buttonIndex == 5 then--成员详情
            local strTable = {"chengyuanxinxi.png","shijijushu.png","chanshengshuishou.png","huodeshuishou.png"};
            local bit = {0.1,0.3,0.6,0.9};
            for i=1,#strTable do
                local sprite = ccui.ImageView:create("newExtend/vip/management/"..strTable[i]);
                sprite:setPosition(biaotilan:getContentSize().width*bit[i]+10,biaotilan:getContentSize().height*0.5);
                biaotilan:addChild(sprite);
            end
        elseif self.buttonIndex == 4 then--普通成员战绩
            local strTable = {"jiesushijian.png","youxifangjian.png","shuyingqingkuang.png"};
            local bit = {0.2,0.5,0.8};
            for i=1,#strTable do
                local sprite = ccui.ImageView:create("newExtend/vip/management/"..strTable[i]);
                sprite:setPosition(biaotilan:getContentSize().width*bit[i]+10,biaotilan:getContentSize().height*0.5);
                biaotilan:addChild(sprite);
            end
        elseif self.buttonIndex == 6 then--推荐成员详情
            local strTable = {"chengyuanxinxi.png","tuijianren.png","chanshengshuishou.png","huodeshuishou.png"};
            local bit = {0.1,0.32,0.6,0.9};
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


function VipManagement:onClickButton(sender)
    local tag = sender:getTag();
    luaPrint("onClickButton",tag);
    self.buttonIndex = tag;
    if  self.buttonIndex == 1 then
        VipInfo:sendGuildSendMoneyReq();
    elseif  self.buttonIndex == 2 then
        VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
    elseif  self.buttonIndex == 3 then
        VipInfo:sendGuildTaxDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
    elseif  self.buttonIndex == 4 then
        -- VipInfo:sendGuildMemberDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
        self:updateData();
    elseif self.buttonIndex == 5 then
        -- self:updateData();
        VipInfo:sendGuildMemberDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
    elseif self.buttonIndex == 6 then
        VipInfo:sendGuildCommendDetail(self.Tingdata.GuildID,self["dateT"..self.buttonIndex])
    end
    
    
    self.isFound = false;
    for k,v in pairs(self.ButtonTable) do
        self.ButtonTable[k]:setEnabled(k~=tag)
    end

    self:updataTiao();

    self:updateTableView();

    if self.buttonIndex == 3 then
        self.allShuiShouScore = 0;
        for k,v in pairs(self.data[3]) do
            self.allShuiShouScore = self.allShuiShouScore + v.lTaxGet;
        end
        self.ssText:setString(goldConvert(self.allShuiShouScore,1))
    end

end

--刷新tableview
function VipManagement:updateTableView()

    self:createTableView();

end

function VipManagement:foundPlay()
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

    luaPrint("查询玩家");

    self.isFound = true;

    if self.buttonIndex == 4 then
        self.RembenUserID = tonumber(str);
        VipInfo:sendGuildRecordReq(self.RembenUserID,self.Tingdata.GuildID,1)
        self.Timet4 = os.time();--成员战绩
        self.dateT4 = 1;--成员战绩 第几天
        self.currentPage = 1;
        return;
    end

    self:foundResultData(tonumber(str));--查询

    self:updateData();

end

function VipManagement:editboxHandle(strEventName,sender)
	local tag = sender:getTag();
	luaPrint("editboxHandle",tag,strEventName);
	if strEventName == "began" then
		luaPrint("began");
	elseif strEventName == "ended" then
		luaPrint("began");
	elseif strEventName == "return" then
		
		-- local str = sender:getText();
		-- luaPrint("return",str);
	elseif strEventName == "changed" then
		luaPrint("changed");
	end
end

function VipManagement:hideTableView(isTrue)
    if  isTrue then
        self.foundTishi:setVisible(true);
        self.lastPageButton:setVisible(false);
        self.nextPageButton:setVisible(false)
        self.pageText:setVisible(false)
        self.timeBg:setVisible(false);
    else
        self.foundTishi:setVisible(false);
        self.lastPageButton:setVisible(true);
        self.nextPageButton:setVisible(true)
        self.pageText:setVisible(true)
        self.timeBg:setVisible(true);
    end
end

--创建tableview
function VipManagement:createTableView()
    if self.buttonIndex == nil then
        luaPrint("按钮下标错误！");
        return
    end

	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end

    local dis = 0;
    if self.buttonIndex == 3 or self.buttonIndex == 4 or self.buttonIndex == 5 or self.buttonIndex == 6 then
        dis = 0;
    end

    luaPrint("self.buttonIndex",self.buttonIndex,#self.data[5]);
    if self.buttonIndex == 5 and #self.data[5] == 0 then
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
        self.rankTableView:setLocalZOrder(100);
    end
end

function VipManagement:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function VipManagement:Rank_cellSizeForTable(view, idx) 

    if self.buttonIndex == 1 or self.buttonIndex == 2 or self.buttonIndex == 5 or self.buttonIndex == 6 then
       return 1210, 100; 
    else
        return 1210, 75; 
    end
end  
  
function VipManagement:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
   local data = self.changeData;
   if self.isFound and self.buttonIndex ~= 4 then
       data = self.foundData 
   end
   local num = 0;
   if self.buttonIndex == 4 then
        if #data[self.buttonIndex] > 0 then
            num = #data[self.buttonIndex][self.currentPage];
        end
   else
        if #data >= self.buttonIndex and #data[self.buttonIndex] > 0 then
            num = #data[self.buttonIndex];
        end
   end
    return num;
end  
  
function VipManagement:Rank_tableCellAtIndex(view, idx)  
    luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(index); 
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

function VipManagement:setRankInfo(rankItem,index)
    luaPrint("TableLayer:setRankInfo--------",self.buttonIndex,index,self.isFound)
    local data = self.changeData;
    if self.isFound and self.buttonIndex ~= 4 then
       data = self.foundData 
    end
    -- luaDump(data[self.buttonIndex][index],"111111111")
    if self.buttonIndex == 1 or self.buttonIndex == 2 or self.buttonIndex == 5 or self.buttonIndex == 6 then
        local headImage = rankItem:getChildByName("headImage");--头像
        local useName = rankItem:getChildByName("useName"); --名字
        local useId = rankItem:getChildByName("useId");--useId
        headImage:loadTexture(getHeadPath(data[self.buttonIndex][index].iLogoID));--logoId
        useName:setString(FormotGameNickName(data[self.buttonIndex][index].NickName,nickNameLen));
        useId:setString("ID:"..data[self.buttonIndex][index].UserID);
    end

    if self.buttonIndex == 1 then
        local time = rankItem:getChildByName("time");--time
        local useScore = rankItem:getChildByName("useScore");
        local tingzhu = rankItem:getChildByName("tingzhu");
        local delateButton = rankItem:getChildByName("delateButton");
        local beizhuButton = rankItem:getChildByName("beizhuButton");
        local gudongButton = rankItem:getChildByName("gudongButton");
        local gudong = rankItem:getChildByName("gudong");

        local string = self:split(timeConvert(data[self.buttonIndex][index].iPassTime,3));
        time:setString(string[1].."\n"..string[2]);
        luaPrint("-----",data[self.buttonIndex][index].score);
        useScore:setString(goldConvert(data[self.buttonIndex][index].WalletMoney,1));
        -- { nickName = "常山赵子龙", dwUserID = 265895,time = 265895, score = math.random(-100000,100000),},
        if data[self.buttonIndex][index].UserID == self.Tingdata.OwnerID then
            tingzhu:setVisible(true)
            delateButton:setVisible(false)
            gudongButton:setVisible(false)
            beizhuButton:setVisible(false)
        else
            tingzhu:setVisible(false)
            delateButton:setVisible(true)
            gudongButton:setVisible(true)
            beizhuButton:setVisible(true)

            delateButton:onClick(function ()
                if data[self.buttonIndex][index].MemberType == 2 then
                    addScrollMessage("股东不可被踢出厅，需先撤销股东")
                    return;
                end
            luaPrint("删除按钮",index);
            
            local prompt = GamePromptLayer:create();
            prompt:showPrompt(GBKToUtf8("确认删除该成员?"));
            prompt:setBtnVisible(true,true)
            prompt:setBtnClickCallBack(function() 
               VipInfo:sendKickGuildUser(self.Tingdata.GuildID,data[self.buttonIndex][index].UserID)
                end);
            end)
        end
        if data[self.buttonIndex][index].MemberType == 2 then
            gudong:setVisible(true)
        else
            gudong:setVisible(false)
        end
        
        beizhuButton:onClick(function ()
            luaPrint("备注按钮",index);
           local layer = require("hall.layer.popView.newExtend.vip.VipUserInfoLayer"):create(data[self.buttonIndex][index],self.Tingdata.GuildID)
            display.getRunningScene():addChild(layer)
            layer:setUserNodeInfoCallback(function (NoteName,NotePhone)
                self:setUserNodeInfo(NoteName,NotePhone,index)
            end)
        end)
        
        gudongButton:onClick(function ()
            luaPrint("股东设置按钮",index);
            VipInfo:sendGuildHolderReq(self.Tingdata.GuildID,data[self.buttonIndex][index].UserID)
            self.gudongID = data[self.buttonIndex][index].UserID;
           -- local layer = require("hall.layer.popView.newExtend.vip.VipgudongSetLayer"):create(data[self.buttonIndex][index],self.Tingdata.GuildID)
           --  display.getRunningScene():addChild(layer)
            -- layer:setUserNodeInfoCallback(function (NoteName,NotePhone)
            --     self:setUserNodeInfo(NoteName,NotePhone,index)
            -- end)
        end)
    elseif self.buttonIndex == 2 then
        local time = rankItem:getChildByName("time");--time
        local noButton = rankItem:getChildByName("noButton");
        local acceptButton = rankItem:getChildByName("acceptButton");

        local string = self:split(timeConvert(data[self.buttonIndex][index].iApplyTime,3));
        time:setString(string[1].."\n"..string[2]);

        noButton:onClick(function ()
            luaPrint("拒绝按钮",index);
            VipInfo:sendRejectGuildJoinInfo(self.Tingdata.GuildID,data[2][index].UserID,0)
        end)
        acceptButton:onClick(function ()
            luaPrint("同意按钮",index);
            VipInfo:sendAgreeGuildJoinInfo(self.Tingdata.GuildID,data[2][index].UserID,0)
        end)
    elseif self.buttonIndex == 3 or self.buttonIndex == 5 or self.buttonIndex == 6 then
        if self.buttonIndex == 3 then
            local gameName = rankItem:getChildByName("gameName");
            gameName:setString(VipRoomInfoModule:getGameNameByNameID(data[self.buttonIndex][index].iGameId));
        end
        if self.buttonIndex == 3 or  self.buttonIndex == 5 then
            local jushu = rankItem:getChildByName("jushu");
            jushu:setString(data[self.buttonIndex][index].iPlayCount);
            if data[self.buttonIndex][index].iGameId == 40010000 or data[self.buttonIndex][index].iGameId == 40010004  then
                jushu:setString("/");
            end
        else
            local TJuseName = rankItem:getChildByName("TJuseName");
            local TJuseId = rankItem:getChildByName("TJuseId");
            TJuseName:setString(FormotGameNickName(data[self.buttonIndex][index].CommendNickName,nickNameLen));
            TJuseId:setString("ID:"..data[self.buttonIndex][index].CommendUserID);
        end
        local shuishou = rankItem:getChildByName("shuishou");
        local deshuishou = rankItem:getChildByName("deshuishou");
        
        shuishou:setString(goldConvert(data[self.buttonIndex][index].lTaxProduce,1));
        deshuishou:setString(goldConvert(data[self.buttonIndex][index].lTaxGet,1));
    elseif self.buttonIndex == 4 then
        local endTime = rankItem:getChildByName("endTime");
        local gameType = rankItem:getChildByName("gameType");
        local score = rankItem:getChildByName("score");
        endTime:setString(timeConvert(data[self.buttonIndex][self.currentPage][index].iCreateDate,3));
        gameType:setString(VipRoomInfoModule:getRoomNameByRoomID(data[self.buttonIndex][self.currentPage][index].iRoomId));
        score:setString(goldConvert(data[self.buttonIndex][self.currentPage][index].iChangeScore,1));
    end

    
end

function VipManagement:split(str)
    local temp = string.split(str,"日")
    if temp[1] ~= nil then
        temp[1] = temp[1].."日";
    end
    return temp;
end



function VipManagement:createItem(index)

    local size = cc.size(1210,100);
    if self.buttonIndex == 3 or self.buttonIndex == 4 then
        size = cc.size(1210,75);
    end

	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(size);
    --layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    --layout:setBackGroundColor(cc.c3b(255, 0, 0))
    --layout:setAnchorPoint(0.5,0.5);
    
	--背景图片
    local itemStr = "newExtend/vip/detail/tiaobig.png"
    if self.buttonIndex == 3 or self.buttonIndex == 4 then
        itemStr = "newExtend/vip/detail/xinxitiao.png"
    end
	local itemBg = ccui.ImageView:create(itemStr);
    layout:addChild(itemBg);
    itemBg:setPosition(size.width/2-5,size.height*0.5);

    if self.buttonIndex == 1 or self.buttonIndex == 2 or self.buttonIndex == 5 or self.buttonIndex == 6 then
        --头像
        local headImage = ccui.ImageView:create("head/1.png");
        layout:addChild(headImage);
        headImage:setScale(0.5);
        headImage:setPosition(50,size.height*0.5);
        headImage:setName("headImage");

        -- local use = FontConfig.createWithSystemFont("玩家名字:", 24,cc.c3b(222, 195, 111));
        -- layout:addChild(use);
        -- use:setAnchorPoint(0.5,0.5);
        -- use:setPosition(size.width*0.15-20,size.height*0.5+20);
        -- use:setName("use");

        --名字
        local useName = FontConfig.createWithSystemFont("卡梅隆.安东尼", 24,cc.c3b(250, 200, 3));
        layout:addChild(useName);
        useName:setAnchorPoint(0,0.5);
        useName:setPosition(size.width*0.15-80,size.height*0.5+20);
        useName:setName("useName");

        --ID
        local useId= FontConfig.createWithSystemFont("ID:256987", 24,cc.c3b(255, 255, 255));
        layout:addChild(useId);
        useId:setAnchorPoint(0.5,0.5);
        useId:setPosition(size.width*0.15-20,size.height*0.5-20);
        useId:setName("useId");
    end

    if self.buttonIndex == 1 then --厅成员
        local text = FontConfig.createWithSystemFont("入厅时间:", 24,cc.c3b(255, 255, 255));
        layout:addChild(text);
        text:setAnchorPoint(0.5,0.5);
        text:setPosition(size.width*0.35-100,size.height*0.5+15);

        --入厅时间
        local time = FontConfig.createWithSystemFont("2019-02-20\n 14:22", 24,cc.c3b(250, 200, 3));
        layout:addChild(time);
        time:setAnchorPoint(0.5,0.5);
        time:setPosition(size.width*0.35+40,size.height*0.5);
        time:setName("time");

        local scoreText= FontConfig.createWithSystemFont("金币:", 24,FontConfig.colorWhite);
        layout:addChild(scoreText);
        scoreText:setAnchorPoint(0.5,0.5);
        scoreText:setPosition(size.width*0.50,size.height*0.5);
        scoreText:setName("scoreText");
        -- scoreText:setColor(cc.c3b(150, 91, 25));--

        --删除按钮
        local delateButton = ccui.Button:create("newExtend/vip/management/shanchu.png","newExtend/vip/management/shanchu-on.png");
        layout:addChild(delateButton);
        delateButton:setPosition(size.width*0.70-30,size.height*0.5);
        delateButton:setName("delateButton")
        -- delateButton:onClick(function ()
        --     luaPrint("删除按钮",index);
            
        --     local prompt = GamePromptLayer:create();
        --     prompt:showPrompt(GBKToUtf8("确认删除该成员?"));
        --     prompt:setBtnVisible(true,true)
        --     prompt:setBtnClickCallBack(function() 
        --        VipInfo:sendKickGuildUser(self.Tingdata.GuildID,self.data[1][index].UserID)
        --     end);
        -- end)
        delateButton:setVisible(false)
        

        --备注按钮
        local beizhuButton = ccui.Button:create("newExtend/vip/management/beizhu.png","newExtend/vip/management/beizhu-on.png");
        layout:addChild(beizhuButton);
        beizhuButton:setPosition(size.width*0.80+140,size.height*0.5);
        beizhuButton:setName("beizhuButton")
        -- beizhuButton:onClick(function ()
        --     luaPrint("备注按钮",index);
        --    local layer = require("hall.layer.popView.newExtend.vip.VipUserInfoLayer"):create(self.userList[index],self.Tingdata.GuildID)
        --     display.getRunningScene():addChild(layer)
        --     layer:setUserNodeInfoCallback(function (NoteName,NotePhone)
        --         self:setUserNodeInfo(NoteName,NotePhone,index)
        --     end)
        -- end)
        --股东设置按钮
        local gudongButton = ccui.Button:create("newExtend/vip/management/gudongshezhi.png","newExtend/vip/management/gudongshezhi-on.png");
        layout:addChild(gudongButton);
        gudongButton:setPosition(size.width*0.70+100,size.height*0.5);
        gudongButton:setName("gudongButton")

        --score
        local useScore= FontConfig.createWithSystemFont("+180", 24,cc.c3b(250, 200, 3));
        layout:addChild(useScore);
        useScore:setAnchorPoint(0,0.5);
        useScore:setPosition(size.width*0.50+30,size.height*0.5);
        useScore:setName("useScore");

        local tingzhu = ccui.ImageView:create("newExtend/vip/detail/zhu.png");
        layout:addChild(tingzhu);
        tingzhu:setPosition(20,size.height*0.7);
        tingzhu:setName("tingzhu");
        tingzhu:setVisible(false)

        local gudong = ccui.ImageView:create("newExtend/vip/gudong/gu.png");
        layout:addChild(gudong);
        gudong:setPosition(20,size.height*0.7);
        gudong:setName("gudong");
        gudong:setVisible(false)

    elseif self.buttonIndex == 2 then --待审核
        local text = FontConfig.createWithSystemFont("申请时间:", 24,cc.c3b(255, 255, 255));
        layout:addChild(text);
        text:setAnchorPoint(0.5,0.5);
        text:setPosition(size.width*0.45-100,size.height*0.5+15);

        --入厅时间
        local time = FontConfig.createWithSystemFont("2019-02-20\n 14:22", 24,cc.c3b(250, 200, 3));
        layout:addChild(time);
        time:setAnchorPoint(0.5,0.5);
        time:setPosition(size.width*0.45+40,size.height*0.5);
        time:setName("time");

        --拒绝按钮
        local noButton = ccui.Button:create("newExtend/vip/management/jujue.png","newExtend/vip/management/jujue-on.png");
        layout:addChild(noButton);
        noButton:setPosition(size.width*0.60+100,size.height*0.5);
        noButton:setName("noButton")
        -- noButton:onClick(function ()
        --     luaPrint("拒绝按钮",index);
        --     VipInfo:sendRejectGuildJoinInfo(self.Tingdata.GuildID,self.data[2][index].UserID,0)
        -- end)

        --同意按钮
        local acceptButton = ccui.Button:create("newExtend/vip/management/tongyi.png","newExtend/vip/management/tongyi-on.png");
        layout:addChild(acceptButton);
        acceptButton:setPosition(size.width*0.80+100,size.height*0.5);
        acceptButton:setName("acceptButton")
        -- acceptButton:onClick(function ()
        --     luaPrint("同意按钮",index);
        --     VipInfo:sendAgreeGuildJoinInfo(self.Tingdata.GuildID,self.data[2][index].UserID,0)
        -- end)

    elseif self.buttonIndex == 3 or self.buttonIndex == 5 or self.buttonIndex == 6 then -- 税收详情 成员详情

        if self.buttonIndex == 3 then
            --游戏名称
            local gameName = FontConfig.createWithSystemFont("百人牛牛", 24,cc.c3b(250, 200, 3));
            layout:addChild(gameName);
            gameName:setAnchorPoint(0.5,0.5);
            gameName:setPosition(size.width*0.10,size.height*0.5);
            gameName:setName("gameName");
        end

        if self.buttonIndex == 3 or self.buttonIndex == 5 then
            --实际局数
            local jushu = FontConfig.createWithSystemFont("10", 24,cc.c3b(250, 200, 3));
            layout:addChild(jushu);
            jushu:setAnchorPoint(0.5,0.5);
            jushu:setPosition(size.width*0.30,size.height*0.5);
            jushu:setName("jushu");
        else
            --推荐人名字
            local TJuseName = FontConfig.createWithSystemFont("卡梅隆.安东尼", 24,cc.c3b(250, 200, 3));
            layout:addChild(TJuseName);
            TJuseName:setAnchorPoint(0,0.5);
            TJuseName:setPosition(size.width*0.35-80,size.height*0.5+20);
            TJuseName:setName("TJuseName");

            --推荐人ID
            local TJuseId= FontConfig.createWithSystemFont("ID:256987", 24,cc.c3b(255, 255, 255));
            layout:addChild(TJuseId);
            TJuseId:setAnchorPoint(0.5,0.5);
            TJuseId:setPosition(size.width*0.35-20,size.height*0.5-20);
            TJuseId:setName("TJuseId");
        end

        --产生税收
        local shuishou = FontConfig.createWithSystemFont("876.64", 24,cc.c3b(250, 200, 3));
        layout:addChild(shuishou);
        shuishou:setAnchorPoint(0.5,0.5);
        shuishou:setPosition(size.width*0.60,size.height*0.5);
        shuishou:setName("shuishou");

        --获得税收
        local deshuishou = FontConfig.createWithSystemFont("756.64", 24,cc.c3b(250, 200, 3));
        layout:addChild(deshuishou);
        deshuishou:setAnchorPoint(0.5,0.5);
        deshuishou:setPosition(size.width*0.90,size.height*0.5);
        deshuishou:setName("deshuishou");

    elseif self.buttonIndex == 4 then -- 成员战绩
        --结束时间
        local endTime = FontConfig.createWithSystemFont("16:25:10", 24,cc.c3b(250, 200, 3));
        layout:addChild(endTime);
        endTime:setAnchorPoint(0.5,0.5);
        endTime:setPosition(size.width*0.20,size.height*0.5);
        endTime:setName("endTime");

        --游戏房间
        local gameType = FontConfig.createWithSystemFont("抢庄牛牛小资场", 24,cc.c3b(250, 200, 3));
        layout:addChild(gameType);
        gameType:setAnchorPoint(0.5,0.5);
        gameType:setPosition(size.width*0.50,size.height*0.5);
        gameType:setName("gameType");

        --输赢情况
        local score = FontConfig.createWithSystemFont("+756.64", 24,cc.c3b(250, 200, 3));
        layout:addChild(score);
        score:setAnchorPoint(0.5,0.5);
        score:setPosition(size.width*0.80,size.height*0.5);
        score:setName("score");

    end

	return layout;
end

function VipManagement:setUserNodeInfo(NoteName,NotePhone,index)
   -- self.data[1][index].NoteName = NoteName;
   -- self.data[1][index].NotePhone = NotePhone;
   addScrollMessage("保存成功")
   VipInfo:sendGetGuildUserInfo(self.Tingdata.GuildID)
end

return VipManagement
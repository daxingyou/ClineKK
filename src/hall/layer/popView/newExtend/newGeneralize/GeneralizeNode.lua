--新推广
local GeneralizeNode =  class("GeneralizeNode", BaseWindow)
--创建类
function GeneralizeNode:create()
	local layer = GeneralizeNode.new();

	return layer;
end

--构造函数
function GeneralizeNode:ctor()
	self.super.ctor(self, false, false);

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeNode:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeNode:bindEvent()
    self:pushEventInfo(GeneralizeInfo,"NewGeneralizeTotal",handler(self, self.receiveNewGeneralizeTotal))
    self:pushEventInfo(GeneralizeInfo,"NewGeneralizeReward",handler(self, self.receiveNewGeneralizeReward))
end

function GeneralizeNode:receiveNewGeneralizeReward(data)
    local data = data._usedata
    luaDump(data,"NewGeneralizeReward");
    if data.ret == 0 then
        GeneralizeInfo:sendGetNewGeneralizeTotalRequest()
        addScrollMessage("领取成功")
        dispatchEvent("refreshScoreBank")
    elseif data.ret == 1 then--模式不对
        addScrollMessage("推广模式不对")
    elseif data.ret == 2 then--钱不够
        addScrollMessage("没有可提取的奖励")
    end
end

function GeneralizeNode:receiveNewGeneralizeTotal(data)
    local data = data._usedata
    luaDump(data,"NewGeneralizeTotal");
    self.data = data;

    self:setInfoString(self.data); 
end

function GeneralizeNode:InitData()
    
end

function GeneralizeNode:InitUI()
    local bg = ccui.ImageView:create("newExtend/newGeneralize/dikuang2.png");
    self:addChild(bg);
    self.background = bg;
    self.size = bg:getContentSize();

    local helpImage = ccui.ImageView:create("newExtend/newGeneralize/tu.png");
    helpImage:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5);
    bg:addChild(helpImage);

    --领取奖励
    local jiangliBtn = ccui.Button:create("newExtend/newGeneralize/jiangli.png","newExtend/newGeneralize/jiangli-on.png","newExtend/newGeneralize/jiangli-cancle.png");
    bg:addChild(jiangliBtn);
    self.jiangliBtn = jiangliBtn;
    self.jiangliBtn:setEnabled(false);
    jiangliBtn:setTag(3);
    jiangliBtn:setPosition(self.size.width*0.7,self.size.height*0.15);
    jiangliBtn:onTouchClick(function (sender)
        self:onCallBack(sender);
    end);

    --提取记录
    local tiquBtn = ccui.Button:create("newExtend/newGeneralize/tiqujilu.png","newExtend/newGeneralize/tiqujilu-on.png");
    bg:addChild(tiquBtn);
    tiquBtn:setTag(1);
    tiquBtn:setPosition(self.size.width*0.1+20,self.size.height*0.15);
    tiquBtn:onTouchClick(function (sender)
        self:onCallBack(sender);
    end);

    --游戏帮助
    local helpBtn = ccui.Button:create("newExtend/newGeneralize/youxibangzhu.png","newExtend/newGeneralize/youxibangzhu-on.png");
    bg:addChild(helpBtn);
    helpBtn:setTag(2);
    helpBtn:setPosition(self.size.width*0.3,self.size.height*0.15);
    helpBtn:onTouchClick(function (sender)
        self:onCallBack(sender);
    end);

    --二维码
    local tag = cc.UserDefault:getInstance():getIntegerForKey("saveExtend",1)
    --local btn = ccui.Button:create()
    createExtendQr()--生成二维码
    local path = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"
    local qr = ccui.ImageView:create(path)
    qr:setPosition(self.size.width*0.2+20,self.size.height*0.7-10)
    self.background:addChild(qr)
    qr:setScale(0.8);

    --总奖励
    local allMoneyText = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(allMoneyText);
    allMoneyText:setPosition(self.size.width*0.80,self.size.height*0.8+50);
    self.allMoneyText = allMoneyText

    --直属玩家人数
    local peopleNumText = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(peopleNumText);
    peopleNumText:setPosition(self.size.width*0.80,self.size.height*0.8);
    self.peopleNumText = peopleNumText

    --其他玩家人数
    local otherPeopleNumText = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(otherPeopleNumText);
    otherPeopleNumText:setPosition(self.size.width*0.80,self.size.height*0.8-50);
    self.otherPeopleNumText = otherPeopleNumText

    --昨日直属玩家奖励
    local peopleScoreText = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(peopleScoreText);
    peopleScoreText:setPosition(self.size.width*0.80,self.size.height*0.8-100);
    self.peopleScoreText = peopleScoreText

    --昨日其他玩家奖励
    local otherPeopleScoreText = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(otherPeopleScoreText);
    otherPeopleScoreText:setPosition(self.size.width*0.80,self.size.height*0.8-150);
    self.otherPeopleScoreText = otherPeopleScoreText

    --总奖励1
    local allScore1 = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(allScore1);
    allScore1:setPosition(self.size.width*0.65,self.size.height*0.3-10);
    self.allScore1 = allScore1
    allScore1:setAnchorPoint(1,0.5)

    --可提取奖励1
    local haveScore = FontConfig.createWithCharMap("0","newExtend/newGeneralize/zitiao.png",18,24,"+")
    self.background:addChild(haveScore);
    haveScore:setPosition(self.size.width*0.90+10,self.size.height*0.3-10);
    self.haveScore = haveScore
    haveScore:setAnchorPoint(1,0.5)

    --保存二维码
    local baocunBtn = ccui.Button:create("newExtend/newGeneralize/baocunerweima.png","newExtend/newGeneralize/baocunerweima-on.png");
    baocunBtn:setPosition(self.size.width*0.2+20,self.size.height*0.7-160)
    self.background:addChild(baocunBtn)
    baocunBtn:setTag(4)
    baocunBtn:onTouchClick(function (sender)
        self:onCallBack(sender);
    end);

    --复制链接
    local fuzhiBtn = ccui.Button:create("newExtend/newGeneralize/fuzhilianjie.png","newExtend/newGeneralize/fuzhilianjie-on.png");
    fuzhiBtn:setPosition(self.size.width*0.2+20,self.size.height*0.7-280);
    self.background:addChild(fuzhiBtn);
    fuzhiBtn:setTag(5)
    fuzhiBtn:onTouchClick(function (sender)
        self:onCallBack(sender);
    end);

    GeneralizeInfo:sendGetNewGeneralizeTotalRequest()


end

function GeneralizeNode:setInfoString(data)
    self.peopleNumText:setString(tostring(data.DirectCount));--直属玩家人数
    self.otherPeopleNumText:setString(tostring(data.TeamCount));--其他玩家人数
    self.allMoneyText:setString(goldConvert(data.LastReward,1));--昨日总奖励
    self.peopleScoreText:setString(goldConvert(data.DirectRevenue,1));--昨日直属玩家奖励
    self.otherPeopleScoreText:setString(goldConvert(data.TeamRevenue,1));--昨日其他玩家奖励
    self.allScore1:setString(goldConvert(data.TotalReward,1)..":;");--历史总奖励
    self.haveScore:setString(goldConvert(data.AgencyReward,1)..":;");--可提取奖励
    self.jiangliBtn:setEnabled(data.AgencyReward>0);
end

--按钮回调
function GeneralizeNode:onCallBack(sender)
    local tag  = sender:getTag();
    luaPrint("tag",tag);
    if tag == 1 then
        local layer = require("layer.popView.newExtend.newGeneralize.GeneralizeLogLayer"):create();
        display.getRunningScene():addChild(layer)
    elseif tag == 2 then
        local layer = require("layer.popView.newExtend.newGeneralize.GeneralizeHelpLayer"):create();
        display.getRunningScene():addChild(layer)
    elseif tag == 3 then --领取奖励
        GeneralizeInfo:sendGetNewGeneralizeRewardRequest()
    elseif tag == 4 then
        local touchLayer = display.newLayer()
        touchLayer:setTouchEnabled(true)
        touchLayer:setLocalZOrder(9000)
        display.getRunningScene():addChild(touchLayer)
        touchLayer:onTouch(function(event) 
                                local eventType = event.name; 
                                if eventType == "began" then
                                    return true
                                end
                                if eventType == "ended" or eventType == "cancel" then
                                    performWithDelay(self,function() touchLayer:removeSelf() end,0.1)
                                end
                    end,false, true)

        local qr = ccui.ImageView:create(qrPath)
        qr:setPosition(winSize.width/2,winSize.height/2)
        touchLayer:addChild(qr)

        saveSystemPhoto(qrPath)
    elseif tag == 5 then
        if copyToClipBoard(getQrUrl()) then
            addScrollMessage("推广地址复制成功")
        end
    end
 end 

return GeneralizeNode;
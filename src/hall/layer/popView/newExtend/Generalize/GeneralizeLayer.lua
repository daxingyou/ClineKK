local GeneralizeLayer =  class("GeneralizeLayer", PopLayer)

GeneralizePath = "hall.layer.popView.newExtend.Generalize";
local BtnType = {
    normal = 1,
    select = 2,
    disable = 3;
}
--主界面
--创建类
function GeneralizeLayer:create(iType)
	local layer = GeneralizeLayer.new(iType);

	return layer;
end

--构造函数
function GeneralizeLayer:ctor(iType)
	self.super.ctor(self,PopType.none)

    self.iType = iType

    cc.FileUtils:getInstance():addSearchPath("res/hall/newExtend/generalize",true);

    local writablePath = cc.FileUtils:getInstance():getWritablePath();

    if device.platform ~= "windows" then
        cc.FileUtils:getInstance():addSearchPath(writablePath.."res/hall/newExtend/generalize",true);
    end

    local uiTable = {
        Panel_template = "Panel_template",
        ListView_list = "ListView_list",
        Image_text = "Image_text",
        Panel_content = "Panel_content",
        Button_close = "Button_close",
        Panel_gg = "Panel_gg",
        Image_ziBg = "Image_ziBg",
        Image_bg = "Image_bg",
        Image_di = "Image_di",
    }

    loadNewCsb(self,"MainScene",uiTable);

    iphoneXFit(self.Image_bg,1);

    --适配
    -- self.Button_close:setPositionX(self.Button_close:getPositionX()-(winSize.width-1280)/2);
    -- self.Image_text:setPositionX(self.Image_text:getPositionX()-(winSize.width-1280)/2);

    -- self.ListView_list:setPositionX(self.ListView_list:getPositionX()-(winSize.width-1280)/2);
    self.Image_di:setPositionX(self.Image_di:getPositionX()-(winSize.width-1280)/2);

    self:InitData();

    self:InitUI();

    self:LoadAfter();
    
    playEffect("hall/sound/generalize.mp3")
	
end

--进入
function GeneralizeLayer:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);

    ExtendInfo:sendExtendTotalCountRequest();
end

function GeneralizeLayer:bindEvent()
    self:pushEventInfo(ExtendInfo,"ExtendTotalCount",handler(self, self.onExtendTotalCount));
    self:pushEventInfo(ExtendInfo,"ExtendProvisions",handler(self, self.onReceiveProvisions));
    self:pushEventInfo(ExtendInfo,"ReceiveGetCash",handler(self, self.onReceiveGetCash));
end

function GeneralizeLayer:InitData()
    self.generalizeList = {};

    self.totalCount = nil;

    self.selectTag = 0;--默认设置

    self.ggData = {};
end

function GeneralizeLayer:InitUI()
    self.Panel_template:setVisible(false);

    for i = 1,7 do
        if i ~= 3 and i~= 6 then
            local temp = self.Panel_template:clone();
            temp:setVisible(true);

            temp:removeFromParent();

            local image = temp:getChildByName("Image_template");
            image:loadTexture("Image/tg"..i.."_1.png");

            self.ListView_list:pushBackCustomItem(temp);

            temp:setTag(i);
            temp:addTouchEventListener(handler(self, self.BtnTouchCallBack));
        end
    end

    --隐藏listview的滑动条
    self.ListView_list:setScrollBarEnabled(false);

    --关闭按钮
    if self.Button_close then
        self.Button_close:onClick(handler(self,self.CloseClick))
    end
end

--关闭
function GeneralizeLayer:CloseClick()
    dispatchEvent("registerLayerUpCallBack");
    self:delayCloseLayer(0);
end

--列表的按钮touch事件 模拟成按钮
function GeneralizeLayer:BtnTouchCallBack(sender,eventType)
    local senderTag = sender:getTag();
    local image = sender:getChildByName("Image_template");

    if self.selectTag == senderTag then
        return;
    end

    if eventType == ccui.TouchEventType.began then
        self:SelectListSender(sender,BtnType.select);
    elseif eventType == ccui.TouchEventType.moved then
        self:SelectListSender(sender,BtnType.normal);
    elseif eventType == ccui.TouchEventType.ended then
        self:SetAllNormalSender();
        --将其他的全部置成普通
        self:SetSelectSender(senderTag);
        audio.playSound(GAME_SOUND_BUTTON)
    elseif eventType == ccui.TouchEventType.canceled then
        self:SelectListSender(sender,BtnType.normal);
    end
end

--加载场景后的界面
function GeneralizeLayer:LoadAfter()

    --设置默认第一个标签选中
    if self.iType == 1 then
        self:SetSelectSender(7);
    else
        self:SetSelectSender(1);
    end
end

--设置选中的标签显示内容
function GeneralizeLayer:SetSelectSender(tag)
    if self.selectTag == tag then
        return;
    end
    self.selectTag = tag;

    local temp = nil;

    for k,v in pairs(self.ListView_list:getChildren()) do
        if v:getTag() == self.selectTag then
            temp = v;
            break;
        end
    end

    if temp == nil then
        return;
    end
    self:SelectListSender(temp,BtnType.disable);

    --根据tag绘制不同的node界面
    local nodePath = nil;
    if tag == 1 then
        nodePath = require(GeneralizePath..".GeneralizeNode");
    elseif tag == 2 then
        nodePath = require(GeneralizePath..".MyPlayerNode");
    elseif tag == 3 then
        nodePath = require(GeneralizePath..".MyPerformanceNode");
    elseif tag == 4 then
        nodePath = require(GeneralizePath..".MyAwardNode");
    elseif tag == 5 then
        nodePath = require(GeneralizePath..".MyDepositNode");
    elseif tag == 6 then
        nodePath = require(GeneralizePath..".MyAdDepositNode");
    elseif tag == 7 then
        nodePath = require(GeneralizePath..".ReadMeNode");
    end

    if nodePath then
        self.Panel_content:removeAllChildren();
        local nodeLoad = nodePath:create(self);
        self.Panel_content:addChild(nodeLoad);
    end

end


--将所有的标签置为false
function GeneralizeLayer:SetAllNormalSender()
    local allTemp = self.ListView_list:getChildren();

    for k,temp in pairs(allTemp) do
        self:SelectListSender(temp,BtnType.normal);
    end
end

--选择选中的标签
function GeneralizeLayer:SelectListSender(sender,type)
    local senderTag = sender:getTag();
    local image = sender:getChildByName("Image_template");

    if type == BtnType.normal then
        image:loadTexture("Image/tg"..senderTag.."_1.png");
    elseif type == BtnType.select then
        image:loadTexture("Image/tg"..senderTag.."_2.png");
    elseif type == BtnType.disable then
        image:loadTexture("Image/tg"..senderTag.."_3.png");
    end        

end

function GeneralizeLayer:onExtendTotalCount(data)
    local msg = data._usedata;
    self.totalCount = msg;
end

function GeneralizeLayer:SetGGData(str)
    if str == "" then
        return;
    end

    table.insert(self.ggData,str);

    if #self.ggData>1 then
        return;
    end

    self:StartGGData();
end

function GeneralizeLayer:StartGGData()
    local ggSize = self.Panel_gg:getContentSize();

    local ggStr = FontConfig.createWithSystemFont(self.ggData[1],30,FontConfig.colorYellow);
    ggStr:setPosition(ggSize.width,ggSize.height/2);
    ggStr:setAnchorPoint(cc.p(0, 0.5));
    ggStr:setName("ggStr");
    self.Panel_gg:addChild(ggStr);

    local ggStrWidth = ggStr:getContentSize().width;

    ggStr:runAction(cc.Sequence:create(cc.MoveBy:create((ggStrWidth+ggSize.width)/80,cc.p(-ggStrWidth-ggSize.width,0)),cc.CallFunc:create(function()
        ggStr:removeFromParent();
        table.remove(self.ggData,1);

        if #self.ggData>0 then
            self:StartGGData();
        end

    end)))
end

function GeneralizeLayer:onReceiveProvisions(data)
    local msg = data._usedata;

    luaDump(msg,"预提现");

    if msg.ret == 0 then--收到提现成功 发送log 和 total消息
        dispatchEvent("refreshScoreBank");
        addScrollMessage("操作成功");
    elseif msg.ret == 1 then
        addScrollMessage("预提低于最低金币")
    elseif msg.ret == 2 then
        addScrollMessage("已经预提过了");
    elseif msg.ret == 3 then
        addScrollMessage("未到达预提时间");
    elseif msg.ret == 4 then
        addScrollMessage("账号被禁用");
    else
        addScrollMessage("预提失败")
    end

end

function GeneralizeLayer:onReceiveGetCash(data)
    local msg = data._usedata;

    if msg.ret == 0 then--收到提现成功 发送log 和 total消息
        dispatchEvent("refreshScoreBank");
        addScrollMessage("操作成功");
    elseif msg.ret == 1 then
        addScrollMessage("支付宝未绑定")
    elseif msg.ret == 2 then
        addScrollMessage("银行卡未绑定")
    elseif msg.ret == 3 then
        addScrollMessage("提现到支付宝至少"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiZifubao)/100).."金币")
    elseif msg.ret == 4 then
        addScrollMessage("提现到银行卡至少"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiYinhangka)/100).."金币")
    elseif msg.ret == 5 then
        addScrollMessage("提现金币必须是"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiTixianbeishu)/100).."倍数")
    elseif msg.ret == 6 then
        addScrollMessage("钱包金币不足")
    elseif msg.ret == 7 then
        addScrollMessage("正在游戏中，请稍后再试")
    elseif msg.ret == 13 then
        addScrollMessage("提现金币不足")
    else
        addScrollMessage("提现请求提交失败")
    end

end

return GeneralizeLayer;
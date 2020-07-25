
--主界面---新推广

local NewGeneralizeLayer =  class("NewGeneralizeLayer", PopLayer)

--创建类
function NewGeneralizeLayer:create()
	local layer = NewGeneralizeLayer.new();

	return layer;
end

--构造函数
function NewGeneralizeLayer:ctor()
	self.super.ctor(self,PopType.none)

    self:InitData();

    self:InitUI();

    playEffect("hall/sound/generalize.mp3")
	
end

--进入
function NewGeneralizeLayer:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function NewGeneralizeLayer:bindEvent()
    
end

function NewGeneralizeLayer:InitData()
    
end

function NewGeneralizeLayer:InitUI()
    --背景
    self.bg = ccui.ImageView:create("newExtend/newGeneralize/bg.png");
    self:addChild(self.bg);
    local winSize = cc.Director:getInstance():getWinSize();
    self.bg:setPosition(cc.p(winSize.width/2,winSize.height/2));
    iphoneXFit(self.bg,1);

    self.size = self.bg:getContentSize()

    -- --右边显示框
    -- local kuang = ccui.ImageView:create("newExtend/newGeneralize/dikuang2.png");
    -- self.bg:addChild(kuang);
    -- kuang:setPosition(self.size.width*0.6+5,self.size.height*0.5-40);

    --按钮背景
    local btnBg = ccui.ImageView:create("newExtend/newGeneralize/cebian.png");
    btnBg:setPosition(self.size.width*0.1,self.size.height*0.5);
    self.bg:addChild(btnBg);

    --顶
    local image = ccui.ImageView:create("newExtend/newGeneralize/ding.png");
    image:setPosition(self.size.width*0.5,self.size.height-38);
    self.bg:addChild(image);

    --图标背景
    local titleBg = ccui.ImageView:create("newExtend/newGeneralize/dingzibg.png");
    titleBg:setPosition(image:getContentSize().width*0.2-30,image:getContentSize().height*0.5);
    image:addChild(titleBg);
    local framesize = cc.Director:getInstance():getWinSize()
    local addWidth = (framesize.width - 1280)/4;
    titleBg:setPositionX(titleBg:getPositionX()-addWidth);

    --图标
    local title = ccui.ImageView:create("newExtend/newGeneralize/tuiguangyuan.png");
    title:setPosition(image:getContentSize().width*0.2-30,image:getContentSize().height*0.5);
    image:addChild(title);
    title:setPositionX(title:getPositionX()-addWidth);

    --关闭按钮
    local closeButton = ccui.Button:create("newExtend/newGeneralize/fanhui.png","newExtend/newGeneralize/fanhui-on.png");
    closeButton:setPosition(image:getContentSize().width*0.85,image:getContentSize().height*0.5);
    image:addChild(closeButton);
    closeButton:onTouchClick(function(sender) self:CloseClick() end,1)
    closeButton:setPositionX(closeButton:getPositionX()+(winSize.width-1280)/4)

    --选项按钮
    self.btnTable = {};
    for i=1,4 do
        local btn = ccui.Button:create("newExtend/newGeneralize/btn"..i..".png","newExtend/newGeneralize/btn"..i.."-on"..".png","newExtend/newGeneralize/btn"..i.."-cancle"..".png");
        btn:setPosition(btnBg:getContentSize().width*0.5+15,btnBg:getContentSize().height*((1-0.18*i)));
        btnBg:addChild(btn);
        btn:setTag(i);
        btn:onTouchClick(function (sender)
            self:btnCallBack(sender)
        end);
        table.insert(self.btnTable,btn)
    end

    self:btnCallBack(self.btnTable[1]);

end

--按钮回调
function NewGeneralizeLayer:btnCallBack(sender)
    local tag = sender:getTag();
    luaPrint("tag",tag);
    self:selectBtn(tag);

    local layer;
    layer = self.bg:getChildByName("newGeneralize");
    if layer then
        layer:removeFromParent();
    end
    if tag == 1 then
        layer = require("layer.popView.newExtend.newGeneralize.GeneralizeNode"):create();
        layer:setName("newGeneralize");
    elseif tag == 2 then
        layer = require("layer.popView.newExtend.newGeneralize.GeneralizeDetailNode"):create();
        layer:setName("newGeneralize");
    elseif tag == 3 then
        layer = require("layer.popView.newExtend.newGeneralize.GeneralizeHelpNode"):create();
        layer:setName("newGeneralize");
    else
        layer = require("layer.popView.newExtend.newGeneralize.GeneralizeRankNode"):create();
        layer:setName("newGeneralize");
    end

    if layer then
        self.bg:addChild(layer);
        local framesize = cc.Director:getInstance():getWinSize()
        --local scale = framesize.width/1280;
        layer:setPosition(framesize.width*0.6+5,framesize.height*0.5-40);
    end

end

--按钮设置
function NewGeneralizeLayer:selectBtn(tag)
    for k,v in pairs(self.btnTable) do
        if tag == v:getTag() then
            v:setEnabled(false);
        else
            v:setEnabled(true);
        end
    end
end

--关闭
function NewGeneralizeLayer:CloseClick()
    dispatchEvent("registerLayerUpCallBack");
    self:delayCloseLayer(0);
end

return NewGeneralizeLayer;
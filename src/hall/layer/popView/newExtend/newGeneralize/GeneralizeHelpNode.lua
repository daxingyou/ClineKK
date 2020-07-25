local GeneralizeHelpNode =  class("GeneralizeHelpNode", BaseWindow)
--主界面
--创建类
function GeneralizeHelpNode:create()
	local layer = GeneralizeHelpNode.new();

	return layer;
end

--构造函数
function GeneralizeHelpNode:ctor()
	self.super.ctor(self, false, false);

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeHelpNode:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeHelpNode:bindEvent()
    self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function GeneralizeHelpNode:receiveConfigInfo(data)
    local data = data._usedata

    luaPrint("receiveConfigInfo",SettlementInfo:getConfigInfoByID(48));

    if data.id == 48 then
        if SettlementInfo:getConfigInfoByID(48) > 0 then
            for k,v in pairs(self.textTable) do
                v:setString(SettlementInfo:getConfigInfoByID(48)/10);
            end
        end
    else

    end
end

function GeneralizeHelpNode:InitData()
    self.textTable = {};
end

function GeneralizeHelpNode:InitUI()
    SettlementInfo:sendConfigInfoRequest(48)
    local bg = ccui.ImageView:create("newExtend/newGeneralize/dikuang2.png");
    self:addChild(bg);
    self.size = bg:getContentSize();

    local helpImage = ccui.ImageView:create("newExtend/newGeneralize/tuiguangjiaochengtu.png");
    helpImage:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5);
    bg:addChild(helpImage);

    --返利比
    local bit = FontConfig.createWithCharMap("0","newExtend/newGeneralize/tuiguangzitiao.png",12,18,"+")
    bg:addChild(bit);
    bit:setPosition(self.size.width*0.80-10,self.size.height*0.4-20-2);
    bit:setString(SettlementInfo:getConfigInfoByID(48)/10);
    table.insert(self.textTable,bit);



    local bit = FontConfig.createWithCharMap("0","newExtend/newGeneralize/tuiguangzitiao2.png",10,16,"+")
    bg:addChild(bit);
    bit:setPosition(self.size.width*0.60,self.size.height*0.2-5);
    bit:setString(SettlementInfo:getConfigInfoByID(48)/10);
    table.insert(self.textTable,bit);

    local bit = FontConfig.createWithCharMap("0","newExtend/newGeneralize/tuiguangzitiao2.png",10,16,"+")
    bg:addChild(bit);
    bit:setPosition(self.size.width*0.60+200+25,self.size.height*0.2-5);
    bit:setString(SettlementInfo:getConfigInfoByID(48)/10);
    table.insert(self.textTable,bit);

    local bit = FontConfig.createWithCharMap("0","newExtend/newGeneralize/tuiguangzitiao2.png",10,16,"+")
    bg:addChild(bit);
    bit:setPosition(self.size.width*0.50+20,self.size.height*0.2-30+3);
    bit:setString(SettlementInfo:getConfigInfoByID(48)/10);
    table.insert(self.textTable,bit);

    local bit = FontConfig.createWithCharMap("0","newExtend/newGeneralize/tuiguangzitiao2.png",10,16,"+")
    bg:addChild(bit);
    bit:setPosition(self.size.width*0.50+90,self.size.height*0.2-30+3);
    bit:setString(SettlementInfo:getConfigInfoByID(48)/10);
    table.insert(self.textTable,bit);

end

return GeneralizeHelpNode;
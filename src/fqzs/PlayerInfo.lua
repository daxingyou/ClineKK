local PlayerInfo = class("PlayerInfo", function() return ccui.Layout:create(); end)

function PlayerInfo:ctor(openLayer, id, data)
    self:initData();

    self.openLayer = openLayer;
    self.id = id;
    self.data = data;

    self:initUI();
end

function PlayerInfo:initData()
end

function PlayerInfo:initUI()
    local bg = ccui.ImageView:create();
    bg:loadTexture("diban.png",UI_TEX_TYPE_PLIST);
    bg:setPosition(cc.p(120,30));
    self:addChild(bg);
    --头像
    local head = ccui.ImageView:create(getHeadPath(self.data.bLogoID,self.data.bBoy));
    head:setPosition(cc.p(35,32));
    head:setScale(0.35);
    bg:addChild(head);
    --昵称
    local name = FontConfig.createWithSystemFont(FormotGameNickName(self.data.nickName,nickNameLen),20,FontConfig.colorBlack);
    name:setAnchorPoint(0.5,0.5);
    name:setPosition(cc.p(130,48))
    bg:addChild(name);

   
    --金币图标
    local jinbikuang = ccui.ImageView:create();
    jinbikuang:loadTexture("jinbixianshi.png",UI_TEX_TYPE_PLIST);
    jinbikuang:setPosition(cc.p(130,18));
    jinbikuang:setScale(0.7);
    bg:addChild(jinbikuang);

    --金币数量
    local label = FontConfig.createWithCharMap(gameRealMoney(self.data.i64Money),"fqzs/zhuangjiazitiao.png",13,22,"+")
    label:setAnchorPoint(0.5,0.5);
    label:setPosition(cc.p(97,20))
    label:setScale(0.9)
    jinbikuang:addChild(label);

end

function PlayerInfo:setExchangeCallBack(func)
    self.Ex_callBack = func;
end

return PlayerInfo;
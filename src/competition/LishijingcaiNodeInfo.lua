--历史竞猜info

local LishijingcaiNodeInfo = class("LishijingcaiNodeInfo", function() return display.newNode(); end)

function LishijingcaiNodeInfo:ctor(matchid, data)
    self.matchid = matchid;
    self.data = data;

    self:initUI();
end

function LishijingcaiNodeInfo:initUI()
    local bg = ccui.ImageView:create("geren/lishi/BGtiao.png");
    bg:setPosition(cc.p(640,88));
    self:addChild(bg);
    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);
    self.pNode = pNode;
    local bgsize = cc.size(1280,170);

    
    local texttz = FontConfig.createWithSystemFont(self.data.dateStr,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.83);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(self.data.matchInfo,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.98,bgsize.height*0.83);
    texttz:setAnchorPoint(cc.p(1, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(self.data.guessInfo,24,cc.c3b(220, 168, 121));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.5);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(self.data.winInfo,24,cc.c3b(87, 197, 224));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.18);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont("投注："..goldConvert(self.data.touScore).."金币",24,cc.c3b(220, 168, 121));
    texttz:setPosition(bgsize.width*0.4,bgsize.height*0.5);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont("回馈："..goldConvert(self.data.fanScore).."金币",24,cc.c3b(220, 168, 121));
    texttz:setPosition(bgsize.width*0.4,bgsize.height*0.18);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);


    local texttz = FontConfig.createWithSystemFont(self.data.statetip,36,FontConfig.colorGold);
    texttz:setPosition(bgsize.width*0.88,bgsize.height*0.36);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    -- local jinbi = ccui.ImageView:create("geren/lishi/jinbitubiao.png");
    -- jinbi:setPosition(bgsize.width*0.95,bgsize.height*0.4);
    -- bg:addChild(jinbi);

    
end

return LishijingcaiNodeInfo

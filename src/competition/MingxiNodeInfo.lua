--明细info

local MingxiNodeInfo = class("MingxiNodeInfo", function() return display.newNode(); end)

function MingxiNodeInfo:ctor(data)
    self.data = data;

    self:initUI();
end

function MingxiNodeInfo:initUI()
    local bg = ccui.ImageView:create("geren/mingxi/BGtiao.png");
    bg:setPosition(cc.p(640,78));
    self:addChild(bg);
    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);
    self.pNode = pNode;
    local bgsize = cc.size(1280,155);

    
    local texttz = FontConfig.createWithSystemFont(self.data.dateStr,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.84);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont("参与竞猜：",24,cc.c3b(220, 168, 121));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.5);
     texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(self.data.content,24,cc.c3b(142, 163, 242));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.3);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    pNode:addChild(texttz);

    

    local jinbi = ccui.ImageView:create("geren/mingxi/jinbitubiao.png");
    jinbi:setPosition(bgsize.width*0.95,bgsize.height*0.4);
    pNode:addChild(jinbi);

    local str = ""
    if self.data.score >= 0 then
        str ="+"..goldConvert(self.data.score);
    else
        str = goldConvert(self.data.score);
    end
    jinbinum = FontConfig.createWithCharMap(str,"zhuye/daojishi.png", 16, 20, '+');
    jinbinum:setPosition(bgsize.width*0.90,bgsize.height*0.4);
    pNode:addChild(jinbinum);

    
end

return MingxiNodeInfo

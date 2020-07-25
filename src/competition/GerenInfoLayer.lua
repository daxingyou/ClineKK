--个人中心

local GerenInfoLayer = class("GerenInfoLayer", BaseWindow)

function GerenInfoLayer:create(tableLayer)
	return GerenInfoLayer.new(tableLayer);
end

function GerenInfoLayer:ctor(tableLayer)
    self.super.ctor(self, nil, true);

    self.tableLayer = tableLayer;

    self:setName("GerenInfoLayer");

    self:initData();

    self:initUI()
end

function GerenInfoLayer:initData()  
    self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveRefreshScoreBank))
end


function GerenInfoLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("zhuye/bg.png");
    -- local bg = ccui.ImageView:create("geren/bg.jpg");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self:addChild(bg);
    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);
    self.pNode = pNode;
    local bgsize = cc.size(1280,720);

    local dinglan = ccui.ImageView:create("zhuye/dinglan.png");
    dinglan:setAnchorPoint(0.5,1);
    dinglan:setPosition(bgsize.width/2,bgsize.height);
    pNode:addChild(dinglan,200);

    local dingNode = cc.Node:create();
    dingNode:setPosition(139.5,0);
    dinglan:addChild(dingNode);
    local dingSize = dinglan:getContentSize();

    -- --主页
    -- local zhuyebg = ccui.ImageView:create("zhuye/biaotiBG.png");
    -- zhuyebg:setAnchorPoint(0,1);
    -- zhuyebg:setPosition(-139,dingSize.height);
    -- dingNode:addChild(zhuyebg);
    -- local zybgsize = zhuyebg:getContentSize();

    -- local zhuye = ccui.ImageView:create("geren/zi-gerenzhongxin.png");
    -- zhuye:setAnchorPoint(1,0.5);
    -- zhuye:setPosition(zybgsize.width-80,zybgsize.height/2+5);
    -- zhuyebg:addChild(zhuye);

    -- --更多
    -- local moreBtn = ccui.Button:create("zhuye/gengduo.png","zhuye/gengduo-on.png")
    -- moreBtn:setPosition(1280-40,dingSize.height/2);
    -- dingNode:addChild(moreBtn,100);
    -- moreBtn:setName("more")
    -- -- moreBtn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end);
    -- moreBtn:onClick(handler(self,self.onClickBtnCallBack));



    local baoxiangui = ccui.ImageView:create("zhuye/baoxianxiang.png");
    baoxiangui:setAnchorPoint(0,0.5);
    baoxiangui:setPosition(300,dingSize.height/2);
    dingNode:addChild(baoxiangui);

    self.baoxianguinum = FontConfig.createWithCharMap(goldConvertFour(PlatformLogic.loginResult.i64Bank),"zhuye/zitiao.png", 15, 21, '+');
    self.baoxianguinum:setPosition(cc.p(60,22));
    self.baoxianguinum:setAnchorPoint(cc.p(0, 0.5));
    baoxiangui:addChild(self.baoxianguinum);
    
    local jinbi = ccui.ImageView:create("zhuye/jinbi.png");
    jinbi:setAnchorPoint(0,0.5);
    jinbi:setPosition(20,dingSize.height/2);
    dingNode:addChild(jinbi);

    self.jinbinum = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Money),"zhuye/zitiao.png", 15, 21, '+');
    self.jinbinum:setPosition(cc.p(60,22));
    self.jinbinum:setAnchorPoint(cc.p(0, 0.5));
    jinbi:addChild(self.jinbinum);


    --个人头像
    local touxiangbg = ccui.ImageView:create("geren/touxiangkuang.png");
    touxiangbg:setPosition(bgsize.width*0.05+3,bgsize.height*0.77-5);
    pNode:addChild(touxiangbg);

    local path,id = getHeadPath(PlatformLogic.loginResult.bLogoID,PlatformLogic.loginResult.bBoy,true)
    local touxiang = ccui.ImageView:create(path);
    touxiang:setPosition(bgsize.width*0.05+3,bgsize.height*0.77-5);
    pNode:addChild(touxiang);
    touxiang:setScale(0.79)

    --线
    local xian = ccui.ImageView:create("geren/xian.png");
    xian:setPosition(bgsize.width*0.27,bgsize.height*0.77-5);
    pNode:addChild(xian);

    --昵称
    local textss = FontConfig.createWithSystemFont("用户名：",24,cc.c3b(87, 197, 224));
    textss:setPosition(bgsize.width*0.17,bgsize.height*0.79);
    pNode:addChild(textss);

    local userName = FontConfig.createWithSystemFont(FormotGameNickName(PlatformLogic.loginResult.nickName,8),24,FontConfig.colorWhite);
    userName:setPosition(bgsize.width*0.24,bgsize.height*0.79);
    pNode:addChild(userName);
    userName:setAnchorPoint(0,0.5)

    --ID
    local textss = FontConfig.createWithSystemFont("用户ID：",24,cc.c3b(87, 197, 224));
    textss:setPosition(bgsize.width*0.17,bgsize.height*0.72);
    pNode:addChild(textss);

    local userID = FontConfig.createWithSystemFont(PlatformLogic.loginResult.dwUserID,24,FontConfig.colorWhite);
    userID:setPosition(bgsize.width*0.24,bgsize.height*0.72);
    pNode:addChild(userID);
    userID:setAnchorPoint(0,0.5)

    --竞猜历史
    local lishibg = ccui.ImageView:create("geren/BGtiao.png");
    lishibg:setPosition(bgsize.width*0.5,bgsize.height*0.60);
    pNode:addChild(lishibg);

    local lishiNode = cc.Node:create();
    lishiNode:setPosition(139.5,0);
    lishibg:addChild(lishiNode);

    local lishitubiao = ccui.ImageView:create("geren/tubiao1.png");
    lishitubiao:setPosition(bgsize.width*0.04,43);
    lishiNode:addChild(lishitubiao);

    local lishi = ccui.ImageView:create("geren/jingcailishi.png");
    lishi:setPosition(bgsize.width*0.13,43);
    lishiNode:addChild(lishi);

    
    --历史查看
    local xiala = ccui.Button:create("geren/chankan.png","geren/chankan-on.png")
    xiala:setPosition(bgsize.width*0.93,43);
    lishiNode:addChild(xiala);
    xiala:onClick(handler(self,self.onClickBtnCallBack));
    xiala:setName("lishichakan")

    --金币明细
    local mingxibg = ccui.ImageView:create("geren/BGtiao.png");
    mingxibg:setPosition(bgsize.width*0.5,bgsize.height*0.47);
    pNode:addChild(mingxibg);

    local mxNode = cc.Node:create();
    mxNode:setPosition(139.5,0);
    mingxibg:addChild(mxNode);

    local mingxitubiao = ccui.ImageView:create("geren/tubiao2.png");
    mingxitubiao:setPosition(bgsize.width*0.04,43);
    mxNode:addChild(mingxitubiao);

    local mingxi = ccui.ImageView:create("geren/jinbimingxi.png");
    mingxi:setPosition(bgsize.width*0.13,43);
    mxNode:addChild(mingxi);
   
    --明细查看
    local mingxi = ccui.Button:create("geren/chankan.png","geren/chankan-on.png")
    mingxi:setPosition(bgsize.width*0.93,43);
    mxNode:addChild(mingxi);
    mingxi:onClick(handler(self,self.onClickBtnCallBack));
    mingxi:setName("mingxi")

    -- --更多
    -- local morebg = ccui.ImageView:create("zhuye/anniuBG.png");
    -- morebg:setAnchorPoint(0.5,1);
    -- morebg:setPosition(moreBtn:getPositionX(),moreBtn:getPositionY()+35);
    -- dingNode:addChild(morebg,10);
    -- local morebgsize = morebg:getContentSize();
    -- self.morebg = morebg;
    -- self.morebg:setVisible(false)

    --主页
    local zyBtn = ccui.Button:create("zhuye/zhuye.png","zhuye/zhuye-on.png","zhuye/zhuye-l.png")
    zyBtn:setPosition(670,dingSize.height/2);
    dingNode:addChild(zyBtn);
    -- zyBtn:addClickEventListener(function()self:delayCloseLayer();end);
    zyBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    zyBtn:setName("zhuye")

    --历史
    local lsBtn = ccui.Button:create("zhuye/lishi.png","zhuye/lishi-on.png","zhuye/lishi-l.png")
    lsBtn:setPosition(zyBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(lsBtn);
    -- lsBtn:addClickEventListener(function()self:delayCloseLayer();end);
    lsBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    lsBtn:setName("lishi")

    --情报
    local qbBtn = ccui.Button:create("zhuye/qingbao.png","zhuye/qingbao-on.png","zhuye/qingbao-l.png")
    qbBtn:setPosition(lsBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(qbBtn);
    -- qbBtn:addClickEventListener(function()self:delayCloseLayer();end);
    qbBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    qbBtn:setName("qingbao")

    --个人中心
    local grBtn = ccui.Button:create("zhuye/gerenzhongxin.png","zhuye/gerenzhongxin-on.png","zhuye/gerenzhongxin-l.png")
    grBtn:setPosition(qbBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(grBtn);
    -- grBtn:addClickEventListener(function()self:delayCloseLayer();end);
    grBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    grBtn:setName("gerenzhongxin")

    --竞猜
    local jingcaiBtn = ccui.Button:create("zhuye/dianjingjingcai.png","zhuye/dianjingjingcai-on.png","zhuye/dianjingjingcai-l.png")
    jingcaiBtn:setPosition(grBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(jingcaiBtn);
    jingcaiBtn:setName("jingcai")
    -- jingcaiBtn:addClickEventListener(function()self:delayCloseLayer();end);
    jingcaiBtn:newOnClick(handler(self,self.onClickBtnCallBack));

    grBtn:setEnabled(false);

    --返回大厅
    local fhBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fhBtn:setAnchorPoint(1,0.5);
    fhBtn:setPosition(1240,dingSize.height/2);
    dingNode:addChild(fhBtn);
    -- fhBtn:addClickEventListener(function()self:delayCloseLayer();end);
    fhBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    fhBtn:setName("fanhui")
   

end

function GerenInfoLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
    if name == "more" then
        self.morebg:setVisible(not self.morebg:isVisible())
    elseif name == "lishichakan" then
        self:addChild(require("competition.LishijingcaiLayer"):create(self.tableLayer));
    elseif name == "mingxi" then
        self:addChild(require("competition.JinbiMingxiLayer"):create(self.tableLayer));
    elseif name == "zhuye" then
        self.tableLayer:addChild(require("competition.MainLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "lishi" then
        self.tableLayer:addChild(require("competition.LishiLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "qingbao" then
        self.tableLayer:addChild(require("competition.QingbaoLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "jingcai" then
        self.tableLayer:addChild(require("competition.JingcaiLayer"):create(self.tableLayer,0));
        self:delayCloseLayer();
    elseif name == "gerenzhongxin" then

    elseif name == "fanhui" then
        self.tableLayer:ExitGame();
    end

end

function GerenInfoLayer:receiveRefreshScoreBank(data)
    local data = data._usedata
    if data then
        self.jinbinum:setText(goldConvert(data.i64WalletMoney))
        self.baoxianguinum:setText(goldConvertFour(data.i64BankMoney))
    end
end


return GerenInfoLayer

local BackTipLayer = class("BackTipLayer", BaseWindow)

function BackTipLayer:create()
	return BackTipLayer.new()
end

function BackTipLayer:ctor()
	self.super.ctor(self,0,true)
	self:initUI();
end

--初始化界面
function BackTipLayer:initUI()
	local bg = ccui.ImageView:create("sweetparty/gamescene_bg/sweetparty_kuang.png")
	bg:setPosition(winSize.width/2,winSize.height/2)
	self:addChild(bg)

	local bgSize = bg:getContentSize();

	--显示标题
	local title = ccui.ImageView:create("sweetparty/gamescene_bg/sweetparty_tishi.png")
	title:setPosition(bgSize.width/2,bgSize.height-50);
	bg:addChild(title)

	--关闭
	local closeBtn = ccui.Button:create("sweetparty_guanbi.png","sweetparty_guanbi-on.png","sweetparty_guanbi-on.png",UI_TEX_TYPE_PLIST)
	closeBtn:setPosition(bgSize.width-50,bgSize.height-50);
	bg:addChild(closeBtn);
	closeBtn:onClick(function()
		self:delayCloseLayer(0);
	end)

	--显示提示
	local tip = ccui.ImageView:create("sweetparty/gamescene_bg/sweetparty_exitzi.png")
	tip:setPosition(bgSize.width/2,bgSize.height/2+30);
	bg:addChild(tip)

	--按钮
	local fangqiBtn = ccui.Button:create("sweetparty/gamescene_bg/sweetparty_fangqi.png","sweetparty/gamescene_bg/sweetparty_fangqi-on.png","sweetparty/gamescene_bg/sweetparty_fangqi-on.png")
	fangqiBtn:setPosition(bgSize.width/2-200,110);
	bg:addChild(fangqiBtn);
	self.fangqiBtn = fangqiBtn;

	local baoliuBtn = ccui.Button:create("sweetparty/gamescene_bg/sweetparty_baoliu.png","sweetparty/gamescene_bg/sweetparty_baoliu-on.png","sweetparty/gamescene_bg/sweetparty_baoliu-on.png")
	baoliuBtn:setPosition(bgSize.width/2+200,110);
	bg:addChild(baoliuBtn);
	self.baoliuBtn = baoliuBtn;
end

function BackTipLayer:getGiveupbtn()
    return  self.fangqiBtn
end

function BackTipLayer:getSavebtn()
    return  self.baoliuBtn
end

return BackTipLayer
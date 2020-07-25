local LoadLayer = class("LoadLayer", BaseWindow)

function LoadLayer:create(callback)
	return LoadLayer.new(callback)
end

function LoadLayer:ctor(callback)
	self.super.ctor(self,0,true)

	self.callback = callback
end

--初始化界面
function LoadLayer:initUI()
	local sharedDirector = cc.Director:getInstance();
	local winSize = sharedDirector:getWinSize();
	local centerX = winSize.width / 2;
	local centerY = winSize.height / 2;

	local bg = ccui.ImageView:create("load/bg.png");
	bg:setPosition(centerX,centerY);
	self:addChild(bg);

	self.bg = bg

	local size = bg:getContentSize()

	local logo = ccui.ImageView:create("load/logo.png");
	logo:setPosition(size.width/2+70,size.height/5*3);
	bg:addChild(logo);

	local barBg = ccui.ImageView:create("load/linebackground.png");
	barBg:setPosition(size.width/2,150);
	bg:addChild(barBg);

	local loadingBar = ccui.LoadingBar:create("load/line.png");
	loadingBar:setPosition(size.width/2, 100);
	loadingBar:setPercent(0)
	bg:addChild(loadingBar);
	self.loadingBar = loadingBar;


	-- local text = FontConfig.createWithSystemFont("正在进入游戏",30,FontConfig.colorWhite);
	-- text:setPosition(size.width/2,100);
	-- bg:addChild(text);
	-- text:setTag(1);
	-- self.text = text;
end

function LoadLayer:onEnter()
	self:initUI()

	self.framesLen = 10
	self.alreadyLen = 0

	self.super.onEnter(self)
end

function LoadLayer:onEnterTransitionFinish()
	-- removeUnuseSkeletonAnimation()
	self.super.onEnterTransitionFinish(self)
	display.removeUnusedSpriteFrames()
	self:loadFrames()
end

function LoadLayer:loadFrames()
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");

	self.alreadyLen = self.alreadyLen + 1

	if self.alreadyLen == self.framesLen then
		self:updateprogram()
	else
		self:showMove(self.alreadyLen, self.framesLen)
	end

	performWithDelay(self, function() self:loadFrames() end, 0.1)
end

function LoadLayer:updateprogram()
	performWithDelay(self, function()
		luaPrint("资源加载完毕！！！")
		if self.callback then
			self.callback()
		end
		self:delayCloseLayer()
	end, 0.2)
end

function LoadLayer:showMove(finish, total)
	local per = finish/total
	if per > 1 then
		per = 1
	end

	per = per * 100

	-- self.text:setString("正在加载资源	"..math.ceil(per).."%")

	self:onDownloadProgess(finish, total)
end

function LoadLayer:onDownloadProgess(singleProgess, singleTotal)
	if singleProgess ~= singleTotal then
		local percent = singleProgess / singleTotal
		self.loadingBar:setPercent(math.ceil(percent * 100))
	else
		self.loadingBar:setPercent(100)
	end
end

return LoadLayer


-- local LoadLayer = class("LoadLayer", BaseWindow);

-- LOAD_DATA = 0;

-- function LoadLayer:scene(callback)
-- 	local layer = LoadLayer:create(callback);

-- 	local scene = display.newScene("Loadcene");
-- 	scene:addChild(layer);

-- 	return scene;
-- end

-- function LoadLayer:create(callback)
-- 	return LoadLayer.new(callback);
-- end

-- function LoadLayer:ctor(callback)
-- 	self.super.ctor(self,0,true);

-- 	if(LOAD_DATA == 1)then
-- 		self.loadTime = 0.05;
-- 	else
-- 		self.loadTime = 0.1;
-- 	end

-- 	self.callback = callback;

-- 	self:initData()
-- end

-- function LoadLayer:initData()
-- 	self.frames = {
-- 					"saoleihongbao/image/slhb_image1",
-- 					"saoleihongbao/image/slhb_image2",
-- 					"saoleihongbao/image/slhb_finger",
-- 					};

-- 	self.sounds = {
-- 					"saoleihongbao/sound/sound-get-gold.mp3",
					
				
-- 					}

-- 	self.musics = {
-- 					"saoleihongbao/sound/sound-bg.mp3",
-- 					}

-- 					--牛牛动画
-- 		local NiuniuAnim ={
-- 				-- name = "bairenpinshitexiao",
-- 				-- json = "saoleihongbao/anim/bairenpinshitexiao.json",
-- 				-- atlas = "saoleihongbao/anim/bairenpinshitexiao.atlas",
-- 		}
		



-- 	self.skeleton = {
-- 						{"slhb_feiqinzoushou", "saoleihongbao/anim/feiqinzoushou.json", "saoleihongbao/anim/feiqinzoushou.atlas"},
						
-- 					}

-- 	local format = {
-- 						cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
-- 					}
-- 	for k,v in pairs(self.frames) do
-- 		display.setTexturePixelFormat(v..".png", format[k]);
-- 	end
-- end

-- function LoadLayer:onEnter()

-- 	for k,v in pairs(self.frames) do
-- 		luaPrint("loadSpriteFrames:",v..".plist", v..".png");
-- 		display.loadSpriteFrames(v..".plist", v..".png");
		
-- 	end
	

-- 	self.framesLen = #self.frames + #self.sounds  + #self.musics;
-- 	self.alreadyLen = 0;

-- 	if sp.SkeletonAnimation.createFromCache then
-- 		self.framesLen = self.framesLen + #self.skeleton;
-- 	end
	
-- 	local sharedDirector = cc.Director:getInstance();
-- 	local winSize = sharedDirector:getWinSize();
-- 	local centerX = winSize.width / 2;
-- 	local centerY = winSize.height / 2;
	
-- 	local bg = ccui.ImageView:create();
-- 	bg:loadTexture("saoleihongbao/image/slhb_loadingbg.png",UI_TEX_TYPE_LOCAL);
-- 	bg:setPosition(centerX,centerY);
-- 	self:addChild(bg);
-- 	self.bg = bg;
	

	

-- 	local size = bg:getContentSize()

-- 	-- local shayu = ccui.ImageView:create();
-- 	-- shayu:loadTexture("slhb_loading_logo.png",UI_TEX_TYPE_PLIST);
-- 	-- shayu:setPosition(size.width/2,size.height/2+50);
-- 	-- bg:addChild(shayu);


-- 	-- local barBg = ccui.ImageView:create();
-- 	-- barBg:loadTexture("saoleihongbao/image/slhb_loading_linebackground.png",UI_TEX_TYPE_LOCAL);
-- 	-- barBg:setPosition(size.width/2,150);
-- 	-- bg:addChild(barBg);

-- 	-- local loadingBar = ccui.LoadingBar:create();
-- 	-- loadingBar:loadTexture("saoleihongbao/image/slhb_loading_line.png",UI_TEX_TYPE_LOCAL);
-- 	-- loadingBar:setPosition(size.width/2, 150);
-- 	-- loadingBar:setPercent(0)
-- 	-- bg:addChild(loadingBar);
-- 	-- self.loadingBar = loadingBar;

-- 	local barBg = ccui.ImageView:create("load/linebackground.png");
-- 	barBg:setPosition(size.width/2,150);
-- 	bg:addChild(barBg);

-- 	local loadingBar = ccui.LoadingBar:create("load/line.png");
-- 	loadingBar:setPosition(size.width/2, 150);
-- 	loadingBar:setPercent(0)
-- 	bg:addChild(loadingBar);
-- 	self.loadingBar = loadingBar;

-- 	local text = FontConfig.createWithSystemFont("正在加载资源.",30,FontConfig.colorGray);
-- 	text:setPosition(size.width/2,100);
-- 	bg:addChild(text);
-- 	text:setTag(1);
-- 	self.text = text;

-- end

-- function LoadLayer:onEnterTransitionFinish()
-- 	self.super.onEnterTransitionFinish(self)
-- 	display.removeUnusedSpriteFrames();
-- 	self:loadFrames();
-- 	self:checkLoad();
-- end

-- function LoadLayer:checkLoad()
-- 	performWithDelay(self, function() 
-- 		if self.alreadyLen <= 1 then
-- 			cc.Director:getInstance():getTextureCache():unbindAllImageAsync();
-- 			self.alreadyLen = 0;
-- 			self:loadFrames();
-- 			self:checkLoad();
-- 		end
-- 	 end,4);
-- end

-- function LoadLayer:onExit()
-- 	-- self.super.onExit(self);
-- end

-- function LoadLayer:loadFrames()
-- 	self.alreadyLen = self.alreadyLen + 1;

-- 	if self.alreadyLen <= #self.frames then
-- 		display.loadImage(self.frames[self.alreadyLen]..".png", function() self:loadPng(); end)
-- 	end
-- end

-- function LoadLayer:loadPng()
-- 	display.loadSpriteFrames(self.frames[self.alreadyLen]..".plist",self.frames[self.alreadyLen]..".png");
-- 	self:showMove(self.alreadyLen, self.framesLen);

-- 	if(self.alreadyLen == #self.frames)then
-- 		-- self:loadAramture();
-- 		self:loadSound();
-- 	else
-- 		self:loadFrames();
-- 	end
-- end

-- function LoadLayer:loadSound()
-- 	self.alreadyLen = self.alreadyLen + 1;

-- 	-- audio.preloadSound(self.sounds[self.alreadyLen - #self.frames])

-- 	self:showMove(self.alreadyLen, self.framesLen);

-- 	if self.alreadyLen == #self.frames+#self.sounds then
-- 		self:loadMusic();
-- 	else
-- 		performWithDelay(self, function() self:loadSound(); end,self.loadTime);
-- 	end
-- end


-- function LoadLayer:loadMusic()
-- 	self.alreadyLen = self.alreadyLen + 1;

-- 	-- audio.preloadMusic(self.musics[self.alreadyLen - #self.frames  - #self.sounds])

-- 	self:showMove(self.alreadyLen, self.framesLen);

-- 	if self.alreadyLen == #self.frames + #self.sounds + #self.musics then
-- 		self:loadSkeletonAnimation();
-- 	else
-- 		performWithDelay(self, function() self:loadMusic(); end,self.loadTime);
-- 	end
-- end

-- function LoadLayer:loadSkeletonAnimation()
-- 	if sp.SkeletonAnimation.createFromCache then
-- 		self.alreadyLen = self.alreadyLen + 1;
-- 		local sk = self.skeleton[self.alreadyLen - #self.frames - #self.sounds - #self.musics];
-- 		addSkeletonAnimation(sk[1],sk[2],sk[3]);
-- 		self:showMove(self.alreadyLen, self.framesLen);
-- 		if self.alreadyLen == self.framesLen then
-- 			self:updateprogram();
-- 		else
-- 			performWithDelay(self, function() self:loadSkeletonAnimation(); end,self.loadTime);
-- 		end
-- 	else
-- 		if self.alreadyLen == self.framesLen then
-- 			self:updateprogram();
-- 		end
-- 	end
-- end

-- function LoadLayer:updateprogram()
-- 	LOAD_DATA = 1
-- 	performWithDelay(self, function()
-- 		luaPrint("资源加载完毕！！！");
-- 		if self.callback then
-- 			self.callback();
-- 		end
-- 		self:delayCloseLayer(0);
-- 	end, 0.2)
-- end

-- function LoadLayer:showMove(finish, total)
-- 	local per = finish/total;
-- 	if per > 1 then
-- 		per = 1;
-- 	end

-- 	per = per * 100;

-- 	self.text:setString("正在加载资源	"..math.ceil(per).."%");

-- 	self:onDownloadProgess(finish, total);
-- end

-- function LoadLayer:onDownloadProgess(singleProgess, singleTotal)
-- 	if singleProgess ~= singleTotal then
-- 		local percent = singleProgess / singleTotal;
-- 		self.loadingBar:setPercent(math.ceil(percent * 100));
-- 	else
-- 		self.loadingBar:setPercent(100);
-- 	end
-- end

-- return LoadLayer

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

	self.bg = bg;
	local size = bg:getContentSize()

	local logo = ccui.ImageView:create("load/logo.png");
	logo:setPosition(size.width/2,size.height/5*3);
	bg:addChild(logo);

	local barBg = ccui.ImageView:create("load/linebackground.png");
	barBg:setPosition(size.width/2,150);
	bg:addChild(barBg);

	local loadingBar = ccui.LoadingBar:create("load/line.png");
	loadingBar:setPosition(size.width/2, 150);
	loadingBar:setPercent(0)
	bg:addChild(loadingBar);
	self.loadingBar = loadingBar;

	local text = FontConfig.createWithSystemFont("正在进入游戏",30,FontConfig.colorWhite);
	text:setPosition(size.width/2,100);
	bg:addChild(text);
	text:setTag(1);
	self.text = text;

end

function LoadLayer:onEnter()
	self:initUI()

	self.framesLen = 10
	self.alreadyLen = 0

	self.super.onEnter(self)
end

function LoadLayer:onEnterTransitionFinish()
	self.super.onEnterTransitionFinish(self)
	--removeUnuseSkeletonAnimation()
	display.removeUnusedSpriteFrames()
	self:loadFrames()
end

function LoadLayer:loadFrames()
	display.loadSpriteFrames("saoleihongbao/image/slhb_image1.plist","baijiale/slhb_image1.png")
	display.loadSpriteFrames("saoleihongbao/image/slhb_image2.plist","baijiale/slhb_image2.png")
	display.loadSpriteFrames("saoleihongbao/image/slhb_finger.plist","baijiale/slhb_finger.png")

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
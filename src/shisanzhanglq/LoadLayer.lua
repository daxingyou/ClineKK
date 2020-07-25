

local LoadLayer = class("LoadLayer", BaseWindow);


LOAD_DATA = 0;

function LoadLayer:scene(callback)
	local layer = LoadLayer:create(callback);

	local scene = display.newScene("Loadcene");
	scene:addChild(layer);

	return scene;
end

function LoadLayer:create(callback)
	return LoadLayer.new(callback);
end

function LoadLayer:ctor(callback)
	self.super.ctor(self,0,true);

	audio.stopMusic();
	if(LOAD_DATA == 1)then
		self.loadTime = 0.05;
	else
		self.loadTime = 0.1;
	end

	self.callback = callback;

	self:initData()
end

function LoadLayer:initData()
	self.frames = {
					"shisanzhanglq/cards/cards",
					};

	self.sounds = {
					"sound/daqiang3.mp3",
					-- "sound/flop.mp3",
					-- "sound/lose.mp3",
					-- "sound/ping.mp3",
					-- "sound/QuanLeiDa.mp3",
					-- "sound/start.mp3",
					-- "sound/win.mp3",
					-- "sound/M/common1.mp3",
					-- "sound/M/common2.mp3",
					-- "sound/M/common3.mp3",
					-- "sound/M/common4.mp3",
					-- "sound/M/common5.mp3",
					-- "sound/M/common6.mp3",
					-- "sound/M/common7.mp3",
					-- "sound/M/common8.mp3",
					-- "sound/M/common9.mp3",
					-- "sound/M/common10.mp3",
					-- "sound/M/daqiang1.mp3",
					-- "sound/M/special1.mp3",
					-- "sound/M/start_compare.mp3",
					-- "sound/M/teshu1.mp3",
					-- "sound/M/teshu2.mp3",
					-- "sound/M/teshu3.mp3",
					-- "sound/M/teshu4.mp3",
					-- "sound/M/teshu5.mp3",
					-- "sound/M/teshu6.mp3",
					-- "sound/M/teshu7.mp3",
					-- "sound/M/teshu8.mp3",

					-- "sound/W/common1.mp3",
					-- "sound/W/common2.mp3",
					-- "sound/W/common3.mp3",
					-- "sound/W/common4.mp3",
					-- "sound/W/common5.mp3",
					-- "sound/W/common6.mp3",
					-- "sound/W/common7.mp3",
					-- "sound/W/common8.mp3",
					-- "sound/W/common9.mp3",
					-- "sound/W/common10.mp3",
					-- "sound/W/daqiang1.mp3",
					-- "sound/W/special1.mp3",
					-- "sound/W/start_compare.mp3",
					-- "sound/W/teshu1.mp3",
					-- "sound/W/teshu2.mp3",
					-- "sound/W/teshu3.mp3",
					-- "sound/W/teshu4.mp3",
					-- "sound/W/teshu5.mp3",
					-- "sound/W/teshu6.mp3",
					-- "sound/W/teshu7.mp3",
					-- "sound/W/teshu8.mp3",
					}

	self.musics = {
					"sound/background.mp3",
					}

	self.skeleton = {
						{"shengli", "spine/shengli.json", "spine/shengli.atlas"},
						{"shibai", "spine/shibai.json", "spine/shibai.atlas"},
						{"pingju", "spine/pingju.json", "spine/pingju.atlas"},
						
						{"quanleida", "spine/quanleida.json", "spine/quanleida.atlas"},
						{"teshupai", "spine/teshupai.json", "spine/teshupai.atlas"},

						{"liuduiban", "specialAni/liuduiban.json", "specialAni/liuduiban.atlas"},
						{"qinglong", "specialAni/qinglong.json", "specialAni/qinglong.atlas"},
						{"sanfentianxia", "specialAni/sanfentianxia.json", "specialAni/sanfentianxia.atlas"},
						{"sanshunzi", "specialAni/sanshunzi.json", "specialAni/sanshunzi.atlas"},
						{"santonghua", "specialAni/santonghua.json", "specialAni/santonghua.atlas"},
						{"santonghuashun", "specialAni/santonghuashun.json", "specialAni/santonghuashun.atlas"},
						{"sitaosantiao", "specialAni/sitaosantiao.json", "specialAni/sitaosantiao.atlas"},
						{"yitiaolong", "specialAni/yitiaolong.json", "specialAni/yitiaolong.atlas"},
					}

	local format = {
						cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
						cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
						cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
					}
	for k,v in pairs(self.frames) do
		display.setTexturePixelFormat(v..".png", format[k]);
	end
end

function LoadLayer:onEnter()
	self.framesLen = #self.frames + #self.sounds  + #self.musics;
	self.alreadyLen = 0;

	if sp.SkeletonAnimation.createFromCache then
		self.framesLen = self.framesLen + #self.skeleton;
	end
	
	local sharedDirector = cc.Director:getInstance();
	local winSize = sharedDirector:getWinSize();
	local centerX = winSize.width / 2;
	local centerY = winSize.height / 2;

	local bg = ccui.ImageView:create("bg/loadbg.jpg");
	-- bg:loadTexture("loadbg.png",UI_TEX_TYPE_PLIST);
	bg:setPosition(centerX,centerY);
	self:addChild(bg);
	self.bg = bg

	local size = bg:getContentSize()
	
	local word = ccui.ImageView:create("bg/word.png");
	-- shayu:loadTexture("logo.png",UI_TEX_TYPE_PLIST);
	word:setPosition(size.width/2,180);
	bg:addChild(word);

	local hua = ccui.ImageView:create("bg/hua.png");
	-- shayu:loadTexture("logo.png",UI_TEX_TYPE_PLIST);
	hua:setPosition(size.width/2, 240);
	bg:addChild(hua);

	local barBg = ccui.ImageView:create("bg/linebackground.png");
	-- barBg:loadTexture("linebackground.png",UI_TEX_TYPE_PLIST);
	barBg:setPosition(size.width/2,150);
	bg:addChild(barBg);

	local loadingBar = ccui.LoadingBar:create("bg/line.png");
	-- loadingBar:loadTexture("line.png",UI_TEX_TYPE_PLIST);
	loadingBar:setPosition(size.width/2, 150);
	loadingBar:setPercent(0)
	bg:addChild(loadingBar);
	self.loadingBar = loadingBar;

	local text = FontConfig.createWithSystemFont("正在加载资源.",30,FontConfig.colorGray);
	text:setPosition(size.width/2,100);
	bg:addChild(text);
	text:setTag(1);
	self.text = text;

end

function LoadLayer:onEnterTransitionFinish()
	self.super.onEnterTransitionFinish(self)
	display.removeUnusedSpriteFrames();
	self:loadFrames();
	self:checkLoad();
end

function LoadLayer:checkLoad()
	performWithDelay(self, function() 
		if self.alreadyLen <= 1 then
			cc.Director:getInstance():getTextureCache():unbindAllImageAsync();
			self.alreadyLen = 0;
			self:loadFrames();
			self:checkLoad();
		end
	 end,4);
end

function LoadLayer:onExit()
	-- self.super.onExit(self);
end

function LoadLayer:loadFrames()
	self.alreadyLen = self.alreadyLen + 1;

	if self.alreadyLen <= #self.frames then
		display.loadImage(self.frames[self.alreadyLen]..".png", function() self:loadPng(); end)
	end
end

function LoadLayer:loadPng()
	display.loadSpriteFrames(self.frames[self.alreadyLen]..".plist",self.frames[self.alreadyLen]..".png");
	self:showMove(self.alreadyLen, self.framesLen);

	if(self.alreadyLen == #self.frames)then
		-- self:loadAramture();
		self:loadSound();
	else
		self:loadFrames();
	end
end

function LoadLayer:loadSound()
	self.alreadyLen = self.alreadyLen + 1;

	audio.preloadSound(self.sounds[self.alreadyLen - #self.frames])

	self:showMove(self.alreadyLen, self.framesLen);

	if self.alreadyLen == #self.frames+#self.sounds then
		self:loadMusic();
	else
		performWithDelay(self, function() self:loadSound(); end,self.loadTime);
	end
end


function LoadLayer:loadMusic()
	self.alreadyLen = self.alreadyLen + 1;

	-- audio.preloadMusic(self.musics[self.alreadyLen - #self.frames  - #self.sounds])

	self:showMove(self.alreadyLen, self.framesLen);

	if self.alreadyLen == #self.frames + #self.sounds + #self.musics then
		self:loadSkeletonAnimation();
	else
		performWithDelay(self, function() self:loadMusic(); end,self.loadTime);
	end
end

function LoadLayer:loadSkeletonAnimation()
	if sp.SkeletonAnimation.createFromCache then
		self.alreadyLen = self.alreadyLen + 1;
		local sk = self.skeleton[self.alreadyLen - #self.frames - #self.sounds - #self.musics];
		addSkeletonAnimation(sk[1],sk[2],sk[3]);
		self:showMove(self.alreadyLen, self.framesLen);
		if self.alreadyLen == self.framesLen then
			self:updateprogram();
		else
			performWithDelay(self, function() self:loadSkeletonAnimation(); end,self.loadTime);
		end
	else
		if self.alreadyLen == self.framesLen then
			self:updateprogram();
		end
	end
end

function LoadLayer:updateprogram()
	LOAD_DATA = 1
	performWithDelay(self, function()
		luaPrint("资源加载完毕！！！");
		if self.callback then
			self.callback();
		end
		self:delayCloseLayer(0);
	end, 0.2)
end

function LoadLayer:showMove(finish, total)
	local per = finish/total;
	if per > 1 then
		per = 1;
	end

	per = per * 100;

	self.text:setString("正在加载资源	"..math.ceil(per).."%");

	self:onDownloadProgess(finish, total);
end

function LoadLayer:onDownloadProgess(singleProgess, singleTotal)
	if singleProgess ~= singleTotal then
		local percent = singleProgess / singleTotal;
		self.loadingBar:setPercent(math.ceil(percent * 100));
	else
		self.loadingBar:setPercent(100);
	end
end

return LoadLayer
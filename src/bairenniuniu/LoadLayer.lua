

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
					"bairenniuniu/image/brnn_img",
					"bairenniuniu/image/brnn_jetton",
					-- "bairenniuniu/image/brnn_bg",
					"bairenniuniu/image/card",
					-- "bairenniuniu/image/brnn_paizhuo_bg",
					};

	self.sounds = {
					"bairenniuniu/sound/sound-bethigh.mp3",
					"bairenniuniu/sound/sound-betlow.mp3",
					"bairenniuniu/sound/sound-button.mp3",
					-- "bairenniuniu/sound/sound-close.mp3",
					-- "bairenniuniu/sound/sound-countdown.mp3",
					-- "bairenniuniu/sound/sound-end-wager.mp3",
					-- "bairenniuniu/sound/sound-fanpai.mp3",
					-- "bairenniuniu/sound/sound-fapai.mp3",
					-- "bairenniuniu/sound/sound-get-gold.mp3",
					-- "bairenniuniu/sound/sound-gold.wav",
					-- "bairenniuniu/sound/sound-jetton.mp3",
					-- "bairenniuniu/sound/sound-result-lose.mp3",
					-- "bairenniuniu/sound/sound-result-nobet.mp3",
					-- "bairenniuniu/sound/sound-result-win.mp3",
					-- "bairenniuniu/sound/sound-sendcard.mp3",
					-- "bairenniuniu/sound/sound-start-wager.mp3",
					-- "bairenniuniu/sound/zhuang-1.mp3",
					-- "bairenniuniu/sound/zhuang-2.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_0.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_1.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_2.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_3.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_4.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_5.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_6.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_7.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_8.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_9.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_10.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_11.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_12.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_13.mp3",
					-- "bairenniuniu/sound/NiuSpeak_W/cow_14.mp3",
					}

	self.musics = {
					"bairenniuniu/sound/sound-bg.mp3",
					}

					--牛牛动画
		local NiuniuAnim ={
				name = "bairenpinshitexiao",
				json = "bairenniuniu/anim/bairenpinshitexiao.json",
				atlas = "bairenniuniu/anim/bairenpinshitexiao.atlas",
		}

		--赢 动画
		local WinAnim ={
				name = "ying",
				json = "bairenniuniu/anim/ying.json",
				atlas = "bairenniuniu/anim/ying.atlas",
		}

		--游戏开始下注动画
		local StartAnim = {
			-- name = "kaishixiazhu",
			-- json = "bairenniuniu/anim/kaishixiazhu.json",
			-- atlas = "bairenniuniu/anim/kaishixiazhu.atlas",
		}

		--倒计时警告动画
		local WarnAnim = {
			name = "daojishi",
			json = "game/daojishi/daojishi.json",
			atlas = "game/daojishi/daojishi.atlas",
		}

		--庄家变换 停止下注，请等待下一局等提示
		local TipAnim = {
			name = "feiqinzoushou",
			json = "game/feiqinzoushou.json",
			atlas = "game/feiqinzoushou.atlas",
		}




	self.skeleton = {
						{"brnn_feiqinzoushou", "bairenniuniu/anim/feiqinzoushou.json", "bairenniuniu/anim/feiqinzoushou.atlas"},
						-- {WinAnim.name, WinAnim.json, WinAnim.atlas},
						
						-- {WarnAnim.name,WarnAnim.json.WarnAnim.atlas},
						-- {TipAnim.name,TipAnim.json.TipAnim.atlas},
						-- {NiuniuAnim.name,NiuniuAnim.json.NiuniuAnim.atlas},
						
					}

	local format = {
						cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
					}
	for k,v in pairs(self.frames) do
		display.setTexturePixelFormat(v..".png", format[k]);
	end
end

function LoadLayer:onEnter()

	for k,v in pairs(self.frames) do
		luaPrint("loadSpriteFrames:",v..".plist", v..".png");
		display.loadSpriteFrames(v..".plist", v..".png");
		
	end
	

	self.framesLen = #self.frames + #self.sounds  + #self.musics;
	self.alreadyLen = 0;

	if sp.SkeletonAnimation.createFromCache then
		self.framesLen = self.framesLen + #self.skeleton;
	end
	
	local sharedDirector = cc.Director:getInstance();
	local winSize = sharedDirector:getWinSize();
	local centerX = winSize.width / 2;
	local centerY = winSize.height / 2;
	
	local bg = ccui.ImageView:create();
	bg:loadTexture("bairenniuniu/image/brnn_loadingbg.png",UI_TEX_TYPE_LOCAL);
	bg:setPosition(centerX,centerY);
	self:addChild(bg);
	self.bg = bg;
	

	

	local size = bg:getContentSize()

	local shayu = ccui.ImageView:create();
	shayu:loadTexture("brnn_loading_logo.png",UI_TEX_TYPE_PLIST);
	shayu:setPosition(size.width/2,size.height/2+50);
	bg:addChild(shayu);


	local barBg = ccui.ImageView:create();
	barBg:loadTexture("brnn_loading_linebackground.png",UI_TEX_TYPE_PLIST);
	barBg:setPosition(size.width/2,150);
	bg:addChild(barBg);

	local loadingBar = ccui.LoadingBar:create();
	loadingBar:loadTexture("brnn_loading_line.png",UI_TEX_TYPE_PLIST);
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

	-- audio.preloadSound(self.sounds[self.alreadyLen - #self.frames])

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

	-- self.text:setString("正在加载资源	"..math.ceil(per).."%");

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
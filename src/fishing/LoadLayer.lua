local LoadLayer = class("LoadLayer", BaseWindow);

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

	self.loadTime = 0.01;

	self.callback = callback;

	self:initData()
end

function LoadLayer:initData()
	self.frames = {
					"fishing/fishing/fish/boss2",
					"fishing/fishing/fish/boss",
					"fishing/fishing/fish/boss1",
					"fishing/fishing/fort",
					"fishing/fishing/fish/fish_test4",
					"fishing/fishing/fish/fish_test3",
					"fishing/fishing/fish/fish_test2",
					"fishing/fishing/fish/fish_test1",
					"fishing/fishing/game/gamefish",
					"fishing/fishing/scene/gold",
					"fishing/fishing/scene/other_gold"
					};

	self.ArmatureList = {
						"effect/dabaoza/eff_kill_dayu",
						"effect/zhuanfanle/eff_get_money",
						"fishEffect/eff_bingdong",
						"effect/click_effect/eff_bowen",
						"fishEffect/eff_shuaidaile",
						"effect/xiaobaoza/eff_kill_dabaozha",
						"effect/zhuanpan/eff_zhuanpan",
						}

	-- self.sounds = {
	-- 				"sound/cannon.mp3",
	-- 				"sound/coin.mp3",
	-- 				"sound/deay_coin.mp3",
	-- 				"sound/ding_marry.mp3",
	-- 				"sound/fire.mp3",
	-- 				"sound/fish10_1.mp3",
	-- 				"sound/fish10_2.mp3",
	-- 				"sound/fish11_1.mp3",
	-- 				"sound/fish11_2.mp3",
	-- 				"sound/fish12_1.mp3",
	-- 				"sound/fish12_2.mp3",
	-- 				"sound/fish13_1.mp3",
	-- 				"sound/fish13_2.mp3",
	-- 				"sound/fish14_1.mp3",
	-- 				"sound/fish14_2.mp3",
	-- 				"sound/fish15_1.mp3",
	-- 				"sound/fish15_2.mp3",
	-- 				"sound/fish16_1.mp3",
	-- 				"sound/fish16_2.mp3",
	-- 				"sound/fish17_1.mp3",
	-- 				"sound/fish17_2.mp3",
	-- 				"sound/fish17_3.mp3",
	-- 				"sound/gun_up.mp3",
	-- 				"sound/rolling.mp3",
	-- 				"sound/sound_coin.mp3",
	-- 				"sound/wave.mp3",
	-- 				"sound/boss/boss41_1.mp3",
	-- 				"sound/boss/boss41_2.mp3",
	-- 				"sound/boss/boss41_3.mp3",
	-- 				"sound/boss/boss42_1.mp3",
	-- 				"sound/boss/boss42_2.mp3",
	-- 				"sound/boss/boss42_3.mp3",
	-- 				"sound/boss/boss43_1.mp3",
	-- 				"sound/boss/boss43_2.mp3",
	-- 				"sound/boss/boss43_3.mp3",
	-- 				"sound/boss/boss44_1.mp3",
	-- 				"sound/boss/boss44_2.mp3",
	-- 				"sound/boss/boss44_3.mp3",
	-- 				"sound/boss/jingbao.mp3",
	-- 				}

	-- self.musics = {
	-- 				"sound/bg1.mp3",
	-- 				"sound/bg2.mp3",
	-- 				"sound/bg3.mp3",
	-- 				"sound/bg4.mp3",
	-- 				"sound/boss/bossbg.mp3"
	-- 				}

	self.skeleton = {
						{"fire", "cannon/fire.json", "cannon/fire.atlas"},
						{"kuangbaozhaohuan","goods/skill/kuangbaozhaohuan.json", "goods/skill/kuangbaozhaohuan.atlas"},
						{"jubuzhadan","effect/jububaozha/jubuzhadan.json", "effect/jububaozha/jubuzhadan.atlas"},
						{"kapai","goods/kapai.json", "goods/kapai.atlas"},
						{"game/effect/gongxihuode","game/effect/gongxihuode.json", "game/effect/gongxihuode.atlas"},
						{"zadan","game/effect/zadan.json", "game/effect/zadan.atlas"},
						{"zadanjiemian","game/effect/zadanjiemian.json", "game/effect/zadanjiemian.atlas"},
						{"huodenengliangpao","energycannon/huodenengliangpao/huodenengliangpao.json", "energycannon/huodenengliangpao/huodenengliangpao.atlas"},
						{"zaixianjiangli","hall/relief/zaixianjiangli.json", "hall/relief/zaixianjiangli.atlas"},
						{"buyuzhuanpan","game/effect/buyuzhuanpan.json", "game/effect/buyuzhuanpan.atlas"},
						{"hongbaojiqi","game/effect/hongbaojiqi.json", "game/effect/hongbaojiqi.atlas"},
						{"yaoqianshu","game/effect/yaoqianshu.json", "game/effect/yaoqianshu.atlas"},
						{"shouzhi","game/effect/shouzhi.json", "game/effect/shouzhi.atlas"},
						{"coin_hou","game/effect/coin_hou.json", "game/effect/coin_hou.atlas"},
						{"coin-qian","game/effect/coin-qian.json", "game/effect/coin-qian.atlas"},
						{"shuibobeijing_0","scene/water/shuibobeijing_0.25.json", "scene/water/shuibobeijing_0.25.atlas"},
						{"yidaboyu","scene/yidaboyu/yidaboyu.json", "scene/yidaboyu/yidaboyu.atlas"},
						{"shengji","game/shengji/shengji.json", "game/shengji/shengji.atlas"},
						{"bosschuchang","boosWaring/bosschuchang.json", "boosWaring/bosschuchang.atlas"},
						{"bosstaopao","boosWaring/bosstaopao/bosstaopao.json", "boosWaring/bosstaopao/bosstaopao.atlas"},
						{"heidongyu","fish/heidongyu.json", "fish/heidongyu.atlas"},
						{"baozha", "effect/baozha/baozha.json", "effect/baozha/baozha.atlas"},
						{"siwangtexiao", "fishing/fishdead/siwangtexiao.json", "fishing/fishdead/siwangtexiao.atlas"}
					}

	local format = {cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
					cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444,
				}
	for k,v in pairs(self.frames) do
		display.setTexturePixelFormat(v..".png", format[k]);
	end
end

function LoadLayer:onEnter()
	-- self.framesLen = #self.frames + #self.sounds + #self.ArmatureList + #self.musics;
	self.framesLen = #self.frames + #self.ArmatureList;
	self.alreadyLen = 0;

	if sp.SkeletonAnimation.createFromCache then
		self.framesLen = self.framesLen + #self.skeleton;
	end

	local sharedDirector = cc.Director:getInstance();
	local winSize = sharedDirector:getWinSize();
	local centerX = winSize.width / 2;
	local centerY = winSize.height / 2;

	local bg = ccui.ImageView:create("platform/bg.png");
	bg:setPosition(centerX,centerY);
	self:addChild(bg);
	self.bg = bg

	local size = bg:getContentSize()

	local skeleton_animation = createSkeletonAnimation("likuipiyubeijing", "platform/buyu/likuipiyubeijing.json", "platform/buyu/likuipiyubeijing.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(size.width/2,size.height/2)
		skeleton_animation:setAnimation(2,"likuipiyubeijing", true);
		bg:addChild(skeleton_animation);
	end

	local shayu = ccui.ImageView:create("load/shayu.png");
	shayu:setPosition(size.width/2,size.height/2+50);
	bg:addChild(shayu);

	local move = cc.MoveBy:create(1,cc.p(0,50));
	local seq = cc.Sequence:create(move, move:reverse(),cc.DelayTime:create(0.5));
	shayu:runAction(cc.RepeatForever:create(seq));

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

	local emitter1 = cc.ParticleSystemQuad:create("platform/buyu/qipao/qipao.plist");
	emitter1:setAutoRemoveOnFinish(true);		--设置播放完毕之后自动释放内存	 
	emitter1:setPosition(cc.p(size.width/2, centerY));
	emitter1:setLocalZOrder(0);
	self:addChild(emitter1);
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
		self:loadAramture();
	else
		self:loadFrames();
	end
end

function LoadLayer:loadSound()
	self.alreadyLen = self.alreadyLen + 1;

	audio.preloadSound(self.sounds[self.alreadyLen - #self.frames - #self.ArmatureList])

	self:showMove(self.alreadyLen, self.framesLen);

	if self.alreadyLen == #self.frames+#self.ArmatureList+#self.sounds then
		self:loadMusic();
	else
		performWithDelay(self, function() self:loadSound(); end,self.loadTime);
	end
end

function LoadLayer:loadAramture()
	self.alreadyLen = self.alreadyLen + 1;
	addArmature(self.ArmatureList[self.alreadyLen - #self.frames].."0.png",
				self.ArmatureList[self.alreadyLen - #self.frames].."0.plist",
				self.ArmatureList[self.alreadyLen - #self.frames]..".ExportJson");
	self:showMove(self.alreadyLen, self.framesLen);

	if self.alreadyLen == #self.frames+#self.ArmatureList then
		-- self:loadSound();
		self:loadSkeletonAnimation();
	else
		performWithDelay(self, function() self:loadAramture(); end,self.loadTime);
	end
end

function LoadLayer:loadMusic()
	self.alreadyLen = self.alreadyLen + 1;

	-- audio.preloadMusic(self.musics[self.alreadyLen - #self.frames - #self.ArmatureList - #self.sounds])

	self:showMove(self.alreadyLen, self.framesLen);

	if self.alreadyLen == #self.frames + #self.sounds + #self.ArmatureList + #self.musics then
		self:loadSkeletonAnimation();
	else
		performWithDelay(self, function() self:loadMusic(); end,self.loadTime);
	end
end

function LoadLayer:loadSkeletonAnimation()
	if sp.SkeletonAnimation.createFromCache then
		self.alreadyLen = self.alreadyLen + 1;
		local sk = self.skeleton[self.alreadyLen - #self.frames - #self.ArmatureList]-- - #self.sounds - #self.musics];
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
	performWithDelay(self, function()
		luaPrint("资源加载完毕！！！");
		if self.callback then
			self.callback();
		end
		self:delayCloseLayer()
	end, 0.02)
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
local FishPath = class("FishPath")
local _fishGroup = nil;
local FishPathType={
	FISH_PATHTYPE_A = 1,
	FISH_PATHTYPE_B = 2,
	FISH_PATHTYPE_C = 3,
	FISH_PATHTYPE_D = 4,
	FISH_PATHTYPE_E = 5,
	FISH_PATHTYPE_STATIC = 6
}
function FishPath:getInstance()
	if _fishGroup == nil then
		_fishGroup = FishPath.new();
	end
	return _fishGroup;
end
local randomFakeSeed =1;
function FishPath:ctor()
end

function FishPath:createFishPath(fish, path, groupIndex, topFish,isSpec)
	-- local pathType=self:getFishPathType(fish._fishtype)
	--鱼的类型和路径编号
	self._path=path;
	randomFakeSeed=self._path*fish._fishType;

	if isSpec then
		self:generateFishPathSpec(fish,groupIndex)
		return;
	end

	local r=FishPath:fakeRandom( 0, 371 )%100;

	if fish._fishType<=2 then
		if(r<=20)then
			self:generateFishPathA(fish,groupIndex);--斜对角
			fish.pathid = "A";
		elseif(r<=20+15)then
			self:generateFishPathC(fish,groupIndex);--水平
			fish.pathid = "C";
		elseif(r<=35+5)then
			self:generateFishPathB(fish,groupIndex);--buttom出现屏幕中间转圈左边出去
			fish.pathid = "B";
		elseif(r<=40+10)then
			 self:generateFishPathF(fish,groupIndex);--屏幕上下方出现 转两圈出去
			 fish.pathid = "F";
		elseif(r<=55+10)then
			self:generateFishPathE(fish,groupIndex);--屏幕两边出现屏幕中间转圈
			fish.pathid = "E";
		elseif r<=75 then
			self:generateFishPathQ(fish, groupIndex);
			fish.pathid = "Q";
		else
			self:generateFishPathP(fish,groupIndex);--屏幕上下方出现 转两圈出去
			fish.pathid = "P";
		end
	elseif fish._fishType<=8 then --13
		if(r<=25)then
			self:generateFishPathA(fish,groupIndex);
			fish.pathid = "A";
		elseif(r<=25+25)then
			self:generateFishPathB(fish,groupIndex);--近似水平
			fish.pathid = "B";
		elseif(r<=35+15)then
			self:generateFishPathB(fish,groupIndex);	
			fish.pathid = "P";
		elseif(r<=50+25)then
			self:generateFishPathC(fish,groupIndex);
			fish.pathid = "C";
		elseif r<=75+15 then
			self:generateFishPathF(fish,groupIndex);
			fish.pathid = "F";
		elseif r<=110 then
			self:generateFishPathQ(fish, groupIndex);
			fish.pathid = "Q";
		else
			self:generateFishPathE(fish,groupIndex);
			fish.pathid = "E";
		end
	elseif fish._fishType<15 then
		if(r<=20)then
			self:generateFishPathA(fish,groupIndex);
			fish.pathid = "A";
		elseif(r<=20+20)then
			self:generateFishPathB(fish,groupIndex);
			fish.pathid = "B";
		elseif r<=40+10 then
			self:generateFishPathF(fish,groupIndex);
			fish.pathid = "F";
		elseif r<=90 then
			self:generateFishPathE(fish,groupIndex); 
			fish.pathid = "E";
		elseif r<=110 then
			self:generateFishPathQ(fish, groupIndex);
			fish.pathid = "Q";
		else
			self:generateFishPathC(fish,groupIndex);
			fish.pathid = "C";
		end
	elseif fish._fishType <= 24 then
		if r < 30 then
			self:generateFishPathB(fish, groupIndex);
			fish.pathid = "B";
		else
			self:generateFishPathJ(fish, groupIndex);
			fish.pathid = "J";
		end
	-- elseif fish._fishType  == 21 then
	-- 	if r < 30 then
	-- 		fish.pathid = "k";
	-- 		self:generateFishPathK(fish, groupIndex);
	-- 	elseif r < 60 then
	-- 		fish.pathid = "L";
	-- 		self:generateFishPathL(fish, groupIndex);
	-- 	else
	-- 		fish.pathid = "T";
	-- 		self:generateFishPathT(fish, groupIndex);
	-- 	end
	elseif fish._fishType <= 30 then
		if r < 30 then
			self:generateFishPathB(fish, groupIndex);
			fish.pathid = "B";
		elseif r < 60 then
			fish.pathid = "R";
			self:generateFishPathR(fish, groupIndex);
		else
			fish.pathid = "S";
			self:generateFishPathS(fish, groupIndex);
		end
	elseif fish._fishType <= 40 then
		if r < 20 then
			self:generateFishPathB(fish, groupIndex);
			fish.pathid = "B";
		elseif r < 30 then
			self:generateFishPathA(fish, groupIndex);
			fish.pathid = "A";
		elseif r < 40 then
			fish.pathid = "R";
			self:generateFishPathR(fish, groupIndex);
		elseif r < 50 then
			fish.pathid = "S";
			self:generateFishPathS(fish, groupIndex);
		else
			self:generateFishPathJ(fish, groupIndex);
			fish.pathid = "J";
		end
	elseif fish._fishType <= 42 or fish._fishType == 44 then
		if r < 30 then
			fish.pathid = "k";
			self:generateFishPathK(fish, groupIndex);
		elseif r < 60 then
			fish.pathid = "L";
			self:generateFishPathL(fish, groupIndex);
		else
			fish.pathid = "T";
			self:generateFishPathT(fish, groupIndex);
		end
	elseif fish._fishType == 43 then
		fish.pathid = "T";
		self:generateFishPathT(fish, groupIndex);
    elseif fish._fishType <= 58 then
        if r < 20 then
            self:generateFishPathB(fish, groupIndex);
            fish.pathid = "B";
        elseif r < 30 then
            self:generateFishPathA(fish, groupIndex);
            fish.pathid = "A";
        elseif r < 40 then
            fish.pathid = "R";
            self:generateFishPathR(fish, groupIndex);
        elseif r < 50 then
            fish.pathid = "S";
            self:generateFishPathS(fish, groupIndex);
        else
            self:generateFishPathJ(fish, groupIndex);
            fish.pathid = "J";
        end
    elseif fish._fishType >= 67 and fish._fishType <= 71 then
    	self:generateFishPathCC(fish,groupIndex);--水平
		fish.pathid = "C";
	else
		self:generateFishPathJ(fish,groupIndex);--四个角落随机出来
		fish.pathid = "J";
	end
end

function FishPath:createCallFishPath(fish, path, startPos)
	local size = cc.Director:getInstance():getWinSize();

	self._path=path;
	randomFakeSeed=self._path*fish._fishType;

	local endPos = {};
	local midPos = {};
	
	local rect = cc.rect(0,size.height*0.4,size.width,size.height*0.6);
	local rect1 = cc.rect(0,0,size.width/2,size.height/2);
	local rect2 = cc.rect(0,size.height/2,size.width/2,size.height/2);
	local rect3 = cc.rect(size.width/2,0,size.width/2,size.height/2);
	local rect4 = cc.rect(size.width/2,size.height/2,size.width/2,size.height/2);
	local str = ""
	-- local l = cc.pGetLength(startPos, cc.p(size.width/2,size.height/2));
	-- if l < 200 then
	--	 -- if startPox.y > size.heigth/2 then
	--	 --	 endPos.x = ;
	--	 --	 endPos.y = ;
	--	 -- elseif startPox.y < size.heigth/2 then
	--	 --	 --todo
	--	 -- else

	--	 -- end
	-- else
		-- if cc.rectContainsPoint(rect, startPos) then
		--	 if startPos.x < size.width/2 then
		--		 endPos.x =  FishPath:fakeRandom(0,74584)%size.width/2+size.width;
		--		 endPos.y =  FishPath:fakeRandom(0,74584)%size.height*2-size.height;
		--		 fish:setFlipRotate(false);
		--		 str =("左边  居中")
		--	 else
		--		 endPos.x =  -math.abs(FishPath:fakeRandom(0,74584)%size.width);
		--		 endPos.y =  FishPath:fakeRandom(0,74584)%size.height*2-size.height;
		--		 fish:setFlipRotate(true);
		--		 str =("右边  居中")
		--	 end
		-- else
		if cc.rectContainsPoint(rect1, startPos) then--左下
			endPos.x =  FishPath:fakeRandom(0,74584)%size.width+size.width;
			endPos.y =  math.abs(FishPath:fakeRandom(0,74584)%(size.height*2))+size.height/4;
			fish:setFlipRotate(false);
			str =("左下  -------")
		elseif cc.rectContainsPoint(rect2, startPos) then--左上
			endPos.x =  math.abs(FishPath:fakeRandom(0,74584)%size.width)+size.width;
			endPos.y =  math.abs(FishPath:fakeRandom(0,74584)%(size.height*2))-size.height;
			fish:setFlipRotate(false);
			str =("左上 --------")
		elseif cc.rectContainsPoint(rect3, startPos) then--右下
			endPos.x =  -math.abs(FishPath:fakeRandom(0,74584)%size.width)-size.width;
			endPos.y =  FishPath:fakeRandom(0,74584)%(size.height*2)+size.height/4;
			fish:setFlipRotate(true);
			str =("右下  ----------")
		elseif cc.rectContainsPoint(rect4, startPos) then--右上
			endPos.x =  -math.abs(FishPath:fakeRandom(0,74584)%size.width)-size.width;
			endPos.y =  -math.abs(FishPath:fakeRandom(0,74584)%(size.height*2))+size.height;
			fish:setFlipRotate(true);
			str =("右上 -------")
		else
			endPos.x =  -math.abs(FishPath:fakeRandom(0,74584)%size.width)-size.width;
			endPos.y =  -math.abs(FishPath:fakeRandom(0,74584)%(size.height*2))+size.height;
			fish:setFlipRotate(true);
		end

		-- luaDump(endPos,"endPos")
		midPos=FishPath:getMDCurvePointRate( cc.p(startPos.x, startPos.y), cc.p(endPos.x, endPos.y),0.1,false);
		-- luaDump(midPos,"midPos")
		local rd = FishPath:fakeRandom(math.ceil(os.time()/CALLFISH_SKILL_CD_TIME),math.ceil(os.time()/30))%2;

		local point = {startPos,endPos};

		if rd == 1 then
			point = {startPos,midPos,endPos};
		end

		luaPrint("rd ----- "..rd);
		fish:setVisible(false);
		if fish.fishShadow then
			fish.fishShadow:setVisible(false);
		end
		fish.isCallFish = true;
		self:createServerFishPath(fish,rd,point,20000);
	-- end	
end

function FishPath:createServerFishPath(fish, pathType, points, dt)
	luaDump(points,"points")
	if pathType == 0 then
		self:createLinePath(fish, points, dt);
	else
		self:createBezierPath(fish, points, dt);
	end
end

function FishPath:createLinePath(fish, points, dt)
	fish._fishPath={};

	local newpos = cc.p(points[1].x,points[1].y);

	if dt < 20000 then
		local delay = cc.DelayTime:create(dt);

		table.insert(fish._fishPath, delay);
	else
		local k = (points[1].y - points[#points].y)/(points[1].x-points[#points].x);
		local b = points[1].y-k*points[1].x;
		local x = points[1].x+5;
		local y = k*x+b;
		newpos = cc.p(x,y);

		if points[1].y == points[#points].y then
			newpos.y = 0;
		end

		if points[1].x < points[#points].x then
			x = points[1].x-5;
			local y = k*x+b;
			newpos = cc.p(x,y);

			if points[1].y == points[#points].y then
				newpos.y = 0;
			end
		end

		local dt = 0.2;

		if FishManager:getGameLayer()._isFrozen == true then
			dt = 0.2
		end

		table.insert(fish._fishPath,cc.MoveTo:create(dt,points[1]));
		table.insert(fish._fishPath,cc.CallFunc:create(function()
			fish:setVisible(true); 
			if fish.fishShadow then
				fish.fishShadow:setVisible(true);
			end

			if fish.isCallFish == true then
				fish:setFishSpeed(0.6,0.6);
			end

			if FishManager:getGameLayer()._isFrozen == true then
				fish:frozen(BINGDONG_SKILL_CD_TIME);
			end
		end));
	end	

	table.insert(fish._fishPath, cc.MoveTo:create(fish._speedTime, points[2]))
	fish:setPosition(newpos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:createBezierPath(fish, points, dt)
	fish._fishPath={};

	local newpos = cc.p(points[1].x,points[1].y);

	if dt < 20000 then
		local delay = cc.DelayTime:create(dt);

		table.insert(fish._fishPath, delay);
	else
		local k = (points[1].y - points[#points].y)/(points[1].x-points[#points].x);
		local b = points[1].y-k*points[1].x;
		local x = points[1].x+5;
		local y = k*x+b;
		newpos = cc.p(x,y);

		if points[1].y == points[#points].y then
			newpos.y = 0;
		end

		if points[1].x < points[#points].x then
			x = points[1].x-5;
			local y = k*x+b;
			newpos = cc.p(x,y);

			if points[1].y == points[#points].y then
				newpos.y = 0;
			end
		end

		local dt = 0.2;

		if FishManager:getGameLayer()._isFrozen == true then
			dt = 0.2
		end

		local bezier1 = {
			newpos,
			cc.pMidpoint(newpos,points[1]),
			points[1],
		}

		table.insert(fish._fishPath,cc.MoveTo:create(dt,points[1]));
		-- table.insert(fish._fishPath,cc.BezierTo:create(dt,bezier1));
		table.insert(fish._fishPath, cc.CallFunc:create(function()
			fish:setVisible(true); 
			if fish.fishShadow then
				fish.fishShadow:setVisible(true);
			end

			if fish.isCallFish == true then
				fish:setFishSpeed(0.6,0.6);
			end
			
			if FishManager:getGameLayer()._isFrozen == true then
				fish:frozen(BINGDONG_SKILL_CD_TIME);
			end  
		end));
	end 

	local bezier1 ={
		points[1],
		points[2],
		points[3]
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime, bezier1);

	table.insert(fish._fishPath, bezierTo1);

	fish:setPosition(newpos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:createFollowPath(fish, path, topFish, groupIndex)
	self._path=path;
	randomFakeSeed=self._path*fish._fishType;


	self:generateFishPathH(fish,groupIndex);

	-- local r=FishPath:fakeRandom( 0, 133 )%100;

	-- if fish._fishType > 9 then
	--	 r=r%60;
	-- end

	-- if(r<10)then
	--	 self:generateFishPathB(fish,groupIndex);
	-- elseif(r<60)then
	--	 self:generateFishPathC(fish,groupIndex);
	-- else
	--	 self:generateFishPathA(fish,groupIndex);
	-- end
end


function FishPath:getFishPathType(fishtype)
	return FishPathType.FISH_PATHTYPE_A;
end

function FishPath:generateFishPathA( fish, groupIndex)
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -s.width*3+_offsetX;
		start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		end_X=visibleSize.width+s.width*3+_offsetX;
		end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY+s.height*2;
		fish:setFlipRotate(false);
	else
		end_X = -s.width*3+_offsetX;
		end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY+s.height*2;
		start_X=visibleSize.width+s.width*3+_offsetX;
		start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		fish:setFlipRotate(true);		
	end
	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
	end

	local middle1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), cc.p(end_X, end_Y),0.1,false);
	local c1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), middle1,0.4,true);
	local c2=FishPath:getReflectPoint(c1,middle1,0.7);

	local bezier1 ={
		c1,
		c1,
		middle1
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

	local bezier2 ={
		c2,
		c2,
		cc.p(end_X, end_Y)
	};

	local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);
	
	table.insert(fish._fishPath,bezierTo1);
	table.insert(fish._fishPath,bezierTo2);

	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end


function FishPath:generateFishPathB( fish, groupIndex )
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -s.width*4+_offsetX;
		start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		end_X=visibleSize.width+s.width*4+_offsetX;
		end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		fish:setFlipRotate(false);
	else
		end_X = -s.width*4+_offsetX;
		end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		start_X=visibleSize.width+s.width*4+_offsetX;
		start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		fish:setFlipRotate(true);
	end


	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%400-200;
		start_Y = start_Y + FishPath:fakeRandom(0,1147)%400-200;
		end_X = end_X + FishPath:fakeRandom(0,1245)%400-200;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%400-200;
		timerOffset = (FishPath:fakeRandom(0,30)-15)/10;
	end

	local middle1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), cc.p(end_X, end_Y),0.3,false);
	local c1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), middle1,0.4,true);
	local c2=FishPath:getReflectPoint(middle1,cc.p(end_X, end_Y),0.7);

	local bezier1 ={
		cc.p(visibleSize.width*1/4,visibleSize.height),
		cc.p(visibleSize.width*3/4,0),
		cc.p(end_X, end_Y)
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime+timerOffset, bezier1);

	table.insert(fish._fishPath,bezierTo1);

	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathC( fish, groupIndex )
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -s.width*3+_offsetX;
		start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		end_X=visibleSize.width+s.width*3+_offsetX;
		end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		fish:setFlipRotate(false);
	else
		end_X = -s.width*3+_offsetX;
		end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		start_X=visibleSize.width+s.width*3+_offsetX;
		start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		fish:setFlipRotate(true);
	end

	local _r=FishPath:fakeRandom(0,2);
	local c1;
	local c2;
	local c21;
	local c22;

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,1245)%300-150-s.width*3;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
	end

	local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y))

	if(_r==1)then
		c1=cc.p((midPos.x-start_X)/4+start_X,math.max(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.max(start_Y,midPos.y));
		c21=cc.p((end_X-midPos.x)/4+midPos.x,math.min(end_Y,midPos.y));
		c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.min(end_Y,midPos.y));
	else
		c1=cc.p((midPos.x-start_X)/4+start_X,math.min(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.min(start_Y,midPos.y));
		c21=cc.p((end_X-midPos.x)/4+midPos.x,math.max(end_Y,midPos.y));
		c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.max(end_Y,midPos.y));
	end

	local bezier1 ={
		c1,
		c2,
		midPos
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

	local bezier2 ={
		c21,
		c22,
		cc.p(end_X, end_Y)
	};

	local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


	table.insert(fish._fishPath,bezierTo1);
	table.insert(fish._fishPath,bezierTo2);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);

end

function FishPath:generateFishPathCC( fish, groupIndex )
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -500;
		start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
		end_X=	visibleSize.width + 500;
		end_Y= start_Y	
		fish:setFlipRotate(false);
	else
		start_X = visibleSize.width + 500;
		start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
		end_X=	-500;
		end_Y= start_Y
		fish:setFlipRotate(true);
	end
	
	local moveTo = cc.MoveTo:create(fish._speedTime*2,cc.p(end_X,end_Y))

	table.insert(fish._fishPath,moveTo);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);

end

--屏幕左边进  左边出
function FishPath:generateFishPathD( fish, groupIndex )
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	start_X = -s.width*3+_offsetX;
	start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
	end_X = -s.width*3+_offsetX;
	end_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;

	local _r=FishPath:fakeRandom(0,2);
	local c1;
	local c2;
	local c21;
	local c22;

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,1245)%300-150-s.width*3;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
	end
	local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y))

	c1=cc.p(visibleSize.width*1/4,visibleSize.height*3/4);
	c2=cc.p(visibleSize.width*3/4,visibleSize.height*3/4);
	c21=cc.p(visibleSize.width*3/4,0);
	c22=cc.p(visibleSize.width*1/4,0);

	local bezier1 ={
		c1,
		c2,
		cc.p(visibleSize.width*4/5,visibleSize.height/2)
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

	local bezier2 ={
		c21,
		c22,
		cc.p(end_X, end_Y)
	};

	local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);
 
	table.insert(fish._fishPath,bezierTo1);
	table.insert(fish._fishPath,bezierTo2);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);

end
--屏幕下边进  下边出
function FishPath:generateFishPathE( fish, groupIndex , isMatrix) --大圆环
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _r=FishPath:fakeRandom(0,8);

	if(isMatrix)then
		self._path=1;
		fish._speedTime=25;
		if(groupIndex%4==1)then
			_r=0;
		elseif(groupIndex%4==2)then
			_r=3;
		elseif(groupIndex%4==3)then
			_r=4;
		else
			_r=7;
		end
	end

	if(_r==0) then
		start_X = -s.width;
		start_Y = visibleSize.height+100;
		end_X = visibleSize.width+s.width*3;
		end_Y = visibleSize.height+s.height;
		fish:setFlipRotate(false);
	elseif(_r==1) then
		end_X = -s.width*3;
		end_Y = visibleSize.height+100;
		start_X = visibleSize.width+s.width;
		start_Y = visibleSize.height+s.height;
		fish:setFlipRotate(false);
	elseif(_r==2) then
		start_X = -s.width;
		start_Y = -s.height;
		end_X = visibleSize.width+s.width*3;
		end_Y = -s.height;
		-- fish:setFlipRotate(true);
		fish:setFlipRotate(false);
	elseif(_r==3) then
		end_X = -s.width*3;
		end_Y = -s.height;
		start_X = visibleSize.width+s.width;
		start_Y = -s.height;
		-- fish:setFlipRotate(true);
		fish:setFlipRotate(false);
	elseif(_r==4) then
		start_X = -s.width*3;
		-- start_Y = -FishPath:fakeRandom(0,86423)%(visibleSize.height/4)+_offsetY;
		start_Y = -s.height;
		end_X = -s.width;
		-- end_Y = FishPath:fakeRandom(0,74584)%(visibleSize.height/4)+visibleSize.height+_offsetY;
		end_Y = visibleSize.height+s.height;
		fish:setFlipRotate(false);
	elseif(_r==5) then
		end_X  = -s.width*3;
		end_Y = -s.height;
		start_X= -s.width;
		start_Y = visibleSize.height+s.height;
		fish:setFlipRotate(false);
	elseif(_r==6) then
		start_X = visibleSize.width+100;
		start_Y = -s.height;
		end_X = visibleSize.width+s.width*3;
		end_Y = visibleSize.height+s.height;
		fish:setFlipRotate(true);
	else
		end_X = visibleSize.width+s.width*3;
		end_Y = -s.height;
		start_X = visibleSize.width+s.width*3;
		start_Y = visibleSize.height+s.height;
		fish:setFlipRotate(false);
	end

	local c1;
	local c2;
	local c21;
	local c22;
	local midPos;

	local timerOffset=0;
	local fudu=1;
	if(isMatrix)then
		fudu=0.5;
	end

	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + (FishPath:fakeRandom(0,1177)%300-150)*fudu;
		start_Y = start_Y + (FishPath:fakeRandom(0,1133)%300-150)*fudu;
		end_X = end_X + (FishPath:fakeRandom(0,1245)%300-150)*fudu;
		end_Y = end_Y + (FishPath:fakeRandom(0,1237)%300-150)*fudu;
		timerOffset = (FishPath:fakeRandom(0,80)-40)/10;

		if(isMatrix)then
			timerOffset=0;
		end

	end

	local _offsetX=(FishPath:fakeRandom(0,1177)%(visibleSize.width/6))*fudu;
	local _offsetY=FishPath:fakeRandom(0,1237)%(visibleSize.height/6);


	if(_r==0) then
		c1=cc.p(visibleSize.width+_offsetX,visibleSize.height);
		c2=cc.p(visibleSize.width+_offsetX,visibleSize.height*1/4-_offsetY);
		c21=cc.p(-_offsetX,visibleSize.height*1/4-_offsetY);
		c22=cc.p(-_offsetX,visibleSize.height);
		midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*1/4-_offsetY);
	elseif(_r==1) then
		c22=cc.p(visibleSize.width+_offsetX,visibleSize.height);
		c21=cc.p(visibleSize.width+_offsetX,visibleSize.height*1/4-_offsetY);
		c2=cc.p(-_offsetX,visibleSize.height*1/4-_offsetY);
		c1=cc.p(-_offsetX,visibleSize.height);
		midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*1/4-_offsetY);
	elseif(_r==2) then
		c1=cc.p(visibleSize.width+_offsetX,0);
		c2=cc.p(visibleSize.width+_offsetX,visibleSize.height*3/4+_offsetY);
		c21=cc.p(-_offsetX,visibleSize.height*3/4+_offsetY);
		c22=cc.p(-_offsetX,0);
		midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*3/4+_offsetY);
	elseif(_r==3) then
		c22=cc.p(visibleSize.width+_offsetX,0);
		c21=cc.p(visibleSize.width+_offsetX,visibleSize.height*3/4+_offsetY);
		c2=cc.p(-_offsetX,visibleSize.height*3/4+_offsetY);
		c1=cc.p(-_offsetX,0);
		midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*3/4+_offsetY);
	elseif(_r==4) then
		c1=cc.p(0,visibleSize.height+_offsetY);
		c2=cc.p(visibleSize.width*3/4+_offsetX,visibleSize.height+_offsetY);
		c21=cc.p(visibleSize.width*3/4+_offsetX,-_offsetY);
		c22=cc.p(0,-_offsetY);
		midPos=cc.p(visibleSize.width*3/4+_offsetX,(visibleSize.height+_offsetY)/2);
	elseif(_r==5) then
		c22=cc.p(0,visibleSize.height+_offsetY);
		c21=cc.p(visibleSize.width*3/4+_offsetX,visibleSize.height+_offsetY);
		c2=cc.p(visibleSize.width*3/4+_offsetX,-_offsetY);
		c1=cc.p(0,-_offsetY);
		midPos=cc.p(visibleSize.width*3/4+_offsetX,(visibleSize.height+_offsetY)/2);
	elseif(_r==6) then
		c1=cc.p(visibleSize.width,visibleSize.height+_offsetY);
		c2=cc.p(visibleSize.width*1/4-_offsetX,visibleSize.height+_offsetY);
		c21=cc.p(visibleSize.width*1/4-_offsetX,-_offsetY);
		c22=cc.p(visibleSize.width,-_offsetY);
		midPos=cc.p(visibleSize.width*1/4-_offsetX,(visibleSize.height+_offsetY)/2);
	else
		c22=cc.p(visibleSize.width,visibleSize.height+_offsetY);
		c21=cc.p(visibleSize.width*1/4-_offsetX,visibleSize.height+_offsetY);
		c2=cc.p(visibleSize.width*1/4-_offsetX,-_offsetY);
		c1=cc.p(visibleSize.width,-_offsetY);
		midPos=cc.p(visibleSize.width*1/4-_offsetX,(visibleSize.height+_offsetY)/2);
	end

	local bezier1 ={
		c1,
		c2,
		midPos
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

	local bezier2 ={
		c21,
		c22,
		cc.p(end_X, end_Y)
	};

	local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


	table.insert(fish._fishPath,bezierTo1);
	table.insert(fish._fishPath,bezierTo2);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathF( fish, groupIndex ) --大圈套小圈
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local _offsetX=0;
	local _offsetY=0;
	local timerOffset=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	start_X = s.width;
	start_Y = -s.height;
	end_X = -s.height*3;
	end_Y = visibleSize.height;


	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,20)-10)/10;

		_offsetX=FishPath:fakeRandom(0,541)%150-75;
		_offsetY=FishPath:fakeRandom(0,743)%200-100;
	end
	fish:setFlipRotate(false);

	local pointArray = {cc.p(start_X-100,start_Y-100),cc.p(start_X+_offsetX,start_Y+_offsetY),cc.p(637+_offsetX,300+_offsetY),cc.p(487+_offsetX,500+_offsetY),cc.p(320+_offsetX,378+_offsetY),cc.p(427+_offsetX,254+_offsetY),cc.p(550+_offsetX,365),cc.p(400+_offsetX,570+_offsetY),cc.p(end_X+_offsetX,end_Y+_offsetY),cc.p(end_X-100,end_Y+100)}

	local rate = 0.25;
	fish:setPosition(start_X,start_Y);
	for i=2,#pointArray-2 do
		local c1_X=pointArray[i].x+rate*(pointArray[i+1].x-pointArray[i-1].x);
		local c1_y=pointArray[i].y+rate*(pointArray[i+1].y-pointArray[i-1].y);
		local c2_X=pointArray[i+1].x-rate*(pointArray[i+2].x-pointArray[i].x);
		local c2_y=pointArray[i+1].y-rate*(pointArray[i+2].y-pointArray[i].y);

		local bezier ={
			cc.p(c1_X,c1_y),
			cc.p(c2_X,c2_y),
			pointArray[i+1]
		};
		local time = (fish._speedTime+timerOffset)/(#pointArray-1);
		-- if(i==2 or i == #pointArray-2)then time=time*1.5 end;
		local bezierTo = cc.BezierTo:create(time, bezier);
		table.insert(fish._fishPath,bezierTo);
	end
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathG( fish, groupIndex ) -- 一边三小弯
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();
	local _r=FishPath:fakeRandom(0,133);

	local _offsetX=0;
	local _offsetY=0;
	local timerOffset=0;


	start_X = FishPath:fakeRandom(0,visibleSize.width)/2;
	start_Y = visibleSize.height+160;
	end_X = visibleSize.width+160;
	end_Y = 260+FishPath:fakeRandom(0,visibleSize.width)%200;

	local c1=cc.p(visibleSize.width*3/5+FishPath:fakeRandom(0,1637)%visibleSize.width/3,start_Y-100-FishPath:fakeRandom(0,739)%50);
	local c2=cc.p(visibleSize.width/10+FishPath:fakeRandom(0,1327)%visibleSize.width/4,c1.y-100-FishPath:fakeRandom(0,941)%100);
	local c3=cc.p(c2.x+150+FishPath:fakeRandom(0,2819)%50,c2.y-150-FishPath:fakeRandom(0,661)%50);
	local c4=cc.p(c2.x,c3.y-(c2.y-c3.y));
	local c5=cc.p((end_X-c4.x)/2+c4.x,20+FishPath:fakeRandom(0,743)%100);

	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,20)-10)/10;

		_offsetX=FishPath:fakeRandom(0,541)%150-75;
		_offsetY=FishPath:fakeRandom(0,743)%200-100;

	end

	fish:setFlipRotate(false);

	local pointArray;
	if(_r%2==1)then
		pointArray = {cc.p(start_X-100,start_Y+100),cc.p(start_X,start_Y),c1,c2,c3,c4,c5,cc.p(end_X,end_Y),cc.p(end_X+100,end_Y-100)}
		fish:setPosition(start_X,start_Y);
	else
		pointArray = {cc.p(end_X+100,end_Y-100),cc.p(end_X,end_Y),c5,c4,c3,c2,c1,cc.p(start_X,start_Y),cc.p(start_X-100,start_Y+100)}
		fish:setPosition(end_X,end_Y);
	end

	local rate = 0.25;

	for i=2,#pointArray-2 do
		local c1_X=pointArray[i].x+rate*(pointArray[i+1].x-pointArray[i-1].x)+_offsetX;
		local c1_y=pointArray[i].y+rate*(pointArray[i+1].y-pointArray[i-1].y)+_offsetY;
		local c2_X=pointArray[i+1].x-rate*(pointArray[i+2].x-pointArray[i].x)+_offsetX;
		local c2_y=pointArray[i+1].y-rate*(pointArray[i+2].y-pointArray[i].y)+_offsetY;

		local bezier ={
			cc.p(c1_X,c1_y),
			cc.p(c2_X,c2_y),
			cc.p(pointArray[i+1].x+_offsetX,pointArray[i+1].y+_offsetY)
		};

		local time = fish._speedTime/(#pointArray-3);
		if(i%2==1)then
		   time = time + timerOffset;
		else
		   time = time - timerOffset;
		end
		local bezierTo = cc.BezierTo:create(time, bezier);
		table.insert(fish._fishPath,bezierTo);

		-- luaPrint("c1_X "..c1_X.." c1_Y "..c1_y.." c2_X "..c2_X.." c2_y "..c2_y.." i_x "..pointArray[i+1].x.." i_Y "..pointArray[i+1].y.." i:"..i)
	end
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathQ(fish, groupIndex)--上下进，随便出
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();
	local _r=FishPath:fakeRandom(0,133);

	local _offsetX=0;
	local _offsetY=0;
	local timerOffset=0;

	start_X = FishPath:fakeRandom(0,visibleSize.width*0.7);
	start_Y = FishPath:fakeRandom(-s.height*2,-s.height)-s.height;
	end_X = FishPath:fakeRandom(FishPath:fakeRandom(0,150),visibleSize.width)+s.width*3;
	end_Y = s.height+FishPath:fakeRandom(visibleSize.width/2,visibleSize.width)+visibleSize.width;

	local c1=cc.p(visibleSize.width*3/5+FishPath:fakeRandom(0,1637)%visibleSize.width/3,start_Y-100-FishPath:fakeRandom(0,739)%50);
	local c2=cc.p(visibleSize.width/10+FishPath:fakeRandom(0,1327)%visibleSize.width/4,c1.y-100-FishPath:fakeRandom(0,941)%100);
	local c3=cc.p(c2.x+150+FishPath:fakeRandom(0,2819)%50,c2.y-150-FishPath:fakeRandom(0,661)%50);
	local c4=cc.p(c2.x,c3.y-(c2.y-c3.y));
	local c5=cc.p((end_X-c4.x)/2+c4.x,20+FishPath:fakeRandom(0,743)%100);

	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,20)-10)/10;

		_offsetX=FishPath:fakeRandom(0,541)%150-75;
		_offsetY=FishPath:fakeRandom(0,743)%200-100;
	end

	fish:setFlipRotate(false);

	local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y));

	if(_r%2==1)then
		c1=cc.p((midPos.x-start_X)/4+start_X,math.max(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.max(start_Y,midPos.y));
	else
		c1=cc.p((midPos.x-start_X)/4+start_X,math.min(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.min(start_Y,midPos.y));
	end

	local bezier ={
			c1,
			c2,
			cc.p(end_X, end_Y)
		};
	local bezierTo = cc.BezierTo:create(fish._speedTime, bezier);
	table.insert(fish._fishPath,bezierTo);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathH( fish, groupIndex ) --三圈
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();
	local _r=FishPath:fakeRandom(0,133);
	local mode=FishPath:fakeRandom(0,15)%2;


	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	start_X = self:fakeRandom(visibleSize.width/3-100,visibleSize.width/3+100);
	start_Y = -400 - self:fakeRandom(0,50);
	end_X = -self:fakeRandom(s.width,s.width+50);
	end_Y = self:fakeRandom(visibleSize.height/3-100,visibleSize.height/3+100);

	local t_Arr = {1,0,-1,0};
	local p_Arr = {1,1,-1,-1};
	local _t = self:fakeRandom(-start_Y+150,-start_Y+250);

	if(mode==1)then
		start_X = self:fakeRandom(visibleSize.width*2/3-100,visibleSize.width*2/3+100);
		start_Y = 400 + self:fakeRandom(0,50)+visibleSize.height;
		t_Arr = {-1,0,1,0};
		p_Arr = {-1,-1,1,1};
		_t = self:fakeRandom(start_Y-visibleSize.height+150,start_Y-visibleSize.height+250);
	end

	local point_now = cc.p(start_X,start_Y);
	fish:setPosition(start_X,start_Y);

	fish:setFlipRotate(false);

	local rate =-1;
	if(_r%2==1)then
		rate=0.5;
	end

	local bezierNum=3;
	for i=1,bezierNum do
		local point_next = cc.p ( point_now.x + _t*p_Arr[(i%4) +1] , point_now.y + _t*p_Arr[(i-1)%4 +1]); 
		local c1=cc.p(point_now.x + rate*_t*t_Arr[(i-1)%4+1], point_now.y + rate*_t*t_Arr[(i+2)%4+1]);
		local c2=cc.p(point_next.x + rate*_t*t_Arr[(i+2)%4+1], point_next.y + rate*_t*t_Arr[(i+1)%4+1]);

		local bezier ={
			c1,
			c2,
			point_next
		};

		local time = fish._speedTime*2/bezierNum;
		local bezierTo = cc.BezierTo:create(time, bezier);
		table.insert(fish._fishPath,bezierTo);
		if(_r%2==1)then
			_t = 200+100+self:fakeRandom(0,127*i+47*i)%200;
		else
			_t = 200+200+self:fakeRandom(0,127*i+47*i)%200;
		end
		point_now=cc.p(point_next.x,point_next.y);

		if(i==bezierNum)then
			if c1.x-point_now.x < 0 then
				end_X=-end_X+visibleSize.width;
			end
		end
	end


	local bezierEnd ={
		cc.p(point_now.x,point_now.y+(point_now.x-end_Y)*0.5),
		cc.p(end_X-(end_X-point_now.x)*0.5,end_Y),
		cc.p(end_X,end_Y)
	};

	local bezierToEnd = cc.BezierTo:create(fish._speedTime*2/bezierNum, bezierEnd);
	table.insert(fish._fishPath,bezierToEnd);

	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathI( fish, groupIndex, beginUp, roundNum ) -- 类似正弦函数前进 ， 鱼阵上用
	if(beginUp == nil)then
		beginUp=true;
	end
	if(roundNum == nil)then
		roundNum=FishPath:fakeRandom(5,15);
	end

	fish._fishPath={};
	local visibleSize = cc.Director:getInstance():getWinSize();
	local roundDistance=visibleSize.width/roundNum;
	local start_X = - roundDistance;
	local start_Y = visibleSize.height/2;
	local p_Arr = {1,1,-1,-1};
	local t_xArr = {0,1};
	local t_yArr = {1,0,-1,0};

	local point_now = cc.p(start_X,start_Y);
	fish:setPosition(start_X,start_Y);
	local _t=roundDistance/2;
	local rate=0.5;

	local upDownDelay=0;
	if(beginUp)then
		upDownDelay=2;
	end

	fish:setFlipRotate(false);

	for i=1,(roundNum+2)*2 do
		local point_next = cc.p ( point_now.x + _t , point_now.y + _t*p_Arr[(i+upDownDelay)%4 +1]); 
		local c1=cc.p(point_now.x + rate*_t*t_xArr[(i-1+upDownDelay)%2+1], point_now.y + rate*_t*t_yArr[(i-1+upDownDelay)%4+1]);
		local c2=cc.p(point_next.x - rate*_t*t_xArr[(i+upDownDelay)%2+1], point_next.y + rate*_t*t_yArr[(i+2+upDownDelay)%4+1]);

		local bezier ={
			c1,
			c2,
			point_next
		};

		local time = 20/(roundNum*2);
		local bezierTo = cc.BezierTo:create(time, bezier);
		table.insert(fish._fishPath,bezierTo);
		point_now=cc.p(point_next.x,point_next.y);
	end
	fish:setFlipScreen(FLIP_FISH);
end

--三元四喜路径
function FishPath:generateFishPathR(fish, groupIndex)
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();

	if fish._fishType == 25 or fish._fishType == 28 then--三元四喜特殊处理
		s.width = 170*3;
		s.height = 170;
	elseif fish._fishType == 26 or fish._fishType == 29 then
		s.width = 145*3;
		s.height = 145;
	elseif fish._fishType == 27 or fish._fishType == 30 then
		s.width = 135*3;
		s.height = 135;
	end
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -s.width*2+_offsetX;
		start_Y = FishPath:fakeRandom(0,864223)%visibleSize.height+_offsetY;
		end_X=visibleSize.width+s.width*2+_offsetX;
		end_Y=FishPath:fakeRandom(0,745824)%(visibleSize.height*0.5)+visibleSize.height/4+_offsetY;
		fish:setFlipRotate(false);
	else
		end_X = -s.width*2+_offsetX;
		end_Y = FishPath:fakeRandom(0,864223)%visibleSize.height+_offsetY;
		start_X=visibleSize.width+s.width*2+_offsetX;
		start_Y = FishPath:fakeRandom(0,745824)%(visibleSize.height*0.5)+visibleSize.height/4+_offsetY;
		fish:setFlipRotate(true);
	end

	local _r=FishPath:fakeRandom(0,2);
	local c1;
	local c2;
	local c21;
	local c22;

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,2177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,2133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,2245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,2237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
	end

	local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y))

	if(_r==1)then
		c1=cc.p((midPos.x-start_X)/4+start_X,math.max(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.max(start_Y,midPos.y));
		c21=cc.p((end_X-midPos.x)/4+midPos.x,math.min(end_Y,midPos.y));
		c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.min(end_Y,midPos.y));
	else
		c1=cc.p((midPos.x-start_X)/4+start_X,math.min(start_Y,midPos.y));
		c2=cc.p((midPos.x-start_X)/4*3+start_X,math.min(start_Y,midPos.y));
		c21=cc.p((end_X-midPos.x)/4+midPos.x,math.max(end_Y,midPos.y));
		c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.max(end_Y,midPos.y));
	end

	local bezier1 ={
		c1,
		c2,
		cc.p(end_X,end_Y)
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime+timerOffset, bezier1);

	table.insert(fish._fishPath,bezierTo1);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathS(fish, groupIndex)
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();

	if fish._fishType == 25 or fish._fishType == 28 then--三元四喜特殊处理
		s.width = 170*3;
		s.height = 170;
	elseif fish._fishType == 26 or fish._fishType == 29 then
		s.width = 145*3;
		s.height = 145;
	elseif fish._fishType == 27 or fish._fishType == 30 then
		s.width = 135*3;
		s.height = 135;
	end
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _offsetX=0;
	local _offsetY=0;

	if(self._path%2==1) then
		start_X = -s.width*2+_offsetX;
		start_Y = FishPath:fakeRandom(0,46423)%visibleSize.height+_offsetY;
		end_X=visibleSize.width+s.width*2+_offsetX;
		end_Y=FishPath:fakeRandom(0,45824)%(visibleSize.height*0.8)+visibleSize.height/4+_offsetY;
		fish:setFlipRotate(false);
	else
		end_X = -s.width*2+_offsetX;
		end_Y = FishPath:fakeRandom(0,46423)%visibleSize.height+_offsetY;
		start_X=visibleSize.width+s.width*2+_offsetX;
		start_Y = FishPath:fakeRandom(0,45824)%(visibleSize.height*0.8)+visibleSize.height/4+_offsetY;
		fish:setFlipRotate(true);
	end

	local _r=FishPath:fakeRandom(0,4);

	if _r == 0 then
		start_Y = start_Y + FishPath:fakeRandom(0,-200);
		end_Y = end_Y + FishPath:fakeRandom(100,-200);
	elseif _r == 1 then
		start_Y = start_Y + FishPath:fakeRandom(0,-100);
		end_Y = end_Y + FishPath:fakeRandom(-100,0);
	elseif _r == 2 then
		start_Y = start_Y + FishPath:fakeRandom(-100,0);
		end_Y = end_Y + FishPath:fakeRandom(0,-200);
	else
		start_Y = start_Y + FishPath:fakeRandom(-100,150);
		end_Y = end_Y + FishPath:fakeRandom(-150,-50);
	end

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + FishPath:fakeRandom(0,2177)%300-150;
		start_Y = start_Y + FishPath:fakeRandom(0,2133)%300-150;
		end_X = end_X + FishPath:fakeRandom(0,2245)%300-150;
		end_Y = end_Y + FishPath:fakeRandom(0,2237)%300-150;
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
	end

	local moveTo = cc.MoveTo:create(fish._speedTime+timerOffset, cc.p(end_X, end_Y));

	table.insert(fish._fishPath, moveTo);

	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathJ(fish, groupIndex) --从四个角出来，到对角 适用于大鱼
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local bezier;
	local startPos;
	local fishSize = fish:getContentSize();

	local _offsetX=0;
	local _offsetY=0;

	local o = math.ceil(FishPath:fakeRandom(20,400)/20)+_offsetY;
	local mode = FishPath:fakeRandom(0, 15)%2;

	if(mode%2==1) then --左边
		if (o%2==1) then --下面
			bezier = self:getRandomPoints("lb",fishSize);
		else--上面
			bezier = self:getRandomPoints("lt",fishSize);
		end		
		fish:setFlipRotate(false);
	else --右边
		if (o%2==1) then --下面
			bezier = self:getRandomPoints("rb",fishSize);
		else--上面
			bezier = self:getRandomPoints("rt",fishSize);
		end
		
		fish:setFlipRotate(true);
	end

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
		if timerOffset <= 0 then
			timerOffset = 1.5;
		end
	end

	startPos = bezier[1];
	table.remove(bezier,1);
	local delay = cc.DelayTime:create(timerOffset);
	local bezierTo1 = cc.BezierTo:create(fish._speedTime, bezier);
	
	table.insert(fish._fishPath,delay);	
	table.insert(fish._fishPath,bezierTo1);

	fish:setPosition(startPos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathK(fish, groupIndex)--boss鱼路线 屏幕来回游一圈 其中之一
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local startPos;
	local p1,p2,p3;
	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();

	local o = math.ceil(FishPath:fakeRandom(20,400));
	local mode = FishPath:fakeRandom(0, 15)%2;

	local x = FishPath:fakeRandom(visibleSize.width*0.9,visibleSize.width);
	startPos = cc.p(-fishSize.width,FishPath:fakeRandom(0,100));
	p1 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.1,visibleSize.height*0.3));
	p2 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.7,visibleSize.height*0.85));
	p3 = cc.p(-fishSize.width,FishPath:fakeRandom(visibleSize.height-100,visibleSize.height+100));

	if(mode%2==1) then --左边
		fish:setFlipRotate(false);
	else --右边
		fish:setFlipRotate(true);
	end

	local pos = {startPos,p1,p2,p3};

	local cardina =  cc.CardinalSplineBy:create(fish._speedTime,pos,0);

	table.insert(fish._fishPath, cardina);

	fish:setPosition(startPos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathL(fish, groupIndex)--boss鱼路线 屏幕来回游一圈 其中之二
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local startPos,p1,p2,endPos;
	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();
	local _offsetX=0;
	local _offsetY=0;

	local o = math.ceil(FishPath:fakeRandom(20,400)/20)+_offsetY;
	local mode = FishPath:fakeRandom(0, 15)%2;

	if(mode%2==1) then --左边
		local x = visibleSize.width+FishPath:fakeRandom(0,300);
		if (o%2==1) then --下面
			startPos = cc.p(-fishSize.width,FishPath:fakeRandom(-100,100));
			p1 = cc.p(x,0);
			p2 = cc.p(x,visibleSize.height);
			endPos = cc.p(-fishSize.width,visibleSize.height+FishPath:fakeRandom(-100, 100));
		else--上面
			startPos = cc.p(-fishSize.width,visibleSize.height+FishPath:fakeRandom(-100,100));
			p1 = cc.p(x,visibleSize.height);
			p2 = cc.p(x,0);
			endPos = cc.p(-fishSize.width,FishPath:fakeRandom(-100, 100));
		end
		fish:setFlipRotate(false);
	else --右边
		local x = FishPath:fakeRandom(-300,0);
		if (o%2==1) then --下面
			startPos = cc.p(visibleSize.width+fishSize.width,FishPath:fakeRandom(-100,100));
			p1 = cc.p(x,0);
			p2 = cc.p(x,visibleSize.height);
			endPos = cc.p(visibleSize.width+fishSize.width,visibleSize.height+FishPath:fakeRandom(-100, 100));
		else--上面
			startPos = cc.p(visibleSize.width+fishSize.width,visibleSize.height+FishPath:fakeRandom(-100,100));
			p1 = cc.p(x,visibleSize.height);
			p2 = cc.p(x,0);
			endPos = cc.p(visibleSize.width+fishSize.width,FishPath:fakeRandom(-100, 100));
		end		
		fish:setFlipRotate(true);
	end

	local timerOffset=0;
	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		timerOffset = (FishPath:fakeRandom(0,50)-25)/10;
		if timerOffset <= 0 then
			timerOffset = 1.5;
		end
	end
	local pos = {p1,p2,endPos};

	local delay = cc.DelayTime:create(timerOffset);
	local bezierTo1 = cc.BezierTo:create(fish._speedTime, pos);
	
	table.insert(fish._fishPath,delay);	
	table.insert(fish._fishPath,bezierTo1);

	fish:setPosition(startPos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathT(fish, groupIndex)
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();
	local mode = FishPath:fakeRandom(0, 15)%2;

	local start_x = 0;
	local start_y = 0;
	local end_x = 0;
	local end_y = 0;

	if(mode%2==1) then --左边
		start_x = -fishSize.height/2-visibleSize.width/4;
		start_y = visibleSize.height/2;
		end_x = visibleSize.width+fishSize.height/2+visibleSize.width/4;
		end_y = visibleSize.height/2;

		if fish._fishType == 43 then
			start_y = visibleSize.height/2+80;
			end_y = visibleSize.height/2+80;
		end
		fish:setFlipRotate(false);
	else --右边
		end_x = -fishSize.height/2-visibleSize.width/4;
		end_y = visibleSize.height/2;
		start_x = visibleSize.width+fishSize.height/2+visibleSize.width/4;
		start_y = visibleSize.height/2;

		if fish._fishType == 43 then
			start_y = visibleSize.height/2+80;
			end_y = visibleSize.height/2+80;
		end
		fish:setFlipRotate(true);
	end

	local mid = cc.p(visibleSize.width/2,visibleSize.height/2);

	if fish._fishType == 43 then
		mid.y = mid.y + 80;
	end

	local move = cc.MoveTo:create(fish._speedTime/2-7.5, mid);
	local delay = cc.DelayTime:create(15);
	local move1 = cc.MoveTo:create(fish._speedTime/2-7.5, cc.p(end_x, end_y));

	table.insert(fish._fishPath,cc.EaseSineOut:create(move));
	table.insert(fish._fishPath,delay);
	table.insert(fish._fishPath,cc.EaseSineIn:create(move1));

	fish:setPosition(cc.p(start_x, start_y));
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathM(fish, groupIndex) --世界boss，屏幕下方移动至中央
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local startPos,p1,p2,endPos;
	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();
	local mode = FishPath:fakeRandom(0, 15)%2;

	-- if(mode%2==1) then --左边	   
	-- else --右边
		fish:setFlipRotate(true);
	-- end

	startPos = cc.p(visibleSize.width/2,-fishSize.height/2);
	-- startPos = cc.p(visibleSize.width/2,200);
	endPos = cc.p(visibleSize.width/2,visibleSize.height/2);

	local move = cc.MoveTo:create(3, endPos)
	
	table.insert(fish._fishPath,cc.EaseSineOut:create(move));
	table.insert(fish._fishPath,cc.DelayTime:create(fish._speedTime-3));
	-- table.insert(fish._fishPath,cc.DelayTime:create(5));
	-- table.insert(fish._fishPath,cc.MoveTo:create(5, cc.p(visibleSize.width/2,visibleSize.height+fishSize.height/2)));

	fish:setPosition(startPos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathN(fish, groupIndex)--凤凰，屏幕中游一圈
	fish._fishPath={};
	randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

	local startPos;
	local p1,p2,p3;
	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();

	local o = math.ceil(FishPath:fakeRandom(20,400));
	local mode = FishPath:fakeRandom(0, 15)%2;

	local x = FishPath:fakeRandom(visibleSize.width*1.1,visibleSize.width*1.2);

	if (o%2==1) then --下面
		local x = FishPath:fakeRandom(visibleSize.width*1.1,visibleSize.width*1.2);
		startPos = cc.p(-fishSize.width,FishPath:fakeRandom(0,100));
		p1 = cc.p(x,FishPath:fakeRandom(20,visibleSize.height*0.15));
		p2 = cc.p(x+180,FishPath:fakeRandom(visibleSize.height*0.6,visibleSize.height*0.7));
		x = FishPath:fakeRandom(visibleSize.width*0.7,visibleSize.width*0.75);
		p3 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.6,visibleSize.height*0.7));
		p4 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.1,visibleSize.height*0.3));
		p5 = cc.p(visibleSize.width+fishSize.width*1.5,FishPath:fakeRandom(0,100));
	else--上面
		local x = FishPath:fakeRandom(visibleSize.width*1.1,visibleSize.width*1.2);
		startPos = cc.p(-fishSize.width,visibleSize.height*0.3-FishPath:fakeRandom(0,100));
		p1 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.6,visibleSize.height*0.7));
		p2 = cc.p(x,FishPath:fakeRandom(0,visibleSize.height*0.1));
		x = FishPath:fakeRandom(visibleSize.width*0.65,visibleSize.width*0.7);
		p3 = cc.p(x,FishPath:fakeRandom(10,visibleSize.height*0.1));
		p4 = cc.p(x,FishPath:fakeRandom(visibleSize.height*0.5,visibleSize.height*0.6));
		p5 = cc.p(visibleSize.width+fishSize.width*1.5,visibleSize.height*0.8-FishPath:fakeRandom(0,100));	
	end 
	
	if(mode%2==1) then --左边
		fish:setFlipRotate(false);
	else
		fish:setFlipRotate(true);
	end

	local pos = {startPos,p1,p2,p3,p4,p5};

	local cardina =  cc.CardinalSplineBy:create(fish._speedTime,pos,0);

	table.insert(fish._fishPath, cardina);

	fish:setPosition(startPos);
	fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathO(fish, groupIndex) --世界小boss，屏幕下方移动至中央
	fish._fishPath={};

	local startPos,endPos;
	local fishSize = fish:getContentSize();
	local visibleSize = cc.Director:getInstance():getWinSize();

	fish:setFlipRotate(true);

	-- startPos = cc.p(-fishSize.width,visibleSize.height/2 );
	-- endPos = cc.p(visibleSize.width  + fishSize.width,visibleSize.height/2);

	startPos = cc.p(visibleSize.width/2,visibleSize.height + fishSize.height/2 );
	endPos = cc.p(visibleSize.width/2,-fishSize.height/2);

	table.insert(fish._fishPath,cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(3, cc.p(visibleSize.width/2,visibleSize.height/2)))));
	table.insert(fish._fishPath,cc.Sequence:create(cc.DelayTime:create(fish._speedTime-10)));
	table.insert(fish._fishPath,cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(3, endPos))));
	
	fish:setPosition(startPos);
	-- fish:setFlipScreen(FLIP_FISH);
	if FLIP_FISH then
		fish:setRotation(180)
	end
end

--屏幕下边进  上边出
function FishPath:generateFishPathP( fish, groupIndex) 
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _r=FishPath:fakeRandom(0,4);

	if(isMatrix)then
		self._path=1;
		fish._speedTime=25;
		if(groupIndex%4==1)then
			_r=0;
		elseif(groupIndex%4==1)then
			_r=1;
		elseif(groupIndex%4==2)then
			_r=2;
		else
			_r=3;
		end
	end

	if(_r==0) then
		start_X = -s.width;
		start_Y = -s.height;
		end_X = visibleSize.width/7*4+s.width;
		end_Y = visibleSize.height+s.height*4;
	elseif(_r==1) then
		start_X = visibleSize.width/5*4+s.width;
		start_Y = -s.height;
		end_X = s.width;
		end_Y = visibleSize.height+s.height*4;		
	elseif(_r==2) then
		start_X = -s.width;
        start_Y = -s.height;
		end_X = visibleSize.width/2+s.width;
		end_Y = visibleSize.height+s.height*4;
	elseif(_r==3) then
		start_X = visibleSize.width/2+s.width;
		start_Y = -s.height;
		end_X = visibleSize.width+s.width;
		end_Y = visibleSize.height+s.height*4;
	end

	local c1;
	local c2;
	local c21;
	local c22;
	local midPos;

	local timerOffset=0;
	local fudu=1;
	if(isMatrix)then
		fudu=0.5;
	end

	if(groupIndex~=0)then
		randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
		start_X = start_X + (FishPath:fakeRandom(0,2546)%200-100)*fudu;
		start_Y = start_Y + (FishPath:fakeRandom(0,1895)%200-100)*fudu;
		end_X = end_X + (FishPath:fakeRandom(0,1582)%200-100)*fudu;
		end_Y = end_Y + (FishPath:fakeRandom(0,1423)%200-100)*fudu;
		timerOffset = (FishPath:fakeRandom(0,80)-30)/10;

		if(isMatrix)then
			timerOffset=0;
		end
	end

	fish:setFlipRotate(false);

	local _offsetX=(FishPath:fakeRandom(0,1177)%(visibleSize.width/6))*fudu;
	local _offsetY=FishPath:fakeRandom(0,1237)%(visibleSize.height/6);

	c1=cc.p(visibleSize.width+_offsetX,visibleSize.height);
	c2=cc.p(visibleSize.width/2+_offsetX,visibleSize.height*1/4-_offsetY);
	c21=cc.p(-_offsetX,visibleSize.height*1/4-_offsetY);
	c22=cc.p(-_offsetX,visibleSize.height);
	midPos=cc.p((visibleSize.width+_offsetX)/4,visibleSize.height*1/4-_offsetY);

	local bezier1 ={
		c1,
		c2,
		midPos
	};

	local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

	local bezier2 ={
		c21,
		c22,
		cc.p(end_X, end_Y)
	};

	local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


	table.insert(fish._fishPath,bezierTo1);
	table.insert(fish._fishPath,bezierTo2);
	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end

--特殊鱼路线，刚进入场景，鱼在屏幕内，快速游出屏幕
function FishPath:generateFishPathSpec( fish, groupIndex )
	fish._fishPath={};

	local start_X=0;
	local start_Y=0;
	local end_X=0;
	local end_Y=0;

	local s = fish:getContentSize();
	
	local visibleSize = cc.Director:getInstance():getWinSize();

	local _r=FishPath:fakeRandom(0,40);
	local c1;
	local c2;
	local time = 0;
	local _offsetX = 0

	if(_r<=10) then
		start_X = visibleSize.width/4+math.random(-50,50);
		start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height;
		end_X=visibleSize.width+s.width*4;
		end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height;
		c1=cc.p(start_X+math.random(0,100),start_Y+math.random(0,50));
		c2=cc.p(start_X+math.random(200,500),end_Y+math.random(0,50))
		fish:setFlipRotate(false);
		time = fish._speedTime*0.7;
		_offsetX = 5;
	elseif(_r<=20) then
		start_X=visibleSize.width/2+math.random(-60,50);
		start_Y = FishPath:fakeRandom(0,44584)%visibleSize.height;
		end_X = visibleSize.width+s.width*4;
		end_Y = FishPath:fakeRandom(0,56423)%visibleSize.height;
		c1=cc.p(start_X+math.random(0,100),start_Y+math.random(0,50));
		c2=cc.p(start_X+math.random(200,500),end_Y+math.random(0,100))
		fish:setFlipRotate(false);
		time = fish._speedTime*0.4;
		_offsetX = 5;
	elseif(_r<=30) then
		start_X=visibleSize.width*3/4+math.random(-50,80);
		start_Y = FishPath:fakeRandom(0,74554)%visibleSize.height;
		end_X = -s.width*4;
		end_Y = FishPath:fakeRandom(0,86123)%visibleSize.height;
		c1=cc.p(start_X-math.random(0,100),start_Y+math.random(0,50));
		c2=cc.p(start_X-math.random(200,500),end_Y+math.random(0,150))
		fish:setFlipRotate(true);
		time = fish._speedTime*0.7;
		_offsetX = -5;
	else
		start_X=visibleSize.width/2+math.random(-50,40);
		start_Y = FishPath:fakeRandom(0,34584)%visibleSize.height;
		end_X = -s.width*3;
		end_Y = FishPath:fakeRandom(0,16423)%visibleSize.height;
		c1=cc.p(start_X-math.random(0,100),start_Y+math.random(0,50));
		c2=cc.p(start_X-math.random(200,500),end_Y+math.random(0,150))
		fish:setFlipRotate(true);
		time = fish._speedTime*0.4;
		_offsetX = -5;
	end

	if fish:checkIsBoss() then
		start_Y = visibleSize.height/2+100;
		end_Y = visibleSize.height/2+100;
		c1.y = visibleSize.height/2+100;
		c2.y = visibleSize.height/2+100;
	end

	local bezier1 ={
		c1,
		c2,
		cc.p(end_X, end_Y)
	};

	-- local fadeInAction = cc.DelayTime:create(0.4);
	local seq = cc.Sequence:create(
		cc.CallFunc:create(function() fish:setVisible(false);if fish.fishShadow then
			fish.fishShadow:setVisible(false);
		end end),
		--cc.MoveTo:create(0.1,cc.p(start_X+_offsetX,start_Y)),
		cc.FadeOut:create(0.1),
		cc.CallFunc:create(function() fish:setVisible(true);if fish.fishShadow then
			fish.fishShadow:setVisible(true);
		end end),cc.FadeIn:create(0.02)
	);
	-- fish:runAction(seq)

	-- table.insert(fish._fishPath,seq);

	local bezierTo1 = cc.BezierTo:create(time, bezier1);

	table.insert(fish._fishPath,bezierTo1);
	-- fish:setFishSpeed(0.8,1)

	fish:setPosition(start_X,start_Y);
	fish:setFlipScreen(FLIP_FISH);
end
--只用于J路线
function FishPath:getRandomPoints(direction,fishSize)
	--返回两个控制点
	local points = nil;
	local visibleSize = cc.Director:getInstance():getWinSize();

	local leftBottom = {				   
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.42,visibleSize.height*0.15),
						cc.p(visibleSize.width*0.89,visibleSize.height*0.29),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.2,visibleSize.height*0.47),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.7),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.05,visibleSize.height*0.97),
						cc.p(visibleSize.width*0.99,visibleSize.height*0.03),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.15,visibleSize.height*0.58),
						cc.p(visibleSize.width*0.53,visibleSize.height*0.9),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.42,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.64,visibleSize.height*0.51),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.25,visibleSize.height*0.45),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.06,visibleSize.height*0.61),
						cc.p(visibleSize.width*0.28,visibleSize.height*0.88),
						cc.p(visibleSize.width+fishSize.width,0)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.06,visibleSize.height*0.61),
						cc.p(visibleSize.width*0.28,visibleSize.height*0.88),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.06,visibleSize.height*0.61),
						cc.p(visibleSize.width*0.28,visibleSize.height*0.88),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.8)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.06,visibleSize.height*0.61),
						cc.p(visibleSize.width*0.28,visibleSize.height*0.88),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.33),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.36),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.33),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.4),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.7)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.1)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.9)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.07,visibleSize.height*0.75),
						cc.p(visibleSize.width*0.45,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.5,visibleSize.height+fishSize.height+fishSize.height*2)
					},
					{
						cc.p(-fishSize.width,0),
						cc.p(visibleSize.width*0.47,visibleSize.height*0.07),
						cc.p(visibleSize.width*0.77,visibleSize.height*0.26),
						cc.p(visibleSize.width*0.79,visibleSize.height+fishSize.height+fishSize.height*2)
					},					
					{
						cc.p(visibleSize.width*0.15,-fishSize.height),
						cc.p(visibleSize.width*0.18,visibleSize.height*0.82),
						cc.p(visibleSize.width*0.35,visibleSize.height*0.97),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(visibleSize.width*0.15,-fishSize.height),
						cc.p(visibleSize.width*0.74,visibleSize.height*0.06),
						cc.p(visibleSize.width*0.86,visibleSize.height*0.47),
						cc.p(visibleSize.width*0.85,visibleSize.height+fishSize.height+fishSize.height*2)
					},
					{
						cc.p(visibleSize.width*0.15,-fishSize.height),
						cc.p(visibleSize.width*0.12,visibleSize.height*0.9),
						cc.p(visibleSize.width*0.56,visibleSize.height*0.94),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height+fishSize.height*2)
					}
	};
	
	local leftTop = {
					{
						cc.p(-fishSize.width,visibleSize.height*0.75),
						cc.p(visibleSize.width*0.28,visibleSize.height*0.6),
						cc.p(visibleSize.width*0.56,visibleSize.height*0.25),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.2)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.75),
						cc.p(visibleSize.width*0.2,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.45,visibleSize.height*0.2),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.2)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.6),
						cc.p(visibleSize.width*0.25,visibleSize.height*0.55),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.3)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.07,visibleSize.height*0.06),
						cc.p(visibleSize.width*0.76,visibleSize.height*0.96),
						cc.p(visibleSize.width,-fishSize.width)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.17,visibleSize.height*0.43),
						cc.p(visibleSize.width*0.5,visibleSize.height*0.18),
						cc.p(visibleSize.width,-fishSize.width)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.53,visibleSize.height*0.88),
						cc.p(visibleSize.width*0.8,visibleSize.height*0.6),
						cc.p(visibleSize.width,-fishSize.width)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.36,visibleSize.height*0.45),
						cc.p(visibleSize.width*0.64,visibleSize.height*0.3),
						cc.p(visibleSize.width,-fishSize.width)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.6,visibleSize.height*1),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.03),
						cc.p(visibleSize.width,-fishSize.width)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.01),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.3),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.77)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.01),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.3),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.01),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.3),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(-fishSize.width,visibleSize.height),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.01),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.3),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.2)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.67),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.64),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.67),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.6),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.67),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.6),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.55),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.55),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.1)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.55),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.9)
					},
					{
						cc.p(-fishSize.width,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.6),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.6),
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.8)
					},
					{
						cc.p(visibleSize.width*0.15,visibleSize.height+fishSize.height),
						cc.p(visibleSize.width*0.18,visibleSize.height*0.18),
						cc.p(visibleSize.width*0.35,visibleSize.height*0.03),
						cc.p(visibleSize.width+fishSize.width,-fishSize.height*2)
					},
					{
						cc.p(visibleSize.width*0.15,visibleSize.height+fishSize.height),
						cc.p(visibleSize.width*0.45,visibleSize.height*0.98),
						cc.p(visibleSize.width*0.92,visibleSize.height*0.9),
						cc.p(visibleSize.width-fishSize.width,-fishSize.height*2)
					}
	};
	local rightBottom = {
					{
						cc.p(visibleSize.width+fishSize.width,0),	   
						cc.p(visibleSize.width*0.24,visibleSize.height*0.09),
						cc.p(visibleSize.width*0.6,visibleSize.height*0.95),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),	   
						cc.p(visibleSize.width*0.56,visibleSize.height*0.77),
						cc.p(visibleSize.width*0.37,visibleSize.height*0.8),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),	   
						cc.p(visibleSize.width*0.56,visibleSize.height*0.23),
						cc.p(visibleSize.width*0.37,visibleSize.height*0.8),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),	   
						cc.p(visibleSize.width*0.24,visibleSize.height*0.05),
						cc.p(visibleSize.width*0.69,visibleSize.height*0.95),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.72,visibleSize.height*0.39),
						cc.p(visibleSize.width*0.52,visibleSize.height*0.07),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.72,visibleSize.height*0.61),
						cc.p(visibleSize.width*0.52,visibleSize.height*0.93),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.45,visibleSize.height*0.1),
						cc.p(visibleSize.width*0.14,visibleSize.height*0.42),
						cc.p(-fishSize.width,visibleSize.height)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.25,visibleSize.height*0.5),
						cc.p(-fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.72),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.8),
						cc.p(-fishSize.width,0)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.72),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.8),
						cc.p(-fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.72),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.8),
						cc.p(-fishSize.width,visibleSize.height*0.2)
					},
					{
						cc.p(visibleSize.width+fishSize.width,0),
						cc.p(visibleSize.width*0.75,visibleSize.height*0.72),
						cc.p(visibleSize.width*0.3,visibleSize.height*0.8),
						cc.p(-fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.36),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.33),
						cc.p(-fishSize.width,visibleSize.height*0.4)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.4),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.33),
						cc.p(-fishSize.width,visibleSize.height*0.6)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.3),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(-fishSize.width,visibleSize.height*0.7)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(-fishSize.width,visibleSize.height*0.5)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(-fishSize.width,visibleSize.height*0.9)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
						cc.p(-fishSize.width,visibleSize.height*0.1)
					},
					{
						cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.5),
						cc.p(visibleSize.width*0.7,visibleSize.height*0.6),
						cc.p(visibleSize.width*0.4,visibleSize.height*0.7),
						cc.p(-fishSize.width,visibleSize.height*0.8)
					},
					{
						cc.p(visibleSize.width,-fishSize.height),
						cc.p(visibleSize.width*0.95,visibleSize.height*0.7),
						cc.p(visibleSize.width*0.85,visibleSize.height*0.94),
						cc.p(visibleSize.width*0.15,visibleSize.height+fishSize.height*2)
					},
					{
						cc.p(visibleSize.width,-fishSize.height),
						cc.p(visibleSize.width*0.35,visibleSize.height*0.1),
						cc.p(visibleSize.width*0.2,visibleSize.height*0.2),
						cc.p(visibleSize.width*0.15,visibleSize.height+fishSize.height*2)
					}
	};

	local rightTop = {
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.3,visibleSize.height*0.86),
					cc.p(visibleSize.width*0.72,visibleSize.height*0.08),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.37,visibleSize.height*0.99),
					cc.p(visibleSize.width*0.57,visibleSize.height*0.01),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.99,visibleSize.height*0.03),
					cc.p(visibleSize.width*0.05,visibleSize.height*0.97),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.51,visibleSize.height*0.95),
					cc.p(visibleSize.width*0.15,visibleSize.height*0.18),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.65,visibleSize.height*0.56),
					cc.p(visibleSize.width*0.42,visibleSize.height*0.71),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.86,visibleSize.height*0.65),
					cc.p(visibleSize.width*0.54,visibleSize.height*0.09),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.05,visibleSize.height*1),
					cc.p(visibleSize.width*1,visibleSize.height*0.05),
					cc.p(-fishSize.width,0)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.6),
					cc.p(visibleSize.width*0.75,visibleSize.height*0.5),
					cc.p(visibleSize.width*0.25,visibleSize.height*0.4),
					cc.p(-fishSize.width,visibleSize.height*0.3)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.73,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.28,visibleSize.height*0.18),
					cc.p(-fishSize.width,visibleSize.height)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.73,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.28,visibleSize.height*0.18),
					cc.p(-fishSize.width,visibleSize.height*0.8)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.73,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.28,visibleSize.height*0.18),
					cc.p(-fishSize.width,visibleSize.height*0.6)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.73,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.28,visibleSize.height*0.18),
					cc.p(-fishSize.width,visibleSize.height*0.4)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height),
					cc.p(visibleSize.width*0.73,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.28,visibleSize.height*0.18),
					cc.p(-fishSize.width,visibleSize.height*0.2)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.7),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.67),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.64),
					cc.p(-fishSize.width,visibleSize.height*0.6)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.7),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.67),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.6),
					cc.p(-fishSize.width,visibleSize.height*0.5)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.7),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.67),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.6),
					cc.p(-fishSize.width,visibleSize.height*0.4)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.55),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.5),
					cc.p(-fishSize.width,visibleSize.height*0.5)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.55),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.4),
					cc.p(-fishSize.width,visibleSize.height*0.1)
				},
				{
					cc.p(visibleSize.width+fishSize.width,visibleSize.height*0.55),
					cc.p(visibleSize.width*0.7,visibleSize.height*0.5),
					cc.p(visibleSize.width*0.4,visibleSize.height*0.6),
					cc.p(-fishSize.width,visibleSize.height*0.9)
				},
				{
					cc.p(visibleSize.width*0.85,visibleSize.height+fishSize.height),
					cc.p(visibleSize.width*0.3,visibleSize.height*0.94),
					cc.p(visibleSize.width*0.2,visibleSize.height*0.85),
					cc.p(visibleSize.width*0.15,-fishSize.height)
				},
				{
					cc.p(visibleSize.width*0.85,visibleSize.height+fishSize.height),
					cc.p(visibleSize.width*0.9,visibleSize.height*0.2),
					cc.p(visibleSize.width*0.85,visibleSize.height*0.1),
					cc.p(visibleSize.width*0.15,-fishSize.height*2)
				}
	};

	local r;

	if (direction == "lb") then
		r = FishPath:fakeRandom(0,9999)%(#leftBottom)+1;
		points = leftBottom[r];
		-- luaPrint("lb  ============================= "..r);
	elseif (direction == "lt") then
		r = FishPath:fakeRandom(0,9999)%(#leftTop)+1;
		points = leftTop[r];
		-- luaPrint("lt  ============================= "..r);
	elseif (direction == "rb") then
		r = FishPath:fakeRandom(0,9999)%(#rightBottom)+1;
		points = rightBottom[r];
		-- luaPrint("rb  ============================= "..r);
	else
		r = FishPath:fakeRandom(0,9999)%(#rightTop)+1;
		points = rightTop[r];
		-- luaPrint("rt  ============================ "..r);
	end

	return points;
end

function FishPath:getMDCurvePointRate(startPos, endPos, rate, plus)
	local angle = math.atan2(startPos.y - endPos.y, startPos.x - endPos.x);
	
	if(plus)then
		angle = angle + math.pi/2;
	else
		angle = angle - math.pi/2;
	end
	
	local distance = rate * math.sqrt((startPos.x-endPos.x)*(startPos.x-endPos.x) + (startPos.y-endPos.y)*(startPos.y-endPos.y))/2;
	
	local _x = distance*math.cos(angle);
	local _y = distance*math.sin(angle)/4;

	local Pos=cc.p((startPos.x+endPos.x)/2+_x, (startPos.y+endPos.y)/2+_y)

	return Pos;
end

function FishPath:getReflectPoint(startPos, origin, rate)
	local Pos=cc.p(origin.x+(origin.x-startPos.x)*rate,origin.y+(origin.y-startPos.y)*rate)

	return Pos;
end


function FishPath:genRandMDPoint(startPos, endPos)
	local _r=FishPath:fakeRandom(0,3);
	local start_X=startPos.x;
	local start_Y=startPos.y;
	local end_X=endPos.x;
	local end_Y=endPos.y;
	if(_r==0)then
		local result_X=(end_X-start_X)/3+start_X;
		local result_Y=(end_Y-start_Y)/3+start_Y;
		return cc.p(result_X,result_Y);
	elseif(_r==1)then
		local result_X=(end_X-start_X)/3*2+start_X;
		local result_Y=(end_Y-start_Y)/3*2+start_Y;
		return cc.p(result_X,result_Y);
	else
		local result_X=(end_X-start_X)/2+start_X;
		local result_Y=(end_Y-start_Y)/2+start_Y;
		return cc.p(result_X,result_Y);
	end
end

function FishPath:fakeRandom( startNum, endNum )
	-- luaPrint("randomFakeSeed"..randomFakeSeed);

	return ((randomFakeSeed*131497+35729)%(endNum-startNum)) + startNum;
end

function FishPath:fakeRandomS(random, startNum, endNum)
	return ((random*131497+35729)%(endNum-startNum)) + startNum;
end

return FishPath



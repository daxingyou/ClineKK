local FishMatrix = class("FishMatrix")
local _fishMatrix = nil;

FishMatrixType = {
        BigFishMatrix =100,
        FishMatrixType_101 = 101,
        FishMatrixType_102 = 102,
        FishMatrixType_103 = 103,
        FishMatrixType_104 = 104,
        FishMatrixType_105 = 105,
        FishMatrixType_106 = 106,
        FishMatrixType_107 = 107,
        FishMatrixType_108 = 108,
        FishMatrixMax = 3
};

local BigFishMatrix={
		1,
	   2,2,
	  2,4,2,
	 2,2,2,2,
	7,7,7,7,7,
   7,7,7,7,7,7,
    7,7,7,7,7,
     7,7,7,7,
	  7,7,7,
	    5,
	   5,5 	
};
local BigFishLineDate={1,2,3,4,5,6,5,4,3,1,2}

local FishManager = require("jinchanbuyu.game.core.FishManager"):getInstance();
local FishPath = require("jinchanbuyu.game.core.FishPath"):getInstance();


local winSize = cc.Director:getInstance():getWinSize();

function FishMatrix:getInstance()
    if _fishMatrix == nil then
        _fishMatrix = FishMatrix.new();
    end
    return _fishMatrix;
end

function FishMatrix:createFishMatrix( parent, Matrixtype , fishesInfo)
	luaPrint("Matrixtype :"..Matrixtype.."    --------- 创建鱼阵了--------- #fishesInfo =  "..#fishesInfo);
	Matrixtype = Matrixtype + 101
	if(Matrixtype==FishMatrixType.FishMatrixType_101)then

		return FishMatrix:createFishNewMatrix0(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_102)then

		return FishMatrix:createFishNewMatrix1(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_103)then

		return FishMatrix:createFishNewMatrix2(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_104)then

		return FishMatrix:createFishNewMatrix3(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_105)then

		return FishMatrix:createFishNewMatrix4(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_106)then

		return FishMatrix:createFishNewMatrix5(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_107)then

		return FishMatrix:createFishNewMatrix6(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_108)then

		return FishMatrix:createFishNewMatrix7(parent,fishesInfo);

	elseif(Matrixtype==FishMatrixType.FishMatrixType_109)then
		return FishMatrix:createFishNewMatrix8(parent,fishesInfo);
	end

	return 0;
end

local MatrixFishTypeListNew0={4,
							  4,4,4,4,4,
							  4,4,4,4,4,
							  4,4,4,4,4,
							  4,4,4,4,4,

							  4,
							  -- 3,3,3,3,3,
							  4,4,4,4,4,

							  4,
							  4,4,4,4,4,
							  -- 3,3,3,3,3,

							  4,
							  -- 3,3,3,3,3,
							  4,4,4,4,4,

							  4,
							  -- 3,3,3,3,3,
							  4,4,4,4,4,

							  4,
							  4,
							  -- 3,
							  -- 3,

							  64,
							  18,
							  18,
							  64
							  };

local ox = 50;
local oy = 50;

local posDataNew0={{0,0},--中心四条
					{ox,oy},{ox*2,oy*2},{ox*3,oy*3},{ox*4,oy*4},{ox*5,oy*5},
					{ox,-oy},{ox*2,-oy*2},{ox*3,-oy*3},{ox*4,-oy*4},{ox*5,-oy*5},
					{-ox,oy},{-ox*2,oy*2},{-ox*3,oy*3},{-ox*4,oy*4},{-ox*5,oy*5},
					{-ox,-oy},{-ox*2,-oy*2},{-ox*3,-oy*3},{-ox*4,-oy*4},{-ox*5,-oy*5},

					{ox*6,oy*6},--右上
					-- {ox,oy*11},{ox,oy*10},{ox,oy*9},{ox,oy*8},{ox,oy*7},
					{ox*7,oy*5},{ox*8,oy*4},{ox*9,oy*3},{ox*10,oy*2},{ox*11,oy},

					{ox*6,-oy*6},--右下
					{ox*11,-oy},{ox*10,-oy*2},{ox*9,-oy*3},{ox*8,-oy*4},{ox*7,-oy*5},
					-- {ox*5,-oy*7},{ox*4,-oy*8},{ox*3,-oy*9},{ox*2,-oy*10},{ox,-oy*11},

					{-ox*6,oy*6},--左上
					-- {-ox,oy*11},{-ox*2,oy*10},{-ox*3,oy*9},{-ox*4,oy*8},{-ox*5,oy*7},
					{-ox*7,oy*5},{-ox*8,oy*4},{-ox*9,oy*3},{-ox*10,oy*2},{-ox*11,oy*1},

					{-ox*6,-oy*6},--左下
					-- {-ox,-oy*11},{-ox*2,-oy*10},{-ox*3,-oy*9},{-ox*4,-oy*8},{-ox*5,-oy*7},
					{-ox*7,-oy*5},{-ox*8,-oy*4},{-ox*9,-oy*3},{-ox*10,-oy*2},{-ox*11,-oy*1},

					{-ox*12,0},
					-- {0,oy*12},
					-- {0,-oy*12},
					{ox*12,0},

					{-ox*5-100,-50},
					{ox*0,oy*4.5},
					{ox*0,-oy*4.5},
					{ox*7-100,-50},
			   };

function FishMatrix:createFishNewMatrix0(parent,fishesInfoList)
	if fishesInfoList == nil then
		return;
	end

	--测试数据
	-- local fishList = {};
	-- for i=1,#MatrixFishTypeListNew0 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = MatrixFishTypeListNew0[i]-1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end

	-- fishesInfoList = nil;
	-- fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posDataNew0[i][1];
		local aY=posDataNew0[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-ox*12-visibleSize.width/4+aX, visibleSize.height/2 + aY))
		-- fish:setPosition(cc.p(visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width/4+ox*24+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeListNew1={16,16,16,16,16,16,16,
								19,19,19,
								16,16,16,16,16,16,16,
							  };

local ox = 240;
local oy = 180;

local posDataNew1={{-ox*3,oy},{-ox*2,oy},{-ox*1,oy},{0,oy},{ox*1,oy},{ox*2,oy},{ox*3,oy},
				   {-ox*2,0},{0,0},{ox*2,0},--,{ox,0},{ox*2,0},{ox*3,0},
				   {-ox*3,-oy},{-ox*2,-oy},{-ox*1,-oy},{0,-oy},{ox*1,-oy},{ox*2,-oy},{ox*3,-oy},
			   };

function FishMatrix:createFishNewMatrix1(parent,fishesInfoList)
	if fishesInfoList == nil then
		return;
	end

	-- 测试数据
	-- local fishList = {};
	-- for i=1,#MatrixFishTypeListNew1 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = MatrixFishTypeListNew1[i]-1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end

	-- fishesInfoList = nil;
	-- fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posDataNew1[i][1];
		local aY=posDataNew1[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-ox*6-visibleSize.width/4+aX, visibleSize.height/2 + aY))
		-- fish:setPosition(cc.p(visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width/4+ox*12+aX,visibleSize.height/2+aY));
		-- local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeListNew2={18,

							  2,2,2,2,
							  2,
							  2,2,2,2,

							  18,

							  2,2,2,2,
							  2,
							  2,2,2,2,

							  18,

							  2,2,2,2,
							  2,
							  2,2,2,2,

							  18,

							  2,2,2,2,
							  2,
							  2,2,2,2,
							  };

local ox = 50;
local oy = 50;

local posDataNew2={
					{-ox*28,0},

					{-ox*28,oy*4},{-ox*27,oy*3},{-ox*26,oy*2},{-ox*25,oy*1},
					{-ox*24,0},
					{-ox*28,-oy*4},{-ox*27,-oy*3},{-ox*26,-oy*2},{-ox*25,-oy*1},

					{-ox*20,0},

					{-ox*20,oy*4},{-ox*19,oy*3},{-ox*18,oy*2},{-ox*17,oy*1},
					{-ox*16,0},
					{-ox*20,-oy*4},{-ox*19,-oy*3},{-ox*18,-oy*2},{-ox*17,-oy*1},

					{-ox*12,0},

					{-ox*12,oy*4},{-ox*11,oy*3},{-ox*10,oy*2},{-ox*9,oy*1},
					{-ox*8,0},
					{-ox*12,-oy*4},{-ox*11,-oy*3},{-ox*10,-oy*2},{-ox*9,-oy*1},

					{-ox*4,0},

					{-ox*4,oy*4},{-ox*3,oy*3},{-ox*2,oy*2},{-ox*1,oy*1},
					{0,0},
					{-ox*4,-oy*4},{-ox*3,-oy*3},{-ox*2,-oy*2},{-ox*1,-oy*1},
			   };

function FishMatrix:createFishNewMatrix2(parent,fishesInfoList)
	if fishesInfoList == nil then
		return;
	end

	--测试数据
	-- local fishList = {};
	-- for i=1,#MatrixFishTypeListNew2 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = MatrixFishTypeListNew2[i]-1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end

	-- fishesInfoList = nil;
	-- fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posDataNew2[i][1]+ox*11;
		local aY=posDataNew2[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-ox*6-visibleSize.width/2+aX, visibleSize.height/2 + aY))
		-- fish:setPosition(cc.p(visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width/4+ox*13+aX,visibleSize.height/2+aY));
		-- local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeListNew3={1,1,1,
							  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
							  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,

							  18,17,17,
							  18,17,17,
							  18,17,17,

							  1,1,1,
							  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
							  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
							  };

local ox = 30;
local oy = 100;

local posDataNew3={
					{ox*19,oy*2},{ox*20,oy*2},{ox*21,oy*2},
					{ox*14,oy*2},{ox*15,oy*2},{ox*16,oy*2},{ox*17,oy*2},{ox*18,oy*2},
					{ox*9,oy*2},{ox*10,oy*2},{ox*11,oy*2},{ox*12,oy*2},{ox*13,oy*2},
					{ox*4,oy*2},{ox*5,oy*2},{ox*6,oy*2},{ox*7,oy*2},{ox*8,oy*2},
					{-ox*1,oy*2},{-ox*0,oy*2},{ox*1,oy*2},{ox*2,oy*2},{ox*3,oy*2},

					{-ox*2,oy*2},{-ox*3,oy*2},{-ox*4,oy*2},{-ox*5,oy*2},{-ox*6,oy*2},
					{-ox*7,oy*2},{-ox*8,oy*2},{-ox*9,oy*2},{-ox*10,oy*2},{-ox*11,oy*2},
					{-ox*12,oy*2},{-ox*13,oy*2},{-ox*14,oy*2},{-ox*15,oy*2},{-ox*16,oy*2},
					{-ox*17,oy*2},{-ox*18,oy*2},{-ox*19,oy*2},{-ox*20,oy*2},{-ox*21,oy*2},

					{-ox*8,0},{0,oy*0.8},{0,-oy*0.8},

					{-ox*8-600,0},{-600,oy*0.8},{-600,-oy*0.8},

					{-ox*8-1200,0},{-1200,oy*0.8},{-1200,-oy*0.8},

					{ox*19,-oy*2},{ox*20,-oy*2},{ox*21,-oy*2},
					{ox*14,-oy*2},{ox*15,-oy*2},{ox*16,-oy*2},{ox*17,-oy*2},{ox*18,-oy*2},
					{ox*9,-oy*2},{ox*10,-oy*2},{ox*11,-oy*2},{ox*12,-oy*2},{ox*13,-oy*2},
					{ox*4,-oy*2},{ox*5,-oy*2},{ox*6,-oy*2},{ox*7,-oy*2},{ox*8,-oy*2},
					{-ox*1,-oy*2},{-ox*0,-oy*2},{ox*1,-oy*2},{ox*2,-oy*2},{ox*3,-oy*2},

					{-ox*2,-oy*2},{-ox*3,-oy*2},{-ox*4,-oy*2},{-ox*5,-oy*2},{-ox*6,-oy*2},
					{-ox*7,-oy*2},{-ox*8,-oy*2},{-ox*9,-oy*2},{-ox*10,-oy*2},{-ox*11,-oy*2},
					{-ox*12,-oy*2},{-ox*13,-oy*2},{-ox*14,-oy*2},{-ox*15,-oy*2},{-ox*16,-oy*2},
					{-ox*17,-oy*2},{-ox*18,-oy*2},{-ox*19,-oy*2},{-ox*20,-oy*2},{-ox*21,-oy*2},
			   };

local rota = {
			  90,90,90,
			  90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,
			  90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,
			  0,0,0,
			  0,0,0,
			  0,0,0,
			  -90,-90,-90,
			  -90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,
			  -90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,-90,
}			   

function FishMatrix:createFishNewMatrix3(parent,fishesInfoList)
	if fishesInfoList == nil then
		return;
	end

	--测试数据
	-- local fishList = {};
	-- for i=1,#MatrixFishTypeListNew3 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = MatrixFishTypeListNew3[i]-1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end

	-- fishesInfoList = nil;
	-- fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posDataNew3[i][1]+ox*4+600;
		local aY=posDataNew3[i][2];

		if fishType == 0 then
			aX=posDataNew3[i][1];
		end

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		if fishType ~= 0 then
			fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY))
		else
			fish:setPosition(cc.p(visibleSize.width/2+aX, visibleSize.height/2 + aY + 200*(rota[i]/90)))
		end		
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};

		fish:setRotation(rota[i]);
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		
		if fishType == 0 then
			action = cc.MoveTo:create(200/50,cc.p(visibleSize.width/2+aX, visibleSize.height/2 + aY));
			action = cc.Sequence:create(action, cc.DelayTime:create(30), cc.MoveBy:create(700/50,cc.p(0,-700*(rota[i]/90))))
		end
		table.insert(fish._fishPath,action);
		fish:goFish();
		
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

-- local MatrixFishTypeListNew4={2,

-- 							  2,2,2,2,2,2,
-- 							  2,2,2,2,2,2,

-- 							  2,2,2,
-- 							  2,2,2,

-- 							  2,2,2,
-- 							  2,

-- 							  3,
-- 							  3,3,3,3,
-- 							  3,3,3,3,
-- 							  3,3,3,
						
-- 							  };

-- local ox = 30;
-- local oy = 30;

-- local rad = 150;

-- local jiaodu = {15,30,45,60,75,90,115,130,145};

-- local yx = rad+ox*5;
-- local yy = -rad*math.sin(math.rad(jiaodu[4]))+oy*3;

-- local yox = 50;
-- local yoy = 50;

-- local posDataNew4={
-- 					{-rad,0},

-- 					{-rad*math.cos(math.rad(jiaodu[1])), rad*math.sin(math.rad(jiaodu[1]))},
-- 					{-rad*math.cos(math.rad(jiaodu[2])), rad*math.sin(math.rad(jiaodu[2]))},
-- 					{-rad*math.cos(math.rad(jiaodu[3])), rad*math.sin(math.rad(jiaodu[3]))},
-- 					{-rad*math.cos(math.rad(jiaodu[4])), rad*math.sin(math.rad(jiaodu[4]))},
-- 					{-rad*math.cos(math.rad(jiaodu[5])), rad*math.sin(math.rad(jiaodu[5]))},
-- 					{-rad*math.cos(math.rad(jiaodu[6])), rad*math.sin(math.rad(jiaodu[6]))},

-- 					{-rad*math.cos(math.rad(jiaodu[1])), -rad*math.sin(math.rad(jiaodu[1]))},
-- 					{-rad*math.cos(math.rad(jiaodu[2])), -rad*math.sin(math.rad(jiaodu[2]))},
-- 					{-rad*math.cos(math.rad(jiaodu[3])), -rad*math.sin(math.rad(jiaodu[3]))},
-- 					{-rad*math.cos(math.rad(jiaodu[4])), -rad*math.sin(math.rad(jiaodu[4]))},
-- 					{-rad*math.cos(math.rad(jiaodu[5])), -rad*math.sin(math.rad(jiaodu[5]))},
-- 					{-rad*math.cos(math.rad(jiaodu[6])), -rad*math.sin(math.rad(jiaodu[6]))},

-- 					{rad*math.cos(math.rad(jiaodu[6])), rad*math.sin(math.rad(jiaodu[6]))},
-- 					{rad*math.cos(math.rad(jiaodu[5])), rad*math.sin(math.rad(jiaodu[5]))},
-- 					{rad*math.cos(math.rad(jiaodu[4])), rad*math.sin(math.rad(jiaodu[4]))},

-- 					{rad*math.cos(math.rad(jiaodu[6])), -rad*math.sin(math.rad(jiaodu[6]))},
-- 					{rad*math.cos(math.rad(jiaodu[5])), -rad*math.sin(math.rad(jiaodu[5]))},
-- 					{rad*math.cos(math.rad(jiaodu[4])), -rad*math.sin(math.rad(jiaodu[4]))},

-- 					{rad*math.cos(math.rad(jiaodu[4])), -rad*math.sin(math.rad(jiaodu[4]))+oy},
-- 					{rad*math.cos(math.rad(jiaodu[4])), -rad*math.sin(math.rad(jiaodu[4]))+oy*2},
-- 					{rad*math.cos(math.rad(jiaodu[4])), -rad*math.sin(math.rad(jiaodu[4]))+oy*3},

-- 					{rad*math.cos(math.rad(jiaodu[4]))-ox*2, -rad*math.sin(math.rad(jiaodu[4]))+oy*3},

-- 					{yx,yy},
-- 					{yx-yox,yy+yoy},{yx-yox*2,yy+yoy*2},{yx-yox*3,yy+yoy*3},{yx-yox*4,yy+yoy*4},--{yx-ox*5,yy+oy*5},
-- 					{yx+yox,yy+yoy},{yx+yox*2,yy+yoy*2},{yx+yox*3,yy+yoy*3},{yx+yox*4,yy+yoy*4},--{yx+ox*5,yy+oy*5},
-- 					{yx,yy-yoy},{yx,yy-yoy*2},{yx,yy-yoy*3}--,{yx,yy-oy*4},
-- 			   };

-- function FishMatrix:createFishNewMatrix4(parent,fishesInfoList)
-- 	if fishesInfoList == nil then
-- 		return;
-- 	end

-- 	--测试数据
-- 	-- local fishList = {};
-- 	-- for i=1,#MatrixFishTypeListNew4 do
-- 	-- 	local fishInfo = {};
-- 	-- 	fishInfo.fishKind = MatrixFishTypeListNew4[i]-1;
-- 	-- 	fishInfo.fishID = 1000+i;
-- 	-- 	fishList[i] = fishInfo;
-- 	-- end

-- 	-- fishesInfoList = nil;
-- 	-- fishesInfoList = fishList;

-- 	local visibleSize = cc.Director:getInstance():getWinSize();

-- 	for i,item in ipairs(fishesInfoList) do
-- 		local fishType=item.fishKind;

-- 		local aX=posDataNew4[i][1];
-- 		local aY=posDataNew4[i][2];

-- 		local fish = FishManager:createSpecificFish(parent,fishType,0);
-- 		-- fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY))
-- 		fish:setPosition(cc.p(rad+aX, visibleSize.height/2 + aY))
-- 		parent.fishLayer:addChild(fish,fishType);

-- 		fish._fishPath = {};
-- 		-- local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width/4+ox*12+aX,visibleSize.height/2+aY));
-- 		-- table.insert(fish._fishPath,action);
-- 		-- fish:goFish();
-- 		fish:setFlipScreen(FLIP_FISH);

-- 		fish:setFishID(item.fishID);
-- 		parent.fishData[ item.fishID ] = fish;
-- 	end

-- 	return 50;
-- end

--39鱼
local MatrixFishTypeList4={11,11,11,11,11,11,11,11,11,11,11,11,
						   59,
						   11,11,11,11,11,11,11,11,11,11,11,11,
						   59,
						   11,11,11,11,11,11,11,11,11,11,11,11,
						   59};

local radius = 250
local x1,x2,x3 = 720,0,-720;
local cosx,sinx = math.cos(math.rad(30)),math.sin(math.rad(30));
local posData4={{x1-radius,0},{x1-radius*cosx,radius*sinx}, {x1-radius*sinx,radius*cosx},
				{x1,radius},  {x1+radius*sinx,radius*cosx}, {x1+radius*cosx,radius*sinx},
				{x1+radius,0},{x1+radius*cosx,-radius*sinx},{x1+radius*sinx,-radius*cosx},
				{x1,-radius}, {x1-radius*sinx,-radius*cosx},{x1-radius*cosx,-radius*sinx},
			   	{x1,0},
			   	{x2-radius,0},{x2-radius*cosx,radius*sinx}, {x2-radius*sinx,radius*cosx},
			   	{x2,radius},  {x2+radius*sinx,radius*cosx}, {x2+radius*cosx,radius*sinx},
				{x2+radius,0},{x2+radius*cosx,-radius*sinx},{x2+radius*sinx,-radius*cosx},
				{x2,-radius}, {x2-radius*sinx,-radius*cosx},{x2-radius*cosx,-radius*sinx},
			   	{x2,0},
			   	{x3-radius,0},{x3-radius*cosx,radius*sinx}, {x3-radius*sinx,radius*cosx},
			   	{x3,radius},  {x3+radius*sinx,radius*cosx}, {x3+radius*cosx,radius*sinx},
				{x3+radius,0},{x3+radius*cosx,-radius*sinx},{x3+radius*sinx,-radius*cosx},
				{x3,-radius}, {x3-radius*sinx,-radius*cosx},{x3-radius*cosx,-radius*sinx},
			   	{x3,0},
			   };

--小乌龟，大海龟
function FishMatrix:createFishNewMatrix4(parent,fishesInfoList)

	--测试数据
	-- local fishList = {};
	-- for i=1,#MatrixFishTypeList4 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = MatrixFishTypeList4[i]-1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end

	-- fishesInfoList = nil;
	-- fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData4[i][1];
		local aY=posData4[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY));
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList5={
							6,6,6,6,
							16,5,16,5,16,5,16,
							6,6,6,6,
						};

local ox = 200;
local oy = 220;

local posData5={{-ox*3-15,oy},{-ox-15,oy},{ox+15,oy},{ox*3+15,oy},
				{-ox*3-20,0},{-ox*2,0},{-ox-20,0},{0,0},{ox-20,0},{ox*2,0},{ox*3-20,0},
				{-ox*3-15, -oy},{-ox-15,-oy},{ox+15,-oy},{ox*3+15,-oy},
			   };

function FishMatrix:createFishNewMatrix5(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList5 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList5[i]-1;
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData5[i][1];
		local aY=posData5[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		fish:setPosition(cc.p(-visibleSize.width + aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList6={
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,
						};
local disX = cc.Director:getInstance():getWinSize().width/2;
local disY = cc.Director:getInstance():getWinSize().height/2;

local posData6={{0+disX,-disX*2+disY},{-disX*2/1.41+disX,-disX*2/1.41+disY},{-disX*2+disX,0+disY},{-disX*2/1.41+disX,disX*2/1.41+disY},
				{0+disX,disX*2+disY},{disX*2/1.41+disX,disX*2/1.41+disY},{disX*2+disX,0+disY},{disX*2+disX,-disX*2/1.41+disY}
			   };

function FishMatrix:createFishNewMatrix6(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList6 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList6[i]-1;
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local k = i%8+1
		local kk = math.floor((i-1)/8)
		-- luaPrint("k = ",k,"kk = ",kk)
		local fishType=item.fishKind;

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		fish:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
		parent.fishLayer:addChild(fish);
		
		fish:setVisible(false)
		performWithDelay(FishManager:getGameLayer(),function()
			if fish.fishShadow then
				fish.fishShadow:setVisible(false)
			end		
		end,0.02)

		fish._fishPath = {};
		local delayTime = cc.DelayTime:create(2.5*kk)
		table.insert(fish._fishPath,delayTime);
		-- local fadein = cc.FadeIn:create(0.5)
		local func = cc.CallFunc:create(function() 
			fish:setVisible(true)
			if fish.fishShadow then
				fish.fishShadow:setVisible(true)
			end
		end)
		table.insert(fish._fishPath,func);
		-- table.insert(fish._fishPath,fadein);
		local action = cc.MoveTo:create(25,cc.p(posData6[k][1],posData6[k][2]) );
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;	

	end

	return 50;
end

local MatrixFishTypeList7={
							6,6,6,6,6,6,6,
							2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
							2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
							6,6,6,6,6,6,6,
						};

local ox = 200;
local oy = 100;

local posData7={{-ox*3,oy*2},{-ox*2,oy*2},{-ox,oy*2},{0,oy*2},{ox,oy*2},{ox*2,oy*2},{ox*3,oy*2},
				{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},
				{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},{ox*3,0},
				{-ox*3,-oy*2},{-ox*2,-oy*2},{-ox,-oy*2},{0,-oy*2},{ox,-oy*2},{ox*2,-oy*2},{ox*3,-oy*2},
			   };

function FishMatrix:createFishNewMatrix7(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList7 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList7[i]-1;
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData7[i][1];
		local aY=posData7[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		fish:setPosition(cc.p(-visibleSize.width + aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish);
		
		fish._fishPath = {};
		local mby1 = cc.MoveBy:create(2,cc.p(0,oy+10))
		local mby2 = cc.MoveBy:create(2,cc.p(0,-(oy+10)))
		
		if i>7 and i<= 23 then
			local delaytime = cc.DelayTime:create((i-8)*1)
			fish:runAction(cc.Sequence:create(delaytime,cc.Repeat:create(cc.Sequence:create(mby1,mby2,mby2,mby1),50)))
			table.insert(fish._fishPath,delaytime);
		elseif i>23 and i<= 39 then
			local delaytime = cc.DelayTime:create((i-24)*1)
			fish:runAction(cc.Sequence:create(delaytime,cc.Repeat:create(cc.Sequence:create(mby2,mby1,mby1,mby2),50)))
			-- fish:runAction(cc.RepeatForever:create(cc.Sequence:create(mby2,mby1,mby1,mby2)))
			table.insert(fish._fishPath,delaytime);
		end
		
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList8={
							4,4,4,4,4,4,4,4,4,4,
							4,4,4,4,4,4,4,4,4,4,
							6,6,6,6,6,6,6,6,6,6,
							6,6,6,6,6,6,6,6,6,6,
						};

function FishMatrix:createFishNewMatrix8(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList8 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList8[i]-1;
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		
		local fishType=item.fishKind;

		local count = 20;
		local angle = 360/count;
		local radius = 150;
		if i>count then
			radius = 240;
		end

		local fish = FishManager:createSpecificFish(parent,fishType,1);
		fish:setPosition(cc.p(visibleSize.width/2 + radius * math.cos(math.rad(angle * i)), visibleSize.height/2 + radius * math.sin(math.rad(angle * i))))
		parent.fishLayer:addChild(fish);
		
		-- fish:setVisible(false)
		-- performWithDelay(FishManager:getGameLayer(),function()
		-- 	if fish.fishShadow then
		-- 		fish.fishShadow:setVisible(false)
		-- 	end		
		-- end,0.02)
		
		fish._fishPath = {};

		for m=1,count*4 do
			local n = ((i*4+m-1)%(count*4)+1)*angle/4
			local delayTime1 = cc.DelayTime:create((m-1)*0.1);
			local moveto1 = cc.MoveTo:create(0.1,cc.p(radius * math.cos(math.rad(n))+visibleSize.width/2,radius * math.sin(math.rad(n))+visibleSize.height/2));
			local action1 = cc.Sequence:create(delayTime1,moveto1);
			fish:runAction(action1);
		end

		-- local delayTime = cc.DelayTime:create((i%count+1)*0.5)

		local delayTime = cc.DelayTime:create(4*count*0.1)
		table.insert(fish._fishPath,delayTime);

		-- local func = cc.CallFunc:create(function() 
		-- 	fish:setVisible(true)
		-- 	if fish.fishShadow then
		-- 		fish.fishShadow:setVisible(true)
		-- 	end
		-- end)
		-- table.insert(fish._fishPath,func);

		-- local cirCleBy = CirCleBy:create(10,cc.p(visibleSize.width/2,visibleSize.height/2),radius)
		-- table.insert(fish._fishPath,cirCleBy);

		local action = cc.MoveTo:create((50-4*count*0.1)*0.5,cc.p(visibleSize.width * math.cos(math.rad(angle * i))+visibleSize.width/2,visibleSize.width * math.sin(math.rad(angle * i))+visibleSize.height/2) );
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;	

	end

	return 50;
end

--水平移动（五个一排）
function FishMatrix:createNormalMatrix(parent,fishesInfo)
	if(fishesInfo==nil or #fishesInfo<60)then
		luaPrint("createNormalMatrix error  fishesInfo number < 60");
	end
	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=0;
	for i,item in ipairs(fishesInfo) do
		local fishType=item.fishKind;
		local line=(i-1)%5;
		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setFishID(item.fishID);
		fish._fishPath = {};
		fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+50*(line-2)))
		local action = cc.MoveTo:create(40, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+50*(line-2)));
		table.insert(fish._fishPath,action);
		fish:goFish();
		parent.fishLayer:addChild(fish);
		parent.fishData[ item.fishID ] = fish;
		-- fish:setFlippedX(FLIP_FISH);

		fish:setFlipScreen(FLIP_FISH);

		if(line==4)then
			offsetX=offsetX+fish._radius*2+10;
		end
	end
end

--菱形阵型
function FishMatrix:createBigFishMatrix(parent,fishesInfo)

	dumps(fishesInfo);
	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;
	for k, line in ipairs(BigFishLineDate) do 
		for i=1, line do
			local item=fishesInfo[fishIndex];
			local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
			fish._fishPath = {};
			fish:setFishID(item.fishID);
			fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+(line-1)*25-(i-1)*50))
			local action = cc.MoveTo:create(60, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+(line-1)*25-(i-1)*50));
			table.insert(fish._fishPath,cc.DelayTime:create(5));
			table.insert(fish._fishPath,action);
			fish:goFish();
			parent.fishLayer:addChild(fish);
			parent.fishData[ item.fishID ] = fish;
			-- fish:setFlippedX(FLIP_FISH);
			fish:setFlipScreen(FLIP_FISH);

			fishIndex=fishIndex+1;
			offsetX_V=fish._radius*2*2/3;
		end
		offsetX=offsetX+offsetX_V;
	end
end

local bombMatrixFish={15,15,15,15,15,15,15,15,9,9,9,9,9,9,9,9,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,23};
local unitDistance = 35;
local distanceData={{6,4},{-8,4},{6,-4},{-8,-4},{3,7},{-5,7},{3,-7},{-5,-7},
					{4,4},{-4,4},{4,-4},{-4,-4},{6,0},{-6,0},{0,6},{0,-6},
					{4,2},{-4,2},{4,-2},{-4,-2},{2,4},{-2,4},{2,-4},{-2,-4},
					{2,2},{-2,2},{2,-2},{-2,-2},{3,0},{-3,0},{0,3},{0,-3},
					{0,0}};

--五角星水平移动
function FishMatrix:createBombMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	for i,item in ipairs(fishesInfo) do
		-- local item=fishesInfo[fishIndex];
		local fishType=item.fishKind;
		-- local fishtype=bombMatrixFish[i];
		local aX=distanceData[i][1]*unitDistance;
		local aY=distanceData[i][2]*unitDistance;

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2+aX, visibleSize.height/2+aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width/2+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end
end

--大鱼在中间  四周小鱼
function FishMatrix:createBigRingMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfo)  do
		local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
		parent.fishLayer:addChild(fish);
		if i~=121 then
			FishPath:generateFishPathE(fish,i,true);
			local _delay=0.2*(i-1)+5;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));
		else
			fish._fishPath={};
			fish:setPosition(cc.p(-260, visibleSize.height/2));
			local action1 = cc.MoveTo:create(8, cc.p(visibleSize.width/2,visibleSize.height/2));
			local action2 = cc.MoveTo:create(6, cc.p(visibleSize.width+300,visibleSize.height/2));
			table.insert(fish._fishPath,action1);
			table.insert(fish._fishPath,cc.DelayTime:create(30));
			table.insert(fish._fishPath,action2);
			fish:setFlipScreen(FLIP_FISH);
		end

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
		fish:goFish();
	end

end

function FishMatrix:createSineMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	-- for i=1,30 do
	-- 	local fish = FishManager:createSpecificFish(parent,10,0);

	-- 	FishPath:generateFishPathI(fish,i,true,4);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/1.5*(i-1);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,30 do
	-- 	local fish = FishManager:createSpecificFish(parent,10,0);

	-- 	FishPath:generateFishPathI(fish,i,false,4);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/1.5*(i-1);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,60 do
	-- 	local fish = FishManager:createSpecificFish(parent,0,0);

	-- 	FishPath:generateFishPathI(fish,i,true,8);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/2*(i-1)+20/8;
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,60 do
	-- 	local fish = FishManager:createSpecificFish(parent,0,0);

	-- 	FishPath:generateFishPathI(fish,i,false,8);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/2*(i-1)+20/8;
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,5 do
	-- 	local fish = FishManager:createSpecificFish(parent,15+i,0);
	-- 	parent.fishLayer:addChild(fish);
	-- 	fish._fishPath={};
	-- 	fish:setPosition(cc.p(-i*260, visibleSize.height/2));
	-- 	local action = cc.MoveTo:create(60, cc.p(visibleSize.width*3-i*260,visibleSize.height/2));
	-- 	table.insert(fish._fishPath,action);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(10));		
	-- 	fish:setFlipScreen(FLIP_FISH);
	-- 	fish:goFish();
	-- end

	for i,item in ipairs(fishesInfo) do
		local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
		parent.fishLayer:addChild(fish);
		fish._fishPath={};

		if(i<=30)then
			FishPath:generateFishPathI(fish,i,true,4);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/1.5*(i-1);
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));	
		elseif(i<=60)then
			FishPath:generateFishPathI(fish,i,false,4);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/1.5*(i-30-1);
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));
		elseif(i<=120)then
			FishPath:generateFishPathI(fish,i-60,true,8);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/2*(i-60-1)+20/8;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
		elseif(i<=180)then
			FishPath:generateFishPathI(fish,i-120,false,8);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/2*(i-120-1)+20/8;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
		elseif(i<=185)then
			fish:setPosition(cc.p(-(i-180)*260, visibleSize.height/2));
			local action = cc.MoveTo:create(60, cc.p(visibleSize.width*3-(i-180)*260,visibleSize.height/2));
			table.insert(fish._fishPath,action);
			table.insert(fish._fishPath,1,cc.DelayTime:create(10));		
			fish:setFlipScreen(FLIP_FISH);
		end

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
		fish:goFish();
	end
end


function FishMatrix:createDefaultMatrix(parent,fishesInfo)

	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=0;
	for i,item in ipairs(fishesInfo) do
		local fishType=item.fishKind;
		local fishID=item.fishID;
		local line=i%5;
		local fish = FishManager:createSpecificFish(parent,fishType,0);

		fish._fishPath = {};
		fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+50*(line-2)))
		local action = cc.MoveTo:create(40, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+50*(line-2)));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFishID(fishID);
		parent.fishLayer:addChild(fish);
		parent.fishData[fishID] = fish;
		-- fish:setFlippedX(FLIP_FISH);
		fish:setFlipScreen(FLIP_FISH);
		if(line==4)then
			offsetX=offsetX+fish._radius*2+10;
		end
	end
end

function FishMatrix:createTestMatrix(parent)

	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=10;
	for i=1,newFishMax do
		local line=i%5;
		local fish = FishManager:createSpecificFish(parent,i-1,0);
		fish:setPosition(cc.p(visibleSize.width-offsetX, visibleSize.height/2+50*(line-2)))
		parent.fishLayer:addChild(fish);
		if(line==4)then
			offsetX=offsetX+fish._radius*2;
		end
	end
end

local MatrixFishTypeList1={16,15,15,17,15,15,19,16};

local posData1={{900+100,0},{670,160},{670,-160},{600,0},
				{360-100,160},{360-100,-160},{380-100,30},{100-200,0}};

--小鱼围绕大鲨鱼
function FishMatrix:creteTestMatrix1(parent,fishesInfoList)
	--测试数据
	local fishList = {};
	for i=1,8 do
		local fishInfo = {};
		fishInfo.fishKind = (MatrixFishTypeList1[i]);
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData1[i][1];
		local aY=posData1[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList2={9,9,15,3,3,9,9,3,3,16,9,9,3,3,15,9,9};

local posData2={{950,180},{950,-180},{850,0},{780,180},{780,-180},{640,180},{640,-180},
			   {500,180},{500,-180},{500,0},{360,180},{360,-180},{220,180},{220,-180},
			   {150,0},{60,180},{60,-180}};

--乌龟鲨鱼
function FishMatrix:creteTestMatrix2(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,17 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList2[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData2[i][1];
		local aY=posData2[i][2];

		--luaPrint("ax = "..aX.."  ay = "..aY);

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

--25鱼
local MatrixFishTypeList3={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
						   2,2,2,2,2,2,2,2,
						   19,
						   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
						   2,2,2,2,2,2,2,2,
						   19};

local scale = 1.2
local posData3={{1000-20*scale,0},{1000-50*scale,45*scale},{1000-50*scale,-45*scale},{1000-85*scale,85*scale},{1000-85*scale,-85*scale},{1000-70*2*scale,70*2*scale-20},{1000-70*2*scale,-70*2*scale+20},{1000-70*3*scale,70*3*scale-60},{1000-70*3*scale,-70*3*scale+60},{1000-70*4*scale,70*4*scale-120},{1000-70*4*scale,-70*4*scale+120},{1000-70*5*scale,70*3*scale-60},
			   {1000-70*5*scale,-70*3*scale+60},{1000-70*6*scale,70*2*scale-20},{1000-70*6*scale,-70*2*scale+20},{1000-70*7*scale+20,85*scale},{1000-70*7*scale+20,-85*scale},{1000-70*7*scale-20,45*scale},{1000-70*7*scale-20,-45*scale},{1000-70*8*scale+20,0},
			   {895,0}, {895-(360/4*1)*scale+30,65*1*scale+10},{895-(360/4*1)*scale+30,-65*1*scale-10}, {895-(360/4*2)*scale,65*2*scale-20},{895-(360/4*2)*scale,-65*2*scale+20}, {895-(360/4*3)*scale-30,65*1*scale+10},{895-(360/4*3)*scale-30,-65*1*scale-10}, {895-(360/4*4)*scale,0},
			   {720,0},
			   {290-20*scale,0},{290-50*scale,45*scale},{290-50*scale,-45*scale},{290-85*scale,85*scale},{290-85*scale,-85*scale},{290-70*2*scale,70*2*scale-20},{290-70*2*scale,-70*2*scale+20},{290-70*3*scale,70*3*scale-60},{290-70*3*scale,-70*3*scale+60},{290-70*4*scale,70*4*scale-120},{290-70*4*scale,-70*4*scale+120},{290-70*5*scale,70*3*scale-60},
			   {290-70*5*scale,-70*3*scale+60},{290-70*6*scale,70*2*scale-20},{290-70*6*scale,-70*2*scale+20},{290-70*7*scale+20,85*scale},{290-70*7*scale+20,-85*scale},{290-70*7*scale-20,45*scale},{290-70*7*scale-20,-45*scale},{290-70*8*scale+20,0},
			   {185,0}, {185-(360/4*1)*scale+30,65*1*scale+10},{185-(360/4*1)*scale+30,-65*1*scale-10}, {185-(360/4*2)*scale,65*2*scale-20},{185-(360/4*2)*scale,-65*2*scale+20}, {185-(360/4*3)*scale-30,65*1*scale+10},{185-(360/4*3)*scale-30,-65*1*scale-10}, {185-(360/4*4)*scale,0},
			   {10,0}
			   };

--大鲨鱼
function FishMatrix:creteTestMatrix3(parent,fishesInfoList)
	--测试数据
	local fishList = {};
	for i=1,58 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList3[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData3[i][1];
		local aY=posData3[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList4={17,7,7,7,7,7,7,7,7,7,7,7,7};
local item4Height = 170
local posData4={{0,0},
				{360, 80},{360-150*1, 130},{360-150*2, item4Height},{360-150*3, item4Height},{360-150*4, 130},{360-150*5, 80},
				{360,-80},{360-150*1,-130},{360-150*2,-item4Height},{360-150*3,-item4Height},{360-150*4,-130},{360-150*5,-80}
			   };

--美人鱼
function FishMatrix:creteTestMatrix4(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,13 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList4[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData4[i][1];
		local aY=posData4[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList5={25,25,24,24,24,24,24,24,24,24};

local posData5={{0,0},{-200,0},
				{185,  0},{360-165*2, 160},{360-165*3, 170},{360-165*4, 160},
				{-400, 0},{360-165*2,-160},{360-165*3,-170},{360-165*4,-160},
			   };

--话费
function FishMatrix:creteTestMatrix5(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,10 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList5[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData5[i][1];
		local aY=posData5[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList6={18,14,14,14,14,6,6,6,6,6,6};

local posData6={{0,0},
				{300,120},{300,-120},{-300,120},{-300,-120},
				{240,  210},{70, 190},{-90, 110},
				{240, -210},{70,-190},{-90,-110},
			   };


function FishMatrix:creteTestMatrix6(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,11 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList6[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData6[i][1];
		local aY=posData6[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2+aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList7={15,15,
							8,8,8,11,11,11,
							12,12,12,9,9,9,
							24,24,24,
							24,24,24,
							25,
							};


local posData7={{0,0},{-850,0},
				{-110,130},{-240,190},{-340,130},{-530,130},{-650,190},{-770,130},
				{-110,-130},{-240,-190},{-340,-130},{-530,-130},{-650,-190},{-770,-130},
				{-190, 60},{-190,-60},{-300,0},
				{-640, 60},{-640,-60},{-530,-0},
				{-420, 0},
			   };


function FishMatrix:creteTestMatrix7(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList7 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList7[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData7[i][1];
		local aY=posData7[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2 + aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

local MatrixFishTypeList8={16,18,
							12,16,
							25,25,
							12,16,
							};


local posData8={{0,0},{-620,0},
				{-70,140},{-350,140},
				{-240,0},{-390,0},
				{-70, -140},{-350,-140},
			   };


function FishMatrix:creteTestMatrix8(parent,fishesInfoList)
	
	--测试数据
	local fishList = {};
	for i=1,#MatrixFishTypeList8 do
		local fishInfo = {};
		fishInfo.fishKind = MatrixFishTypeList8[i];
		fishInfo.fishID = 1000+i;
		fishList[i] = fishInfo;
	end

	fishesInfoList = nil;
	fishesInfoList = fishList;

	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfoList) do
		local fishType=item.fishKind;

		local aX=posData8[i][1];
		local aY=posData8[i][2];

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2 + aX, visibleSize.height/2 + aY))
		parent.fishLayer:addChild(fish,fishType);

		fish._fishPath = {};
		local action = cc.MoveTo:create(50, cc.p(visibleSize.width+visibleSize.width+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end

	return 50;
end

return FishMatrix
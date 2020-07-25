
local ChipNodeManager = class("ChipNodeManager");

local _chipNodeManager = nil;

function ChipNodeManager:getInstance(tableLayer)
    if _chipNodeManager == nil then
        _chipNodeManager = ChipNodeManager.new(tableLayer);
    end
    return _chipNodeManager;
end

function ChipNodeManager:ctor(tableLayer)
	self:init(tableLayer)
end

function ChipNodeManager:init(tableLayer)

	self.tableLayer = tableLayer
	self:initData();
	
end

function ChipNodeManager:initData()
	self.ChipNodeTable = {};

	local zpos = self.tableLayer.Text_zhuangGold:getParent():convertToWorldSpace(cc.p(self.tableLayer.Text_zhuangGold:getPosition()));--cc.p(300,580) -- 庄家位置
	local mpos = self.tableLayer.Node_1:getParent():convertToWorldSpace(cc.p(self.tableLayer.Node_1:getPosition()));--cc.p(110,65) --自己的位置
	local opos = self.tableLayer.Button_otherWanjia:getParent():convertToWorldSpace(cc.p(self.tableLayer.Button_otherWanjia:getPosition()));--cc.p(45,580) --其他用户的位置
	self.ZhuangPos = self.tableLayer.Node_3:convertToNodeSpace(zpos);
	self.mePos = self.tableLayer.Node_3:convertToNodeSpace(mpos);
	self.otherPos = self.tableLayer.Node_3:convertToNodeSpace(opos);
	--下注区域
	self.checkChipPos = {cc.p(320,455),cc.p(320,300),cc.p(540,455),cc.p(550,295),
						 cc.p(770,455),cc.p(780,295),cc.p(990,455),cc.p(970,310)};

	self.ChipCreateCacheTable = {};
	self.OneXiazhuNum = 10; --定时器一次下注的筹码数量
	self.ChipCreateCheduler = nil;
end

--最后一秒将剩余的筹码全部下注
function ChipNodeManager:showAllCreateChip()
	for k,msg in pairs(self.ChipCreateCacheTable) do
		local chip = self:ChipCreate(msg.createType,msg.chipType,msg.xiazhuType,msg.random,msg.isMe,true)
		self:ChipMove(chip,3,msg.xiazhuType,true)
	end
	self:claerCreateChip();
end

function ChipNodeManager:claerCreateChip()
	self.ChipCreateCacheTable = {};
end

--启动一个定时器每隔0.5秒下注10个筹码
function ChipNodeManager:startChipScheduler()
	--self:stopChipScheduler();
	local ChipCreateCheduler = schedule(self.tableLayer, function() 
		if #self.ChipCreateCacheTable ~= 0 then 
			local msg = self.ChipCreateCacheTable[1];
			if msg then
				local chip = self:ChipCreate(msg.createType,msg.chipType,msg.xiazhuType,msg.random,msg.isMe,true)
				local isRandom = true;
				if msg.createType ~= 3 then--直接创建在下注区域的筹码不需要移动
					self:ChipMove(chip,3,msg.xiazhuType,isRandom)
				end
				
				table.removebyvalue(self.ChipCreateCacheTable,msg)
			end
	    end
    end, 1/15)
end

function ChipNodeManager:stopChipScheduler()
	if self.ChipCreateCheduler then
		self.tableLayer:stopAction(self.ChipCreateCheduler)
	    self.ChipCreateCheduler = nil;
	end
end

function ChipNodeManager:getNeedCreatChip()
	local chipTable = {};
	if #self.ChipCreateCacheTable <= self.OneXiazhuNum then
		chipTable = self.ChipCreateCacheTable;
 		self.ChipCreateCacheTable = {}
	else
		for index,msg in pairs(self.ChipCreateCacheTable) do
			if #chipTable <= self.OneXiazhuNum then
				table.remove(self.ChipCreateCacheTable,index)
				table.insert(chipTable,msg)
			else
				break;
			end
		end
	end
	return chipTable;
end

--创建筹码--创建类型，筹码类型，下注类型(下注的区域1-8)
function ChipNodeManager:ChipCreate(createType,chipType,xiazhuType,random,isMe,isself)
	luaPrint("创建筹码",createType,chipType,xiazhuType,random,isself)
	display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
	local msg = {};
	if isself == nil and isMe == false then
		msg.createType = createType
		msg.chipType = chipType
		msg.xiazhuType = xiazhuType;
		msg.random = random;
		msg.isMe = isMe;
		table.insert(self.ChipCreateCacheTable,msg)
		return;
	end
	local randomPos = nil;
	if createType == 1 then --自己创建的筹码
		randomPos = clone(self.mePos)
	elseif createType == 2 then --其他用户创建的筹码
		randomPos = clone(self.otherPos)
	elseif createType == 3 then	
		--luaPrint("createType",self.checkChipPos[xiazhuType])
		randomPos = clone(self.checkChipPos[xiazhuType]) --直接创建在下注的地方
	elseif createType == 4 then --庄家创建的筹码
		randomPos = clone(self.ZhuangPos)
	end
	--luaPrint("chipType.."..chipType)
    --创建
    local chipSp = cc.Sprite:create("benchibaoma/table/bcbm_chouma_"..chipType..".png");
    
    if random then
        randomPos.x =  randomPos.x + math.random(0,50)-25;
        randomPos.y =  randomPos.y + math.random(0,50)-25;
    end
    chipSp:setPosition(randomPos);
    chipSp:setScale(0.4)
    chipSp.chipType = chipType
    chipSp.xiazhuType = xiazhuType;
    chipSp.isMe = isMe;
    table.insert(self.ChipNodeTable,chipSp);
    self.tableLayer.Node_3:addChild(chipSp,10);

    return chipSp;
end

--筹码移动动画实现
function ChipNodeManager:ChipMove(chipNode,endType,xiazhuType,random,time)
    local randomPos = nil;
	if endType == 1 then --自己创建的筹码
		randomPos = clone(self.mePos)
	elseif endType == 2 then --其他用户创建的筹码
		randomPos = clone(self.otherPos)
	elseif endType == 3 then	
		--luaPrint("createType",self.checkChipPos[xiazhuType])
		randomPos = clone(self.checkChipPos[xiazhuType]) --直接创建在下注的地方
	-- elseif createType == 4 then --庄家创建的筹码
	-- 	randomPos = clone(self.ZhuangPos)
	end

    if random then
        randomPos.x =  randomPos.x + math.random(0,60)-30;
        randomPos.y =  randomPos.y + math.random(0,60)-30;
    end

    local moveTime = 0.3;
    if time then
    	moveTime = time;
    else
    	self.tableLayer:playBcbmMusic(13)
    end

    --创建动画
    local chipMove = cc.MoveTo:create(moveTime,randomPos);
    chipNode:runAction(cc.Sequence:create(cc.EaseOut:create(chipMove,moveTime) ));
end

--游戏结束的筹码的移动
function ChipNodeManager:ResultChipRemove(winChipType)
	local winChipNode = {};
	local FailChipNode = {};
	local ResultChipNode = {};

	--luaPrint("table.nums",table.nums(self.ChipNodeTable))

	if #self.ChipNodeTable <= 0 then
		return;
	end

	for i,node in ipairs(self.ChipNodeTable) do
		if node.xiazhuType == winChipType then
			table.insert(winChipNode,node)
			table.insert(ResultChipNode,node)
			
		else
			table.insert(FailChipNode,node)
		end
	end

	local fun1 = cc.CallFunc:create(function() 
		for i,node in ipairs(FailChipNode) do
			if i == 1 then
				self.tableLayer:playBcbmMusic(6)
			end
			node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,self.ZhuangPos),cc.CallFunc:create(function() 
				node:setVisible(false) end) ));
		end
		
	end)

	local fun2 = cc.CallFunc:create(function() 
		for i,node in ipairs(winChipNode) do
			if i == 1 then
				self.tableLayer:playBcbmMusic(6)
			end
			local copyNode = self:ChipCreate(4,node.chipType,node.xiazhuType,false,node.isMe,true);
    		self:ChipMove(copyNode,3,node.xiazhuType,true,0.5)
    		table.insert(ResultChipNode,copyNode)
		end
	end)

	local fun3 = cc.CallFunc:create(function() 
		for i,node in ipairs(ResultChipNode) do
			if i == 1 then
				self.tableLayer:playBcbmMusic(6)
			end
			if node.isMe then
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,self.mePos),cc.CallFunc:create(function() 
					node:setVisible(false) 
					end) ));
			else
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,self.otherPos),cc.CallFunc:create(function()
				 node:setVisible(false) 
				 end) ));
			end
		end
	end)

	self.tableLayer:runAction(cc.Sequence:create(fun1,cc.DelayTime:create(0.5),fun2,cc.DelayTime:create(0.5),fun3,
		cc.DelayTime:create(0.5),cc.CallFunc:create(function() self:clearAllChip() end),cc.CallFunc:create(function() self:showScoreTips() end) ))
	
end

function ChipNodeManager:showScoreTips()
    self.tableLayer:updateUserAndBankScore();
end


function ChipNodeManager:clearAllChip()
	for i,node in ipairs(self.ChipNodeTable) do
		node:removeFromParent()
	end
	self.ChipNodeTable = {};
end

return ChipNodeManager;
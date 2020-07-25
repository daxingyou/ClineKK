
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
	self.chipdata ={};

	self.ZhuangPos = cc.p(570,530) -- 庄家位置
	self.mePos = cc.p(50,36) --自己的位置
	-- self.otherPos = cc.p(40,360) --其他用户的位置
	self.otherPos = cc.p(self.tableLayer.Button_other:getPositionX()-self.tableLayer.Node_di:getPositionX()+self.tableLayer.Node_zuo:getPositionX(),self.tableLayer.Button_other:getPositionY());
end

function ChipNodeManager:ChipCreate(createType,chipType,xiazhuType,isme,random,ismove)
	local msg = {};
	msg.createType = createType;
	msg.chipType = chipType;
	msg.xiazhuType = xiazhuType;
	msg.isme = isme;
	msg.random = random;
	msg.ismove = ismove;
	table.insert(self.chipdata,msg)
	self:startTimer();
end

function ChipNodeManager:startTimer()
	if  self.chipSchedule then
		self.tableLayer:stopAction(self.chipSchedule);
		self.chipSchedule = nil;
		self.chipSchedule = schedule(self.tableLayer, function() self:callEverySecond(); end, 1/20);
	else
		self.chipSchedule = schedule(self.tableLayer, function() self:callEverySecond(); end, 1/20);
	end
end

function ChipNodeManager:stopTimer()
	-- for k,v in pairs(self.chipdata) do
	-- 	self:ChipCreateIMG(v.createType,v.chipType,v.xiazhuType,v.isme,v.random,v.ismove,true)
	-- end
	if self.chipSchedule then
		self.tableLayer:stopAction(self.chipSchedule);
		self.chipSchedule = nil;
	end
	self.chipdata ={};
end

function ChipNodeManager:callEverySecond()
	if #self.chipdata > 0 then
		self:ChipCreateIMG(self.chipdata[1].createType,self.chipdata[1].chipType,self.chipdata[1].xiazhuType,self.chipdata[1].isme,self.chipdata[1].random,self.chipdata[1].ismove)
		table.remove(self.chipdata,1)
	else
		self:stopTimer();
	end

end

--创建筹码--创建类型，筹码类型，下注类型(下注的区域1-8)
function ChipNodeManager:ChipCreateIMG(createType,chipType,xiazhuType,isme,random,ismove,isSound)
	-- luaPrint("创建筹码",createType,chipType,xiazhuType,isme,random,ismove)
	if (not createType)  or (not chipType) or (not xiazhuType) or chipType < 1 or chipType > 6  or xiazhuType < 1 or xiazhuType > 12 then
		return;
	end
	local randomPos = nil;
	if createType == 1 then --自己创建的筹码
		randomPos = clone(self.mePos)
	elseif createType == 2 then --其他用户创建的筹码
		randomPos = clone(self.otherPos)
	elseif createType == 3 then	
		randomPos = cc.p(self.tableLayer.Button_fqzs[xiazhuType]:getPositionX(),self.tableLayer.Button_fqzs[xiazhuType]:getPositionY());
	elseif createType == 4 then --庄家创建的筹码
		randomPos = clone(self.ZhuangPos)
	end

	 if random then
        randomPos.x =  randomPos.x + math.random(0,30)-20;
        randomPos.y =  randomPos.y + math.random(0,30)-35;
    end
    if createType == 3 and xiazhuType > 10 then
    	randomPos.x =  randomPos.x + 100;
    end
    display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
    --创建
    local typename = {1,10,50,100,500,1000};
    -- luaPrint("-------------------chipType=",chipType)
    local imgPath = typename[chipType]..".png";
	local chipSp = cc.Sprite:createWithSpriteFrameName(imgPath)
	-- local chipSp = cc.Sprite:create("chouma/"..chipType..".png")
    chipSp:setPosition(randomPos);
    chipSp:setScale(0.3)
    -- chipSp:setTag(chipType)
    chipSp.chipType = chipType;
    chipSp.xiazhuType = xiazhuType;
    chipSp.isMe = isme;
    table.insert(self.ChipNodeTable,chipSp);
    self.tableLayer.Node_di:addChild(chipSp,1);
    if ismove then
    	self:ChipMove(chipSp,3,xiazhuType,true);
    	if not isSound then
    		audio.playSound("sound/sound-jetton.mp3",false);
    	end
    end
    
    return chipSp;
end

--筹码移动动画实现
function ChipNodeManager:ChipMove(chipNode,endType,xiazhuType,random)
	-- luaPrint("endType="..endType.." xiazhuType="..xiazhuType)
    local randomPos = nil;
	if endType == 1 then --自己创建的筹码
		randomPos = clone(self.mePos)
	elseif endType == 2 then --其他用户创建的筹码
		randomPos = clone(self.otherPos)
	elseif endType == 3 then	
		randomPos = cc.p(self.tableLayer.Button_fqzs[xiazhuType]:getPositionX(),self.tableLayer.Button_fqzs[xiazhuType]:getPositionY());
	elseif createType == 4 then --庄家创建的筹码
		randomPos = clone(self.ZhuangPos)
	end
	
    if random then
        randomPos.x =  randomPos.x + math.random(0,30)-20;
        randomPos.y =  randomPos.y + math.random(0,30)-35;
    end
    if  xiazhuType > 10 then
    	randomPos.x =  randomPos.x + 100;
    end
    local moveTime = 0.2;

    --创建动画
    local chipMoveto = cc.MoveTo:create(moveTime,randomPos);
    chipNode:runAction(chipMoveto);
end

--游戏结束的筹码的移动
function ChipNodeManager:ResultChipRemove(winChipType)
	local winChipNode = {};
	local FailChipNode = {};
	local ResultChipNode = {};
	-- luaPrint("winChipType = "..winChipType)
	local otherPoswin = -1
	if winChipType<= 4 then
		otherPoswin = 11;
	elseif winChipType<= 8 then
		otherPoswin = 12;
	end
	for i,node in ipairs(self.ChipNodeTable) do

		if node.xiazhuType == winChipType or node.xiazhuType == otherPoswin or winChipType == 14 or (node.xiazhuType == 9 and  winChipType == 10) then
			table.insert(winChipNode,node)
			table.insert(ResultChipNode,node)
		else
			table.insert(FailChipNode,node)
		end
	end

	local fun1 = cc.CallFunc:create(function() 
		for i,node in ipairs(FailChipNode) do
			if node and not tolua.isnull(node) then
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,self.ZhuangPos),cc.CallFunc:create(function() node:setVisible(false) end) ));
			end	
			if i== 1 then
				audio.playSound("sound/sound-get-gold.mp3",false);
			end
		end
	end)

	local fun2 = cc.CallFunc:create(function() 
		for i,node in ipairs(winChipNode) do
			if i== 1 then
				audio.playSound("sound/sound-get-gold.mp3",false);
			end
			local copyNode = self:ChipCreateIMG(4,node.chipType,node.xiazhuType,node.isMe,false,true,true);
    		-- self:ChipMove(copyNode,3,node.xiazhuType,true)
    		table.insert(ResultChipNode,copyNode)
		end
	end)

	local fun3 = cc.CallFunc:create(function() 
		for i,node in ipairs(ResultChipNode) do
			if i== 1 then
				audio.playSound("sound/sound-get-gold.mp3",false);
			end
			if node.isMe then
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,self.mePos),cc.CallFunc:create(function() node:setVisible(false) end) ));
			else
				if node and not tolua.isnull(node) then
					local act1 = cc.MoveTo:create(0.5,self.otherPos);
					local act2 = cc.CallFunc:create(function() node:setVisible(false) end);
					node:runAction(cc.Sequence:create(act1,act2));
				end
			end
		end
	end)

	self.tableLayer:runAction(cc.Sequence:create(fun1,cc.DelayTime:create(0.5),fun2,cc.DelayTime:create(0.5),fun3,cc.DelayTime:create(0.5),cc.CallFunc:create(function() self:clearAllChip() end) ))

end


function ChipNodeManager:clearAllChip()
	for i,node in ipairs(self.ChipNodeTable) do
		if node and not tolua.isnull(node) then
			node:removeFromParent()
		end
	end
	self.ChipNodeTable = {};
	-- body
end

return ChipNodeManager;
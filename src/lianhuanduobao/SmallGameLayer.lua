local ZuanshiSprite = require("lianhuanduobao.ZuanshiSprite");
local SmallGameLayer =  class("SmallGameLayer",function()
    return cc.Layer:create();
end);

--宝箱金额
local SINGLE_BAOXIANG_CONFIG = {
    [1] = {0.2,0.4,1,1.4,1.8},
    [2] = {0.2,0.6,1,1.4,1.8},
    [3] = {0.5,0.75,1,1.25,1.5},
    [4] = {0.8,0.9,1,1.1,1.2},
    [5] = {0.9,0.95,1,1.05,1.1},


};

function SmallGameLayer:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/lianhuanduobao",true)
	cc.FileUtils:getInstance():addSearchPath("src/lianhuanduobao",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/lianhuanduobao",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/lianhuanduobao",true)
	end
end

--创建类
function SmallGameLayer:create(isautoJump,callback,callbackStart)
	self.isautoJump = isautoJump
    self.callbackGuanshu = callback
    self.callbackStart = callbackStart
    local gameLayer = SmallGameLayer:new();
    return gameLayer;
end

--构造函数
function SmallGameLayer:ctor()	
    self:setRes()
    display.loadSpriteFrames("lianhuanduobao/baoxiang.plist","lianhuanduobao/baoxiang.png");

	local uiTable = {
        --最外层元素
        Panel_bg = "Panel_bg",
        Panel_1 = "Panel_1",
		zuanshi1 = "zuanshi1",
        zuanshi2 = "zuanshi2",
		zuanshi3 = "zuanshi3",
		zuanshi4 = "zuanshi4",
		zuanshi5 = "zuanshi5",
		zuanshi6 = "zuanshi6",
		zuanshi7 = "zuanshi7",
		zuanshi8 = "zuanshi8",
		zuanshi9 = "zuanshi9",
		zuanshi10 = "zuanshi10",
		zuanshi11 = "zuanshi11",
		zuanshi12 = "zuanshi12",
		zuanshi13 = "zuanshi13",
		zuanshi14 = "zuanshi14",
		zuanshi15 = "zuanshi15",
		zuanshi16 = "zuanshi16",
        imgbaoxiang12 = "imgbaoxiang12",
        imgbaoxiang13 = "imgbaoxiang13",
        imgbaoxiang14 = "imgbaoxiang14",
        imgbaoxiang15 = "imgbaoxiang15",
        imgbaoxiang16 = "imgbaoxiang16",
        lblCoin12 = "lblCoin12",
        lblCoin13 = "lblCoin13",
        lblCoin14 = "lblCoin14",
        lblCoin15 = "lblCoin15",
        lblCoin16 = "lblCoin16",
        layEndScore = "layEndScore",
        lblCoinEnd = "lblCoinEnd",
        btnstart = "btnstart",
	}

	 loadNewCsb(self,"lianhuanduobao/SmallGameLayer",uiTable);
     self.btnstart:onClick(handler(self,self.onStart))
     self:initsmallzusnshi()
     if self.isautoJump then
        self:onStart()  
     end

end

function SmallGameLayer:onStart()  
    local callFunc =  cc.CallFunc:create(handler(self,self.callbackStart))
    self.btnstart:runAction(callFunc)
end

function SmallGameLayer:getDataOnGame(baoxiangCoin,zhongjiangIndex,winmoney)  
    self.baoxiangCoin = baoxiangCoin
    self.zhongjiangIndex = zhongjiangIndex
    self.winmoney =winmoney
    self.btnstart:hide()
    self:jumptoBaoxiang()
    self:updateBaoxiangDate()
end


--初始化钻石界面
function SmallGameLayer:initsmallzusnshi()  
    --钻石
    local zuanshiImg0 = ZuanshiSprite:create(2,2);
    zuanshiImg0:setTag(0);
    zuanshiImg0:setPosition(self.zuanshi1:getPosition());
    zuanshiImg0:setScale(0.5)
    self.Panel_1:addChild(zuanshiImg0);
    zuanshiImg0:setLocalZOrder(9)

    local zuanshiImg1 = ZuanshiSprite:create(5,3);
    zuanshiImg1:setTag(1);
    zuanshiImg1:setPosition(self.zuanshi2:getPosition());
    self.Panel_1:addChild(zuanshiImg1);
    zuanshiImg1:setLocalZOrder(9)

    local zuanshiImg2 = ZuanshiSprite:create(4,3);
    zuanshiImg2:setTag(2);
    zuanshiImg2:setPosition(self.zuanshi3:getPosition());
    self.Panel_1:addChild(zuanshiImg2);
    zuanshiImg2:setLocalZOrder(9)
        
    local zuanshiImg3 = ZuanshiSprite:create(4,3);
    zuanshiImg3:setTag(3);
    zuanshiImg3:setPosition(self.zuanshi4:getPosition());
    self.Panel_1:addChild(zuanshiImg3);
    zuanshiImg3:setLocalZOrder(9)


    for i = 1,3 do
        self["zuanshiImg" .. 3+i] = ZuanshiSprite:create(3,3);
        self["zuanshiImg" .. 3+i] :setTag(4+i);
        self["zuanshiImg" .. 3+i] :setPosition(self["zuanshi" .. 4+i]:getPosition());
        self.Panel_1:addChild( self["zuanshiImg" .. 3+i]);
        self["zuanshiImg" .. 3+i]:setLocalZOrder(9)

    end

    for i = 1,4 do
        self["zuanshiImg" .. 4+i] = ZuanshiSprite:create(2,3);
        self["zuanshiImg" .. 4+i] :setTag(5+i);
        self["zuanshiImg" .. 4+i] :setPosition(self["zuanshi" .. 7+i]:getPosition());
        self.Panel_1:addChild( self["zuanshiImg" .. 4+i]);
        self["zuanshiImg" .. 4+i]:setLocalZOrder(9)
    end
        
    for i =12,16 do
      self["lblCoin" .. i]:hide()
    end

    self.btnstart:setLocalZOrder(10)
    self.layEndScore:setLocalZOrder(11)


end

--更新宝箱奖励金额
function SmallGameLayer:updateBaoxiangDate() 
   for i =12,16 do
      self["lblCoin" .. i]:show()
      self:ScoreToMoney(self["lblCoin" .. i],self.baoxiangCoin[i-11],"");

      --self["lblCoin" .. i]:setString(self.baoxiangCoin[i-11])
   end

end


--宝箱奖励结算
function SmallGameLayer:moveEndScore(date) 
   self.layEndScore:show()
   self:ScoreToMoney(self.lblCoinEnd,date,"");

end

--小球跳动
function SmallGameLayer:jumptoBaoxiang()	
    self:setRes()
    display.loadSpriteFrames("lianhuanduobao/zuanshiImage/baoxiang.plist","lianhuanduobao/zuanshiImage/baoxiang.png");

    local qiu = self.Panel_1:getChildByTag(0)
    if qiu ~= nil then
        qiu:setPosition(self.zuanshi1:getPosition())
    end
    
    for i =12,16 do
      self["imgbaoxiang" .. i]:loadTexture("baoxiang" ..i-11 .. "_1.png",1)
    end

    local posNums1 
    local posNums2 
    local posNums3
    local posNums4 =self.zhongjiangIndex +11
   
    if posNums4 == 12 then
        posNums1 = 3
        posNums2 = 5
        posNums3 = 8
    end


    if posNums4 == 16 then
        posNums1 = 4
        posNums2 = 7
        posNums3 = 11
    end

    if posNums4 == 13 then
        posNums1 = 3
        posNums2 = 5
        posNums3 = math.random(8,9)
        if posNums3 == 9 then
           posNums2 = math.random(5,6)
           if posNums2 == 6 then
               posNums1 = math.random(3,4)
           end
        end
    end



    if posNums4 == 15 then
        posNums1 = 4
        posNums2 = 7
        posNums3 = math.random(10,11)
        if posNums3 == 10 then
           posNums2 = math.random(6,7)
           if posNums2 == 6 then
               posNums1 = math.random(3,4)
           end

            if posNums2 == 7 then
               posNums1 = 4
           end
        end
    end


    
    if posNums4 == 14 then
        posNums3 = math.random(9,10)
        if posNums3 == 10 then
           posNums2 = math.random(6,7)
           if posNums2 == 6 then
               posNums1 = math.random(3,4)
           end

           if posNums2 == 7 then
               posNums1 = 4
           end
        end
       
        if posNums3 == 9 then
           posNums2 = math.random(5,6)
           if posNums2 == 6 then
               posNums1 = math.random(3,4)
           end

           if posNums2 == 5 then
               posNums1 = 3
           end
        end
    end


    local x,y = self.zuanshi2:getPosition()
   
    local x0,y0 = self["zuanshi" ..posNums1]:getPosition()    
    local x1,y1 = self["zuanshi" ..posNums2]:getPosition()    
    local x2,y2 = self["zuanshi" ..posNums3]:getPosition()    
    local x3,y3 = self["zuanshi" ..posNums4]:getPosition()    
        
    local moveto = cc.MoveTo:create(0.2,cc.p(x,y+55))
    local jumpto = cc.Spawn:create(cc.JumpTo:create(0.5,cc.p(x0,y0+60),100,1),cc.CallFunc:create(function()
        audio.playSound("lianhuanduobao/voice/sound_xiaoyouxi.mp3");
    end));

    local jumpto0 = cc.Spawn:create(cc.JumpTo:create(0.5,cc.p(x1,y1+60),100,1),cc.CallFunc:create(function()
        audio.playSound("lianhuanduobao/voice/sound_xiaoyouxi.mp3");
    end));

    local jumpto1 = cc.Spawn:create(cc.JumpTo:create(0.5,cc.p(x2,y2+60),100,1),cc.CallFunc:create(function()
        audio.playSound("lianhuanduobao/voice/sound_xiaoyouxi.mp3");
    end));

    local jumpto2 = cc.Spawn:create(cc.JumpTo:create(0.5,cc.p(x3,y3+60),100,1),cc.CallFunc:create(function()
        audio.playSound("lianhuanduobao/voice/sound_xiaoyouxi.mp3");
    end));

    local jumpto3 = cc.Spawn:create(cc.JumpTo:create(0.2,cc.p(x3,y3),0,0),cc.CallFunc:create(function()
        audio.playSound("lianhuanduobao/voice/sound_xiaoyouxi.mp3");
    end));

    self.callback = function ()
        self["imgbaoxiang" .. posNums4]:setLocalZOrder(9)
        self["imgbaoxiang" .. posNums4]:loadTexture("baoxiang" ..posNums4-11 .. "_2.png",1)
        self:moveEndScore(self.winmoney) 
    end

    local callBack = cc.CallFunc:create(handler(self,self.callback))


    local dey = cc.DelayTime:create(1)
    self.callback1 = function ()
        self:removeFromParent()
    end
   
    local callBack1 = cc.CallFunc:create(handler(self,self.callback1))

    local callbackGuanshu = cc.CallFunc:create(handler(self,self.callbackGuanshu))

    local lastMoneyCallFunc = cc.CallFunc:create(function()
        if self.baoxiangCoin[self.zhongjiangIndex] > 1 then--????
            audio.playSound("lianhuanduobao/voice/sound_win.mp3");
        elseif self.baoxiangCoin[self.zhongjiangIndex] < 1 then
            audio.playSound("lianhuanduobao/voice/sound_lose.mp3");
        end
    end)

    local seq = cc.Sequence:create(moveto,jumpto,jumpto0,jumpto1,jumpto2,jumpto3,callBack,lastMoneyCallFunc,dey,callBack1,callbackGuanshu)

    qiu:runAction(seq)
end

--玩家分数
function SmallGameLayer:ScoreToMoney(pNode,score,string)
	if string == nil then
		string = "";
	end

	local remainderNum = score%100;
	local remainderString = "";

	if remainderNum == 0 then--保留2位小数
		remainderString = remainderString..".00";
	else
		if remainderNum%10 == 0 then
			remainderString = remainderString.."0";
		end
	end
	if pNode == nil then
        if (score/100)>=0 then
             return string..(score/100)..remainderString;
        else
             return string..":;<"..(score/100)..remainderString;
        end
    end
    if (score/100)>=0 then
         pNode:setString(string..(score/100)..remainderString);
    else
         pNode:setString(string..":;<"..(score/100)..remainderString);
    end
end

return SmallGameLayer;


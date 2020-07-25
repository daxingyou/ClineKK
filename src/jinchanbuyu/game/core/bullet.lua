local Bullet = class( "Bullet", function() return display.newSprite(); end)

local FishManager = require("jinchanbuyu.game.core.FishManager"):getInstance();
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

--控制子弹移动方式
BULLET_MOVE_TYPE_ACTION = 1
BULLET_MOVE_TYPE_VELOCITY = 2
BULLET_MOVE_TYPE =  BULLET_MOVE_TYPE_ACTION

--memberOrder 子弹所属玩家的vip等级
function Bullet:ctor(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow)
    self.database = database;

    self.paoOption = paoOption;
    self.paoLevel = paoLevel;

    self.memberOrder = memberOrder
    --打出的子弹是否减速
    self.bSetLockFishSlow = bSetLockFishSlow

    --vip4以上自动开启子弹追踪模式
    -- if self.memberOrder and self.memberOrder >= 4 then
    --     self.follow = true
    -- else
        self.follow = false
    -- end

    self.isRobotBullet = false;

    --自己发射的子弹
    self.myFire = false;
   
    self.curRotation = 0;
    self.reflectCount = 0;
 
    self:setReflectForever();

    self:updateData(true);
end

function Bullet:updateData(isInit)
    self.isFrames = true;
    self.hit = false
    self.lockFish = nil
    self.isSendData = false
    self.myFire = false
    self.m_attackFishList = {}  --攻击的鱼列表
    self.follow = false

    self:setRotation(0)
    -- self:setDefaultData();
    self:createDefaultBullet();
    self:addPhysicsBody(self:getContentSize());

    self.id =  FishManager:getGameLayer().GLOBAL_BULLET_ID

    -- luaPrint("bulletID = "..self.id)
    -- FishManager:getGameLayer().checkBulletList[self.id]=self;
end

function Bullet:resetData(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow)
    self.database = database;
    self.paoOption = paoOption;
    self.paoLevel = paoLevel;

    self.memberOrder = memberOrder
    --打出的子弹是否减速
    self.bSetLockFishSlow = bSetLockFishSlow
    self.follow = false
    self.isRobotBullet = false;

    --自己发射的子弹
    self.myFire = false;
   
    self.curRotation = 0;
    self.reflectCount = 0;

    self.bulleltFrame = nil;
    self.bulleltWangFrame = nil;
 
    self:setReflectForever();

    self:updateData(true);
end

--设置子弹的标示符
function Bullet:setThisType(myFire,charID,isRobotBullet,bullet_id)
    self.myFire = myFire;
    self.charID = charID;
    self.isRobotBullet = isRobotBullet;
    
    if bullet_id ~= nil then
        self.id = bullet_id;
    end
    
    if(myFire)then
        self:setTag(THIS_BULLET_TAG);
        bulletCurCount[self.charID] = bulletCurCount[self.charID] + 1;
    else
        self:setTag(OTHER_BULLET_TAG);
    end
end

function Bullet:addPhysicsBody(size)
    if isPhysics then
        if self.paoLevel == 2 then
            size.width = size.width/3;
            size.height = size.height/2;
        elseif self.paoLevel == 3 then
            size.width = size.width/2;
        elseif self.paoLevel == 5 then
            size.width = size.width/3;
            size.height = size.height/2;
        else
            size.width = size.width/2;
        end
        --add body  
        self.boxBody = cc.PhysicsBody:createBox(size,cc.PhysicsMaterial(0, 1, 0))--cc.p(self:getContentSize()
        --self.boxBody = cc.PhysicsBody:createCircle(size.width,cc.PhysicsMaterial(0, 1, 0))--cc.p(self:getContentSize()
        self.boxBody:setCategoryBitmask(16);
        self.boxBody:setCollisionBitmask(40);
        self.boxBody:setContactTestBitmask(40);
        self.boxBody:setRotationEnable(false);
        self.boxBody:setGravityEnable(false)
        self.boxBody:setRotationEnable(false)
        self:setPhysicsBody(self.boxBody)

        if BULLET_MOVE_TYPE == BULLET_MOVE_TYPE_ACTION then
            self.boxBody:setDynamic(false);
        end
    end
end

function Bullet:onExit()
    self:bulletUnschedule();
end

function Bullet:setDefaultData()
    self.reflectTimes = 0;
    --vip1以上自动开启子弹加速
    self.speed = 1100*0.8;

    if self.follow == true then
        self.speed = 1100*1.2;
    end
end

--设置无限反弹
function Bullet:setReflectForever()
    self.foreverReflect = true
end

function Bullet:createDefaultBullet()
    if self.isFrames == true then
        DataCacheManager:updateDataCache()

        if self.bulleltFrame == nil then
            local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
            local pFrame = sharedSpriteFrameCache:getSpriteFrame("jcby_zd"..self.paoLevel.."_level_1.png");
            self.bulleltFrame = pFrame
        end

        if self.bulleltFrame then
            self:setSpriteFrame(self.bulleltFrame)
        else
            luaPrint("zd"..self.paoOption.."_level_"..self.paoLevel..".png")
        end

        local frames = display.newFrames("jcby_zd"..self.paoLevel.."_level_%d.png", 1, 4);
        local activeFrameAnimation = display.newAnimation(frames, 0.1);
        local animate= cc.Animate:create(activeFrameAnimation);
        local aimateAction=cc.RepeatForever:create(animate);
        self:runAction(aimateAction);
    else
        local skeleton_animation = createSkeletonAnimation("zidan","cannon/zidan.json", "cannon/zidan.atlas");
        self:setContentSize(cc.size(25,60));
        if skeleton_animation then
            skeleton_animation:setPosition(self:getContentSize().width/2, self:getContentSize().height/2);
            self:addChild(skeleton_animation);
            skeleton_animation:setAnimation(1,"pao"..(self.paoLevel-1).."_zidan", true);
        end
    end
end

function Bullet:setEnergyCannon(isEnabled)
    if isEnabled then
        self.isEnergyCannon = true;
    --     local skeleton_animation = sp.SkeletonAnimation:create("fish/zidan_shandian.json", "fish/zidan_shandian.atlas");
    --     skeleton_animation:setPosition(self:getContentSize().width/2, self:getContentSize().height/2);
    --     self:addChild(skeleton_animation);
    --     skeleton_animation:setAnimation(1,"zidan_shandian", true);
    --     self.skeleton_animation = skeleton_animation;
    end
end

function Bullet:setFastShoot(isEnabled)
    if isEnabled then
        self.isMoreFastShoot = true;
    end
end

function Bullet:shootTo(rotation,pt)

    -- if self.follow and self.lockFish then
    --     self:shootToFish();
    -- else
        -- self:shootToPos(rotation);
        -- self:bodyShootToPos(rotation)
    -- end

    if self.lockFish then
        self.follow = true;
        self:setDefaultData();
        if self:moveActionUpdate(1) then
            self:shootToFish();
        else
            self.follow = false;
            self:setDefaultData();
            self:shootToPos(pt);
        end
    else
        self:setDefaultData();
        if BULLET_MOVE_TYPE == BULLET_MOVE_TYPE_ACTION then
            self:shootToPos(pt);
        elseif BULLET_MOVE_TYPE == BULLET_MOVE_TYPE_VELOCITY then
            self:bodyShootToPos(rotation)
        end
    end

    -- luaPrint("rotation "..rotation.." pt.x = "..pt.x.."   pt.y = "..pt.y)

    -- luaPrint("this.x = "..self:getPositionX().."   this.y = "..self:getPositionY())
end

function Bullet:setMainTarget(fish)
    --自己发射的子弹
    if(self.myFire)then

        --添加到受攻击的鱼列表
        for k,v in pairs(self.m_attackFishList) do
            if v == fish then
                return
            end
        end

        table.insert(self.m_attackFishList,fish)
    else
        --机器人碰撞
        if self:isRobot() then
            --添加到受攻击的鱼列表
            for k,v in pairs(self.m_attackFishList) do
                if v == fish then
                    return
                end
            end

            table.insert(self.m_attackFishList,fish)
        end
    end

    -- if #self.m_attackFishList > 0 then
        -- FishManager:getGameLayer().checkBulletList[self.id]=nil;
    -- end
end

--是否是机器人,只有代碰撞客户端，认识机器人
function Bullet:isRobot()
    return self.isRobotBullet;
end

--返回两个参数 第一个参数标示鱼是否显示受伤状态 第二个参数是否添加到攻击列表
function Bullet:showNet(fish)
    --锁定状态 当锁定的鱼不存在的时候允许碰撞
    if(self.lockFish)then
        if(FishManager:getGameLayer():checkFishValid(self.lockFish) == true)then
            if(fish ~= self.lockFish and #self.m_attackFishList == 0)then
                return false
            elseif fish ~= self.lockFish and #self.m_attackFishList > 0 then
                return true
            end
        else
            self.lockFish = nil
        end
    end

    if( not self.isSendData and self.hit )then
        return true;
    elseif self.isSendData then
        return false
    end

    if isPhysics then
        self.boxBody:setVelocity(cc.p(0,0));
    end    

    self.hit = true;
    self:bulletUnschedule();

    self:stopAllActions();

    if self.skeleton_animation then
        self.skeleton_animation:removeFromParent();
    end
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)

    local lv = self.paoLevel
    if self.isEnergyCannon == true then
        lv = self.paoOption;
    end
    lv = 1
    if not self.bulleltWangFrame then
        display.loadSpriteFrames("jinchanbuyu/fishing/jcby_fort.plist","jinchanbuyu/fishing/jcby_fort.png")
        local fileName = "jcby_wang"..lv.."_1.png";
        local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileName);
        self.bulleltWangFrame = pFrame
    end

    if self.bulleltWangFrame then
        self:setSpriteFrame(self.bulleltWangFrame);

        local frames = display.newFrames("jcby_wang"..lv.."_%d.png", 1, 7);
        local activeFrameAnimation = display.newAnimation(frames, 0.02);
        local animate= cc.Animate:create(activeFrameAnimation);
        local aimateAction=cc.RepeatForever:create(animate);
        self:runAction(animate);
    else
        Hall.showTips("渔网创建出错  id = "..self.id.."self.isEnergyCannon = "..tostring(self.isEnergyCannon).."  , setSpriteFrame self.paoOption = "..self.paoOption.." , lv = "..lv.." self.paoLevel = "..self.paoLevel,10);
    end
    
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)

    if(self:getPhysicsBody())then
        self:getPhysicsBody():removeFromWorld();
    end

    -- self:setScale(0);
    local sequence = cc.Sequence:create(        
            -- cc.EaseSineIn:create(cc.ScaleTo:create(0.3, 1)),
            -- cc.CallFunc:create(function() 
            --     self:addPhysicsBody(cc.size(100,100));
            --     end),
            cc.DelayTime:create(0.4),
            cc.CallFunc:create(function() self:disappear();end)        
    )
    self:runAction(sequence);

    -- audio.playSound("sound/wang.mp3");
    return true
end

function Bullet:catchFish()
    if(self.m_attackFishList)then
        --调整列表
        -- table.sort(self.m_attackFishList,function(a,b)
        --    return a._multiple > b._multiple
        -- end);
        
        -- FishManager:getGameLayer().checkBulletList[self.id]=nil;
        self.sendAttackFishList = {}

        for k,v in pairs(self.m_attackFishList) do
            --最多上传两条鱼
            if v and v.getFishID and #self.sendAttackFishList == 0 then
                if not self.isRobotBullet then
                    -- if v.isCanHit ~= false then
                    --     v.isCanHit = false;
                        table.insert(self.sendAttackFishList,v:getFishID())
                        break;
                    -- end
                else
                    table.insert(self.sendAttackFishList,v:getFishID())
                    break;
                end
            end
        end

        if self.lockFish then
            self.sendAttackFishList = {}
            table.insert(self.sendAttackFishList,self.lockFish:getFishID())
        end
         
        if self.isEnergyCannon == true and self.isMoreFastShoot == true then
            self.paoLevel = self.paoLevel + 8;
        end
        --死亡的时候发送被攻击的鱼列表
        self.isSendData = true
        if self.myFire then            
            bulletCurCount[self.charID] = bulletCurCount[self.charID] - 1;
            if #self.sendAttackFishList > 0 then
                FishManager:getGameLayer():catchFishWithNet(self);
            end
        elseif self:isRobot() then
            if #self.sendAttackFishList > 0 then
                FishManager:getGameLayer():catchFishWithNet(self);
            end            
        end
    end
end

function Bullet:disappear()
    self.hit = true;

    self:bulletUnschedule()
    
    self.database[ tostring(self) ] = nil;

    self:catchFish();--抓鱼处理先屏蔽

    self:stopAllActions();

    if(self:getPhysicsBody())then
        self:getPhysicsBody():removeFromWorld();
    end
    
    --缓存托管
    DataCacheManager:removeBullet(self);    
end

function Bullet:bulletUnschedule()
    if self.updateBulletScheduler then
        self:stopAction(self.updateBulletScheduler)
        self.updateBulletScheduler = nil;
    end

    if self.bulletScheduler then
        self:stopAction(self.bulletScheduler)
        self.bulletScheduler = nil;
    end
end

function Bullet:isFishInScreen()
  local winSize = cc.Director:getInstance():getWinSize();
  local screenRect = cc.rect(0,0,winSize.width,winSize.height);

  local fishRect = self:getBoundingBox();
  if cc.rectIntersectsRect(screenRect, fishRect) then
    return true;
  end

  return false;
end

function Bullet:bodyShootToPos(rotation)
    self.curRotation = rotation;

    if FLIP_FISH then
       self:setRotation(rotation+180);
    else
       self:setRotation(rotation);
    end

    local deltaPos = cc.p(math.sin(math.rad(rotation)), math.cos(math.rad(rotation)));
    self.boxBody:setVelocity(cc.p(deltaPos.x * self.speed,deltaPos.y * self.speed));
    self.velocity = cc.p(self.boxBody:getVelocity().x, self.boxBody:getVelocity().y);

    self.bulletScheduler = schedule(self, function() self:update(); end, 1/20)
end

function Bullet:update(dt)
    if(self.hit == true)then
        return
    end

    if(false == self:isFishInScreen())then
        self:disappear()
    end
        
    --取得炮台的位置，再与ptTo连线构造三角形，便于下一步从炮台出发的角度计算
    local potion = cc.p(self.boxBody:getVelocity().x, self.boxBody:getVelocity().y);

    --力是否相同
    if(self.velocity.x == potion.x and self.velocity.y == potion.y)then
        return 
    end

    --计算预备要转到的角度值 atan2f函数 返回 弧度值
    local angle =  math.atan((potion.x)/(potion.y)) / math.pi * 180;    
    local rotation = angle;
    if potion.y < 0 then
        rotation = rotation + 180;
    end

    if FLIP_FISH then
       self:setRotation(rotation+180);
    else
       self:setRotation(rotation);
    end

    local deltaPos = cc.p(math.sin(math.rad(rotation)), math.cos(math.rad(rotation)));
    self.boxBody:setVelocity(cc.p(deltaPos.x*self.speed,deltaPos.y*self.speed));
    self.velocity = cc.p(self.boxBody:getVelocity().x, self.boxBody:getVelocity().y);

    --反弹到指定次数后消失
    if(self.foreverReflect == false)then
         if(self.curRotation ~= rotation)then
            if(self.reflectCount > 9)then
                self:disappear();
            else
                self.curRotation = rotation;
                self.reflectCount = self.reflectCount+1;
            end
        end
    end

end

function Bullet:shootToFish()
    if self.updateBulletScheduler then
        self:stopAction(self.updateBulletScheduler);
        self.updateBulletScheduler = nil;
    end

    self.updateBulletScheduler = schedule(self, function() self:moveActionUpdate() end, 0.1)
end

function Bullet:moveActionUpdate(dt)
    local valid = FishManager:getGameLayer():checkFishValid(self.lockFish);

    self:stopActionByTag(111);

    if valid then
        local target = self.lockFish:getFishPos()--cc.p(self.lockFish:getPositionX(),self.lockFish:getPositionY());
        if target then
            local realTarget = self:getParent():convertToNodeSpace(target);

            self:shootToPos(realTarget);
        end

        return true
    else
        
        self.lockFish = nil

        --找不到鱼的时候随便碰撞
        if self.updateBulletScheduler then
            self:stopAction(self.updateBulletScheduler);
            self.updateBulletScheduler = nil;
        end

        if dt ~= nil and (self.ptLastStart == nil or self.previousTarget == nil) then
            
        else
            self:reflect(true);
        end

        return false
    end
end

function Bullet:shootToPos(pt)
    local ptTo = pt--self:getParent():convertToNodeSpace(pt);
    local ptFrom = cc.p(self:getPositionX(),self:getPositionY());
    local angle =  math.atan((ptTo.x-ptFrom.x)/(ptTo.y-ptFrom.y)) / math.pi * 180;

    local rotation =  angle;
    if ptFrom.y > ptTo.y then
        rotation = 180 + angle;
    end
    
    self:setRotation(rotation);

    local size = cc.Director:getInstance():getWinSize();

    local k = (ptFrom.y - ptTo.y)/(ptFrom.x-ptTo.x);
    if ptFrom.y == ptTo.y or ptFrom.x == ptTo.x then
        k = 1
    end

    local b = ptFrom.y-k*ptFrom.x;
    local target = {cc.p(0,b), cc.p(size.width, size.width*k+b), cc.p(-b/k, 0), cc.p((size.height-b)/k, size.height)};--cross with left, cross with right, cross with down, cross with up
    local targetPt = nil;
    local rc = cc.rect(0, 0, size.width, size.height);

    for i = 1, 4 do
        if cc.rectContainsPoint(rc,target[i]) and (ptTo.y - ptFrom.y) * (target[i].y-ptFrom.y) > 0 then
            targetPt = target[i];
            break;
        end
    end

    if targetPt == nil then
        luaPrint("...异常 Bullet:reflect ... realTarget 为 nil ... 错了")
        self:disappear();
        return
    end

    if self.follow == true then
        targetPt = ptTo
    end

    local ccpDistance = math.sqrt( (ptFrom.x-targetPt.x)*(ptFrom.x-targetPt.x) + (ptFrom.y-targetPt.y)*(ptFrom.y-targetPt.y) );
    local speed = self.speed;
    local moveSec = ccpDistance / speed;

    local sequence = transition.sequence(
        {
            cc.MoveTo:create(moveSec, targetPt),
            cc.CallFunc:create(function() self:reflect();end)
        }
    )
    if self.follow == true then
        sequence = transition.sequence(
            {
                cc.MoveTo:create(moveSec, targetPt)
            }
        )
    end

    self:stopActionByTag(111);
    sequence:setTag(111);
    self:runAction(sequence);
    -- self:runAction(cc.Sequence:create(
    --     cc.DelayTime:create(5),
    --     cc.CallFunc:create(function() self:stopActionByTag(111) end),
    --     cc.DelayTime:create(3),
    --     cc.CallFunc:create(function() self:disappear(); end)
    --     )
    -- )

    self.ptLastStart = ptFrom;
    self.previousTarget = targetPt;
end

function Bullet:reflect(ret)

    self:setFlippedY(false);

    self.reflectTimes = self.reflectTimes + 1;

    if self.reflectTimes > 2 and not self.foreverReflect then
        self:disappear();
        return;
    end

    local ptLastStart = self.ptLastStart;
    local ptFrom = cc.p(self:getPositionX(),self:getPositionY());

    if self.previousTarget  then
        if ptFrom.x ~= self.previousTarget.x then
            ptFrom.x = self.previousTarget.x
        end

        if ptFrom.y ~= self.previousTarget.y then
            ptFrom.y = self.previousTarget.y
        end
    end

    if ptLastStart == nil then
        local r = self:getRotation();
        ptLastStart = cc.p(ptFrom.x-math.sin(math.rad(r))*5,ptFrom.y-math.cos(math.rad(r))*5);
    end

    local size = cc.Director:getInstance():getWinSize();

    local k = -(ptFrom.y - ptLastStart.y)/(ptFrom.x-ptLastStart.x);
    
    if self.follow == true and ret ~= nil then
        k = -k;
    end

    if ptFrom.y == ptLastStart.y or ptFrom.x == ptLastStart.x then
        k = 1
    end

    local b = ptFrom.y-k*ptFrom.x;

    local target = {cc.p(0,b), cc.p(size.width, size.width*k+b), cc.p(-b/k, 0), cc.p((size.height-b)/k, size.height)};--cross with left, cross with right, cross with down, cross with up    
    
    local realTarget = nil;
    local rc = cc.rect(0, 0, size.width, size.height);

    for i = 1, #target do
        -- if ( math.floor(target[i].x) ~= math.floor(ptFrom.x) or math.floor(target[i].y) ~= math.floor(ptFrom.y) ) and cc.rectContainsPoint(rc,target[i]) then
        if ( target[i].x ~= ptFrom.x and target[i].y ~= ptFrom.y ) and cc.rectContainsPoint(rc,target[i]) then
            realTarget = target[i];
            break;
        end
    end

    --容错
    if realTarget then
        local angle = math.atan((realTarget.x-ptFrom.x)/(realTarget.y-ptFrom.y)) / math.pi * 180;
        local rotation = angle;
        if ptFrom.y > realTarget.y then
            rotation = 180 + angle;
        end
        self:setRotation(rotation);


        local ccpDistance = math.sqrt( (ptFrom.x-realTarget.x)*(ptFrom.x-realTarget.x) + (ptFrom.y-realTarget.y)*(ptFrom.y-realTarget.y) );
        local speed = self.speed;
        local moveSec = ccpDistance / speed;

        local sequence = transition.sequence(
            {
                cc.MoveTo:create(moveSec, realTarget),
                cc.CallFunc:create(function() self:reflect();end)
            }
        )
        sequence:setTag(111);
        self:runAction(sequence);
        self.previousTarget = realTarget;
    else
        luaPrint("...异常 Bullet:reflect ... realTarget 为 nil ... 错了")
        self:disappear();
        -- luaPrint("k  :"..k.." b :"..b.." ptLastStart :"..self.ptLastStart.x.." ptLastStart y :"..self.ptLastStart.y.." ptFrom y :"..ptFrom.x.." ptFrom y :"..ptFrom.y);
        return
    end

    self.ptLastStart = ptFrom;

end

function Bullet:getBulletBoundingBox()
    local bulletRect = self:getBoundingBox();
    bulletRect = cc.rect(bulletRect.x+bulletRect.width*0.25,bulletRect.y+bulletRect.height*0.25,bulletRect.width*0.5,bulletRect.height*0.5)

    return bulletRect;
end

return Bullet;

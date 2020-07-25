-----------------------------------------------------------------------------
-- local Cannon = class("Cannon");
local Cannon = class( "Cannon", BaseNode)
local FishManager = require("fishing.game.core.FishManager"):getInstance();
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();
local FishPath = require("fishing.game.core.FishPath"):getInstance();

function Cannon:ctor(container, database, seat, player,paoLevel)
    self:setAnchorPoint(cc.p(0.5,0.5));

    self.container = container;
    self.database = database;
    self.seat = seat;
    self.player = player;

    self.paoOption = paoLevel;
   
    --炮台等级(1.2.3.4)
    self.paoLevel = paoLevel
    self.isFastShoot = false
    self.isCallFish = false
    self.isMoreFastShoot = false

    self.isFrames = false;--炮台是帧动画 还是spine动画

    if self.isFrames == true then
        self.paoOption = 1;
   
        --炮台等级(1.2.3.4)
        self.paoLevel = paoLevel
    end
    
    self:setDefaultData();
    self:createDefaultCannon();
end

function Cannon:setDefaultData()
    self.rotation = 0;
    self.lockfish = false;
    self.inCooldown = false;
    self.cooldownTime = 1/5
    self.runTime = 0;
    self.m_scale = 1;
end

function Cannon:addFrameCache()
    -- FishManager:getGameLayer():loadCacheResource();
end

function Cannon:createDefaultCannon()
    local paoTai = ccui.ImageView:create("game/other_fort_bg.png");
    if FLIP_FISH then
        if self.seat < 3 then
            paoTai:setPosition(cc.p(self:getContentSize().width/2,-10));
        else
            paoTai:setPosition(cc.p(self:getContentSize().width/2,10));
        end
    else
        if self.seat > 2 then
            paoTai:setPosition(cc.p(self:getContentSize().width/2,-10));
        else
            paoTai:setPosition(cc.p(self:getContentSize().width/2,10));
        end
    end
    paoTai:setAnchorPoint(cc.p(0.5,0.5));
    self:addChild(paoTai)
    self.paoTai = paoTai;

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    --local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."-l"..self.paoLevel..".png");
    local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."_level_"..self.paoLevel..".png");

    if(not pFrame)then
        self:addFrameCache();
        pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."_level_"..self.paoLevel..".png");
    end

    local cannon = nil;
    if self.isFrames == true then
        cannon = cc.Sprite:createWithSpriteFrame(pFrame);
        cannon:setAnchorPoint(cc.p(0.5,0.35));
        cannon:setPosition(cc.p(self.paoTai:getContentSize().width/2,38));

        self.paokou_ani = self:getPaoKouAnimation()
        if self.paokou_ani then
            self.paokou_ani:setVisible(false)
            self.paokou_ani:setScale(0.8);
            self.paokou_ani:setPosition(cc.p(cannon:getContentSize().width/2,cannon:getContentSize().height-10))
            cannon:addChild(self.paokou_ani)
            -- self.paokou_ani:getAnimation():playWithIndex(0)
        end
    else
        paoTai:loadTexture("game/other_fort_bgnew.png")
        cannon = createSkeletonAnimation("pao", "cannon/pao.json", "cannon/pao.atlas");
        -- cannon:setAnchorPoint(cc.p(0.5,1));
        if cannon then
            cannon:setPosition(cc.p(self.paoTai:getContentSize().width/2,45));
            cannon:setLocalZOrder(10);

            -- local skeleton_animation = sp.SkeletonAnimation:create("cannon/dizuo.json", "cannon/dizuo.atlas");
            -- skeleton_animation:setAnchorPoint(0.5,0.5);
            -- skeleton_animation:setPosition(self.paoTai:getContentSize().width/2,100)
           
            -- skeleton_animation:setAnimation(0,"dizuo", true);
            -- self.paoTai:addChild(skeleton_animation);

            self.paokou_ani = self:getPaoKouAnimation()
            if self.paokou_ani then
                self.paokou_ani:setVisible(false)
                -- self.paokou_ani:setScale(0.8);
                self.paokou_ani:setPosition(cc.p(cannon:getContentSize().width/2,cannon:getContentSize().height+80))
                cannon:addChild(self.paokou_ani,10)
                -- self.paokou_ani:getAnimation():playWithIndex(0)
            end   
        end
    end
    if cannon then 
        self.paoTai:addChild(cannon,10);
    end

    self.model = cannon;

    -- if self.player.mainPlayer ~= true then
    --     performWithDelay(self,function() cannon:setAnimation(2,"pao1dong", false); end,0.5) 
    -- end

    --狂暴特效
    self:addKuangbaoEffect()

    --锁定于技能
    self:addLockFish()
end

function Cannon:getLockFishPos(fish)
    if fish then
        return fish:getParent():convertToWorldSpace(cc.p(fish:getPositionX() + fish.offsetPosx, fish:getPositionY()));
    end
                                                                                                                                                                                                                                                                                                         
    return cc.p(0,0);
end

function Cannon:getPaoTongPos()
    local pos = nil;
    if self.model then
        pos = cc.p(self.model:getPositionX(),self.model:getPositionY())
        pos = self.paoTai:convertToWorldSpace(pos);
    else
        pos =cc.p(0,0)
    end
    return pos;
end

function Cannon:setFast(fast)
    if fast then
        self.cooldownTime = 1/6;
    else
        self.cooldownTime = 1/5;
    end
end

function Cannon:setCannonFrame()
    self.player:updateBullet(self.player.cur_zi_dan_cost)
    if self.isFrames == true then
        local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
        --local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."-l"..self.paoLevel..".png")
        local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."_level_"..self.paoLevel..".png")

        if(not pFrame)then
            self:addFrameCache();
            pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."_level_"..self.paoLevel..".png");
        end
        if self.model then
            self.model:setSpriteFrame(pFrame)
        end
    else
        if self.model then
            self.model:clearTracks();--解决连续点击播放问题
            if self.isMoreFastShoot == true then
                self.model:setAnimation(self.paoOption+2,"pao"..(self.paoOption-1).."dong_sandan", false);
            else
                self.model:setAnimation(self.paoOption+2,"pao"..(self.paoOption-1).."dong", false);
            end
        end
    end
end

function Cannon:setPaoLevel(level, isReadChangeData)
    if level == self.paoLevel then
        -- return
    end

    --能量炮时不改变子弹等级
    if self.player.isEnergyCannon ~= true then
        self.paoLevel = level
    end
    
    self:setCannonFrame();
end

function Cannon:setPaoOption(level,isReadChangeData)
    if self.paoOption == level and not self.player.mainPlayer then
        self:setMoreFastFire(level > 8);
        return;
    end

    if level > 8 then
        self.paoOption = level - 8;
        self:setMoreFastFire(true);
    else
        self.paoOption = level;
        if self.player.mainPlayer then
            self:setCannonFrame();
        else
            self:setMoreFastFire(false);
        end
    end
end

function Cannon:setEnergyCannon(isEnabled)
    self.isEnergyCannon = isEnabled;
end

function Cannon:setFortInfo(fortOption,fortLevel)
    if fortOption then
        self:setPaoOption(fortOption,true)
    end

    if fortLevel then
       self:setPaoLevel(fortLevel,true)
    end
end

function Cannon:rotationAndFire(rotation, myFire, cost, bSetLockFishSlow,bullet_id,android_chairid,isRotate,isLockFishID)
    if rotation == 0 then
        rotation = 0.001
    end

    -- if self.player.isRobot == true then
    --     local rotation1 = self:getRobotRotation();
    --     if rotation1 ~= nil then
    --         rotation = rotation1;
    --     end
    -- end

    local lockFish = self.player.lockFish
    self.rotation = rotation;

    local tempRotation = self.rotation

    -- local sequence = cc.Sequence:create(
    --     {   
            -- cc.DelayTime:create(0.1),
            -- cc.CallFunc:create(
                -- function()
                    if self.isFrames == true then
                        self.paokou_ani:setVisible(true)
                        self.paokou_ani:getAnimation():playWithIndex(0);
                    else
                        if isRotate == nil then
                            local size = nil;
                            if self.model then
                                size = self.model:getContentSize();
                            else
                                size = cc.size(50,50)
                            end
                            if self.paokou_ani == nil or tolua.isnull(self.paokou_ani) then
                                self.paokou_ani = self:getPaoKouAnimation()
                                if self.paokou_ani then
                                    self.paokou_ani:setVisible(false)
                                    self.paokou_ani:setPosition(cc.p(self.model:getContentSize().width/2,self.model:getContentSize().height+80))
                                    self.model:addChild(self.paokou_ani,10)
                                end 
                            end
                            if self.paoOption == 1 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+80))
                            elseif self.paoOption == 2 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+125))
                            elseif self.paoOption == 3 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+120))
                            elseif self.paoOption == 4 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+115))
                            elseif self.paoOption == 5 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+120))
                            elseif self.paoOption == 6 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+100))
                            elseif self.paoOption == 7 then
                                self.paokou_ani:setPosition(cc.p(size.width/2,size.height+90))
                            end

                            self.paokou_ani:setVisible(true)
                            local lv = self.paoOption
                            lv = 1
                            if self.isMoreFastShoot then
                                self.paokou_ani:setAnimation(lv,"fire_pao"..(lv-1).."_sandan", false);
                            else
                                self.paokou_ani:setAnimation(lv,"fire_pao"..(lv-1), false);
                            end
                        end
                    end

                    if(myFire and self.isMoreFastShoot)then
                        local angle = 0;
                        if self.paoOption == 1 then
                            angle = 25
                        elseif self.paoOption == 2 then
                            angle = 25;
                        elseif self.paoOption == 3 then
                            angle = 25;
                        elseif self.paoOption == 4 then
                            angle = 32;
                        elseif self.paoOption == 5 then
                            angle = 33;
                        elseif self.paoOption == 6 then
                            angle = 30;
                        elseif self.paoOption == 7 then
                            angle = 35;
                        end
                        self:doFire(myFire, nil, cost, bSetLockFishSlow,tempRotation + angle,bullet_id,android_chairid);
                        performWithDelay(self,function() self:doFire(myFire, nil, cost, bSetLockFishSlow,tempRotation - angle,bullet_id,android_chairid); end, 20/1000);
                        performWithDelay(self,function() self:doFire(myFire, lockFish, cost, bSetLockFishSlow,tempRotation,bullet_id,android_chairid); end, 40/1000);
                        -- self:doFire(myFire, nil, cost, bSetLockFishSlow,tempRotation - angle,bullet_id,android_chairid);
                        -- self:doFire(myFire, lockFish, cost, bSetLockFishSlow,tempRotation,bullet_id,android_chairid);
                    else
                        if isLockFishID == false then
                            self:doFire(myFire, nil, cost, bSetLockFishSlow,tempRotation,bullet_id,android_chairid);
                        else
                            self:doFire(myFire, lockFish, cost, bSetLockFishSlow,tempRotation,bullet_id,android_chairid);
                        end
                    end

                    -- --子弹音效
                    -- if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
                    --     audio.playSound("sound/cannon.mp3");
                    -- end

                    -- if(self.model:getActionByTag(200) == nil)then
                     
                    --     self.model:setScale(self.m_scale);

                    --     local scaleAction = cc.Sequence:create(
                    --             cc.ScaleTo:create(0.08, self.m_scale + 0.1),
                    --             cc.ScaleTo:create(0.08, self.m_scale)
                    --         );

                    --     scaleAction:setTag(200);
                    --     self.model:runAction(scaleAction)
                    -- end
                   
                -- end)
    --     }
    -- )
    -- self.model:runAction(sequence);
    -- self.model:stopActionByTag(100);
    -- local rotateAction = cc.RotateTo:create(0.1, tempRotation);
    -- rotateAction:setTag(100);
    -- self.model:runAction(rotateAction);
    if isRotate == nil then
        if self.model then
            self.model:setRotation(tempRotation)
        end
    end

    if myFire then
        self:setCannonFrame();
    end
end

function Cannon:cooldown(isCoolDown)
    self.inCooldown = isCoolDown;

    if(self.inCooldown)then
        self.runTime = 0--重置时间
    end
end

function Cannon:getCoolDownState()
    return self.inCooldown
end

function Cannon:posIsScene(pos)    
    if pos.x < 0 or pos.y < 0 then
        return false
    end

    local winSize = cc.Director:getInstance():getWinSize();

    if pos.x > winSize.width or pos.y > winSize.height then
        return false
    end

    return true
end

function Cannon:doFire(myFire, lockFish, cost, bSetLockFishSlow,fortRotation,bullet_id,android_chairid)
    --缓存托管
    -- local bullet = require("core.bullet").new(self.database,self.paoOption,self.paoLevel,self.player.userInfo.memberOrder,bSetLockFishSlow);
    local lv = self.paoOption;
    if self.isEnergyCannon == true then
        lv = ionPaoLv;
    end

    local bullet = DataCacheManager:createBullet(self.database,self.paoOption,lv,1,bSetLockFishSlow);
    bullet:setEnergyCannon(self.isEnergyCannon);
    bullet:setFastShoot(self.isMoreFastShoot);
    bullet._userInfo = self.player.userInfo
    bullet.cost = cost
    bullet.player = self.player
    self.container:addChild(bullet);
    bullet.lockFish = lockFish;
    -- local offset = math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/16;

    local dis = 70;

    local angle = fortRotation;
    local thisRotation = fortRotation;

    local y = 10;

    -- if lv == 5 then--调整第5个炮台
    --     y = 0;
    -- end

    local offset=0;

    if FLIP_FISH then
        if self.seat > 2 then
           dis = dis*-1;
        else
            thisRotation = fortRotation+180;
            -- y = -y-8;
            y=0;
            if self.paoOption == 1 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/7;
            elseif self.paoOption == 2 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/12;
            elseif self.paoOption == 3 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/4;
            elseif self.paoOption == 4 then
                if angle < 360 then
                    offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/4;
                else
                    offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/6;
                end
            elseif self.paoOption == 5 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/18;
            elseif self.paoOption == 6 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/6;
            elseif self.paoOption == 7 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/8;
            end
        end
    else 
        if self.seat > 2 then
            dis = dis*-1;
            thisRotation = fortRotation+180;
            -- y = -y
            y=0;
            if self.paoOption == 1 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/7;
            elseif self.paoOption == 2 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/12;
            elseif self.paoOption == 3 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/6;
            elseif self.paoOption == 4 then
                if angle < 360 then
                    offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/4;
                else
                    offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/6;
                end
            elseif self.paoOption == 5 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/18;
            elseif self.paoOption == 6 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/6;
            elseif self.paoOption == 7 then
                offset = -math.abs(math.sin(math.rad(fortRotation)))*bullet:getContentSize().width/8;
            end
        end
    end
    
    local deltaPos = cc.p(math.sin(math.rad(angle))*dis, math.cos(math.rad(angle))*dis);

    local pos = cc.p(self:getPositionX(),self:getPositionY()+y+offset);
    local absolutePos = self:convertToWorldSpace(pos)
    local relaPos = self:getParent():getParent():convertToNodeSpace(absolutePos);--注意坐标转换，影响子弹位置

    if self:posIsScene(cc.p(relaPos.x + deltaPos.x,relaPos.y + deltaPos.y)) == false then
        dis = dis/70 + 2
        deltaPos = cc.p(math.sin(math.rad(angle))*dis, math.cos(math.rad(angle))*dis);
    end
    
    bullet:setPosition(cc.p(relaPos.x + deltaPos.x,relaPos.y + deltaPos.y));
    bullet:shootTo(fortRotation,(cc.p(relaPos.x + deltaPos.x*1.2,relaPos.y + deltaPos.y*1.2)));
    --子弹列表
    self.database[ tostring(bullet) ] = bullet;
-- deltaPos = cc.p(math.sin(math.rad(angle))*400, math.cos(math.rad(angle))*400);
-- local wp = self.container:convertToWorldSpace(cc.p(relaPos.x + deltaPos.x,relaPos.y + deltaPos.y));
-- local lp = self:convertToNodeSpace(wp)
--       local draw = cc.DrawNode:create()
--       draw:setAnchorPoint(0.5,0.5)
--       self:getParent():addChild(draw, 1000)
--       draw:drawLine(pos, lp, cc.c4f(1,1,1,1))
--       draw:drawPoint(pos, 4, cc.c4f(1,0,0,1))
--       draw:runAction(cc.Sequence:create(
--         cc.DelayTime:create(3),
--         cc.CallFunc:create(function() draw:removeSelf(); end)
--         )
--     )
    if myFire then
        --自己发射的子弹添加标记
        bullet:setThisType(self.player.isRobot ~= true,self.seat, self.player.isRobot);
        local lockFishID = -1;
        if lockFish then
            lockFishID = lockFish:getFishID();
        end

        local angle = thisRotation
        if FLIP_FISH then angle = angle + 180 end

        --网络不超时的时候在通知服务器
        if RoomLogic:isConnect() then
            FishManager:getGameLayer().isResponeClick = false;

            if self.isMoreFastShoot == true then
                lv = lv + 8;
            end

            FishManager:getGameLayer():userFireRequest(lv, angle, cost, bullet.id, lockFishID,self.seat-1);
            
            FishManager:getGameLayer().GLOBAL_BULLET_ID =  FishManager:getGameLayer().GLOBAL_BULLET_ID + 1;
        end
        -- luaPrint("cannon:doFire   fortRotation = "..fortRotation.." lockFishID = "..lockFishID)
    else
        -- Hall:showScrollMessage("android_chairid = "..android_chairid.."  ,  "..FishManager:getGameLayer().my:getSeatNo());
        bullet:setThisType(false,self.seat,android_chairid==FishManager:getGameLayer().my:getSeatNo(),bullet_id);
        if self.player.isRobot == true then
            FishManager:getGameLayer().GLOBAL_BULLET_ID =  FishManager:getGameLayer().GLOBAL_BULLET_ID + 1;
        end
    end

    if self.player.mainPlayer == true then
        self:cooldown(true)
    end
end

function Cannon:getFireGunLevel(gunNumber)
    local bullet_kinds = 0
    if(gunNumber< FishInfo.gameConfig.bulletMultipleMin*10) then
        bullet_kinds = 0
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*100 then
         bullet_kinds = 1
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*1000 then
         bullet_kinds = 2
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*10000 then
         bullet_kinds = 3
    end
    return bullet_kinds;
end

function Cannon:getPaoKouAnimation()
    -- local manager = ccs.ArmatureDataManager:getInstance()
    -- if manager:getAnimationData("eff_paokou") == nil then
    --     manager:addArmatureFileInfo("effect/pao_kou/eff_paokou0.png","effect/pao_kou/eff_paokou0.plist","effect/pao_kou/eff_paokou.ExportJson")
    -- end
    -- local armature = ccs.Armature:create("eff_paokou")
    -- return armature;
    local skeleton_animation = createSkeletonAnimation("fire", "cannon/fire.json", "cannon/fire.atlas");

    return skeleton_animation;
end

function Cannon:addKuangbaoEffect()
    if not self.kuangbaoObj then
        self.kuangbaoObj = createSkeletonAnimation("kuangbaozhaohuan","goods/skill/kuangbaozhaohuan.json", "goods/skill/kuangbaozhaohuan.atlas");
        if self.kuangbaoObj then
            self.kuangbaoObj:setPosition(cc.p(self.paoTai:getContentSize().width/2,0))
            self.kuangbaoObj:setVisible(false)
            -- self.kuangbaoObj:setAnimation(1,"kuangbao", true);
            self.kuangbaoObj:setLocalZOrder(10000)
            self.paoTai:addChild(self.kuangbaoObj);
        end
    end

    if not self.callFishObj then
        self.callFishObj = createSkeletonAnimation("kuangbaozhaohuan","goods/skill/kuangbaozhaohuan.json", "goods/skill/kuangbaozhaohuan.atlas");
        if self.callFishObj then
            self.callFishObj:setPosition(cc.p(self.paoTai:getContentSize().width/2,0))
            self.callFishObj:setVisible(false)
            self.callFishObj:setLocalZOrder(10000)
            self.paoTai:addChild(self.callFishObj);
        end
    end
end

function Cannon:setMoreFastFire(isMoreFastShoot)
    if self.isMoreFastShoot == isMoreFastShoot then
        self:setCannonFrame();
        return;
    end

    self.isMoreFastShoot = isMoreFastShoot;
    self:setCannonFrame();

    if isMoreFastShoot == true then
        --发射子弹频率控制
        self.player:deleteUpdateFunction()
        self.player:createUpdateFunction(0.15)
    else
        --发射子弹频率控制
        self.player:deleteUpdateFunction()
        self.player:createUpdateFunction(0.2)
    end
end

function Cannon:addLockFish()
    if not self.lockFishObj then
        self.lockFishObj = cc.Sprite:create("game/auto_mark.png");
        self.lockFishObj:setVisible(false)
        self.lockFishObj:setPosition(cc.p(self.paoTai:getContentSize().width/2,90));
        self.lockFishObj:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)));
        self.paoTai:addChild(self.lockFishObj,20);
    end       
end

function Cannon:setFastFireTime(time)
    self.kuangbaoObj:clearTracks();
    self.kuangbaoObj:setAnimation(1,"kuangbao", true);
    self.isFastShoot = true
    --发射子弹频率控制
    self.player:deleteUpdateFunction()
    self.player:createUpdateFunction(0.15)

    FishManager:getGameLayer().playerFastTimeList[self.seat] = time
    -- luaPrint(" self.fastShootTime = "..FishManager:getGameLayer().playerFastTimeList[self.seat])

    if self.kuangbaoAction then
        self:stopAction(self.kuangbaoAction)
        self.kuangbaoAction = nil;
    end

    local func = function(dt) 
        if self.isFastShoot ==  true then
            if(FishManager:getGameLayer().playerFastTimeList[self.seat] > 0)then
                FishManager:getGameLayer().playerFastTimeList[self.seat] = FishManager:getGameLayer().playerFastTimeList[self.seat] - dt
                self.kuangbaoObj:setVisible(true)
            else
                if self.kuangbaoAction then
                    self:stopAction(self.kuangbaoAction)
                    self.kuangbaoAction = nil;
                end

                FishManager:getGameLayer().playerFastTimeList[self.seat] = 0
                self.kuangbaoObj:setVisible(false)

                -- 发射子弹频率控制
                self.player:deleteUpdateFunction()
                self.player:createUpdateFunction(0.2)

                self.isFastShoot = false                
            end
        end
    end
    
    self.kuangbaoAction = schedule(self,function() func(0.1) end, 0.1);
end

function Cannon:setCallFishTime(time)
    -- local pos = cc.p(FishManager:getGameLayer().zhaohuanBtn:getPosition());
    -- local wp = FishManager:getGameLayer().Sprite_bg.view:convertToWorldSpace(pos);
    -- local lp = self.paoTai:convertToNodeSpace(wp);

    local size = cc.Director:getInstance():getWinSize();

    -- local x = FishPath:fakeRandomS(math.ceil(os.time()/CALLFISH_SKILL_CD_TIME)*self.seat, size.width/4,size.width*0.9);
    -- local y = FishPath:fakeRandomS(math.ceil(os.time()/CALLFISH_SKILL_CD_TIME)*self.seat, size.height/4,size.height*0.9);
    local rand = (FishManager:getGameLayer().cacheCallFish[1].fish_kind+1)*FishManager:getGameLayer().cacheCallFish[1].pathid;
    local x = FishPath:fakeRandomS(rand*self.seat, size.width/4,size.width*0.9);
    local y = FishPath:fakeRandomS(rand*self.seat, size.height/4,size.height*0.9);

    if self.player.mainPlayer ~= true then
        if FLIP_FISH then
            if self.seat <= 2 then
                x = size.width-x;
                y = size.height-y;
            end
        else
            if self.seat > 2 then
                x = size.width-x;
                y = size.height-y;
            end
        end
    end

    if x <= size.width/2 and x > size.width*0.4 then
        x =  x/2;
    elseif x >= size.width/2 and x < size.width*0.6 then
        x =  x*1.5;
    end

    local target = cc.p(x,y);
    FishManager:getGameLayer().callFishTargetPos =  FishManager:getGameLayer().fishLayer:convertToNodeSpace(cc.p(x,y));
    
    self.orginPos = cc.p(self.callFishObj:getPosition());
    target = self.paoTai:convertToNodeSpace(target);

    local speed = 500;
    local dt = cc.pGetLength(self.orginPos,lp)/speed;

    if self.callFishObj then
        self.callFishObj:clearTracks();
        self.callFishObj:setAnimation(2,"zhaohuan", true);
        self.callFishObj:setPosition(target);

        self.isCallFish = true
        FishManager:getGameLayer().playerCallFishTimeList[self.seat] = time
        
        if runMode == "debug" then
            luaDump(target,"target")
            luaDump(FishManager:getGameLayer().callFishTargetPos,"FishManager:getGameLayer().callFishTargetPos")
        end

        self.callFishObj:runAction(
            cc.Sequence:create(
                -- cc.MoveTo:create(dt,target),
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(function()
                    FishManager:getGameLayer():refreshCallFish();
                end),
                cc.FadeOut:create(1),
                cc.CallFunc:create(function()
                    FishManager:getGameLayer().playerCallFishTimeList[self.seat] = 0;
                    self.isCallFish = false;
                    self.callFishObj:setOpacity(255);
                    self.callFishObj:setVisible(false);
                    self.callFishObj:setPosition(self.orginPos);
                end)
                )
            )

        if self.callFishAction then
            self:stopAction(self.callFishAction)
            self.callFishAction = nil;
        end

        local func = function(dt) 
            if self.isCallFish ==  true then
                if(FishManager:getGameLayer().playerCallFishTimeList[self.seat] > 0)then
                    FishManager:getGameLayer().playerCallFishTimeList[self.seat] = FishManager:getGameLayer().playerCallFishTimeList[self.seat] - dt
                    self.callFishObj:setVisible(true)
                else
                    if self.callFishAction then
                        self:stopAction(self.callFishAction)
                        self.callFishAction = nil;
                    end

                    FishManager:getGameLayer().playerCallFishTimeList[self.seat] = 0
                    self.callFishObj:setVisible(false)

                    self.isCallFish = false                
                end
            end
        end

        self.callFishAction = schedule(self,function() func(0.1) end, 0.1);        
    end
end

function Cannon:setLockFishTime(time)
    self:addLockFish()

    if time > 0  or time == -1 then
        self.lockFishObj:setVisible(true)
        if time ~= -1 then
            performWithDelay(self, function() self.lockFishObj:setVisible(false) end, time)
        end        
    else
        self.lockFishObj:setVisible(false)
    end
end

function Cannon:cannonUpdate(dt)
    self.runTime = self.runTime + dt

    if(self.runTime >= self.cooldownTime)then
        self:cooldown(false)
    end

    -- if self.isFastShoot ==  true then
    --     if(FishManager:getGameLayer().playerFastTimeList[self.seat] > 0)then
    --         FishManager:getGameLayer().playerFastTimeList[self.seat] = FishManager:getGameLayer().playerFastTimeList[self.seat] - dt
    --         self.kuangbaoObj:setVisible(true)
    --     else
    --         FishManager:getGameLayer().playerFastTimeList[self.seat] = 0
    --         self.kuangbaoObj:setVisible(false)

    --         -- 发射子弹频率控制
    --         self.player:deleteUpdateFunction()
    --         self.player:createUpdateFunction(0.2)

    --         self.isFastShoot = false
    --     end
    -- end

    -- if self.isCallFish == true then
    --     -- luaPrint("FishManager:getGameLayer().playerCallFishTimeList[self.seat]  -----------  "..FishManager:getGameLayer().playerCallFishTimeList[self.seat])
    --     if(FishManager:getGameLayer().playerCallFishTimeList[self.seat] > 0)then
    --         FishManager:getGameLayer().playerCallFishTimeList[self.seat] = FishManager:getGameLayer().playerCallFishTimeList[self.seat] - dt
    --         -- local zhaohunaAnimate = nil;
    --         -- if self.player.mainPlayer == true then
    --         --     zhaohunaAnimate = FishManager:getGameLayer().zhaohuanAnimate;
    --         -- end

    --         -- if zhaohunaAnimate then
    --         --     zhaohunaAnimate:setVisible(true)
    --         -- end
    --         self.callFishObj:setVisible(true)
    --     else
    --         FishManager:getGameLayer().playerCallFishTimeList[self.seat] = 0
    --         -- local zhaohunaAnimate = nil;
    --         -- if self.player.mainPlayer == true then
    --         --     zhaohunaAnimate = FishManager:getGameLayer().zhaohuanAnimate;
    --         -- end

    --         -- if zhaohunaAnimate then
    --         --     zhaohunaAnimate:setVisible(false)
    --         -- end
    --         self.callFishObj:setVisible(false)

    --         self.isCallFish = false
    --     end
    -- end
end

return Cannon;
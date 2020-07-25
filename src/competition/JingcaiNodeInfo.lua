--竞猜info

local JingcaiNodeInfo = class("JingcaiNodeInfo", function() return display.newNode(); end)
local GameConfig = require("competition.GameConfig")

function JingcaiNodeInfo:ctor(data,parent,jingcaiLayer,isOpen,tag,tableLayer)
    self.data = data;
    self.parent = parent;
    self.jingcaiLayer = jingcaiLayer;
    self.tableLayer = tableLayer;

    self:DealPLData();

    self:initUI(isOpen,tag);
end

function JingcaiNodeInfo:initUI(isOpen,tag)
    self.size = cc.Director:getInstance():getWinSize()
    --第一个展开
    if isOpen then
        self:updataUI(1,tag)
    else
        self:updataUI(2)
    end
    
end

--整条按钮按下
function JingcaiNodeInfo:NodeClick()
    self:onClickBtnCallBack(self.xiala);
end

function JingcaiNodeInfo:onClickBtnCallBack(sender)
    local name = sender:getName();
    local tag = sender:getTag();
  
    if name == "zhankai" then
        sender:setName("shouqi")
        sender:loadTextures("jingcai/anniu-shouqi.png","jingcai/anniu-shouqi-on.png")
        self.jingcaiLayer.key = tonumber(self.data.game_id);
        self:UpdateJingcaiNode();
    elseif name == "shouqi" then
        sender:setName("zhankai")
        sender:loadTextures("jingcai/anniu-zhankai.png","jingcai/anniu-zhankai.png")
        self.jingcaiLayer.key = 0;
        self:UpdateJingcaiNode();
    elseif name == "zhanju" then --第几局8个
        local haveGuess = false;
        for k,v in pairs(self.data.guess) do
            if v.jushu == tag then
                haveGuess = true;
                break;
            end
        end

        if haveGuess == false then
            addScrollMessage("该场次没有竞猜");
            return;
        end

        self:UpdateJingcaiNode(tag);

    elseif name == "xiazhuzj" then --总局下注2个队
        if tag == 0 then
            addScrollMessage("当前场次已停止下注，下注失败");
            return;
        end

        local selectId = sender.selectData;
        local idSplit = string.split(selectId,"-");

        local  layer = self.tableLayer:getChildByName("XiazhuLayer");
        if layer then
            return;
        end

        local XiazhuLayer = require("competition.XiazhuLayer");

        local newLayer = XiazhuLayer:create(self.data,tonumber(idSplit[1]),tonumber(idSplit[2]));

        newLayer:setName("XiazhuLayer");

        self.tableLayer:addChild(newLayer);
    end

end

function JingcaiNodeInfo:updataUI(itype,num)
    self:removeAllChildren();
    --设置初始值
    if num == nil then
        num = 0;
    end

    if self.parent then
         --公共顶
        local bg = ccui.ImageView:create("jingcai/BGtiao.png");
        bg:setAnchorPoint(0.5,1);
        self:addChild(bg);
        local pNode = cc.Node:create();
        pNode:setPosition(139.5,10);
        bg:addChild(pNode);
        self.pNode = pNode;
        local bgsize = cc.size(1280,80);

        local beginTime = string.split(self.data.begin_time," ");
        local timeSplit0 = string.split(beginTime[1],"-");
        local timeSplit1 = string.split(beginTime[2],":");

        local timeAll = os.time({day=tonumber(timeSplit0[3]), month=tonumber(timeSplit0[2]), year=tonumber(timeSplit0[1]), hour=tonumber(timeSplit1[1]), minute=tonumber(timeSplit1[2]), second=tonumber(timeSplit1[3])})

        --时间的组成
        local dateStr = "星期";

        if tonumber(os.date("%w",timeAll)) == 1 then
            dateStr = dateStr.."一 ";
        elseif tonumber(os.date("%w",timeAll)) == 2 then
            dateStr = dateStr.."二 ";
        elseif tonumber(os.date("%w",timeAll)) == 3 then
            dateStr = dateStr.."三 ";
        elseif tonumber(os.date("%w",timeAll)) == 4 then
            dateStr = dateStr.."四 ";
        elseif tonumber(os.date("%w",timeAll)) == 5 then
            dateStr = dateStr.."五 ";
        elseif tonumber(os.date("%w",timeAll)) == 6 then
            dateStr = dateStr.."六 ";
        elseif tonumber(os.date("%w",timeAll)) == 0 then
            dateStr = dateStr.."日 ";
        end

        dateStr = dateStr..timeSplit0[2].."月"..timeSplit0[3].."日".." "..timeSplit1[1]..":"..timeSplit1[2];


        local texttz = FontConfig.createWithSystemFont(dateStr,28,FontConfig.colorWhite);
        texttz:setPosition(bgsize.width*0.02,bgsize.height*0.7);
        texttz:setAnchorPoint(cc.p(0, 0.5));
        pNode:addChild(texttz);

        local texttz = FontConfig.createWithSystemFont("BO"..self.data.bo,28,FontConfig.colorWhite);
        texttz:setPosition(bgsize.width*0.02,bgsize.height*0.3);
        texttz:setAnchorPoint(cc.p(0, 0.5));
        pNode:addChild(texttz);

        local texttz = FontConfig.createWithSystemFont(self.data.teamInfo[1].name.."-"..self.data.teamInfo[2].name,33,FontConfig.colorWhite);
        texttz:setPosition(bgsize.width*0.3,bgsize.height*0.5);
        texttz:setAnchorPoint(cc.p(0, 0.5));
        pNode:addChild(texttz);

        --王者荣耀
        local wangzhe = ccui.ImageView:create("game/"..GameConfig:GetGameTitle(self.data.event_id)..".png");
        wangzhe:setPosition(bgsize.width*0.65,bgsize.height*0.5);
        pNode:addChild(wangzhe);

        --KPL
        local kpl = ccui.ImageView:create("game/"..GameConfig:GetGameMatch(self.data.match_id)..".png");
        kpl:setPosition(bgsize.width*0.73,bgsize.height*0.5);
        pNode:addChild(kpl);


        local matchStage = FontConfig.createWithSystemFont(self.data.match_stage,24,FontConfig.colorWhite);
        matchStage:setAnchorPoint(cc.p(0,0.5));
        matchStage:setPosition(bgsize.width*0.78,bgsize.height*0.5);
        pNode:addChild(matchStage);

        --展开
        local xiala = ccui.Button:create("jingcai/anniu-zhankai.png","jingcai/anniu-zhankai.png")
        xiala:setPosition(bgsize.width*0.97,bgsize.height*0.5);
        pNode:addChild(xiala);
        xiala:setName("zhankai");
        self.xiala = xiala;
        xiala:onClick(handler(self,self.onClickBtnCallBack));


        --获取需要移的像素数量
        local function GetGuessCount(jushu,key)
            local count = 0;

            if key == nil then
                for k,v in pairs(self.data.guess) do
                    if v.jushu == jushu then
                        if #v.items <4 then
                            count = count+math.floor(#v.items/4)+1;
                        else
                            count = count+math.floor(#v.items/4);
                        end
                    end
                end
            else
                for k,v in pairs(self.data.guess) do
                    if k<key and v.jushu == jushu then
                        if #v.items < 4 then
                            count = count+math.floor(#v.items/4)+1;
                        else
                            count = count+math.floor(#v.items/4);
                        end
                    end
                end
            end

            return count;
        end

        if itype == 2 then --收起
            self.parent:setContentSize(1559,90);
            self:setContentSize(1559,90);
            bg:setPosition(cc.p(1559/2,90));

        else  --总局
            local changbg = ccui.ImageView:create("jingcai/BGtiao2.png");

            local jingcaiNodeHeight = 90+changbg:getContentSize().height+85*GetGuessCount(num)+10;

            --计算大小 并设置
            self.parent:setContentSize(1559,jingcaiNodeHeight);
            self:setContentSize(1559,jingcaiNodeHeight);

            bg:setAnchorPoint(cc.p(0.5,1));
            bg:setPosition(cc.p(1559/2,jingcaiNodeHeight));

            xiala:setName("shouqi")
            xiala:loadTextures("jingcai/anniu-shouqi.png","jingcai/anniu-shouqi-on.png")
            --总局
            changbg:setAnchorPoint(cc.p(0.5,1));
            changbg:setPosition(cc.p(1559/2,bg:getPositionY()-bg:getContentSize().height));
            self:addChild(changbg);

            local changeNode = cc.Node:create();
            changeNode:setPosition(139.5,0);
            changbg:addChild(changeNode);
            local ccbgsize = cc.size(1280,45);
            for i=1,self.data.bo+1 do
                local btn = ccui.Button:create("jingcai/zi/di"..(i-1)..".png","jingcai/zi/di"..(i-1).."-on.png")
                btn:setPosition(ccbgsize.width*0.12*i-50,ccbgsize.height*0.45);
                changeNode:addChild(btn);
                btn:setName("zhanju")
                btn:setTag(i-1)
                btn:onClick(handler(self,self.onClickBtnCallBack));
                if i-1 == num then
                    btn:setVisible(false);
                    local xianshi = ccui.ImageView:create("jingcai/zi/di"..(i-1).."-l.png");
                    xianshi:setPosition(cc.p(btn:getPosition()));
                    changeNode:addChild(xianshi);
                end
            end

            local nameBgHeightCount = 5;

            local dataNode = cc.Node:create();
            dataNode:setPosition(139.5,0);
            self:addChild(dataNode);

            for k,v in pairs(self.data.guess) do
                if v.jushu == num then--jushu为0是总局
                    --将要移动的位置距离

                    -- luaDump(v,"创建的数据");

                    local tmp = cc.Sprite:create("jingcai/xiazhuqu/kuang1.png")
                    local fullRect = cc.rect(0,0,tmp:getContentSize().width,tmp:getContentSize().height)
                    local insetRect = cc.rect(82,39,1,2)
                    local namebg = cc.Scale9Sprite:create("jingcai/xiazhuqu/kuang1.png",fullRect,insetRect) 


                    namebg:setAnchorPoint(cc.p(0.5,1));
                    dataNode:addChild(namebg);

                    --进行特殊处理
                    local sizeH = 0;
                    if #v.items < 4 then
                        sizeH = namebg:getContentSize().height*(math.floor(#v.items/4)+1);
                    else
                        sizeH = namebg:getContentSize().height*(math.floor(#v.items/4))+5*(math.floor(#v.items/4)-1);
                    end
                    namebg:setContentSize(namebg:getContentSize().width,sizeH);

                    namebg:setPosition(90,changbg:getPositionY()-changbg:getContentSize().height-nameBgHeightCount);

                    nameBgHeightCount = nameBgHeightCount+5+sizeH;
                    --投注项的名字
                    local name = FontConfig.createWithSystemFont(v.bet_title,18,FontConfig.colorWhite,cc.size(165,0));
                    name:setPosition(83,namebg:getContentSize().height/2);
                    namebg:addChild(name);

                    local guessStatus = ccui.ImageView:create("zhuye/sousuokuang.png");

                    --创建赔率
                    local tmp = cc.Sprite:create("jingcai/xiazhuqu/kuang4.png")
                    local fullRect = cc.rect(0,0,tmp:getContentSize().width,tmp:getContentSize().height)
                    local insetRect = cc.rect(135,39,1,2)

                    local peilvSize = tmp:getContentSize();
                    if #v.items < 4 then
                        peilvSize.width = peilvSize.width*2+4;
                    end
                    --标记是否开启投注
                    local touzhuFlag = false;

                    --根据items的num排序
                    for i = 1,#v.items do
                        for j = i,#v.items do
                            if tonumber(v.items[i].items_bet_num)>tonumber(v.items[j].items_bet_num) then
                                local temp = clone(v.items[i]);
                                v.items[i] = clone(v.items[j]);
                                v.items[j] = temp;
                            end
                        end
                    end

                    --循环创建赔率的底
                    for k1,v1 in pairs(v.items) do
                        local peilvBg = ccui.Button:create("jingcai/xiazhuqu/kuang4.png","jingcai/xiazhuqu/kuang4-l.png","jingcai/xiazhuqu/kuang4-l.png");

                        peilvBg:setScale9Enabled(true);

                        peilvBg:setAnchorPoint(cc.p(0,1));

                        peilvBg:setContentSize(peilvSize);

                        local pos = cc.p(0,0);
                        --设置坐标的X轴
                        pos.x = namebg:getPositionX()+namebg:getContentSize().width/2+4*((k1-1)%4+1)+peilvSize.width*((k1-1)%4);

                        pos.y = namebg:getPositionY()-(peilvSize.height+5)*math.floor((k1-1)/4);

                        peilvBg:setPosition(pos);
                        dataNode:addChild(peilvBg);
                        peilvBg:addClickEventListener(function(sender)
                            self:onClickBtnCallBack(sender);
                        end)

                        peilvBg:setName("xiazhuzj");
                        peilvBg.selectData = k.."-"..k1;

                        local isTou = 0;
                        if tonumber(v1.items_odds_status) == 1 and tonumber(v1.isDelete) == 0 then
                            isTou = 1;
                        end

                        peilvBg:setTag(isTou);


                        --显示赔率信息
                        local name = FontConfig.createWithSystemFont(v1.items_odds_name,24,FontConfig.colorWhite);
                        name:setAnchorPoint(cc.p(1,0.5));
                        name:setPosition(peilvBg:getContentSize().width/2-4,peilvBg:getContentSize().height/2);
                        peilvBg:addChild(name);

                        local peilv = FontConfig.createWithCharMap(tonumber(v1.items_odds)/100,"jingcai/xiazhuqu/zitiao2.png", 15, 21, '+');
                        peilv:setAnchorPoint(cc.p(0,0.5));
                        peilv:setPosition(peilvBg:getContentSize().width/2+6,peilvBg:getContentSize().height/2);
                        peilvBg:addChild(peilv);

                        --isdelete后台停止
                        if tonumber(v1.items_odds_status) == 1 and tonumber(v1.isDelete) == 0 then
                            touzhuFlag = true;
                        end

                        --投注有结果则显示
                        if tonumber(v1.items_status) ~= 0 then
                            local winSp = nil;
                            if tonumber(v1.items_win) == 1 then
                                winSp = ccui.ImageView:create("jingcai/win1.png");
                            elseif tonumber(v1.items_win) == 0 then
                                winSp = ccui.ImageView:create("jingcai/win0.png");
                            end

                            if winSp then
                                winSp:setAnchorPoint(0,1);
                                winSp:setPosition(0,peilvBg:getContentSize().height);
                                peilvBg:addChild(winSp);
                            end
                        end 

                    end

                    --显示该项的下注状态

                    local touzhuStatusSp;
                    if touzhuFlag then
                        touzhuStatusSp = ccui.ImageView:create("jingcai/touzhu1.png");
                    else
                        touzhuStatusSp = ccui.ImageView:create("jingcai/touzhu0.png");
                    end

                    touzhuStatusSp:setAnchorPoint(0,1);
                    touzhuStatusSp:setPosition(0,namebg:getContentSize().height);
                    namebg:addChild(touzhuStatusSp);

                end
            end

        end
        
    end
end

function JingcaiNodeInfo:UpdateJingcaiNode(num)

    if num == nil then
        num = 0;
    end

    --刷新listview
    if self.jingcaiLayer then
        self.jingcaiLayer:updateMatchLlist(self.tableLayer.GametypeEcList,num);
    end
end

-- 首先完成10杀-第2局
-- 首先完成10杀-第2局
-- 双方人头总数-第2局
-- 双方人头总数-第2局
-- 第三局比赛获胜队伍
-- 字符串字符判断第几局的游戏
function JingcaiNodeInfo:DealPLData()
    if self.data.guess then
        for k,v in pairs(self.data.guess) do
            local guessTitle = v.bet_title;
            local guessTitleSplit = string.split(guessTitle,"-");--根据-分割
            if guessTitleSplit[2] then
                v.bet_title = guessTitleSplit[1];
                --将中文的第和局替换""
                local split1 = string.gsub(guessTitleSplit[2],"第","");
                local split2 = string.gsub(split1,"局","");

                local jushu = tonumber(split2);
                v.jushu = 0;
                if jushu then
                    v.jushu = jushu;
                end
            else
                v.jushu = 0;                
            end
        end
    end
    -- --luaDump(self.data.guess,"竞猜信息")
end

return JingcaiNodeInfo

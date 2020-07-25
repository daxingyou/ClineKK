--历史单

local LishiNodeInfo = class("LishiNodeInfo", function() return display.newNode(); end)
local GameConfig = require("competition.GameConfig")

function LishiNodeInfo:ctor(data)
    self.data = data;

    self:initUI();
end

function LishiNodeInfo:initUI()
    local bg = ccui.ImageView:create("zhuye/BGtiao.png");
    bg:setPosition(cc.p(640,82));
    self:addChild(bg);
    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);

    self.pNode = pNode;

    local bgsize = cc.size(1280,163);

    local zhuangtai = ccui.ImageView:create("lishi/tubiao.png");
    zhuangtai:setPosition(bgsize.width*0.05,bgsize.height*0.5);
    pNode:addChild(zhuangtai);

    --游戏标题
    local gameTitle = ccui.ImageView:create("game/"..GameConfig:GetGameTitle(self.data.event_id)..".png");
    gameTitle:setPosition(bgsize.width*0.14,bgsize.height*0.6);
    pNode:addChild(gameTitle);

    local gameMatch = ccui.ImageView:create("game/"..GameConfig:GetGameMatch(self.data.match_id)..".png");
    gameMatch:setPosition(bgsize.width*0.14+gameTitle:getContentSize().width/2+10+gameMatch:getContentSize().width/2,bgsize.height*0.6);
    pNode:addChild(gameMatch);

    local beginTime = string.split(self.data.begin_time," ");
    local timeSplit = string.split(beginTime[2],":");
    local startTime = timeSplit[1]..":"..timeSplit[2];

    --时间
    local time = FontConfig.createWithCharMap(startTime,"zhuye/shijianzitiao.png", 20, 25, '+');
    time:setPosition(bgsize.width*0.18,bgsize.height*0.30);
    pNode:addChild(time);

    local matchStage = FontConfig.createWithSystemFont(self.data.match_stage,24,FontConfig.colorWhite);
    matchStage:setAnchorPoint(cc.p(0,0.5));
    matchStage:setPosition(bgsize.width*0.27,bgsize.height*0.8);
    pNode:addChild(matchStage);
    --vs
    local vs = ccui.ImageView:create("zhuye/vs.png");
    vs:setPosition(bgsize.width*0.55,bgsize.height*0.6);
    pNode:addChild(vs);

    --创建队伍的名字
    local team1name = FontConfig.createWithSystemFont(self.data.teamInfo[1].name,24,FontConfig.colorWhite);
    team1name:setAnchorPoint(cc.p(1,0.5));
    team1name:setPosition(bgsize.width*0.51,bgsize.height*0.6);
    pNode:addChild(team1name);

    local team2name = FontConfig.createWithSystemFont(self.data.teamInfo[2].name,24,FontConfig.colorWhite);
    team2name:setAnchorPoint(cc.p(0,0.5));
    team2name:setPosition(bgsize.width*0.57,bgsize.height*0.6);
    pNode:addChild(team2name);

    local bifen = FontConfig.createWithCharMap(self.data.score_a.."-"..self.data.score_b,"zhuye/zitiao2VS.png", 35, 44, '+');
    bifen:setPosition(bgsize.width*0.55,bgsize.height*0.30);
    pNode:addChild(bifen);
    self.bifen = bifen;


    local savePath = cc.FileUtils:getInstance():getWritablePath();
    local pngpath = savePath.."djA"..self.data.game_id..".png";
    if cc.FileUtils:getInstance():isFileExist(pngpath) then
        cc.TextureCache:getInstance():removeTextureForKey(pngpath);
        local teamSp=ccui.ImageView:create(pngpath);
        teamSp:setScale(105/teamSp:getContentSize().height); 
        teamSp:setPosition(bgsize.width*0.38,bgsize.height*0.38);
        pNode:addChild(teamSp);

    else
        local url = self.data.teamInfo[1].icon;
        HttpUtils:requestHttp(url,function(result,response)
            if self.onHttpRequestTeamA then
                self:onHttpRequestTeamA(result,response)
            end
        end)
    end
    --队伍2
    local pngpath = savePath.."djB"..self.data.game_id..".png";
    if cc.FileUtils:getInstance():isFileExist(pngpath) then
        cc.TextureCache:getInstance():removeTextureForKey(pngpath);
        local teamSp=ccui.ImageView:create(pngpath)
        teamSp:setScale(105/teamSp:getContentSize().height);  
        teamSp:setPosition(bgsize.width*0.68,bgsize.height*0.38);
        pNode:addChild(teamSp);
    else
        local url = self.data.teamInfo[2].icon;
        HttpUtils:requestHttp(url,function(result,response)
            if self.onHttpRequestTeamB then
                self:onHttpRequestTeamB(result,response);
            end
        end)
    end

    --投注
    local touzhubg = ccui.ImageView:create("zhuye/BGtiao2.png");
    touzhubg:setPosition(bgsize.width*0.91,bgsize.height*0.46);
    pNode:addChild(touzhubg);

    local touzhu = ccui.ImageView:create("lishi/yijieshu.png");
    touzhu:setPosition(88,80);
    touzhubg:addChild(touzhu);


    local dayTime = string.split(beginTime[1],"-");
    local texttz = FontConfig.createWithSystemFont(dayTime[2].."月"..dayTime[3].."号",24,FontConfig.colorWhite);
    texttz:setPosition(88,130);
    touzhubg:addChild(texttz);

    
end

-- 队标请求结果
function LishiNodeInfo:onHttpRequestTeamA(result, response)
    if result == false then
        luaPrint("http request cmd =  error")
    else
        if self.pNode == nil then
            return;
        end

        local bgsize = cc.size(1280,163);

        local savePath = cc.FileUtils:getInstance():getWritablePath();
        local path = savePath.."djA"..self.data.match_id..".png";
        if path then
            -- //渲染图片
            local f = io.open(path, 'wb')
            if f then
                f:write(response)

                f:close()
            end

            cc.TextureCache:getInstance():removeTextureForKey(path);
            local teamSp=ccui.ImageView:create(path)
            teamSp:setScale(105/teamSp:getContentSize().height); 
            teamSp:setPosition(bgsize.width*0.38,bgsize.height*0.38);
            self.pNode:addChild(teamSp);
        end
    end
end

-- 队标请求结果
function LishiNodeInfo:onHttpRequestTeamB(result, response)
    if result == false then
        luaPrint("http request cmd =  error")
    else
        if self.pNode == nil then
            return;
        end
        
        local bgsize = cc.size(1280,163);

        local savePath = cc.FileUtils:getInstance():getWritablePath();
        local path = savePath.."djB"..self.data.match_id..".png";
        if path then
            -- //渲染图片
            local f = io.open(path, 'wb')
            if f then
                f:write(response)

                f:close()
            end

            cc.TextureCache:getInstance():removeTextureForKey(path);
            local teamSp=ccui.ImageView:create(path)
            teamSp:setScale(105/teamSp:getContentSize().height); 
            teamSp:setPosition(bgsize.width*0.68,bgsize.height*0.38);
            self.pNode:addChild(teamSp);
        end
    end
end

return LishiNodeInfo

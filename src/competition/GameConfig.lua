--配置表格
local GameConfig = {
    --游戏列表
    wangzhe = 254,

    --赛事列表
    kpl = 342,
    gcs = 1485,
    krkpl = 1235,

    --赛季列表
    chunji = 343,
    qiuji = 344,
    changgui = 345,
    jihou = 346,
}

--判断游戏
function GameConfig:GetGameTitle(eventId)
    eventId = tonumber(eventId);
    if eventId == GameConfig.wangzhe then
        return "wangzhe";
    end
    return "";
end

--判断赛事
function GameConfig:GetGameMatch(matchId)
    matchId = tonumber(matchId);
    if matchId == GameConfig.kpl then
        return "kpl";
    elseif matchId == GameConfig.gcs then
        return "gcs";
    elseif matchId == GameConfig.krkpl then        
        return "krkpl";
    end
    return "";
end
--判断春季赛还是秋季赛
function GameConfig:GetGameMatchStage(matchStageId)
    matchStageId = tonumber(matchStageId);
    if matchStageId == GameConfig.chunji then
        return "chunji";
    elseif matchStageId == GameConfig.qiuji then
        return "qiuji";
    elseif matchStageId == GameConfig.changgui then
        return "changgui";
    elseif matchStageId == GameConfig.jihou then
        return "jihou";
    end
    return "";
end


return GameConfig

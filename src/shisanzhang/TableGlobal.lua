TableGlobal = {}

TableGlobal.iMaValue = false        -- 马牌值  
TableGlobal.bMoreCard = false       -- 是否多一色

TableGlobal.iSelectDlg = 2          -- 聊天框选择

-- 是否一起报牌
function TableGlobal.isShowTogether()
    -- return (GameCreator:getCurrentGameNameID()==GAME_SHISANSHUI_6R)
    return false
end

-- reset 可能有影响的全局变量
function TableGlobal.resetGlobleVal()
    log("resetGlobleVal   resetGlobleVal ")
    TableGlobal.iMaValue = false        -- 马牌值  
    TableGlobal.bMoreCard = false       -- 是否多一色
    TableGlobal.iSelectDlg = 2          -- 聊天框选择
end
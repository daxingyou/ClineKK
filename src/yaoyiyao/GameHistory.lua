local GameHistory =  class("GameHistory", PopLayer)

function GameHistory:createLayer(historyList)
    local layer = GameHistory.new(historyList);

    layer:setName("GameHistory");

    return layer;
end

function GameHistory:ctor(historyList)
    self.super.ctor(self,PopType.none)

    self:InitLayer(historyList);
end

function GameHistory:InitLayer(historyList)
    self:removeAllChildren();
    local rootNode = cc.CSLoader:createNode("yaoyiyao/GameHistory.csb");
    if rootNode == nil then
        return nil;
    end
    self.xBg = rootNode
    self:addChild(rootNode);
    --保存历史信息
    local list = {};
    self.historyList = {};
    for k,v in pairs(historyList) do
        if v[1] == -1 or v[2] == -1 or v[3] == -1 or v[4] == -1 then
            break;
        end
        table.insert(list,v); 
    end
    for i = #list,0,-1 do
        table.insert(self.historyList,list[i]);
    end
    self.ImageBg = rootNode:getChildByName("Image_Bg")
    self.exampleInfo = self.ImageBg:getChildByName("Panel_exampleInfo");
    self.exampleInfo:setVisible(false);

    --列表容器
    local listHistory = self.ImageBg:getChildByName("ListView_history");
    for k,v in pairs(self.historyList) do
        if k<=20 then
            local gamePanel = self.exampleInfo:clone();
            gamePanel:setVisible(true);
            self:SetGameBtnInfo(gamePanel,k);
            listHistory:pushBackCustomItem(gamePanel);
        end
    end   
    
    --设置关闭按钮
    self.ImageBg:getChildByName("Button_close"):addClickEventListener(function(sender) 
        self:removeFromParent();
    end);
end

--tableview的reloadData后的坐标问题（上下滚动）isNeedFlush是否需要滚动到顶
function GameHistory:CommomFunc_TableViewReloadData_Vertical(pTableView, singleCellSize, isNeedFlush)
    if isNeedFlush == true then
        -- 直接重新加载数据
        pTableView:reloadData();
    else
        -- 需要设定位置
        local currOffSet = pTableView:getContentOffset();
        local viewSize = pTableView:getViewSize();
        -- 重新加载数据
        pTableView:reloadData();
        -- 获取大小
        local contentSize = pTableView:getContentSize();
        -- 如果tableview内尺寸大于可视尺寸，需要设定当前的显示位置
        if contentSize.height > viewSize.height then
            -- 
            local minPointY = viewSize.height - contentSize.height;
            local maxPointY = 0;
            if currOffSet.y < minPointY then
                currOffSet.y = minPointY;
            elseif currOffSet.y > maxPointY then
                currOffSet.y = maxPointY;
            end
            pTableView:setContentOffset(currOffSet);
        end
    end    
end

--cell点击事件
function GameHistory:tableCellTouched(table,cell)
    --CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, cc.size( 200, self.Panel_userInfo:getContentSize().height+10), false);
end
--列表项的尺寸
function GameHistory:tabel_cellSizeForTable(sender, index)
    local itemSize = self.exampleInfo:getContentSize();  
    return self.ImageBg:getChildByName("Panel_size"):getContentSize().width, itemSize.height+10;
end

--列表项的数量
function GameHistory:tabel_numberOfCellsInTableView(sender)
    return #self.historyList;
end

--创建列表项
function GameHistory:tabel_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    if nil == cell then
        cell = cc.TableViewCell:new();
        local gamePanel = self.exampleInfo:clone();
        gamePanel:ignoreContentAdaptWithSize(true);
        gamePanel:setVisible(true);  
        gamePanel:setPosition(cc.p(self.ImageBg:getChildByName("Panel_size"):getContentSize().width/2,gamePanel:getContentSize().height/2+5));  
        cell:addChild(gamePanel);
        self:SetGameBtnInfo(gamePanel, index);     
    else
        local gamePanel = cell:getChildByName("Panel_exampleInfo");
        self:SetGameBtnInfo(gamePanel, index);
    end
    
    return cell;
end

function GameHistory:SetGameBtnInfo(gamePanel,idx)
    local historyInfo = self.historyList[idx];
    local diceNum = historyInfo[2];
    cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
    for i = 1,3 do--设置点数
        -- luaPrint("diceNum",diceNum);
        gamePanel:getChildByName("Image_Dice"..i):loadTexture("yyy_Dice"..(diceNum%10)..".png",UI_TEX_TYPE_PLIST);
        diceNum = math.floor(diceNum/10);
    end
    --设置点数和
    gamePanel:getChildByName("Text_DiceSum"):setString(historyInfo[3]..":;");
    --判断大小
    local judgeImage = gamePanel:getChildByName("Image_SumJudge");
    judgeImage:ignoreContentAdaptWithSize(true);
    if historyInfo[4] == 2 then--大
        judgeImage:loadTexture("yyy_da.png",UI_TEX_TYPE_PLIST);
    elseif historyInfo[4] == 3 then--豹子
        judgeImage:loadTexture("yyy_baozi.png",UI_TEX_TYPE_PLIST);
    else--小
        judgeImage:loadTexture("yyy_xiao.png",UI_TEX_TYPE_PLIST);
    end
end


return GameHistory
local RankInfoLayer = class("RankInfoLayer", BaseWindow)

function RankInfoLayer:create(tableLayer)
	return RankInfoLayer.new(tableLayer);
end

function RankInfoLayer:ctor(tableLayer)
	self.super.ctor(self, nil, true);
	luaDump(data,"LuZiLayer")
	self:setName("RankInfoLayer");
	self.tableLayer = tableLayer;
	--self.recordData = data;
	local uiTable = {
		--Image_zhu = "Image_zhu",
		--Image_da = "Image_da",
		Button_hideOther = "Button_hideOther",
		Panel_otherBg = "Panel_otherBg",
		ListView_otherBg = "ListView_otherBg",
		Panel_otherMsg = "Panel_otherMsg",
		Text_otherNum = "Text_otherNum",
		--Button_luzi = "Button_luzi",
		--Image_wantBank = "Image_wantBank",
	}

	loadNewCsb(self,"baijiale/RankInfoLayer",uiTable)
	self:initData();
	self:initUI();

end

function RankInfoLayer:initData()
	
	-- self.width1 = self.Image_zhu:getContentSize().width;
	-- self.height1 = self.Image_zhu:getContentSize().height;
	-- self.dis = self.height1/6--30;--间距


end

function RankInfoLayer:initUI()
	if self.Button_hideOther then
		luaPrint("找到关闭按钮");
		self.Button_hideOther:addClickEventListener(function ( ... )
			-- body
			luaPrint("close");
			self:removeFromParent();
		end);
	end

	self:initOtherMsgPanle();
	
end

function RankInfoLayer:initOtherMsgPanle()
   --其他用户信息的显示隐藏
    --self.Button_hideOther:setVisible(false)
    --self.Panel_otherBg:setVisible(false)
    if self.Panel_otherBg then
        local ListView_otherBg = self.Panel_otherBg:getChildByName("ListView_otherBg");
        local sizeScroll = ListView_otherBg:getContentSize();
        local posScrollX,posScrollY = ListView_otherBg:getPosition();
        self.Panel_otherMsg = ListView_otherBg:getChildByName("Panel_otherMsg");
        self.Panel_otherMsg:retain();
        -- 获取样本战绩信息的容器
        self.rankTableView = cc.TableView:create(cc.size(sizeScroll.width,sizeScroll.height));
        if self.rankTableView then
            self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
            self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
            self.rankTableView:setPosition(cc.p(posScrollX,posScrollY));
            self.rankTableView:setDelegate();

            self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
            self.rankTableView:reloadData();
            self.Panel_otherBg:addChild(self.rankTableView);
        end
        ListView_otherBg:removeFromParent();
    end
end

function RankInfoLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function RankInfoLayer:Rank_cellSizeForTable(view, idx)  

    local width = self.Panel_otherMsg:getContentSize().width;
    local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return width, height;  
end  
  
function RankInfoLayer:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
    return table.nums(self.tableLayer.otherMsgTable);
end  
  
function RankInfoLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self.Panel_otherMsg:clone(); 
        rankItem:setPosition(cc.p(0,0));
        if rankItem then
            self:setRankInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("Panel_otherMsg");
        self:setRankInfo(rankItem,index);
    end
    
    return cell;
end 

function RankInfoLayer:setRankInfo(rankItem,index)
    luaPrint("TableLayer:setRankInfo--------",index)
    local userInfo = self.tableLayer.otherMsgTable[index];
   --luaDump(self.tableLogic._deskUserList._users,"infoTable")
   --luaDump(userInfo,"userInfo")
    if userInfo  then
        local nameText = rankItem:getChildByName("Text_otherName");
        if nameText then
            nameText:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
        end

        local Text_otherMoney = rankItem:getChildByName("Text_otherMoney");
        if Text_otherMoney then
            Text_otherMoney:setString(numberToString2(userInfo.i64Money));
        end
        
        local Image_otherHead = rankItem:getChildByName("Image_otherHead");
        if Image_otherHead then
            --luaPrint("getHeadPath(userInfo.bLogoID)",getHeadPath(userInfo.bLogoID))
            Image_otherHead:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
        end
    end
    
end

--tableview的reloadData后的坐标问题（上下滚动）isNeedFlush是否需要滚动到顶
function RankInfoLayer:CommomFunc_TableViewReloadData_Vertical(pTableView, singleCellSize, isNeedFlush)
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

--刷新其他玩家信息
function RankInfoLayer:flushOtherMsg()
    luaPrint("有玩家进入或者退出,刷新界面RankInfoLayer")
    --local userCount = self.tableLayer.tableLogic:getOnlineUserCount();
    --local num = userCount -1;
    --self.tableLayer.Text_otherNum:setString("("..num..")");
    --self.tableLayer.otherMsgTable  = self:getOthersTable();
    if self.rankTableView then
        self:CommomFunc_TableViewReloadData_Vertical(self.rankTableView, self.Panel_otherMsg:getContentSize(), false);
    end
end

return RankInfoLayer;
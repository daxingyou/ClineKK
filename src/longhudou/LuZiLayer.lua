local LuZiLayer = class("LuZiLayer", PopLayer)

function LuZiLayer:create(data)
	return LuZiLayer.new(data);
end

function LuZiLayer:ctor(data)
	self.super.ctor(self, PopType.none);
	--luaDump(data,"LuZiLayer")
	self:setName("LuZiLayer");
	-- data = {}
	-- for i=1,15 do
	-- 	local msg = {};
	-- 	msg.iWinner = 1
	-- 	msg.iCardShape = 2
	-- 	table.insert(data,msg)
	-- end
	-- local msg = {};
	-- msg.iWinner = 2
	-- msg.iCardShape = 5
	-- table.insert(data,msg)
	-- for i=1,3 do
	-- 	local msg = {};
	-- 	msg.iWinner = 1
	-- 	msg.iCardShape = 2
	-- 	table.insert(data,msg)
	-- end
	-- for k=1,8 do
	-- 	for i=1,20 do
	-- 		local msg = {};
	-- 		msg.iWinner = k%2
	-- 		msg.iCardShape = 2
	-- 		table.insert(data,msg)
	-- 	end
	-- end
	-- self:removeAllChildren();
	if data then
		for i,msg in ipairs(data) do
			msg.last = false; 
			if i == #data then --最后一个
				msg.last = true;
			end
		end

		self.recordData = clone(data);--原始数据--table
	end

	local uiTable = {
		Button_close = "Button_close",
		Slider_ratio = "Slider_ratio",
		Text_hei = "Text_hei",
		Text_hong = "Text_hong",
		ListView_luzi = "ListView_luzi",
		Panel_pailu = "Panel_pailu",
		ListView_pailu = "ListView_pailu",
		Panel_pailu1 = "Panel_pailu1",
		Image_pailu = "Image_pailu",
		Panel_zoushi = "Panel_zoushi",
		Panel_zoushi1 = "Panel_zoushi1",
		Image_pailudi = "Image_pailudi",
		ListView_paixing = "ListView_paixing",
	}
	loadNewCsb(self,"longhudou/LuziLayer",uiTable)
	self.xBg = self.csbNode
	 self:initData();
	 self:initUI();
	 --self.Image_pailudi:setVisible(false)
	--self.colorLayer:setOpacity(100);

	self.colorLayer:setOpacity(150)

end

function LuZiLayer:initData()
	self:segmentation_zhulu1();
	self.isFade = false;
end

function LuZiLayer:segmentation_zhulu1()
	local tableX = 1000;
	local tableY = 7;

	local zhuTable = {}--一个形象的二维数组
	local zhuTableMsg = {}--一个形象的二维数组的msg

	for i=1,tableX do--X
	   zhuTable[i] = {}
	   zhuTableMsg[i] = {};
	   for j=1,tableY do --y
	   		zhuTable[i][j] = -1;
	   		zhuTableMsg[i][j] = {};
	   end
	end
	
	local zhuTableIndex = 1;
	local lastColor = 0;
	--luaDump(self.recordData)
	local copyRecordData = clone(self.recordData);
	for index,data in pairs(copyRecordData) do
		data.indexflag = 0;
		if index == 1 then
			zhuTable[1][1] = self:getType(data,index)
			lastColor = zhuTable[1][1]
			data.indexflag = zhuTableIndex;
			data.posX = 1;
			data.posY = 1;
			zhuTableMsg[1][1] = data;
		else
			if data.iWinner == 2 or lastColor == data.iWinner then

					local tempPosX = -1;
					local tempPosY = -1;
					--luaDump(zhuTableMsg)
					for i,data1 in ipairs(zhuTableMsg) do
						for k=1,7 do
							if data1[k] and data1[k].indexflag == zhuTableIndex then--是当前的
								--luaPrint("tempPosX",data1[k].posX,data1[k].posY)
								tempPosX = data1[k].posX;
								tempPosY = data1[k].posY;
							end
						end
					end

					if tempPosY <7 then
						if zhuTable[tempPosX][tempPosY+1]  == -1 and tempPosX == zhuTableIndex then
							tempPosY = tempPosY + 1;
						else
							--luaPrint("tempPosX222222222--------",tempPosX,tempPosY)
							if tempPosY == 1 and zhuTableIndex ~= tempPosX then
								zhuTableIndex = zhuTableIndex +1;
							end
							tempPosX = tempPosX + 1;
						end
					else
						--luaPrint("tempPosX2222222221111111111111--------",tempPosX,tempPosY)
						tempPosX = tempPosX + 1;
					end
						zhuTable[tempPosX][tempPosY] =  self:getType(data,index);
						data.indexflag = zhuTableIndex;
						data.posX = tempPosX;
						data.posY = tempPosY;
						zhuTableMsg[tempPosX][tempPosY] = data;

			else
				--luaPrint("tempPosX33333333--------",zhuTableIndex,data.iWinner,copyRecordData[index-1].iWinner)
				zhuTableIndex = zhuTableIndex +1;
				zhuTable[zhuTableIndex][1] =  self:getType(data,index);
				lastColor = zhuTable[zhuTableIndex][1]
				data.indexflag = zhuTableIndex;
				data.posX = zhuTableIndex;
				data.posY = 1;
				zhuTableMsg[zhuTableIndex][1] = data;
			end  
		end
	end
	

	self.zhuTable = clone(zhuTable);
	self.zhuTableMsg = clone(zhuTableMsg);
end


--分割数据(珠路)
--把数据分割到一个二维数组中
function LuZiLayer:segmentation_zhulu()
	
	local tableX = 1000;
	local tableY = 7;

	local zhuTable = {}--一个形象的二维数组
	local zhuTableMsg = {}--一个形象的二维数组的msg
	--local zhuTable = {}
	for i=1,tableX do--X
	   zhuTable[i] = {}
	   zhuTableMsg[i] = {};
	   for j=1,tableY do --y
	   		zhuTable[i][j] = -1;
	   		zhuTableMsg[i][j] = {};
	   end
	end

	--luaDump(zhuTable,"zhuTable");
	local posX = 1;
	for k,msg in pairs(self.recordData) do
		if k == 1 then
			zhuTable[1][1] = self:getType(msg,k);
			zhuTableMsg[1][1] = clone(msg);
			luaPrint("1111111111111111111");
			--luaDump(zhuTable,"zhuTable0")
			posX = posX+1
		else
			--local zhuX = 2;
			local have = false;
			for i,table in pairs(zhuTable) do
			-- 	--luaDump(table,"table");
			-- 	--从第二个开始处理 i=2 开始
			 	if table[1] == -1 then
			 		if zhuTable[i-1][1] ~= self:getType(msg,k) then
						zhuTable[i][1] = self:getType(msg,k)
						zhuTableMsg[i][1] = clone(msg);
						luaPrint("222222222222222222222");
						break;
			 		else
						for m=1,tableY do
							if zhuTable[i-1][m] == -1 then
								zhuTable[i-1][m] = self:getType(msg,k);
								zhuTableMsg[i-1][m] = clone(msg);
								luaPrint("33333333333333333333333333");
								have = true;
								break;
							end

							--转弯
							if m+1 <= tableY then
								if zhuTable[i-1][m] ~= -1 and zhuTable[i-1][m] ~= zhuTable[i-1][m+1] and zhuTable[i-1][m+1]~= -1 then
									--zhuTable[i][m] = self:getType(msg);
									--转弯
									for p=0,tableX-i do
										if zhuTable[i+p][m] == -1 then
											zhuTable[i+p][m] = self:getType(msg,k);
											zhuTableMsg[i+p][m] = clone(msg);
											have = true;
											luaPrint("44444444444444444444444444");
											break;
										end
									end
								elseif zhuTable[i-1][m] ~= -1 and zhuTable[i-1][m+1] == -1 then
									zhuTable[i-1][m+1] = self:getType(msg,k);
									zhuTableMsg[i-1][m+1] = clone(msg);
									have = true;
									luaPrint("66666666666666666666666666");
									break;
								end
							elseif m == tableY and zhuTable[i-1][m] ~= -1 then
								--转弯
								for p=0,tableX-i do
									if zhuTable[i+p][m] == -1 then
										zhuTable[i+p][m] = self:getType(msg,k);
										zhuTableMsg[i+p][m] = clone(msg);
										have = true;
										luaPrint("77777777777777777777777");
										break;
									end
								end
							end

							if have then break; end
						
						end

						if have then break; end
						
			 		end
			 	end

			end
		end
	end

	--luaDump(zhuTable,"zhuTable");
	self.zhuTable = clone(zhuTable);
	self.zhuTableMsg = clone(zhuTableMsg);

end

--0龙 1虎 2平
function LuZiLayer:getType(msg,k)
	local iWinner = clone(msg.iWinner);
	if iWinner == 2 then
		local lastMsg = nil;

		for i=0,20 do
			if k-i > 0 then
				lastMsg = self.recordData[k-i];
				if lastMsg then
					if lastMsg.iWinner ~= 2 then --上一个不是2
						iWinner = clone(lastMsg.iWinner);
						break;
					end
				end
			end
		end
	end
	
	return iWinner;
end

function LuZiLayer:initUI()

	self.Button_close:addClickEventListener(function ()
		self:removeFromParent();
	end);

	self:initOtherMsgPanle_zhu();

	self:updateLuziLayer();
end

--刷新界面
function LuZiLayer:updateLuziLayer(data)
	if data then
		for i,msg in ipairs(data) do
			msg.last = false; 
			if i == #data then --最后一个
				msg.last = true;
			end
		end
		self.recordData = clone(data);--原始数据--table
	end
	
	self:segmentation_zhulu1()
	self.isFade = true
	if self.TableView_zhu then
		self:CommomFunc_TableViewReloadData_Vertical(self.TableView_zhu, self.Panel_pailu1:getContentSize(), false);
	end

	self:showHistory();
	--self:showPaiXing();
	self:showSlider();
end



-------------------------------------珠路---------------------------------------------------------------------------------
function LuZiLayer:initOtherMsgPanle_zhu()
	 -- 创建按钮的tableview
	if self.Panel_pailu then
        local Panel_zhulu = self.Panel_pailu:getChildByName("ListView_pailu");
        local sizeScroll = self.ListView_pailu:getContentSize();
        local posScrollX,posScrollY = Panel_zhulu:getPosition();
        self.Panel_pailu1 = Panel_zhulu:getChildByName("Panel_pailu1");
        self.Panel_pailu1:retain();
        -- 获取样本战绩信息的容器
        self.TableView_zhu = cc.TableView:create(cc.size(sizeScroll.width,sizeScroll.height));
        if self.TableView_zhu then
            self.TableView_zhu:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);    
            self.TableView_zhu:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
            self.TableView_zhu:setPosition(cc.p(posScrollX,posScrollY));
            self.TableView_zhu:setDelegate();

            self.TableView_zhu:registerScriptHandler( handler(self, self.Zhu_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
            self.TableView_zhu:registerScriptHandler( handler(self, self.Zhu_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
            self.TableView_zhu:registerScriptHandler( handler(self, self.Zhu_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
            self.TableView_zhu:registerScriptHandler( handler(self, self.Zhu_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
            self.TableView_zhu:reloadData();
            self.Panel_pailu:addChild(self.TableView_zhu);
        end
        Panel_zhulu:removeFromParent();
    end
 
end

function LuZiLayer:Zhu_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function LuZiLayer:Zhu_cellSizeForTable(view, idx)  

    local width = self.Panel_pailu1:getContentSize().width;
    local height = self.Panel_pailu1:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return width, height;  
end  
  
function LuZiLayer:Zhu_numberOfCellsInTableView(view)  
    --luaPrint("Zhu_numberOfCellsInTableView------",table.nums(self.recordData))
    return self:getZhuNum();
end  
  
function LuZiLayer:Zhu_tableCellAtIndex(view, idx)  
    --luaPrint("Zhu_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self.Panel_pailu1:clone(); 
        rankItem:setPosition(cc.p(0,0));
        if rankItem then
            self:setZhuInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("Panel_pailu1");
        self:setZhuInfo(rankItem,index);
    end
    
    return cell;
end 

function LuZiLayer:setZhuInfo(rankItem,index)
   --luaPrint("LuZiLayer:setZhuInfo--------",index,#self.zhuTable,self:getZhuNum())
   	
    display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
    local imageTable = {}; 
    for k=1,7 do
    	local image = rankItem:getChildByName("Image_content_"..k);
    	image:setVisible(false);
    	table.insert(imageTable,image);
    end
    for i=1,7 do
    	if self.zhuTableMsg[index][i] then
    		if self.zhuTableMsg[index][i].iWinner == 0 then--龙
				imageTable[i]:loadTexture("lhd_lanquan.png",UI_TEX_TYPE_PLIST);
				imageTable[i]:setVisible(true);
			elseif	self.zhuTableMsg[index][i].iWinner == 1 then--虎
				imageTable[i]:loadTexture("lhd_hongquan.png",UI_TEX_TYPE_PLIST);
				imageTable[i]:setVisible(true);
			elseif self.zhuTableMsg[index][i].iWinner == 2 then--和
				local hePath = "lhd_lanquan_2.png";
				if self.zhuTable[index][i] == 1 then
					 hePath = "lhd_hongquan_2.png";
				end
				imageTable[i]:loadTexture(hePath,UI_TEX_TYPE_PLIST);
				imageTable[i]:setVisible(true);
			end
			if self.zhuTableMsg[index][i].last and self.isFade and imageTable[i] then
				self.isFade = false
					local action1 =  cc.CallFunc:create(function () imageTable[i]:setVisible(false) end)
			        local action2 =  cc.CallFunc:create(function () imageTable[i]:setVisible(true) end)
			        local action3 = cc.DelayTime:create(0.5);
			        local repeatAction = cc.Repeat:create(cc.Sequence:create(action1,action3,action2,action3),3);
			        imageTable[i]:runAction(cc.Sequence:create(repeatAction))
			end
			-- if index == self:getZhuNum() then

			-- 	if self.zhuTable[index][1] == -1 then--拐弯
					
			-- 	else

			-- 	end 
			-- 	local temp = clone(self.zhuTable[index]);
			-- 	--luaDump(temp)
			-- 	local flag = -1;
			-- 	for i,v in ipairs(temp) do
			-- 		if v == -1 then
			-- 			flag = i;						
			-- 		end
			-- 	end



			-- 	--luaPrint("index-----------",index,flag)
			-- 	if flag ~= -1 and imageTable[flag] and  then
			-- 		self.isFade = false
			-- 		local action1 =  cc.CallFunc:create(function () imageTable[flag]:setVisible(false) end)
			--         local action2 =  cc.CallFunc:create(function () imageTable[flag]:setVisible(true) end)
			--         local action3 = cc.DelayTime:create(0.5);
			--         local repeatAction = cc.Repeat:create(cc.Sequence:create(action1,action3,action2,action3),3);
			--         imageTable[flag]:runAction(cc.Sequence:create(repeatAction))
			--     end
			-- end
    	end


    end
    
end

--获取有效个数
function LuZiLayer:getZhuNum()
	local num = 0 ;
	for k,v in pairs(self.zhuTable) do
		local isNull = false;
		for k,n in pairs(v) do
			if n ~= -1 then
				isNull = true;
				num = num +1;
				break;
			end
		end

		if isNull == false then
			break;
		end
	end
	return num;
end

--横向的tableView刷新数据
function LuZiLayer:CommomFunc_TableViewReloadData_Vertical(pTableView, singleCellSize, isNeedFlush)
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
        if contentSize.width > viewSize.width then
            local minPointX = viewSize.width - contentSize.width;
            local maxPointX = 0;
            if currOffSet.x < minPointX then
                currOffSet.x = minPointX;
            elseif currOffSet.x > maxPointX then
                currOffSet.x = maxPointX;
            end
           -- luaPrint("------------------",currOffSet.x,maxPointX)
            currOffSet.x = minPointX;
            pTableView:setContentOffset(currOffSet);
        end
    end    
end

--获取有效的历史实录
function LuZiLayer:getEffectiveData(num)
	local realRecordTable = {};
	--luaDump(self.recordData)
	for i,v in ipairs(self.recordData) do
		--luaDump(v)
		if v.iWinner ~= 255 then
			table.insert(realRecordTable,v);
		end
	end
	if num then
		--luaDump(realRecordTable,"realRecordTable11111")
		local effectReacodTable = {};
		if num >= #realRecordTable then
			return realRecordTable;
		else
			for i,v in ipairs(realRecordTable) do
				if i > #realRecordTable - num then
					table.insert(effectReacodTable,v)
				end
			end
			--luaDump(effectReacodTable,"effectReacodTable222222")
			return effectReacodTable;
		end 
	else
		return realRecordTable;
	end
end

function LuZiLayer:showSlider()
	local pailuTable = self:getEffectiveData(20);

	if #pailuTable > 0 then 
		local huwinNum  = 0;
		local longwinNum  = 0;
		for i,v in ipairs(pailuTable) do
			if v.iWinner == 1 then
				huwinNum = huwinNum + 1;
			elseif v.iWinner == 0 then 
				longwinNum = longwinNum + 1;------long
			end
		end

		if (huwinNum+longwinNum) == 0 then
			self.Text_hei:setString("50%")
			self.Text_hong:setString("50%")
			return;
		end

		local percent = math.round(longwinNum/(huwinNum+longwinNum)* 100) ;--
		self.Slider_ratio:setPercent(percent)

		self.Text_hei:setString(percent.."%")
		self.Text_hong:setString((100-percent).."%")
	end
end

--显示界面上的路子
function LuZiLayer:showHistory()
	local pailuTable = self:getEffectiveData(20);
	self.ListView_luzi:setScrollBarEnabled(false);
	self.ListView_luzi:removeAllChildren();
	--luaPrint("showHistory,pailuTable--------",#pailuTable)
	if #pailuTable > 0 then
		for i=1,#pailuTable do
			local layout = ccui.Layout:create();
		    layout:setContentSize(cc.size(38, 30));
		    layout:setPosition(38*(i-1),15)
		  
		   	 local imgPath = "lhd_lvqiu.png";
		    if pailuTable[i].iWinner == 0 then
		    	imgPath = "lhd_lanqiu.png";
		    elseif pailuTable[i].iWinner == 1 then
		   		imgPath = "lhd_hongqiu.png";
		   	end
		    local content = cc.Sprite:createWithSpriteFrameName(imgPath)
		    content:setPosition(15,10)
		    layout:addChild(content);
		    self.ListView_luzi:pushBackCustomItem(layout);
		end
	end
end

return LuZiLayer;
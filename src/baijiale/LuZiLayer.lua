local LuZiLayer = class("LuZiLayer", PopLayer)

function LuZiLayer:create(data)
	return LuZiLayer.new(data);
end

function LuZiLayer:ctor(data)
	--self.super.ctor(self, nil, true);
	--self.super.ctor(self)
	self.super.ctor(self,PopType.none)
	self:setName("ResultLayer");
	luaDump(data,"LuZiLayer")
	self:setName("LuZiLayer");
	self:removeAllChildren();

	self.recordData = clone(data);--原始数据--table

	local uiTable = {
		Button_close = "Button_close",
		--Panel_zhulu = "Panel_zhulu",
		Panel_zhulu = "Panel_zhulu",
		Panel_zhu_cell = "Panel_zhu_cell",
		Panel_dalu = "Panel_dalu",
		Panel_dalu_cell = "Panel_dalu_cell",
		AtlasLabel_xian = "AtlasLabel_xian",
		AtlasLabel_zhuang = "AtlasLabel_zhuang",
		AtlasLabel_ping = "AtlasLabel_ping",
		AtlasLabel_zhuangdui = "AtlasLabel_zhuangdui",
		AtlasLabel_xiandui = "AtlasLabel_xiandui",
	}
	loadNewCsb(self,"baijiale/LuLayer",uiTable)
	self.xBg = self.csbNode
	self:initData();
	self:initUI();
	self:updateNum();
	--self.colorLayer:setOpacity(100);

end

function LuZiLayer:initData()
	
	--分割数据(珠路)
	self:segmentation_zhulu();

	self.newData = self:SortWayList(self.recordData);

	--分割数据(大路)
	self:segmentation_dalu();

end

--刷新数量
function LuZiLayer:updateNum()
	-- {
	-- 	bBankerTwoPair = false,
	-- 	bPlayerTwoPair = false,
	-- 	cbBankerCount  = 3,
	-- 	cbKingWinner   = 0,
	-- 	cbPlayerCount  = 1,
 -- 	},
	local xian = 0
	local zhuang = 0
	local ping = 0
	local zhuangdui = 0
	local xiandui = 0
	for k,msg in pairs(self.recordData) do
		if msg.cbPlayerCount>msg.cbBankerCount then
			xian = xian+1
		elseif msg.cbPlayerCount==msg.cbBankerCount then
			ping = ping+1
		elseif msg.cbPlayerCount<msg.cbBankerCount then
			zhuang = zhuang+1
		end

		if msg.bBankerTwoPair then
			zhuangdui = zhuangdui+1
		end
		if msg.bPlayerTwoPair then
			xiandui = xiandui+1
		end
	end

	self.AtlasLabel_xian:setString(xian);
	self.AtlasLabel_zhuang:setString(zhuang);
	self.AtlasLabel_ping:setString(ping);
	self.AtlasLabel_zhuangdui:setString(zhuangdui);
	self.AtlasLabel_xiandui:setString(xiandui);

end

--分割数据(大路)
function LuZiLayer:segmentation_dalu()
	local tableX = 100;
	local tableY = 5;

	local daTable = {};--一个形象的二维数组
	local daTableMsg = {}--一个形象的二维数组的msg
	for i=1,tableX do--X
	   daTable[i] = {}
	   daTableMsg[i] = {};
	   for j=1,tableY do --y
	   		daTable[i][j] = -1;
	   		daTableMsg[i][j] = {};
	   end
	end

	for k,msg in pairs(self.recordData) do

		daTable[math.floor((k-1)/5)+1][(k-1)%5 +1] = self:getType(msg);
		daTableMsg[math.floor((k-1)/5)+1][(k-1)%5 +1] = clone(msg);

	end

	self.daTable = clone(daTable);
	self.daTableMsg = clone(daTableMsg);

end


--分割数据(珠路)
--把数据分割到一个二维数组中
function LuZiLayer:segmentation_zhulu()
	
	local tableX = 100;
	local tableY = 5;

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
			zhuTable[1][1] = self:getType(msg);
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
			 		if zhuTable[i-1][1] ~= self:getType(msg) then
						zhuTable[i][1] = self:getType(msg)
						zhuTableMsg[i][1] = clone(msg);
						luaPrint("222222222222222222222");
						break;
			 		else
						for m=1,tableY do
							if zhuTable[i-1][m] == -1 then
								zhuTable[i-1][m] = self:getType(msg);
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
											zhuTable[i+p][m] = self:getType(msg);
											zhuTableMsg[i+p][m] = clone(msg);
											have = true;
											zhuTableMsg[i+p][m].sign = self:getType(msg);
											luaPrint("44444444444444444444444444");
											break;
										end
									end
								elseif zhuTable[i-1][m] ~= -1 and zhuTable[i-1][m+1] == -1 then
									zhuTable[i-1][m+1] = self:getType(msg);
									zhuTableMsg[i-1][m+1] = clone(msg);
									have = true;
									luaPrint("66666666666666666666666666");
									break;
								end
							elseif m == tableY and zhuTable[i-1][m] ~= -1 then
								--转弯
								luaPrint("转弯",zhuTableMsg[i][m].sign,zhuTableMsg[i-1][m].sign);
								local index_m = m;
								if self:getType(msg) == zhuTableMsg[i-1][m].sign and zhuTableMsg[i-1][m].sign~=nil then
									-- for p=0,tableX-i do
									-- 	if zhuTable[i+p][m-1] == -1 then
									-- 		zhuTable[i+p][m-1] = self:getType(msg);
									-- 		zhuTableMsg[i+p][m-1] = clone(msg);
									-- 		have = true;
									-- 		zhuTableMsg[i+p][m-1].sign = self:getType(msg);
									-- 		luaPrint("77777777777000777777777777");
									-- 		break;
									-- 	end
									-- end
									index_m = m - 1;
								end
								for p=0,tableX-i do
									if zhuTable[i+p][index_m] == -1 then
										zhuTable[i+p][index_m] = self:getType(msg);
										zhuTableMsg[i+p][index_m] = clone(msg);
										have = true;
										zhuTableMsg[i+p][index_m].sign = self:getType(msg);
										--luaPrint("77777777777771117777777777");
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

	luaDump(zhuTableMsg,"zhuTableMsg");
	self.zhuTable = clone(zhuTable);
	self.zhuTableMsg = clone(zhuTableMsg);

end

--大路排序
function LuZiLayer:SortWayList(msg)
	local msg = clone(msg);

	local dataDeal = {};

	local MaxHeight = 5;

	for i = 1,#msg do
		if i == 1 then
			dataDeal[1] = {};
			dataDeal[1][1] = msg[i];
			msg[i].point = cc.p(1,1);--记录点的位置
			msg[i].count = 1;--记录相同的个数
			msg[i].color = self:SetColor(msg[i]);
		else
			if self:JudgeSamePoint(msg[i],msg[i-1]) then--相同的类型
				local point = msg[i-1].point;
				if dataDeal[point.x][point.y+1] == nil and point.y < MaxHeight then--优先先竖着加
					dataDeal[point.x][point.y+1] = msg[i];
					msg[i].point = cc.p(point.x,point.y+1);
				else
					if dataDeal[point.x+1] == nil then
						dataDeal[point.x+1] = {};
					end
					dataDeal[point.x+1][point.y] = msg[i];
					msg[i].point = cc.p(point.x+1,point.y);
				end
				msg[i].count = msg[i-1].count+1;
				msg[i].color = self:SetColor(msg[i],msg[i-1]);
			else
				local point  = msg[i - msg[i-1].count].point;
				if dataDeal[point.x+1] == nil then
					dataDeal[point.x+1] = {};
				end

				dataDeal[point.x+1][point.y] = msg[i];
				msg[i].point = cc.p(point.x+1,point.y);
				msg[i].count = 1;
				msg[i].color = self:SetColor(msg[i]);
			end

		end
	end

	luaDump(dataDeal,"排序");
	return dataDeal;
end

function LuZiLayer:getType(msg)
	if msg.cbPlayerCount>msg.cbBankerCount then
		return 1;--闲
	elseif msg.cbPlayerCount<msg.cbBankerCount then
		return 2--庄
	elseif msg.cbPlayerCount==msg.cbBankerCount then
		return 0--平
	end
end

--设置颜色
function LuZiLayer:SetColor(msg,leftMsg)
	local msgType = self:getType(msg);
	if msgType == 0 then--如果是平则判断跟上个颜色一样
		if leftMsg then
			if leftMsg.color == 1 or leftMsg.color == 3 then
				return 3;
			else
				return 4;
			end
		else--第一个默认闲平
			return 3;
		end
	else
		if msgType == 1 then--闲
			return 1;
		else
			return 2;
		end
	end
end

--1闲 2 庄 3 闲平 4 庄平
function LuZiLayer:JudgeSamePoint(msg,leftMsg)
	local msgType = self:getType(msg);
	local leftMsgType = self:getType(leftMsg);

	if msgType == 0 then--平时返回true
		return true;
	else
		if msgType == leftMsgType then--2个值相同返回true
			return true;
		else
			if self:getType(leftMsg) == 0 then--如果前个平的颜色跟当前颜色相同返回true
				local msgColor = self:SetColor(msg);
				if (leftMsg.color == 3 and msgColor == 1) or (leftMsg.color == 4 and msgColor == 2) then--闲
					return true;
				else
					return false;
				end

			else
				return false;
			end
		end
	end
end

--//分割数据(珠路)
-- value 0:平  1：闲  2：庄
-- color 1:闲（蓝色）2：庄（红色）
function LuZiLayer:segmentation_zhulu1()
    local tableX = 10;
    local tableY = 5;

    local zhuTable = {}  --//一个形象的二维数组
    local zhuTableMsg = {} --//--一个形象的二维数组的msg
    
    for i=1,tableX do --//--X
    
        zhuTable[i] = {}
        zhuTableMsg[i] = {}
        for j=1,tableY do --//--y
         
            zhuTable[i][j] = -1;
            zhuTableMsg[i][j]={};
        end
     end

    --//local posX = 0;
    local foundPos = {x = 1,y = 1};
    local lastColor = 1;
    for k=1,#self.recordData do
    
         local msg = self.recordData[k];
         --//console.log("fonnd Pos" + foundPos.x+" - " + foundPos.y);
         if (k == 1) then
         
            zhuTable[1][1] = self:getType(msg);
            zhuTableMsg[1][1].msg = clone(msg);
            zhuTableMsg[1][1].value = self:getType(msg);
            if (self:getType(msg) == 1 ) then
                zhuTableMsg[1][1].color = 1; --//闲
                lastColor = 1;
            else
            
                zhuTableMsg[1][1].color = 2; --//庄
                lastColor = 2;
            end
            --//console.log("1111111111111111111");
            foundPos = {x = 1,y = 1};
         else
        
                    local have = false;
                    
                    if zhuTable[foundPos.x+1] == nil then
                    	luaPrint("创建一个");
                    	zhuTable[foundPos.x+1] = {-1,-1,-1,-1,-1}
                        zhuTableMsg[foundPos.x+1] = {{},{},{},{},{}};
                    end
                    luaPrint("foundPos",foundPos.x,foundPos.y);
                    luaPrint("---000---",zhuTable[foundPos.x][foundPos.y] ,"-"..self:getType(msg));
                    if (zhuTable[foundPos.x][foundPos.y] == self:getType(msg) or self:getType(msg) == 0 or 
                        (zhuTable[foundPos.x][foundPos.y]==0 and lastColor == self:getType(msg) ) ) then--//上一个和自己相同或者自己平或者上一个平且颜色一样
                        --//向下寻找
                        luaPrint("---111---")
                        if (foundPos.y+1 <= tableY and zhuTable[foundPos.x][foundPos.y+1] == -1) then
                            foundPos = {x = foundPos.x,y = foundPos.y+1}
                            have = true;
                            --//console.log("2222222222222222222");
                        elseif(zhuTable[foundPos.x+1][foundPos.y] == -1) then  --//向右寻找
                        	luaPrint("---222---")
                            foundPos = {x = foundPos.x+1,y = foundPos.y};
                            have = true;
                            --//console.log("33333333333333333333");
                        end
                        zhuTableMsg[foundPos.x][foundPos.y].color = lastColor;
                        lastColor = zhuTableMsg[foundPos.x][foundPos.y].color;
                    
                    else --//上一个和自己不相同
                    	luaPrint("---333---")
                        --//寻找新的X坐标
                        for temp = 1,tableX  do
                        
                            if (zhuTable[temp][0] == -1) then
                            
                                foundPos = {x = temp,y = 0};
                                have = true;
                                --//console.log("4444444444444444444444");
                                if (self:getType(msg) == 1 ) then
                                
                                    zhuTableMsg[foundPos.x][foundPos.y].color = 1; --//闲
                                    lastColor = 1;
                                else
                                    zhuTableMsg[foundPos.x][foundPos.y].color = 2; --//庄
                                    lastColor = 2;
                                end
                                break;
                            end
                        end
                    end

                    zhuTable[foundPos.x][foundPos.y] = self:getType(msg);
                    zhuTableMsg[foundPos.x][foundPos.y].msg = clone(msg);
                    zhuTableMsg[foundPos.x][foundPos.y].value = self:getType(msg);
             
          end

    end
    --//console.log("zhuTableMsg",zhuTableMsg);
    self.zhuTable = zhuTable;
    --self.zhuTableMsg = zhuTableMsg;
    self.zhuTableMsg = self:adjustData_zhu(zhuTableMsg);
    -- for k,v in pairs(self.zhuTableMsg) do
    -- 	luaDump(self.zhuTableMsg[k],"msg");
    -- end
    luaDump(zhuTableMsg,"self.zhuTableMsg1");

end

--//对数据进行刷选
function LuZiLayer:adjustData_zhu(zhuTableMsg)
    local temp = {};
    for i = 1,#zhuTableMsg do
   
        for j = 1,#zhuTableMsg[i] do
        
            if zhuTableMsg[i][j].value ~= nil then
            	table.insert(temp,zhuTableMsg[i]);
                break;
            end
        end
    end
    return temp;
end

function LuZiLayer:initUI()

	self.Button_close:onClick(function ()
		self:removeFromParent();
	end);

	self:initOtherMsgPanle_zhu();

	self:initOtherMsgPanle_da();

end


-------------------------------------珠路---------------------------------------------------------------------------------
function LuZiLayer:initOtherMsgPanle_zhu()
   --其他用户信息的显示隐藏
    --self.Button_hideOther:setVisible(false)
    --self.Panel_otherBg:setVisible(false)
    if self.Panel_zhulu then
        local Panel_zhulu = self.Panel_zhulu:getChildByName("ListView_zhu");
        local sizeScroll = Panel_zhulu:getContentSize();
        local posScrollX,posScrollY = Panel_zhulu:getPosition();
        self.Panel_zhu_cell = Panel_zhulu:getChildByName("Panel_zhu_cell");
        self.Panel_zhu_cell:retain();
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
            self.Panel_zhulu:addChild(self.TableView_zhu);
        end
        Panel_zhulu:removeFromParent();
    end
end

function LuZiLayer:Zhu_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function LuZiLayer:Zhu_cellSizeForTable(view, idx)  

    local width = self.Panel_zhu_cell:getContentSize().width;
    local height = self.Panel_zhu_cell:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return width, height;  
end  
  
function LuZiLayer:Zhu_numberOfCellsInTableView(view)  
    --luaPrint("Zhu_numberOfCellsInTableView------",table.nums(self.recordData))
    return #self.newData--self:getZhuNum();--table.nums(self.recordData);
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
  
function LuZiLayer:Zhu_tableCellAtIndex(view, idx)  
    --luaPrint("Zhu_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self.Panel_zhu_cell:clone(); 
        rankItem:setPosition(cc.p(0,0));
        if rankItem then
            self:setZhuInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("Panel_zhu_cell");
        self:setZhuInfo(rankItem,index);
    end
    
    return cell;
end 

function LuZiLayer:setZhuInfo(rankItem,index)
    luaPrint("LuZiLayer:setZhuInfo--------",index)
   	local imageTable = {}; 
    
    for k=1,5 do
    	local image = rankItem:getChildByName("Image_"..k);
    	image:setVisible(false);
    	table.insert(imageTable,image);
    end

    --是否显示对子
    function showDui(node,msg)
    	local zhuangdui = node:getChildByName("Image_zhuangdui");
    	local xiandui = node:getChildByName("Image_xiandui");
    	-- {"bPlayerTwoPair","BOOL"},--//对子标识
		-- {"bBankerTwoPair","BOOL"},--//对子标识
		--luaDump(msg,"showDui");
    	zhuangdui:setVisible(msg.bBankerTwoPair);
    	xiandui:setVisible(msg.bPlayerTwoPair);
    end

   --  for i=1,5 do
   --  	if self.zhuTable[index][i] ~= -1 then
   --  		if self.zhuTable[index][i] == 0 then--平
   --  			local str = "ping_xian.png"
   --  			if i>1 then
   --  				if self.zhuTable[index][i-1] == 1 then
   --  					str = "ping_xian.png"
   --  				elseif self.zhuTable[index][i-1] == 2 then
   --  					str = "ping_zhuang.png"
   --  				elseif self.zhuTable[index][i-1] == 0 then
   --  					if index>1 then
   --  						if self.zhuTable[index-1][1] == 1 then
   --  							str = "ping_xian.png"
			-- 				elseif self.zhuTable[index-1][1] == 2 then
			-- 					str = "ping_zhuang.png"
   --  						end
   --  					end
   --  				end
   --  			elseif i == 1 then
   --  				--luaPrint("11111",index);
   --  				--luaDump(self.zhuTable,"self.zhuTable");
   --  				if index >1 then
   --  					if self.zhuTable[index-1][1] == 1 then
   --  						str = "ping_xian.png"
   --  					elseif self.zhuTable[index-1][1] == 2 then
   --  						str = "ping_zhuang.png"
   --  					end
	  --   			end
   --  			end
   --  			imageTable[i]:loadTexture(str,UI_TEX_TYPE_PLIST);
   --  			imageTable[i]:setVisible(true);
   --  			showDui(imageTable[i],self.zhuTableMsg[index][i]);
			-- elseif self.zhuTable[index][i] == 1 then--闲
			-- 	imageTable[i]:loadTexture("LUZI_lanquan.png",UI_TEX_TYPE_PLIST);
			-- 	imageTable[i]:setVisible(true);
			-- 	showDui(imageTable[i],self.zhuTableMsg[index][i]);
			-- elseif	self.zhuTable[index][i] == 2 then--庄
			-- 	imageTable[i]:loadTexture("LUZI_hongquan.png",UI_TEX_TYPE_PLIST);
			-- 	imageTable[i]:setVisible(true);
			-- 	showDui(imageTable[i],self.zhuTableMsg[index][i]);
			-- end
   --  	end
   --  end
   --if self.newData[index] then
	   for i=1,5 do
	   		if self.newData[index][i] then
		   		if self.newData[index][i].color == 3 or self.newData[index][i].color == 4 then--平
		   			local str = "";
		   			if self.newData[index][i].color == 3 then
		   				str = "ping_xian.png"
		   			else
		   				str = "ping_zhuang.png"
		   			end
		   			imageTable[i]:loadTexture(str,UI_TEX_TYPE_PLIST);
		   			imageTable[i]:setVisible(true);
		   		elseif self.newData[index][i].color == 1 then--闲
		   			imageTable[i]:loadTexture("LUZI_lanquan.png",UI_TEX_TYPE_PLIST);
		   			imageTable[i]:setVisible(true);
		   		elseif self.newData[index][i].color == 2 then--庄
		   			imageTable[i]:loadTexture("LUZI_hongquan.png",UI_TEX_TYPE_PLIST);
		   			imageTable[i]:setVisible(true);
		   		end
		   		showDui(imageTable[i],self.newData[index][i]);
		   	end
	   end
    --end
    
end

-----------------------------珠路结束-----------------------------------------------------------------------------


-------------------------------------大路---------------------------------------------------------------------------------
function LuZiLayer:initOtherMsgPanle_da()
   --其他用户信息的显示隐藏
    --self.Button_hideOther:setVisible(false)
    --self.Panel_otherBg:setVisible(false)
    if self.Panel_dalu then
        local Panel_dalu = self.Panel_dalu:getChildByName("ListView_dalu");
        local sizeScroll = Panel_dalu:getContentSize();
        local posScrollX,posScrollY = Panel_dalu:getPosition();
        self.Panel_dalu_cell = Panel_dalu:getChildByName("Panel_dalu_cell");
        self.Panel_dalu_cell:retain();
        -- 获取样本战绩信息的容器
        self.TableView_da = cc.TableView:create(cc.size(sizeScroll.width,sizeScroll.height));
        if self.TableView_da then
            self.TableView_da:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);    
            self.TableView_da:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
            self.TableView_da:setPosition(cc.p(posScrollX,posScrollY));
            self.TableView_da:setDelegate();

            self.TableView_da:registerScriptHandler( handler(self, self.Da_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
            self.TableView_da:registerScriptHandler( handler(self, self.Da_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
            self.TableView_da:registerScriptHandler( handler(self, self.Da_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
            self.TableView_da:registerScriptHandler( handler(self, self.Da_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
            self.TableView_da:reloadData();
            self.Panel_dalu:addChild(self.TableView_da);
        end
        Panel_dalu:removeFromParent();
    end
end

function LuZiLayer:Da_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function LuZiLayer:Da_cellSizeForTable(view, idx)  

    local width = self.Panel_dalu_cell:getContentSize().width;
    local height = self.Panel_dalu_cell:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return width, height;  
end  
  
function LuZiLayer:Da_numberOfCellsInTableView(view)  
    luaPrint("Da_numberOfCellsInTableView------",math.floor(table.nums(self.recordData)/5)+1)
    return math.floor(table.nums(self.recordData)/5)+1;
end  
  
function LuZiLayer:Da_tableCellAtIndex(view, idx)  
    --luaPrint("Zhu_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self.Panel_dalu_cell:clone(); 
        rankItem:setPosition(cc.p(0,0));
        if rankItem then
            self:setDaInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("Panel_dalu_cell");
        self:setDaInfo(rankItem,index);
    end
    
    return cell;
end 

function LuZiLayer:setDaInfo(rankItem,index)
    --luaPrint("LuZiLayer:setDaInfo--------",index)
   	local imageTable = {}; 
    
    for k=1,5 do
    	local image = rankItem:getChildByName("Image_"..k);
    	image:setVisible(false);
    	table.insert(imageTable,image);
    end

    --是否显示对子
    function showDui(node,msg)
    	local zhuangdui = node:getChildByName("Image_zhuangdui");
    	local xiandui = node:getChildByName("Image_xiandui");
    	-- {"bPlayerTwoPair","BOOL"},--//对子标识
		-- {"bBankerTwoPair","BOOL"},--//对子标识
		--luaDump(msg,"showDui");
    	zhuangdui:setVisible(msg.bBankerTwoPair);
    	xiandui:setVisible(msg.bPlayerTwoPair);
    end

    for i=1,5 do
    	if self.daTable[index][i] ~= -1 then
    		if self.daTable[index][i] == 0 then--平
    			imageTable[i]:loadTexture("LUZI_ping_2.png",UI_TEX_TYPE_PLIST);
    			imageTable[i]:setVisible(true);
    			showDui(imageTable[i],self.daTableMsg[index][i]);
			elseif self.daTable[index][i] == 1 then--闲
				imageTable[i]:loadTexture("LUZI_xian_2.png",UI_TEX_TYPE_PLIST);
				imageTable[i]:setVisible(true);
				showDui(imageTable[i],self.daTableMsg[index][i]);
			elseif	self.daTable[index][i] == 2 then--庄
				imageTable[i]:loadTexture("LUZI_zhuang_2.png",UI_TEX_TYPE_PLIST);
				imageTable[i]:setVisible(true);
				showDui(imageTable[i],self.daTableMsg[index][i]);
			end
    	end
    end
    
    
end

-----------------------------大路结束-----------------------------------------------------------------------------

--tableview的reloadData后的坐标问题（上下滚动）isNeedFlush是否需要滚动到顶
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
function LuZiLayer:flushOtherMsg(data)
    luaPrint("有玩家进入或者退出,刷新界面RankInfoLayer")
    self.recordData = clone(data);--原始数据
    self:segmentation_zhulu();
    self:segmentation_dalu();
    self.newData = self:SortWayList(self.recordData);
    if self.TableView_zhu then
        self:CommomFunc_TableViewReloadData_Vertical(self.TableView_zhu, self.Panel_zhu_cell:getContentSize(), false);
    end
    if self.TableView_da then
        self:CommomFunc_TableViewReloadData_Vertical(self.TableView_da, self.Panel_dalu_cell:getContentSize(), false);
    end

    self:updateNum();
end

return LuZiLayer;
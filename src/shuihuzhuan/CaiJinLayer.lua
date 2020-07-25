local CaiJinLayer = class("CaiJinLayer",PopLayer)
local TableLogic = require("shuihuzhuan.TableLogic");
local ShuiHuZhuanInfo = require("shuihuzhuan.shuihuzhuanInfo");

CaiJinLayer.logData = {};
function CaiJinLayer:create(data,poolPoint)
    local layer = CaiJinLayer:new();
	layer:init(data,poolPoint)
    layer:initData()
    return layer;
end

--构造函数
function CaiJinLayer:ctor()	
	display.loadSpriteFrames("shuihuzhuan/image/CaiJin/caijin.plist","shuihuzhuan/image/CaiJin/caijin.png");

	local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",
		Node_note = "Node_1",
        Node_record = "Node_2",
        Button_exit = "Button_close",

        --Node_note的元素
        Button_record = "Button_record";
        Text_Name = "Text_Name";
        Text_BeiShu = "Text_BeiShu";
        Text_YaFen = "Text_YaFen";
        Text_CaiJin = "Text_CaiJin";
        AtlasLabel_money = "AtlasLabel_money";

        --Node_record的元素
        Panel_record = "Panel_record";
        Panel_player= "Panel_player";
        Text_recordTime = "Text_recordTime";
        Text_recordName = "Text_recordName";
        Text_recordYaFen = "Text_recordYaFen";
        Text_recordBeiShu = "Text_recordBeiShu";
        Text_recordCaijin = "Text_recordCaiJin";
	}

	loadNewCsb(self,"shuihuzhuan/CaiJinLayer",uiTable);
end

function CaiJinLayer:init(data,poolPoint)   
    --请求彩金数据 
    self.logData = {}

    if self.Button_exit then
        self.Button_exit:addClickEventListener(function(sender)
			self:ClickExitCallBack(sender);
		end)
    end

    if self.Button_record then
        self.Button_record:addClickEventListener(function(sender)
			self:ClickRecordCallBack(sender);
		end)
    end
    
    luaPrint("poolPoint",poolPoint);
    if self.AtlasLabel_money then
        self:ScoreToMoney(self.AtlasLabel_money,poolPoint)
    end
    
    self.logData = data;

    luaDump(self.logData,"self.logData");
    self:createTableView();
end

    
--明细
function CaiJinLayer:initData()
    if #self.logData == 0 then
        self.Text_Name:setVisible(false);
        self.Text_YaFen:setVisible(false);
        self.Text_BeiShu:setVisible(false);
        self.Text_CaiJin:setVisible(false);
        self.Panel_player:setVisible(false);
        return;
    end
    self.Text_recordTime:setString(timeConvert(self.logData[#self.logData].CreateDate,5));
    -- self.Text_Name:setString(self.logData[#self.logData].strName);
    self.Text_Name:setString(FormotGameNickName(self.logData[#self.logData].strName,nickNameLen));
    self.Text_YaFen:setString(goldConvert(self.logData[#self.logData].nYaFen));
    self.Text_BeiShu:setString(self.logData[#self.logData].nBeiShu);
    self.Text_CaiJin:setString(goldConvert(self.logData[#self.logData].nMoney));
    self:createTableView();
end

--创建tableview
function CaiJinLayer:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end
    luaPrint("self.logData",self.logData)
    luaPrint("#self.logData",#self.logData);
    if #self.logData==0 then
        return;
    end

    self.Panel_player:setVisible(false);
    local showSize = self.Panel_record:getContentSize();
    self.rankTableView = cc.TableView:create(cc.size(showSize.width,showSize.height));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP); 
        self.rankTableView:setPosition(cc.p(0,0));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.Panel_record:addChild(self.rankTableView);
    end
end

--滚动时的回调函数 
function CaiJinLayer:Rank_scrollViewDidScroll(sender)
--    self._isTableViewScroll = true;
end

--列表项的尺寸
function CaiJinLayer:Rank_cellSizeForTable(sender, index)
    local itemSize = self.Panel_player:getContentSize()    
    return itemSize.width, itemSize.height;
end

--列表项的数量
function CaiJinLayer:Rank_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    luaPrint("index",index);
    local InfoIndex = index + 1;
    if nil == cell then
        local newItem = self.Panel_player:clone();
        newItem:setVisible(true);
        newItem:setPosition(cc.p(0,50));
        newItem:setName("Panel_player");      
        if newItem then
            self:setRankInfo(newItem, InfoIndex);   
        end  
        cell = cc.TableViewCell:new();  
        cell:addChild(newItem);
    else
        local newItem = cell:getChildByName("Panel_player");
        self:setRankInfo(newItem, InfoIndex);
    end
    
    return cell;
end

--创建列表项
function CaiJinLayer:Rank_numberOfCellsInTableView(sender)
    
    return #self.logData;
end

function CaiJinLayer:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    
--    self.Text_recordTime:setString(timeConvert(self.logData[self.currentPage][index].CreateDate,5));
    local useName = rankItem:getChildByName("Text_recordName");
    local createTime = rankItem:getChildByName("Text_recordTime");
    local nYafen = rankItem:getChildByName("Text_recordYaFen");
    local nBeiShu= rankItem:getChildByName("Text_recordBeiShu");
    local nMoney = rankItem:getChildByName("Text_recordCaiJin");
    luaDump(self.logData[index],"self.logData[index]")
    createTime:setString(os.date("%m-%d %H:%M",self.logData[index].CreateDate));
    useName:setString(self.logData[index].strName);
    nYafen:setString(goldConvert(self.logData[index].nYaFen));
    nBeiShu:setString(self.logData[index].nBeiShu);
    nMoney:setString(goldConvert(self.logData[index].nMoney));
end

function CaiJinLayer:ClickRecordCallBack()
    self.Node_note:setVisible(false);
    self.Node_record:setVisible(true);
end

function CaiJinLayer:ClickExitCallBack()
    if self.Node_record:isVisible() == true then
        self.Node_record:setVisible(false);
        self.Node_note:setVisible(true);
    else
        self:removeFromParent();
    end    
end

--玩家分数
function CaiJinLayer:ScoreToMoney(pNode,score,string)
	if string == nil then
		string = "";
	end

	local remainderNum = score%100;
	local remainderString = "";

	if remainderNum == 0 then--保留2位小数
		remainderString = remainderString..".00";
	else
		if remainderNum%10 == 0 then
			remainderString = remainderString.."0";
		end
	end
	if pNode == nil then
		return string..(score/100)..remainderString;
	end
	pNode:setString(string..(score/100)..remainderString);
end

return CaiJinLayer;

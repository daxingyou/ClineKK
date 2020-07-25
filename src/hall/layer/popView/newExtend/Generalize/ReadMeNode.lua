local ReadMeNode = class("ReadMeNode", BaseWindow)

--奖励说明

--创建类
function ReadMeNode:create()
    local layer = ReadMeNode.new();
    layer:setName("ReadMeNode");
    return layer;
end

--构造函数
function ReadMeNode:ctor()
    self.super.ctor(self, 0, false);
    local uiTable = {
        Panel_1 = "Panel_1",
        Button_down = "Button_down",

        Panel_2 = "Panel_2",
        Button_up = "Button_up",

        Panel_template = "Panel_template",
        Image_contentRead = "Image_contentRead",
        Button_sm = "Button_sm",
    }

    loadNewCsb(self,"Node_ReadMe",uiTable);

    self:InitData();

    self:InitUI();

    -- self:pushEventInfo(ExtendInfo,"NeedLevelExp",handler(self, self.onNeedLevelExp));
    self:bindEvent()
end

function ReadMeNode:bindEvent()
    self:pushEventInfo(ExtendInfo,"userAgencyLevel",handler(self, self.receiveUserAgencyLevel))
end

--进入
function ReadMeNode:onEnter()
    self.super.onEnter(self);
    local data = {
        {
            LevelName = "1",
            Rat       = 50,
            levelid   = 0,
            needexper = 0,
        },
        {
            LevelName = "2",
            Rat       = 60,
            levelid   = 1,
            needexper = 200000,
        },
        {
            LevelName = "3",
            Rat       = 70,
            levelid   = 2,
            needexper = 500000,
        },
        {
            LevelName = "4",
            Rat       = 80,
            levelid   = 3,
            needexper = 1000000,
        },
        {
            LevelName = "5",
            Rat       = 90,
            levelid   = 4,
            needexper = 2000000,
        },
        {
            LevelName = "6",
            Rat       = 110,
            levelid   = 5,
            needexper = 5000000,
        },
        {
            LevelName = "7",
            Rat       = 130,
            levelid   = 6,
            needexper = 10000000,
        },
        {
            LevelName = "8",
            Rat       = 135,
            levelid   = 7,
            needexper = 15000000,
        },
        {
            LevelName = "9",
            Rat       = 140,
            levelid   = 8,
            needexper = 20000000,
        },
        {
            LevelName = "10",
            Rat       = 145,
            levelid   = 9,
            needexper = 25000000,
        },
        {
            LevelName = "11",
            Rat       = 150,
            levelid   = 10,
            needexper = 30000000,
        },
        {
            LevelName = "12",
            Rat       = 155,
            levelid   = 11,
            needexper = 40000000,
        },
        {
            LevelName = "13",
            Rat       = 160,
            levelid   = 12,
            needexper = 50000000,
        },
        {
            LevelName = "14",
            Rat       = 170,
            levelid   = 13,
            needexper = 60000000,
        },
        {
            LevelName = "15",
            Rat       = 180,
            levelid   = 14,
            needexper = 80000000,
        },
        {
            LevelName = "16",
            Rat       = 190,
            levelid   = 15,
            needexper = 100000000,
        },
        {
            LevelName = "17",
            Rat       = 195,
            levelid   = 16,
            needexper = 150000000,
        },
        {
            LevelName = "18",
            Rat       = 200,
            levelid   = 17,
            needexper = 200000000,
        },
        {
            LevelName = "19",
            Rat       = 205,
            levelid   = 18,
            needexper = 250000000,
        },
        {
            LevelName = "20",
            Rat       = 210,
            levelid   = 19,
            needexper = 300000000,
        },
        {
            LevelName = "21",
            Rat       = 215,
            levelid   = 20,
            needexper = 350000000,
        },
        {
            LevelName = "22",
            Rat       = 220,
            levelid   = 21,
            needexper = 400000000,
        },
        {
            LevelName = "23",
            Rat       = 230,
            levelid   = 22,
            needexper = 450000000,
        },
        {
            LevelName = "24",
            Rat       = 235,
            levelid   = 23,
            needexper = 500000000,
        },
        {
            LevelName = "25",
            Rat       = 240,
            levelid   = 24,
            needexper = 550000000,
        }
    }
    -- if #ExtendInfo.NeedLevelExp > 0 then
        self:onNeedLevelExp({_usedata=data})
    -- else
    --     ExtendInfo:sendGetNeedLevelRequest()
    -- end
    
    ExtendInfo:sendUserAgencyLevel()
end

function ReadMeNode:InitData()
    self.actionFinish = true;
    self.myLevelNode = {}
end

function ReadMeNode:InitUI()
    --设置页面画上滑下
    if self.Button_down then
        self.Button_down:onClick(handler(self,self.DownClick));
    end

    if self.Button_sm then
        self.Button_sm:onClick(handler(self,self.DownClick));
    end

    if self.Button_up then
        self.Button_up:onClick(handler(self,self.UpClick));
    end


    --创建上下晃动的特效
    local moveByUp = cc.MoveBy:create(0.2,cc.p(0,10));
    local moveByDown = cc.MoveBy:create(0.2,cc.p(0,-10));

    self.Button_down:runAction(cc.RepeatForever:create(cc.Sequence:create(moveByUp,moveByDown,moveByDown,moveByUp)));

    local moveByUp1 = cc.MoveBy:create(0.2,cc.p(0,10));
    local moveByDown1 = cc.MoveBy:create(0.2,cc.p(0,-10));
    self.Button_up:runAction(cc.RepeatForever:create(cc.Sequence:create(moveByUp1,moveByDown1,moveByDown1,moveByUp1)));


    self.Panel_template:setVisible(false);

    local text_tips = ccui.Text:create("提示：0-2000实际等于0-1999，以此类推",FONT_PTY_TEXT,20);
    text_tips:setAnchorPoint(0,0.5);
    text_tips:setPosition(cc.p(80,28))
    self.Panel_2:addChild(text_tips)
end

function ReadMeNode:onNeedLevelExp(data)
    local msg = data._usedata;
    self.Image_contentRead:removeAllChildren();
    self:RefreshScene(msg);
end

function ReadMeNode:receiveUserAgencyLevel(data)
    local data = data._usedata

    if data.nUserID == PlatformLogic.loginResult.dwUserID then
        for k,v in pairs(self.myLevelNode) do
            v:setVisible(k == data.nLevel)
        end
    end
end

function ReadMeNode:RefreshScene(msg)
    local posX = {234,699};
    local posY = 434;

    -- local posY = self.Panel_template:getPositionY();

    local setDataToPanel = function(data,count)
        local x = posX[1];
        local yCount = count;
        if count>13 then
            x = posX[2];
            yCount = yCount - 13;
        end

        local temp = self.Panel_template:clone();
        temp:setVisible(true);
        temp:setPosition(x,posY - 33*(yCount-1));
        self.Image_contentRead:addChild(temp)

        local name = temp:getChildByName("Text_name");
        name:setString(data.LevelName);

        local AtlasLabel_num = temp:getChildByName("AtlasLabel_num");
        AtlasLabel_num:setString(count);

        local image = ccui.ImageView:create("newExtend/generalize/Image/my.png")
        image:setPosition(AtlasLabel_num:getPositionX()+30,AtlasLabel_num:getPositionY())
        AtlasLabel_num:getParent():addChild(image)
        image:hide()
        table.insert(self.myLevelNode,image)

        local yejiNum = temp:getChildByName("Text_yejiNum");

        local str = ""..(data.needexper/1000000).."万";

        --值是0
        if data.needexper/1000000 == 0 then
            str = "0";
        end

        if data.needexperNext == nil then
            str = str.."及以上"
        else
            str = str.."到"..(data.needexperNext/1000000).."万";
        end

        yejiNum:setString(str);

        local biliNum = temp:getChildByName("Text_biliNum");
        biliNum:setString("每万"..data.Rat.."元");
    end

    local count = 1;
    for i =1,#msg do
        if msg[i].LevelName == "" then
            break;
        else
            if i == #msg then
                msg[i].needexperNext = nil;
                setDataToPanel(msg[i],count);
            else
                msg[i].needexperNext = msg[i+1].needexper;
                if msg[i+1].LevelName == "" then
                    msg[i].needexperNext = nil;
                end
                setDataToPanel(msg[i],count);
            end
            count = count+1;
        end
    end
end

--滑下
function ReadMeNode:DownClick(sender)
    if self.actionFinish == false then
        return;
    end

    self.Button_up:loadTextures("Image/jiantou.png","Image/jiantou.png",UI_TEX_TYPE_LOCAL);
    self.actionFinish = false;
    self.csbNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(0,665)),cc.CallFunc:create(function()
        self.actionFinish = true;
    end)))
end

--滑上
function ReadMeNode:UpClick(sender)
    if self.actionFinish == false then
        return;
    end

    self.Button_down:loadTextures("Image/jiantou.png","Image/jiantou.png",UI_TEX_TYPE_LOCAL);
    self.actionFinish = false;
    self.csbNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(0,0)),cc.CallFunc:create(function()
        self.actionFinish = true;
    end)))
end


return ReadMeNode;
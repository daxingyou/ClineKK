--情报单

local QingbaoNodeInfo = class("QingbaoNodeInfo", function() return display.newNode(); end)

function QingbaoNodeInfo:ctor(data)
    self.data = data;

    self:initUI();
end

function QingbaoNodeInfo:initUI()
    --luaDump(self.data,"QingbaoNodeInfo")

    local bg = ccui.ImageView:create("qingbao/BGtiao.png");
    bg:setPosition(cc.p(640,74));
    self:addChild(bg);

    self.bg = bg;
    local bgsize = bg:getContentSize();

    local textss = FontConfig.createLabel(FontConfig.gFontConfig_22,self.data.special_desc,FontConfig.colorBlack);
    textss:setPosition(bgsize.width*0.58,bgsize.height*0.5);
    textss:setDimensions(cc.size(1000, 0))
    
    textss:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    textss:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    bg:addChild(textss);

    local url = self.data.special_pic;

    HttpUtils:requestHttp(url,function(result,response)
        if self.onHttpRequestQingBao then
            self:onHttpRequestQingBao(result,response)
        end
    end)
    
end

-- 情报图片
function QingbaoNodeInfo:onHttpRequestQingBao(result, response)
    luaPrint("情报图片------------------",result)
    if result == false then
        luaPrint("http request cmd =  error")
    else
        if self.bg == nil then
            return;
        end

        local savePath = cc.FileUtils:getInstance():getWritablePath();
        local path = savePath.."djQingbao"..self.data.special_id..".png";
        if path then
            -- //渲染图片
            local f = io.open(path, 'wb')
            if f then
                f:write(response)

                f:close()
            end

            local bgsize = self.bg:getContentSize();

            cc.TextureCache:getInstance():removeTextureForKey(path);
            local teamSp=ccui.ImageView:create(path)
            teamSp:setScale(bgsize.height/teamSp:getContentSize().height);
            teamSp:setAnchorPoint(0,0.5); 
            teamSp:setPosition(0,bgsize.height/2);
            self.bg:addChild(teamSp);
        end
    end
end

return QingbaoNodeInfo

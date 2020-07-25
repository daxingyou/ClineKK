local HeadManager = class("HeadManager")

local _instance = nil;

function HeadManager:getInstance()
	if _instance == nil then
		_instance = HeadManager.new();
	end

	return _instance;
end

function HeadManager:ctor()
	self.m_HeadMap = {};
	self.m_HeadLoadMap = {};
	self.m_strRequestUrl = nil;
	self.m_strPostUrl = nil;
end

function HeadManager:setRequestUrl(url)
    self.m_strRequestUrl = url;
end

function HeadManager:setPostUrl(url)
    self.m_strPostUrl = url;
end

function HeadManager:postHttp(filePath, callback)
	HttpUtils:uploadFile(self.m_strPostUrl, filePath, "", callback);
end

function HeadManager:requestHttp(dwUserIdx, pNode, nTimeout)
    if pNode == nil or pNode:getParent() == nil then
        return;
    end

    local iter = self.m_HeadMap[dwUserIdx];

    if isEmptyTable(iter) then
        local now = os.date();
        local iter2 = self.m_HeadLoadMap[dwUserIdx];

        if iter2 ==nil then
        	self.m_HeadLoadMap[dwUserIdx] = tonumber(now);
        else
            if now < iter2 + 30 * 10000 then
                -- //加载图片
                local savePath = cc.FileUtils:getInstance():getWritablePath();
                local pngpath = savePath.."customHead"..dwUserIdx..".png";

                if cc.FileUtils:getInstance():isFileExist(pngpath) then
                    -- //load
                    cc.TextureCache:getInstance():removeTextureForKey(pngpath);
                    local gamePlayerNode = nil;
                    if pNode.view then
                        if pNode.view:getParent() then
                            if pNode.view:getParent():getParent() then
                                if pNode.view:getParent():getParent():getParent() then
                                    gamePlayerNode =  pNode.view:getParent():getParent():getParent():getParent();
                                end
                            end
                        end
                    else
                        if pNode:getParent() then
                            if pNode:getParent():getParent() then
                                if pNode:getParent():getParent():getParent() then
                                    gamePlayerNode =  pNode:getParent():getParent():getParent():getParent();
                                end
                            end
                        end
                    end

                    if gamePlayerNode and gamePlayerNode.bUserCutState  then
                        gamePlayerNode:setCutHead();
                    else
                        if pNode.view then
                            pNode.view:loadTexture(pngpath);
                            if 96 < pNode.view:getContentSize().width then
                                local Xscale = pNode.view:getScaleX();
                                local s = 96/pNode.view:getContentSize().width*Xscale;
                                pNode.view:setScale(s);
                            end
                        else
                            pNode:loadTexture(pngpath);
                            if 96 < pNode:getContentSize().width then
                                local Xscale = pNode:getScaleX();
                                local s = 96/pNode:getContentSize().width*Xscale;
                                pNode:setScale(s);
                            end
                        end
                    end
                else
                    self.m_HeadLoadMap[dwUserIdx] = now;        --//更新
                end
            else
                self.m_HeadLoadMap[dwUserIdx] = now;        --//更新
            end
        end

        if self.m_HeadMap[dwUserIdx] == nil then
        	self.m_HeadMap[dwUserIdx] = {};
        end

        -- self.m_HeadMap[dwUserIdx] = {};
        table.insert(self.m_HeadMap[dwUserIdx], pNode);
        pNode:retain();

        local url = self.m_strRequestUrl.."head_"..dwUserIdx..".png";

        local xhr = cc.XMLHttpRequest:new()
	    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	    xhr:open("GET", url)

	    local function onReadyStateChanged()
	        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            luaPrint("xhr.response ------------  "..xhr.response)

	            self:onGetResponse(dwUserIdx, true, xhr.response)
	        else
	            luaPrint("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
	            self:onGetResponse(dwUserIdx, false, xhr.response)
	        end

	        xhr:unregisterScriptHandler()
	    end

	    xhr:registerScriptHandler(onReadyStateChanged)
	    xhr:send()
    else
    	table.insert(self.m_HeadMap[dwUserIdx], pNode);
    	pNode:retain();
    end
end

function HeadManager:onGetResponse(dwUserIdx, result, response)
	if response == nil then
        return;
    end
    
    if result == true then
        -- //加载图片
        local savePath = cc.FileUtils:getInstance():getWritablePath();
        local path = savePath.."customHead"..dwUserIdx..".png";

        if path then
            -- //渲染图片
            local f = io.open(path, 'wb')
		    f:write(response)

		    f:close()

            cc.TextureCache:getInstance():removeTextureForKey(path);
            local iter = self.m_HeadMap[dwUserIdx];

            if  iter ~= nil then
            	for k,v in pairs(iter) do
					if v == nil then
						--todo
					elseif v:getParent() ==nil then
						v:release();
					else
						v:release();
                        if v.view then
                            local gamePlayerNode = nil;
                            if v.view then
                                if v.view:getParent() then
                                    if v.view:getParent():getParent() then
                                        if v.view:getParent():getParent():getParent() then
                                            gamePlayerNode =  v.view:getParent():getParent():getParent():getParent();
                                        end
                                    end
                                end                        
                            else
                                if v:getParent() then
                                    if v:getParent():getParent() then
                                        if v:getParent():getParent():getParent() then
                                            gamePlayerNode =  v:getParent():getParent():getParent():getParent();
                                        end
                                    end
                                end
                            end
                        
                            if gamePlayerNode and gamePlayerNode.bUserCutState  then
                                gamePlayerNode:setCutHead();
                            else
                                if cc.FileUtils:getInstance():isFileExist(path) then
                                    v:loadTexture(path);
                                    if 96 < v:getContentSize().width then
                                        local Xscale = v:getScaleX();
                                        local s = 96/v:getContentSize().width*Xscale;
                                        v:setScale(s);
                                    end
                                end
                            end
                        else
                            if cc.FileUtils:getInstance():isFileExist(path) then
                                v:loadTexture(path);
                                if 96 < v:getContentSize().width then
                                    local Xscale = v:getScaleX();
                                    local s = 96/v:getContentSize().width*Xscale;
                                    v:setScale(s);
                                end
                            end
                        end
					end
            	end

            	self.m_HeadMap[dwUserIdx] = nil;
            end
        end
    else
        -- //失败
        local savePath = cc.FileUtils:getInstance():getWritablePath();
        local path = savePath.."customHead"..dwUserIdx..".png";

        if cc.FileUtils:getInstance():isFileExist(path) then
            local iter = self.m_HeadMap[dwUserIdx];

            if iter ~= nil then

            	for k,v in pairs(iter) do
					if v == nil then
						--todo
					elseif v:getParent() ==nil then
						v:release();
					else
						v:release();
                        local gamePlayerNode = nil;
                        if v.view then
                            if v.view:getParent() then
                                if v.view:getParent():getParent() then
                                    if v.view:getParent():getParent():getParent() then
                                        gamePlayerNode =  v.view:getParent():getParent():getParent():getParent();
                                    end
                                end
                            end                        
                        else
                            if v:getParent() then
                                if v:getParent():getParent() then
                                    if v:getParent():getParent():getParent() then
                                        gamePlayerNode =  v:getParent():getParent():getParent():getParent();
                                    end
                                end
                            end
                        end
                        if gamePlayerNode and gamePlayerNode.bUserCutState  then
                            gamePlayerNode:setCutHead();
                        else
                            v:loadTexture(path);
                            if 96 < v:getContentSize().width then
                                local Xscale = v:getScaleX();
                                local s = 96/v:getContentSize().width*Xscale;
                                v:setScale(s);
                            end
                        end
					end
            	end

            	self.m_HeadMap[dwUserIdx] = nil;
            end
        else
            local iter = self.m_HeadMap[dwUserIdx];

            if iter ~= nil then
            	for k,v in pairs(iter) do
            		if v == nil then
            			--todo
            		else
            			v:release();
            		end
            	end

            	self.m_HeadMap[dwUserIdx] = nil;
            end
        end
    end
end

return HeadManager

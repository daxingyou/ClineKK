require("json")

WX_ACCESS_TOKEN_URL = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=";

CMD_ACCESS_TOKEN = 1;
CMD_USER_INFO = 2;
CMD_REFRESH_TOKEN = 4;
CMD_USER_INFO_REFRESH = 5;

local HttpUtils = {}

function HttpUtils:init()
    self.callback = nil;
end

--readyState
-- 0: 请求未初始化
-- 1: 服务器连接已建立
-- 2: 请求已接收
-- 3: 请求处理中
-- 4: 请求已完成，且响应已就绪

-- 数据返回格式  xhr.responseType
-- cc.XMLHTTPREQUEST_RESPONSE_STRING = 0 -- 返回字符串类型
-- cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER = 1 -- 返回字节数组类型
-- cc.XMLHTTPREQUEST_RESPONSE_BLOB = 2 -- 返回二进制大对象类型
-- cc.XMLHTTPREQUEST_RESPONSE_DOCUMENT = 3 -- 返回文档对象类型
-- cc.XMLHTTPREQUEST_RESPONSE_JSON = 4 -- 返回JSON数据类型

function HttpUtils:requestHttpCmd(cmd, url, callback)
    luaPrint(url)
    callback = callback or nil;

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    xhr:open("GET", url)

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            -- luaPrint("xhr.response ------------  "..xhr.response)

            if callback then
                callback(cmd, true, xhr.response);
            end
        else
            luaPrint("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback then
                callback(cmd, false, xhr.response);
            end
        end
        luaPrint("http self.cmd -------- "..cmd);
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)
    xhr:send()
end

function HttpUtils:requestHttp(url, callback, responseType, data)
    luaPrint(url)
    callback = callback or nil;

    if responseType == nil then
        responseType = "GET";
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(responseType, url)

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            -- luaPrint("xhr.response ------------  "..xhr.response)

            if callback then
                callback(true, xhr.response);
            end
        else
            luaPrint("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback then
                callback(false, xhr.response);
            end
        end

        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)

    if data ~= nil and data ~= "" then
        xhr:send(data);
    else
        xhr:send()
    end
end

--上传文件
--url 上传地址
--fileName 文件名
--fileText 文件内容 可选 不传，需保证本地有上传文件
--callback 上传回调函数
function HttpUtils:uploadFile(url,fileName,fileText,callback)
    luaPrint("开始上传文件")

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)

    local strBin = fileText

    if cc.FileUtils:getInstance():isFileExist(fileName) and isEmptyString(fileText) then
        local f = io.open(fileName, 'rb')

        if f then
            strBin = f:read("*all");
            f:close()
        end
    end

    if isEmptyString(strBin) then
        luaPrint("上传文件内容为空，中断上传！")
        return
    end

    -- //拿到图片数据
    local buff = 0
    local STR_END = "\r\n"
    local boundary = "----------------WebKitFormBou3123ndaryEm5WNw6hGiQUBpng"
    local str = STR_END

    str = str.."--"
    str = str..boundary
    str = str..STR_END
    str = str.."Content-Disposition: form-data; name=\"photo\"; filename=\""
    str = str..fileName--"head_"..PlatformLogic.loginResult.dwUserID..".png";
    str = str.."\""
    str = str..STR_END
    str = str.."Content-Type: application/octet-stream"
    str = str..STR_END
    str = str..STR_END
    str = str..strBin
    str = str..STR_END
    str = str.."--"
    str = str..boundary
    str = str.."--"
    str = str..STR_END
    luaPrint("开始上传 url "..url)

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            luaPrint("xhr.response ------------  "..xhr.response)
            luaPrint("上传成功")
            if callback then
                callback(true, xhr.response)
            end
        else
            luaPrint("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            luaPrint("上传错误")
            xhr.response = xhr.readyState.." , "..xhr.status
            if callback then
                callback(false, xhr.response)
            end
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)

    xhr:setRequestHeader("Content-Type","multipart/form-data; boundary = ----------------WebKitFormBou3123ndaryEm5WNw6hGiQUBpng")
    xhr:send(str)
end

--url         下载地址
--savePath    下载保存地址
--callback    下载回调函数
function HttpUtils:downLoadFile(url,savePath,callback)
    if isEmptyString(savePath) then
        luaPrint("下载保存路径为 "..tostring(savePath).." 中断下载！")
        return
    end

    local func = function(result,response)
        if result == true then
            -- //渲染图片
            local f = io.open(savePath, 'wb')
            if f then
                f:write(response)

                f:close()
                response = nil
            end
        else
            luaPrint("url "..url.." 下载文件异常!")
        end

        if callback then
            callback(result,savePath,response)
        end
    end
    self:requestHttp(url,func)
end

--网络请求错误提示 需自己调用
function HttpUtils:showError(code,isCenter)
    -- if appleView == 1 or (globalUnit and globalUnit.isEnterGame) then--审核模式不显示
    --     return
    -- end

    -- local winSize = cc.Director:getInstance():getWinSize()

    -- local scene = cc.Director:getInstance():getRunningScene()

    -- if scene then
    --     local node = scene:getChildByName("httperrorcode")
    --     if node then
    --         if node:getString() == code then
    --             return
    --         else
    --             node:removeSelf()
    --         end
    --     end

    --     if code == nil then
    --         code = "网络连接异常，请检查！"
    --     elseif isCenter == true then
            
    --     else
    --         code = "Http error code : "..tostring(code)
    --     end

    --     local label = FontConfig.createWithSystemFont(code, 28)

    --     if isCenter == true then
    --         label:setAnchorPoint(0.5,0.5)
    --         label:setPosition(winSize.width/2,winSize.height/2)
    --     else
    --         label:setAnchorPoint(0,0)
    --         label:setPosition(15,15)
    --     end
        
    --     label:setLocalZOrder(10000)
    --     label:setColor(cc.c3b(255, 0, 0))
    --     label:setName("httperrorcode")
    --     scene:addChild(label)

    --     label:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.FadeOut:create(1.0), cc.CallFunc:create(function() label:removeFromParent() end)))
    -- end
end

return HttpUtils;


function readType(msg,v)
    local ret
    if v == "BYTE" then
        ret = msg:readUchar()
    elseif v == "CHAR" then
        ret = msg:readChar()
    elseif v == "SHORT" then
        ret = msg:readShort()
    elseif v == "USHORT" or v == "WORD" then
        ret = msg:readUshort()
    elseif v == "INT" then
        ret = msg:readInt()
    elseif v == "UINT" then
        ret = msg:readUint()
    elseif v == "FLOAT" then
        ret = msg:readFloat()
    elseif v == "LONG" then
        ret = msg:readLong()
    elseif v == "ULONG" or v == "DWORD" then
        ret = msg:readUlong()
    elseif v == "LLONG" then
        ret = msg:readLlong()
    elseif v == "ULLONG" then
        ret = msg:readUllong()
    elseif v == "BOOL" then
        ret = msg:readBoolean()
    elseif v == "DOUBLE" then
        ret = msg:readDouble()
    elseif v == "LDOUBLE" then
        ret = msg:readUdouble()
    else
        local temp = string.split(v,"[")
        if #temp>1 then
            local ctype = temp[1]
            local num = string.split(temp[2],"]")[1]
            ret = msg:readStringFromCharArr(tonumber(num))
        else
            ret = convertToLua(msg,un_ser(v));
        end
    end
    
    return ret
end

function un_ser(str)
    str = "return " .. str
    local fun = loadstring(str)
    return fun()
end


function readArr(msg,varr,idx)
    local ret = {}
    if #varr>idx then
        local num = string.split(varr[idx],"]")[1]
        for i=1,num do
            ret[i] = readArr(msg,varr,idx+1)
        end
    else
        local num = string.split(varr[idx],"]")[1]
        for i=1,num do
            ret[i] = readType(msg,varr[1])
        end
    end
    return ret
end

function convertToLua(msg,cf)
    local ret = {}
    for i,value in ipairs(cf) do
        local k = value[1]
        local v = value[2]

        if type(v) == "string" then
            local varr = string.split(v,"[");
            if #varr>1 and varr[1]~="CHARSTRING" and varr[1]~="CHARSTRING0" then
                ret[k] = readArr(msg,varr,2)
            else
                ret[k] = readType(msg,v)
            end
        else
            ret[k] = convertToLua(msg,v)
        end
    end
    return ret
end

function writeType(sendData,value,v)
    if v == "BYTE" then
        if value == nil then
            value = 0;
        end
        sendData:writeUchar(value)
    elseif v == "CHAR" then
        if value == nil then
            value = "";
        end
        sendData:writeChar(value)
    elseif v == "SHORT" then
        if value == nil then
            value = 0;
        end
        sendData:writeShort(value)
    elseif v == "USHORT" or v == "WORD" then
        if value == nil then
            value = 0;
        end
        sendData:writeUshort(value)
    elseif v == "INT" then
        if value == nil then
            value = 0;
        end
        sendData:writeInt(value)
    elseif v == "UINT" then
        if value == nil then
            value = 0;
        end
        sendData:writeUint(value)
    elseif v == "FLOAT" then
        if value == nil then
            value = 0;
        end
        sendData:writeFloat(value)
    elseif v == "LONG" then
        if value == nil then
            value = 0;
        end
        sendData:writeLong(value)
    elseif v == "ULONG" or v == "DWORD" then
        if value == nil then
            value = 0;
        end
        sendData:writeUlong(value)
    elseif v == "LLONG" then
        if value == nil then
            value = 0;
        end
        sendData:writeLlong(value)
    elseif v == "ULLONG" then
        if value == nil then
            value = 0;
        end
        sendData:writeUllong(value)
    elseif v == "BOOL" then
        if value == nil then
            value = false;
        end
        sendData:writeBool(value)
    elseif v == "DOUBLE" then
        if value == nil then
            value = 0;
        end
        sendData:writeDouble(value)
    elseif v == "LDOUBLE" then
        if value == nil then
            value = 0;
        end
        sendData:writeLdouble(value)
    else
        local temp = string.split(v,"[")
        local ctype = temp[1]
        local num = string.split(temp[2],"]")[1]
        if value == nil then
            value = "";
        end
        if ctype == "CHARSTRING" then
            sendData:writeStringToCharArr(value,tonumber(num),false)
        elseif ctype == "CHARSTRING0" then
            sendData:writeStringToCharArr(value,tonumber(num),true)
        else
            convertToC(sendData,value,un_ser(ctype))
        end
    end
end

function writeArr(sendData,value,varr,idx)
    if #varr>idx then
        local num = string.split(varr[idx],"]")[1]
        for i=1,num do
            writeArr(sendData,value[i],varr,idx+1)
        end
    else
        local num = string.split(varr[idx],"]")[1]
        for i=1,num do
            writeType(sendData,value[i],varr[1])
        end
    end
end

function convertToC(sendData,obj,cf)
    for i,value in ipairs(cf) do
        local k = value[1]
        local v = value[2]
        if type(v) == "string" then
            local varr = string.split(v,"[")
            if #varr>1 and varr[1]~="CHARSTRING" and varr[1]~="CHARSTRING0" then
                writeArr(sendData,obj[k],varr,2)
            else
                writeType(sendData,obj[k],v)
            end
        else
            convertToC(sendData,obj[k],v)
        end
    end
end

function getCSize(v)
    local ret = 0
    if v == "BYTE" then
        ret = 1
    elseif v == "CHAR" then
        ret = 1
    elseif v == "SHORT" then
        ret = 2
    elseif v == "USHORT" or v == "WORD" then
        ret = 2
    elseif v == "INT" then
        ret = 4
    elseif v == "UINT" then
        ret = 4
    elseif v == "FLOAT" then
        ret = 4
    elseif v == "LONG" then
        ret = 4
    elseif v == "ULONG" or v == "DWORD" then
        ret = 4
    elseif v == "LLONG" then
        ret = 8
    elseif v == "ULLONG" then
        ret = 8
    elseif v == "BOOL" then
        ret = 1
    elseif v == "DOUBLE" then
        ret = 8
    elseif v == "LDOUBLE" then
        ret = 10
    else
        local temp = string.split(v,"[")
        local ctype = temp[1]
        if ctype == "CHARSTRING" or ctype == "CHARSTRING0" then
            local num = string.split(temp[2],"]")[1]
            ret = tonumber(num)
        else--结构体数组
            ret = getObjSize(un_ser(v));
        end        
    end
    return ret
end

function getObjSize(cf)
    local ret = 0
    if cf then
        for i,v in ipairs(cf) do
            local ctype = v[2]
            if type(ctype) == "string" then
                local varr = string.split(ctype,"[")
                if #varr>1 and varr[1]~="CHARSTRING" and varr[1]~="CHARSTRING0" then   
                    local size = getCSize(varr[1])
                    for i=2,#varr do
                        local num = string.split(varr[i],"]")[1]
                        size = size*num
                    end
                    ret = ret+size
                else
                    ret = ret+getCSize(ctype)
                end
            else
                ret = ret+getObjSize(ctype)
            end
        end
    end
    
    return ret
end

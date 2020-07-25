local ipSocket = {}
-- 引入相关包
local socket = require("socket")

function ipSocket.main()

        local a,b=pcall(t.execute);
        if a==false then
                luaPrint(a,b);
        end

end

function ipSocket.execute()
        luaPrint("start");
        --local m = os.execute("ifconfig");
        --logdebug(m);
        --local s= io.popen('ifconfig')
        --local b = s:read("*all")
        --logdebug(b);
        --local t=os.execute(ip addr|grep inet|grep -v inet6|grep eth0|awk '{luaPrint $2}'|awk -F "/" '{luaPrint $1}' >> /log/app/localhost.tmp);
        --local t=os.execute("ifconfig eth0 |grep 'inet addr'| cut -f 2 -d ':'|cut -f 1 -d ' ' >> /log/app/localhost.tmp ");
        luaPrint(os.time());
        local ip,resolved = socket.dns.toip(socket.dns.gethostname());
        luaPrint((ip));
        luaPrint(resolved);
        luaPrint(unpack(ipSocket.GetAdd(socket.dns.gethostname())));
        return ip
end

function ipSocket.GetAdd(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local ListTab = {}
    for k, v in ipairs(resolved.ip) do
        luaPrint(k.."|"..v);
        table.insert(ListTab, v)
    end
    return ListTab
end

return ipSocket

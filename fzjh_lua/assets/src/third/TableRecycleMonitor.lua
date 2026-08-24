local TalbeRecycleMonitor = class("TalbeRecycleMonitor")

function TalbeRecycleMonitor:create()
    return TalbeRecycleMonitor.new()
end

function TalbeRecycleMonitor:ctor()
    self._tbs = setmetatable({}, {__mode = "v"})
    self._tbAddrs = {}
    self._recycledTables = {}
end

-- 添加需要被监控释放的table
function TalbeRecycleMonitor:add(tb)
    if type(tb) == "table" then
        local tbAddr = tostring(tb)
        if self._tbs[tbAddr] == nil then
            self._tbs[tbAddr] = tb
            table.insert(self._tbAddrs, tbAddr)
        end
    end
end

-- 检测table释放
function TalbeRecycleMonitor:update()
    for i = #self._tbAddrs, 1, -1 do
        local tbAddr = self._tbAddrs[i]
        if self._tbs[tbAddr] == nil then
            print("table被释放: ", tbAddr)
            -- 释放前添加进入已释放队列
            table.insert(self._recycledTables, tbAddr)
            -- 释放后从当前记录中清除
            table.remove(self._tbAddrs, i)
            -- 可以触发某些事件
        end
    end
end

-- 打印
function TalbeRecycleMonitor:printRecycledTable()
    print("已清理table列表:")
    for k,v in pairs(self._recycledTables) do
        print(k, v)
    end
end

return TalbeRecycleMonitor00000
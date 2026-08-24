local SyncWebTime = {
    __isOpen = true,
    __interval = 60,
    __lastTime = 0
}

function SyncWebTime:setOpen(open)
    self.__isOpen = open
end

function SyncWebTime:update()
    if self.__isOpen then
        if GetTime() - self.__lastTime > self.__interval then
            HttpManagerEx:getTime(function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 and data.time ~= nil then
                    SetTime(tonumber(data.time))
                    self.__lastTime = tonumber(data.time)
                end
            end,nil,nil,"")
        end
        
    end
end

return SyncWebTime000000
local class = require("third.class.NewClass")
local Emap = require("app.models.EMap.EMap")
local DreamMap = {}

function DreamMap:create(data)
    local p = DreamMap.new(data)

    Emap.ctor(p)

    return p
end

function DreamMap:__playerDie()
    Emap.__playerDie(self)
end

-- 在DreamMap中增加Update方法. 用于刷新梦境角色状态
function DreamMap:scheduleFunc(ft)
    Emap.scheduleFunc(self, ft)


    -- 一秒判断一次招式解锁
    DoFuncWithInterval("DreamMap:scheduleFunc.unlockActiveZhao",
    function()
        local dreamPlayer = self:getPlayer()

        -- 尝试解锁梦境角色主动招式
        dreamPlayer:checkActiveZhaoIsDeblocking()
    end, 10)
end

return class("DreamMap", { Emap }, DreamMap)000000000000000
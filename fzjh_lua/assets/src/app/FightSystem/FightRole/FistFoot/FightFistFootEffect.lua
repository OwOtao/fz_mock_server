--[[
    author:Seven
    time:2022-11-24 16:12:29
    desc: 战斗用拳脚特性基础类
]]
local newClass = require("third.class.NewClass")

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local FightFistFootEffect = {}

function FightFistFootEffect:create(e_id, e_lv)
    return FightFistFootEffect.new():__init(e_id, e_lv)
end

function FightFistFootEffect:__init(e_id, e_lv)
    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
    self.__basicFistFootEffect = FistFootResManager:getFistFootEffect(e_id, e_lv)

    return self
end

--@desc: 特性id
--@author:Seven
--@time:2022-11-24 16:25:53
function FightFistFootEffect:getId()
    return self.__basicFistFootEffect:getPeculiarityid()
end

--@desc: 特性名字
--@author:Seven
--@time:2022-11-24 16:26:19
function FightFistFootEffect:getName()
    return self.__basicFistFootEffect:getName()
end

--@desc: 特性是否拥有携带常态buff
--@author:Seven
--@time:2022-11-24 16:26:27
function FightFistFootEffect:hasPermanentBuff()
    return self.__basicFistFootEffect:getPermanentBuffId() ~= 0
end

--@desc: 获取特性携带常态buff
--@author:Seven
--@time:2022-11-24 16:27:15
function FightFistFootEffect:getPermanentBuffId()
    return self.__basicFistFootEffect:getPermanentBuffId()
end

--@desc: 是否拥有buff添加器
--@author:Seven
--@time:2022-11-24 16:27:31
function FightFistFootEffect:hasBuffLauncherAdd()
    return self.__basicFistFootEffect:getBuffLauncherAdd() ~= nil
end

--@desc: 获取buff添加器
--@author:Seven
--@time:2022-11-24 16:27:48
function FightFistFootEffect:getBuffLauncherAdd()
    return self.__basicFistFootEffect:getBuffLauncherAdd()
end

return newClass("FightFistFootEffect", {}, FightFistFootEffect)
0000000000000000
local ShenBingRes = {}

function ShenBingRes:init()
    local specialList = require("script.others.godweapon")["weaponSpecials"]
    self.__specialMap = {}
    for _, v in pairs(specialList) do
        self.__specialMap[v.specialid] = v
    end

    self.__templateData = require("script.newbattle.demo.shenbingDataTemplate")["data"]
end

function ShenBingRes:getSpecialInfo(specialId)
    return self.__specialMap[specialId]
end

--@desc: 获取神兵携带常态buff
--@author:Seven
--@time:2024-02-27 15:09:13
--@buffId: buffId，0表示没有
--@return: buffRes | nil
function ShenBingRes:getShenBingNormalBuffInfo(buffId)
    if buffId == 0 then
        return nil
    end

    local BuffConf = require("app.FightSystem.Configuration.BuffConf")
    
    return BuffConf:getNormalBuffRes(buffId)
end

function ShenBingRes:getShenBingTemplateData(t_id)
    t_id = tostring(t_id)
    if self.__templateData[t_id] == nil then
        error("获取神兵模板数据失败：未知神兵模板数据ID - " .. t_id)
    end

    return self.__templateData[t_id]
end

ShenBingRes:init()

return ShenBingRes
0000
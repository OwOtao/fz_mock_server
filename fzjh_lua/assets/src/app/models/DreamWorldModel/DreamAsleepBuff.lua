local DreamAsleepBuff = {}

local FallAsleepTab = require("script.dreamworld.dreamcenser")["buff"] --入梦buff表

--获取buff资源配表属性
function DreamAsleepBuff:getAsleepBuffAttr(buffId)
    local attr = {}
    if buffId == nil then
        return attr
    end
    
    return FallAsleepTab[tostring(buffId)]
end

local changeMap = {
    [1] = "qiMax",          --气血上限
    [2] = "neiLiLimit",       --内力上限
    [3] = "qiMax;neiLiLimit", --气血和内力上限
    [4] = "damage;protect",     --伤害力和防护力
    [5] = "addNanyangExp",  --南阳匪乱经验收益增加
    [6] = "addFeizeiExp",   --飞贼横行经验收益增加
}

function DreamAsleepBuff:getAsleepBuffMap(role)
    local retMap = {}
    if MapIsEmpty(role) == true then
		return retMap
    end
    
    local buffIdList = self:getAsleepBuff(role)
    if MapIsEmpty(buffIdList) == true then
		return retMap
    end
    
    for i,buffId in ipairs(buffIdList) do
        local buffAttr = self:getAsleepBuffAttr(buffId)
        local list = self:calcBuffMap(role,buffAttr)
        if  MapIsEmpty(list) == false then
            for k,v in pairs(list) do
                if retMap[k] ~= nil then
                    retMap[k] = retMap[k] + v
                else
                    retMap[k] = v
                end
            end
        end
    end

    return retMap
end

--获取入梦buff列表
function DreamAsleepBuff:getAsleepBuff(role)
    local buffIdList = {}
    if role == nil then
        return buffIdList
    end
    local asleepBuff = role:getAttr("AsleepBuff")
    if  MapIsEmpty(asleepBuff) == false then
        for i = #asleepBuff,1,-1 do
            local buff = asleepBuff[i]
            if self:checkBuffIsFail(buff.id,buff.startTime) == false then --未失效
                table.insert(buffIdList, buff.id)
            else
                --buff失效 移除
                table.remove(asleepBuff,i)
            end
        end
    end

    return buffIdList
end

--检查buff是否失效
function DreamAsleepBuff:checkBuffIsFail(buffId,startTime)
    local result = true
    if buffId == nil or startTime == nil then
        return result
    end
    
    local currTime = GetTime()
    local buffAttr = self:getAsleepBuffAttr(buffId)
    local duration = buffAttr.duration

    if currTime > startTime + duration then
        result = true
    else
        result = false
    end

    return result
end

-- @desc 计算单条buff属性结果
function DreamAsleepBuff:calcBuffMap(role, buffAttr)
    local retMap = {}
    if MapIsEmpty(role) == true or MapIsEmpty(buffAttr) == true then
		return retMap
	end
    
    local bufftype = changeMap[buffAttr.bufftype]
    if bufftype then
        local attrList = string.split(bufftype,";")
        local valueList = string.split(buffAttr.value,";")
        for index = 1,#attrList do
            local attrName = attrList[index]
            local value = tonumber(valueList[index])

            if buffAttr.valuetype == 1 then --百分比
                local baseValue = switch(attrName,{
                    atk = function()
                        return role:getAtk(true)
                    end,
                    def = function()
                        return role:getDef(true)
                    end,
                    damage = function()
                        return role:getPowerDamage(true)
                    end,
                    protect = function()
                        return role:getFangHu(true)
                    end,
                    default = function()
                        return Helper:getDef(role:getAttr(attrName),1)
                    end
                })

                value = baseValue * (value/100)
                retMap[attrName] = value
            else
                retMap[attrName] = value
            end
        end
    else
        error(false,"未定义的类型")
    end
    return retMap
end

return DreamAsleepBuff0000
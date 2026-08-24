local XingZhen = {}
local npcDatas = require("script.others.zouxuejing")

local EffectList = {
    ["1"] = function(role,value,time,effectId)--后天臂力变化
        return "secStr", Helper:mathFloor((role:getSkillLv("jibenquanjiao")/10) * value)
    end,
    ["2"] = function(role,value,time,effectId)--后天身法变化
        return "secDex", Helper:mathFloor((role:getSkillLv("jibenqinggong")/10) * value)
    end,
    ["3"] = function(role,value,time,effectId)--现有精力变化
        local addValue = role:getJingMax() * value
        role:addAttr("jing",addValue)
    end,
    ["4"] = function(role,value,time,effectId)--潜能变化
       print("_________________________________",value,time)
       role:addAttr("pot",value)
       -- return "pot",value
    end,
    ["5"] = function(role,value,time,effectId)--内力上限变化（不超过上限）
		role:addAttr("neiliMax", value)
    end,
    ["6"] = function(role,value,time,effectId)--容貌变化
        role:addAttr("looks", value)
	    local addValue = value
        role:addPolymorphLastLooks(addValue)
    end,

    ["7"] = function(role, value, time,effectId)--2真气变化
       role:addAttr("breathVal", value)
    end,
    ["8"] = function(role, value, time,effectId)--打坐回复速度变化 是有cd还是永久 Role:getNeiLiSpeed
       -- role:setTimeLimitFlag("走穴十四经内力变化", value, time)
       return "xingzhenNeiLi", value
    end,
    ["9"] = function(role, value, time,effectId)--2体力上限变化  Fight:playRoleAutoZhao1294
       -- role:addAttr("tiliMax", value)
       return "tiliMax", value
    end,
    -- ["10"] = function(role, value, time)--精力回复速度变化 是有cd还是永久 Role:addJing
    --    -- role:setTimeLimitFlag("走穴十四经精力变化", value, time)
    --    return "xingzhenJing", value
    -- end,
    ["11"] = function(role, value, time,effectId)--2侠义正气变化
        role:addAttr("zhengqi", value)
       -- local count = XingZhen:zhijieAdd(role,"zhengqi",effectId)
       -- return "zhengqi", count
    end,
    ["12"] = function(role,value,time,effectId)--生命上限变化
        -- role:addAttr("qiMax", value)
        local addValue = role:getAttr("qiMax") * value
        return "qiMax", addValue
    end,
    ["13"] = function(role,value,time,effectId)--2经脉经验变化
        role:addAttr("meridianExp", value)
        -- local count = XingZhen:zhijieAdd(role,"meridianExp")
        -- return "meridianExp", count
    end,


    ["14"] = function(role,value,time,effectId)--挂机收益变化 1 有点问题
        return "xingzhenGuaJiSY",value
    end, 
    ["15"] = function(role,value,time,effectId)--后天悟性变化
        return "secInt", Helper:mathFloor((role:getSkillLv("dushushizi")/10) * value)
    end,   
    ["16"] = function(role,value,time,effectId)--下次冲穴概率变化 Meridian:getRandomEventState
        return "xingzhenChong", value
    end, 
    ["17"] = function(role,value,time,effectId)--下次淬炼概率变化
        return "xingzhenCuiLian", value
    end, 
    ["20"] = function(role,value,time,effectId)--战斗中无法使用主动技能
        return "xingzhenZhanDou", value
    end,
    ["21"] = function(role,value,time,effectId)--气血上限不受伤害
        return "xingzhenQiXue", value
    end,
    ["22"] = function(role,value,time,effectId)--无法进行挂机
        -- role:setTimeLimitFlag("走穴十四经进行挂机", 1, time)
        return "xingzhenGuaJi", value
    end,


    ["23"] = function(role,value,time,effectId)--精力上限
        -- role:setAttr("jingMax",math.max(role:getAttr(jing) + value,300))
        local count = XingZhen:zhijieAdd(role,"xingZhenJingMax",effectId)

        if count > 6 then
            count = 6
        end
        -- return "xingZhenJingMax", count
        return "xingZhenJingMax", count
    end,
    ["25"] = function(role,value,time,effectId)--无法进行打坐
        return "xingzhenDaZuo", value
    end,
    ["26"] = function(role,value,time,effectId)--攻速速度变化 atkSpeedFactor
        return "atkSpeedFactor", value
    end,
}

--直接加的效果
function XingZhen:zhijieAdd(role,key,effectId)
    local xingzhen = role:getAttr("xingzhen")

    local effectCounts = xingzhen.effectsCount

    local count = 0
    if effectCounts[key] ~= nil and effectCounts[key][effectId] ~= nil then
        count = effectCounts[key][effectId]
    end
    count = count + 1
    return count
end

-- 获取效果集
function XingZhen:getXingZhenMap(role)
    local retMap = {}
    local xingzhen = role:getAttr("xingzhen")
    if MapIsEmpty(xingzhen) == true then
        return retMap
    end
    local effectInfo = Helper:getDef(self:getXingZhen("行针走穴EffectsCD",role), {}) --Helper:getDef(self:getXingZhen("针法时间记录"), {}) 
    local effectDatas = xingzhen["行针走穴Effects"]
    if MapIsEmpty(effectDatas) == true then
    else
        for k,effectId in pairs(effectDatas) do
            local effectData = npcDatas.effect[effectId]
            local type = effectData.type
            local value = effectData.value
            local time = effectData.time

            local effect
            for index, effectTime in pairs(effectInfo) do
                if effectTime.effectId == effectId then
                    effect = effectTime
                    break
                end
            end
            if effect ~= nil then
                if time == 0 and effect.before == 0 then
                else
                    if effect.after >= GetTime() then
                        local str, value = EffectList[tostring(type)](role,value,time)
                        if retMap[str] == nil then
                            retMap[str] = value
                        else
                            retMap[str] =retMap[str] + value
                        end
                    end
                end
            end
        end
    end

    local retMap1 = self:updateBuffByTimeZero(role)
    Helper:tableCover(retMap,retMap1)
    return retMap
end

--提交行针效果
--effectDatas 生效的效果集
function XingZhen:submitXingZhenEffects(role)
    local retMap = {}
    -- local role = User:getRole()
    local xingzhen = role:getAttr("xingzhen")
    if MapIsEmpty(xingzhen) == true then
        return retMap
    end
    local effectInfo = {}
    local effectDatas = xingzhen["行针走穴Effects"]
    for k,v in pairs(effectDatas) do
        local effectData = npcDatas.effect[v]
        effectInfo[v] = {
            startTime = GetTime(),
            timeLimit = npcDatas.effect[v].time
        }

        --属性效果直接增加收益
        local type = effectData.type
        local value = effectData.value
        local time = effectData.time
        if time == 0 then
            -- RoleAddEffectList[tostring(type)](role,value,time)
            --测试效果是否加成功
             -- local key, value = EffectList[tostring(type)](role,value,time)
             -- role:addAttr(key,value)
            local key, finalCount = EffectList[tostring(type)](role,value,time,v)
            if key == nil then
            else
                self:updateEffectCount(key,finalCount,role,v)
            end
            role:updateRoleBuff()
        end
    end
    
    if role:getHangUpSystem():checkHangUpTaskFinish() then
        role:getHangUpSystem():autoStopHangUp()
    end

    -- self:setXingZhen("针法时间记录", effectInfo)
end

--测试穴位效果
function XingZhen:ceShiXingZhenEffects(role, effectId)
    local retMap = {}
    -- local role = User:getRole()
    local xingzhen = role:getAttr("xingzhen")
    if MapIsEmpty(xingzhen) == true then
        return retMap
    end
    local effectData = npcDatas.effect[effectId]--拿到效果的一条数据
    local effectTime = effectData.time + GetTime() --修改当前的CD时间
    local effectsCD = {before = effectData.time, after = effectTime, effectId = effectId}
    if MapIsEmpty(xingzhen["行针走穴EffectsCD"]) == true then
        xingzhen["行针走穴EffectsCD"] = {}
    end
    if MapIsEmpty(xingzhen["行针走穴Effects"]) == true then
        xingzhen["行针走穴Effects"] = {}
    end
    table.insert(xingzhen["行针走穴EffectsCD"], effectsCD)
    table.insert(xingzhen["行针走穴Effects"], effectId)


    --属性效果直接增加收益
    local type = effectData.type
    local value = effectData.value
    local time = effectData.time
    if time == 0 then
        local key, finalCount = EffectList[tostring(type)](role,value,time,effectId)
        if key == nil then
        else
            self:updateEffectCount(key,finalCount,role,effectId)
        end
        role:updateRoleBuff()

        if role:getHangUpSystem():checkHangUpTaskFinish() then
            role:getHangUpSystem():autoStopHangUp()
        end
    end
end

function XingZhen:updateBuffByTimeZero(role)

    --[["breathVal" = {
            effectId = count,
            xxx = count
        },
        "tiliMax" = {
                effectId = count,
            xxx = count
        },
        "zhengqi" = {
                effectId = count,
            xxx = count
        },
    --]]
    local effectCounts = role:getAttr("xingzhen")["effectsCount"]
    --初始化表，获得表里面的值，还有次数
    --表里面的值
    -- local effectDatas = xingzhen["行针走穴Effects"]
    local temp = {}
    local retMap = {}
    for key,v in pairs(effectCounts) do
        local value = 0
        for k1,v1 in pairs(v) do
            local effect = npcDatas.effect[k1]
            --最后加成效果的值
            local finalValue = effect.value * v1
            if temp[key] then
                temp[key] =temp[key] + finalValue
            else
                temp[key] = finalValue
            end
            
            retMap[key] = temp[key]
        end
    end


    return retMap
end

function XingZhen:updateEffectCount( key,count,role,effectId )
    local xingZhen = role:getAttr("xingzhen")
    local effectsCount = xingZhen["effectsCount"]
    if effectsCount[key] == nil then 
        effectsCount[key] = {}
    end

    effectsCount[key][effectId] = count
    xingZhen["effectsCount"] = effectsCount

    role:setAttr("xingzhen",xingZhen)
end


local relation = {
    ["xingzhenCuiLian"] = {
        "effect035","effect036","effect1021"
    },

    ["xingzhenChong"] = {
        "effect033","effect034","effect1020"
    },
}

--行针的效果有限制，规定的时间内，效果只有一次
function XingZhen:removeZouxueEffectByKey(key)
    local role = User:getRole()
    local xingzhen = role:getAttr("xingzhen")
    local effectDatas = xingzhen["行针走穴Effects"]
    local effectInfo = Helper:getDef(self:getXingZhen("行针走穴EffectsCD"),{})

    local effects = relation[key]

    for _,effectId in ipairs(effects) do
        for _,cd_effect in ipairs(effectInfo) do
            if effectId == cd_effect.effectId then
                cd_effect.after = 0
                -- break
            end
        end

    end

    role:updateRoleBuff()
end

-- 根据权重抽取效果
function XingZhen:insertRandomEffects(effectsData,effectDatas)
    local effects = string.split(effectsData, ";")
    -- Helper:print_lua_table(effects)
    local weight = {}  
    for i = 1,#effects do
        local effectSplitList = string.split(effects[i], ",")
        table.insert(weight,tonumber(effectSplitList[2]))
    end
    
    local random = Helper:RandomByWeight(weight)
    
    local tab = string.split(effects[random],",")
    local effectList = tab[1]

    effectList = string.split(effectList, "_")
    
    for k,v in pairs(effectList) do
        table.insert(effectDatas, v)
    end
end

--试针成功把成功的针添加到列表
function XingZhen:insertShiZhenResult()
    local role = User:getRole()
    local xingZhenList = Helper:getDef(role:getInheritFlag("行针针法Skills"),{})--试针成功把成功的针添加到列表

    if PRINT_MODE == 1 then
        print("...............................行针针法Skills..................")
        Helper:print_lua_table(xingZhenList)
    end
    -- if MapIsEmpty(xingZhenList) == true  then
    for k,v in pairs(npcDatas.zhenfa) do
        local id = v.id
        local unlocklevel = v.unlocklevel

        local skillLv = role:getSkillLv("zouxueshisijing")
        if unlocklevel == 100 or skillLv >= unlocklevel then
             table.insert(xingZhenList, id)
        else

        end
    end 
    -- end

    xingZhenList = table.unique(xingZhenList, true)
    role:setInheritFlag("行针针法Skills", xingZhenList)
end

-- 获取行针数据
function XingZhen:getXingZhen(key,role)
    role = Helper:getDef(role,User:getRole())
    if type(key) ~= "string" or key == "" then
        return 0
    end
    local xingzhen = Helper:getDef(role:getAttr("xingzhen"), {})
    return xingzhen[key] == nil and 0 or xingzhen[key]
end

-- 更新行针数据
function XingZhen:setXingZhen(key, value)
    if type(key) ~= "string" or key == "" then
        return
    end
    local xingzhen = Helper:getDef(User:getRoleAttr("xingzhen"), {})
    xingzhen[key] = value
    User:setRoleAttr("xingzhen", xingzhen)
end

--行针效果结算
function XingZhen:calcEffect(id)
    local role = User:getRole()
    local zhenfaData = npcDatas.zhenfa[id]
    if MapIsEmpty(zhenfaData) then
        return
    end

    local effectDatas = {}
    if zhenfaData.effects then
        self:insertRandomEffects(zhenfaData.effects,effectDatas)
    end

    if zhenfaData.badrate then
        local badrate = zhenfaData.badrate - math.floor(role:getSkillLv("zouxueshisijing")/100) * zhenfaData.lvbadrate
        local randomNum = math.random(1, 100)

        if randomNum <= badrate then
            self:insertRandomEffects(zhenfaData.badffects,effectDatas)
        end
    end
    local function sameAdd(t)
        local n = {}
        local values = {}

        for i ,v in ipairs(t) do
            local effectData = npcDatas.effect[v]
            -- Helper:print_lua_table(effectData)

            table.insert( n,v)
            table.insert(values,effectData.value)
        end

        return n,values
    end

    local tmpeffectDatas, tmpeffectDataValues = sameAdd(effectDatas)
    self:setXingZhen("行针走穴CD时间",  GetTime() + zhenfaData.coldtime)
    -- role:setFlag("是否完成游戏", 1)
    self:setXingZhen("针法数据", zhenfaData.id)
    self:setXingZhen("行针走穴Effects", tmpeffectDatas)
    self:setXingZhen("行针走穴EffectsValues", tmpeffectDataValues)

    local effectsCD = {}
    for k,v in pairs(tmpeffectDatas) do
        local effectData = npcDatas.effect[v] --拿到效果的一条数据

        local time = effectData.time + GetTime() --修改当前的CD时间
        table.insert(effectsCD, {before = effectData.time, after = time,effectId = v})
    end
    self:setXingZhen("行针走穴EffectsCD", effectsCD)

    -- Helper:print_lua_table(User:getRoleAttr("xingzhen"))
end

return XingZhen0000000000
local ShenBingRes = require("app.models.ShenBing.ShenBingRes")
local godweapon = require("script.others.godweapon")
local LogSystem = require("app.models.LogSystem.LogSystem")

local ShenBingEffct = {}
local weaponList = godweapon["weaponSpecials"]
function ShenBingEffct:create()
    local p = clone(ShenBingEffct)
    p:ctor()
    return p
end

function ShenBingEffct:ctor()
    -- self._ShenBingEffctMap = {} --神兵拥有的特性
    -- self.attr = {}  --特性加成
end

function ShenBingEffct:init()
end

--CN 成功淬炼次数 weight 武器重量 ,currDex 当前身法, currStr当前臂力 yindu --武器硬度 rendu --武器韧度
-- 提升硬度 HARDNESS
-- 提升坚韧 TOUGHNESS
-- 提升重量  WEIGHT
-- 提升攻击  ATK
-- 提升伤害力 DAMAGE
-- 加命中值 HIT
-- 加招架值 PARRY
local ShenBingEffctList = {
    ["ATK"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升攻击力
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end,
    ["DAMAGE"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升武器伤害力
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue =",addValue)
        return addValue
    end,
    ["HARDNESS"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升武器额外硬度
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end,
    ["WEIGHT"] = function(role, cuilianCount, weight, yindu, rendu, formula) --降低重量值
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end,
    -- [5] = function (role,cuilianCount,weight, value, formula)       --增加重量值
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     print("addValue =addValue =addValue ="..addValue)
    --     return addValue

    -- end,
    ["TOUGHNESS"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升武器的额外坚韧度
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end,
    ["DODGE"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升闪避
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue =" .. addValue)
        return addValue
    end,
    ["HIT"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升命中
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end,
    ["PARRY"] = function(role, cuilianCount, weight, yindu, rendu, formula) --提升招架
        local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
        local addValue = Helper:GetValueFromScript(formula, params)
        -- print("addValue ="..addValue)
        return addValue
    end
    -----------------------------------
    -- [7] = function (role,cuilianCount,weight, value, formula)      --击中敌人造成额外伤害(触发)
    --    local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     print("addValue ="..addValue)
    --     return addValue

    -- end,
    -- [8] = function (role,cuilianCount,weight, value, formula)    --击中敌人一定几率使其带上流血效果
    --    local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --    local strList = string.split(formula,";")
    --    local bleed = strList[1]
    --    local odds = strList[2]
    --    local time = strList[3]

    --     bleed = Helper:GetValueFromScript(bleed,params)

    --     return bleed,odds,time  --（流血伤害;几率百分比;持续时间）

    -- end,
    -- [9] = function (role,cuilianCount,weight, value, formula)   --击中敌人可造成额外伤害，并有一定几率造成流血效果。--
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     local strList = string.split(formula,";")
    --     local damage = strList[1]
    --     local odds = strList[2]
    --     local bleed = strList[3]
    --     local time = strList[4]

    --     damage = Helper:GetValueFromScript(damage,params)
    --     bleed = Helper:GetValueFromScript(bleed,params)

    --     return damage,bleed,odds,time  --（额外伤害;流血伤害;几率百分比;持续时间）

    -- end,
    -- [10] = function (role,cuilianCount,weight, value, formula)  --击中敌人时，有一定几率使得敌人获得招架降低效果
    --    local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --    local strList = string.split(formula,";")
    --    local odds = strList[1]
    --    local value = strList[2]
    --    local time = strList[3]

    --     odds = Helper:GetValueFromScript(odds,params)

    --     return odds,value,time   --(几率;降低比例;持续秒数）

    -- end,
    -- [11] = function (role,cuilianCount,weight, value, formula)  --击中敌人时，有一定几率使得敌人获得攻速降低效果。
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     local strList = string.split(formula,";")
    --     local odds = strList[1]
    --     local value = strList[2]
    --     local time = strList[3]

    --     odds = Helper:GetValueFromScript(odds,params)
    --     return odds ,value,time     --(几率;降低比例;持续秒数)

    -- end,
    -- [12] = function (role,cuilianCount,weight, value, formula)    --攻击命中敌人时，有一定几率可以打落别人兵器
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     return addValue

    -- end,
    -- [13] = function (role,cuilianCount,weight, value, formula)  --提升敌人格挡时，打飞他武器的概率
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     return addValue

    -- end,
    -- [14] = function (role,cuilianCount,weight, value, formula)  --格挡住敌人时一定几率反击
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     local strList = string.split(formula,";")
    --     local odds = strList[1]
    --     local damage = strList[2]

    --     odds = Helper:GetValueFromScript(odds,params)
    --     damage = Helper:GetValueFromScript(damage,params)

    --     return odds,damage --(几率;造成伤害)

    -- end,
    -- [15] = function (role,cuilianCount,weight, value, formula)  --自己格挡住敌人武器时，有一定几率打落敌人的兵器
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     return addValue

    -- end,
    -- [16] = function (role,cuilianCount,weight, value, formula)  --敌人格挡自身攻击时，还是会承受部分伤害
    --     local params = {CN = cuilianCount ,weight = weight, currDex = role:getRoleAttr("currDex"),currStr = role:getRoleAttr("currStr")}
    --     if value ~= 0 then
    --         addValue = value
    --     else
    --         addValue = Helper:GetValueFromScript(formula,params)
    --     end
    --     return addValue

    -- end
}

-- 获取特效的属性，资源配表  effctId = 特性id
function ShenBingEffct:getEffectAttr(effctId)
    for k, v in pairs(weaponList) do
        if v.specialid == effctId then
            return v
        end
    end
end

--[[
    @desc: 获得神兵特性列表
    author:TangJian
    time:2022-03-05 15:53:33
    --@weapon: 神兵的属性
    @return:
]]
function ShenBingEffct:getSpecialInfoList(weapon)
    local specialInfoList = {}
    local specialIdList = table.getValueListByKey(weapon, "effct")
    for _, specialId in ipairs(specialIdList) do
        local specialInfo = ShenBingRes:getSpecialInfo(specialId)
        table.insert(specialInfoList, specialInfo)
    end
    return specialInfoList
end

-- 判断是否存在特性
function ShenBingEffct:isHaveEffect(effctId, specialnumber)
    -- 获取特效的属性
    local v = self:getEffectAttr(effctId)
    if v.specialnumber == specialnumber then
        return true
    else
        return false
    end
end

--获取神兵特性加成值
function ShenBingEffct:getAddNum(effctId, user, cuilianCount, weight, yindu, rendu)
    -- local addvalue = 0
    local v = self:getEffectAttr(effctId)
    local specialnumber = v.specialnumber
    if specialnumber then
        local val1, val2, val3, val4 = ShenBingEffctList[specialnumber](user, cuilianCount, weight, yindu, rendu, v.formula)

        -- print("specialnumber="..specialnumber)
        -- print("神兵特性加成值==",val1,val2,val3,val4)
        return val1, val2, val3, val4
    end
end

-- -- 获取神兵特性 加成后的总数值  value 基础属性
-- function ShenBingEffct:getFinalNum(effctId, value)
--     local addvalue = self:getAddNum(effctId)
--     print("addvalue====",addvalue)
--     PopText("addvalue:"..tostring(addvalue))
--     return addvalue + value
-- end

-------------------------------------------------------------------------------------------------
-------------------------------------------------获取特性的效果，返回值不包含基础属性----------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/11 14:14:43
-- @desc 提升攻击力
function ShenBingEffct:getWeaponExtraAtk(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "ATK") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

--获取闪避加成
function ShenBingEffct:getWeaponExtraDodge(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "DODGE") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

--获取命中加成
function ShenBingEffct:getWeaponExtraHit(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "HIT") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

--获取招架加成
function ShenBingEffct:getWeaponExtraParry(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "PARRY") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

-- 提升硬度 HARDNESS
-- 提升坚韧 TOUGHNESS
-- 提升闪避 DODGE
-- 提升重量  WEIGHT
-- 提升攻击  ATK
-- 提升伤害力 DAMAGE
-- 获取神兵伤害
function ShenBingEffct:getWeaponExtraDamage(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        -- if weapon.name == "易电剑" then
        --     Helper:print_lua_table(weapon)
        -- end
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "DAMAGE") == true then
                addValue = addValue + tonumber(self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0)))
            else
            end
        else
            break
        end
    end
    return addValue
end

-- 获取武器硬度
function ShenBingEffct:getWeaponExtraYingDu(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "HARDNESS") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

--获取武器重量
function ShenBingEffct:getWeaponExtraWeight(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]

        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "WEIGHT") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

--获取兵器韧度
function ShenBingEffct:getWeaponrendu(weapon, user)
    assert(type(weapon) == "table")
    local addValue = 0
    if SHENBINGSYS ~= true then
        return addValue
    end
    for i = 1, 10 do
        local effctId = weapon["effct" .. i]
        if effctId ~= nil and effctId ~= "" then
            if self:isHaveEffect(effctId, "TOUGHNESS") == true then
                addValue = addValue + self:getAddNum(effctId, user, Helper:getDef(weapon.cuilianCount, 0), Helper:getDef(weapon.weight, 0), Helper:getDef(weapon.yindu, 0), Helper:getDef(weapon.rendu, 0))
            else
            end
        else
            break
        end
    end
    return addValue
end

-- --战斗中额外伤害
-- function ShenBingEffct:getAddDamage(weapon,user)
--     assert(type(weapon) == "table")
--     local addValue = 0
--     for i=1,10 do
--         local effctId = weapon["effct"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 7) == true then
--                 addValue = addValue + self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--             else

--             end
--         else
--             break
--         end
--     end
--     return addValue
-- end

-- --流血效果伤害
-- function ShenBingEffct:getbleed(weapon,user)
--     local bleed,odds,time = 0,0,0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 8) == true then
--                 local var1,var2,var3 = self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--                 bleed = bleed + var1
--                 odds = odds + var2
--                 time = time + var3
--             else
--             end
--         else
--             break
--         end
--     end
--     return bleed,odds,time
-- end
-- --额外伤害加流血
-- function ShenBingEffct:getBleedAndDamage(weapon,user)
--     local damage,bleed,odds,time = 0,0,0,0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 9) == true then
--                 local var4,var1,var2,var3 =  self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--                 damage = damage + var4
--                 bleed = bleed + var1
--                 odds = odds + var2
--                 time = time + var3
--             else
--             end
--         end
--     end

--     return damage,bleed,odds,time
-- end

-- --使得敌人获得招架降低效果
-- function ShenBingEffct:getWeaponExtraParry(weapon,user)
--     local bleed,odds,time = 0,0,0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 10) == true then
--                 local var1,var2,var3 = self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--                 bleed = bleed + var1
--                 odds = odds + var2
--                 time = time + var3
--             else
--             end
--         else
--             break
--         end
--     end
--     return bleed,odds,time
-- end

-- --击中敌人时，有一定几率使得敌人获得攻速降低效果。
-- function ShenBingEffct:getWeaponExtraAttackSpeed(weapon,user)
--     local bleed,odds,time = 0,0,0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 11) == true then
--                 local var1,var2,var3 = self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--                 bleed = bleed + var1
--                 odds = odds + var2
--                 time = time + var3
--             else
--             end
--         else
--             break
--         end
--     end

--     return bleed,odds,time
-- end

-- --攻击命中敌人时，有一定几率可以打落别人兵器
-- function ShenBingEffct:getunloadWeaponOdds()
--     assert(type(weapon) == "table")
--     local addValue = 0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 12) == true then
--                 addValue = addValue + self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--             else
--             end
--         else
--             break
--         end
--     end
--     return addValue
-- end
-- --提升敌人格挡时，打飞他武器的概率
-- function ShenBingEffct:getWeaponParryBlowFly(weapon,user)
--     assert(type(weapon) == "table")
--     local addValue = 0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 13) == true then
--                 addValue = addValue + self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--             else
--             end
--         else
--             break
--         end
--     end

--     return addValue
-- end

-- --格挡住敌人时一定几率反击
-- function ShenBingEffct:getWeaponParryFightBack(weapon,user)
--     local odds,damage
--     for i=1,10 do
--         local effctId = self["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if ShenBingEffct:isHaveEffect(effctId, 14) == true then
--                 local var1,var2 = self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--                 odds = odds + var1
--                 damage = var2 + damage
--             else
--             end
--         else
--             break
--         end
--     end

--     return odds,damage
-- end

-- --自己格挡住敌人武器时，有一定几率打落敌人的兵器
-- function ShenBingEffct:getEffct15()
--     assert(type(weapon) == "table")
--     local addValue = 0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 15) == true then
--                 addValue = addValue + self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--             else
--             end
--         else
--             break
--         end
--     end

--     return addValue
-- end

-- --敌人格挡自身攻击时，还是会承受部分伤害
-- function ShenBingEffct:getEffct16(weapon,user)
--     assert(type(weapon) == "table")
--     local addValue = 0
--     for i=1,10 do
--         local effctId = weapon["effect"..i]
--         if effctId ~= nil and effctId ~= "" then
--             if self:isHaveEffect(effctId, 16) == true then
--                 addValue = addValue + self:getAddNum(effctId,user,Helper:getDef(weapon.cuilianCount,0),Helper:getDef(weapon.weight,0))
--             else
--             end
--         else
--             break
--         end
--     end

--     return addValue
-- end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/12 17:15:00
-- @desc 获取特效
function ShenBingEffct:getWeaponEffectByEffectId(effectMapId)
    assert(type(effectMapId) == "string")
    return Skill:getSkillEffect(effectMapId)
end

-----------------------------------------------------------------------------------------------------------
--创建神兵effectList
function ShenBingEffct:initWeaponEffect(role)
    -- if role._role.teamId ~= 1 then
    --     return
    -- end
    -- if not role:isPlayer() then
    --     return
    -- end
    local weapon = role._role:getEquipByName("weapon")
    local weapontype = role._role:getCurrWeaponType()

    role._WeaponEffectArray = {}
    if weapon == nil and weapontype == "拳脚" then
        print("没有装备神兵！无法创建神兵effectList")
        return
    end
    local weaponAttr = role._role:getOneItemByKey(weapon.itemId)
    if weaponAttr == nil then
        print("weapon.itemId无法获得该兵器", weapon.itemId)
        return
    end

    for i = 1, 10 do
        local effectId = weaponAttr["effct" .. tostring(i)]
        -- Helper:print_lua_table(weaponAttr)
        if effectId ~= nil and effectId ~= "" then
            local effectAttr = self:getEffectAttr(effectId)
            if effectAttr and effectAttr.specialnumber and effectAttr.formula then
                local cuilianCount, weight = Helper:getDef(weaponAttr.cuilianCount, 0), Helper:getDef(weaponAttr.weight, 0)
                local yindu, rendu = Helper:getDef(weaponAttr.yindu, 0),Helper:getDef(weaponAttr.rendu, 0)
                local params = {CN = cuilianCount, weight = weight, currDex = role:getFinalAttr("currDex"), currStr = role:getFinalAttr("currStr"),YD1 = yindu, RD1 = rendu}
                -- if DEBUG_MODE == 1 then
                --     effectAttr.formula = 1
                -- end
                local formulaList = string.split(effectAttr.formula, ";")
                local idList = string.split(effectAttr.specialnumber, ";")
                local fighttext = Helper:getDef(effectAttr.fighttext, "")
                -- local effctNameText  = Helper:getDef(effectAttr.name,"")
                local effctNameText = Helper:getDef(effectAttr.poptext, "")
                if #idList ~= #formulaList then
                    assert(nil, "formula与specialnumber配置的个数不匹配")
                end

                local weaponEffect = {}
                weaponEffect.effectId = effectId
                weaponEffect.formulaList = formulaList
                weaponEffect.effctNameText = effctNameText
                weaponEffect.idList = idList
                weaponEffect.conditiontype = effectAttr.conditiontype
                weaponEffect.params = params
                weaponEffect.fighttext = fighttext

                table.insert(role._WeaponEffectArray, weaponEffect)
            end
        end
    end

    table.sort(role._WeaponEffectArray, function(a, b)
        return a.effectId < b.effectId
    end)
end

-- 得到当前触发的 WeaponEffectList
function ShenBingEffct:getRandomEwaponEffectResult(role, weapon, tYpe)
    assert(type(tYpe) == "number")
    local rTab = {}
    local strTab = {}
    local namelist = {}
    local WeaponEffect = role._WeaponEffectArray

    if SHENBINGSYS ~= true or not WeaponEffect then
        return rTab, strTab, namelist
    end

    for __, effectAttr in pairs(WeaponEffect) do
        local specialIsDo = false

        if effectAttr.conditiontype == tYpe then
            local idList = effectAttr.idList
            for k, id in pairs(idList) do
                local params = effectAttr.params
                local formulaList = effectAttr.formulaList
                local fighttext = effectAttr.fighttext
                local effctNameText = effectAttr.effctNameText
                if #idList ~= #formulaList then
                    assert(nil, "formula与specialnumber配置的个数不匹配")
                end

                local random = Helper:GetValueFromScript(formulaList[k], params) * 100
                local randomNum = role._fight:randomAndSetSeed(1, 100)
                print("randomNum = ", randomNum, random)
                if randomNum > random then
                else
                    local effect = self:getWeaponEffectByEffectId(id)
                    if effect ~= nil then

                        table.insert(rTab, effect)
                        table.insert(strTab, fighttext)
                        table.insert(namelist, effctNameText)

                        if specialIsDo == false then
                            LogSystem:log("旧版战斗：", "神兵特性ID = ", effectAttr.effectId .. " |神兵持有者 = ", role:getName())
                            specialIsDo = true
                        end

                        LogSystem:log("旧版战斗：", "神兵效果ID = ", id)
                    else
                        assert(nil, "异常没有找到特效配置:" .. id)
                    end
                end
            end
        end
    end
    return rTab, strTab, namelist
end

--获取武器对应特性
function ShenBingEffct:getShenBingTypeEffect(weaponType)
    if not weaponType then
        return
    end
    local effectList = {}
    for k, list in pairs(weaponList) do
        if list.weapontype == weaponType then
            effectList[list.specialget / 100 + 1] = list.specialid
        end
    end
    return effectList
end

-- 获得当前毒术等级
function ShenBingEffct:getDssklv(name)
    assert(type(name) == "string")
    if name == nil then
        name = "jibendushu"
    end
    local dssklv = Helper:getDef(User:getRole():getSkillLv(name), 0)
    return dssklv
end

--获取神兵特性所带永久常态buff
function ShenBingEffct:getEffectNormalBuff(effectId)
    local effect = self:getEffectAttr(effectId)

    if MapIsEmpty(effect) == false then
        return effect.permanentBuffId
    end

    return nil
end

--获取神兵所带永久常态buff
function ShenBingEffct:getShenBingNormalBuff(weapon)
    local normalBuffs = {}

    if MapIsEmpty(weapon) == false then
        for i = 1, 10 do
            local effectId = weapon["effct" .. i]
            if effectId ~= nil and effectId ~= "" then
                local buffId = self:getEffectNormalBuff(effectId)
                if buffId ~= nil and tonumber(buffId) ~= 0 then
                    table.insert(normalBuffs, buffId)
                end
            end
        end
    end

    return normalBuffs
end

--[[
    @desc: 获得战斗buff数组
    author:TangJian
    time:2022-03-05 17:47:12
    --@weapon: 
    @return:
]]
function ShenBingEffct:getFightBuffArray(weapon)
    local buffArray = {}
    local specialInfoList = self:getSpecialInfoList(weapon)
    for i, specialInfo in ipairs(specialInfoList) do
        local normalBuff = ShenBingRes:getShenBingNormalBuffInfo(specialInfo.permanentBuffId)
        if normalBuff then
            table.insert(buffArray, normalBuff)
        else
            print("找不到常态buff：", specialInfo.permanentBuffId)
        end
    end
    return buffArray
end

function ShenBingEffct:getBuffLauncherIdList(weapon)
    local buffLauncherIdList = {}
    local specialInfoList = self:getSpecialInfoList(weapon)
    for i, specialInfo in ipairs(specialInfoList) do
        local buffLauncherAdd = specialInfo.buffLauncherAdd
        if buffLauncherAdd then
            table.insert(buffLauncherIdList, buffLauncherAdd)
        end
    end
    return buffLauncherIdList
end

--武器打断打飞机制
function ShenBingEffct:getFlyAndBreakParams(weapon)
    local specialInfoList = self:getSpecialInfoList(weapon)
    for i, specialInfo in ipairs(specialInfoList) do
        if specialInfo.specialnumber == "DDDF1" then
            return {
                breakWeapon = 0, --打断武器
                flyWeapon = 0, --打飞武器
                brokenWeapon = 0, --被打断武器
                beflyWeapon = 0 --被打飞武器
            }
        end
    end
end

local EffectAttrConstValueConfig = {
    ["DDDF1"] = {
        flyWeapon = 0,
        beflyWeapon = 0,
        breakWeapon = 0,
        brokenWeapon = 0
    }
}

function ShenBingEffct:getWeaponFlyValue(weapon)
    local specialInfoList = self:getSpecialInfoList(weapon)
    local value = 1
    for i, specialInfo in ipairs(specialInfoList) do
        if EffectAttrConstValueConfig[specialInfo.specialnumber] ~= nil then
            if EffectAttrConstValueConfig[specialInfo.specialnumber].flyWeapon ~= nil then
                value = value * EffectAttrConstValueConfig[specialInfo.specialnumber].flyWeapon
            end
        end
    end
    return value
end

function ShenBingEffct:getBeFlyWeapon(weapon)
    local specialInfoList = self:getSpecialInfoList(weapon)
    local value = 1
    for i, specialInfo in ipairs(specialInfoList) do
        if EffectAttrConstValueConfig[specialInfo.specialnumber] ~= nil then
            if EffectAttrConstValueConfig[specialInfo.specialnumber].beflyWeapon ~= nil then
                value = value * EffectAttrConstValueConfig[specialInfo.specialnumber].beflyWeapon
            end
        end
    end
    return value
end

function ShenBingEffct:getBreakWeapon(weapon)
    local specialInfoList = self:getSpecialInfoList(weapon)
    local value = 1
    for i, specialInfo in ipairs(specialInfoList) do
        if EffectAttrConstValueConfig[specialInfo.specialnumber] ~= nil then
            if EffectAttrConstValueConfig[specialInfo.specialnumber].breakWeapon ~= nil then
                value = value * EffectAttrConstValueConfig[specialInfo.specialnumber].breakWeapon
            end
        end
    end
    return value
end

function ShenBingEffct:getBrokenWeapon(weapon)
    local specialInfoList = self:getSpecialInfoList(weapon)
    local value = 1
    for i, specialInfo in ipairs(specialInfoList) do
        if EffectAttrConstValueConfig[specialInfo.specialnumber] ~= nil then
            if EffectAttrConstValueConfig[specialInfo.specialnumber].brokenWeapon ~= nil then
                value = value * EffectAttrConstValueConfig[specialInfo.specialnumber].brokenWeapon
            end
        end
    end
    return value
end

return ShenBingEffct
00000000000000
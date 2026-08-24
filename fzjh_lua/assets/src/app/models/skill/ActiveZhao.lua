local Skill = require("app.models.skill.Skill")
local Role = require("app.models.role.Role")

local activeZhaoCheatTab = {}

local methodsTab =
{
    ["quanjiao1"] = SKILL_METHOD_TYPE_QUANJIAO,
    ["quanjiao2"] = SKILL_METHOD_TYPE_QUANJIAO,
    ["neigong"] = SKILL_METHOD_TYPE_NEIGONG,
    ["qinggong"] = SKILL_METHOD_TYPE_QINGGONG,
    ["zhaojia"] = SKILL_METHOD_TYPE_ZHAOJIA,
    ["jianfa"] = 5,
    ["daofa"] = 5,
    ["gunfa"] = 5,
    ["anqi"] = 5,
    ["bianfa"] = 5,
    ["shuangchi"] = 5,
    ["qinfa"] = 5,
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 11:44:40
-- @desc 检查 逻辑条件是否正确
local function checkLogicIsValid(logic)
    return switch(logic,
        {
            ["小于"] = true,
            ["小于等于"] = true,
            ["等于"] = true,
            ["大于等于"] = true,
            ["大于"] = true,
            default = false
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/11 20:48:02
-- @desc 获取类型的中文称呼
local function getMethodCN(stype)
    return switch(stype,
        {
            "拳脚",
            "内功",
            "轻功",
            "招架",
            "兵器"
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 11:27:56
-- @desc 检查资源是否格式正确
local function checkResourceIsValid(rtypes, ids, logics, values)
    if rtypes == nil or ids == nil or logics == nil or values == nil then
        return
    end
    local typeList = string.split(rtypes, ";")
    local idList = string.split(ids, ";")
    local logicList = string.split(logics, ";")
    local valueList = string.split(values, ";")
    
    
    if (#logicList ~= 1 and #idList ~= #logicList) or #idList ~= #valueList or (#typeList ~= 1 and #typeList ~= #idList) then
        print(rtypes, ids, logics, values)
        assert(nil, "判断条件数量不匹配 id = " .. tostring(#idList) .. " logic = " .. tostring(#logicList) .. " value = " .. tostring(#valueList) .. " type = " .. tostring(#typeList))
    
    end
    for i, v in ipairs(idList) do
        local rtype = Helper:getDef(typeList[i], typeList[1])
        local id, logic, value = idList[i], Helper:getDef(logicList[i], logicList[1]), valueList[i]
        switch(rtype,
            {
                ["属性"] = function()
                    if Role[id] == nil then
                        assert(nil, "未知角色属性 ---> " .. tostring(id))
                    end
                    
                    if value == nil then
                        assert(nil, "角色属性的判断值不能为空 ---> " .. tostring(value))
                    end
                end,
                ["武功"] = function()
                    local skill = Skill:getSkill(id)
                    if MapIsEmpty(skill) == true then
                        assert(nil, "未知的武功ID ---> " .. tostring(id))
                    end
                    
                    if type(value) ~= "number" and tonumber(value) == nil then
                        assert(nil, "武功等级必须为数字类型,请检查 --- > " .. tostring(value))
                    end
                end,
                ["装备技能"] = function()
                    local list = string.split(id, " or ")
                    for j, id in ipairs(list) do
                        local skill = Skill:getSkill(id)
                        if MapIsEmpty(skill) == true then
                            assert(nil, "未知的技能ID ---> " .. tostring(id))
                        end
                        
                        if value ~= "是" and value ~= "否" and type(value) ~= "number" and tonumber(value) == nil then
                            assert(nil, "装备技能的类型的判断值,必须为“是”或者“否”或者数字。 ---> " .. tostring(value))
                        end
                    end
                end,
                default = function()
                    assert(nil, "未知条件类型 ---> " .. tostring(rtype))
                end
            })
        
        if checkLogicIsValid(logic) == false then
            assert(nil, "未知逻辑条件 ---> " .. tostring(logic))
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 21:33:46
-- @desc 条件转换为中文
local function conditionToCN(ctype, id, logic, value)
    local tab = {
        ["小于"] = "低于",
        ["小于等于"] = "不高于",
        ["等于"] = "为",
        ["大于等于"] = "不低于",
        ["大于"] = "高于",
        default = ""
    }
    return switch(ctype,
        {
            ["属性"] = function()
                -- return Role:getCHAttrName(id) ..tab[logic]..tostring(value)
                return "[" .. Role:getCHAttrName(id) .. "]" .. tab[logic] .. tostring(value)
            end,
            ["武功"] = function()
                local skill = Skill:getSkill(id)
                if MapIsEmpty(skill) == true then
                    else
                    -- return tostring(skill.name)..tab[logic]..tostring(value)
                    return "[" .. tostring(skill.name) .. "]" .. tab[logic] .. tostring(value) .. "级"
                end
            end,
            ["装备技能"] = function()
                local list = string.split(id, " or ")
                local str = ""
                for i, id in ipairs(list) do
                    local skill = Skill:getSkill(id)
                    if MapIsEmpty(skill) == true then
                        else
                        if i == 1 then
                            str = str .. "[" .. tostring(skill._NoColorName) .. "]"
                        else
                            str = str .. "或[" .. tostring(skill._NoColorName) .. "]"
                        end
                    end
                end
                -- return tostring(skill.name)..tab[logic]..tostring(value)
                local str_1 = ""
                if logic == "不等于" then
                    str_1 = "禁止"
                end

                if value == "是" then
                    return str_1 .. "准备" .. str
                elseif type(tonumber(value)) == "number" then
                    return str_1 .. "准备" .. str .. "为" .. getMethodCN(tonumber(value))
                elseif string.find(value," or ") then
                    local valueList = string.split(value, " or ")
                    local text = ""
                    for k,v in ipairs(valueList) do
                        if k == 1 then
                            text = str_1 .. "准备" .. str .. "为" .. getMethodCN(tonumber(v))
                        else
                            text = text .. "或" .. getMethodCN(tonumber(v))
                        end
                    end

                    return text
                else
                    return "未准备" .. str
                end
            -- return "[" .. tostring(skill.name) .. "]"..logic..tostring(value)
            end,
            ["门派"] = function ()
                local Family = require("app.models.family.Family")
                local list = string.split(id, " or ")
                local str = "[门派]为"
                for i, id in ipairs(list) do
                    local family = Family:getFamily(id)
                    if MapIsEmpty(family) == true then
                    else
                        if i == 1 then
                            str = str .. "[" .. tostring(family:getName()) .. "]"
                        else
                            str = str .. "或[" .. tostring(family:getName()) .. "]"
                        end
                    end
                end
                return str
            end,

            ["使用武学"] = function ()
                local Family = require("app.models.family.Family")
                local skillIdList = string.split(id, " or ")
                local str = ""
                for i, id in ipairs(skillIdList) do
                    local skill = Skill:getSkill(id)
                    if MapIsEmpty(skill) == false then
                        if i == 1 then
                            str = str .. "[" .. tostring(skill._NoColorName) .. "]"
                        else
                            str = str .. "或[" .. tostring(skill._NoColorName) .. "]"
                        end
                    else
                        print("找不到技能：",id)
                    end
                end

                if str ~= "" then
                    return "战斗中使用" .. "["..value.."]" .. "为" .. str
                end
            end,

            ["使用武学属于门派"] = function ()
                local Family = require("app.models.family.Family")
                local skilType = id
                local familyList = string.split(value," or ")
                local str = "战斗中使用".."["..skilType.."]"

                for i, id in ipairs(familyList) do
                    local family = Family:getFamily(id)
                    if MapIsEmpty(family) == true then
                    else
                        if i == 1 then
                            str = str .. "为[" .. tostring(family.name) .. "]"
                        else
                            str = str .. "或[" .. tostring(family:getName()) .. "]"
                        end
                    end
                end

                str = str.."武学"

               return str
            end,
            default = nil
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 18:17:57
-- @desc 主动招式类
local ActiveZhao = {}

-- 定义变量
defVars(ActiveZhao,
    {
        id = {"Id", ""}, -- 编号
        name = {"Name", ""}, -- 名称
        desc = {"Desc", ""}, -- 描述
        
        owner = {"Owner"}, -- 拥有者
        
        useDesc = {"UseDesc"}, -- 使用描述
        hitDesc = {"HitDesc"}, -- 命中描述
        
        useCondition = {"UseCondition", }, -- 使用条件
        cost = {"Cost", 0}, -- 消耗
        cd = {"CD", 0}, -- 冷却时间
        
        cdLeft = {"CDLeft", 0}, -- 剩余冷却时间
        
        type = {"Type", "攻击"},
        effects = {"Effects", ""}, -- 效果
        additionalEffects = {"AdditionalEffects", ""}, -- 额外的效果
        
        arg1 = {"Arg1"},
        arg2 = {"Arg2"},
        arg3 = {"Arg3"},
        
        animType = {"AnimType", "攻击"}, -- 动画类型
        anim = {"Anim", {}}, -- 动画
        level = {"Level",1},
        unDoEffects = {"UnDoEffects",{}}, --不生效的效果列表

        anim2 = {"Anim2", {}}, -- 第二套主动技能动画
    })

-- 辅助变量定义
defVars(ActiveZhao,
    {
        cache = {"Cache", {}},
    })

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 18:12:01
-- @desc 通过data创建
function ActiveZhao:create(data)
    local p = inherit(clone(data or {}), ActiveZhao)
    p:initWithData(data)
    
    -- cd时间转为帧
    p:setCD(data.cd * 30)
    if data.pvpcd then
        p.pvpcd = data.pvpcd * 30
    end
    
    -- 初始化动画
    local anim = Helper:GetValueFromScript(data.anim)
    -- assert(anim)
    if anim == nil then
        anim = {
            duration = 12, -- 主动技能总时间
            attackAnim =
            {
                animName = "liumaishenjian-ready",
                duration = 12,
                offset = -300,
                hits =
                {
                    {
                        frame = 6,
                        hitPos = "head",
                        hisOffset = -1
                    }
                }
            }
        }
    end
    
    p:setAnim(anim)
    
    return p
end

local function initMethods(zhao)
    if zhao.methods ~= nil and string.len(zhao.methods) > 0 then
        local method = string.split(zhao.methods, ";")
        zhao.methods = {}
        for i, v in ipairs(method) do
            table.insert(zhao.methods, tonumber(v))
        end
    end
end



local function initCheatData(zhao)
    local learnConditions = {}
    for i = 1, 10 do
        local i_string = tostring(i)
        local learn_value_i = "learn_value_" .. i_string
        if zhao[learn_value_i] ~= nil then
            learnConditions[i_string] = learn_value_i
        else
            break
        end
    end

    if not activeZhaoCheatTab[zhao.id] then
        activeZhaoCheatTab[zhao.id] = TableProxy:createEncryptedTable(learnConditions)
    end
end

local cheatState = {}

local function checkIsCheat(zhao)
    if MapIsEmpty(zhao) == true or MapIsEmpty(activeZhaoCheatTab) == true then
        return false
    end
    
    local cheatDate = activeZhaoCheatTab[zhao.id]
    for k,v in pairs(cheatDate) do
        if zhao[v] == nil then
            print("作弊!!!, 修改数据", zhao.id,v, "->", nil)
            IS_ABLE_TO_SAVE_DATA = false
            Collection:memoryCheat(User:getRole().userid, "CheatingAgainstSystem", v, nil)
            cc.Director:getInstance():endToLua()
        end
    end

    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 18:12:07
-- @desc 通过data初始化
function ActiveZhao:initWithData(data)
    assert(type(data) == "table", [[type(data) == "table"]])
   
    initMethods(self)
    initCheatData(self)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 22:35:18
-- @desc 克隆
function ActiveZhao:clone()    
    return inherit({owner=self.owner}, self)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/23 16:12:31
-- @desc 得到动画时间
function ActiveZhao:getDuration()
    return self:getAnim().duration
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 15:52:13
-- @desc 得到效果
function ActiveZhao:getEffectArray()
    local effectArray = self:getCache()["effectArray"]
    if effectArray then
        for k, skillEffect in pairs(effectArray) do
            skillEffect:setActiveZhao(self)
        end
    else
        local effects = self:getEffects()
        if effects ~= "" then
            effectArray = {}
            local effects = string.split(self:getEffects(), ";")
            for k, v in pairs(effects) do
                if v ~= "" then
                    if string.find(v, "{") then
                        -- PopText("v = " .. v)
                        local zargs = Helper:GetValueFromScript(v)
                        v = zargs[1]
                        table.remove(zargs, 1)
                        local skillEffect = Skill:getSkillEffect(v):clone()
                        skillEffect:setZArgs(zargs)

                        -- skillEffect:setActiveZhaoCost(self:getCost())
                        skillEffect:setActiveZhao(self)
                        table.insert(effectArray, skillEffect)
                    else
                        local skillEffect = Skill:getSkillEffect(v):clone()
                        -- skillEffect:setActiveZhaoCost(self:getCost())
                        skillEffect:setActiveZhao(self)
                        table.insert(effectArray, skillEffect)
                    end
                end
            end
            self:getCache()["effectArray"] = effectArray
        end
    end
    local additionalEffectArray = self:getAdditionalEffectArray()
    if additionalEffectArray then
        return table.mergeArray(effectArray, additionalEffectArray)
    else
        return effectArray
    end    
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/27 14:57:58
-- @desc 得到立即生效的效果
function ActiveZhao:getImmediateEffectArray()
    local immediateEffectArray = {}
    local effectArray = self:getEffectArray()

    local unDoEffects = self:getUnDoEffects()   
    for i, effect in ipairs(effectArray) do
        local effectId = effect:getId()
        if effect:getDuration() == 0 and unDoEffects[effectId] ~= true then
            table.insert(immediateEffectArray, effect)
        end
    end
    return immediateEffectArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 02:51:45
-- @desc 临时效果
function ActiveZhao:setAdditionalEffectArray(additionalEffects)
    -- PopText("additionalEffects = " .. additionalEffects)

    self:setAdditionalEffects(additionalEffects)
    self:getCache()["additionalEffectArray"] = nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 02:53:37
-- @desc 得到额外的效果
function ActiveZhao:getAdditionalEffectArray()
    local additionalEffectArray = self:getCache()["additionalEffectArray"]
    if additionalEffectArray then
        for k, skillEffect in pairs(additionalEffectArray) do
            skillEffect:setActiveZhao(self)
        end
    else
        local additionalEffects = self:getAdditionalEffects()
        if additionalEffects ~= "" then
            additionalEffectArray = {}
            local effects = string.split(additionalEffects, ";")
            for k, v in pairs(effects) do
                if string.find(v, "{") then
                    -- PopText("v = " .. v)
                    local zargs = Helper:GetValueFromScript(v)
                    v = zargs[1]
                    table.remove(zargs, 1)
                    local skillEffect = Skill:getSkillEffect(v):clone()
                    skillEffect:setZArgs(zargs)
                    -- skillEffect:setActiveZhaoCost(self:getCost())
                    skillEffect:setActiveZhao(self)
                    table.insert(additionalEffectArray, skillEffect)
                else
                    -- PopText("v = " .. "[" .. v .. "]")
                    local skillEffect = Skill:getSkillEffect(v):clone()
                    -- skillEffect:setActiveZhaoCost(self:getCost())
                    skillEffect:setActiveZhao(self)
                    table.insert(additionalEffectArray, skillEffect)
                end
            end
        end
    end
    return additionalEffectArray
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 11:52:13
-- @desc 检查招式学习条件 调试使用
function ActiveZhao:checkLearnConditionIsValid()
    for i = 1, 10 do
        if self["learn_type_" .. tostring(i)] ~= nil then
            if self["learn_id_" .. tostring(i)] == nil or self["learn_logic_" .. tostring(i)] == nil or self["learn_value_" .. tostring(i)] == nil then
                assert(nil, self:getName() .. "第[" .. tostring(i) .. "]个使用条件填写不全")
            end
            if string.find(self["learn_type_" .. tostring(i)], "；") ~= nil or string.find(self["learn_id_" .. tostring(i)], "；") ~= nil or string.find(self["learn_logic_" .. tostring(i)], "；") ~= nil or string.find(self["learn_value_" .. tostring(i)], "；") ~= nil then
                assert(nil, self:getName() .. "第[" .. tostring(i) .. "]个学习条件中存在中文封号,请检查")
            end
            checkResourceIsValid(self["learn_type_" .. tostring(i)], self["learn_id_" .. tostring(i)], self["learn_logic_" .. tostring(i)], self["learn_value_" .. tostring(i)])
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 12:13:51
-- @desc 检查招式使用条件 调试使用
function ActiveZhao:checkUseConditonIsValid()
    for i = 1, 10 do
        if self["use_type_" .. tostring(i)] ~= nil then
            if self["use_id_" .. tostring(i)] == nil or self["use_logic_" .. tostring(i)] == nil or self["use_value_" .. tostring(i)] == nil then
                assert(nil, self:getName() .. "第[" .. tostring(i) .. "]个使用条件填写不全")
            end
            if string.find(self["use_type_" .. tostring(i)], "；") ~= nil or string.find(self["use_id_" .. tostring(i)], "；") ~= nil or string.find(self["use_logic_" .. tostring(i)], "；") ~= nil or string.find(self["use_value_" .. tostring(i)], "；") ~= nil then
                assert(nil, self:getName() .. "第[" .. tostring(i) .. "]个使用条件中存在中文封号,请检查")
            end
            checkResourceIsValid(self["use_type_" .. tostring(i)], self["use_id_" .. tostring(i)], self["use_logic_" .. tostring(i)], self["use_value_" .. tostring(i)])
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 15:13:46
-- @desc 招式的使用条件
function ActiveZhao:zhaoUseCondition(role, currWeaponType)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:learnCondition(role)", "没有角色,学习条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    
    if currWeaponType == nil then
        currWeaponType = role:getCurrWeaponType()
    end

    local result, retText = true, ""
    for i = 1, 10 do
        if self["use_type_" .. tostring(i)] ~= nil then
            local typeList = string.split(self["use_type_" .. tostring(i)], ";")
            local idList = string.split(self["use_id_" .. tostring(i)], ";")
            local logicList = string.split(self["use_logic_" .. tostring(i)], ";")
            local valueList = string.split(self["use_value_" .. tostring(i)], ";")
            
            for j, id in ipairs(idList) do
                local ltype = Helper:getDef(typeList[j], typeList[1])
                local logic = Helper:getDef(logicList[j], logicList[1])
                result, retText = switch(ltype, {
                    ["武功"] = function() return self:skillCondition(role, id, logic, valueList[j]) end,
                    ["属性"] = function() return self:attrCondition(role, id, logic, valueList[j]) end,
                    ["装备武器"] = function() return self:weaponCondition(currWeaponType, id, logic, valueList[j]) end,
                    ["门派"] = function() return self:familyCondition(role, id, logic, valueList[j]) end,
                    ["使用武学"] = function() return self:useSkillCondition(role, id, logic, valueList[j]) end,
                    ["使用武学属于门派"] = function() return self:useSkillFamilyBelongCondition(role, id, logic, valueList[j]) end,

                    ["default"] = function() return self:skillIsPrepared(role, id, logic, valueList[j]) end
                })
                if result == false then
                    return result, retText
                end
            end
        end
    end

    do
        -- add by XiaoZhiWei 2018/07/03 21:29:51 必须满足:招式类型所准备的武功和招式所对应的武学必须保持一致
        local skillId = Skill:getSkillIdByZhaoId(self:getId())
        local skill = Skill:getSkill(skillId)
        local preparedList = role:getSkillPrepare()
        result = false
        for k,v in pairs(preparedList) do
            if skillId == v then
                for i,zhaoType in ipairs(self.methods) do
                    if methodsTab[k] == zhaoType then
                        result = true 
                        break
                    end
                end
            end
        end
        if result == false then
            return false , "你的[" .. skill.name .."]还未准备好" 
        end
    end
    

    return result

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 11:47:19
-- @desc 招式的学习条件
function ActiveZhao:learnCondition(role)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:learnCondition(role)", "没有角色,学习条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end

    if role.isDreamRole == false and role.isChallengeRole == false then
        checkIsCheat(self)
    end
    

    local result, retText = true, ""
    for i = 1, 10 do
        if self["learn_type_" .. tostring(i)] ~= nil then
            local typeList = string.split(self["learn_type_" .. tostring(i)], ";")
            local idList = string.split(self["learn_id_" .. tostring(i)], ";")
            local logicList = string.split(self["learn_logic_" .. tostring(i)], ";")
            local valueList = string.split(self["learn_value_" .. tostring(i)], ";")
            
            for j, id in ipairs(idList) do
                local ltype = Helper:getDef(typeList[j], typeList[1])
                local logic = Helper:getDef(logicList[j], logicList[1])
                result, retText = switch(ltype, {
                    ["武功"] = function() return self:skillCondition(role, id, logic, valueList[j]) end,
                    ["属性"] = function() return self:attrCondition(role, id, logic, valueList[j]) end,
                    ["门派"] = function() return self:familyCondition(role, id, logic, valueList[j]) end,
                    ["default"] = function() return self:skillIsPrepared(role, id, logic, valueList[j]) end
                })
                if result == false then
                    return result, retText
                end
            end
        end
    end

    if self.learnMethod == 1 then
        return false, "此招式只能通过书页习得"
    end

    return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 12:14:49
-- @desc 武功类学习条件判断
function ActiveZhao:skillCondition(role, skillId, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:learnCondition(role)", "没有角色,学习条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    local result = true
    -- 判断条件如果为空,则直接通过判断
    if skillId == nil or logic == nil or value == nil then
        return true
    else
        local skill = Skill:getSkill(skillId)
        local roleSkill = role:getSkill(skillId)
        if MapIsEmpty(skill) == true then
            return false, "没有该武功的信息"
        elseif MapIsEmpty(roleSkill) == true then
            return false, "你还未习得【" .. tostring(skill.name) .. "】"
        else
            local skillLv = Skill:getLv(roleSkill.exp)
            if Helper:compareTwoNumberWithCN(skillLv, value, logic) == false then
                return false, "你的[" .. tostring(skill.name) .. "]火候太浅"
            end
        end
    end
    return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 17:02:46
-- @desc 属性类学习条件判断
function ActiveZhao:attrCondition(role, attr, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:learnCondition(role)", "没有角色,学习条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    local result = true
    -- 判断条件如果为空,则直接通过判断
    -- print("判断角色属性", attr, logic, value, role:getAttr(attr))
    if attr == nil or logic == nil or value == nil then
        return true
    else
        -- add by LvBin 2018/10/10 10:28:40 属性判断改为加成后的属性
        if Helper:compareTwoNumberWithCN(role:getFinalAttr(attr), value, logic) ~= true then
            return false, switch(logic,
                {
                    ["小于"] = "你的[" .. tostring(role:getCHAttrName(attr)) .. "]太高，无法学习。",
                    ["小于等于"] = "你的[" .. tostring(role:getCHAttrName(attr)) .. "]太高，无法学习。",
                    -- ["等于"] = "你的["..tostring(role:getCHAttrName(attr)).."]不平衡，无法学习。",
                    ["大于等于"] = "你的[" .. tostring(role:getCHAttrName(attr)) .. "]太低，无法学习。",
                    ["大于"] = "你的[" .. tostring(role:getCHAttrName(attr)) .. "]太低，无法学习。",
                    ["default"] = "你的[" .. tostring(role:getCHAttrName(attr)) .. "]无法确定，无法学习。"
                })
        end
    end
    return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 17:03:06
-- @desc 判断武功是否准备
function ActiveZhao:skillIsPrepared(role, skillId, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:learnCondition(role)", "没有角色,学习条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    local result, text = true, "你的"
    -- 判断条件如果为空,则直接通过判断
    if skillId == nil or logic == nil or value == nil then
        return true
    else
        local list = string.split(skillId, " or ")
        for i, skillId in ipairs(list) do
            local skill = Skill:getSkill(skillId)
            local preparedList = role:getSkillPrepare()
            if MapIsEmpty(skill) == true then
                result, text = false, "没有该武功的信息"
            else
                for k, v in pairs(preparedList) do
                    if skill.id == v then
                        -- add by XiaoZhiWei 2018/07/03 20:17:09 准备好即可
                        if value == "是" then
                            if logic == "不等于" then
                                return false
                            end
                            return true
                        -- add by XiaoZhiWei 2018/07/03 20:17:16 必须准备为指定的类型
                        elseif type(tonumber(value)) == "number" and methodsTab[k] == tonumber(value) then
                            if logic == "不等于" then
                                return false
                            end
                            return true
                        elseif string.find(value," or ") then
                            local valueList = string.split(value, " or ")
                            for __,_value in pairs(valueList) do
                                if methodsTab[k] == tonumber(_value) then
                                    if logic == "不等于" then
                                        return false
                                    end
                                    return true
                                end
                            end
                        end
                    end
                end

                if value == "否" then
                    return true
                end

                if logic == "不等于" then
                    return true
                end
                
                if i == 1 then
                    result, text = false, text .. "[" .. tostring(skill.name) .. "]"
                else
                    result, text = false, text .. "或[" .. tostring(skill.name) .. "]"
                end
            end
        end
    end
    text = text .. "还未准备好"
    return result, text
end

--@desc: 
--@author:Liang SongQiang
--@time:2018-07-06 19:08:18
--@role:[app.models.role.Role#Role]
--@weaponType:武器类型
--@logic:
--@value: 
function ActiveZhao:weaponCondition(currWeaponType, weaponType, logic, value)
    if type(currWeaponType) ~= "string" then
        if PRINT_MODE == 1 then
            print("ActiveZhao:weaponCondition(currWeaponType)", "角色当前武器类型异常:", currWeaponType)
        end
        return false, "没有角色信息,请重试"
    end
    local result,text = true, ""
    -- 判断条件如果为空,则直接通过判断
    -- print("判断角色属性", attr, logic, value, role:getAttr(attr))
    if weaponType == nil or logic == nil or value == nil then
        return true
    else
        if currWeaponType == weaponType and value == "是" then
            return true
        end

        if currWeaponType ~= weaponType and value == "否" then
            return true
        end
        text = "当前武器无法使用该招式"
        return false,text
    end
    return result
end

function ActiveZhao:familyCondition(role, familyIds, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:familyCondition(role)", "没有角色,装备条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end

    local list = string.split(familyIds, " or ")

    local roleFamilyId = role:getFamilyId()

    for _,familyId in ipairs(list) do
        if familyId == roleFamilyId then
            return true
        end
    end

    return false
end

-- 当前使用武学条件判断
function ActiveZhao:useSkillCondition(role, skillIdList, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:useSkillsCondition(role)", "没有角色,当前使用武学条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    local result,text = true, ""
    -- 判断条件如果为空,则直接通过判断
    -- print("判断角色属性", attr, logic, value, role:getAttr(attr))
    if skillIdList == nil or logic == nil or value == nil then
        return true
    else
        skillIdList = string.split(skillIdList, " or ")
        for i,skillId in ipairs(skillIdList) do
            if value == "攻击武学" then
                local skill,doubleSkill = role:getPrepareAttackSkill()
                if logic == "等于" and skill and skill.id == skillId then
                    return true
                end

                if logic == "等于" and doubleSkill and doubleSkill.id == skillId then
                    return true
                end
            else
                local prepareSkillType = switch(value,{
                    ["内功武学"] = "neigong",
                    ["轻功武学"] = "qinggong",
                    ["招架武学"] = "zhaojia",
                })

                local prepareSkillId = role:getPrepareSkillIdByType(prepareSkillType)
                if logic == "等于" and prepareSkillId == skillId then
                    return true
                end
            end
        end
        
        return false
    end
end

-- 当前使用武学属于门派条件判断
function ActiveZhao:useSkillFamilyBelongCondition(role, prepareSkillType, logic, value)
    if MapIsEmpty(role) == true then
        if PRINT_MODE == 1 then
            print("ActiveZhao:useSkillFamilyBelongCondition(role)", "没有角色,当前使用武学条件判断失败")
        end
        return false, "没有角色信息,请重试"
    end
    local result,text = true, ""
    -- 判断条件如果为空,则直接通过判断
    -- print("判断角色属性", attr, logic, value, role:getAttr(attr))
    if prepareSkillType == nil or logic == nil or value == nil then
        return true
    else
        local familyList = string.split(value, " or ")

        if MapIsEmpty(familyList) then
            return false
        end

        local skill,doubleSkill

        if prepareSkillType == "攻击武学" then
            skill,doubleSkill = role:getPrepareAttackSkill()
        else
            local prepareSkillType = switch(prepareSkillType,{
                ["内功武学"] = "neigong",
                ["轻功武学"] = "qinggong",
                ["招架武学"] = "zhaojia",
            })

            local prepareSkillId = role:getPrepareSkillIdByType(prepareSkillType)
            
            if not prepareSkillId then
                return false,"准备武学类型错误"
            end

            skill = Skill:getSkill(prepareSkillId)
        end

        if skill then
            for k,id in pairs(familyList) do
                if logic == "等于" and skill:isSectSkill(id) then
                    return true
                end
            end
        end

        if doubleSkill then
            for k,id in pairs(familyList) do
                if logic == "等于" and doubleSkill:isSectSkill(id) then
                    return true
                end
            end
        end
        
        return false
    end
end

--@desc: 获取资源表格配置的招式学习条件列表
--@author:LvBin
--@time:2025-10-18 17:21:38
--@return
function ActiveZhao:getLearnConditionResList()
	if MapIsEmpty(self.learn_condition_list) == true then
        local retList = {}
        for i = 1, 10 do
            if self["learn_type_" .. tostring(i)] ~= nil then
                local typeList = string.split(self["learn_type_" .. tostring(i)], ";")
                local idList = string.split(self["learn_id_" .. tostring(i)], ";")
                local logicList = string.split(self["learn_logic_" .. tostring(i)], ";")
                local valueList = string.split(self["learn_value_" .. tostring(i)], ";")
                for j, id in ipairs(idList) do
                    local ltype = Helper:getDef(typeList[j], typeList[1])
                    local logic = Helper:getDef(logicList[j], logicList[1])
                    local ltext = conditionToCN(ltype, id, logic, valueList[j])
                    
                    if ltext ~= nil then
                        table.insert(retList, ltext)
                    end
                end
            end
        end

        self.learn_condition_list = retList
    end

    return self.learn_condition_list
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 18:31:14
-- @desc 获取招式学习条件列表 (中文列表,用于界面显示)
function ActiveZhao:getLearnConditionListWithCN()
    -- add by XiaoZhiWei 2017/03/14 17:07:39 只需要初始化一次 以后的调用都是自己直接取
    if MapIsEmpty(self.learn_condition_list_with_CN) == true then
        local retList = self:getLearnConditionResList()
		
        if self.learnMethod == 1 then
            local BookSkillsHelper = require("app.models.book.BookSkillsHelper")
            local str = BookSkillsHelper:getActiveSkillLearnForBookText(self.id)
            table.insert(retList, str)
        end

        if MapIsEmpty(retList) then
            table.insert(retList, "此主动招式获取武学后直接领悟，无需额外学习")
        end

        self.learn_condition_list_with_CN = retList
    else
    end


    return self.learn_condition_list_with_CN
end

-- @desc 获取研习招式的条件文本(用于界面显示)
function ActiveZhao:getLearnZhaoConditionText(role)
    -- 优先使用传入角色
    if role == nil then
        role = User:getRole()
    end

    local result,retText,ltext = true,"",""
    for i = 1, 10 do
        if self["learn_type_" .. tostring(i)] ~= nil then
            local typeList = string.split(self["learn_type_" .. tostring(i)], ";")
            local idList = string.split(self["learn_id_" .. tostring(i)], ";")
            local logicList = string.split(self["learn_logic_" .. tostring(i)], ";")
            local valueList = string.split(self["learn_value_" .. tostring(i)], ";")
            for j, id in ipairs(idList) do
                local ltype = Helper:getDef(typeList[j], typeList[1])
                local logic = Helper:getDef(logicList[j], logicList[1])

                result,retText = switch(ltype, {
                    ["武功"] = function() return self:skillCondition(role, id, logic, valueList[j]) end,
                    ["属性"] = function() return self:attrCondition(role, id, logic, valueList[j]) end,
                    ["门派"] = function() return self:familyCondition(role, id, logic, valueList[j]) end,
                    default = function() print("未知条件类型 ---> ltype") end
                })

                if result == false then
                    ltext = conditionToCN(ltype, id, logic, valueList[j])

                    if ltext ~= "" then
                        return ltext
                    end
                end
                
            end
        end
    end
    return ""
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 18:32:18
-- @desc 获取招式的使用列表
function ActiveZhao:getUseConditonListWithCN()
    -- add by XiaoZhiWei 2017/03/14 17:07:39 只需要初始化一次 以后的调用都是自己直接取
    if MapIsEmpty(self.use_condition_list_with_CN) == true then
        local retList = {}
        -- print("self.cost", self.cost, Helper:GetValueFromScript(self.cost, {neili = User:getRoleAttr("neili")}), User:getRoleAttr("neili"))
        if self.cost ~= nil then
            table.insert(retList, "内力不低于" .. tostring(math.ceil(self:getFinalCost())))
        end
        for i = 1, 10 do
            if self["use_type_" .. tostring(i)] ~= nil then
                local typeList = string.split(self["use_type_" .. tostring(i)], ";")
                local idList = string.split(self["use_id_" .. tostring(i)], ";")
                local logicList = string.split(self["use_logic_" .. tostring(i)], ";")
                local valueList = string.split(self["use_value_" .. tostring(i)], ";")
                for j, id in ipairs(idList) do
                    local ltype = Helper:getDef(typeList[j], typeList[1])
                    local logic = Helper:getDef(logicList[j], logicList[1])
                    local ltext = conditionToCN(ltype, id, logic, valueList[j])
                    
                    if ltext ~= nil then
                        local list = string.splitUTF8(ltext)
                        local str, index = "", 0
                        for i, v in ipairs(list) do
                            str = str .. v
                            index = index + string.len(v)
                            if index >= 60 then -- add by XiaoZhiWei 2017/03/16 11:07:11 超过20个中文汉字的长度,则换一行
                                if i == #list - 1 then -- add by XiaoZhiWei 2017/03/16 11:09:29 如果只剩下一个字,则无需换行
                                    str = str .. list[#list]
                                    table.insert(retList, str)
                                    index = 0
                                    str = ""
                                    break
                                else
                                    table.insert(retList, str)
                                    index = 0
                                    str = ""
                                end
                            elseif i == #list then
                                table.insert(retList, str)
                            end
                        end
                    end
                end
            end
        end
        
        local skillId = Skill:getSkillIdByZhaoId(self:getId())
        local skill = Skill:getSkill(skillId)
        if MapIsEmpty(skill) ~= true then
            local str = "准备[" .. tostring(skill._NoColorName) .. "]为"
            for i, v in ipairs(self.methods) do
                if i == 1 then
                    str = str .. getMethodCN(v)
                else
                    str = str .. "或" .. getMethodCN(v)
                end
            end
            table.insert(retList, str)
        end

        -- @desc 去除相同条件字符
        local filter = {}
        for i = #retList,1,-1 do
            local str = retList[i]
            if filter[str] then
                table.remove( retList, i)
            else
                filter[str] = true
            end
        end
        filter = nil

        self.use_condition_list_with_CN = retList
    else
        end
    
    return self.use_condition_list_with_CN
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/11 20:18:35
-- @desc 判断招式是否属于某一个类型
function ActiveZhao:checkTypeIsZhaoMethods(stype)
    if stype == nil then
        return false
    end
    for i, v in ipairs(self.methods) do
        if stype == v then
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 11:10:36
-- @desc 检查效果错误
function ActiveZhao:checkEffectsError()
    local errArray = {"主动招式 ", self:getName(), ": "}
    local isError = false
    local effects = string.split(self:getEffects(), ";")
    for k, v in pairs(effects) do
        if string.find(v, "{") then
            local zargs = Helper:GetValueFromScript(v)
            v = zargs[1]
            if Skill:getSkillEffect(v) == nil then
                isError = true
                table.insert(errArray, "效果 ")
                table.insert(errArray, v)
                table.insert(errArray, " 不存在, ")
            end
        else
            if Skill:getSkillEffect(v) == nil then
                isError = true
                table.insert(errArray, "效果 ")
                table.insert(errArray, v)
                table.insert(errArray, " 不存在, ")
            end
        end
    end
    return isError, table.concat(errArray, "")
end

local params = {}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 11:35:41
-- @desc 得到最终参数
function ActiveZhao:getValueWithCalc(value)
    -- 方法参数
    do
        params.min = math.min -- 取最小值
        params.max = math.max -- 取最大值
        params.abs = math.abs -- 绝对值
    end
    
    -- 拥有者属性参数
    do
        local owner = self:getOwner()
        
        local currInt = 1
        local currCon = 1
        local currStr = 1
        local currDex = 1
        local qimax = 1
        local neili = 1
        local neiliMax = 1
        
        if owner then
            currInt = owner:getFinalAttr("int") + owner:getFinalAttr("secInt")
            currCon = owner:getFinalAttr("con") + owner:getFinalAttr("secCon")
            currStr = owner:getFinalAttr("str") + owner:getFinalAttr("secStr")
            currDex = owner:getFinalAttr("dex") + owner:getFinalAttr("secDex")
            qimax = owner:getFinalAttr("qiMax")-- 气血最大值
            neili = owner:getAttr("neili")-- 内力
            neiliMax = owner:getAttr("neiliMax")-- 内力
        end
        
        params.currint = currInt -- 有效悟性
        params.currcon = currCon -- 有效根骨
        params.currstr = currStr -- 有效臂力
        params.currdex = currDex
        
        params.qimax = qimax -- 气血最大值
        params.neili = neili -- 内力
        params.neiliMax = neiliMax -- 内力最大值
    end
    
    local ret = Helper:GetValueFromScript(value, params)
    return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/14 23:12:12
-- @desc 得到最终的cost
function ActiveZhao:getFinalCost()
    if self.finalCost then
        return self.finalCost
    end
    self.finalCost = self:getValueWithCalc(self:getCost())
    return self.finalCost
end

-- 判断是否为切换武器的主动技能
function ActiveZhao:isChangeWeaponZhao()
    if self.__isChangeWeaponZhao == nil then
        local effects = self:getEffectArray()

        self.__isChangeWeaponZhao = false
        
        if MapIsEmpty(effects) == false then
            for k,v in pairs(effects) do
                if v and v:getType() == "武器切换" then
                    self.__isChangeWeaponZhao = true
                    break
                end
            end
        end
    end
    return self.__isChangeWeaponZhao
end

function ActiveZhao:refreshCD()
    local cdLeft = self:getCDLeft()
    if cdLeft <= 0 then
        cdLeft = 0
    elseif cdLeft > 0 then
        cdLeft = cdLeft - 1
    else
        print("cdLeft error")
        cdLeft = 0
    end
    self:setCDLeft(cdLeft)
end

return ActiveZhao
00000000
--[[
    该文件中方法用于取值，不可用于方法定义
    外部使用该类中的方法为 [xx.方法名] 后面不可接（）
    如果需要定义方法需使用app\models\skill\BaseSelfCreatedSkill.lua
]]

local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedZhaoOld = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhaoOld")
local BaseSelfCreatedSkill = require("app.models.skill.BaseSelfCreatedSkill")
local inherit = require("third.inherit.inherit")
local SelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SkillHelper = require("app.models.skill.SkillHelper")
local function log(...)
    print("SelfCreatedSkillOld:", ...)
end

local SelfCreatedSkillOld = {}

function SelfCreatedSkillOld:create(data, role)
    local p = {}
    p._role = role
    p._data = data
    p._newSkill = SelfCreatedSkill:create(data)
    setmetatable(p, {
        __index = function(tb, key)
            -- log(key)
            if SelfCreatedSkillOld[key] == nil then
                return nil
            end
            return SelfCreatedSkillOld[key](tb)
        end
    })

    return inherit({}, p, BaseSelfCreatedSkill)
end

local zhaosCache = {}
-- 获取招式数据
function SelfCreatedSkillOld:getZhaos()
    local retZhaos = zhaosCache[self]

    if retZhaos == nil then
        local zhaos = {}
        for i, zhaoData in ipairs(self._data.zhaos) do
            local zhao = SelfCreatedZhaoOld:create(zhaoData,self._newSkill)
            table.insert(zhaos, zhao)
        end

        retZhaos = zhaos
        zhaosCache[self] = retZhaos
    end

    return retZhaos
end

-- 武学编号
function SelfCreatedSkillOld:id()
    return SkillHelper:selfCreatedSkillDataIdToSkillId(self._role:getAttr("userid"), self._data.id)
end

-- 类型
function SelfCreatedSkillOld:type()
    return SKILL_TYPE_SELFCREATE
end

function SelfCreatedSkillOld:outputType()
    return self._newSkill:getOutputType()
end

function SelfCreatedSkillOld:unlocks()
    return self._newSkill:getUnlocks()
end

-- 武学名称
function SelfCreatedSkillOld:name()
    return "OLIVE" .. self._data.name .. "NOR"
end

function SelfCreatedSkillOld:_NoColorName()
    return self._data.name
end

-- 描述
function SelfCreatedSkillOld:dsc()
    local dsc = "HIW"..self._newSkill:getDsc().."NOR"
    local skillTypeName = self._newSkill:getSkillTypeName()
    local weaponTypeText = self._newSkill:getWeapontypeText()

    dsc = dsc.."\n \n可准备为:"..skillTypeName
    if type(weaponTypeText) == "string" then
        dsc = dsc.."\n需要装备:"..weaponTypeText
    end

    dsc = dsc.."\n心法要求:无"

    return dsc
end

-- 招架类型   已经无用
function SelfCreatedSkillOld:parryType()
    return self._newSkill:getParryType()
end

-- 师门
function SelfCreatedSkillOld:familyId()
    return
end

-- 师门列表
function SelfCreatedSkillOld:familyList()
    return self._newSkill:getFamilyList()
end

function SelfCreatedSkillOld:allEffectLv()
    return self._newSkill:getAllEffectLv()
end

-- 武器类型
function SelfCreatedSkillOld:weapontype()
    local weaponType = self._newSkill:getWeapontype()
    -- log("SelfCreatedSkillOld:weapontype():")
    -- for k, v in ipairs(weaponType) do
    --     log(k, v)
    -- end
    return weaponType
end

-- 准备方式
function SelfCreatedSkillOld:methods()
    -- log("SelfCreatedSkillOld:methods():")
    -- log("self._data.firstType", self._data.firstType)
    -- log("self._data.firstType", self._data.secondType)
    local method = self._newSkill:getMethods()

    -- log("method = ", method)
    assert(type(method) == "number", "method不等于数字, 异常!!")

    return { method }
end

-- 内力
function SelfCreatedSkillOld:neili()
    return 0
end

-- 闪避
function SelfCreatedSkillOld:dodge()
    return 0
end

-- 招架
function SelfCreatedSkillOld:parry()
    return 90
end

function SelfCreatedSkillOld:potEfficiency()
    local zhaoNum = #self._data.zhaos
    return SelfCreatedSkillManager:getConsumeZhaoRateMap(zhaoNum).potEfficiency
end

-- 伤害倍率
function SelfCreatedSkillOld:damRate()
    return SelfCreatedSkillManager:getParamsById("transform_damRate")
end

-- 攻击倍率
function SelfCreatedSkillOld:powerAtkRate()
    return SelfCreatedSkillManager:getParamsById("transform_powerAtkRate")
end

-- 攻击速度
function SelfCreatedSkillOld:atkSpd()
    return 0
end

-- 武学等级
function SelfCreatedSkillOld:wxlevel()
    return 1
end

function SelfCreatedSkillOld:wxclassify()
    local wxclassifyStr = self._newSkill:getWxclassify()
    local wxclassifyArray = {}
    local array = string.split(wxclassifyStr,",")
    for i,v in ipairs(array) do
        table.insert(wxclassifyArray, v)
    end
    return wxclassifyArray
end

-- 
function SelfCreatedSkillOld:levelScore()
    return 1
end

-- 站立动画
function SelfCreatedSkillOld:standAnim()
    return self._newSkill:getStandAnim()
end

-- 
function SelfCreatedSkillOld:jumpBackwardAnim()
    return self._newSkill:getJumpBackwardAnim()
end

-- 招式列表
function SelfCreatedSkillOld:zhaoList()
    local zhaoList = {}

    for i, zhaoData in ipairs(self._data.zhaos) do
        table.insert(zhaoList, zhaoData.templateId)
    end

    return zhaoList
    -- return {
    --     [1] = "shewu",
    --     [2] = "dangpo",
    -- }
end

-- 招架技能
function SelfCreatedSkillOld:parrySkills()
    return {
        [1] = {
            ["textColor"] = "默认",
            ["action"] = "$n躲开了$N的攻击",
            ["id"] = 1,
        },
    }
end

local autoSkillsCache = {}
function SelfCreatedSkillOld:autoSkills()
    local autoSkills = autoSkillsCache[self]

    if autoSkills == nil then
        autoSkills = self.autoZhaos
        local exp = self._data.exp
        if type(exp) == "number" and exp > 0 then
            local currSkillLv = Skill:getLv(exp)
            local allEffectLv = self.allEffectLv
            local baseZhaos = self.baseZhaos
            if currSkillLv < allEffectLv and MapIsEmpty(baseZhaos) == false then
                autoSkills = table.mergeArray(baseZhaos, autoSkills)
            end
        end
        autoSkillsCache[self] = autoSkills
    end
    return autoSkills
end

local autoZhaosCache = {}
function SelfCreatedSkillOld:autoZhaos()
    local autoZhaos = autoZhaosCache[self]

    if autoZhaos == nil then
        autoZhaos = self.getZhaos
        local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)
        for k, zhao in pairs(autoZhaos) do
            if #self.weapontype == 0 then
                -- 无需额外初始化
            else
                local anims = {}

                for i, anim in ipairs(zhao.anims) do
                    local tab = {}

                    for index, value in ipairs(self.weapontype) do
                        local weaponTypeNum = string.sub(value, -1)
                        local newAnimId = anim.anim .. weaponTypeNum

                        local newSkillanimParam = newSkillanim[newAnimId]
                        local hitPos = newSkillanimParam["location"]
                        local offset = newSkillanimParam["offset"]

                        tab[value] = {
                            anim = newAnimId,
                            hitPos = hitPos,
                            offset = offset,
                            speed = anim.speed
                        }
                    end
                    table.insert(anims, tab)
                end

                zhao.anims = anims
            end
        end

        table.sort(autoZhaos, function(a, b)
            if not a.lv then
                return false
            elseif not b.lv then
                return true
            elseif a.lv == b.lv then
                return a.id < b.id
            else
                return a.lv < b.lv
            end
        end)

        autoZhaosCache[self] = autoZhaos
    end
    return autoZhaos
end

local baseZhaosCache = {}
function SelfCreatedSkillOld:baseZhaos()
    local baseZhaos = baseZhaosCache[self]

    if baseZhaos == nil then
        baseZhaos = self._newSkill:getBaseZhaos()
        local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)
        for k, zhao in pairs(baseZhaos) do
            if #self.weapontype == 0 then
                -- 无需额外初始化
            else
                local anims = {}

                for i, anim in ipairs(zhao.anims) do
                    local tab = {}

                    for index, value in ipairs(self.weapontype) do
                        local weaponTypeNum = string.sub(value, -1)
                        local newAnimId = anim.anim .. weaponTypeNum

                        local newSkillanimParam = newSkillanim[newAnimId]
                        local hitPos = newSkillanimParam["location"]
                        local offset = newSkillanimParam["offset"]

                        tab[value] = {
                            anim = newAnimId,
                            hitPos = hitPos,
                            offset = offset,
                            speed = anim.speed
                        }
                    end
                    table.insert(anims, tab)
                end

                zhao.anims = anims
            end
        end

        table.sort(baseZhaos, function(a, b)
            if not a.lv then
                return false
            elseif not b.lv then
                return true
            elseif a.lv == b.lv then
                return a.id < b.id
            else
                return a.lv < b.lv
            end
        end)

        baseZhaosCache[self] = baseZhaos
    end
    return baseZhaos
end

--
function SelfCreatedSkillOld:multiEq()
    return self._newSkill:getMultiEq()
end

function SelfCreatedSkillOld:actionid()
    return self._newSkill:getActionid()
end

function SelfCreatedSkillOld:hitRate()
    return SelfCreatedSkillManager:getParamsById("transform_hitRate")
end

function SelfCreatedSkillOld:jumpForwardAnim()
    return self._newSkill:getJumpForwardAnim()
end

function SelfCreatedSkillOld:learn()
    local potEfficiency = SelfCreatedSkillManager:getConsumeZhaoRateMap(#self._data.zhaos).potEfficiency

    return {
        ["potEfficiency"] = potEfficiency,
    }
end

function SelfCreatedSkillOld:factors()
    return {
    ["neili"] = self.neili,
    ["atk"] = self.atk,
    ["powerAtkRate"] = self.powerAtkRate,
    ["HpRate"] = self.HpRate,
    ["dodge"] = self.dodge,
    ["powerDamRate"] = self.powerDamRate,
    ["atkSpd"] = self.atkSpd,
    ["def"] = self.def,
    ["hitRate"] = self.hitRate,
    ["parry"] = self.parry,
    }
end

function SelfCreatedSkillOld:def()
    return 87
end

function SelfCreatedSkillOld:atk()
    return SelfCreatedSkillManager:getParamsById("transform_atk")
end

function SelfCreatedSkillOld:HpRate()
    return -0
end

function SelfCreatedSkillOld:powerDamRate()
    return SelfCreatedSkillManager:getParamsById("transform_powerDamRate")
end

function SelfCreatedSkillOld:framenumber()
    return self._newSkill:getFramenumber()
end

function SelfCreatedSkillOld:useSkills()
    return {
    -- [1] = {
    --     ["name"] = "真武除邪",
    --     ["requirement"] = {
    --     }
    -- }
    }
end



-- function SelfCreatedSkillOld:Logic_1()
--     return "大于等于"
-- end
-- function SelfCreatedSkillOld:conditonValue_1()
--     return 400
-- end
-- function SelfCreatedSkillOld:conditionType_2()
--     return "属性"
-- end

-- function SelfCreatedSkillOld:conditionType_1()
--     return "技能"
-- end
-- function SelfCreatedSkillOld:conditonValue_2()
--     return 1000
-- end
-- function SelfCreatedSkillOld:ConditionId_2()
--     return "neiliMax"
-- end
-- function SelfCreatedSkillOld:Logic_1()
--     return "大于等于"
-- end
-- function SelfCreatedSkillOld:conditonValue_1()
--     return 400
-- end
-- function SelfCreatedSkillOld:conditionType_2()
--     return "属性"
-- end
-- function SelfCreatedSkillOld:ConditionId_3()
--     return "hamagong"
-- end
-- function SelfCreatedSkillOld:Logic_3()
--     return "大于等于"
-- end
-- function SelfCreatedSkillOld:Logic_2()
--     return "大于等于"
-- end
return SelfCreatedSkillOld000000000000
local NewClass = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local ISelfCreatedDsc = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.ISelfCreatedDsc")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local log = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end

local SelfCreatedDsc = {}

local indexConfig = {
    {
        rangeIndex = "atkRange",
        levelIndex = "atkLevel",
        dscIndex = "atkDsc"
    },
    {
        rangeIndex = "hitRange",
        levelIndex = "hitLevel",
        dscIndex = "hitDsc"
    },
    {
        rangeIndex = "defenseRange",
        levelIndex = "defenseLevel",
        dscIndex = "defenseDsc"
    },
    {
        rangeIndex = "parryRange",
        levelIndex = "parryLevel",
        dscIndex = "parryDsc"
    },
    {
        rangeIndex = "atkSpdRange",
        levelIndex = "atkSpdLevel",
        dscIndex = "atkSpdDsc"
    },
    {
        rangeIndex = "dodgeRange",
        levelIndex = "dodgeLevel",
        dscIndex = "dodgeDsc"
    },
    {
        rangeIndex = "hpRange",
        levelIndex = "hpLevel",
        dscIndex = "hpDsc"
    },
    {
        rangeIndex = "hfRange",
        levelIndex = "hfLevel",
        dscIndex = "hfDsc"
    },
}

local SkillDscMapByType = {}
local function loadSkillDscMap()
    local skillDscTemplates = require("script.selfCreatedSkill.skillDscTemplates")["武学描述"]

    for k, v in pairs(skillDscTemplates) do

        if SkillDscMapByType[v.type] == nil then
            SkillDscMapByType[v.type] = {}
        end
        table.insert(SkillDscMapByType[v.type], v)
    end
end
loadSkillDscMap()

function SelfCreatedDsc:create()
    local p = SelfCreatedDsc.new()
    return p
end

function SelfCreatedDsc:setSkill(skill)
    self._skill = skill
end


function SelfCreatedDsc:__getSkillDscMapByType(skillType)
    return SkillDscMapByType[skillType]
end

--[[
    武学描述为：
    XXX(武学名称)是XXX（玩家ID）所自创的一门剑法（当前武学类型）绝学 +
    分别属性描述（顺序为 攻击，命中，防御，招架，攻速，闪避，气血，回复，属性不为0，才显示对应描述）
]]
function SelfCreatedDsc:getSkillDsc()
    local skillName = self._skill:getName()
    local userName = User:getRole():getName()
    local skillTypeName = self._skill:getSkillTypeName()
    local dsc = skillName.."是"..userName.."所自创的一门"..skillTypeName.."绝学"
    
    local suffixDsc = self:__getSuffixDsc()

    return dsc..suffixDsc
end

function SelfCreatedDsc:__getSuffixDsc()
    local dsc = ""
    local attrArray = {
        self._skill:getAttack(),self._skill:getHit(),self._skill:getDefense(),self._skill:getParry(),
        self._skill:getAttackSpeed(),self._skill:getDodge(),self._skill:getBlood(),self._skill:getRecovery()
    } 

    local skillDscMap = self:__getSkillDscMapByType(self._skill:getThirdType())

    for i,config in ipairs(indexConfig) do
        local attrValue = attrArray[i]
        local rangeIndex = config.rangeIndex
        local levelIndex = config.levelIndex
        local dscIndex = config.dscIndex
        for k,v in pairs(skillDscMap) do
            local rangeStr = v[rangeIndex]
            local minValue = tonumber(string.split(rangeStr,";")[1])
            local maxValue = tonumber(string.split(rangeStr,";")[2])
            if attrValue ~= 0 and attrValue > minValue and attrValue <= maxValue then
                dsc = dsc.."，"..v[dscIndex]
                break
            end
        end
    end

    return dsc.."。"
end

function SelfCreatedDsc:getCreatingSkillDsc()
    local skillName = self._skill:getName()
    local userName = User:getRole():getName()
    local skillTypeName = self._skill:getSkillTypeName()
    local dsc = "这是"..userName.."正在自创的一门"..skillTypeName.."武学"

    local suffixDsc = self:__getSuffixDsc()

    return dsc..suffixDsc
end

function SelfCreatedDsc:getCreatedSkillDsc()
    local skillName = self._skill:getName()
    local userName = User:getRole():getName()
    local skillTypeName = self._skill:getSkillTypeName()
    local dsc = "这是"..userName.."所自创的一门"..skillTypeName.."武学"

    local suffixDsc = self:__getSuffixDsc()

    return dsc..suffixDsc
end

function SelfCreatedDsc:__getLevel(index,value)
    local level = ""
    local skillDscMap = self:__getSkillDscMapByType(self._skill:getThirdType())
    local config = indexConfig[index]
    local rangeIndex = config.rangeIndex
    local levelIndex = config.levelIndex

    log("------------武学属性打印--------------index = ",index,"value = ",value,"rangeIndex = ",rangeIndex,"levelIndex = ",levelIndex)

    for k,v in pairs(skillDscMap) do
        local rangeStr = v[rangeIndex]
        local minValue = tonumber(string.split(rangeStr,";")[1])
        local maxValue = tonumber(string.split(rangeStr,";")[2])
        if value > minValue and value <= maxValue then
            level = v[levelIndex]
            break
        end
    end
    return level
end

function SelfCreatedDsc:getAttackLevel()
    return self:__getLevel(1,self._skill:getAttack()) 
end

function SelfCreatedDsc:getHitLevel()
    return self:__getLevel(2,self._skill:getHit()) 
end

function SelfCreatedDsc:getDefenseLevel()
    return self:__getLevel(3,self._skill:getDefense()) 
end

function SelfCreatedDsc:getParryLevel()
    return self:__getLevel(4,self._skill:getParry()) 
end

function SelfCreatedDsc:getAttackSpeedLevel()
    return self:__getLevel(5,self._skill:getAttackSpeed()) 
end

function SelfCreatedDsc:getDodgeLevel()
    return self:__getLevel(6,self._skill:getDodge()) 
end

function SelfCreatedDsc:getBloodLevel()
    return self:__getLevel(7,self._skill:getBlood()) 
end

function SelfCreatedDsc:getRecoveryLevel()
    return self:__getLevel(8,self._skill:getRecovery()) 
end

return NewClass("SelfCreatedDsc", { ISelfCreatedDsc }, SelfCreatedDsc)0
local NewClass = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local ISelfCreatedZhaoDsc = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.ISelfCreatedZhaoDsc")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local ZhaosDscTemplates = require("script.selfCreatedSkill.zhaosDscTemplates")["Sheet1"]
local log = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end

local SelfCreatedZhaoDsc = {}

local indexConfig = {
    {
        rangeIndex = "attackRange",
        levelIndex = "attackText",
    },
    {
        rangeIndex = "hitRange",
        levelIndex = "hitText",
    },
    {
        rangeIndex = "topRange",
        levelIndex = "topText",
    },
    {
        rangeIndex = "nlRange",
        levelIndex = "nlText",
    },
    {
        rangeIndex = "tiliRange",
        levelIndex = "tiliText",
    },
    {
        rangeIndex = "dodgeRange",
        levelIndex = "dodgeText",
    },
    {
        rangeIndex = "atkSpeedRange",
        levelIndex = "atkSpeedText",
    },
    {
        rangeIndex = "defenseRange",
        levelIndex = "defenseText",
    },
    {
        rangeIndex = "parryRange",
        levelIndex = "parryText",
    },
    
    {
        rangeIndex = "hfRange",
        levelIndex = "hfText",
    },
    {
        rangeIndex = "hpRange",
        levelIndex = "hpText",
    },
    {
        rangeIndex = "attackAddRange",
        levelIndex = "attackAddText",
    },
    {
        rangeIndex = "hitAddRange",
        levelIndex = "hitAddText",
    },
    {
        rangeIndex = "parryAddRange",
        levelIndex = "parryAddText",
    },
    {
        rangeIndex = "defenseAddRange",
        levelIndex = "defenseAddText",
    },
    {
        rangeIndex = "dodgeAddRange",
        levelIndex = "dodgeAddText",
    },
    {
        rangeIndex = "atkSpeedAddRange",
        levelIndex = "atkSpeedAddText",
    },
    {
        rangeIndex = "hfAddRange",
        levelIndex = "hfAddText",
    },
    {
        rangeIndex = "hpAddRange",
        levelIndex = "hpAddText",
    },
}

function SelfCreatedZhaoDsc:create()
    local p = SelfCreatedZhaoDsc.new()
    return p
end

function SelfCreatedZhaoDsc:setZhao(zhao)
    self._zhao = zhao
end

function SelfCreatedZhaoDsc:__getLevel(index,value)
    local level = ""
    local config = indexConfig[index]

    local rangeIndex = config.rangeIndex
    local levelIndex = config.levelIndex
    
    log("------------招式属性打印--------------index = ",index,"value = ",value,"rangeIndex = ",rangeIndex,"levelIndex = ",levelIndex)
    
    for k,v in pairs(ZhaosDscTemplates) do
        local rangeStr = v[rangeIndex]
        if rangeStr then
            local minValue = tonumber(string.split(rangeStr,";")[1])
            local maxValue = tonumber(string.split(rangeStr,";")[2])
            
            if minValue and maxValue and value > minValue and value <= maxValue then
                level = v[levelIndex]
                break
            end
        end
    end
    return level
end

function SelfCreatedZhaoDsc:getAttackLevel()
    return self:__getLevel(1,self._zhao:getAttack()) 
end

function SelfCreatedZhaoDsc:getHitLevel()
    return self:__getLevel(2,self._zhao:getHit()) 
end

function SelfCreatedZhaoDsc:getTopLimitLevel()
    return self:__getLevel(3,self._zhao:getTopLimit()) 
end

function SelfCreatedZhaoDsc:getNeiLiLevel()
    return self:__getLevel(4,self._zhao:getNeiLi()) 
end

function SelfCreatedZhaoDsc:getSpiritLevel()
    return self:__getLevel(5,self._zhao:getSpirit()) 
end

function SelfCreatedZhaoDsc:getDodgeLevel()
    return self:__getLevel(6,self._zhao:getDodge()) 
end

function SelfCreatedZhaoDsc:getAttackSpeedLevel()
    return self:__getLevel(7,self._zhao:getAttackSpeed()) 
end

function SelfCreatedZhaoDsc:getDefenseLevel()
    return self:__getLevel(8,self._zhao:getDefense()) 
end

function SelfCreatedZhaoDsc:getParryLevel()
    return self:__getLevel(9,self._zhao:getParry()) 
end

function SelfCreatedZhaoDsc:getRecoveryLevel()
    return self:__getLevel(10,self._zhao:getRecovery()) 
end

function SelfCreatedZhaoDsc:getBloodLevel()
    return self:__getLevel(11,self._zhao:getBlood()) 
end

function SelfCreatedZhaoDsc:getAttackAddLevel()
    return self:__getLevel(12,self._zhao:getUniverseValue("attack")) 
end

function SelfCreatedZhaoDsc:getHitAddLevel()
    return self:__getLevel(13,self._zhao:getUniverseValue("hit")) 
end

function SelfCreatedZhaoDsc:getParryAddLevel()
    return self:__getLevel(14,self._zhao:getUniverseValue("parry")) 
end

function SelfCreatedZhaoDsc:getDefenseAddLevel()
    return self:__getLevel(15,self._zhao:getUniverseValue("defense")) 
end

function SelfCreatedZhaoDsc:getDodgeAddLevel()
    return self:__getLevel(16,self._zhao:getUniverseValue("dodge")) 
end

function SelfCreatedZhaoDsc:getSpeedAddLevel()
    return self:__getLevel(17,self._zhao:getUniverseValue("speed")) 
end

function SelfCreatedZhaoDsc:getRecoveryAddLevel()
    return self:__getLevel(18,self._zhao:getUniverseValue("recovery")) 
end

function SelfCreatedZhaoDsc:getBloodAddLevel()
    return self:__getLevel(19,self._zhao:getUniverseValue("blood")) 
end

return NewClass("SelfCreatedZhaoDsc", { ISelfCreatedZhaoDsc }, SelfCreatedZhaoDsc)00
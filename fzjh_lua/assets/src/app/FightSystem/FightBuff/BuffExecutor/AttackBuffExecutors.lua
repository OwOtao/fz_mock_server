--[[
    author:Seven
    time:2022-08-17 17:09:56
    desc: 攻击流程中处理buff效果需要独自处理的情况
]]
local newClass = require("third.class.NewClass")
local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local AttackBuffExecutors = {}

function AttackBuffExecutors:create()
    return AttackBuffExecutors.new()
end

function AttackBuffExecutors:ctor()
    self.__executors = {}

    self.__characterAttrChangeMap = {}
end

function AttackBuffExecutors:setSkillAttack(skillAttack)
    self.__skillAttack = skillAttack
end

function AttackBuffExecutors:getSkillAttack()
    return self.__skillAttack
end

function AttackBuffExecutors:addExecutor(buffExecutor)
    table.insert(self.__executors, buffExecutor)
end

function AttackBuffExecutors:addDoCharacterAttrChange(c_id, attrName, value)
    if self.__characterAttrChangeMap[c_id] == nil then
        self.__characterAttrChangeMap[c_id] = {}
    end

    if self.__characterAttrChangeMap[c_id][attrName] == nil then
        self.__characterAttrChangeMap[c_id][attrName] = 0
    end

    self.__characterAttrChangeMap[c_id][attrName] = self.__characterAttrChangeMap[c_id][attrName] + value
end

function AttackBuffExecutors:execute()
    if table.getn(self.__executors) <= 0 then
        return
    end

    for i = 1, table.getn(self.__executors) do
        --@RefType [src.app.FightSystem.FightBuff.BuffExecutor#BuffExecutor]
        local executor = self.__executors[i]

        executor:dispatch()

        executor:showAddSuccessText()

        executor:attackExecute(self)
    end

    self:__doCharacterAttrChange()

    --@RefType [src.app.FightSystem.Fight.Fight#Fight]
    local fight = self.__skillAttack:getFight()
    local characters = fight:getFightCharacters()

    for i, v in ipairs(characters) do
        v:updateBuffInfos()
        
        v:__updateAnimUIView()
        
        v:updateAnimQiShield()

        v:updateShadowEffect()

        if v:canDead() then
            v:changeState(CHARACTER_STATE.DEAD, nil)
        end
    end
end

function AttackBuffExecutors:__doCharacterAttrChange()
    if MapIsEmpty(self.__characterAttrChangeMap) then
        return
    end

    --@RefType [src.app.FightSystem.Fight.Fight#Fight]
    local fight = self.__skillAttack:getFight()
    

    for c_id, changeMap in pairs(self.__characterAttrChangeMap) do
        local character = fight:getFightCharacter(c_id)

        character:doChangeAttrMap(changeMap)

        for k, v in pairs(changeMap) do
            if k == "qi" and v < 0 then
                character:addUpSufferDamge(math.abs(v))
            end

            character:doEffectChangeAttrUpdateInfo(k, v)
        end
    end
end

return newClass("AttackBuffExecutors", {}, AttackBuffExecutors)
000000000000
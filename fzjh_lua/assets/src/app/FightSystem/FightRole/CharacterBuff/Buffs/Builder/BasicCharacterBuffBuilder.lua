--[[
    author:Seven
    time:2023-03-10 15:01:55
    desc: 角色buff构造器
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local BasicFightCharacterBuff = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff")

local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

local BasicCharacterBuffBuilder = {}

function BasicCharacterBuffBuilder:create()
    return BasicCharacterBuffBuilder.new()
end

function BasicCharacterBuffBuilder:ctor()
    self.__dyArgMap = {}
end

--@return: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
function BasicCharacterBuffBuilder:setCharacter(character)
    self.__character = character
    return self
end

--@return: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
function BasicCharacterBuffBuilder:setBuffCreator(buffCreator)
    self.__buffCreator = buffCreator
    return self
end

--@return: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
function BasicCharacterBuffBuilder:setFight(fight)
    self.__fight = fight
    return self
end

--@return: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
function BasicCharacterBuffBuilder:setBuffDynamicArgValue(attrName, value)
    self.__dyArgMap[attrName] = value
    return self
end

--@return: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
function BasicCharacterBuffBuilder:setBuffId(id)
    self.__buffId = id
    return self
end

--@desc: 构建buff对象
--@author:Seven
--@time:2023-11-30 15:32:41
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicCharacterBuffBuilder:build()
    if self.__buffId == nil then
        error("BasicCharacterBuffBuilder:build buff id 未设置")
    end

    if self.__fight == nil then
        error("BasicCharacterBuffBuilder:build fight 未设置")
    end

    if self.__character == nil then
        error("BasicCharacterBuffBuilder:build character 未设置")
    end

    local basicBuffClass = BuffConf:getBasicBuffClass(self.__buffId)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
    local buff = BasicFightCharacterBuff:create(basicBuffClass)

    buff:setOwner(self.__character)

    buff:setBuffCreator(self.__buffCreator)

    buff:setBuffContext(self.__fight)

    for k, v in pairs(self.__dyArgMap) do
        buff:setBuffDynamicArg(k, v)
    end

    local lives

    local resLives = basicBuffClass:getBuffLives()

    if type(resLives) == "string" then
        local live = buff:getBuffDynamicArg(resLives)
        if type(live) == "string" then
            local hurtDegree = ZhaoHurtDegreeFactory:createHurtDegreeGroup(live, self.__character)

            lives = hurtDegree:getHurtValue()
        elseif type(live) == "number" then
            lives = live
        else
            error("BasicCharacterBuffBuilder:build buff lives 动态参数类型错误 ： " .. tostring(live))
        end
    else
        lives = resLives
    end

    buff:setBuffLives(math.ceil(lives))

    return buff
end

return newClass("BasicCharacterBuffBuilder", {}, BasicCharacterBuffBuilder)
00000
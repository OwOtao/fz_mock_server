--[[
    author:Seven
    time:2022-11-30 20:16:52
    desc: 战斗用被动招式组合 
]]
local newClass = require("third.class.NewClass")

local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

local FightFormula = require("app.FightSystem.FightFormula")

local BasicFightAutoZhaoCombination = {}

function BasicFightAutoZhaoCombination:create(basicAutoZhaoComb, character, basicFightSkill)
    return BasicFightAutoZhaoCombination.new():__init(basicAutoZhaoComb, character, basicFightSkill)
end

function BasicFightAutoZhaoCombination:__init(basicAutoZhaoComb, character, basicFightSkill)
    if basicAutoZhaoComb == nil then
        error("BasicFightAutoZhaoCombination:__init 参数 basicAutoZhaoComb 不可为空")
    end

    if character == nil then
        error("BasicFightAutoZhaoCombination:__init 参数 character 不可为空")
    end

    --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoCombination#BasicAutoZhaoCombination]
    self.__basicAutoZhaoComb = basicAutoZhaoComb

    --@desc: 当前被动组合拥有者
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character

    --@RefType [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
    self.__basicFightSkill = basicFightSkill

    return self
end

function BasicFightAutoZhaoCombination:getCostTili()
    return FightFormula:calAutoAttackTiliCost(self:getTiliCost(), self.__character:getBuffMaxValue("autoTiliCorrectionFactor"), self.__character:getBuffAddAttr("autoTiliConst"))
end

function BasicFightAutoZhaoCombination:getCostNeili()
    return FightFormula:calAutoAttackNeiliCost(self.__character:getPlusPointBattle(), self.__character:getBuffMaxValue("autoNeiliCorrectionFactor"), self.__character:getBuffAddAttr("autoNeiliConst"))
end

--@desc: 是否满足释放被动招式
--@author:Seven
--@time:2023-02-27 20:10:15
--@return true | false
function BasicFightAutoZhaoCombination:releaseAreMet()
    return self.__character:getAttr("tili") >= self:getCostTili()
end

function BasicFightAutoZhaoCombination:getId()
    return self.__basicAutoZhaoComb:getId()
end

function BasicFightAutoZhaoCombination:getZhaoId()
    return tonumber(self.__basicAutoZhaoComb:getZhaoId())
end

function BasicFightAutoZhaoCombination:getCombName()
    return self.__basicAutoZhaoComb:getZhaoName()
end

function BasicFightAutoZhaoCombination:getLevel()
    return tonumber(self.__basicAutoZhaoComb:getLv())
end

--@desc: 出招文本
--@author:Seven
--@time:2021-05-15 10:58:55
function BasicFightAutoZhaoCombination:getActionText()
    return self.__basicAutoZhaoComb:getActionText()
end

--@desc: 伤害描述文本类型
--@author:Seven
--@time:2021-07-14 11:53:38
function BasicFightAutoZhaoCombination:getDamageType()
    return self.__basicAutoZhaoComb:getDamageType()
end

--@desc: 击中部位系列
--@author:Seven
--@time:2021-07-14 11:54:03
function BasicFightAutoZhaoCombination:getHurtPosClass()
    return self.__basicAutoZhaoComb:getHurtPosClass()
end

--@desc: 攻击性能
--@author:Seven
--@time:2021-05-15 10:58:35
function BasicFightAutoZhaoCombination:getAttack()
    return self.__basicAutoZhaoComb:getAttack()
end

--@desc: 命中性能
--@author:Seven
--@time:2021-05-15 10:58:44
function BasicFightAutoZhaoCombination:getHit()
    return self.__basicAutoZhaoComb:getHit()
end

--@desc: 伤害性能
--@author:Seven
--@time:2021-05-15 11:47:28
function BasicFightAutoZhaoCombination:getTopLimit()
    return self.__basicAutoZhaoComb:getTopLimit()
end

--@desc: 消耗体力
--@author:Seven
--@time:2021-05-15 11:47:37
function BasicFightAutoZhaoCombination:getTiliCost()
    return self.__basicAutoZhaoComb:getTiliCost()
end

function BasicFightAutoZhaoCombination:getAttackAverage()
    return self.__basicAutoZhaoComb:getAttackAverage()
end

--return 0 or skillDamageAttrConf配置对应id ，0 为不生效，使用时注意
function BasicFightAutoZhaoCombination:getAutoZhaoAtkDamageClass()
    return self.__basicFightSkill:getAutoZhaoAtkDamageClass()
end

--return 0 or skillDamageAttrConf配置对应id ，0 为不生效，使用时注意
function BasicFightAutoZhaoCombination:getZhaoJiaDefDamageClass()
    return self.__basicFightSkill:getZhaoJiaDefDamageClass()
end

function BasicFightAutoZhaoCombination:getZhaoJiaDefDamageParam()
    return self.__basicFightSkill:getZhaoJiaDefDamageParam()
end

function BasicFightAutoZhaoCombination:getAttackZhaoInfos()
    if self.__atkZhaoList == nil then
        self.__atkZhaoList = {}

        local ids = self.__basicAutoZhaoComb:getAtkList()

        for _, zhaoId in ipairs(ids) do
            local autoZhao = BasicSkillManager:getBasicSkillAutoZhaoInfo(zhaoId)

            table.insert(self.__atkZhaoList, autoZhao)
        end
    end

    return self.__atkZhaoList
end

--@desc: 获取攻击招式
--@author:Seven
--@time:2023-01-04 17:20:15
--@index: 第几招
--@return: [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
function BasicFightAutoZhaoCombination:getBasicZhaoInfo(index)
    if index <= 0 or index > self:getAttackCount() then
        error("BasicFightAutoZhaoCombination:getBasicZhaoInfo index 越界")
    end

    return self:getAttackZhaoInfos()[index]
end

--@desc: 该招式出招攻击次数
--@author:Seven
--@time:2021-05-15 11:10:55
function BasicFightAutoZhaoCombination:getAttackCount()
    return table.getn(self:getAttackZhaoInfos())
end

function BasicFightAutoZhaoCombination:__walkAttackZhaoInfos(func)
    if self:getAttackCount() <= 0 then
        return
    end

    for i, v in ipairs(self:getAttackZhaoInfos()) do
        func(i, v)
    end
end

--@desc: 获取招式组合伤害总权重
--@author:Seven
--@time:2021-06-25 20:27:39
function BasicFightAutoZhaoCombination:getCombAttackTotalWeight()
    local value = 0

    self:__walkAttackZhaoInfos(
        function(index, zhao)
            -- --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
            -- local zhao = zhao

            value = value + zhao:getHurtWeight()
        end
    )

    return value
end

return newClass("BasicFightAutoZhaoCombination", {}, BasicFightAutoZhaoCombination)
00000000000
local inherit = require("third.inherit.inherit")
local ICurrSkillInfoPresenterOutput = require("app.presenters.selfCreatedSkill.currSkillInfo.ICurrSkillInfoPresenterOutput")
local ICurrSkillInfoPresenterInput = require("app.presenters.selfCreatedSkill.currSkillInfo.ICurrSkillInfoPresenterInput")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local CurrSkillInfoPresenter = {}

function CurrSkillInfoPresenter:create(ICurrSkillInfoOutput,selfCreatedSkillSystem,skill)
    local p = inherit({}, CurrSkillInfoPresenter)
    p:init(ICurrSkillInfoOutput,selfCreatedSkillSystem,skill)
    return p
end

function CurrSkillInfoPresenter:init(ICurrSkillInfoOutput,selfCreatedSkillSystem,skill)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._skill = skill

    self._ICurrSkillInfoOutput = isImplement(ICurrSkillInfoOutput, ICurrSkillInfoPresenterOutput)
end


function CurrSkillInfoPresenter:showLayer()
    self:showTextSkillName()
    self:showTextSkillDsc()
    self:showTextPreSkillType()
    self:showTextEquipType()
    self:showTextActiveZhaoNum()
    self:showTextAutoZhaoNum()

    self:showTextStr1()
    self:showTextStr2()
    self:showTextStr3()
    self:showTextStr4()
    self:showTextStr5()
    self:showTextStr6()
    self:showTextStr7()
    self:showTextStr8()

    self:setButtonBack()
    
    self._ICurrSkillInfoOutput:setShowLayer()
end

function CurrSkillInfoPresenter:showTextSkillName()
    local skillTypeName = self._skill:getSkillTypeName()
    local text = "正在自创的"..skillTypeName.."武学"
    self._ICurrSkillInfoOutput:setTextSkillName(text)
end

function CurrSkillInfoPresenter:showTextSkillDsc()
    local text = self._skill:getCreatingSkillDsc()
    self._ICurrSkillInfoOutput:setTextSkillDsc(text)
end

function CurrSkillInfoPresenter:showTextPreSkillType()
    local skillTypeName = self._skill:getSkillTypeName()
    self._ICurrSkillInfoOutput:setTextPreSkillType("可准备为："..skillTypeName)
end

function CurrSkillInfoPresenter:showTextEquipType()
    local text = self._skill:getWeapontypeText()
    if text == 0 then
        text = ""
    else
        text = "需要装备："..text
    end
    self._ICurrSkillInfoOutput:setTextEquipType(text)
end

function CurrSkillInfoPresenter:showTextActiveZhaoNum()
    local text = 0
    self._ICurrSkillInfoOutput:setTextActiveZhaoNum(text)
end

function CurrSkillInfoPresenter:showTextAutoZhaoNum()
    local zhaosNum = self._skill:getZhaoNum()
    self._ICurrSkillInfoOutput:setTextAutoZhaoNum(zhaosNum)
end

function CurrSkillInfoPresenter:showTextStr1()
    local text = "【力道】"
    local level = self._skill:getAttackLevel()
    self._ICurrSkillInfoOutput:setTextStr1(text)
    self._ICurrSkillInfoOutput:setTextLevel1(level)
end

function CurrSkillInfoPresenter:showTextStr2()
    local text = "【命中】"
    local level = self._skill:getHitLevel()
    self._ICurrSkillInfoOutput:setTextStr2(text)
    self._ICurrSkillInfoOutput:setTextLevel2(level)
end

function CurrSkillInfoPresenter:showTextStr3()
    local text = "【防御】"
    local level = self._skill:getDefenseLevel()
    self._ICurrSkillInfoOutput:setTextStr3(text)
    self._ICurrSkillInfoOutput:setTextLevel3(level)
end

function CurrSkillInfoPresenter:showTextStr4()
    local text = "【格挡】"
    local level = self._skill:getParryLevel()
    self._ICurrSkillInfoOutput:setTextStr4(text)
    self._ICurrSkillInfoOutput:setTextLevel4(level)
end

function CurrSkillInfoPresenter:showTextStr5()
    local text = "【攻速】"
    local level = self._skill:getAttackSpeedLevel()
    self._ICurrSkillInfoOutput:setTextStr5(text)
    self._ICurrSkillInfoOutput:setTextLevel5(level)
end

function CurrSkillInfoPresenter:showTextStr6()
    local text = "【闪躲】"
    local level = self._skill:getDodgeLevel()
    self._ICurrSkillInfoOutput:setTextStr6(text)
    self._ICurrSkillInfoOutput:setTextLevel6(level)
end

function CurrSkillInfoPresenter:showTextStr7()
    local text = "【气血】"
    local level = self._skill:getBloodLevel()
    self._ICurrSkillInfoOutput:setTextStr7(text)
    self._ICurrSkillInfoOutput:setTextLevel7(level)
end

function CurrSkillInfoPresenter:showTextStr8()
    local text = "【回复】"
    local level = self._skill:getRecoveryLevel()
    self._ICurrSkillInfoOutput:setTextStr8(text)
    self._ICurrSkillInfoOutput:setTextLevel8(level)
end

function CurrSkillInfoPresenter:hideLayer()
    self._ICurrSkillInfoOutput:hideLayer()
end

function CurrSkillInfoPresenter:setButtonBack()
    self._ICurrSkillInfoOutput:setButtonBack(function()
        self:hideLayer()
    end)
end

isImplement(CurrSkillInfoPresenter, ICurrSkillInfoPresenterInput)
return CurrSkillInfoPresenter
000000000
--[[
    author:Seven
    time:2023-10-30 21:01:00
    desc: 添加buff后视图层处理事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterAddBuffsViewEvent = {}

function CharacterAddBuffsViewEvent:create(...)
    return CharacterAddBuffsViewEvent.new():__init(...)
end

--@desc:
--@author:Seven
--@time:2023-11-24 20:47:06
--@IBuffContext: [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
function CharacterAddBuffsViewEvent:__init(IBuffContext, fight)
    self.__changeMap = {}

    self.__popTexts = {}

    self.__printTexts = {}

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    --@RefType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultCount#EffectModifierResultCount]
    self.__effectModifierResultCount = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultCount"):create()

    IBuffContext:walkBuffEffcetHurts(
        function(effectHurt)
            self.__effectModifierResultCount:addModifierAttr(effectHurt)
        end
    )

    self:__initPopAndPrintText()

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterAddBuffsViewEvent:doViewEvent(mainView)
    for _, text in ipairs(self.__printTexts) do
        mainView:printText(text)
    end

    for id, list in pairs(self.__popTexts) do
        for _, pop_text in ipairs(list) do
            mainView:popHeadTextInAnimView(id, pop_text)
        end
    end
end

function CharacterAddBuffsViewEvent:__insertPopText(targetid, text)
    if self.__popTexts[targetid] == nil then
        self.__popTexts[targetid] = {}
    end

    table.insert(self.__popTexts[targetid], text)
end

function CharacterAddBuffsViewEvent:__initPopAndPrintText()
    self.__effectModifierResultCount:walkModifierCount(
        function(c_id, effectId, ownerId, attrName, value)
            local basicEffect = BuffConf:getBasicEffect(effectId)

            local popDesc = basicEffect:getActiveEffectRolePop()

            local owener = self.__fight:getCharacter(c_id)

            if popDesc ~= nil then
                --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
                local f_desc = FightDesc:create()

                f_desc:setBuffOwner(owener)

                f_desc:setBuffTarget(owener)

                f_desc:setBuffActualValue(math.abs(value))

                f_desc:setText(popDesc)

                self:__insertPopText(owener:getId(), f_desc:getString())
            end

            local printDesc = basicEffect:getActiveEffectDesc()

            if printDesc ~= nil then
                --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
                local f_desc = FightDesc:create()

                f_desc:setBuffOwner(owener)

                f_desc:setBuffTarget(owener)

                f_desc:setBuffActualValue(math.abs(value))

                f_desc:setText(printDesc)

                table.insert(self.__printTexts, f_desc:getString())
            end
        end
    )
end

return newClass("CharacterAddBuffsViewEvent", {IViewEvent}, CharacterAddBuffsViewEvent)
000000
local ActiveSkillInfoInBattlePresenters = class("ActiveSkillInfoInBattlePresenters", cc.Layer)

function ActiveSkillInfoInBattlePresenters:create()
    local p = ActiveSkillInfoInBattlePresenters:new()
    p:init()
    return p
end

function ActiveSkillInfoInBattlePresenters:init()
    --@RefType [ActiveSkillInfoForBattleUI]
    self.__UI = require("app.views.ui.SkillUI.ActiveSkillInfoForBattleUI"):create()

    self.__UI:addTo(self)
end

function ActiveSkillInfoInBattlePresenters:showLayer()
    self.__UI:setPanelBackFunc(
        function()
            self:hideLayer()
        end
    )

    self.__UI:setTextTitle2("使用条件")

    self.__UI:show()
end

function ActiveSkillInfoInBattlePresenters:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveSkillInfoInBattlePresenters",
        function(layer)
            self.__UI:hide()
        end
    )
end

function ActiveSkillInfoInBattlePresenters:setName(name)
    self.__UI:setTextName(name)
end

function ActiveSkillInfoInBattlePresenters:setLevel(lv)
    self.__UI:setTextLevel(lv .. "重")
end

function ActiveSkillInfoInBattlePresenters:setNeiliCost(value)
    self.__UI:setTextTitle1("内力消耗：" .. value)
end

function ActiveSkillInfoInBattlePresenters:setDesc(desc)
    self.__UI:setTextDesc(desc)
end

function ActiveSkillInfoInBattlePresenters:setConditionTexts(texts)
    self.__UI:removeAllConditionsList()

    if MapIsEmpty(texts) then
        return
    end

    for i, v in ipairs(texts) do
        self.__UI:addStringToListView(v)
    end
end

Helper:classDefNodeGetInstance(ActiveSkillInfoInBattlePresenters)
return ActiveSkillInfoInBattlePresenters
000000000000
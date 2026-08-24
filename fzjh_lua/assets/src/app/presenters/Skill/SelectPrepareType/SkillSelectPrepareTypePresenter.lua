local SkillSelectPrepareTypePresenter = class("SkillSelectPrepareTypePresenter", cc.Layer)

function SkillSelectPrepareTypePresenter:create()
    local p = SkillSelectPrepareTypePresenter:new()
    p:init()
    return p
end

function SkillSelectPrepareTypePresenter:init()
    self.__ui = require("app.views.ui.SkillUI.SkillSelectPrepareTypeUI"):create()
    self.__ui:addTo(self)
end

function SkillSelectPrepareTypePresenter:setCallback(func)
    self.__callback = func
end

function SkillSelectPrepareTypePresenter:setHideCallback(func)
    self.__hideCallback = func
end

function SkillSelectPrepareTypePresenter:showLayer(skill,prepareTypes)
    self.__skill = skill

    self.__prepareTypes = prepareTypes

    self:setTextDesc()

    self:setListView()

    self:setButtonCancel()

    self.__ui:showUI()
end

function SkillSelectPrepareTypePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "SkillSelectPrepareTypePresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function SkillSelectPrepareTypePresenter:setTextDesc()
    local prepareText = ""

    for i, v in ipairs(self.__prepareTypes) do
        if i == 1 then
            prepareText = v.name.."类型"
        else
            prepareText = prepareText.."和"..v.name.."类型"
        end
    end

    prepareText = "当前武学"..self.__skill._NoColorName.."可以设置为"..prepareText.."，请确认所需设置类型。"

    self.__ui:setTextDesc(prepareText)
end

function SkillSelectPrepareTypePresenter:setListView()
    local retArray = {}
    for i,prepareData in ipairs(self.__prepareTypes) do
        local tab = {
            name = prepareData.name,
            func = EMPTY_FUNC
        }

        tab["func"] = function()
            self:hideLayer()
            self.__callback(prepareData.prepareType)
        end
        table.insert(retArray, tab)
    end

    self.__ui:setListView(retArray)
end

function SkillSelectPrepareTypePresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        if self.__hideCallback then
            self.__hideCallback()
        end
        self:hideLayer()
    end)
end


Helper:classDefNodeGetInstance(SkillSelectPrepareTypePresenter)
return SkillSelectPrepareTypePresenter
00000000000
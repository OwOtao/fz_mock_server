local ArmorDescInfoPresenter = class("ArmorDescInfoPresenter", cc.Layer)

function ArmorDescInfoPresenter:create()
    local p = ArmorDescInfoPresenter:new()
    p:init()
    return p
end

function ArmorDescInfoPresenter:init()
    self._ui = require("app.views.ui.ItemDescInfoUI.ItemDescInfoUI"):create()

    self._ui:addTo(self)
end
--[[
    {
        name = ""， --名字
        protect = 0, --保护力
        score = 0,  --武藏评分
        desc = "",  --描述
    }
]]
function ArmorDescInfoPresenter:setData(data)
    self._data = data
end

function ArmorDescInfoPresenter:showLayer()
    self:initUI()
end

function ArmorDescInfoPresenter:initUI()
    if self._data.score then
        self._ui:setScoreVisible(true)
        self._ui:setScoreText(self._data.score)
    else
        self._ui:setScoreVisible(false)
    end

    self._ui:setNameText(self._data.name)
    self._ui:setDamageText("保护力+"..Helper:getDef(Helper:mathFloor(self._data.protect),0))
    self._ui:setDescText(self._data.desc)

    self._ui:setAttributeTextMaskVisible(true)
    self._ui:setHideButtonFunc(function()
        self:hideLayer()
    end)

    self._ui:show()
end

function ArmorDescInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ArmorDescInfoPresenter",
        function(layer)
            self._ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(ArmorDescInfoPresenter)

return ArmorDescInfoPresenter
0000000000000000
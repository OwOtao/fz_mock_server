local WeaponDescInfoPresenter = class("WeaponDescInfoPresenter", cc.Layer)

function WeaponDescInfoPresenter:create()
    local p = WeaponDescInfoPresenter:new()
    p:init()
    return p
end

function WeaponDescInfoPresenter:init()
    self._ui = require("app.views.ui.ItemDescInfoUI.ItemDescInfoUI"):create()

    self._ui:addTo(self)
end
--[[
    {
        name = ""， --名字
        damage = 0, --伤害力
        score = 0,  --武藏评分
        desc = "",  --描述
        attrs = {
           { 
                name = "【硬度】",
                state = "略显钝挫",
                desc = "硬度：一把武器的硬度决定了它击碎他人的武器的难易程度。",
                stateDesc = "略显钝挫：这件兵器有点粗糙。",
                valueDesc = "硬度值：50",
            }
        },
    }
]]
function WeaponDescInfoPresenter:setData(data)
    self._data = data
end

function WeaponDescInfoPresenter:showLayer()
    self:initUI()
end

function WeaponDescInfoPresenter:initUI()
    if self._data.score then
        self._ui:setScoreVisible(true)
        self._ui:setScoreText(self._data.score)
    else
        self._ui:setScoreVisible(false)
    end

    self._ui:setNameText(self._data.name)
    self._ui:setDamageText("伤害值+"..Helper:getDef(Helper:mathFloor(self._data.damage),0))
    self._ui:setDescText(self._data.desc)

    local attrInfos = self._data.attrs
    for i = 1, #attrInfos do
        self._ui:setAttributeText(i, attrInfos[i].name, attrInfos[i].state)
        self._ui:setAttributePanelFunc(i, function()
            self._ui:setTipsDesc_1Text(attrInfos[i].desc)
            self._ui:setTipsDesc_2Text(attrInfos[i].stateDesc)
            self._ui:setTipsDesc_3Text(attrInfos[i].valueDesc)
        end)
    end

    self._ui:setAttributeTextMaskVisible(false)
    self._ui:setHideButtonFunc(function()
        self:hideLayer()
    end)

    self._ui:show()
end

function WeaponDescInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "WeaponDescInfoPresenter",
        function(layer)
            self._ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(WeaponDescInfoPresenter)

return WeaponDescInfoPresenter
000
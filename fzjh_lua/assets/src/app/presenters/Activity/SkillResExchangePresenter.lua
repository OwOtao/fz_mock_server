local SkillResExchangePresenter = class("SkillResExchangePresenter", cc.Layer)

function SkillResExchangePresenter:create()
    local p = SkillResExchangePresenter:new()
    p:init()
    return p
end

function SkillResExchangePresenter:init()
    self._actionUI = require("app.views.layer.ActionLayer.QiXiFestival_2019.QiXiActionUI"):create()

    self._actionUI:addTo(self)

    local SkillResExchange = require("app.models.Action.SkillResExchange")

    self._interactor = SkillResExchange:create()

    self._actionUI:setButton1("关闭",
        function()
            self:hideLayer()
        end
    )
end

function SkillResExchangePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function SkillResExchangePresenter:setDsc(dsc)
    self._actionUI:setRichText(dsc)
end

function SkillResExchangePresenter:setTitle(title)
    self._actionUI:setTitleName(title)
end

function SkillResExchangePresenter:showLayer()
    self._interactor:init(function()
        self._actionUI:setHongDianVisible(self._interactor:getHongDianState())

        self._actionUI:setButton3("前往交易",
            function()
                self:goToMap()
            end
        )

        self._actionUI:show()
    end)
end

function SkillResExchangePresenter:goToMap()
    local role = User:getRole()
    local mapId, roomId = self._interactor:getMapIdAndRoomId()
    local map = Map:getMapById(mapId)
    local room= map:getRoomById(roomId)
    local text = "选择前往HIY"..map.name..room.name.."NOR的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）"
    local backClick = true
    local callfunc = function(result, failureState)
        if result == true then
            self:hideLayer()
        end
    end

    local JumpMapStylePrensenter = require("app.presenters.JumpMapStyle.JumpMapStylePrensenter"):create()
    JumpMapStylePrensenter:showLayer(role, mapId, roomId, text, backClick, callfunc)
end

function SkillResExchangePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "SkillResExchangePresenter",
        function(layer)
            self._actionUI:hide()
        end
    )
end

Helper:classDefNodeGetInstance(SkillResExchangePresenter)

return SkillResExchangePresenter
000000000000000
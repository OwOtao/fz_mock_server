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
    local item = Item:getOneItemByKey("dundifu")
    local skill = role:getSkill("wuxingdunfa")

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    local showStr="HIY"..map.name..room.name.."NOR"
    dialog:show("选择前往"..showStr.."的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）")
    dialog:setWeChatVisible(false)
    dialog:setButton1("自行前往", function()
        local jump_to_map_select = function()
            if MainControllLayer:getCurrLayer() == "MapLayer" then
                local mapLayer = MainControllLayer:getLayer("MapLayer")
                mapLayer:quit()
                mapLayer:setVisible(false)
            end

            MainControllLayer:pushLayer("SelectMapLayer")
            local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
            selectMapLayer:setMap(mapId)
            self:hideLayer()
        end

        local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
        if RoleTaskControllor:clickMapLayer(role, EMPTY_FUNC) == false then
            return
        else
            jump_to_map_select()
        end
    end)

    dialog:setButton2("用遁地符", function()
        if role:isMapCompleted(mapId) ~= true then
            PopText("当前副本未通关")
            return
        end

        item:useDunDiFu(role, mapId, roomId,function ()
            self:hideLayer()
        end,SKILL_ITEM_DUNDIFU_TYPE)
    end)

    if MapIsEmpty(skill) == false then
        dialog:setButton3("五行遁法", function()
            if role:isMapCompleted(mapId) ~= true then
                PopText("当前副本未通关")
                return
            end
            item:useDunDiFu(role, mapId, roomId, function(useResult)
                if useResult == false then 
                    dialog:setVisible(true)
                else
                    self:hideLayer()
                end
            end,SKILL_ITEM_TYPE)
        end)
    end
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
00000000000
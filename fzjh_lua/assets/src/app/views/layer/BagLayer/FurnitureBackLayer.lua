local FurnitureBackLayer = class("FurnitureBackLayer", require("app.views.layer.BagLayer.BaseItemDetailPanelLayer"))

--@RefType [app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

function FurnitureBackLayer:create()
    local p = FurnitureBackLayer:new()
    p:init()
    return p
end

function FurnitureBackLayer:init()
    local UI = require("Layer.AttrUI.FurnitureBackUI").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
end

function FurnitureBackLayer:hideLayer(anim)
    PopupLayerController:hideLayer(
        "FurnitureBackLayer",
        function(layer)
            layer:hide(anim)
        end
    )
end

function FurnitureBackLayer:showLayer(item, itemAttr)
    self.Panel.Text_Name:setColor(cc.c3b(208, 208, 208))
    self.Panel.Text_Name:setString(itemAttr.name)
    self.Panel.Text_Type:setString(itemAttr.showType)
    
    self.Panel.Text_Desc:setColor(cc.c3b(166, 166, 166))
    self.Panel.Text_Desc:setString(itemAttr:getDsc())

    self:setPlaceLocDesc(itemAttr)

    self:show()
end

--@desc 设置家具可放置地方的描述文本
function FurnitureBackLayer:setPlaceLocDesc(itemAttr)
    local loc_type_list = string.split(itemAttr.takelimit, ";")

    if MapIsEmpty(loc_type_list) then
        self.Panel.Text_Desc2:setString("")
        return
    end

    local text = "可放置于：\n"
    for _, room_type in pairs(loc_type_list) do
        local roomAttr = Helper:getDef(HomelandRoomUtil:getNormalRoomAttr(room_type),{})

        local name = ""
        if MapIsEmpty(roomAttr) == true then
            roomAttr = Helper:getDef(HomelandRoomUtil:getSpeciaRoomAttr(room_type),{})
            name = roomAttr.roomname
        else
            name = roomAttr.name
        end

        if name ~= nil then
            text = text .. name .. "、"
        end
    end

    text = string.sub(text, 1, -4)

    self.Panel.Text_Desc2:setString(text)
end

function FurnitureBackLayer:setLeftButtonVisible(bool)
    if bool == true then
        self.Panel.Btn_Left:setVisible(true)
    else
        self.Panel.Btn_Left:setVisible(false)
    end
end

--@TODO 2018-09-07 18:11:35 暂时开放按钮逻辑注册，后续由各个Panel自身控制按钮逻辑
function FurnitureBackLayer:setLeftButton(name, func)
    if name == nil and func == nil then
        return
    end

    func = func or EMPTY_FUNC

    name = name or "放仓\n入库"

    self.Panel.Btn_Left.Text_Name:setString(name)

    self.Panel.Btn_Left:releaseFunc(
        function()
            func()
        end
    )
end

function FurnitureBackLayer:setRightButtonVisible(bool)
    if bool == true then
        self.Panel.Btn_Right:setVisible(true)
    else
        self.Panel.Btn_Right:setVisible(false)
    end
end

function FurnitureBackLayer:setRightButton(name, func)
    if name == nil and func == nil then
        return
    end

    func = func or EMPTY_FUNC

    name = name or "安\n放"

    self.Panel.Btn_Right.Text_Name:setString(name)

    self.Panel.Btn_Right:releaseFunc(
        function()
            func()
        end
    )
end

Helper:classDefNodeGetInstance(FurnitureBackLayer)
return FurnitureBackLayer
000
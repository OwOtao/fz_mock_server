local FloorPlanLayer = class("FloorPlanLayer", LayerEx)

function FloorPlanLayer:create()
    local p = FloorPlanLayer:new()
    p:init()
    return p
end

function FloorPlanLayer:init()
    self._UI = require("Layer/HomelandUI/FloorPlanUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Button_OK:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self.Image_TitleBack:loadTexture("OtherImage/Fight/Scene/jiejianyan.png", 0)
    self.Image_TitleBack:setSize({width = 1080.0000, height = 340.0000})
end

function FloorPlanLayer:hideLayer()
    PopupLayerController:hideLayer(
        "FloorPlanLayer",
        function(layer)
            layer:hide()
        end
    )
end

function FloorPlanLayer:setTitleName(name)
    name = name or ""

    self.Text_Title:setTextColor({r = 197, g = 197, b = 197})

    self.Text_Title:setString(name)
end

function FloorPlanLayer:initViewLabel(floorPlan)
    local text = cc.Label:createWithTTF(floorPlan, Resource:getFontPath("default"), 32)

    text:enableOutline(cc.c4b(0, 0, 0, 1), 5)

    text:setAnchorPoint(cc.p(0.5, 0.5))

    text:setTag(10000)

    local box = text:getBoundingBox()

    -- Helper:print_lua_table(box)

    self.ScrollView_map:setInnerContainerSize({width = box.width + 200, height = box.height + 200})

    local innerSize = self.ScrollView_map:getInnerContainerSize()

    text:setPosition(cc.p(innerSize.width / 2 - 100, innerSize.height / 2))

    -- local rect = cc.rect(0,0,box.width,box.height)

    -- local draw = cc.DrawNode:create()

    -- draw:drawRect(cc.p(rect.x+rect.width,rect.y+rect.height), cc.p(rect.x,rect.y), cc.c4f(1,1,0,1))

    -- self.ScrollView_map:addChild(draw)

    return text
end

function FloorPlanLayer:showLayer(name, floorPlan)

    if name == nil or floorPlan == nil then
        self:hideLayer()
        return
    end

    self.ScrollView_map:removeChildByTag(10000)

    self:setTitleName(name)

    local textLabel = self:initViewLabel(floorPlan)

    self.ScrollView_map:addChild(textLabel)

    self:show()
end

Helper:classDefNodeGetInstance(FloorPlanLayer)
return FloorPlanLayer
00000000000000
--@SuperType [src.app.views.base.LayerEx#LayerEx]
local EnterDreamLayer = class("EnterDreamLayer", LayerEx)

function EnterDreamLayer:create()
    local p = EnterDreamLayer:new()
    p:init()
    return p
end

function EnterDreamLayer:init()
    self._round = require("Layer/DreamWorldUI/EnterDreamUI.lua").create()["root"]
    self._round:addTo(self)
    Helper:convertUIByParent(self)

    self.Text_Dsc:setString("香烟袅袅。。。。。。")

end

function EnterDreamLayer:hideLayer()
    PopupLayerController:hideLayer(
        "EnterDreamLayer",
        function(layer)
            self.Text_Ding:stopActionByName("scaleDing")
            layer:hide()
        end
    )
end

function EnterDreamLayer:showLayer(startFunc)
    self:setShowAndHideAnimType(2)
    self:setshowAndHideAnimDuration(0.5)
    self.Text_Ding:setScale(0.5)
    self:show(
        function()
            if startFunc then
                startFunc()
            end

            local scale1 = cc.ScaleBy:create(1.5, 3, 3)
            local scale2 = scale1:reverse()

            local action = cc.RepeatForever:create(cc.Sequence:create(scale1, scale2))

            self.Text_Ding:runActionWithName("scaleDing",action)
        end
    )
end

Helper:classDefNodeGetInstance(EnterDreamLayer)
return EnterDreamLayer
0000000000000
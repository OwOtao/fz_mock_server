local QiXiActionUI = require("app.views.layer.ActionLayer.QiXiFestival_2019.QiXiActionUI")

local QiXiMingShiGaoTuLayer = class("QiXiMingShiGaoTuLayer", LayerEx)

function QiXiMingShiGaoTuLayer:create()
    local p = QiXiMingShiGaoTuLayer:new()
    p:init()
    return p
end

function QiXiMingShiGaoTuLayer:init()
    --@RefType [src.app.views.layer.ActionLayer.QiXiFestival_2019.QiXiActionUI#QiXiActionUI]
	self._UI = QiXiActionUI:create()
	self._UI:addTo(self)

    self._UI:initRichText()

    self._UI:setButton("Button_2")
end

function QiXiMingShiGaoTuLayer:hideLayer()
    PopupLayerController:hideLayer("QiXiMingShiGaoTuLayer",function (layer)
        layer:hide()
    end)
end

function QiXiMingShiGaoTuLayer:showLayer(action)
    self._UI:setTitleName(action.name)
    local timeStartStr =Helper:getTimeStrCNFormat(action["start"])
    local timeEndStr = Helper:getTimeStrCNFormat(action["end"])

    local detail_desc_list = action.detail_desc

    local str = action.desc .. "\n \n"

    for i,desc in ipairs(detail_desc_list) do
        desc = string.gsub(desc,"#start#",timeStartStr)
        desc = string.gsub(desc,"#end#",timeEndStr)
        str = str .. desc .. "\n"
    end

    self._UI:setRichText(str)

    self._UI:setButton("Button_3","立即前往",function ()
        local role = User:getRole()
        if role:getLv() < 200 then
            PopText("你修为尚浅，师门任务暂不对你开放。")
            return
        end
        if not role:hasFamily() then
            PopText("要领取师门任务，请先加入任一门派。")
            return
        end
        PopupLayerController:showLayer("TeacherGuaJiTaskListLayer", function(layer)
            layer:showLayer()
        end)
    end)
    self._UI:setButton("Button_1","关闭",function ()
        self:hideLayer()
    end)

    self:show()
end

Helper:classDefNodeGetInstance(QiXiMingShiGaoTuLayer)
return  QiXiMingShiGaoTuLayer0000000000000000
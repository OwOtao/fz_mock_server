--@SuperType [app.views.base.LayerEx#LayerEx]
local QiXiLikeLayer = class("QiXiLikeLayer", LayerEx)

--@RefType [app.models.Action.ChineseValentine.2018.QiXiUtil#QiXiUtil]
local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")

function QiXiLikeLayer:create()
    local p = QiXiLikeLayer:new()
    p:init()
    return p
end


function QiXiLikeLayer:initRichText(index)
	if self.Panel_1["RichText_print"..index] then
        self.Panel_1["RichText_print"..index]:removeFromParent()
        self.Panel_1["RichText_print"..index] = nil
	end
	
	local x, y = self.Panel_1["Text_"..index]:getPosition()
	local size = self.Panel_1["Text_"..index]:getContentSize()
	
	self.Panel_1["RichText_print"..index] = ExtRichTextScroll:create()
	self.Panel_1["Text_"..index]:getParent():addChild(self.Panel_1["RichText_print"..index])
	self.Panel_1["RichText_print"..index]:setTouchEnabled(false)
	self.Panel_1["RichText_print"..index]:setAnchorPoint(0,0.5)
    self.Panel_1["RichText_print"..index]:move(cc.p(x, y))
    self.Panel_1["RichText_print"..index]:setSize(size)
    self.Panel_1["RichText_print"..index]:setDirection(kCCScrollViewDirectionVertical)
    self.Panel_1["RichText_print"..index]:getRichText():setVerticalSpace(5)
end


local textColor = cc.c3b(208, 208, 208)
function QiXiLikeLayer:printRichText( index,desc )
    self:initRichText(index)
    self.Panel_1["RichText_print"..index]:pushBackText(desc, textColor, 255, Resource:getFontPath("default"), 42)
end


function QiXiLikeLayer:init()
    self._UI = require("Layer/ActionUI/QIXI2018/QiXiLikeUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:setShowAndHideAnimType("ROLL")

    self:setBtnAndBack()

    for i=1,7 do
        -- self:initRichText(i)
        self.Panel_1["Text_"..i]:setVisible(false)
    end
end

function QiXiLikeLayer:showLayer(npc)
    self._npc = npc
    self:setTitle()
    self:setDesc()
    self:show()
end


function QiXiLikeLayer:setTitle()
    local text = "这是"..self._npc.name.."内心的想法："

    self.Panel_1.Text_Title:setString(text)
end


function QiXiLikeLayer:setDesc()
    local list = QiXiUtil:getLikeInfoDescList(self._npc)

    for i=1,7 do
        local text = list[i]

        if text == nil then
            self.Panel_1["Text_"..i]:setVisible(false)
            if self.Panel_1["RichText_print"..i] ~= nil then
                self.Panel_1["RichText_print"..i]:setVisible(false)
            end
        else
            -- self.Panel_1["Text_"..i]:setVisible(true)
            -- self.Panel_1["Text_"..i]:setString(text)

            self:printRichText(i,text)
        end
    end

end


function QiXiLikeLayer:hideLayer()
    PopupLayerController:hideLayer(
        "QiXiLikeLayer",
        function(layer)
            layer:hide()
        end
    )
end

function QiXiLikeLayer:setBtnAndBack()
    self.Panel_1.Button_1:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(QiXiLikeLayer)
return QiXiLikeLayer
0
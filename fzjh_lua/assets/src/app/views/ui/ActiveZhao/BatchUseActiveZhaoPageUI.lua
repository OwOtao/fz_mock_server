local BatchUseActiveZhaoPageUI = class("BatchUseActiveZhaoPageUI", LayerEx)

function BatchUseActiveZhaoPageUI:create()
    local p = BatchUseActiveZhaoPageUI:new()
    p:init()
    return p
end

function BatchUseActiveZhaoPageUI:init()
    self.__ui = require("Layer.GongfuPage.BatchUsePageUI").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function BatchUseActiveZhaoPageUI:showUI()
    self:show()
end

function BatchUseActiveZhaoPageUI:hideUI()
    self:hide()
end

function BatchUseActiveZhaoPageUI:setTextTitle(title)
    self.Text_title:setString(title)
end

function BatchUseActiveZhaoPageUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function BatchUseActiveZhaoPageUI:setTextInfo1(text)
    self.Text_info1:setString(text)
end

function BatchUseActiveZhaoPageUI:setTextInfo2(text)
    self.Text_info2:setString(text)
end

function BatchUseActiveZhaoPageUI:setTextInfo3(text)
    self.Text_info3:setString(text)
end

function BatchUseActiveZhaoPageUI:setTextSelectNum(text)
    self.Panel_select.Text_select:setString(text)
end

function BatchUseActiveZhaoPageUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(
        function()
            func()
        end
    )
end

function BatchUseActiveZhaoPageUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(
        function()
            func()
        end
    )
end

function BatchUseActiveZhaoPageUI:setButton(buttonIndex,data)
	local buttonName = "Button"..buttonIndex

	local button = self.Panel_select[buttonName]

	if button then
		button:loadTextureNormal(data["image"])
		button:setTitleText(data["title"])
		button:setTitleColor(data["titleColor"])
		button:releaseFuncTotally(function()
			data["beganFunc"]()
		end,function()
			data["endedFunc"]()
		end,function()
			data["canceledFunc"]()
		end)
	end
end

function BatchUseActiveZhaoPageUI:setTextTip(text)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(text)
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

return BatchUseActiveZhaoPageUI
0000000000000
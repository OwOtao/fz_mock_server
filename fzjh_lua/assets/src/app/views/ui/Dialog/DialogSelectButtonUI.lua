local DialogSelectButtonUI = class("DialogSelectButtonUI", LayerEx)

function DialogSelectButtonUI:create()
	local p = DialogSelectButtonUI:new()
	p:init()
	return p
end

function DialogSelectButtonUI:init()
    self.__ui = require("Layer/Dialog/DialogSelectButtonUI.lua").create()['root']
    self.__ui:addTo(self)
    Helper:convertUIByParent(self)
end

function DialogSelectButtonUI:show()
    self:setVisible(true)
end

function DialogSelectButtonUI:hide()
	self:setVisible(false)
end

function DialogSelectButtonUI:setTextDesc(text)
    self.Text_text:setString(text)
end

function DialogSelectButtonUI:setLoadingBarPercent(percent)
    self.LoadingBar:setPercent(percent)
end

function DialogSelectButtonUI:setButtonListView(array)
    self.ListView_1:removeAllItems()
    if MapIsEmpty(array) == false then
        local panelCount = math.ceil(#array / 2)
        for i = 1,panelCount do
            local panel = self.Panel_List:clone()

            Helper:convertUIByParent(panel)

            for _i = 1,2 do
                local index = (i-1)*2 + _i
                local panalData = array[index]
                if panalData then
                    if _i == 1 then
                        panel.Button_Left.Text_name:setString(panalData.name)
                        panel.Button_Left:releaseFunc(function()
                            panalData.func()
                        end)
                    else
                        panel.Button_Right.Text_name:setString(panalData.name)
                        panel.Button_Right:releaseFunc(function()
                            panalData.func()
                        end)
                    end
                else
                    panel.Button_Right:setVisible(false)
                end
            end

            self.ListView_1:pushBackCustomItem(panel)
        end
    end
end

return DialogSelectButtonUI000
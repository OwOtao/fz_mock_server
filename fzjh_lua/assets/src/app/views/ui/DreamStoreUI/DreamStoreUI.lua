local DreamStoreUI = class("DreamStoreUI", LayerEx)

function DreamStoreUI:create()
	local p = DreamStoreUI:new()
	p:init()
	return p
end

function DreamStoreUI:init()
    self._UI = require("Layer/DreamWorldUI/DreamStoreUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setVisible(false)
end

function DreamStoreUI:showUI()
    self:show()
end

function DreamStoreUI:hideUI()
    self:hide()
end

function DreamStoreUI:setButtonBack(func)
    self.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end
    )
end

function DreamStoreUI:setButtonClose(func)
    self.Button_close:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function DreamStoreUI:setTextTital(text)
    self.Text_tital:setString(text)
end

function DreamStoreUI:setTextDsc(text)
    self.Text_dsc:setString(text)
end

function DreamStoreUI:setTextTime(text)
    self.Text_time:setString(text)
end

function DreamStoreUI:setTextPoint(text)
    self.Text_point:setString(text)
end

function DreamStoreUI:setListView(array)
    self.ListView_item:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self.Panel_item:clone()
        Helper:convertUIByParent(panel)

        panel.Image_1:loadTexture(v["itemImage"],0)
        panel.Text_name:setString(v["name"])
        panel.Text_condition:setString(v["condition"])
        panel.Text_num:setString(v["num"])
        panel.Button_1:loadTextureNormal(v["buttonImage"],0)
        panel.Button_1.Text_buttonName:setString(v["buttonName"])
        panel.Button_1:releaseFunc(function()
            if v["func"] then
                v["func"]()
            end
        end)

        self.ListView_item:pushBackCustomItem(panel)
    end
end

function DreamStoreUI:refreshOneItem(index,data)
    local panel = self.ListView_item:getItem(index - 1)
    if not panel then
        return
    end
    panel.Image_1:loadTexture(data["itemImage"],0)
    panel.Text_num:setString(data["num"])
    panel.Button_1.Text_buttonName:setString(data["buttonName"])
    panel.Button_1:loadTextureNormal(data["buttonImage"],0)
    panel.Button_1:releaseFunc(function()
        if data["func"] then
            data["func"]()
        end
    end)
end

function DreamStoreUI:popText(text)
    PopText(text)
end

return DreamStoreUI00000000000000
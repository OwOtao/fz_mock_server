local CharacterInfoUI = class("CharacterInfoUI", LayerEx)

function CharacterInfoUI:create()
	local p = CharacterInfoUI:new()
	p:init()
	return p
end

function CharacterInfoUI:init()
    self._round = require("Layer/FistFootUI/CharacterInfoUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function CharacterInfoUI:setListViewCharacter(array)
    self.Panel_1.ListView_1:removeAllItems()
    local mod, remainder = math.modf(#array/3)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    for i = 1,mod do
        local panelItem = self.Panel_item:clone()
        Helper:convertUIByParent(panelItem)

        for index = 1,3 do
            local panelCharacter = panelItem["Panel_character"..index]
            local data = array[(i - 1 ) * 3 + index]
            if data then
                panelCharacter:setVisible(true)
                panelCharacter.Image_di:setVisible(data.imageVisible)
                panelCharacter.Text_name:setString(data.name)
                panelCharacter.Text_name:setTextColor(data.color)
                panelCharacter:releaseFunc(function()
                    if data.func then
                        data.func()
                    end
                end)
            else
                panelCharacter:setVisible(false)
            end
        end

        self.Panel_1.ListView_1:pushBackCustomItem(panelItem)
    end
    
    self.Panel_1.ListView_1:jumpToTop()
end

function CharacterInfoUI:setPanel2(data)
    local panel = self.Panel_2
        panel.Text_name:setString(data.name)
        panel.Text_levelNum:setString(data.level)
        panel.Text_desc:setString(data.desc)
        panel.Text_condition:setString(data.condition)
end

return CharacterInfoUI0000000000000000
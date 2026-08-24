local MenKeDaiDaLayer = class("MenKeDaiDaLayer", LayerEx)

function MenKeDaiDaLayer:create()
	local p = MenKeDaiDaLayer:new()
	p:init()
	return p
end

function MenKeDaiDaLayer:init()
	local UI = require("Layer/HomelandUI/MenKeDaiDaUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self.Panel_back:releaseFunc(function()
        self:hide()
    end)
end

function MenKeDaiDaLayer:showLayer()

    self:show()
end

function MenKeDaiDaLayer:setTextTitle(title)
    self.Text_title:setString(title)
end

function MenKeDaiDaLayer:setDesc(desc)
    self.Text_1:setString(desc)
end

function MenKeDaiDaLayer:setListView(array,func)
    self.ListView_1:removeAllItems()
    if MapIsEmpty(array) then
        return 
    end

    for i,v in ipairs(array) do
        local button = self.Button_1:clone()
        Helper:convertUIByParent(button)
        local name = v.realName or v.name 
        button.Text_buttonName:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
        button.Text_buttonName:setString(name)

        button:releaseFunc(function()
            if func then
                func(v.id)
            end
        end)
        self.ListView_1:pushBackCustomItem(button)
    end

end

Helper:classDefNodeGetInstance(MenKeDaiDaLayer)

return MenKeDaiDaLayer00000000000
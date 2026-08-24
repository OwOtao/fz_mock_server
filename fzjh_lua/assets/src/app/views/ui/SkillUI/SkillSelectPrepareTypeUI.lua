local SkillSelectPrepareTypeUI = class("SkillSelectPrepareTypeUI", LayerEx)

function SkillSelectPrepareTypeUI:create()
	local p = SkillSelectPrepareTypeUI:new()
	p:init()
	return p
end

function SkillSelectPrepareTypeUI:init()
    self._round = require("Layer/SkillUI/SkillSelectPrepareTypeUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillSelectPrepareTypeUI:showUI()
    self:setVisible(true)
end

function SkillSelectPrepareTypeUI:hideUI()
    self:setVisible(false)
end

function SkillSelectPrepareTypeUI:setTextDesc(text)
    self.Text_Desc:setString(text)
end

function SkillSelectPrepareTypeUI:setListView(array)
    self.ListView_prepare:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createButton(v) 
        self.ListView_prepare:pushBackCustomItem(panel)
    end
end

function SkillSelectPrepareTypeUI:_createButton(data)
    local button = self.Button_1:clone()
    Helper:convertUIByParent(button)

    button.Text_name:setString(data["name"])
    button:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return button
end

function SkillSelectPrepareTypeUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end


return SkillSelectPrepareTypeUI0
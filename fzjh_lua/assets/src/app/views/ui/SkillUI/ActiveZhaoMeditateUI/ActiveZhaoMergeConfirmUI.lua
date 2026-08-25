local ActiveZhaoMergeConfirmUI = class("ActiveZhaoMergeConfirmUI", LayerEx)

function ActiveZhaoMergeConfirmUI:create()
	local p = ActiveZhaoMergeConfirmUI:new()
	p:init()
	return p
end

function ActiveZhaoMergeConfirmUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoMergeConfirmUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoMergeConfirmUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoMergeConfirmUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoMergeConfirmUI:setTextDsc(text)
	self.Text_dsc:setString(text)
end

function ActiveZhaoMergeConfirmUI:setListView(array)
    if MapIsEmpty(array) then
        self.ListView_1:removeAllItems()
        return 
    end

	local isJumpToTop = false
	if #self.ListView_1:getItems() == 0 then
		isJumpToTop = true
	end

    for i =1,#array do
        local panel = self.ListView_1:getItem(i - 1)
        if panel == nil then
            panel = self:__createPanelItem()
            self.ListView_1:pushBackCustomItem(panel)
        end
		self:__initPanelItem(panel,array[i])
    end

    for i = #array + 1, #self.ListView_1:getItems() do
        self.ListView_1:removeLastItem()
    end

	if isJumpToTop then
		self:skillListViewJumpToTop()
	end
end

function ActiveZhaoMergeConfirmUI:skillListViewJumpToTop()
	self.ListView_1:jumpToTop()
end

function ActiveZhaoMergeConfirmUI:__createPanelItem()
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function ActiveZhaoMergeConfirmUI:__initPanelItem(item,data)
    item.Text_name:setString(data.name)
    item.Text_num:setString(data.num)
end

function ActiveZhaoMergeConfirmUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMergeConfirmUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMergeConfirmUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoMergeConfirmUI000000000000
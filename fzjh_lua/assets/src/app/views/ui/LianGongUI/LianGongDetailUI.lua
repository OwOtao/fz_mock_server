local LianGongDetailUI = class("LianGongDetailUI", LayerEx)

function LianGongDetailUI:create()
	local p = LianGongDetailUI:new()
	p:init()
	return p
end

function LianGongDetailUI:init()
    self._UI = require("Layer/LianGongUI/LianGongInfoUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function LianGongDetailUI:showUI()
    self:setVisible(true)
end

function LianGongDetailUI:hideUI()
    self:setVisible(false)
end

function LianGongDetailUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function LianGongDetailUI:setTextXinShenNum(text)
    self.Text_xinshenNum:setString(text)
end

function LianGongDetailUI:setTextTiLiNum(text)
    self.Text_tiliNum:setString(text)
end

function LianGongDetailUI:setTextTip(text)
    self.Image_kuang.Text_tip:setString(text)
end

function LianGongDetailUI:setTextSpillExpDsc(text)
    self.Text_spillExpDsc:setString(text)
end

function LianGongDetailUI:setListView(array)
    for i,v in ipairs(array) do
        local panel = self.Image_kuang.ListView_list:getItem(i - 1)
        if panel == nil then
            panel = self.Panel_row:clone()
            self.Image_kuang.ListView_list:pushBackCustomItem(panel)
        end

        Helper:convertUIByParent(panel)

        panel.Text_title:setString(v["title"])
        panel.Text_num:setString(v["content"])
    end

    for i = #array + 1, #self.Image_kuang.ListView_list:getItems() do
		self.Image_kuang.ListView_list:removeLastItem()
	end
end

function LianGongDetailUI:setButton1(name,func)
    if name == nil then
        self.Button_1:setVisible(false)
        return
    end
    self.Button_1:setVisible(true)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function LianGongDetailUI:setButton2(name,func)
    if name == nil then
        self.Button_2:setVisible(false)
        return
    end
    self.Button_2:setVisible(true)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function LianGongDetailUI:setButton3(name,func)
    if name == nil then
        self.Button_3:setVisible(false)
        return
    end
    self.Button_3:setVisible(true)
    self.Button_3.Text_ButtonName:setString(name)
    self.Button_3:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return LianGongDetailUI00000000000
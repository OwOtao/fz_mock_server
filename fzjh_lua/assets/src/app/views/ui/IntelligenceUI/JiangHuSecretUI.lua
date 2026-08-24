local JiangHuSecretUI = class("JiangHuSecretUI", LayerEx)
local IJiangHuSecretOutput = require("app.presenters.intelligence.jianghuSecret.IJiangHuSecretOutput")
local IJiangHuSecretInput = require("app.presenters.intelligence.jianghuSecret.IJiangHuSecretInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function JiangHuSecretUI:create()
	local p = JiangHuSecretUI:new()
	p:init()
	return p
end

function JiangHuSecretUI:init()
    self._round = require("Layer/IntelligenceUI/SecretUI.lua").create()['root']
    self._round:addTo(self)
    Helper:convertUIByParent(self)
end

function JiangHuSecretUI:showLayer(presenter)
    self._Input = isImplement(presenter, IJiangHuSecretInput)

    self.ListView_1:setTouchEnabled(false)
    self.ListView_1:setScrollBarEnabled(false)
    self._Input:showLayer()
end

function JiangHuSecretUI:setShowLayer()
    self:show()
end

function JiangHuSecretUI:setTextNum(text)
	self.Text_num:setString(text)
end

function JiangHuSecretUI:setTextPageNum(text)
	self.Text_pageNum:setString(text)
end

function JiangHuSecretUI:setNotSecretVisible(boolean)
	self.Text_notSecret:setVisible(boolean)
end

function JiangHuSecretUI:setUpPageButtonEnabled(boolean)
    self.Button_upPage:setEnabled(boolean)
end

function JiangHuSecretUI:setDownPageButtonEnabled(boolean)
    self.Button_downPage:setEnabled(boolean)
end

function JiangHuSecretUI:setUpPageButton(func)
	self.Button_upPage:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function JiangHuSecretUI:setDownPageButton(func)
	self.Button_downPage:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function JiangHuSecretUI:setBackButton(func)
	self.Image_title.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function JiangHuSecretUI:setListView(array)
    self.ListView_1:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createPanel(v) 
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function JiangHuSecretUI:_createPanel(data)
    local panel = self.Panel_intelligence:clone()
    Helper:convertUIByParent(panel)

    panel.Text_isNew:setVisible(data["new_isVisible"])
    panel.Text_name:setString(data["name"])
    panel:releaseFunc(function()
		if data["func"] then
			data["func"](panel.Text_isNew)
		end
    end)
    
    return panel
end

function JiangHuSecretUI:hideLayer()
    PopupLayerController:hideLayer("JiangHuSecretUI",function(layer)
        layer:hide()
    end)
end

isImplement(JiangHuSecretUI,IJiangHuSecretOutput)
Helper:classDefNodeGetInstance(JiangHuSecretUI)
return JiangHuSecretUI0000
local ZhaoSelectDscUI = class("ZhaoSelectDscUI", LayerEx)
local ZhaoSelectDscPresenter = require("app.presenters.selfCreatedSkill.zhaoSelectDsc.ZhaoSelectDscPresenter")
local IZhaoSelectDscPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoSelectDsc.IZhaoSelectDscPresenterOutput")
local IZhaoSelectDscPresenterInput = require("app.presenters.selfCreatedSkill.zhaoSelectDsc.IZhaoSelectDscPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function ZhaoSelectDscUI:create()
	local p = ZhaoSelectDscUI:new()
	p:init()
	return p
end

function ZhaoSelectDscUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/zhaoSelectDscUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ZhaoSelectDscUI:showLayer(selfCreatedSkillSystem,zhaoDscId,zhao,dscList,callback)
    self._IZhaoSelectDscPresenterInput = isImplement(ZhaoSelectDscPresenter:create(self,selfCreatedSkillSystem,zhaoDscId,zhao,dscList,callback), IZhaoSelectDscPresenterInput)

    self._IZhaoSelectDscPresenterInput:showLayer()
end

function ZhaoSelectDscUI:setShowLayer()
    self:show()
end


-- @desc 设置招式列表
function ZhaoSelectDscUI:setShowZhaoDscListView(zhaoDscArray)
    self.ListView_1:removeAllItems()
    for i,zhaoDsc in ipairs(zhaoDscArray) do
        local panel = self.Panel_zhaoDsc:clone()

        self.ListView_1:pushBackCustomItem(panel)
        
        Helper:convertUIByParent(panel)

        self:__setPanelZhaoDsc(panel,zhaoDsc)

    end
end

function ZhaoSelectDscUI:setBackButton(func)
	self.Image_title.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ZhaoSelectDscUI:__setPanelZhaoDsc(panel,zhaoDsc)
    panel.Text_3:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    panel.Text_3:setString(zhaoDsc.dsc)
    panel.Image_2:setVisible(zhaoDsc.Image2IsVisible)
    panel.Image_1:setVisible(zhaoDsc.Image1IsVisible)
    panel.Image_xuanzhong:setVisible(zhaoDsc.ImageXZIsVisible)
    panel:releaseFunc(function()
        if type(zhaoDsc.func) == "function" then
            zhaoDsc.func()
        end
	end)
end

function ZhaoSelectDscUI:hideLayer()
    PopupLayerController:hideLayer("ZhaoSelectDscUI",function(layer)
        layer:hide()
    end)
end

isImplement(ZhaoSelectDscUI,IZhaoSelectDscPresenterOutput)
Helper:classDefNodeGetInstance(ZhaoSelectDscUI)
return ZhaoSelectDscUI00000000
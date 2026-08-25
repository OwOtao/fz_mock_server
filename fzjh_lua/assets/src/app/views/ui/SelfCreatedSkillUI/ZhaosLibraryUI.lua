local ZhaosLibraryUI = class("ZhaosLibraryUI", LayerEx)
local ZhaosLibraryPresenter = require("app.presenters.selfCreatedSkill.zhaosLibrary.ZhaosLibraryPresenter")
local IZhaosLibraryPresenterOutput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterOutput")
local IZhaosLibraryPresenterInput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function ZhaosLibraryUI:create()
	local p = ZhaosLibraryUI:new()
	p:init()
	return p
end

function ZhaosLibraryUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/zhaosLibraryUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
    self:initRichText()
end

function ZhaosLibraryUI:showLayer(selfCreatedSkillSystem,callback,presenter,skillId)
    self._IZhaosLibraryPresenterInput = isImplement(presenter:create(self,selfCreatedSkillSystem,callback), IZhaosLibraryPresenterInput)

    self._IZhaosLibraryPresenterInput:showLayer(skillId)
end

function ZhaosLibraryUI:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Text_dsc:getPosition()
    local size = self.Text_dsc:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Text_dsc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(0)
    self.rich_text:setScrollBarEnabled(false)
end

function ZhaosLibraryUI:setShowLayer()
    self:show()
end

function ZhaosLibraryUI:setTextPot(text)
    self.Text_pot:setString(text)
end

function ZhaosLibraryUI:setTextJing(text)
    self.Text_jing:setString(text)
end

function ZhaosLibraryUI:setTextDsc(text)
    self.Text_dsc:setString("")
	self:initRichText()

	local textColor = cc.c3b(149, 149, 149)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 42)
end

function ZhaosLibraryUI:setTextPotIsVisible(isVisible)
    self.Text_pot:setVisible(isVisible)
end	

function ZhaosLibraryUI:setTextJingIsVisible(isVisible)
    self.Text_jing:setVisible(isVisible)
end	

function ZhaosLibraryUI:setButtonCreateZhaoIsVisible(isVisible)
    self.Panel_CreateZhao:setVisible(isVisible)
end	

function ZhaosLibraryUI:setButtonCompleteIsVisible(isVisible)
    self.Button_complete:setVisible(isVisible)
end	

function ZhaosLibraryUI:setButtonPropIsVisible(isVisible)
    self.Button_prop:setVisible(isVisible)
end	

function ZhaosLibraryUI:setTextUseProp(text)
    self.Panel_CreateZhao.Text_useProp:setString(text)
end	

-- @desc 创建招式按钮
function ZhaosLibraryUI:setButtonCreateZhao(func)
    self.Panel_CreateZhao.Button_CreateZhao:releaseFunc(function()
        if func then
            func()
        end
	end)
end	

-- @desc 招式创建完成按钮
function ZhaosLibraryUI:setButtonComplete(buttonEnabled,func)
    self.Button_complete:setEnabled(buttonEnabled)
    self.Button_complete:releaseFunc(function()
        if func then
            func()
        end
	end)
end

-- @desc 招式创作道具
function ZhaosLibraryUI:setButtonProp(func)
    self.Button_prop:releaseFunc(function()
        if func then
            func()
        end
	end)
end

function ZhaosLibraryUI:__setButtonCreateZhaoPosionY(posionY)
    posionY = Helper:getRange(posionY,169,1145)
    self.Panel_CreateZhao:setPositionY(posionY)
end

--@desc 查看当前武学界面
function ZhaosLibraryUI:setButtonSkillInfo(func)
    self.Image_title.Button_skillInfo:releaseFunc(function()
        if func then
            func()
        end
	end)
end


-- @desc 设置招式列表
function ZhaosLibraryUI:setShowZhaosListView(zhaoArray)
    self:__setButtonCreateZhaoPosionY(1145 - ((#zhaoArray-1)*275))
    self.ListView_1:removeAllItems()
    for i,zhao in ipairs(zhaoArray) do
        local panel = self.Panel_zhao:clone()

        self.ListView_1:pushBackCustomItem(panel)
        
        Helper:convertUIByParent(panel)

        self:__setPanelZhao(panel,zhao)

    end
    self.ListView_1:jumpToItem(#zhaoArray-1,cc.p(1,1),cc.p(0.5,0.5))
end

function ZhaosLibraryUI:setBackButton(func)
	self.Image_title.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ZhaosLibraryUI:__setPanelZhao(panel,zhao)
    panel:setBackGroundImage(zhao.Image,0)
    panel.Text_zhaoIndex:setString(zhao.Text_zhaoIndex)
    panel.Text_zhaoName:setTextColor(zhao.Text_zhaoNameColor)
    panel.Text_zhaoName:setString(zhao.Text_zhaoName)
    panel.Text_zhaoType:setString(zhao.Text_zhaoType)
    panel.TextField_desc:setString(zhao.TextField_desc)

    panel.Text_zhaoIndex:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
    panel.Text_zhaoName:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
    panel.Text_zhaoName:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
    panel.Text_zhaoName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    panel.Text_look:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
    
    panel:releaseFunc(function()
        if type(zhao.Button_func) == "function" then
            zhao.Button_func()
        end
	end)
end

function ZhaosLibraryUI:hideLayer()
    PopupLayerController:hideLayer("ZhaosLibraryUI",function(layer)
        layer:hide()
    end)
end

function ZhaosLibraryUI:popText(text)
    PopText(text)
end

function ZhaosLibraryUI:richPrint(text)
    RichPrint("main",text)
end

function ZhaosLibraryUI:setButtonRuleVisible(isVisible)
    self.Image_rule:setVisible(isVisible)
end	

function ZhaosLibraryUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

isImplement(ZhaosLibraryUI,IZhaosLibraryPresenterOutput)
Helper:classDefNodeGetInstance(ZhaosLibraryUI)
return ZhaosLibraryUI000000000000
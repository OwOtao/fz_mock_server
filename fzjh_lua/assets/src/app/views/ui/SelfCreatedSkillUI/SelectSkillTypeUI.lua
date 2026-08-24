local SelectSkillTypeUI = class("SelectSkillTypeUI", LayerEx)
local SelectSkillTypePresenter = require("app.presenters.selfCreatedSkill.selectSkillType.SelectSkillTypePresenter")
local ISelectSkillTypePresenterOutput = require("app.presenters.selfCreatedSkill.selectSkillType.ISelectSkillTypePresenterOutput")
local ISelectSkillTypePresenterInput = require("app.presenters.selfCreatedSkill.selectSkillType.ISelectSkillTypePresenterInput")
local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local isImplement = require("third.assertIsInstance.assertIsInstance")

function SelectSkillTypeUI:create()
	local p = SelectSkillTypeUI:new()
	p:init()
	return p
end

function SelectSkillTypeUI:init()
	self._round = require("Layer/SelfCreatedSkillUI/selectSkillTypeUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self) -- 获得所有子节点
    
    self:__setPanelBack()
end

function SelectSkillTypeUI:showLayer(selfCreatedSkillSystem,callback,costPot,costJing)
    self._ISelectSkillTypePresenterInput = isImplement(SelectSkillTypePresenter:create(self,selfCreatedSkillSystem,callback,costPot,costJing), ISelectSkillTypePresenterInput)
    self._ISelectSkillTypePresenterInput:showLayer()
end

function SelectSkillTypeUI:setShowLayer()
    self:show()
end

function SelectSkillTypeUI:setTitalText(text)
    self.Text_desc:setString(text)
end

-- 高亮选择标题
function SelectSkillTypeUI:setFirstImageShow(panel)
    if panel then
        local tag = panel:getTag()
        if not MapIsEmpty(self._titleVector) and tag then
            for i, v in ipairs(self._titleVector) do
                if v:getTag() and v:getTag() == tag then
                    v.Button_1.Text_buttonName:setTextColor({r = 221, g = 162, b = 21})
                    v.Image_2:setVisible(true)
                else
                    v.Button_1.Text_buttonName:setTextColor({r = 171, g = 171, b = 171})
                    v.Image_2:setVisible(false)
                    v.Panel_2:setVisible(false)
                    v.Panel_2:removeAllChildren()
                end
            end
        end
    end
end

function SelectSkillTypeUI:setFirstPanel(panelData)
    self.Panel:removeAllChildren()
    self._titleVector = {}
    local tag = 999
    for i,v in ipairs(panelData) do
        local panel = self:__createFirstPanel(v.posX,v.posY)
        panel:addTo(self.Panel)
        panel:setTag(tag)
        panel.Button_1.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
        panel.Button_1.Text_buttonName:setString(v.name)
        panel.Button_1:loadTextureNormal(v.image,0)
        panel.Button_1:releaseFunc(
            function()
                if v.func then
                    v.func(panel.Panel_2)
                    self:setFirstImageShow(panel)
                end
            end
        )
        self._titleVector[#self._titleVector + 1] = panel
        tag = tag + 1
    end
end

function SelectSkillTypeUI:__createFirstPanel(posX,posY)
    local panel = self.Panel_1:clone()
    Helper:convertUIByParent(panel)
    panel:setPosition(posX,posY)
    return panel
end

function SelectSkillTypeUI:setSecondPanel(parent,panelData)
    parent:removeAllChildren()
    parent:setVisible(true)
    for i,v in ipairs(panelData) do
        local button = self:__createSecondButton(v.posX,v.posY)
        button:addTo(parent)
        button.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
        button.Text_buttonName1:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
        button.Text_buttonName:setString(v.name)
        button.Text_buttonName1:setString(v.name1)
        button:releaseFunc(
            function()
                if v.func then
                    v.func()
                end
            end
        )
    end

    PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
        layer:setPopText("")
        layer:showLayer()
    end)

    parent:setRotation(0.-90)
    parent:setCascadeOpacity(0)
    parent:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.8),
                cc.RotateTo:create(0.8, 0)
            ),
            cc.CallFunc:create(function ()
                PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                    layer:hideLayer()
                end)
            end)
        )
	)
end

function SelectSkillTypeUI:__createSecondButton(posX,posY)
    local button = self.Button_2:clone()
    Helper:convertUIByParent(button)
    button:setPosition(posX,posY)
    return button
end

function SelectSkillTypeUI:__setPanelBack()
    self.Panel_back:releaseFunc(
        function()
            Audio:playEffect("fanHuiQuXiao")
            self:hideLayer()
        end
    )
end

function SelectSkillTypeUI:hideLayer()
    PopupLayerController:hideLayer("SelectSkillTypeUI",function(layer)
        layer:hide()
    end)
end

function SelectSkillTypeUI:richPrint(text)
    RichPrint("main",text)
end

function SelectSkillTypeUI:popText(text)
    PopText(text)
end

isImplement(SelectSkillTypeUI,ISelectSkillTypePresenterOutput)
Helper:classDefNodeGetInstance(SelectSkillTypeUI)
return SelectSkillTypeUI
000000000000
local SelfCreatedSkillMenuUI = class("SelfCreatedSkillMenuUI", LayerEx)
local SelfCreatedSkillMenuPresenter = require("app.presenters.selfCreatedSkill.selfCreatedSkillMenu.SelfCreatedSkillMenuPresenter")
local ISelfCreatedSkillMenuPresenterOutput = require("app.presenters.selfCreatedSkill.selfCreatedSkillMenu.ISelfCreatedSkillMenuPresenterOutput")
local ISelfCreatedSkillMenuPresenterInput = require("app.presenters.selfCreatedSkill.selfCreatedSkillMenu.ISelfCreatedSkillMenuPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function SelfCreatedSkillMenuUI:create()
    local p = SelfCreatedSkillMenuUI:new()
    p:init()
    return p
end

function SelfCreatedSkillMenuUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/selfCreatedSkillMenuUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SelfCreatedSkillMenuUI:showLayer(selfCreatedSkillSystem)
    self._ISelfCreatedSkillMenuPresenterInput = isImplement(SelfCreatedSkillMenuPresenter:create(self,selfCreatedSkillSystem), ISelfCreatedSkillMenuPresenterInput)

    self._ISelfCreatedSkillMenuPresenterInput:showLayer()
end

function SelfCreatedSkillMenuUI:setShowLayer()
    self:show()
end

function SelfCreatedSkillMenuUI:setTextPot(text)
    self.Text_pot:setString(text)
end

function SelfCreatedSkillMenuUI:setTextJing(text)
    self.Text_jing:setString(text)
end

function SelfCreatedSkillMenuUI:setTextDsc(text)
    self.Text_dsc:setString(text)
end

function SelfCreatedSkillMenuUI:setTextSkillNum(text)
    self.Text_2:setString(text)
end

function SelfCreatedSkillMenuUI:setText4(text)
    self.Text_4:setString(text)
end

function SelfCreatedSkillMenuUI:setText5(text)
    self.Text_5:setString(text)
end

function SelfCreatedSkillMenuUI:setText6(text)
    self.Text_6:setString(text)
end

function SelfCreatedSkillMenuUI:setText7(text)
    self.Text_7:setString(text)
end

function SelfCreatedSkillMenuUI:setButtonCreate(buttonName,func)
    self.Button_create.Text_buttonName:setString(buttonName)
    self.Button_create:releaseFunc(function()
        if func then
            func()
        end
	end)
end

function SelfCreatedSkillMenuUI:setButton1(buttonEnabled,func)
    self.Button_1:setEnabled(buttonEnabled)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
	end)
end

function SelfCreatedSkillMenuUI:hideLayer()
    self:hide()
end

function SelfCreatedSkillMenuUI:popText(text)
    PopText(text)
end

function SelfCreatedSkillMenuUI:richPrint(text)
    RichPrint("main",text)
end

isImplement(SelfCreatedSkillMenuUI,ISelfCreatedSkillMenuPresenterOutput)
Helper:classDefNodeGetInstance(SelfCreatedSkillMenuUI)
return SelfCreatedSkillMenuUI
0000000000000
local CurrSkillInfoUI = class("CurrSkillInfoUI", LayerEx)
local CurrSkillInfoPresenter = require("app.presenters.selfCreatedSkill.currSkillInfo.CurrSkillInfoPresenter")
local ICurrSkillInfoPresenterOutput = require("app.presenters.selfCreatedSkill.currSkillInfo.ICurrSkillInfoPresenterOutput")
local ICurrSkillInfoPresenterInput = require("app.presenters.selfCreatedSkill.currSkillInfo.ICurrSkillInfoPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function CurrSkillInfoUI:create()
	local p = CurrSkillInfoUI:new()
	p:init()
	return p
end

function CurrSkillInfoUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/currSkillInfoUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUI(self)
end

function CurrSkillInfoUI:showLayer(selfCreatedSkillSystem,skill)
    self._ICurrSkillInfoPresenterInput = isImplement(CurrSkillInfoPresenter:create(self,selfCreatedSkillSystem,skill), ICurrSkillInfoPresenterInput)

    self._ICurrSkillInfoPresenterInput:showLayer()
end

function CurrSkillInfoUI:setShowLayer()
    self:show()
end

function CurrSkillInfoUI:setTextSkillName(text)
    self.Text_skillName:setString(text)
end

function CurrSkillInfoUI:setTextSkillDsc(text)
    self.Text_dsc:setString(text)
end

function CurrSkillInfoUI:setTextPreSkillType(text)
    self.Text_1:setString(text)
end

function CurrSkillInfoUI:setTextEquipType(text)
    self.Text_3:setString(text)
end

function CurrSkillInfoUI:setTextActiveZhaoNum(text)
    self.Text_6:setString(text)
end

function CurrSkillInfoUI:setTextAutoZhaoNum(text)
    self.Text_9:setString(text)
end

function CurrSkillInfoUI:setTextStr1(text)
    self.Text_str1:setString(text)
end

function CurrSkillInfoUI:setTextStr2(text)
    self.Text_str2:setString(text)
end

function CurrSkillInfoUI:setTextStr3(text)
    self.Text_str3:setString(text)
end

function CurrSkillInfoUI:setTextStr4(text)
    self.Text_str4:setString(text)
end

function CurrSkillInfoUI:setTextStr5(text)
    self.Text_str5:setString(text)
end

function CurrSkillInfoUI:setTextStr6(text)
    self.Text_str6:setString(text)
end

function CurrSkillInfoUI:setTextStr7(text)
    self.Text_str7:setString(text)
end

function CurrSkillInfoUI:setTextStr8(text)
    self.Text_str8:setString(text)
end

function CurrSkillInfoUI:setTextLevel1(text)
    self.Text_level1:setString(text)
end

function CurrSkillInfoUI:setTextLevel2(text)
    self.Text_level2:setString(text)
end

function CurrSkillInfoUI:setTextLevel3(text)
    self.Text_level3:setString(text)
end

function CurrSkillInfoUI:setTextLevel4(text)
    self.Text_level4:setString(text)
end

function CurrSkillInfoUI:setTextLevel5(text)
    self.Text_level5:setString(text)
end

function CurrSkillInfoUI:setTextLevel6(text)
    self.Text_level6:setString(text)
end

function CurrSkillInfoUI:setTextLevel7(text)
    self.Text_level7:setString(text)
end

function CurrSkillInfoUI:setTextLevel8(text)
    self.Text_level8:setString(text)
end


function CurrSkillInfoUI:hideLayer()
    PopupLayerController:hideLayer("CurrSkillInfoUI",function(layer)
        layer:hide()
    end)
end

function CurrSkillInfoUI:setButtonBack(func)
    self.Panel_back:releaseFunc(
        function()
            func()
        end
    )
end

isImplement(CurrSkillInfoUI,ICurrSkillInfoPresenterOutput)
Helper:classDefNodeGetInstance(CurrSkillInfoUI)
return CurrSkillInfoUI0000000000
local SkillUpgradeConfirmUI = class("SkillUpgradeConfirmUI", LayerEx)

function SkillUpgradeConfirmUI:create()
	local p = SkillUpgradeConfirmUI:new()
	p:init()
	return p
end

function SkillUpgradeConfirmUI:init()
    self._round = require("Layer/SkillUI/UpgradeSkillConfirmUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillUpgradeConfirmUI:showUI()
	self:show()
end

function SkillUpgradeConfirmUI:hideUI()
	self:hide()
end

function SkillUpgradeConfirmUI:setButton1Func(callback)
    self.Button_1:releaseFunc(function()
		callback()
	end)
end

function SkillUpgradeConfirmUI:setButton2Func(callback)
    self.Button_2:releaseFunc(function()
		callback()
	end)
end

function SkillUpgradeConfirmUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function SkillUpgradeConfirmUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function SkillUpgradeConfirmUI:setTextSkillName(text)
    self.Text_skillName:setString(text)
end

function SkillUpgradeConfirmUI:setTextSkillLv(text)
    self.Text_skillLv:setString(text)
end

function SkillUpgradeConfirmUI:setTextZhaoName1(text)
    self.Text_zhaoName1:setString(text)
end

function SkillUpgradeConfirmUI:setTextZhaoExp1(text)
    self.Text_zhaoExp1:setString(text)
end

function SkillUpgradeConfirmUI:setTextZhaoName2(text)
    self.Text_zhaoName2:setString(text)
end

function SkillUpgradeConfirmUI:setTextZhaoExp2(text)
    self.Text_zhaoExp2:setString(text)
end

return SkillUpgradeConfirmUI0000000000000
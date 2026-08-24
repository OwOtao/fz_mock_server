local SkillBreakPopUI = class("SkillBreakPopUI", LayerEx)

function SkillBreakPopUI:create()
	local p = SkillBreakPopUI:new()
	p:init()
	return p
end

function SkillBreakPopUI:init()
    self._round = require("Layer/SkillUI/SkillBreakPopUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillBreakPopUI:showUI()
    self:setVisible(true)
end

function SkillBreakPopUI:hideUI()
    self:setVisible(false)
end

function SkillBreakPopUI:showPanelTip(data)
    self.Panel_tip.Text_title:setString(data["title"])
    self.Panel_tip.Text_desc:setString(data["desc"])
    self.Panel_tip.Text_name:setString(data["name"])
    self.Panel_tip.Text_bLevelNum:setString(data["bLevelNum"])
    self.Panel_tip.Text_needWxxd1:setString(data["needWxxd1"])
    self.Panel_tip.Text_needWxxd2:setString(data["needWxxd2"])
    self.Panel_tip.Text_needWxxd3:setString(data["needWxxd3"])

    self.Panel_tip.Text_needItem1:setString(data["needItem1"])
    self.Panel_tip.Text_needItem2:setString(data["needItem2"])
    self.Panel_tip.Text_needItem3:setString(data["needItem3"])
    self.Panel_tip.Text_needItem4:setString(data["needItem4"])

    self.Panel_tip.Text_needItemTitle:setString(data["needItemTitle"])

    self.Panel_tip.Button_confirm:setPositionY(data["button1PosY"])
    self.Panel_tip.Button_confirm.Text_buttonName:setString(data["button1Name"])
    self.Panel_tip.Button_confirm:releaseFunc(function()
        data["button1Func"]()
    end)

    self.Panel_tip.Button_close:setPositionY(data["button2PosY"])
    self.Panel_tip.Button_close.Text_buttonName:setString(data["button2Name"])
    self.Panel_tip.Button_close:releaseFunc(function()
        data["button2Func"]()
    end)
end

return SkillBreakPopUI00000000000000
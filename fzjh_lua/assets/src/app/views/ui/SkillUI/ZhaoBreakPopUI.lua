local ZhaoBreakPopUI = class("ZhaoBreakPopUI", LayerEx)

function ZhaoBreakPopUI:create()
	local p = ZhaoBreakPopUI:new()
	p:init()
	return p
end

function ZhaoBreakPopUI:init()
    self._round = require("Layer/SkillUI/ZhaoBreakPopUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ZhaoBreakPopUI:showUI()
    self:setVisible(true)
end

function ZhaoBreakPopUI:hideUI()
    self:setVisible(false)
end

function ZhaoBreakPopUI:showPanelTip(data)
    self.Panel_tip.Text_title:setString(data["title"])
    self.Panel_tip.Text_desc:setString(data["desc"])
    self.Panel_tip.Text_name:setString(data["name"])
    self.Panel_tip.Text_int:setString(data["int"])
    self.Panel_tip.Text_expNum:setString(data["expNum"])
    self.Panel_tip.Text_bLevel:setString(data["bLevelNum"])
    self.Panel_tip.Text_skillLv:setString(data["skillLv"])
    self.Panel_tip.Text_addExpTip:setString(data["addExpTip"])

    self.Panel_tip.Text_needItem1:setString(data["needItem1"])
    self.Panel_tip.Text_needItem2:setString(data["needItem2"])
    self.Panel_tip.Text_needItem3:setString(data["needItem3"])
    self.Panel_tip.Text_needItem4:setString(data["needItem4"])
    
    self.Panel_tip.Button_confirm.Text_buttonName:setString(data["button1Name"])
    self.Panel_tip.Button_confirm:releaseFunc(function()
        data["button1Func"]()
    end)

    self.Panel_tip.Button_close.Text_buttonName:setString(data["button2Name"])
    self.Panel_tip.Button_close:releaseFunc(function()
        data["button2Func"]()
    end)
end

return ZhaoBreakPopUI000000000000000
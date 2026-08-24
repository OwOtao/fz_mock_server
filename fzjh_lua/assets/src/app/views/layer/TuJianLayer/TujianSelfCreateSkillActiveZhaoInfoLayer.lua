local TujianSelfCreateSkillActiveZhaoInfoLayer = class("TujianSelfCreateSkillActiveZhaoInfoLayer", cc.Layer)
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

function TujianSelfCreateSkillActiveZhaoInfoLayer:create()
	local p = TujianSelfCreateSkillActiveZhaoInfoLayer:new()
	p:init()
	return p
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:init()
	self._round = require("Layer/TuJianUI/tujianSelfCreateSkillActiveZhaoInfoUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	self.Panel_Bg:releaseFunc(function()
		PopupLayerController:hideLayer("TujianSelfCreateSkillActiveZhaoInfoLayer",function(layer)
			self:hideLayer()
		end)
	end)

	self.Panel_Show:releaseFunc(function()
		PopupLayerController:hideLayer("TujianSelfCreateSkillActiveZhaoInfoLayer",function(layer)
			self:hideLayer()
		end)
	end)
	
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:hideLayer()
	self.skill = nil
	self:hide()
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:showLayer(skill)
	local zhaoList = skill.getZhaos

	if MapIsEmpty(zhaoList) == false then
		table.sort(zhaoList,function(a,b)
			if a and b then
				if tonumber(a.getIndex) < tonumber(b.getIndex) then
					return true
				else
					return false
				end
			else
				return false
			end
		end)
	end
	
	self:setSkillZhaoTitle(skill.name.."武学招式：共有"..#zhaoList.."招")
	self.skill = skill

	self:initZhaoList(zhaoList)
	self:show()
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:initZhaoList(zhaoList)
	self.ListView_zhao:removeAllItems()
	for k,zhao in ipairs(zhaoList) do
		local panelInfo = {}
		panelInfo.name = "第"..Helper:numberCast(k).."招："..zhao.name
		panelInfo.text_1 = zhao.getAttackLevel
		panelInfo.text_2 = zhao.getHitLevel
		panelInfo.text_3 = zhao.getTopLimitLevel
		panelInfo.text_4 = zhao.getSpiritLevel
		panelInfo.text_5 = zhao.getHitAddLevel
		panelInfo.text_6 = zhao.getAttackAddLevel
		panelInfo.text_7 = zhao.getHitPos1Name.."部"
		panelInfo.dsc = zhao.getDsc
		panelInfo.needSkillLv = "【"..self.skill.name.."】不低于"..zhao.lv.."级"
		panelInfo.affixs = zhao.getAffixs

		local panel = self.Panel_zhao:clone()
		Helper:convertUIByParent(panel) -- 获得所有子节点
		self:initPanel(panel,panelInfo)
		self.ListView_zhao:pushBackCustomItem(panel)
	end
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:initPanel(panel,panelInfo)
	panel.Text_zhaoName:setString(panelInfo.name)
	panel.Text_zhaoDsc:setString(panelInfo.dsc)
	panel.Text_skillName:setString(panelInfo.needSkillLv)

	panel.Text_zhaoTitle_text1:setString(panelInfo.text_1)
	panel.Text_zhaoTitle_text2:setString(panelInfo.text_2)
	panel.Text_zhaoTitle_text3:setString(panelInfo.text_3)
	panel.Text_zhaoTitle_text4:setString(panelInfo.text_4)
	panel.Text_zhaoTitle_text5:setString(panelInfo.text_5)
	panel.Text_zhaoTitle_text6:setString(panelInfo.text_6)
	panel.Text_zhaoTitle_text7:setString(panelInfo.text_7)

	local textColor = cc.c3b(177, 177, 177)
	panel.Text_zhaoTitle_text1:setColor(textColor)
	panel.Text_zhaoTitle_text2:setColor(textColor)
	panel.Text_zhaoTitle_text3:setColor(textColor)
	panel.Text_zhaoTitle_text4:setColor(textColor)
	panel.Text_zhaoTitle_text5:setColor(textColor)
	panel.Text_zhaoTitle_text6:setColor(textColor)
	panel.Text_zhaoTitle_text7:setColor(textColor)
	panel.Text_skillName:setColor(textColor)

	panel.Text_zhaoTitle_1:setString("【力道】")
	panel.Text_zhaoTitle_2:setString("【命中】")
	panel.Text_zhaoTitle_3:setString("【重伤】")
	panel.Text_zhaoTitle_4:setString("【消耗】")
	panel.Text_zhaoTitle_5:setString("【炼准】")
	panel.Text_zhaoTitle_6:setString("【炼劲】")
	panel.Text_zhaoTitle_7:setString("【部位】")


	for i =1 ,6 do
		local zhaoPanel = panel["Text_zhaoWord_"..tostring(i)]
		if panelInfo.affixs[i] then
			zhaoPanel:setVisible(true)
			zhaoPanel.Text_zhaoWord:setString(panelInfo.affixs[i]:getName())
			zhaoPanel:releaseFunc(function()
				zhaoPanel.Image_7:setVisible(false)
				local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
				local dialog = DialogELayer:getInstance()
				dialog:show(panelInfo.affixs[i]:getDsc())
				dialog:setPanelBack(function()
					zhaoPanel.Image_7:setVisible(true)
				end)
			end)
		else
			zhaoPanel:setVisible(false)
		end
	end
end

function TujianSelfCreateSkillActiveZhaoInfoLayer:setSkillZhaoTitle(title)
	self.Text_title:setString(title)
end


Helper:classDefNodeGetInstance(TujianSelfCreateSkillActiveZhaoInfoLayer)
return TujianSelfCreateSkillActiveZhaoInfoLayer00
local Resource = require("app.Resource")
local SelectTeacherButton = require("app.views.ui.TeacherUI.SelectTeacherButton")
local Teacher = require("app.models.teacher.Teacher")
local Npc = require("app.models.npc.Npc")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local SelectTeacherLayer = class("SelectTeacherLayer", cc.Layer)

function SelectTeacherLayer:create()
	local p = SelectTeacherLayer:new()
	p:init()
	return p
end

function SelectTeacherLayer:init()
	self._UI = require("Layer/TeacherUI/SelectTeacher").create()['root']
	self._UI:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点

	-- self:initFamilyList()
end

function SelectTeacherLayer:updateLayerSkinUI(skin_config)
	self.__Selectionbtn = skin_config.Selectionbtn
end

function SelectTeacherLayer:initFamilyList()
	local selectTeachers = Teacher:getSelectTeachers()
	self:initWithFamilyList(selectTeachers)
end

function SelectTeacherLayer:initWithFamilyList(familyList)
	self.ListView_center:removeAllItems()

	for i, v in ipairs(familyList) do

		local button = SelectTeacherButton:create()
		button:loadNormalTexture(self.__Selectionbtn)
		self.ListView_center:pushBackCustomItem(button)

		button:setTitle(v.nameColor..v.name)
		-- button:setTitleColor(nameColor)
		button:setDsc(v.dsc)
 
		if v.type == "门派类型" then
			button:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")	
					if PRINT_MODE == 1 then
						print("松开按钮, 门派类型")
					end
					MainControllLayer:pushLayer("SelectTeacherLayer_family")
					MainControllLayer:getLayer("SelectTeacherLayer_family"):initWithFamilyList(Teacher:getFamilys(v.name))

					if v.name == "名门正派" then
						RichPrint("main", "HIC一股浩然正气涌上心头，你决定投身名门正派。")
					elseif v.name == "江湖邪派" then
						RichPrint("main", "RED你嘿嘿一笑，让人毛骨悚然，你决定加入江湖邪派。")
					elseif v.name == "中立门派" then
						RichPrint("main", "YEL淡泊明志，宁静致远，你觉得中庸之道才是最合适自己的。")
					end
				end
				)
		elseif v.type == "门派" then
			button:setDsc(v.litteDesc)
			local canJoin = true
			local requirement = v.requirement
			if requirement then
				for attrName, attrRange in pairs(requirement) do
					local roleAttr = User:getRoleAttr(attrName)
					if roleAttr then
						if (attrRange.min == nil or roleAttr >= attrRange.min) and (attrRange.max == nil or roleAttr <= attrRange.max) then
						else
							canJoin = false
						end
					else
						-- 没有这个属性，没达到要求
						canJoin = false
					end
				end
			end

			if canJoin then
				button:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					local npc = Npc:getNpc(v.defaultTeacher)

					local dialog = DialogALayer:getInstance()
					dialog:show("你确定要加入【"..v.name.."】吗？", "师父："..npc:getName())
					dialog:setButton1("决定了", function()
						if PRINT_MODE == 1 then
							print("松开按钮, 门派")
						end

						if User:getRole():obApprentice(npc) then
							MainControllLayer:pushLayer("MainLayer",{animDuration = 0})
							local runningScene = cc.Director:getInstance():getRunningScene()
							runningScene:delayFunc(0.1,function ()
								MainControllLayer:pushLayer("TeacherLayer")
							end)
						end
					end)
					dialog:setButton2("再想想")
				end
				)
			else
				button:disable()
				button:releaseFunc(
				function()
				end
				)
			end			
		else
			assert(false)
		end
	end
end

function SelectTeacherLayer:setTextExp(exp)
	exp = tostring(exp)
	self.Text_exp:setString("『经验』"..exp)
end

function SelectTeacherLayer:setTextPot(pot)
	pot = tostring(pot)
	self.Text_pot:setString("『潜能』"..pot)
end

function SelectTeacherLayer:setTextMoney(money)
	money = tostring(money)
	self.Text_money:setString("『金钱』"..money)
end

return SelectTeacherLayer000000000000
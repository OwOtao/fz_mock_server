local EditRoleAttrLayer = class("EditRoleAttrLayer", cc.LayerColor)
local DebugLayer = require("app.views.layer.DebugLayer.DebugLayer")
local Skill = require("app.models.skill.Skill")
function EditRoleAttrLayer:create()
	local p = EditRoleAttrLayer:new()	
	p:init()
	return p
end
function EditRoleAttrLayer:init()
	self._round = require("Layer/DebugUI/EditRoleAttrLayer.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)
	local sprite = cc.Sprite:create("Image/UI/TaskUI/kuang.png", cc.rect(display.cx,display.cy,1080,1920))
	sprite:setLocalZOrder(0)
	sprite:setAnchorPoint(cc.p(0.5,0.5))
	sprite:setPosition(0,0)
	
	sprite:addTo(self)
end

function EditRoleAttrLayer:show()
	-- PopText("测试4")
	local role = User:getRole()
	self.exp = role:getNumAttr("exp")--经验
	self.pot = role:getNumAttr("pot")--潜能
	self.money = role:getNumAttr("money")--金钱
	self.str = role:getNumAttr("str")--臂力
	self.int = role:getNumAttr("int")--悟性
	self.con = role:getNumAttr("con")--根骨
	self.dex = role:getNumAttr("dex")--身法
	self:setButtonSubmit()
	self.data = {[1]="exp",[2]="pot",[3] = "money",[4] = "str",[5] = "int",[6] = "con",[7] = "dex"}
	self:initEditBox()
	self:initSkillEditBox()
	self:initSkillExpEditBox()
	self:initWPEditBox()
	self:initWpNumEditBox()
	self:removeText()
end

function EditRoleAttrLayer:removeText()
	--将不需要的Text移除
	self.Text_exp_num:removeFromParent()
	self.Text_pot_num:removeFromParent()
	self.Text_money_num:removeFromParent()
	self.Text_str_num:removeFromParent()
	self.Text_int_num:removeFromParent()
	self.Text_con_num:removeFromParent()
	self.Text_dex_num:removeFromParent()

	self.Text_skillId1:removeFromParent()
	self.Text_skillId2:removeFromParent()
	self.Text_skillId3:removeFromParent()

	self.Text_skillExp1:removeFromParent()
	self.Text_skillExp2:removeFromParent()
	self.Text_skillExp3:removeFromParent()

	self.Text_skillId1_0:removeFromParent()
	self.Text_skillId2_0:removeFromParent()
	self.Text_skillId3_0:removeFromParent()

	self.Text_skillExp1_0:removeFromParent()
	self.Text_skillExp2_0:removeFromParent()
	self.Text_skillExp3_0:removeFromParent()
end
function EditRoleAttrLayer:initWpNumEditBox()
	for i = 3,5 do
			local size = self.Image_Skill_Num1:getContentSize()
			local skikkEditBox = ccui.EditBox:create(size, "self.exp")
			skikkEditBox:setInputMode(1)
			skikkEditBox:setInputFlag(3)
			skikkEditBox:setReturnType(1)
			skikkEditBox:setFontSize(45)
			skikkEditBox:setTag(200000+i)
			skikkEditBox:setText("物品数量")
			skikkEditBox:addTo(self)
			skikkEditBox:setPosition(self.Image_Skill_Num1:getPositionX(),self.Image_Skill_Num1:getPositionY()-(i-3)*70)
			skikkEditBox:onEditHandler(function(event)
				local eventName = event.name
				print("eventName = "..tostring(eventName))
			    print("eventTarget = "..tostring(eventTarget))
				if eventName =="return" then
					local editTextNum = skikkEditBox:getText()
					local num = tonumber(editTextNum)
					if type(num) == "number" then
					else
						if editTextNum ~= "物品数量" then
							PopText("请输入纯数字！！！")
							skikkEditBox:setText("物品数量")
						end
					end
				end
			end)
	end
end
function EditRoleAttrLayer:initWPEditBox()
	local i = 3
	for i=3,5 do
		local size = self.Image_WP_id1:getContentSize()
		local skikkEditBox = ccui.EditBox:create(size, "self.exp")
		skikkEditBox:setInputMode(1)
		skikkEditBox:setInputFlag(3)
		skikkEditBox:setReturnType(1)
		skikkEditBox:setFontSize(40)
		skikkEditBox:setTag(20000+i)
		skikkEditBox:setPosition(self.Image_WP_id1:getPositionX(),self.Image_WP_id1:getPositionY()-(i-3)*70)
		skikkEditBox:setText("物品ID")
		skikkEditBox:addTo(self)
		skikkEditBox:onEditHandler(function(event)
			local eventName = event.name
			if eventName =="return" then
				local editTextNum = skikkEditBox:getText()
				if self:compareSkillId(editTextNum) then
				else
					if editTextNum == nil then
						skikkEditBox:setText("物品ID")
					else
						if editTextNum == nil or editTextNum == "" then
							PopText("物品物品ID不能为空！！！")
							skikkEditBox:setText("物品ID")
						else
							if editTextNum ~="物品ID" then
								PopText("物品ID不存在,将为人物添加新的技能")
							end
						end
					end
				end
			end
		end)
	end
end
function EditRoleAttrLayer:initSkillEditBox()
	for i = 0,2 do
		local size = self.Image_Skill_id1:getContentSize()
		local skikkEditBox = ccui.EditBox:create(size, "self.exp")
		skikkEditBox:setInputMode(1)
		skikkEditBox:setInputFlag(3)
		skikkEditBox:setReturnType(1)
		skikkEditBox:setFontSize(40)
		skikkEditBox:setTag(20000+i)
		skikkEditBox:setPosition(self.Image_Skill_id1:getPositionX(),self.Image_Skill_id1:getPositionY()-i*70)
		i = i+1
		skikkEditBox:setText("技能ID")
		skikkEditBox:addTo(self)
		skikkEditBox:onEditHandler(function(event)
			local eventName = event.name
			if eventName =="return" then
				local editTextNum = skikkEditBox:getText()
				if self:compareSkillId(editTextNum) then
				else
					if editTextNum == nil then
						skikkEditBox:setText("技能ID")
					else
						if editTextNum == nil or editTextNum == "" then
							PopText("技能ID不能为空！！！")
							skikkEditBox:setText("技能ID")
						else
							if editTextNum ~="技能ID" then
								PopText("技能ID不存在,将为人物添加新的技能")
							end
						end
					end
				end
			end
		end)
	end
end
function EditRoleAttrLayer:initSkillExpEditBox()
for i = 0,2 do
		local size = self.Image_Skill_Exp1:getContentSize()
		local skikkEditBox = ccui.EditBox:create(size, "self.exp")
		skikkEditBox:setInputMode(1)
		skikkEditBox:setInputFlag(3)
		skikkEditBox:setReturnType(1)
		skikkEditBox:setFontSize(45)
		skikkEditBox:setTag(200000+i)
		skikkEditBox:setText("技能经验")
		skikkEditBox:addTo(self)
		skikkEditBox:setPosition(self.Image_Skill_Exp1:getPositionX(),self.Image_Skill_Exp1:getPositionY()-i*70)
		skikkEditBox:onEditHandler(function(event)
			local eventName = event.name
			print("eventName = "..tostring(eventName))
		    print("eventTarget = "..tostring(eventTarget))
			if eventName =="return" then
				local editTextNum = skikkEditBox:getText()
				local num = tonumber(editTextNum)
				if type(num) == "number" then
				else
					if editTextNum ~= "技能经验" then
						PopText("请输入纯数字！！！")
						skikkEditBox:setText("技能经验")
					end
				end
			end
		end)
	end
end
function EditRoleAttrLayer:initEditBox()
	local role = User:getRole()
	local i = 0
	for k,v in pairs(self.data) do
		local size = self.Image_exp:getContentSize()
		local edit = ccui.EditBox:create(size, "self.exp")
		edit:setInputMode(1)
		edit:setInputFlag(3)
		edit:setReturnType(1)
		edit:setFontSize(40)
		edit:setTag(2000+i)
		edit:setPosition(self.Image_exp:getPositionX(),self.Image_exp:getPositionY()-i*70)
		i = i+1
		local text = role:getNumAttr(v)
		edit:setText(text)
		edit:addTo(self)
		edit:onEditHandler(function(event)
			local eventName = event.name
			print("eventName = "..tostring(eventName))
		    print("eventTarget = "..tostring(eventTarget))
			if eventName =="return" then
				local editTextNum = edit:getText()
				local num = tonumber(editTextNum)
				if type(num) == "number" then
					if num <=0 then
						PopText("请输入大于0的数字！！！")
						RichPrint( "main", "请输入大于0的数字！！！" )
						num = role:getNumAttr(v)
						edit:setText(num)
					end
				else
					PopText("请输入数字！！！")
					RichPrint( "main", "请输入数字！！！" )
					num = role:getNumAttr(v)
					edit:setText(num)
				end
			end
		end)
	end
end
function EditRoleAttrLayer:setButtonSubmit()
	self.Button_submit:releaseFunc(function()
		local i = 0
		local role = User:getRole()
		for k,v in pairs(self.data) do 
			local edit = self:getChildByTag(i+2000)
			local editTextNum = edit:getText()
			local num = tonumber(editTextNum)
			if type(num) == "number" then
				role:setAttr(v, num)
			else
				PopText("请输入数字！！！")
				RichPrint( "main", "请输入数字！！！" )
				num = role:getNumAttr(k)
				edit:setText(num)
			end
			i = i+1
		end
		for i=0,2 do
			local skillId = self:getChildByTag(i+20000)
			local skillExp = self:getChildByTag(i+200000)
			skillid = skillId:getText()
			skillexp = skillExp:getText()
			if skillid == "技能ID" or skillexp == "技能经验" then
			else
				local skill = Skill:getSkill(skillid)
				if skill == nil then
					PopText("没有该技能的资源"..tostring(skillid))
				else
					role:addSkillExp(skillId, skillexp)
				end
			end
		end
		for i = 3,5 do 
			local itemNameText = self:getChildByTag(i+20000)
			local itemCountText = self:getChildByTag(i+200000)
			itemId = itemNameText:getText()
			itemCount = itemCountText:getText()
			if itemId == "物品ID" or itemCount == "物品数量" then
				-- self:helpMethod(role:getItems())
			else
				local item = role:getOneItemByKey(itemId)
				if item == nil then
					PopText("没有该物品的资源"..tostring(itemId))
				else
					role:addItemCount(itemId, tonumber(itemCount))
					PopText("添加物品 "..tostring(item.name).." X "..tostring(itemCount).."个")
				end
				Statistics:recordItemCount(itemId, tonumber(itemCount))
				
				-- if self:compareWPId(skillid) then 
				-- 	--技能ID存在
				-- 	local bskillexp = role:getItemCount(skillid)
				-- 	RichPrint( "main", "添加数量前物品个数"..bskillexp )
				-- 	role:addItemCount(skillId,tonumber(skillexp))
				-- 	bskillexp = role:getItemCount(skillid)
				-- 	RichPrint( "main", "添加数量后物品个数"..bskillexp )
				-- else
				-- 	-- PopText("物品ID:"..skillid.."不存在,将增加此物品")
				-- 	-- local  roleSkill = {id = skillid, exp = tonumber(skillexp)}
				-- 	-- role:setSkill(skillid, roleSkill)
				-- end
				-- self:helpMethod(role:getItems())
			end
		end
		self:removeFromParent()
		
	end)
end
function EditRoleAttrLayer:compareSkillId(skillId)
	local role = User:getRole()
	local skill = role:getSkill(skillId)
	if skill == nil then
		return false
	end
	PopText(role:getSkillLv(skillId))
	if skill["id"] == skillId then
		return true
	end
	return false
end
function EditRoleAttrLayer:compareWPId(wpId)
	local role = User:getRole()
	local wp = role:getItem(wpId)
	if wp == nil then
		return false
	end
	if wp["id"] == wpId then
		return true
	end
	return false
end
function EditRoleAttrLayer:helpMethod(table)
	for k,v in pairs(table) do
		if type(v) == "table" then
			RichPrint( "main", k )
			self:helpMethod(v)
		else
			RichPrint( "main", k.." :"..v)
			PopText(k.." :"..v)
		end 
	end
end
Helper:classDefNodeGetInstance(EditRoleAttrLayer)
return EditRoleAttrLayer  00000000000
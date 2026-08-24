
local User = require("app.models.user.User")
local BackUI = class("BackUI", cc.Layer)
local HouseSkinConfig = require("app.models.ChangeHouseSkin.HouseSkinConfig")

function BackUI:create()
	local p = BackUI:new()
	p:init()
	return p
end

function BackUI:init()
	self._round = require("Layer/BackUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
end

function BackUI:hideImage(duration)
	self.Is_show = false
	local actionTag = self.Sprite_bottom:getActionTagByName("Sprite_bottomShowAndHide")
	self:stopActionByTag(actionTag)
	local imgHeight = self.Sprite_bottom:getContentSize().height
	local action = cc.Sequence:create(
		cc.MoveTo:create(duration, cc.p(0, -imgHeight)),
		cc.CallFunc:create(
			function()
				-- toLayer:resumeSelfAndChildren()
			end))
	action:setTag(actionTag)
	self.Sprite_bottom:runAction(action)
end

function BackUI:showImage(duration)
	self.Is_show = true
	local actionTag = self.Sprite_bottom:getActionTagByName("Sprite_bottomShowAndHide")
	self:stopActionByTag(actionTag)
	local action = cc.Sequence:create(
		cc.MoveTo:create(duration, cc.p(0, 0)),
		cc.CallFunc:create(
			function()
				-- toLayer:resumeSelfAndChildren()
			end))
	action:setTag(actionTag)
	self.Sprite_bottom:runAction(action)
end

function BackUI:switch(duration, toLayerName)
	if HouseSkinConfig:isShowBg(toLayerName) then
		return
	end
	
	if duration and duration > 0 then
		duration = duration / 2
	else
		duration = 0
	end

	local role = User:getRole()
	local imagePath = "MainUI/changjing01.png"		-- 默认场景
	local backImagePath = "Image/UI/MainUI/backgurand.jpg"

	local tescher =
	{
		SelectTeacherLayer_type = 1,
		SelectTeacherLayer_family = 1,
		SkillInfoLayer = 1,
		SkillPrepareLayer = 1,
		TeacherLayer = 1,
		FamilyGroupRankLayer = 1,
	}
	-- 师门需要改变背景场景
	if tescher[toLayerName] == 1 then
		-- 师门
		if not role:hasFamily() then
			imagePath = "MainUI/back/wudang.png"
		else
			imagePath = "MainUI/back/"..role:getFamilyId()..".png"
		end
	-- 属性界面需要改变背景场景
	elseif toLayerName == "AttrLayer" then
		-- 属性
		local sex = role:getAttr("sex")
		if sex == "男" then
			imagePath = "AttrUI/nan.png"
		else
			imagePath = "AttrUI/nv.png"
		end
	elseif toLayerName == "TuJianMenuLayer" then
		imagePath = "MainUI/back/tujian.png"
	elseif toLayerName == "TuJianInFoLayer" then
		imagePath = ""
	else
	end
	imagePath = "Image/UI/"..imagePath

	if self.Is_show then
		self:hideImage(duration)
	end

	self:delayFunc(duration, function()
		if self.Is_show then
			return
		end
		self.Sprite_bottom:setTexture(imagePath)
		self.Sprite_background:setTexture(backImagePath)
		self:showImage(duration)
	end)
end

function BackUI:setSpriteBottomTexture(texture)
	self.Sprite_bottom:setTexture(texture)
end

function BackUI:setSpriteBackgroundTexture(texture)
	self.Sprite_background:setTexture(texture)
end

return BackUI
0000000
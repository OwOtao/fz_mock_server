
local Skill = require("app.models.skill.Skill")

local JiaLiLayer = class("JiaLiLayer", cc.Layer)

function JiaLiLayer:create()
	local p = JiaLiLayer:new()	
	p:init()
	return p
end

function JiaLiLayer:init()
	local UI = require("Layer/AttrUI/AddLiUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
end

function JiaLiLayer:show()
	
	self._touchTime = 0
	self.Text_desc4:setVisible(false)
	self.Text_desc5:setVisible(false)
	self.Text_desc6:setVisible(false)

	local role = User:getRole()
	local skills = role:getSkills()
	if skills["jibenneigong"] == nil or role:getSkillPrepare()["neigong"] == nil then
		PopText("请先准备内功")
		self:hide()
		return
	end

	local maxnum = role:getJiaLiMax()
	if not maxnum or maxnum <= 0 then
		PopText("你的内力值不足以分配")
		self:hide()
		return
	end

	self:setVisible(true)
	self._maxNum = maxnum
	local jiaLi = User:getRoleAttr("jiaLi")
	self:setTextNum(jiaLi)

	self:setBack()
	self:setButtonAdd()
	self:setButtonDec()
	self:setButtonMax()
	self:setButtonMin()
	self:setButtonConfirm()
end

function JiaLiLayer:hide()
	PopupLayerController:hideLayer("JiaLiLayer", function(layer)
		if self._handle ~= nil then
			self:unschedule(self._handle)
		end
		
		self:setVisible(false)
	end)
end

function JiaLiLayer:setBack()
	self.Image_back:releaseFunc(function()
		self:hide()
	end)

	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

function JiaLiLayer:setButtonConfirm()
	self.Button_confirm:releaseFunc(function()
		RichPrint("main", "你决定使用["..tonumber(self:getTextNum()).."]点内力来伤敌。")
		User:setRoleAttr("jiaLi", tonumber(self:getTextNum()))
		self:hide()
	end)
end

function JiaLiLayer:setButtonMax()
	self.Button_max:releaseFunc(function()
		self:setTextNum(100000000000)
	end)
end

function JiaLiLayer:setButtonMin()
	self.Button_min:releaseFunc(function()
		self:setTextNum(0)
	end)
end

function JiaLiLayer:setButtonAdd()
	-- self.Button_add:releaseFunc(function()
	-- 	local jiaLi = assert(tonumber(self:getTextNum()))
	-- 	self:setTextNum(jiaLi + 1)
	-- end)

	self.Button_add:releaseFuncTotally(
		function()

			local currTime = GetTime()

			if currTime - self._touchTime < 0.3 then
				return
			end

			self._touchTime = currTime

			if self._handle ~= nil then
				self:unschedule(self._handle)
			end

			local total_time = 0

			local jiaLi = assert(tonumber(self:getTextNum()))

			self._handle =
				self:schedule(
				function(ft)
					total_time = total_time + ft
					if total_time > 1.25 and total_time < 3 then
						jiaLi = jiaLi + 0.2
						self:setTextNum(jiaLi)
					elseif total_time >= 2.5 then
						jiaLi = jiaLi + 0.5
						self:setTextNum(jiaLi)
					end
				end
			)
		end,
		function()
			local jiaLi = assert(tonumber(self:getTextNum()))
			jiaLi = jiaLi + 1
			self:setTextNum(Helper:mathFloor(jiaLi))
			if self._handle ~= nil then
				self:unschedule(self._handle)
			end
		end,
		function()
			if self._handle ~= nil then
				self:unschedule(self._handle)
			end
		end
	)


end

function JiaLiLayer:setButtonDec()
	-- self.Button_dec:releaseFunc(function()
	-- 	local jiaLi = assert(tonumber(self:getTextNum()))
	-- 	self:setTextNum(jiaLi - 1)
	-- end)
	self.Button_dec:releaseFuncTotally(
		function()
			local total_time = 0

			local currTime = GetTime()

			if currTime - self._touchTime < 0.3 then
				return
			end

			self._touchTime = currTime

			if self._handle ~= nil then
				self:unschedule(self._handle)
			end

			local jiaLi = assert(tonumber(self:getTextNum()))

			self._handle =
				self:schedule(
				function(ft)
					total_time = total_time + ft
					if total_time > 1.25 and total_time < 3 then
						jiaLi = jiaLi - 0.2
						self:setTextNum(jiaLi)
					elseif total_time >= 2.5 then
						jiaLi = jiaLi - 0.5
						self:setTextNum(jiaLi)
					end
				end
			)
		end,
		function()
			local jiaLi = assert(tonumber(self:getTextNum()))
			jiaLi = jiaLi - 1
			self:setTextNum(Helper:mathFloor(jiaLi))
			if self._handle ~= nil then
				self:unschedule(self._handle)
			end
		end,
		function()
			if self._handle ~= nil then
				self:unschedule(self._handle)
			end
		end
	)

end

function JiaLiLayer:buttonIsForbid(name, status)
	if not name then
		return
	end
	local button = self["Button_"..name]
	local forbid, canUse

	if name == "max" or name == "min" then
		forbid = button.Text_forbid
		canUse = button.Text_canUse
	else
		forbid = button.Image_forbid
		canUse = button.Image_canUse
	end

	forbid:setVisible(false)
	canUse:setVisible(false)
	if status then
		button:setEnabled(false)
		button:setTouchEnabled(false)
		forbid:setVisible(true)
	else
		button:setEnabled(true)
		button:setTouchEnabled(true)
		canUse:setVisible(true)
	end
end

function JiaLiLayer:setTextNum(num)
	self:buttonIsForbid("add", false)
	self:buttonIsForbid("dec", false)
	self:buttonIsForbid("max", false)
	self:buttonIsForbid("min", false)

	num = self:handleNum(num)

	if not num or tonumber(num) <= 0 then
		num = 0
		self:buttonIsForbid("dec", true)
		self:buttonIsForbid("min", true)
		if self._handle ~= nil then
			self:unschedule(self._handle)
		end
	elseif tonumber(num) >= self._maxNum then
		num = self._maxNum
		self:buttonIsForbid("max", true)
		self:buttonIsForbid("add", true)
		if self._handle ~= nil then
			self:unschedule(self._handle)
		end
	end
	self.Text_num:setString(num)
end

function JiaLiLayer:getTextNum()
	return self.Text_num:getString()
end

function JiaLiLayer:handleNum(num)
	if num < 0 then
		num = 0
	elseif num >= 0 and num <= 1 then
		num = math.ceil(num)
	else
		num = Helper:mathFloor(num)
	end

	return num
end

Helper:classDefNodeGetInstance(JiaLiLayer)

return JiaLiLayer  00000000000
local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local Meridian = require("app.models.Meridian.Meridian")

-- 经脉平复
local MeridianCalmDownLayer = class("MeridianCalmDownLayer", LayerEx)

function MeridianCalmDownLayer:create()
	local p = MeridianCalmDownLayer:new()
	p:init()
	return p
end

function MeridianCalmDownLayer:init()
	self._UI = require("Layer/MeridianUI/MeridianCalmDownUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setShowAndHideAnimType("ROLL")

	self:setButton()
	self:setBack()

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end
end

-- state 1 平复界面 2 师傅平复界面
function MeridianCalmDownLayer:showLayer(state, callBackFunc, callBackFunc1)
	if state == nil then
		state = 1
	end

	self.callBackFunc = Helper:getDef(callBackFunc, function()end)
	self.callBackFunc1 = Helper:getDef(callBackFunc1, function()end)

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self.Panel_1.Text_wait:setString("")

	local role = User:getRole()
	if state == 1 then
		self.Panel_1:setVisible(true)
		self.Panel_2:setVisible(false)
		if role:hasFamily() then
			self.Panel_1.Button_shimen:setVisible(true)
		else
			self.Panel_1.Button_shimen:setVisible(false)
		end

		if role:getFlag("坐等平复") == 1 then
			self.Panel_1.Button_wait:setVisible(false)
		else
			self.Panel_1.Button_wait:setVisible(true)
		end

		self._handle = self:schedule(function (ft)
			self:update(ft)
		end,1)
	else
		self.Panel_1:setVisible(false)
		self.Panel_2:setVisible(true)

		self.Panel_2.Text_pot:setString("现有潜能:" .. math.floor(User:getRoleAttr("pot")))
		self.Panel_2.Text_needpot:setString("需要潜能:" .. 1000)
	end
	self:show()
	self:update()
end

function MeridianCalmDownLayer:setButton()
	self.Panel_1.Button_anshendan:releaseFunc(function()
		-- 安神丹
		local role = User:getRole()
		local itemCount = role:getItemCount("jingmai106")
		if itemCount <= 0 then
			PopText("安神丹不足")
		else
			role:setFlag("平复真气", 0)
			role:addItemCount("jingmai106", -1)
			PopText("服用安神丹")
			self.callBackFunc()
			PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
				self:hide()
			end, 0)

			-- 服用安神丹统计
			local Record = require("app.models.Record.Record")
			Record:addRecordCount("jingmai", "useItem", "jingmai106")
		end
	end)

	self.Panel_1.Button_shimen:releaseFunc(function()
		local role = User:getRole()
		PopText("去找师傅求助吧，应该能解决你的问题！")
		role:setFlag("平复真气", 1)
		PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
			self:hide()
		end, 0)
	end)

	self.Panel_1.Button_wait:releaseFunc(function()
		local role = User:getRole()
		role:setFlag("平复真气", 0)
		role:setFlag("坐等平复", 1)
		role:setTimeLimitFlag("坐等平复", 1, 1800)
		self.Panel_1.Button_wait:setVisible(false)
		self:update()
	end)

	self.Panel_2.Button_yungong:releaseFunc(function()
		if User:getRoleAttr("pot") < 1000 then
			PopText("潜能不足")
			return
		else
			User:addRoleAttr("pot", -1000)
			local meridian = User:getRoleAttr("meridian")
			meridian.acupointState = 1
			User:getRole():setFlag("平复真气", 0)
			User:getRole():setFlag("坐等平复", 0)
			User:getRole():setTimeLimitFlag("坐等平复", 0, 0)
			User:setRoleAttr("meridian", meridian)

			RichPrint("main", "你赶紧依师傅所言行功平复真气，在师傅的真气加持下，你的努力终于起到了作用，那股紊乱的真气终于平复下来了。")
			PopText("真气平复了！")
			PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
				self:hide()
			end, 0)

			local Record = require("app.models.Record.Record")
			Record:addRecordCount("jingmai", "event", "pingfuzhenqi")
		end
	end)

	self.Panel_2.Button_leave:releaseFunc(function()
		PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
			self:hide()
		end)
	end)
end

function MeridianCalmDownLayer:setBack()
	self.Panel_back:releaseFunc(function()
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

function MeridianCalmDownLayer:update(dt)
	local role = User:getRole()
	if role:getFlag("坐等平复") == 1 then
		self.Panel_1.Button_wait:setVisible(false)
		local currTime = GetTime()
		local time = role:getTimeLimitFlagTime("坐等平复")
		local year, month, day, hour, minute, second = Helper:getExpiredTime(currTime + time, currTime)
		self.Panel_1.Text_wait:setString("预计真气会在" .. minute .. "分钟" .. second .. "秒后平复下来")
		if time == 0 then
			self.callBackFunc1()
			PopupLayerController:hideLayer("MeridianCalmDownLayer", function(layer)
				self:hide()
			end, 0)
		end
	end
end

Helper:classDefNodeGetInstance(MeridianCalmDownLayer)

return MeridianCalmDownLayer000000000000000
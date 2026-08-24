local BatchProcessLayer = class("BatchProcessLayer", cc.Layer)

function BatchProcessLayer:create()
	local p = BatchProcessLayer:new()	
	p:init()
	return p
end

function BatchProcessLayer:init()
	local UI = require("Layer/AttrUI/AddLiUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setBack()
	self:setButtonAdd()
	self:setButtonDec()
	self:setButtonMax()
	self:setButtonMin()
	self:setButtonConfirm()

	self._minNum = 1
	self._maxNum = 99

end

function BatchProcessLayer:showLayer()
	self.Text_desc:setVisible(false)
    self.Text_desc2:setVisible(false)
    self.Text_desc3:setVisible(false)
	self.Text_desc4:setVisible(false)
	self.Text_desc5:setVisible(false)
	self.Text_desc6:setVisible(false)

	self._touchTime = 0
	self.buyPrice = nil
	self.currencyUnit = "碎银"

    self:show()
end

--设置界面初始值
function BatchProcessLayer:setInitNum(num)
	if type(num) ~= "number" then
		assert(nil,"BatchProcessLayer:setInitNum(num)  参数类型不是数字")
	end
	self:setTextNum(num)
end

--设置能加到的最大数
function BatchProcessLayer:setMaxNum(num)
	if type(num) ~= "number" then
		assert(nil,"BatchProcessLayer:setMaxNum(num)  参数类型不是数字")
	end
	self._maxNum = num
end

--设置能减到的最小数
function BatchProcessLayer:setMinNum(num)
	if type(num) ~= "number" then
		assert(nil,"BatchProcessLayer:setMinNum(num)  参数类型不是数字")
	end
	self._minNum = num
end

--描述1
function BatchProcessLayer:setTextDesc(desc)
    self.Text_desc:setVisible(true)
    self.Text_desc:setString(desc)
end

--描述2
function BatchProcessLayer:setTextDesc2(desc)
    self.Text_desc2:setVisible(true)
    self.Text_desc2:setString(desc)
end

--描述3
function BatchProcessLayer:setTextDesc3(desc)
    self.Text_desc3:setVisible(true)
    self.Text_desc3:setString(desc)
end

--描述4
function BatchProcessLayer:setTextDesc4(desc)
    self.Text_desc4:setVisible(true)
    self.Text_desc4:setString(desc)
end

--描述5
function BatchProcessLayer:setTextDesc5(desc)
    self.Text_desc5:setVisible(true)
    self.Text_desc5:setString(desc)
end

function BatchProcessLayer:setBuyPrice(buyPrice)
	self.buyPrice = buyPrice
end
--设置货币显示单位(目前只有碎银)
function BatchProcessLayer:setCurrencyUnit(currencyUnit)
	if not currencyUnit then 
		currencyUnit = "碎银"
	end
	self.currencyUnit = currencyUnit
end

function BatchProcessLayer:hideLayer()
	PopupLayerController:hideLayer("BatchProcessLayer", function(layer)
		self:hide()
	end)
end

function BatchProcessLayer:setBack()
	self.Image_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function BatchProcessLayer:setButtonConfirm(func)
	self.Button_confirm:releaseFunc(function()
		if func then
			func(tonumber(self:getTextNum()))
		end
		self:hideLayer()
	end)
end

function BatchProcessLayer:setButtonMax()
	self.Button_max:releaseFunc(function()
		self:setTextNum(self._maxNum)
	end)
end

function BatchProcessLayer:setButtonMin()
	self.Button_min:releaseFunc(function()
		self:setTextNum(self._minNum)
	end)
end

function BatchProcessLayer:setButtonAdd()
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

function BatchProcessLayer:setButtonDec()
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

function BatchProcessLayer:buttonIsForbid(name, status)
	if not name then
		return
	end
	local button = self["Button_"..name]
	local forbid, canUse

	if name == "max" then
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

function BatchProcessLayer:setTextNum(num)
	self:buttonIsForbid("add", false)
	self:buttonIsForbid("dec", false)
	self:buttonIsForbid("max", false)


	if not num or tonumber(num) <= self._minNum then
		num = self._minNum
		self:buttonIsForbid("dec", true)
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
	num = self:handleNum(num)
	if type(self.buyPrice) == "number" then
		self.Text_desc6:setVisible(true)
		self.Text_desc6:setString("总计："..self.buyPrice * tonumber(num)..self.currencyUnit)
	end
	self.Text_num:setString(num)
end

function BatchProcessLayer:getTextNum()
	return self.Text_num:getString()
end

function BatchProcessLayer:handleNum(num)
	if num < 0 then
		num = 0
	elseif num >= 0 and num <= 1 then
		num = math.ceil(num)
	else
		num = Helper:mathFloor(num)
	end

	return num
end

Helper:classDefNodeGetInstance(BatchProcessLayer)

return BatchProcessLayer  000000000000000
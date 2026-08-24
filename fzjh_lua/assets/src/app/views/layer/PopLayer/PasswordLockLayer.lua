-- 机关锁界面
local PasswordLockLayer = class("PasswordLockLayer", LayerEx)

function PasswordLockLayer:create()
	local p = PasswordLockLayer:new()
	p:init()
	return p
end

function PasswordLockLayer:init()
	self._UI = require("Layer/PopUI/PasswordLockUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	--self:setBackEnabled(false)

	-- 剩余点击次数
	self.lockCount = 8

	-- 正确顺序
	self.password = 0

	-- 玩家输入顺序
	self.inputPassword = 0

	self.rightFunc = nil
	self.wrongFunc = nil

	self:setVisible(false)

	self:setShowAndHideAnimType("ROLL")

	self:setBack()
	self:setButton()
end

function PasswordLockLayer:showLayer(title, desc, password, rightFunc, wrongFunc)
	self.Text_title:setString(title)
	self.Text_desc:setString(desc)
	self.lockCount = 8
	self.password = password
	self.inputPassword = 0

	self.rightFunc = rightFunc
	self.wrongFunc = wrongFunc

	if self.rightFunc == nil then
		self.rightFunc = function()
		end
	end

	if self.wrongFunc == nil then
		self.wrongFunc = function()
		end
	end

	self.Button_lock_1:setEnabled(true)
	self.Button_lock_2:setEnabled(true)
	self.Button_lock_3:setEnabled(true)
	self.Button_lock_4:setEnabled(true)
	self.Button_lock_5:setEnabled(true)
	self.Button_lock_6:setEnabled(true)
	self.Button_lock_7:setEnabled(true)
	self.Button_lock_8:setEnabled(true)
	self:show()
end

function PasswordLockLayer:setBack()
	self.Panel_back:releaseFunc(function()
		self.wrongFunc()
		PopupLayerController:hideLayer("PasswordLockLayer", function(layer)
			self:hide()
		end)
	end)
end

-- 1乾 2坤 3艮 4兑 5坎 6离 7巽 8震
function PasswordLockLayer:setButton()
	-- 4兑
	self.Button_lock_1:releaseFunc(function()
		self.Button_lock_1:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 4)
		self:checkPassword()
	end)

	-- 1乾
	self.Button_lock_2:releaseFunc(function()
		self.Button_lock_2:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 1)
		self:checkPassword()
	end)

	-- 7巽
	self.Button_lock_3:releaseFunc(function()
		self.Button_lock_3:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 7)
		self:checkPassword()
	end)

	-- 6离
	self.Button_lock_4:releaseFunc(function()
		self.Button_lock_4:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 6)
		self:checkPassword()
	end)

	-- 5坎
	self.Button_lock_5:releaseFunc(function()
		self.Button_lock_5:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 5)
		self:checkPassword()
	end)

	-- 8震
	self.Button_lock_6:releaseFunc(function()
		self.Button_lock_6:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 8)
		self:checkPassword()
	end)

	-- 2坤
	self.Button_lock_7:releaseFunc(function()
		self.Button_lock_7:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 2)
		self:checkPassword()
	end)

	-- 3艮
	self.Button_lock_8:releaseFunc(function()
		self.Button_lock_8:setEnabled(false)
		self.lockCount = self.lockCount - 1
		self.inputPassword = self.inputPassword + (math.pow(10, self.lockCount) * 3)
		self:checkPassword()
	end)
end

function PasswordLockLayer:checkPassword()
	if self.lockCount <= 0 then
		if self.password == self.inputPassword then
			-- 密码正确
			print("密码正确 " .. self.inputPassword)
			self.rightFunc()
			PopupLayerController:hideLayer("PasswordLockLayer", function(layer)
				self:hide()
			end)
		else
			print("密码错误 " .. self.inputPassword)
			print("正确密码" .. self.password)
			self.wrongFunc()
			PopupLayerController:hideLayer("PasswordLockLayer", function(layer)
				self:hide()
			end)
		end
	end
end

Helper:classDefNodeGetInstance(PasswordLockLayer)

return PasswordLockLayer00000000000000
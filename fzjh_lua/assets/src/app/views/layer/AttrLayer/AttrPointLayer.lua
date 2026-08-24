local AttrPointLayer = class("AttrPointLayer", require("app.views.base.BaseLayer"))

local attrUINameList = {
	str = "Panel_bili",
	dex = "Panel_shenfa",
	int = "Panel_wuxing",
	con = "Panel_gengu",
}

function AttrPointLayer:create()
	local p = AttrPointLayer:new()
	p:init()
	return p
end

function AttrPointLayer:init()
	self._UI = require("Layer/AttrUI/AttrPointUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	-- 待分配属性点
	self.attrPoint = 0

	-- 分配属性点 暂存
	self.attrList =
	{
		str = 0,
		dex = 0,
		int = 0,
		con = 0,
	}

	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Button_1:releaseFunc(function()
		self:confirm()
		self:hideLayer()
	end)

	self.Button_2:releaseFunc(function()
		self:hideLayer()
	end)
end

function AttrPointLayer:hideLayer()
	self:__stopSchedule()
	self.attrPoint = 0
	self.attrList =
	{
		str = 0,
		dex = 0,
		int = 0,
		con = 0,
	}

	PopupLayerController:hideLayer("AttrPointLayer", function(layer)
		self:hide(true)
	end)
end

function AttrPointLayer:setButton()
	self._touchTime = 0

	for attr, uiName in pairs(attrUINameList) do
		if self[uiName] then
			self[uiName].Button_add:releaseFuncTotally(function()
				if self.attrPoint > 0 then
					self:__update(function()
						self:attrUpdateFunc(attr, "add")
						self:updateUI(attr)
					end)
				end
			end,function()
				if self.attrPoint > 0 then
					self:attrUpdateFunc(attr, "add")
					self:updateUI(attr)
				end
				
				self:__stopSchedule()
			end,function()
				self:__stopSchedule()
			end)

			self[uiName].Button_dec:releaseFuncTotally(function()
				if self.attrList[attr] > 0 then
					self:__update(function()
						self:attrUpdateFunc(attr, "dec")
						self:updateUI(attr)
					end)
				end
			end,function()
				if self.attrList[attr] > 0 then
					self:attrUpdateFunc(attr, "dec")
					self:updateUI(attr)
				end
				
				self:__stopSchedule()
			end,function()
				self:__stopSchedule()
			end)
		end
	end
end

function AttrPointLayer:initData()
	self.attrPoint = 0
	self.attrList =
	{
		str = 0,
		dex = 0,
		int = 0,
		con = 0,
	}

	-- 总属性点
	local currAttrPoint = self._role:getAttr("str") + self._role:getAttr("dex") + self._role:getAttr("int") + self._role:getAttr("con")
	-- 转生次数对应属性点总和上限
	local point = 0
	local inheritCount = self._role:getAttr("inheritCount")

	-- 三转后每次转生加固定50点
	if inheritCount == 0 then
		point = 80
	elseif inheritCount == 1 then
		point = 110
	elseif inheritCount == 2 then
		point = 150
	elseif inheritCount >= 3 then
		point = 150 + ( 50 * ( inheritCount - 2 ) )
	end

	if point - currAttrPoint > 0 then
		self.attrPoint = point - currAttrPoint
	end
end

function AttrPointLayer:attrUpdateFunc(attr, type)
	if type == "add" then
		if self.attrPoint > 0 then
			self.attrList[attr] = self.attrList[attr] + 1
			self.attrPoint = self.attrPoint - 1
		end
	elseif type == "dec" then
		if self.attrList[attr] > 0 then
			self.attrList[attr] = self.attrList[attr] - 1
			self.attrPoint = self.attrPoint + 1
		end
	end
end

-- 更新按钮状态 数值
function AttrPointLayer:updateUI(attr)
	local uiName = attrUINameList[attr]

	if not self[uiName] then
		return
	end

	if self.attrList[attr] > 0 then
		self[uiName].Button_dec.Image_forbid:setVisible(false)
	else
		self[uiName].Button_dec.Image_forbid:setVisible(true)
	end

	self[uiName].Text_num:setString(self._role:getAttr(attr) + self.attrList[attr])

	self:setCanUseAttrPoint(self.attrPoint)
end

function AttrPointLayer:setCanUseAttrPoint(point)
	self.Text_desc:setString("可分配先天属性点 " .. point)
end

-- 确认属性
function AttrPointLayer:confirm()
	self._role:addAttr("str", self.attrList.str)
	self._role:addAttr("dex", self.attrList.dex)
	self._role:addAttr("int", self.attrList.int)
	self._role:addAttr("con", self.attrList.con)
end

-- 重置界面
function AttrPointLayer:showLayer()
	self._role = User:getRole()

	self:initData()

	if self.attrPoint > 0 then
		self.Panel_bili.Button_add.Image_forbid:setVisible(false)
		self.Panel_shenfa.Button_add.Image_forbid:setVisible(false)
		self.Panel_wuxing.Button_add.Image_forbid:setVisible(false)
		self.Panel_gengu.Button_add.Image_forbid:setVisible(false)
	else
		self.Panel_bili.Button_add.Image_forbid:setVisible(true)
		self.Panel_shenfa.Button_add.Image_forbid:setVisible(true)
		self.Panel_wuxing.Button_add.Image_forbid:setVisible(true)
		self.Panel_gengu.Button_add.Image_forbid:setVisible(true)
	end

	self.Panel_bili.Button_dec.Image_forbid:setVisible(true)
	self.Panel_shenfa.Button_dec.Image_forbid:setVisible(true)
	self.Panel_wuxing.Button_dec.Image_forbid:setVisible(true)
	self.Panel_gengu.Button_dec.Image_forbid:setVisible(true)

	self.Panel_bili.Text_num:setString(self._role:getAttr("str"))
	self.Panel_shenfa.Text_num:setString(self._role:getAttr("dex"))
	self.Panel_wuxing.Text_num:setString(self._role:getAttr("int"))
	self.Panel_gengu.Text_num:setString(self._role:getAttr("con"))

	self:setCanUseAttrPoint(self.attrPoint)
	self:setButton()

	self:show(true)
end

function AttrPointLayer:__update(callback)
	local currTime = GetTime()

	if currTime - self._touchTime < 0.3 then
		return
	end

	self._touchTime = currTime

	self:__stopSchedule()

	local total_time = 0

	self._handle =
		self:schedule(
		function(ft)
			total_time = total_time + ft
			if total_time > 1.25 then
				if callback then
					callback()
				end
			end
		end
	)
end

function AttrPointLayer:__stopSchedule()
    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end
end

Helper:classDefNodeGetInstance(AttrPointLayer)

return AttrPointLayer000000000000
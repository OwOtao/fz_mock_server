local Item = require("app.models.item.Item")

local NeiDanLayer = class("NeiDanLayer", cc.Layer)

local fenpeiList =
	{
		str = 0,
		int = 0,
		con = 0,
		dex = 0
	}

function NeiDanLayer:create()
	local p = NeiDanLayer:new()
	p:init()
	return p
end

function NeiDanLayer:init()
	local UI = require("Layer/AttrUI/NeiDanUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(false)

	self:schedule(function()
		self:refreshUI()
	end, 0.1)
end

function NeiDanLayer:show()
	self:setBack()
	self:initButtons()

	local fenpei = User:getRoleAttr("fenpei")
	self._numMax = fenpei
	if fenpei <= 0 then
		PopText("你没有可分配的属性点。")
	end
	self:setTextDesc(fenpei)
	self:setVisible(true)

	fenpeiList =
	{
		str = 0,
		int = 0,
		con = 0,
		dex = 0
	}

end

function NeiDanLayer:hide()
	PopupLayerController:hideLayer("NeiDanLayer", function(layer)
		self:setVisible(false)
		self:saveData()
	end)
end

function NeiDanLayer:setBack()
	self.Image_back:releaseFunc(function()
		self:hide()
	end)

	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

function NeiDanLayer:buttonIsForbid(button, status, btype)
	if not button then
		return
	end
	local forbid, canUse

	if btype == "fuyao" then
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

function NeiDanLayer:setTextDesc(num)
	if not num or type(num) ~= "number" then
		num = 0
	end

	if num <= 0 then
		self:buttonIsForbid(self.Panel_bili.Button_add, true)
		self:buttonIsForbid(self.Panel_shenfa.Button_add, true)
		self:buttonIsForbid(self.Panel_wuxing.Button_add, true)
		self:buttonIsForbid(self.Panel_gengu.Button_add, true)
	else
		self:buttonIsForbid(self.Panel_bili.Button_add, false)
		self:buttonIsForbid(self.Panel_shenfa.Button_add, false)
		self:buttonIsForbid(self.Panel_wuxing.Button_add, false)
		self:buttonIsForbid(self.Panel_gengu.Button_add, false)
	end
	self._numMax = num

	self.Text_desc:setString("可分配先天属性点："..num)
end

function NeiDanLayer:initButtons()
	local role = User:getRole()
	-- local fenpeiList = role:getAttr("fenpeiList")
	local list =
	{
		{
			name = "bili",
			key = "str",
			-- num = fenpeiList.str + role:getNumAttr("str"),
			num = role:getFinalAttr("str"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("臂力")
				end
				local item = Item:getOneItemByKey("shenlishan")
				item:storeItemUse()
			end
		},
		{
			name = "shenfa",
			key = "dex",
			-- num = fenpeiList.dex + role:getNumAttr("dex"),
			num = role:getFinalAttr("dex"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("身法")
				end
				local item = Item:getOneItemByKey("qingshenyao")
				item:storeItemUse()
			end
		},
		{
			name = "wuxing",
			key = "int",
			-- num = fenpeiList.int + role:getNumAttr("int"),
			num = role:getFinalAttr("int"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("悟性")
				end
				local item = Item:getOneItemByKey("lingzhicao")
				item:storeItemUse()
			end
		},
		{
			name = "gengu",
			key = "con",
			-- num = fenpeiList.con + role:getNumAttr("con"),
			num = role:getFinalAttr("con"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("根骨")
				end
				local item = Item:getOneItemByKey("goupigao")
				item:storeItemUse()
			end
		},
		{
			name = "rongmao",
			key = "looks",
			num = role:getFinalAttr("looks"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("容貌")
				end
				local item = Item:getOneItemByKey("xiyanshui")
				item:storeItemUse()
			end
		},
		{
			name = "fuyuan",
			key = "luck",
			num = role:getFinalAttr("luck"),
			funcFuYao = function()
				if PRINT_MODE == 1 then
					print("富源")
				end
				local item = Item:getOneItemByKey("fuyuandan")
				item:storeItemUse()
			end
		}
	}

	for i,v in ipairs(list) do
		self:setPanelItem(v)
	end
end

-------------------------------------------------------------------------------------------------------
--[[  params 结构
	{
		name = "bili",
		funcFuYao = function()
		end
	}
]]
-------------------------------------------------------------------------------------------------------
function NeiDanLayer:setPanelItem(params)
	if not params or _G.next(params) == nil then
		return
	end
	local panel = self["Panel_"..params.name]

	local function setTextNum(num)
		if not num or type(num) ~= "number" then
			num = 0
		end

		self:buttonIsForbid(panel.Button_dec, false)
		self:buttonIsForbid(panel.Button_add, false)
		self:buttonIsForbid(panel.Button_fuyao, false, "fuyao")
		if num <= params.num then
			self:buttonIsForbid(panel["Button_dec"], true)
			num = params.num
		end
		panel.Text_num:setString(num)
	end

	local function getTextNum()
		return panel.Text_num:getString()
	end

	setTextNum(params.num)

	--减
	panel.Button_dec:releaseFunc(function()
		local num = assert(tonumber(getTextNum()))
		setTextNum(num - 1)
		self:setTextDesc(self._numMax + 1)
		fenpeiList[params.key] = fenpeiList[params.key] - 1
	end)
	--加
	panel.Button_add:releaseFunc(function()
		local num = assert(tonumber(getTextNum()))
		setTextNum(num + 1)
		self:setTextDesc(self._numMax - 1)
		fenpeiList[params.key] = fenpeiList[params.key] + 1
	end)
	--服药
	panel.Button_fuyao:releaseFunc(function()
		if params.funcFuYao then
			params.funcFuYao()
		end
	end)

end

function NeiDanLayer:refreshUI()
	local role = User:getRole()
	local bili, wuxing, gengu, shenfa, rongmao, fuyuan = role:getNumAttr("str"), role:getNumAttr("int"), role:getNumAttr("con"), role:getNumAttr("dex"), role:getNumAttr("looks"), role:getFinalAttr("luck")

	self.Panel_bili.Text_num:setString(bili + fenpeiList.str)
	self.Panel_wuxing.Text_num:setString(wuxing + fenpeiList.int)
	self.Panel_gengu.Text_num:setString(gengu + fenpeiList.con)
	self.Panel_shenfa.Text_num:setString(shenfa + fenpeiList.dex)
	self.Panel_rongmao.Text_num:setString(rongmao)
	self.Panel_fuyuan.Text_num:setString(fuyuan)
end

-- 保存数据
function NeiDanLayer:saveData()
	-- User:setRoleAttr("fenpeiList", list)
	for attr,num in pairs(fenpeiList) do
		User:addRoleAttr(attr, num)
	end
	User:setRoleAttr("fenpei", self._numMax)
end

Helper:classDefNodeGetInstance(NeiDanLayer)

return NeiDanLayer0000000000000
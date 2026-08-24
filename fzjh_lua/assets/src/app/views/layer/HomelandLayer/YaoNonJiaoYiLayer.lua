
local Resource = require("app.Resource")
local YaoNonJiaoYi = class("YaoNonJiaoYi", cc.Layer)
local List_view = {}
local roleItems = {} --玩家临时背包
local Literary = require("script.book.literary.lua")["Sheet1"]
local literaryList = {}

--从itemlist中移除一个itemId==id的item,要考虑数量
local function removeItemById(itemlist, id)
	for i, v in ipairs(itemlist) do		
		if v.itemId == id then
			v.count = v.count - 1			
			if v.count <= 0 then
				table.remove(itemlist, i)
			end
			return true
		end
	end
	return false
end

function YaoNonJiaoYi:create()
	local p = YaoNonJiaoYi:new()
	p:init()
	return p
end

function YaoNonJiaoYi:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
end

function YaoNonJiaoYi:show()
	self:setVisible(true)
end

function YaoNonJiaoYi:hide()
	self:setVisible(false)
end


-- 设置角色,参数1是玩家角色
function YaoNonJiaoYi:setRoles(role)
	if not role then
		assert(nil, "YaoNonJiaoYi:setRoles(role) -> 角色1不存在")
	end
		
	self.role = role
	for i,v in pairs(Literary) do
		table.insert(literaryList, v)
	end	
	--为玩家临时背包填充数据
	roleItems = clone(role:getItems())	
	self.Image_title.Text_title2:setString("书童")
	self.Panel_item2.Text_num:setVisible(false)

	-- 能卖出售物品给NPC
	--self.npcCanSale = true
	
	--把玩家背包的数据填充到ui
	self:setBagList1(roleItems)
	self:setBagList2(literaryList)
	
	-- 刷新玩家临时背包容量
	self:refreshWeightUI()
	
	-- 文本隐藏
	self.Text_desc:setVisible(false)
	
	-- 按钮初始化
	self:initButtons()
end

-- 自己的背包
function YaoNonJiaoYi:setBagList1(list)

	if not list then
		return
	end
	for i, v in ipairs(list) do
		local row
		if v.count > 0 then
			local item = Item:getOneItemByKey(v.itemId)
			
			if not item then
				if DEBUG_MODE == 1 then
					print("====================================================================================没有该物品",v.itemId)
					assert(nil, "YaoNonJiaoYi:createItem1(mapValue) -> 没有该物品" .. v.itemId)
				end
			end
			local widget = self.ListView_1:getItem(i - 1)
			row = self:createItem1(v, item, widget)
			if widget == nil then
				self.ListView_1:pushBackCustomItem(row)
			end
		end
	end

	for i = #list + 1, #self.ListView_1:getItems() do
		self.ListView_1:removeLastItem()
	end
end

-- 对方的背包
function YaoNonJiaoYi:setBagList2(list)
	if not list then
		return
	end
	
	for i,v in ipairs(list) do
		local row 
		local widget = self.ListView_2:getItem(i - 1)

		local row = self:createItem2(i,v,widget)
		
		if widget == nil then
			self.ListView_2:pushBackCustomItem(row)
		end
	end

	for i = #list + 1, #self.ListView_2:getItems() do
		self.ListView_2:removeLastItem()
	end

end

-- 自己背包的栏目
function YaoNonJiaoYi:createItem1(bagItem, itemData, widget)
	
	local row = widget
	if row == nil then
		row = self.Panel_item1:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)
	row.Text_name:setString(tostring(itemData.name) .. " X " .. tostring(bagItem.count))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	local role = User:getRole()
	-- 点击处理
	row:releaseFunc(function()
			
	end)
	return row
end

-- 对方背包的栏目
function YaoNonJiaoYi:createItem2(bagItem,itemData,widget)
	
	local row = widget
	if row == nil then
		row = self.Panel_item2:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)
	--显示名字
	row.Text_name:setString(tostring(itemData.name))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	row:releaseFunc(function()
		print("============================傻逼")
	end)
	return row
end

--按钮初始化
function YaoNonJiaoYi:initButtons()
	--local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton()
	--self:addChild(button1)
	self:addChild(button2)
	--button1:move(cc.p(270, 200))
	button2:move(cc.p(810, 200))
	--self.Button_1 = button1
	self.Button_2 = button2
	--self:setButton1("取消")
	self:setButton2("取消")
end

function YaoNonJiaoYi:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

-- function YaoNonJiaoYi:setButton1(name)
-- 	self.Button_1.Text_buttonName:setString(name)
-- 	self.Button_1:releaseFunc(function()
-- 		Audio:playEffect("xiaoAnNiu")
		
-- 		self:hide()
		
-- 	end)
-- end

function YaoNonJiaoYi:setButton2(name,itemData)
	self.Button_2.Text_buttonName:setString(name)
	self.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")		
		self:hide()	
	end)
end

--获取1~n之间
-- function YaoNonJiaoYi:getRandomNum()
-- 	local tab = {}
-- 	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
-- 	for i=1, 5 do  
-- 		local tab[i] = math.random(1,#literaryList)		
-- 	end
	
-- end

--去重
function YaoNonJiaoYi:getUniqueRandomNum(tab)
	local list1 = {}
	local list2 = {}
	for key,value in pairs(tab) do
		if not list1[value] then
			
		end
	end
end

-- 当前值的计数在list的重新渲染中统计
function YaoNonJiaoYi:refreshWeightUI()
	self.Text_weight:setString((#roleItems) .. "/" .. User:getRoleAttr("weight"))
end

Helper:classDefNodeGetInstance(YaoNonJiaoYi)

return YaoNonJiaoYi 0000
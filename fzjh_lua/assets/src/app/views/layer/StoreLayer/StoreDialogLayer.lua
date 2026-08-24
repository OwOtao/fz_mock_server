local StoreDialogLayer = class("StoreDialogLayer", cc.Layer)

function StoreDialogLayer:create()
	local p = StoreDialogLayer:new()
	p:init()
	return p
end

function StoreDialogLayer:init()
	self._round = require("Layer/StoreUI/StoreDialogUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setVisible(false)
end

function StoreDialogLayer:show(item, func)
	if MapIsEmpty(item) then
		self:hide()
		PopupLayerController:hideLayer("StoreDialogLayer")
		return
	end
	self:setTextDesc(item.dsc1, item.dsc2)

	self:setTextGet(item.name, item.number, item.itemId)

	self:setTextCostNum(item.price)

	self:setTextNotice(item.share)

	self:setButton1(func)
	self:setButton2()
	self:setVisible(true)

	if GetTime() > Helper:getTimeStampWithStringDate("20181220", 0) and GetTime() < Helper:getTimeStampWithStringDate("20190105", 24) then
		self.Text_mingxi:setVisible(true)
		self.Text_mingxi_1:setVisible(true)
	else
		self.Text_mingxi:setVisible(false)
		self.Text_mingxi_1:setVisible(false)
	end

end

-- 设置确定按钮
function StoreDialogLayer:setButton1(func)
	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		if func then
			func()
		end		
		PopupLayerController:hideLayer("StoreDialogLayer")
	end)
end

-- 设置取消按钮
function StoreDialogLayer:setButton2(func)
	self.Button_2:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
		PopupLayerController:hideLayer("StoreDialogLayer")
	end)
end

-- 设置描述
function StoreDialogLayer:setTextDesc(desc1, desc2)
	if desc1 == nil then
		self.Text_desc_1:setVisible(false)
	else
		self.Text_desc_1:setVisible(true)
	end
	local desc = tostring(desc1)
	if desc2 ~= nil then
		desc = desc.."\n"..tostring(desc2)
	end
	self.Text_desc_1:setString(desc)
end

-- 设置商品显示图片
function StoreDialogLayer:setImageGoods(itemId)
	if itemId == nil then
		self.Image_Goods:setVisible(false)
	else
		self.Image_Goods:setVisible(true)
	end

	local defaultTab = 
	{
		["fuben11-20"] = 1,
		item01 = 1,
		["fuben21-30"] = 1,
		["fuben31-35"] = 1,
		["fuben36-40"] = 1,
	}
	if defaultTab[itemId] == 1 then
		itemId = "zhuzi"
	end

	local fileName = "Image/UI/StoreUI/"..tostring(itemId)..".png"
	if cc.FileUtils:getInstance():isFileExist(fileName) then
		self.Image_Goods:loadTexture(fileName, 0)
	else
		self.Image_Goods:setVisible(false)
	end    	
end

-- 设置商品获取数量
function StoreDialogLayer:setTextGet(name, num, itemId)
	if name == nil then
		self.Text_desc_3:setVisible(false)
		self.Image_Goods:setVisible(false)
		self.Text_title_1:setVisible(false)
	else
		self.Text_desc_3:setVisible(true)
		self.Image_Goods:setVisible(true)
		self.Text_title_1:setVisible(true)
	end

	-- 设置图片
	self:setImageGoods(itemId)

	local str = ""
	local defaultTab = 
	{
		["fuben11-20"] = 1,
		["fuben21-30"] = 1,
		["fuben31-35"] = 1,
		["fuben36-40"] = 1,
	}

	if num == nil or num <= 0 or defaultTab[itemId] == 1 then
		str = name
	else
		str = name.." X"..tostring(num)
	end
	self.Text_desc_3:setString(str)
end

-- 设置花费数量
function StoreDialogLayer:setTextCostNum(num)
	if num == nil then
		self.Text_title_2:setVisible(false)
		self.Text_desc_4:setVisible(false)
	else
		self.Text_title_2:setVisible(true)
		self.Text_desc_4:setVisible(true)
	end
	self.Text_desc_4:setString(num)
end

-- 显示友好提示内容
function StoreDialogLayer:setTextNotice(str)
	if str == nil then
		self.Text_notice:setVisible(false)
	else
		self.Text_notice:setVisible(true)
	end
	self.Text_notice:setString(str)
end


Helper:classDefNodeGetInstance(StoreDialogLayer)
return StoreDialogLayer0000000000000
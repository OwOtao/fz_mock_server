local DialogGLayer = class("DialogGLayer", cc.Layer)

function DialogGLayer:create()
	local p = DialogGLayer:new()
	p:init()
	return p
end

function DialogGLayer:init()
	self._round = require("Layer/Dialog/Dialog7UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setVisible(false)
end

-- 处理页面公用异常，初始化页面
function DialogGLayer:initPanel(panelType)
	if panelType == nil then
		return
	end
	self.Image_Goods:setVisible(true)
	self.Button_close:setVisible(true)
	self.Text_title_3:setVisible(true)
	self.Text_desc_5:setVisible(true)
	self.Text_title_1:setVisible(true)
	self.Text_Bag_Ck:setVisible(true)
	self.Text_desc_3:setVisible(true)
	self.Panel_1:setVisible(false)
	self.Panel_2:setVisible(false)
	if panelType == "map" then
		--点击时间，配置界面
		self.Image_Goods:setVisible(false)
		self.Button_close:setVisible(false)
		self.Text_title_3:setVisible(false)
		self.Text_desc_5:setVisible(false)
		self.Text_title_1:setVisible(false)
		self.Text_Bag_Ck:setVisible(false)
		self.Text_desc_3:setVisible(false)

		--配置界面
		self:setText_title("请确定刷新")
		self:setBUttonName("立即刷新","取消")
	elseif panelType == "bag" then
		self.Image_Goods:setVisible(false)
		self.Image_Goods:setVisible(false)
		self:setText_title("请确定升级")
		self:setText_title_1("升级可获得")
		self:setBUttonName("升级背包","升级仓库")
		self:setText_desc_1("请选择升级背包或仓库")
		self.Text_desc_3:setVisible(false)
	elseif panelType == "refresh" then
		self.Image_Goods:setVisible(false)
		self.Button_close:setVisible(false)
		self.Text_title_3:setVisible(false)
		self.Text_desc_5:setVisible(false)
		self.Text_title_1:setVisible(false)
		self.Text_Bag_Ck:setVisible(false)
		self.Text_desc_3:setVisible(false)
		self:setText_title("请确定刷新")
		self:setBUttonName("立即刷新","取消")
	elseif panelType == "zhounianqing" then
		self.Image_Goods:setVisible(false)
		self.Button_close:setVisible(false)
		self.Text_title_3:setVisible(false)
		self.Text_desc_5:setVisible(false)
		self.Text_desc_6:setVisible(false)
		self.Text_title_1:setVisible(true)
		self.Text_Bag_Ck:setVisible(false)
		self.Text_desc_3:setVisible(true)
		-- self.Panel_1:setVisible(true)
		self:setText_title("请确定刷新")
		self:setBUttonName("立即刷新","取消")
	else
		self.Button_close:setVisible(false)
		self.Text_title_3:setVisible(false)
		self.Text_desc_5:setVisible(false)
		self.Text_Bag_Ck:setVisible(false)
		self:setBUttonName("确定","取消")
	end
	self:setVisible(true)
end

function DialogGLayer:show(item, item2, func1, func2)
	if not item and type(item) ~= "table" and not item2 and type(item2) ~= "table" then
		return
	end
	self:setText_desc_1(item2.dsc, item2.itemDesc)
	if item.itemId == "fuben11-20" or item.itemId == "fuben21-30" or item.itemId == "fuben31-35" or itemId == "fuben36-40" then
		self:setText_desc_3(item.name)
	else
		self:setText_desc_3(item.name, item.number)
	end
	-- self:setText_desc_3(item.name, item.number)
	self:setText_desc_4(item2.buyPrice)
	self:setImageGoods(item.itemId)
	self:setButton1(func1)
	self:setButton2(func2)
	self:setVisible(true)
end

function DialogGLayer:setButton1(func,mark)
	if PRINT_MODE == 1 then
		print("DialogGLayerwhat!!!")
	end
	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if mark == nil then
			self:hide()
		end
		if func then
			func()
		end		
	end)
end


function DialogGLayer:setButton2(func,mark)
	self.Button_2:releaseFunc(function()
		if mark == nil then
			self:hide()
		end
		if func then
			func()
		end
	end)
end
function DialogGLayer:setButtonclose(func)
	self.Button_close:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end)
end
function DialogGLayer:setImageGoods(itemId)
	if itemId then
		if itemId == "fuben11-20" or itemId == "item01" or itemId == "fuben21-30" or itemId == "fuben31-35" or itemId == "fuben36-40" then
			itemId = "zhuzi"
		end
	    self.Image_Goods:loadTexture("Image/UI/StoreUI/"..tostring(itemId)..".png",0)
	else
		self.Image_Goods:loadTexture("", 0)
	end
end

function DialogGLayer:getReturnString(desc1, desc2)
	local str = ""
	if not desc1 and not desc2 then
	elseif not desc1 then
		str = desc2
	elseif not desc2 then
		str = desc1
	else
		if type(desc2) == "number" then
			str = tostring(desc1).."x"..tostring(desc2)	
		else
			str = tostring(desc1).."\n"..tostring(desc2)	
		end
	end
	return str
end

function DialogGLayer:setBUttonName(str1,str2)
	self.Text_button_1Name:setString(str1)
	self.Text_button_2Name:setString(str2)
end

function DialogGLayer:setTextBagCk(str)
	self.Text_Bag_Ck:setVisible(true)
	self.Text_Bag_Ck:setString(str)
end

function DialogGLayer:setText_title(str)
	self.Text_title:setString(str)
end
function DialogGLayer:setText_title_1(str)
	self.Text_title_1:setString(str)
end

function DialogGLayer:setText_desc_1(desc1, desc2)
	local str = self:getReturnString(desc1, desc2)
	self.Text_desc_1:setString(str)
end
function DialogGLayer:setText_desc_clour_1(_rgb)
	if _rgb then
		_rgb = Helper:getDef(_rgb,cc.c3b(255, 255, 255))
		self.Text_desc_1:setColor(_rgb)
	end
end
function DialogGLayer:setText_desc_3(desc1, desc2)
	local str = self:getReturnString(desc1, desc2)
	self.Text_desc_3:setString(str)
end

function DialogGLayer:setText_desc_4(desc)
	local str = self:getReturnString(desc)
	self.Text_desc_4:setString(str)
end

function DialogGLayer:setText_desc_5(desc)
	self.Text_desc_5:setVisible(true)
	local str = self:getReturnString(desc)
	self.Text_desc_5:setString(str)
end

function DialogGLayer:SetVisible()
	self.Text_title:setVisible(false)
	self.Text_title_1:setVisible(false)
	self.Text_desc_3:setVisible(false)
	self.Image_Goods:setVisible(false)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/28 17:59:04
-- @desc 增加一个物品描述
function DialogGLayer:setText_desc_6(desc)
	self.Text_desc_6:setVisible(true)
	local str = self:getReturnString(desc)
	self.Text_desc_6:setString(str)
end
function DialogGLayer:setPanelText_desc(desc)
	self.Panel_1:setVisible(true)
	local str = self:getReturnString(desc)
	self.Text_desc_7:setString(str)
end
--设置已有商品、货币
function DialogGLayer:setPanel2_desc(str1, str2)
	self.Panel_2:setVisible(true)
	self.Text_desc_8:setString(str1)
	self.Text_desc_9:setString(str2)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/29 10:21:36
-- @desc 这是text文本对其方式，0左对齐，1水平居中，2右对齐
function DialogGLayer:setTextHorizontalAlignmentWithType(nodeName,tag)
	if self[nodeName] then
		self[nodeName]:setTextHorizontalAlignment(tag)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/29 15:35:52
-- @desc 获取text X坐标位置
function DialogGLayer:getTextPositionX(nodeName)
	if self[nodeName] then
		return self[nodeName]:getPositionX()
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/29 15:37:27
-- @desc 设置X坐标
function DialogGLayer:setTextPositionX(nodeName,posX)
	if self[nodeName] then
		self[nodeName]:setPositionX(posX)
	end
end
Helper:classDefNodeGetInstance(DialogGLayer)
return DialogGLayer0000000000000000
--
-- Author: Your Name
-- Date: 2018-09-10 15:00:46
--
local GoodsShowLayer=class("GoodsShowLayer",LayerEx)
function GoodsShowLayer:create()
	local layer=GoodsShowLayer:new()
	layer:init()
	return layer
end

function GoodsShowLayer:init()
	local UI=require("Layer/Dialog/GoodsShowUI.lua").create()["root"]
	UI:addTo(self)
	Helper:convertUI(self)
end

function GoodsShowLayer:initUI(title,roleStr,itemId,list,ratio)  --标题，NPC文本，兑换货币，兑换列表，兑换比率
	local titleStr="材料兑换"
	if title then 
		titleStr=title.."兑换"
	end
	local roleTextStr=""
	if type(roleStr)=="string" then 
		roleTextStr=roleStr
	else
		roleTextStr=tostring(roleStr)
	end
	if ratio then 
		self.ratio=ratio
	end
	self.Panel_back1:setVisible(false)
	self.Panel_num:setVisible(false)
	if itemId then 
		self.money_itemId=itemId
		local item=Item:getOneItemByKey(itemId)
		local role=User:getRole()
		local itemNum=role:getSmeltBoxItemCount(itemId)
		self.Text_num:setVisible(true)
		self.Text_num:setString("当前拥有"..item.name..":"..itemNum)
	else
		self.Text_num:setVisible(false)
	end
	self.Text_title:setString(titleStr)
	self.Text_desc:setString(roleTextStr)
	if type(list)=="table" then 
		self:initBtnListView(list)
	else
		print("没有兑换材料")
	end
	self.Panel_back:releaseFunc(function ()
		self:hide()
	end)
	self.Panel_back1:releaseFunc(function ()
		self.Panel_back1:setVisible(false)
		self.Panel_num:setVisible(false)
	end)
end

function GoodsShowLayer:createItem(itemStr)
	local btn=self.Button_item:clone()
	Helper:convertUIByParent(btn)
	if itemStr and type(itemStr)=="string" then 
		btn.Text_name:setString(itemStr)
	end
	
	return btn
end

function GoodsShowLayer:initBtnListView(list)
	self.ListView_Item:removeAllItems()
	if not list or type(list)~="table" then 
		return 
	end
	for i,v in pairs(list) do 
		local itemName
		if v then 
			local item=Item:getOneItemByKey(v) 
			itemName=item.name
			local btn=self:createItem(itemName)
			self.index=i
			btn:releaseFunc(function ()
			self.Panel_back1:setVisible(true)
			self.Panel_num:setVisible(true)
			self:initNumPanel(itemName,v,self.ratio[self.index])
			end)
			self.ListView_Item:pushBackCustomItem(btn)
		end
	end
end

function GoodsShowLayer:initNumPanel(str,itemId,ratio)
	if not str or not itemId then 
		return 
	end
	local localRatio=1
	if ratio then 
		localRatio=ratio
	end
	self.item_desc:setString("你打算兑换多少"..str)
	self.Text_name1:setString("1个")
	self.Text_name2:setString("5个")
	self.Text_name3:setString("10个")
	self.Button_num1:releaseFunc(function ()
		self:btnDuiHuan(1,itemId,localRatio)
	end)
	self.Button_num2:releaseFunc(function ()
		self:btnDuiHuan(5,itemId,localRatio)
	end)
	self.Button_num3:releaseFunc(function ()
		self:btnDuiHuan(10,itemId,localRatio)
	end)
end

function GoodsShowLayer:btnDuiHuan(num,itemId,ratio)
	if not itemId then 
		print("兑换材料id出错")
		return 
	end
	local role=User:getRole()
	local money_num=role:getSmeltBoxItemCount(self.money_itemId)
	local item=Item:getOneItemByKey(self.money_itemId)
	if money_num>=num*ratio and role:checkCanBuyThings(itemId,num)==true then 
		role:addItemCount(itemId, num)
		local duihuanItem=Item:getOneItemByKey(itemId)
		role:addItemCount(self.money_itemId, -num*ratio)
		local itemNum=role:getSmeltBoxItemCount(self.money_itemId)
		PopText("成功兑换"..duihuanItem.name..num.."个！")
		self.Text_num:setString("当前拥有"..item.name..":"..itemNum)
	elseif money_num<num*ratio then
		PopText(item.name.."数量不足！")
	end

end

function GoodsShowLayer:showLayer(title,roleStr,itemId,list,ratio)
	self:initUI(title,roleStr,itemId,list,ratio)

	self:show()
end


function GoodsShowLayer:hideLayer()
	PopupLayerController:hideLayer("GoodsShowLayer",function (layer)
		layer:hide()
	end)
end

Helper:classDefNodeGetInstance(GoodsShowLayer)
return GoodsShowLayer00000000000000
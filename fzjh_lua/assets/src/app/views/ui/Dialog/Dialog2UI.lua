

local DialogTwoUI = class("DialogTwoUI", cc.Layer)

function DialogTwoUI:create()
	local p = DialogTwoUI:new()
	p:init()
	return p
end

function DialogTwoUI:init()
	self._round = require("Layer/Dialog/Dialog2UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.Image_kuang.Panel_row:setVisible(false)

	if Game:isOpenWeiXinShare() == true then
		self.Image_weixin:setVisible(true)
		self:setWeiXinShared()
	else
		self.Image_weixin:setVisible(false)	
	end
end

function DialogTwoUI:show(list)
	self:setVisible(true)
	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Button_3:setVisible(false)
	self:setListView(list)
end

function DialogTwoUI:hide()
	self:setVisible(false)
end

function DialogTwoUI:createOneRow(title, str)
	local row = self.Image_kuang.Panel_row:clone()
	Helper:convertUI(row)

	row:setVisible(true)
	row.Text_title:setString(title)
	row.Text_num:setString(str)
	return row
end

--list = {{title = "", str = ""}}
function DialogTwoUI:setListView(list)
	self.Image_kuang.ListView_list:removeAllItems()
	for i,v in ipairs(list) do
		local row = self:createOneRow(v.title, v.num)
		self.Image_kuang.ListView_list:pushBackCustomItem(row)
	end
end

function DialogTwoUI:setButton(name, title, func)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
		self[name].Text_name:setString(title)
	end

	self[name]:releaseFunc(function() 
			Audio:playEffect("xiaoAnNiu")
			self:hide()
			if func then
				func()
			end
		end)
end

function DialogTwoUI:setButton1(title, func)
	self:setButton("Button_1", title, func)
end

function DialogTwoUI:setButton2(title, func)
	self:setButton("Button_2", title, func)
end

function DialogTwoUI:setButton3(title, func)
	self:setButton("Button_3", title, func)
end
 
function DialogTwoUI:getRow(rowNum)
	if not rowNum or type(rowNum) ~= "number" then
		return
	end
	return
end

-- 微信分享功能
function DialogTwoUI:setWeiXinShared()
	self.Image_weixin:releaseFunc(function()
		local WXShare = require("app.models.wxShare.WXShare")
		WXShare:doShare()
	end)
end

return DialogTwoUI00000000000
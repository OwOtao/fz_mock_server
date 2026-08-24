

local DialogThreeUI = class("DialogThreeUI", cc.Layer)

function DialogThreeUI:create()
	local p = DialogThreeUI:new()
	p:init()
	return p
end

function DialogThreeUI:init()
	self._round = require("Layer/Dialog/Dialog3UI.lua").create()['root']
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

function DialogThreeUI:show(title, list, state)
	self:setVisible(true)
	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Button_3:setVisible(false)
	self.Button_4:setVisible(false)
	self:setTextTitle(title)
	self:setTextState(state)
	self:setListView(list)
	self:setBack()
end

function DialogThreeUI:hide()
	self:setVisible(false)
end

function DialogThreeUI:createOneRow(title, str)
	local row = self.Image_kuang.Panel_row:clone()
	Helper:convertUI(row)

	row:setVisible(true)
	row.Text_title:setString(title)
	row.Text_num:setString(str)
	return row
end

--list = {{title = "", str = ""}}
function DialogThreeUI:setListView(list)
	self.Image_kuang.ListView_list:removeAllItems()
	for i,v in ipairs(list) do
		local row = self:createOneRow(v.title, v.num)
		self.Image_kuang.ListView_list:pushBackCustomItem(row)
	end
end

function DialogThreeUI:setButton(name, title, func, unHide)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
	end

	self[name].Text_name:setString(title)
	self[name]:releaseFunc(function() 
			Audio:playEffect("xiaoAnNiu")
			if not unHide then
				self:hide()
			end
			if func then
				func()
			end
		end)
end

function DialogThreeUI:setButton1(title, func, unHide)
	self:setButton("Button_1", title, func, unHide)
end

function DialogThreeUI:setButton2(title, func, unHide)
	self:setButton("Button_2",title, func, unHide)
end

function DialogThreeUI:setButton3(title, func, unHide)
	self:setButton("Button_3",title, func, unHide)
end

function DialogThreeUI:setButton4(title, func, unHide)
	self:setButton("Button_4",title, func, unHide)
end

function DialogThreeUI:setTextState(str)
	if not str then
		self.Image_kuang.Panel_state:setVisible(false)
	else
		self.Image_kuang.Panel_state:setVisible(true)
	end
	self.Image_kuang.Panel_state.Text_state:setString(str)
end

function DialogThreeUI:setTextTitle(str)
	if not str then
		self.Panel_title:setVisible(false)
	else
		self.Panel_title:setVisible(true)
	end
	self.Panel_title.Text_title:setString(str)
end
 
function DialogThreeUI:getRow(rowNum)
	if not rowNum or type(rowNum) ~= "number" then
		return
	end
	return
end

function DialogThreeUI:setBack(isHide)
	if isHide == nil then
		isHide = true
	end
	self.Panel_back:setTouchEnabled(true)
	self.Panel_back:releaseFunc(function()
			if isHide == true then
				self:hide()
			end
		end)
end

function DialogThreeUI:getList()
	return self.Image_kuang.ListView_list:getItems()
end

-- 微信分享功能
function DialogThreeUI:setWeiXinShared()
	self.Image_weixin:releaseFunc(function()
		local WXShare = require("app.models.wxShare.WXShare")
		WXShare:doShare()
	end)
end

-- 设置List高度(闭关专用 - - )
function DialogThreeUI:setListHeight(isBiguan)
	if isBiguan == true then
		self.Image_kuang.ListView_list:setContentSize(self.Image_kuang:getContentSize())
		self.Image_kuang.ListView_list:move(cc.p(540, 300))
	else
		self:init()
	end
	
end

function DialogThreeUI:setDescTextVisible(isVisible)
	if isVisible==nil then 
	 	isVisible = true
	end
	self.Text_desc3:setVisible(isVisible)
	self.Text_desc2:setVisible(isVisible)
end

return DialogThreeUI00000000000000
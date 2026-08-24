local ChineseValentineMyQiyuanDialog = class("ChineseValentineMyQiyuanDialog", require("app.views.base.BaseLayer"))

local prayMap = {
	["caiyuanguangjin"] = "财源广进",
	["wugongyoucheng"] = "武功有成",
	["huarongyuemao"] = "花容月貌",
	["jinglichongpei"] = "精力充沛",
	["juexuezhaoshi"] = "绝学招式",
	["shangdenghaojiu"] = "上等好酒",
	["shenbingliqi"] =	"神兵利器",
	["meishijiayao"] =	"美食佳肴",
	["xuefuwuche"] =	"学富五车",
	["shimenxingwang"] = "师门兴旺",
	["jianghumeiyu"] =	"江湖美誉",
	["jingmaiyoucheng"] = "经脉有成",
	
}

function ChineseValentineMyQiyuanDialog:create()
	local p = ChineseValentineMyQiyuanDialog:new()
	p:init()
	return p
end

function ChineseValentineMyQiyuanDialog:init()
	self._UI = require("Layer/ChineseValentineUI/CVMyQiyuanUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self.Panel_CheckItem:setVisible(false)
	self:setPanelBack()
end


function ChineseValentineMyQiyuanDialog:getListDataFromWeb()
	HttpManagerEx:getWishList1(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			if MapIsEmpty(data) == false then
				self:setList(data)
			end
		else 
			PopText(errmsg)
		end
	end)
end


function ChineseValentineMyQiyuanDialog:setList(list)
	self.Panel_Check.ListView_Check:removeAllItems()
	for _, data in ipairs(list) do
		local row = self:createItem(data)
		self.Panel_Check.ListView_Check:pushBackCustomItem(row)
	end
	self.Panel_Check.ListView_Check:jumpToTop()
end


function ChineseValentineMyQiyuanDialog:createItem(data)
	local row = self.Panel_CheckItem:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_Pray:setString(prayMap[data.wish_type])
	local arr = string.split(data.create_time," ")
	row.Text_Time:setString(arr[1])	
	row.Text_WishTimes:setString(data.wished_times)
	return row
end

function ChineseValentineMyQiyuanDialog:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("ChineseValentineMyQiyuanDialog", function(layer)
			self:hide(true)
		end)
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(ChineseValentineMyQiyuanDialog)
return ChineseValentineMyQiyuanDialog 0000
local  TreasureList = require("script.others.Treasure")
local ShenShuHeChengLayer = class("ShenShuHeChengLayer", LayerEx)

function ShenShuHeChengLayer:create()
	local p = ShenShuHeChengLayer:new()
	p:init()
	return p
end

function ShenShuHeChengLayer:init()
	local UI = require("Layer/ShenShu/ShenShuHeChengUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setButtonBack()
end

function ShenShuHeChengLayer:initLayer()
	self.ListView:removeAllItems()
	local list = TreasureList["神书合成"]
	list = self:sortTable(list)
	local role = User:getRole()
	local itemPanel
	for k,book in pairs(list) do 
		local item = self:copyPanel() 
		if tonumber(k) % 2 == 1 then
			itemPanel = self.Panel_1:clone()
			self.ListView:pushBackCustomItem(itemPanel)
			item:addTo(itemPanel)
			item:setPosition(294,74)
		else
			item:addTo(itemPanel)
			item:setPosition(726,74)
		end
		item.Text_bookName:setString(book.Synthesisname)
		item:releaseFunc(function()
			local needBookList = string.split(book.Synthesisneed,",")
			local canHeCheng = true
			for i,needBook in pairs(needBookList) do 
				if role:getItem(needBook) == nil then
					PopText("您没有"..self:getBookNameById(needBook))
					canHeCheng = false
				end
			end
			if canHeCheng == true then
				for i,beedBook in pairs(needBookList) do 
					role:addItemCount(beedBook,-1)
				end
				role:addItemCount(book.Synthesisitem,1)
				local itemAttr = Item:getOneItemByKey(book.Synthesisitem)
				PopText("获得物品 "..tostring(itemAttr.name).. " X "..tostring(1))
				RichPrint("main",book.Synthesistext)
			end
			PopupLayerController:hideLayer("ShenShuHeChengLayer", function(layer)
				self:hide()
			end)
		end)
	end
end
function ShenShuHeChengLayer:sortTable(list)
	if list == nil then
		return
	end
	local tmpList = {}
	for k,v in pairs(list) do 
		tmpList[tonumber(k)] = v
	end
	return tmpList
end
function ShenShuHeChengLayer:getBookNameById(itemId)
	if itemId then
		local list = TreasureList["神书列表"]
		for k,v in pairs(list) do 
			if v.Godid == itemId then
				return v.Godname
			end
		end
		list = TreasureList["神书合成"]
		for k,v in pairs(list) do 
			if v.Synthesisitem == itemId then
				return v.Synthesisname
			end
		end
		return nil 
	end
	return nil
end
function ShenShuHeChengLayer:copyPanel()
	local row = self.Panel_item:clone()
	Helper:convertUI(row)
	row.Text_bookName:setFontName("Font/default.ttf")
	row.Text_bookName:setFontSize(48)
	row.Text_bookName:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	return row
end
function ShenShuHeChengLayer:setButtonBack()
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("ShenShuHeChengLayer", function(layer)
			self:hide()
		end)
	end)
end
Helper:classDefNodeGetInstance(ShenShuHeChengLayer)

return ShenShuHeChengLayer000000
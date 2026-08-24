local ChineseValentineCheckListLayer = class("ChineseValentineCheckListLayer", require("app.views.base.BaseLayer"))

local prayMap = require("app.models.Action.ChineseValentine.CVModel"):getPrayItemMap()


function ChineseValentineCheckListLayer:create()
	local p = ChineseValentineCheckListLayer:new()
	p:init()
	return p
end

function ChineseValentineCheckListLayer:init()
	self._UI = require("Layer/ChineseValentineUI/CVCheckListUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
	self:setClickBtn()
end

function ChineseValentineCheckListLayer:onResume()
	self:getListDataFromWeb()
end

function ChineseValentineCheckListLayer:getListDataFromWeb()
	HttpManagerEx:getWishList2(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			if MapIsEmpty(data) == false then
				self:setList(data)
			end
		end
	end)
end

function ChineseValentineCheckListLayer:setClickBtn()
	self.Button_Cancel:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		PopupLayerController:hideLayer("ChineseValentineCheckListLayer", function(layer)
			self:hide()
		end)
	end)
	
	self.Button_Check:releaseFunc(function()
		PopupLayerController:showLayer("ChineseValentineMyQiyuanDialog", function(layer)
			layer:getListDataFromWeb()
			layer:show(true)
		end)
	end)
end

function ChineseValentineCheckListLayer:setList(list)
	self.ListView_Ranking:removeAllItems()
	for _, v in ipairs(list) do
		local row = self:createItems(v)
		self.ListView_Ranking:pushBackCustomItem(row)
	end
	self.ListView_Ranking:jumpToTop()
end

function ChineseValentineCheckListLayer:createItems(userData)
	local row = self.Panel_item:clone()		
	Helper:convertUI(row)
	row.Text_name:setString(userData.name)
	row.Text_menpai:setString(userData.real_menpai)
	row.Text_Pray:setString(prayMap[userData.wish_type])
	
	if MapIsEmpty(userData.wished_users) then
		row.Text_Wish0:setVisible(false)
		row.Button_Wish:setVisible(true)
	else
		local m = nil
		if not MapIsEmpty(userData.wished_users) then
			for i, v in pairs(userData.wished_users) do
				if v == User:getUserId() then
					row.Text_Wish0:setVisible(true)
					row.Button_Wish:setVisible(false)
					break
				else
					row.Text_Wish0:setVisible(false)
					row.Button_Wish:setVisible(true)
				end
			end
		end
		
		
	end
	
	
	-- row.Text_Wish0:setVisible(false)
	local role = User:getRole()
	-- Helper:tableCover(userData, role)
	local imagePath
	if userData.yueka == true then
		imagePath = role:getFaceRankFrame(userData.portrait, true)
	else
		imagePath = role:getFaceRankFrame(userData.portrait, false)
	end
	row.Image_kuang:loadTexture(imagePath)
	
	-- 设置图片大小
	local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
	row.Image_kuang:setSize(texture:getContentSize())

	local present = require("app.presenters.HeadView.HVDPresent"):create(row.Image_looks,userData)
	present:showHead()
	
	row.Button_Wish:releaseFunc(function()
		HttpManagerEx:recordWishedData(userData.record_id, userData.userid, function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
				row.Button_Wish:setVisible(false)
				row.Text_Wish0:setVisible(true)
				local pot = role:getAttr("pot")
				local money = role:getAttr("money")
				local prizePot = userData.lv + 50
				local prizeMoney = userData.lv * 10
				role:setAttr("pot", pot + prizePot)
				role:setAttr("money",money + prizeMoney)
				PopText("您祝福了"..userData.name)
				PopText("潜能 +" .. prizePot)
				PopText("碎银 +" .. prizeMoney)
				RichPrint("main", "CYN你双手合十，对" .. userData.name .. "的祈福祝福了一番，只觉心中突有所感，整个人都精神了不少。")
				RichPrint("main","潜能 +"..prizePot)
				RichPrint("main","碎银 +" .. prizeMoney)
			else
				PopText(errmsg)
			end
		end)
	end)
	return row
end

Helper:classDefNodeGetInstance(ChineseValentineCheckListLayer)
return ChineseValentineCheckListLayer 0000000000
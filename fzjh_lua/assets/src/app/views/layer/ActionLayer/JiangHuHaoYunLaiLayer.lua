--江湖好运来界面
local JiangHuHaoYunLaiLayer = class("JiangHuHaoYunLaiLayer", LayerEx)
local goodLuck = require("script.others.goodluck")
 local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
function JiangHuHaoYunLaiLayer:create()
	local p = JiangHuHaoYunLaiLayer:new()
	p:init()
	return p
end

function JiangHuHaoYunLaiLayer:init()
	local UI = require("Layer/ActionUI/JiangHuHaoYunLaiUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setButtonFun()
	self:__setRuleFunc()
end

function JiangHuHaoYunLaiLayer:showLayer(actionId)
	self:show()
	self:setActionTime(actionId)
	self:getWebIssueData()
end

function JiangHuHaoYunLaiLayer:getWebIssueData()
	HttpManagerEx:getLuckyGoods("N",function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				self:setGoodsList(data.luck_list)
				self:setButton(data)
				self:initialization(data)
				self:setItemInfo(data)
				self._exchangeNum = data.exchangeNum
				self._exchangeNumLimit = data.exchangeNumLimit
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

function JiangHuHaoYunLaiLayer:initialization(data)
	self.Text_2:setString("元宝:"..data.yuanbao)
    self.Text_3:setString("江湖换物节")
    self.Text_5:setString("好运通宝:"..data.total_point)
end

function JiangHuHaoYunLaiLayer:setButton(data)

 	self.Button_refresh:releaseFunc(function()
       	local dialog = DialogALayer:getInstance()
        dialog:show("刷新将花费50元宝，确定刷新？")
        --dialog:setRichText( "刷新将花费50元宝，确定刷新？")
        dialog:setButton1("确定", function()
			HttpManagerEx:getLuckyGoods("Y",function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						self:setButton(data)
						self:initialization(data)
						self:setItemInfo(data)
						self._exchangeNum = data.exchangeNum
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end)
		dialog:setButton2("取消", function()
			dialog:hide()
		end)
    end)

    self.Button_exchange:releaseFunc(function()
        PopupLayerController:showLayer("HaoYunDuiHuanLayer", function(layer)
			layer:setExchangeNum(self._exchangeNum)
			layer:setExchangeNumLimit(self._exchangeNumLimit)
            layer:showLayer(function()
			self:getWebIssueData()
			end,
			data.total_point)
        end)
    end)
end

function JiangHuHaoYunLaiLayer:setItemInfo(data)
	local itemList = data.luck_goods
	self.Text_nothingShow:setVisible(false)
	self.ListView_item:removeAllItems()
	self.ListView_item:setItemsMargin(60)

	if MapIsEmpty(itemList) then 
		self.Text_nothingShow:setVisible(true)
		self.Text_nothingShow:setString("暂时没有可兑换物品\n每日15点刷新")
		return
	end
	local i=0
	for k,v in pairs(itemList) do
		local itemPanel,BgPanel
		i = i+1
		if math.mod(i-1, 2)==0 then 
			BgPanel = self.Panel_itemBg:clone()
			self.ListView_item:pushBackCustomItem(BgPanel)
		else
			BgPanel = self.ListView_item:getItem(math.ceil(i/2)-1)
			if not BgPanel then 
				print("BgPanel is not exist !!! ")
			end
		end
		itemPanel = self.Panel_item:clone()
		Helper:convertUIByParent(itemPanel)
		BgPanel:addChild(itemPanel)
		itemPanel.Text_name:setString(v.name)
		itemPanel.Text_num:setString(v.need.."好运通宝")
		itemPanel.Item_image:loadTexture(v.icon)
		if math.mod(i, 2)==0 then 
			itemPanel:setPosition(cc.p(490,15)) 
		else
			itemPanel:setPosition(cc.p(40,15))
		end
		
		itemPanel:releaseFunc(function ()
			local role = User:getRole()
			if not role:checkCanBuyThings(v.itemId,1) then
				-- PopText("您的背包空间已满，无法购买")
				return
			end
			local dialog = DialogALayer:getInstance()
			local itemAttr = role:getOneItemByKey(v.itemId)
			if not itemAttr then 
				print("不存在物品 ",v.itemId)
				return
			end
	        dialog:show()
	        dialog:setRichText(itemAttr.dsc.."\n是否要用YEL"..v.need.."NOR好运通宝兑换YEL1NOR个RED"..v.name.."NOR？")
	        dialog:setButton1("确定", function()
				HttpManagerEx:buyLuckyGoods(v.itemId,tonumber(v.id),function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then
							self:getWebIssueData()
							role:addItemCount(v.itemId, 1)
							PopText("获得"..v.name)
						else
							PopText(errmsg)
						end
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end)
			dialog:setButton2("取消", function()
				dialog:hide()
			end)
		end)
 	end
 	self.ListView_item:jumpToTop()
end 

function JiangHuHaoYunLaiLayer:setButtonFun()
	self.Button_back:releaseFunc(function()
		self:hide()
		-- self:destroyInstance()
	end)
end

-- @desc 设置活动时间
-- local textColor = cc.c3b(208,208,208)
function JiangHuHaoYunLaiLayer:setActionTime(actionId)
	if actionId == nil then
		return
	end
	
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		local year,month,day,time,hour,min
				year = tonumber(Helper:date("%Y", tonumber(data.start)))
        		month = tonumber(Helper:date("%m", tonumber(data.start)))
        		day = tonumber(Helper:date("%d", tonumber(data.start)))
				hour = tonumber(Helper:date("%H", tonumber(data.start)))
        		min = tonumber(Helper:date("%M", tonumber(data.start)))
        		time = "在"..year.."年"..month.."月"..day.."日活动上线后到"
				year =  tonumber(Helper:date("%Y", tonumber(data["end"])))
        		month = tonumber(Helper:date("%m", tonumber(data["end"])))
        		day = tonumber(Helper:date("%d", tonumber(data["end"])))
        		hour = tonumber(Helper:date("%H", tonumber(data["end"])))
        		min = tonumber(Helper:date("%M", tonumber(data["end"])))
        		time = time..year.."年"..month.."月"..day.."日".."可使用好运通宝兑换心仪物品！好运通宝可通过遁地符、分身符、十里香、清风醉等道具兑换获得。"
				-- self.RichText_Print:pushBackText(time, textColor, 255, Resource:getFontPath("default"), 48)
        	    self.Text_1:setString(time)
            end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function JiangHuHaoYunLaiLayer:setGoodsList(list)
	self.goodsList = list
end

function JiangHuHaoYunLaiLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuHaoYunLaiLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function JiangHuHaoYunLaiLayer:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(JiangHuHaoYunLaiLayer)

return JiangHuHaoYunLaiLayer000000000
local XianShiPointLayer = class("XianShiPointLayer", LayerEx)

function XianShiPointLayer:create()
	local p = XianShiPointLayer:new()
	p:init()
	return p
end

function XianShiPointLayer:init()
	self._UI = require("Layer/ActionUI/XianShiLiBaoPointUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:setShowAndHideAnimType("ROLL")

	-- 积分
	self.point = 0

	-- 购买的礼包次数
	self.count = 0

	-- 道具列表
	self.itemList = {}

	self:setBack()
	self:setButton()
	self:__setRuleFunc()

	-- if device.platform == "android" then
	-- 	self.Text_desc:setString("6月8日-6月27日23点59分内购买限时礼包有积分，\n买1次限时礼包可获得1点积分。")
	-- 	self.Text_desc_1:setString("积分兑换将持续到6月30日23点59分，\n活动结束后积分将被清零，请及时将积分进行兑换。")
	-- elseif device.platform == "ios" then
	-- 	self.Text_desc:setString("6月2日-6月27日23点59分内购买限时礼包有积分，\n买1次限时礼包可获得1点积分。")
	-- 	self.Text_desc_1:setString("积分兑换将持续到6月30日23点59分，\n活动结束后积分将被清零，请及时将积分进行兑换。")
	-- elseif device.platform == "windows" then
	-- 	self.Text_desc:setString("6月8日-6月27日23点59分内购买限时礼包有积分，\n买1次限时礼包可获得1点积分。")
	-- 	self.Text_desc_1:setString("积分兑换将持续到6月30日23点59分，\n活动结束后积分将被清零，请及时将积分进行兑换。")
	-- else
	-- end

	-- self.Text_desc:setString("8月5日-8月31日23点59分内购买限时礼包有积分，\n买1次限时礼包可获得1点积分。")
	-- self.Text_desc_1:setString("积分兑换将持续到9月2日23点59分，\n活动结束后积分将被清零，请及时将积分进行兑换。")
end

function XianShiPointLayer:showLayer(actionId)
	--self.count = count
	self:setActionTime(actionId)
end
function XianShiPointLayer:setActionTime(actionId)
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	-- Helper:print_lua_table(data)
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		-- local month,day,time,hour,min
        		-- month = tonumber(Helper:date("%m", tonumber(data.start)))
        		-- day = tonumber(Helper:date("%d", tonumber(data.start)))
        		-- time = month.."月"..day.."日活动上线-"
        		-- month = tonumber(Helper:date("%m", tonumber(data["end"])))
        		-- day = tonumber(Helper:date("%d", tonumber(data["end"])))
        		-- hour = tonumber(Helper:date("%H", tonumber(data["end"])))
        		-- min = tonumber(Helper:date("%M", tonumber(data["end"])))
        		-- time =time..month.."月"..day.."日"..hour.."时"..min.."分内累计充值\n可获得丰厚奖励"
        		-- self.Text_5:setString(time)
        		local _end = Helper:getDef(data["end"],GetTime())
        		local _change_end = _end 
        		local str = "活动开始后~"

        		--限时礼包兑换结束时间
        		local month = Helper:date("%m",_change_end)
        		str = str..tostring(month).."月"
				local day = Helper:date("%d",_change_end)
				str = str .. tostring(day) .. "日"
				local hours = Helper:date("%H",_change_end)
				str = str .. tostring(hours) .. "点"
				local min = Helper:date("%M",_change_end)
				str = str .. tostring(min) .. "分"

				str = str.."购买限时礼包可获得积分，\n买1次限时礼包可获得1积分"
        		self.Text_desc:setString(str)

        		local str1 = "积分兑换将持续到" .. month .."月"..day.."日"..hours .. "点"..min.."分。"

        		self.Text_desc_1:setString(str1)
        		self:getState()
				self:show()
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
-- 获取积分
function XianShiPointLayer:getState()
	HttpManagerEx:getXianShiPoint(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
            	if data ~= nil and data.list ~= nil then
            		self.point = data.total
            		Helper:print_lua_table(data)
            		self.itemList = data.list
            		self:updateUI()
					-- self:show()
            	end
            else
                --PopText(errmsg)
            end
    	end
	end, IS_SHOW_WAITING)
end

function XianShiPointLayer:updateUI()
	self.Text_PointCount:setString("本次活动剩余积分:" .. self.point)

	if MapIsEmpty(self.itemList) == true then
		self.Button_exchange1:setEnabled(false)
		self.Button_exchange2:setEnabled(false)
		self.Button_exchange3:setEnabled(false)
		self.Button_exchange4:setEnabled(false)
		return
	end

	self.Image_reward1.Text_desc:setString(Item:getOneItemByKey(self.itemList[1].item_id).name .. "X1(消耗2积分)")
	self.Image_reward2.Text_desc:setString(Item:getOneItemByKey(self.itemList[2].item_id).name .. "X1(消耗3积分)")
	self.Image_reward3.Text_desc:setString(Item:getOneItemByKey(self.itemList[3].item_id).name .. "X1(消耗5积分)")
	self.Image_reward4.Text_desc:setString(Item:getOneItemByKey(self.itemList[4].item_id).name .. "X1(消耗10积分)")


	self.Button_exchange1:setEnabled(self.point >= self.itemList[1].points)
	self.Button_exchange2:setEnabled(self.point >= self.itemList[2].points)
	self.Button_exchange3:setEnabled(self.point >= self.itemList[3].points)
	self.Button_exchange4:setEnabled(self.point >= self.itemList[4].points)
end

function XianShiPointLayer:setBack()
	self.Button_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

function XianShiPointLayer:setButton()
	local function checkItems()
		-- 检测背包空间 不足不能兑换
		local role = User:getRole()

		local weight = role:getAttr("weight")
		local items = role:getAttr("items")

		-- 1个道具需要1个背包空位
		if weight - #items < 1 then
			PopText("背包剩余空间不足 无法兑换")
			return false
		end

		return true
	end

	self.Button_exchange1:releaseFunc(function()
		local itemId = self.itemList[1].item_id
		if checkItems() and itemId ~= nil then
			PopYuanBaoBuyItemLayer(itemId, function(eventType)
	                if eventType == "success" then
	                	local role = User:getRole()
	                	role:addItemCount(itemId, 1)
	                	PopText("获得 " .. Item:getOneItemByKey(itemId).name .. "X1")
	                	self:getState()
	                end
	            end)
		end
	end)
	self.Button_exchange2:releaseFunc(function()
		local itemId = self.itemList[2].item_id
		if checkItems() and itemId ~= nil then
			PopYuanBaoBuyItemLayer(itemId, function(eventType)
	                if eventType == "success" then
	                	local role = User:getRole()
	                	role:addItemCount(itemId, 1)
	                	PopText("获得 " .. Item:getOneItemByKey(itemId).name .. "X1")
	                	self:getState()
	                end
	            end)
		end
	end)
	self.Button_exchange3:releaseFunc(function()
		local itemId = self.itemList[3].item_id
		if checkItems() and itemId ~= nil then
			PopYuanBaoBuyItemLayer(itemId, function(eventType)
	                if eventType == "success" then
	                	local role = User:getRole()
	                	role:addItemCount(itemId, 1)
	                	PopText("获得 " .. Item:getOneItemByKey(itemId).name .. "X1")
	                	self:getState()
	                end
	            end)
		end
	end)
	self.Button_exchange4:releaseFunc(function()
		local itemId = self.itemList[4].item_id
		if checkItems() and itemId ~= nil then
			PopYuanBaoBuyItemLayer(itemId, function(eventType)
	                if eventType == "success" then
	                	local role = User:getRole()
	                	role:addItemCount(itemId, 1)
	                	PopText("获得 " .. Item:getOneItemByKey(itemId).name .. "X1")
	                	self:getState()
	                end
	            end)
		end
	end)
end

function XianShiPointLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function XianShiPointLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function XianShiPointLayer:__showRule()
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

Helper:classDefNodeGetInstance(XianShiPointLayer)

return XianShiPointLayer00000000
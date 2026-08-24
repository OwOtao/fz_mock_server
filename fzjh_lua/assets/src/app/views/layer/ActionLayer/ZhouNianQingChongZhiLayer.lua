
local ZhouNianQingChongZhiLayer = class("ZhouNianQingChongZhiLayer", LayerEx)

function ZhouNianQingChongZhiLayer:create()
	local p = ZhouNianQingChongZhiLayer:new()
	p:init()
	return p
end
-- [{"date": "", is_received: "", reward: [{"itemId": "xxx", "number": 1, "imgPath":""}]}, …]
local tab = {

}
function ZhouNianQingChongZhiLayer:showLayer(actionId)
	local layer = self:getInstance()
	layer:show()
	-- layer:setViewList(tab)
	layer:setActivityTime(actionId)
	layer:getAnniversaryRewardList()
end
function ZhouNianQingChongZhiLayer:init()
	local UI = require("Layer/ActionUI/ZhouNianQingChongZhiUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self.canGetReward = true
end
function ZhouNianQingChongZhiLayer:setBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end
function ZhouNianQingChongZhiLayer:setActivityTime(actionId)
	print("____________________________________________________"..actionId)
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
    			local str = "活动时间："
    			str = str..tostring(Helper:date("%Y",tonumber(data.start))).."年"
    			str = str..tostring(Helper:date("%m",tonumber(data.start))).."月"
    			str = str..tostring(Helper:date("%d",tonumber(data.start))).."日"

    			str = str.."-"..tostring(Helper:date("%Y",tonumber(data["end"]))).."年"
      			str = str..tostring(Helper:date("%m",tonumber(data["end"]))).."月"
    			str = str..tostring(Helper:date("%d",tonumber(data["end"]))).."日"
        		self.Text_3:setString(str)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function ZhouNianQingChongZhiLayer:setViewList(list)
	self.count = 0
	self.panel = nil
	self.ListView_3:removeAllItems()
	local todayDate = Helper:date("%Y%m%d",tonumber(GetTime()))
	print(todayDate)
	local dateStr = {"第一天","第二天","第三天","第四天","第五天","第六天","第七天","第八天","第九天","第十天","第十一天","第十二天","第十三天","第十四天","第十五天"}
	for k,v in pairs(list) do 
		if self.count %5 == 0 then
			self.panel =self:clonePanel("Panel_5") 
			self.ListView_3:pushBackCustomItem(self.panel)
			self.count = 0
		end
		local row = self:clonePanel("Panel_1")
		if v.is_received == 0 then
			row:releaseFunc(function()
				PopText("没有可领取的奖励")
			end)
		elseif v.is_received == 1 then
			row.Image_tag:setVisible(true)
			row:releaseFunc(function()
				if self.canGetReward == true then
					self.canGetReward = false
					local reTab = {}
					for i,value in pairs(v.reward) do 
						if value.itemId ~= "yuanbao" then
							reTab[value.itemId] = value.number
						end
					end
					if User:getRole():checkCanBuyTwoOrMoreThings(reTab) == true then
						self:getAnniversaryReward({v.date},function(data)
							if data[tostring(v.date)] == 0 then
								list[k].is_received = 2
								row.Image_tag:loadTexture("Image/UI/SignInUI/signGou.png",0)
								self.canGetReward = true
								for i,value in pairs(v.reward) do 
									if value.itemId ~= "yuanbao" then
										local item = User:getRole():getOneItemByKey(value.itemId)
										PopText("获得物品"..item.name.."X"..tostring(value.number))
										User:getRole():addItemCount(value.itemId,value.number)
									else
										PopText("获得物品"..User:getRole():getCHAttrName(value.itemId).."X"..tostring(value.number))
									end
								end
								row:releaseFunc(function()
									PopText("没有可领取的奖励")
								end)
							else
								PopText("领取失败")
							end
							self.canGetReward = true
						end)
					else
						self.canGetReward = true
					end
				else
					PopText("请稍等")
				end
			end)
		else
			row.Image_tag:setVisible(true)
			row.Image_tag:setVisible(true)
			row.Image_tag:loadTexture("Image/UI/SignInUI/signGou.png",0)
			row:releaseFunc(function()
				PopText("没有可领取的奖励")
			end)
		end
		if tonumber(v.date) == tonumber(todayDate) then
			row.Image_kuang:setVisible(true)
		end
		for i,value in pairs(v.reward) do 
			row["Image_item"..tostring(i)]:loadTexture(value.imgPath,0)
			print("Image_item"..tostring(i),value.imgPath)
		end
		row.Text_5:setString(dateStr[k])
		row:addTo(self.panel) 
		row:setPosition((self.count+0.5)*190+60,217)
		self.count = self.count + 1
	end
end
function ZhouNianQingChongZhiLayer:clonePanel(nodeName)
	if self[nodeName] then
		local row = self[nodeName]:clone()
		Helper:convertUI(row)
		return row
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/29 20:07:37
-- @desc 一键领取
function ZhouNianQingChongZhiLayer:setButtonGetAllReward(list)
	self.Button_5:releaseFunc(function()
		if self.canGetReward == true then
			if self:getCanGetReward(list) == false then
				PopText("没有可领取的奖励")
				self.canGetReward = true
				return 
			end
			self.canGetReward = false
			local tmptab = {}
			for k,v in pairs(self.reward) do 
				if k ~= "yuanbao" then
					tmptab[k] = v
				end
			end
			if User:getRole():checkCanBuyTwoOrMoreThings(tmptab) == true then
				self:getAnniversaryReward(self.rewardDate,function(data)
					self:dealRewardList(data)
					for k,v in pairs(self.reward) do 
						if k ~= "yuanbao" then
							local item = User:getRole():getOneItemByKey(k)
							PopText("获得物品"..item.name.."X"..tostring(v))
							User:getRole():addItemCount(k,v)
						else
							PopText("获得物品"..User:getRole():getCHAttrName(k).."X"..tostring(v))	
						end
					end
					tab = self.rewardList
					self:setViewList(tab)
					self.canGetReward = true
				end)
			else
				PopText("背包空间不足,无法领取")
				self.canGetReward = true
			end
		else
			PopText("请稍等")
		end
	end)

end

function ZhouNianQingChongZhiLayer:dealRewardList(data)
	local dateStr = {"第一天","第二天","第三天","第四天","第五天","第六天","第七天","第八天","第九天","第十天","第十一天","第十二天","第十三天","第十四天","第十五天"}
	for k,v in pairs(data) do 
		if v == false then 
			for i,value in pairs(self.rewardList) do 
				if tostring(value.date) == k then
					PopText(dateStr[i].."领取失败")
					for j,item in pairs(value.reward) do 
						self:addRewardItem(item.itemId,0-item.number)
					end
					self.rewardList[i].is_received = 1
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/29 20:10:06
-- @desc 获取所有可领取奖励的列表
function ZhouNianQingChongZhiLayer:getCanGetReward(list)
	list = Helper:getDef(list,{})
	self.rewardList = {}
	self.rewardDate = {}
	self.reward = {}
	local returnType = false
	for k,v in pairs(list) do 
		local tab_cop = v
		if v.is_received == 1 then
			table.insert(self.rewardDate,v.date)
			for i,value in pairs(v.reward) do 
				self:addRewardItem(value.itemId,value.number)
			end
			tab_cop.is_received = 2
			returnType = true
		end
		table.insert(self.rewardList,tab_cop)
	end
	return returnType
end
function ZhouNianQingChongZhiLayer:addRewardItem(itemId,count)
	if not itemId or not count then
		return
	end
	if self.reward[itemId] == nil then
		self.reward[itemId] = count
	else
		self.reward[itemId] = self.reward[itemId] + count
	end
	if count < 0 then
		if self.reward[itemId] == 0 then
			self.reward[itemId] = nil
		end
	end
end
function ZhouNianQingChongZhiLayer:printPreview(str, verticalSpace)
	self:initRichTextPreview()
	local textColor = cc.c3b(255,255,255)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichTextPreview()
	end
	self.Panel_3:setVisible(false)
	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_Print:pushBackNewLine()
		self.RichText_Print:pushBackNewLine(verticalSpace)
		self.RichText_Print:setCascadeOpacity(0)
		self:delayFunc(0.4,function ()
			self.RichText_Print:jumpToTop()
			self.RichText_Print:setCascadeOpacity(255)
		end)
	end
end
function ZhouNianQingChongZhiLayer:initRichTextPreview()
	local x, y = self.Panel_3:getPosition()
	local size = self.Panel_3:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_3:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_3:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 10:08:36
-- @desc 获取奖励列表
function ZhouNianQingChongZhiLayer:getAnniversaryRewardList()
	HttpManagerEx:getAnniversaryRewardList(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			-- Helper:print_lua_table(data)
			tab = data

			self:setViewList(tab)
			self:setBack()
			local str = "活动期间内，每日充值RED任意金额NOR，即可获得一次RED神秘大礼NOR！"
			self:printPreview(str)
			self:setButtonGetAllReward(tab)
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/30 10:11:36
-- @desc 领取单个奖励奖励
function ZhouNianQingChongZhiLayer:getAnniversaryReward(reTab,func)
	HttpManagerEx:getAnniversaryReward(reTab,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			func(data)
		else
			PopText(errmsg)
			self.canGetReward = true
		end
	end,IS_SHOW_WAITING)
end


Helper:classDefNodeGetInstance(ZhouNianQingChongZhiLayer)

return ZhouNianQingChongZhiLayer0
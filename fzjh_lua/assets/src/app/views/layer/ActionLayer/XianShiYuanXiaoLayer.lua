local XianShiYuanXiaoLayer = class("XianShiYuanXiaoLayer", LayerEx)

function XianShiYuanXiaoLayer:create()
	local p = XianShiYuanXiaoLayer:new()
	p:init()
	return p
end

function XianShiYuanXiaoLayer:init()
	local UI = require("Layer/ActionUI/XianShiLiBao1UI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self.surplusTime = 0		-- 礼包到期时间
	self.surplusCount = 0		-- 礼包剩余购买次数

	self:setBack()
	self:setButton()

	if device.platform == "android" then
		self.Panel_item1.Text_name:setString("武功秘典")
		self.Panel_item4.Image_zhuzi:loadTexture("Image/UI/StoreUI/juejinchan.png")
		self.Panel_item4.Text_name:setString("掘金铲")
		self.Panel_item4.Text_num:setString("X2")
	elseif device.platform == "ios" then
		self.Panel_item1.Text_name:setString("武功秘典")
		self.Panel_item4.Image_zhuzi:loadTexture("Image/UI/StoreUI/juejinchan.png")
		self.Panel_item4.Text_name:setString("掘金铲")
		self.Panel_item4.Text_num:setString("X2")
	elseif device.platform == "windows" then
		self.Panel_item1.Text_name:setString("武功秘典")
		self.Panel_item4.Image_zhuzi:loadTexture("Image/UI/StoreUI/juejinchan.png")
		self.Panel_item4.Text_name:setString("掘金铲")
		self.Panel_item4.Text_num:setString("X2")
	else
	end

	self.Button_confirm_0:setEnabled(false)

	-- 更新剩余时间
	self:schedule(
	function(dt)
		self:UpdateTimeAndCount(dt)
	end, 1)
end

function XianShiYuanXiaoLayer:setBack()
	self.Panel_back:releaseFunc(function()
		if self.Image_help:isVisible() == true then
			self:hidePopDsc()
		else
			self.Button_confirm_0:setVisible(false)
			self:hide()
			self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
		end
	end)
end

-- 更新时间
function XianShiYuanXiaoLayer:UpdateTimeAndCount(dt)
	local overTime = self.surplusTime
	local currTime = GetTime()
	if currTime >= overTime then
		self.Text_Time:setString("活动已经结束")
		self.Text_Count:setString("剩余0个")
		return
	end
	local year, month, day, hour, minute, second = Helper:getExpiredTime(overTime, currTime)

	local str = ""
	if tonumber(month) >= 1 then
		str = str .. month .. "月"
	end
	self.Text_Time:setString(str .. day .. "天" .. hour .. "小时" .. minute .. "分" .. second .. "秒")

	self.Text_Count:setString("剩余" .. self.surplusCount .. "个")
end

-- 获取限时礼包状态
function XianShiYuanXiaoLayer:getState()
	self.Button_confirm_0:setVisible(true)

	HttpManagerEx:getNewYearFestivalState(3,function(status, errcode, errmsg, data)
		self.surplusTime = 0
        self.surplusCount = 0
        if status == 200 then
            if errcode == 0 then
            	if data ~= nil and data.is_open == 1 and data.status == 1 then
        			self.surplusTime = data["end"]
        			self.surplusCount = data.left
            	end
            else
                --PopText(errmsg)
            end
    	end
	end, IS_SHOW_WAITING)
end

function XianShiYuanXiaoLayer:setButton()
	self.Button_confirm:releaseFunc(function()
		-- 检测背包空间 不足不能购买
		local role = User:getRole()

		local weight = role:getAttr("weight")
		local items = role:getAttr("items")

		local currTime = GetTime()
		local endTime = self.surplusTime
		if currTime >= endTime then
			PopText("活动已经结束了")
			return
		end

		if self.surplusCount == 0 then
			PopText("礼包已经卖完了")
			return
		end

		-- 5个道具需要5个背包空位
		if weight - #items < 6 then
			PopText("背包剩余空间不足 无法购买")
			return
		end

		PopYuanBaoBuyItemLayer("xianshilibao", function(eventType)
                if eventType == "success" then
                	role:addItemCount("jiu106", 2)
					role:addItemCount("qiannengdan", 8)
					role:addItemCount("jingxinwan", 6)
					role:addItemCount("jiu107", 4)

					if device.platform == "android" then
						role:addItemCount("chunjie504", 1)
                		role:addItemCount("juejinchan", 2)
					elseif device.platform == "ios" then
						role:addItemCount("chunjie504", 1)
                		role:addItemCount("juejinchan", 2)
					elseif device.platform == "windows" then
						role:addItemCount("chunjie504", 1)
	                	role:addItemCount("juejinchan", 2)
					else

					end
					PopText("获得 醉梦生 X2")
					PopText("获得 潜能丹 X8")
					PopText("获得 静心丸 X6")
					PopText("获得 清风醉 X4")

					if device.platform == "android" then
						PopText("获得 武功秘典 X1")
						PopText("获得 掘金铲 X2")
					elseif device.platform == "ios" then
						PopText("获得 武功秘典 X1")
						PopText("获得 掘金铲 X2")
					elseif device.platform == "windows" then
						PopText("获得 武功秘典 X1")
						PopText("获得 掘金铲 X2")
					else
					end

					self:getState()
                end
            end)
	end)

	self.Button_point:releaseFunc(function()
		local XianShiPointLayer = require("app.views.layer.ActionLayer.XianShiPointLayer")
		XianShiPointLayer:getInstance():showLayer(12 - self.surplusCount)
	end)
end

Helper:classDefNodeGetInstance(XianShiYuanXiaoLayer)

return XianShiYuanXiaoLayer0
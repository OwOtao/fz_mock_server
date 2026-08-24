local ZhangDanLayer = class("ZhangDanLayer", LayerEx)

function ZhangDanLayer:create()
	local p = ZhangDanLayer:new()
	p:init()
	return p
end

function ZhangDanLayer:init()
	local UI = require("Layer/ActionUI/JiangHuHuiYiUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)
	self:setVisible(false)
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/10 21:45:39
-- @desc 账单页面显示
function ZhangDanLayer:showLayer()
	HttpManagerEx:getShareLink(function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				self:chaKan(data)
				self:shareLink(data)
				self:show()
			else
				PopText(errmsg)
			end
			return true
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/10 20:18:17
-- @desc 查看按钮
function ZhangDanLayer:chaKan(data)
	if MapIsEmpty(data) == true or data.url == nil then
		return
	end
	self.Button_open:releaseFunc(function()
		local layer = require("app.views.layer.CommunityLayer.FengXiangLayer"):getInstance()
		layer:setUrl(data.url)
		layer:setTitle("江湖回忆录")
		layer:show()
		self.__Is_Looking = true
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/11 02:01:51
-- @desc 微信分享按钮
-- local title = "良心独立游戏佳作——画面简约内容丰富，高自由度的武侠世界，轻松的放置玩法以及代入感极高的探索解谜。没时间解释了，拔剑吧，骚年！"
local titleList = {
	"年关时分，来看看你的江湖历程。",
	"放置江湖年度大侠之路，启程。",
	"江湖人生，人生江湖。你的放置江湖的年度历程。",
	"来看看你这一年在放置江湖做了什么！",
}
local text = "没时间解释了，快拔剑吧！"
function ZhangDanLayer:shareLink(data)
	if MapIsEmpty(data) == true or data.url == nil then
		return
	end
	local role = User:getRole()
	self.Button_share:releaseFunc(function()
		if self.__Is_Looking ~= true then
			PopText("需观看江湖回忆录后方可进行分享")
			return
		end
		if device.platform == "windows" then
			return
		end
		
		local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
		local waitingLayer = WaitingLayer:createInRunningScene()
        waitingLayer:setText("请稍后...")
		
		SdkMethod:WeiXin_setAboutLink(data.url, titleList[math.random(1, #titleList)], text)
		SdkMethod:WeiXin_SetCallback(function(eventName)
			if eventName == "成功" then
				HttpManagerEx:doShare(function(status, errcode, errmsg, data,isEncrypted)
					if status == 200 then
						if errcode == 0 then
							if MapIsEmpty(data) == true or MapIsEmpty(data.items) == true then
								PopText("奖励数据异常,请联系客服!")
							else
								-- for k,v in pairs(data.items) do
								-- 	local itemAttr = Item:getOneItemByKey(k)
								-- 	if MapIsEmpty(itemAttr) == true then
								-- 		if DEBUG_MODE == 1 then
								-- 			assert(nil, "这个物品的资源不存在, itemId = "..tostring(k))
								-- 		end
								-- 	else
								-- 		role:addItemCount(k, tonumber(v))
								-- 		PopText("获得"..tostring(itemAttr.name).. " X " ..tostring(v))
								-- 	end

								-- end
								PopText("获得元宝 X 88")
							end
						else
							PopText(errmsg)
						end
						waitingLayer:hideAndRemoveSelf()
						return true
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
			else
				waitingLayer:hideAndRemoveSelf()
			end
		end)
		SdkMethod:shareToWeixinFriends()
	end)
end

Helper:classDefNodeGetInstance(ZhangDanLayer)
return ZhangDanLayer000000
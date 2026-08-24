local FlyKiteLayer = class("FlyKiteLayer", LayerEx)
function FlyKiteLayer:create()
	local p = FlyKiteLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:08:09
-- @desc 奖励列表
local rewardList = 
{
	[1] = {
		name = "今日最高积分",
		num = 4,
		num_id = "today_point"
	},
	[2] = {
		name = "风筝大赛总积分",
		num = 3,
		num_id = "total_point"
	},
	[3] = {
		name = "当前门派排名",
		num = 2,
		num_id = "rank"
	},
	[4] = {
		name = "当前个人排名",
		num = 1,
		num_id = "personal_rank"
	},
-- 今日答题积分
-- 今日放风筝积分
-- 活动总积分
-- 活动积分排名
 -- ["yestoday_point"] = 97,
 -- ["ffz_max_point"] = 0,
 -- ["total_point"] = 97,
 -- ["q_point"] = 0,
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 显示赛龙舟活动
function FlyKiteLayer:showBoatLayer(data)
	local layer = self:getInstance()
	-- Helper:print_lua_table(data)
	layer:start(data)
end

function FlyKiteLayer:init()
	local UI = require("Layer/ActionUI/PersonalRankingUI.lua").create()['root']
	UI:addTo(self)
	self:setVisible(true)
	Helper:convertUIByParent(self)
end
function FlyKiteLayer:start(data)
	if PRINT_MODE == 1 then
        Helper:print_lua_table(data)
    end
	self:initTable(data)
	self:setBack()
	self:buttonToRankList()
	self:setDscText()
	self:show()
end
function FlyKiteLayer:initUI()
	self.ListView_1:removeAllItems()
	for i=1,table.getn(rewardList) do 
		local panel =self:clonePanel(self.Panel_4)
		panel.Text_name:setString(rewardList[i].name..":")
		panel.Text_num:setString(tostring(rewardList[i].num))
		panel.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		panel.Text_num:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		self.ListView_1:pushBackCustomItem(panel)		
	end
end
function FlyKiteLayer:setDscText()
	 self.Text_1:setString("\n活动时间：3月20日0时 — 3月26日23时59分\n活动期间内前往平安小镇寻找“刘鹤君”可参与风筝大赛，每日可参与三次，取成绩最好的一次进行保存及累计，结束活动后根据“门派”与“个人”排行来领取奖励。传承积分不保留。\n领奖时间：3月27日12时 — 3月31日23时59分")
	-- self.Text_1_0:setString("舟活动，完成活动可获取赛龙舟活动积分，在活动结")
	-- self.Text_1_1:setString("束后根据玩家门派的最高积分排名来获取奖励。")
end
function FlyKiteLayer:initTable(tab)
	for i=1,table.getn(rewardList) do 
		rewardList[i].num = Helper:getDef(tab[rewardList[i].num_id], 0) 
	end
	self:show()
	-- Helper:print_lua_table(rewardList)
	self:initUI()
end
function FlyKiteLayer:clonePanel(panel)
	if panel == nil then
		return
	end
	local row = panel:clone() 
	Helper:convertUI(row)
	return row
end
function FlyKiteLayer:setBack()
	self.Panel_back:releaseFunc(function()
		-- self:hide()
		-- self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
			PopupLayerController:hideLayer("FlyKiteLayer",function(layer)
				layer:hide()
			end)
	end)
end
function FlyKiteLayer:buttonToRankList()
	self.Text_title:setString("风筝大赛")
	local str = "本次活动传承后将继承风筝大赛积分\n本次活动结束时将根据积分排行榜发放门派、个人奖励"
	self.Text_19:setString(str)
	self.Text_19:setVisible(false)
	--赛龙舟门派积分排行
	self.Button_10.Text_TotalPrizeName:setString("门派积分排行榜")
	self.Button_10:releaseFunc(function()
		PopupLayerController:showLayer("FlyKiteRankListLayer",function(layer)
			layer:test()
		end)
	end)

	--新添加的个人排行
	self.Button_11.Text_TotalPersonalName:setString("个人积分排行榜")
	self.Button_11:releaseFunc(function()
		PopupLayerController:showLayer("BoatPersonalRankingLayer",function(layer)
			HttpManagerEx:getLongZhouDailyBoard(2,function(status, errcode, errmsg, data)
				if PRINT_MODE == 1 then
					print("111111111111111111111111111111222222222222222222222222222222222222222222222222222")
					Helper:print_lua_table(data.body)
				end
				if status == 200 then 
					if errcode == 0 then
						layer:showLayer()
						layer:createListViews(data.body)
						-- layer:showPeopleTop(data.body)
					else
						PopText(tostring(errmsg))
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end)
	end)
end

--春分积分的调用(显示春分积分活动)
function FlyKiteLayer:getAllTypePoint()
	HttpManagerEx:getAllTypePoint(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self:show()
			self:initTable(data)
			self:setBack()
			self:buttonToRankList()
		else
			PopText(errmsg)
			PopupLayerController:hideLayer("FlyKiteLayer",function(layer)
				layer:hide()
			end,0)
			-- self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
			return
		end
	end, IS_SHOW_WAITING)
end
Helper:classDefNodeGetInstance(FlyKiteLayer)
return FlyKiteLayer
00000000000
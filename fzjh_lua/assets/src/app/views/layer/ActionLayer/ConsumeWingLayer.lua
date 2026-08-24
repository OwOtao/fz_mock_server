local StoreLayer = require("app.views.layer.StoreLayer.StoreLayer")
local ConsumeWingLayer = class("ConsumeWingLayer", LayerEx)
function ConsumeWingLayer:create()
	local p = ConsumeWingLayer:new()
	p:init()
	return p
end
function ConsumeWingLayer:init()
	local UI = require("Layer/ActionUI/ConsumeWingUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setCongif()
	self:setBurronToPayAndBurronBack()
	self:setVisible(false)
	self:__setRuleFunc()
end

local reward = {
 ["gift_list"] = {
 },
 ["config"] = {
     ["strategy_id"] = 1,
     ["extra"] = {
     },
     ["base"] = {
 ["500"] = {
	     [1] = {
	         ["image"] = "Image/UI/StoreUI/juhuajiu100.png",
	         ["id"] = "jiu106",
	         ["getType"] = 1,
	         ["count"] = 6,
	         ["name"] = "醉梦生",
	         ["showType"] = 1,
	     },
	     [2] = {
	         ["image"] = "Image/UI/StoreUI/qiannengdan.png",
	         ["id"] = "qiannengdan",
	         ["getType"] = 1,
	         ["count"] = 10,
	         ["name"] = "潜能丹",
	         ["showType"] = 1,
	     },
	     [3] = {
	         ["image"] = "Image/UI/SignInUI/baoyu.png",
	         ["id"] = "gongxiandian100",
	         ["getType"] = 1,
	         ["count"] = 14,
	         ["name"] = "宝玉",
	         ["showType"] = 1,
	     },
	     [4] = {
	         ["image"] = "Image/UI/SignInUI/meiyu.png",
	         ["getType"] = 1,
	         ["count"] = 280,
	         ["name"] = "江湖美誉",
	         ["showType"] = 1,
	     },
	 },
	 ["30"] = {
	     [1] = {
	         ["image"] = "Image/UI/StoreUI/juhuajiu100.png",
	         ["id"] = "jiu106",
	         ["getType"] = 1,
	         ["count"] = 1,
	         ["name"] = "醉梦生",
	         ["showType"] = 1,
	     },
	     [2] = {
	         ["image"] = "Image/UI/StoreUI/qiannengdan.png",
	         ["id"] = "qiannengdan",
	         ["getType"] = 1,
	         ["count"] = 2,
	         ["name"] = "潜能丹",
	         ["showType"] = 1,
	     },
	     [3] = {
	         ["image"] = "Image/UI/SignInUI/baoyu.png",
	         ["id"] = "gongxiandian100",
	         ["getType"] = 1,
	         ["count"] = 1,
	         ["name"] = "宝玉",
	         ["showType"] = 1,
	     },
	     [4] = {
	         ["image"] = "Image/UI/SignInUI/meiyu.png",
	         ["getType"] = 1,
	         ["count"] = 20,
	         ["name"] = "江湖美誉",
	         ["showType"] = 1,
	     },
	 },
	 ["100"] = {
	     [1] = {
	         ["image"] = "Image/UI/StoreUI/juhuajiu100.png",
	         ["id"] = "jiu106",
	         ["getType"] = 1,
	         ["count"] = 2,
	         ["name"] = "醉梦生",
	         ["showType"] = 1,
	     },
	     [2] = {
	         ["image"] = "Image/UI/StoreUI/qiannengdan.png",
	         ["id"] = "qiannengdan",
	         ["getType"] = 1,
	         ["count"] = 3,
	         ["name"] = "潜能丹",
	         ["showType"] = 1,
	     },
	     [3] = {
	         ["image"] = "Image/UI/SignInUI/baoyu.png",
	         ["id"] = "gongxiandian100",
	         ["getType"] = 1,
	         ["count"] = 4,
	         ["name"] = "宝玉",
	         ["showType"] = 1,
	     },
	     [4] = {
	         ["image"] = "Image/UI/SignInUI/meiyu.png",
	         ["getType"] = 1,
	         ["count"] = 80,
	         ["name"] = "江湖美誉",
	         ["showType"] = 1,
	     },
	 },
	 ["800"] = {
	     [1] = {
	         ["image"] = "Image/UI/StoreUI/juhuajiu100.png",
	         ["id"] = "jiu106",
	         ["getType"] = 1,
	         ["count"] = 9,
	         ["name"] = "醉梦生",
	         ["showType"] = 1,
	     },
	     [2] = {
	         ["image"] = "Image/UI/StoreUI/qiannengdan.png",
	         ["id"] = "qiannengdan",
	         ["getType"] = 1,
	         ["count"] = 17,
	         ["name"] = "潜能丹",
	         ["showType"] = 1,
	     },
	     [3] = {
	         ["image"] = "Image/UI/SignInUI/baoyu.png",
	         ["id"] = "gongxiandian100",
	         ["getType"] = 1,
	         ["count"] = 22,
	         ["name"] = "宝玉",
	         ["showType"] = 1,
	     },
	     [4] = {
	         ["image"] = "Image/UI/SignInUI/meiyu.png",
	         ["getType"] = 1,
	         ["count"] = 440,
	         ["name"] = "江湖美誉",
	         ["showType"] = 1,
	     },
	 },
	 ["300"] = {
	     [1] = {
	         ["image"] = "Image/UI/StoreUI/juhuajiu100.png",
	         ["id"] = "jiu106",
	         ["getType"] = 1,
	         ["count"] = 3,
	         ["name"] = "醉梦生",
	         ["showType"] = 1,
	     },
	     [2] = {
	         ["image"] = "Image/UI/StoreUI/qiannengdan.png",
	         ["id"] = "qiannengdan",
	         ["getType"] = 1,
	         ["count"] = 6,
	         ["name"] = "潜能丹",
	         ["showType"] = 1,
	     },
	     [3] = {
	         ["image"] = "Image/UI/SignInUI/baoyu.png",
	         ["id"] = "gongxiandian100",
	         ["getType"] = 1,
	         ["count"] = 9,
	         ["name"] = "宝玉",
	         ["showType"] = 1,
	     },
	     [4] = {
	         ["image"] = "Image/UI/SignInUI/meiyu.png",
	         ["getType"] = 1,
	         ["count"] = 180,
	         ["name"] = "江湖美誉",
	         ["showType"] = 1,
	     },
	 },
     },
     ["prefix_key"] = "labour_holiday_20170805",
     ["prize_list"] = {
         [1] = 30,
         [2] = 100,
         [3] = 300,
         [4] = 500,
         [5] = 800,
     },
     ["extra_list"] = {
     },
 },
 ["list"] = {
     ["500"] = 0,
     ["30"] = 2,
     ["100"] = 1,
     ["800"] = 0,
     ["300"] = 1,
 },
 ["shopping_money"] = 400,
}
local posList = {
	[1] = {
		[1] = {
			x = 397.32,
			y = 308.88
		},
	},
	[2] = {
		[1] = {
			x = 188.16,
			y = 308.88
		},
		[2] = {
			x = 606.49,
			y = 308.88
		},
	},
	[3] = {
		[1] = {
			x = 188.16,
			y = 421.28
		},
		[2] = {
			x = 606.49,
			y = 421.28
		},
		[3] = {
			x = 188.16,
			y = 196.48
		},
	},
	[4] = {
		[1] = {
			x = 188.16,
			y = 421.28
		},
		[2] = {
			x = 606.49,
			y = 421.28
		},
		[3] = {
			x = 188.16,
			y = 196.48
		},
		[4] = {
			x = 606.49,
			y = 196.48
		},
	},
	[5] = {
		[1] = {
			x = 188.16,
			y = 421.28
		},
		[2] = {
			x = 606.49,
			y = 421.28
		},
		[3] = {
			x = 188.16,
			y = 196.48
		},
		[4] = {
			x = 606.49,
			y = 196.48
		},
		[5] = {

		}
	},
}

local configList
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 19:10:00
-- @desc 设置配置
function ConsumeWingLayer:setCongif()
	configList = {
		["yuanbaoxiaohao"] = { --一掷千金
			text = "消耗",
			desc = "累计消耗元宝达到指定数量，即可领取\n相应奖励！",
			unit = "元宝",
			desc1 = "累计消耗",
			infoFunc = function()
				HttpManagerEx:getYuanBaoCostGiftList(function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self:setLoadBasr(reward)
						self:show()
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end,
			rewardFunc = function(num,actionId)
				HttpManagerEx:receiveYuanBaoPlanGift(num,function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						self:getReward()
					else
						PopText(errmsg)
						self.Button_TotalPrize:setTouchEnabled(true)
					end
				end,IS_SHOW_WAITING)
			end,
			refreshFunc = function()
				HttpManagerEx:getYuanBaoCostGiftList(function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self.LoadingBar.Text_TotalDayName:setString(data.shopping_money.."/"..self._showNum)
						self.Text_name_0:setString("累计消耗"..self._showNum.."元宝即可获得以下奖励")--"累计消耗"..nowMoney.."元宝即可获得以下奖励"
						self.LoadingBar:setPercent((data.shopping_money/self._showNum)*100)
						self:setRewardButton(data)
						self:setLeftAndRightButton(data)
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end,
		},
		["dailyPay1"] = { -- 每日充值
			text = "充值",
			desc = "每日累计充值达到指定金额，\n即可获得丰厚奖励！",
			unit = "元",
			desc1 = "累计充值",
			infoFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self:setLoadBasr(reward)
						self:show()
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)

				local extraActionsEntrance = {
					["江湖异人录"] = {actionId = "jianghuyirenlu",btnName = "江湖异人"},
					["迎春聚福"] = {actionId = "dailyJifu1",btnName = "聚福奖励"},
					["耕穗叠金"] = {actionId = "dailyJifu1",btnName = "叠金奖励"},
				}
				-- local currExtraAction = "迎春聚福"
				local currExtraAction = "江湖异人录"
				-- 关闭 修改为 江湖异人，点击打开江湖异人录页面
				self.Button_close.Text_buttonName:setText(extraActionsEntrance[currExtraAction].btnName)
				-- 点击后打开江湖异人界面
				self.Button_close:releaseFunc(function()
					-- 江湖异人录活动ID
					local actionId = extraActionsEntrance[currExtraAction].actionId
					switch(actionId,
					{

						["jianghuyirenlu"] = function()
							HttpManagerEx:getActionState(actionId, nil, function(status, errcode, errmsg, data)
								if status == 200 and errcode == 0  then
									if data ~= nil and data.is_open == 1 and data.status == 1 then
										-- 服务器上异人名帖的物品ID（异人名帖是保存在服务器上的）
										local needItemId = "yirenitem1"
										HttpManagerEx:detectionGoods(needItemId, function(status2, errcode2, errmsg2, data2)
											if status2 == 200 then
												if errcode2 == 0 then
													local JiangHuYiRenLuLayer = require("app.views.layer.ActionLayer.JiangHuYiRenLuLayer")
													JiangHuYiRenLuLayer:getInstance():showLayer(data, data2)
												else
													PopText(errmsg2)
												end
											else
												PopText(errmsg2)
											end
										end, IS_SHOW_WAITING)
									else
										PopText("活动未开放")
									end
								else
									PopText(errmsg)
								end
							end, IS_SHOW_WAITING)
						end,

						["dailyJifu1"] = function()
							 local DailyJiFuLayer = require("app.views.layer.ActionLayer.DailyJiFuLayer")
            				 DailyJiFuLayer:showLayer(actionId)
						end,
					})
					
				end)
				-- 点击背景关闭
				self.Panel_back:releaseFunc(function()
					self:hide()
					self:destroyInstance()
				end)
			end,
			rewardFunc = function(num,actionId)
				HttpManagerEx:receiveSpendPlanGiftList(actionId,num,function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						self:getReward()

						-- 获得服务端虚拟物品时，做出提示
						if MapIsEmpty(data) == false and MapIsEmpty(data.data) == false then
							local virtualItemInfo = data.data
							PopText("获得 "..virtualItemInfo.name.."X"..tostring(virtualItemInfo.number))
						end
					else
						PopText(errmsg)
						self.Button_TotalPrize:setTouchEnabled(true)
					end
				end,IS_SHOW_WAITING)
			end,
			refreshFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self.LoadingBar.Text_TotalDayName:setString(data.shopping_money.."/"..self._showNum)
						self.Text_name_0:setString("累计充值"..self._showNum.."元即可获得以下奖励")--"累计消耗"..nowMoney.."元宝即可获得以下奖励"
						self.LoadingBar:setPercent((data.shopping_money/self._showNum)*100)
						self:setRewardButton(data)
						self:setLeftAndRightButton(data)
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end
		},
		["totalPay1"] = {-- 累计充值
			text = "充值",
			desc = "累计充值达到指定数量即可\n领取丰厚奖励！",
			unit = "元",
			desc1 = "累计充值",
			infoFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self:setLoadBasr(reward)
						self:show()
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end,
			rewardFunc = function(num,actionId)
				HttpManagerEx:receiveSpendPlanGiftList(actionId,num,function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						self:getReward()
					else
						PopText(errmsg)
						self.Button_TotalPrize:setTouchEnabled(true)
					end
				end,IS_SHOW_WAITING)
			end,
			refreshFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self.LoadingBar.Text_TotalDayName:setString(data.shopping_money.."/"..self._showNum)
						self.Text_name_0:setString("累计充值"..self._showNum.."元即可获得以下奖励")--"累计消耗"..nowMoney.."元宝即可获得以下奖励"
						self.LoadingBar:setPercent((data.shopping_money/self._showNum)*100)
						self:setRewardButton(data)
						self:setLeftAndRightButton(data)
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end,
		},
		["dailyPay2"] = { -- 宅家充值福利
			text = "充值",
			desc = "每日累计充值达到指定金额，\n即可获得丰厚奖励！",
			unit = "元",
			desc1 = "累计充值",
			infoFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self:setLoadBasr(reward)
						self:show()
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)

				self.Button_close.Text_buttonName:setText("关闭")
				self.Button_close:releaseFunc(function()
					self:hide()
					self:destroyInstance()
				end)
			end,
			rewardFunc = function(num,actionId)
				HttpManagerEx:receiveSpendPlanGiftList(actionId,num,function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						self:getReward()

						-- 获得服务端虚拟物品时，做出提示
						if MapIsEmpty(data) == false and MapIsEmpty(data.data) == false then
							local virtualItemInfo = data.data
							PopText("获得 "..virtualItemInfo.name.."X"..tostring(virtualItemInfo.number))
						end
					else
						PopText(errmsg)
						self.Button_TotalPrize:setTouchEnabled(true)
					end
				end,IS_SHOW_WAITING)
			end,
			refreshFunc = function()
				HttpManagerEx:getSpendPlanGiftList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						reward = Helper:getDef(data,{})
						self:initGiftTable(data.config)
						self.LoadingBar.Text_TotalDayName:setString(data.shopping_money.."/"..self._showNum)
						self.Text_name_0:setString("累计充值"..self._showNum.."元即可获得以下奖励")--"累计消耗"..nowMoney.."元宝即可获得以下奖励"
						self.LoadingBar:setPercent((data.shopping_money/self._showNum)*100)
						self:setRewardButton(data)
						self:setLeftAndRightButton(data)
					else
						self:hide()
						PopText(errmsg)
						self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
					end
				end,IS_SHOW_WAITING)
			end
		},
	}
end

function ConsumeWingLayer:showLayer(actionId)
	print("-----------------------------actionId-----------------------",actionId)
	local layer = self:getInstance()
	layer:setActionTime(actionId)
end
function ConsumeWingLayer:setActionTime(actionId)
	if actionId == nil then
		return 
	end
	self.actionId = actionId
	HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		self.Text_title:setString(data.name)
        		self.Text_totalSign:setString(configList[self.actionId].desc1)
        		self:setActionDsc(data.start,data["end"])
        		self:getCostList()
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function ConsumeWingLayer:setActionDsc(starTime,endTime)
	local str = ""
	str = str .. tostring(Helper:date("%Y",starTime)).."年"
	str = str .. tostring(Helper:date("%m",starTime)).."月"
	str = str .. tostring(Helper:date("%d",starTime)).."日"

	str = str .."~".. tostring(Helper:date("%Y",endTime)).."年"
	str = str .. tostring(Helper:date("%m",endTime)).."月"
	str = str .. tostring(Helper:date("%d",endTime)).."日期间，\n"..configList[self.actionId].desc
	self.Text_5:setString(str)
end
function ConsumeWingLayer:getCostList()
	if MapIsEmpty(configList) == false and MapIsEmpty(configList[self.actionId]) == false then
		if configList[self.actionId].infoFunc then
			configList[self.actionId].infoFunc()
		end
	end
end
function ConsumeWingLayer:setLoadBasr(data)
	local list = data.list
	local shopping_money = data.shopping_money
	if MapIsEmpty(list) == true or type(shopping_money) ~= "number" then
		return
	end
	local nowMoney = self:getMinMoney(list)
	nowMoney = self:getNowMoney(list)
		
	self._nowPanel = self.Panel_kuang.Panel_1
	self._nextPanel = self.Panel_kuang.Panel_2
	self._showNum = self:getNowMoney(data.list)
	self:setRewardPanel(data,self:getNowMoney(data.list))
end
function ConsumeWingLayer:setBurronToPayAndBurronBack()
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer=MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			if MapIsEmpty(configList) == false and MapIsEmpty(configList[self.actionId]) == false then
				if configList[self.actionId].refreshFunc then
					configList[self.actionId].refreshFunc()
					self:show()
					self:maxZ()
				end
			end
		end)
		self:hide()
	end)
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance()
	end)
end
function ConsumeWingLayer:setRewardPanel(data,nowMoney,tag)
	local pos = posList[#data.config.base[tostring(nowMoney)]]
	self._nextPanel:removeAllChildren()
	if tag == nil then
		self._nowPanel:removeAllChildren()
		local panelCount = 1
		for k,v in pairs(data.config.base[tostring(nowMoney)]) do 
			if v.showType == 1 then 
				local panel = self:createPanel(v)
				panel:addTo(self._nowPanel)
				panel:setPosition(pos[panelCount].x,pos[panelCount].y)
				panelCount = panelCount + 1
			end
		end
	elseif tag == "left" then
		local panelCount = 1
		self._nextPanel:setPosition(-400,332)
		for k,v in pairs(data.config.base[tostring(nowMoney)]) do 
			if v.showType == 1 then
				local panel = self:createPanel(v)
				panel:addTo(self._nextPanel)
				panel:setPosition(pos[panelCount].x,pos[panelCount].y)
				panelCount = panelCount + 1
			end
		end
	elseif tag == "right" then
		local panelCount = 1
		self._nextPanel:setPosition(1200,332)
		for k,v in pairs(data.config.base[tostring(nowMoney)]) do 
			if v.showType == 1 then
				local panel = self:createPanel(v)
				panel:addTo(self._nextPanel)
				panel:setPosition(pos[panelCount].x,pos[panelCount].y)
				panelCount = panelCount + 1
			end
		end
	end 
	self:createActionByTag(tag)
	self._showNum = nowMoney
	self.LoadingBar.Text_TotalDayName:setString(data.shopping_money.."/"..nowMoney)
	self.Text_name_0:setString("累计"..configList[self.actionId].text..nowMoney..configList[self.actionId].unit.."即可获得以下奖励")--"累计消耗"..nowMoney.."元宝即可获得以下奖励"
	self.LoadingBar:setPercent((data.shopping_money/nowMoney)*100)
	self:setLeftAndRightButton(data)
	self:setRewardButton(data)
end
function ConsumeWingLayer:setRewardButton(data)
	if data.list[tostring(self._showNum)] == 0 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("领取")
		self.Button_TotalPrize:releaseFunc(function()
			PopText("未"..configList[self.actionId].text.."足够金额！")
		end)
	elseif data.list[tostring(self._showNum)] == 1 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("领取")
		self.Button_TotalPrize:releaseFunc(function()
			self.Button_TotalPrize:setTouchEnabled(false)
			self:checkCanReward(data)
		end)
	elseif data.list[tostring(self._showNum)] == 2 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("已领取")
		self.Button_TotalPrize:releaseFunc(function()

		end)
	end
end
function ConsumeWingLayer:checkCanReward(data)
	local rewardList = {}
	for k,v in pairs(data.config.base[tostring(self._showNum)]) do 
		if v.id ~= nil then
			rewardList[v.id] = v.count
		end --v.id 
	end
	if User:getRole():checkCanBuyTwoOrMoreThings(rewardList) ~= true then
		self.Button_TotalPrize:setTouchEnabled(true)
		return 
	else
		self:receiveReward()
	end
end
function ConsumeWingLayer:receiveReward()
	if MapIsEmpty(configList) == false and MapIsEmpty(configList[self.actionId]) == false then
		if configList[self.actionId].rewardFunc then
			configList[self.actionId].rewardFunc(self._showNum,self.actionId)
		end
	end
end
function ConsumeWingLayer:getReward()
	local list = reward.config.base[tostring(self._showNum)]
	for k,v in pairs(list) do 
		if v.id ~= nil then
			local item = User:getRole():getOneItemByKey(v.id)
			if item ~= nil then
				User:getRole():addItemCount(v.id,v.count)
				PopText("获得物品"..item.name.."X"..tostring(v.count))
				self.Button_TotalPrize.Text_TotalPrizeName:setString("已领取")
				self.Button_TotalPrize:releaseFunc(function()

				end)
			end
		else
			PopText("获得物品"..v.name.."X"..tostring(v.count))
		end
	end
	reward.list[tostring(self._showNum)] = 2
	self.Button_TotalPrize:setTouchEnabled(true)
end
function ConsumeWingLayer:createActionByTag(tag)
	self.Panel_right:setTouchEnabled(false)
	self.Panel_left:setTouchEnabled(false)
	self.Button_TotalPrize:setTouchEnabled(false)
	local movePos 
	if tag == "left" then
		movePos = cc.p(1200,332)
	elseif tag == "right" then
		movePos = cc.p(-400,332)
	else
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
		self.Button_TotalPrize:setTouchEnabled(true)
		return 
	end
	local time = 0.5
	local action = nil

	if false then
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
			self._nowPanel:runAction(cc.MoveTo:create(time, movePos))
		end),cc.CallFunc:create(function()
			self._nextPanel:runAction(cc.MoveTo:create(time, cc.p(400,332)) )
		end)),cc.CallFunc:create(function()
        	local tmpPanel = self._nextPanel
        	self._nextPanel = self._nowPanel
        	self._nowPanel = tmpPanel
		end))

	else
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
				self._nowPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(time, movePos) ,
							cc.FadeOut:create(time)
						),  Expo_EaseOut ) )
	        end),cc.CallFunc:create(function()

				self._nextPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(time, cc.p(400,332)) ,
						cc.FadeIn:create(time)
					),  Expo_EaseIn ) )

	        end)),cc.CallFunc:create(function()
	        	local tmpPanel = self._nextPanel
	        	self._nextPanel = self._nowPanel
	        	self._nowPanel = tmpPanel
	        end)

		)
	end
	self:runActionWithName("move", action)
	self:delayFunc(time,function()
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
		self.Button_TotalPrize:setTouchEnabled(true)
	end)
end
function ConsumeWingLayer:createPanel(list)
	list = Helper:getDef(list,{})
	local panel = self:clonePanel()
	self:setPanel(panel,list)
	return panel
end
function ConsumeWingLayer:setPanel(panel,list)
	if not panel then
		return
	end
	list = Helper:getDef(list,{})
	panel.Image_zhuzi:loadTexture(list.image,0)
	panel.Text_name:setString(list.name)
	if list.nameDes == nil then
		panel.Text_NameDdes:setVisible(false)
	end
	panel.Text_num:setString(tostring(list.count))
end
function ConsumeWingLayer:clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end
function ConsumeWingLayer:setLeftAndRightButton(data)
	local listTab=data.list
	local tabLength=0
	for i,v in pairs(listTab) do 
		if v then 
			tabLength=tabLength+1
		end
	end 
	if tabLength==1 then 
		self.Panel_left:setVisible(false)
		self.Panel_right:setVisible(false)
		self.Text_14:setVisible(false)
	else
		self.Panel_left:setVisible(true)
		self.Panel_right:setVisible(true)
		self.Text_14:setVisible(true)
	end
	self:setLeftButton(data)
	self:setRightButton(data)
end
function ConsumeWingLayer:setLeftButton(data)
	local leftMoney = self:getPrevNowMoney(data.list)
	if leftMoney == nil then
		self.Panel_left:releaseFunc(function()
		end)
	else
		self.Panel_left:releaseFunc(function()
			self:setRewardPanel(data,leftMoney,"left")
		end)
	end
end
function ConsumeWingLayer:setRightButton(data)
	local rightMoney = self:getNextNowMoney(data.list)
	if rightMoney == nil then
		self.Panel_right:releaseFunc(function()
		end)
	else
		self.Panel_right:releaseFunc(function()
			self:setRewardPanel(data,rightMoney,"right")
		end)
	end
end
function ConsumeWingLayer:getNextNowMoney(list)
	if list == nil  or type(list) ~= "table" then
		return
	end
	local tab = self:serializeTable(list)
	for k,v in pairs(tab) do 
		if v == self._showNum then
			if k == #tab then
				return nil
			else
				return tab[k+1]
			end
		end
	end
end
function ConsumeWingLayer:getPrevNowMoney(list)
	if list == nil  or type(list) ~= "table" then
		return
	end
	local tab = self:serializeTable(list)
	for k,v in pairs(tab) do 
		if v == self._showNum then
			if k == 1 then
				return nil 
			else
				return tab[k-1]
			end
		end
	end
end
function ConsumeWingLayer:getRandomList(list)--随机获取奖励
	if list == nil then
		return
	end
	return list[math.random(1,#list)]
end
function ConsumeWingLayer:getMinMoney(list)--获取最小充值奖励金额
	if list == nil or type(list) ~= "table"  then
		return
	end
	local min = 1000000
	for k,v in pairs(list) do
		if tonumber(k)<min then
			min = tonumber(k)
		end
	end
	return min
end
function ConsumeWingLayer:getMaxMoney(list)--获取最大充值奖励金额
	if list == nil or type(list) ~= "table"  then
		return
	end
	local max = 0
	for k,v in pairs(list) do 
		if tonumber(k) > max then
			max = tonumber(k)
		end
	end
	return max
end
function ConsumeWingLayer:getNowMoney(list)--获取当前可领取奖励档位金额
	if list == nil  or type(list) ~= "table" then
		return
	end
	local tab = self:serializeTable(list)
	for k,v in pairs(tab) do 
		if list[tostring(v)] == 0 then
			return v
		elseif list[tostring(v)] == 1 then
			return v
		elseif k == #tab then
			return v
		end
	end
end
function ConsumeWingLayer:serializeTable(list)--序列化一个表
	 local tab = {}
	 local i = 1
	 for k,v in pairs(list) do 
	 	table.insert(tab,tonumber(k))
	 end
	 table.sort(tab)
	 return tab
end
function ConsumeWingLayer:initGiftTable(tab)
	local list = tab
	local rewardList = {}
	for k,v in pairs(list.base) do 
		rewardList[tostring(k)] = {}
		for i,value in pairs(v) do 
			rewardList[tostring(k)][i] = {}
			for n,m in pairs(value) do 
				if n == "itemId" then
					if m == "" then
						rewardList[tostring(k)][i].id = nil
					else
						rewardList[tostring(k)][i].id = m
					end
					if value["isVirtual"] and value["isVirtual"] == 1 then
						rewardList[tostring(k)][i].id = nil
					end
				elseif n == "number" then
					rewardList[tostring(k)][i].count = m
				elseif n == "name" then
					rewardList[tostring(k)][i].name = m
				elseif n == "imagePath" then
					rewardList[tostring(k)][i].image = m
				elseif n == "showType" then
					rewardList[tostring(k)][i].showType = m
				elseif n == "nameDes" then
					rewardList[tostring(k)][i].nameDes = m
				end
				if list.strategy_id == 1 then
					rewardList[tostring(k)][i].getType = 1
				elseif list.strategy_id == 2 then

				elseif list.strategy_id == 3 then

				end
			end
		end
	end
	reward.config.base = rewardList
end

function ConsumeWingLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function ConsumeWingLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function ConsumeWingLayer:__showRule()
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

Helper:classDefNodeGetInstance(ConsumeWingLayer)

return ConsumeWingLayer0000000000000000
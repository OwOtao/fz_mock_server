local StoreLayer = require("app.views.layer.StoreLayer.StoreLayer")
local SuiMoJiFuLayer = class("SuiMoJiFuLayer", LayerEx)
function SuiMoJiFuLayer:create()
	local p = SuiMoJiFuLayer:new()
	p:init()
	return p
end
function SuiMoJiFuLayer:init()
	local UI = require("Layer/ActionUI/SuiMoJiFuUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self.currRewardTimes = nil --当前页面是获得第几次奖励
    self.Text_xiangqing:setTouchEnabled(true)
    self.Text_xiangqing:releaseFunc(function()
		PopupLayerController:showLayer("JiangHuSanYouXQLayer",function(layer)
            layer:setDsc("1、本次活动设置了七个迎春奖励：迎春（一）、迎春（二）……迎春（七）。\n2、活动期间，第一次充值达到16元，可以领取迎春（一），第二次充值达到16元，可以领取迎春（二），以此类推。但两次充值不能是同一天。即如果想领取全部的七个迎春奖励，需要在七天（可以不连续）里每天充值都达到16元。\n3、当迎春（七）可领取的时候，可额外再领取一份春归奖励。\n4、活动期间，可领取但没有领取的奖励，可以补领，但活动结束后，无法再领取，请留意并及时领取。")
			layer:setTextTitle("活动说明")
            layer:showLayer()
    	end)
	end)
	self:setBurronToPayAndBurronBack()
end

local posList = {
	[3] = {
		[1] = {
			x = 200,
			y = 92
		},
		[2] = {
			x = 600,
			y = 92
		},
		[3] = {
			x = 400,
			y = 332
		}
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
			x = 200,
			y = 92
		},
		[2] = {
			x = 600,
			y = 92
		},
		[3] = {
			x = 200,
			y = 332
		},
		[4] = {
			x = 600,
			y = 332
		},
		[5] = {

		}
	},
}


function SuiMoJiFuLayer:showLayer(actionId)
    self.currRewardTimes = 1

	self:setActionTime(actionId)
    self:show()
end

function SuiMoJiFuLayer:hideLayer()
    self:hide()
    self:destroyInstance()
end

function SuiMoJiFuLayer:setActionTime(actionId)
	if actionId == nil then
		return 
	end
	self.actionId = actionId
	HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
            if DEBUG_MODE == 1 then
			    Helper:print_lua_table(data)
            end
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		self.Text_title:setString(data.name)
        		self:setActionDsc(data.start,data["end"],data.desc)
        		self:getCostList()
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

--设置文本描述
function SuiMoJiFuLayer:setActionDsc(starTime,endTime,desc)
	local str = ""
	str = str .. tostring(Helper:date("%m",starTime)).."月"
	str = str .. tostring(Helper:date("%d",starTime)).."日更新后"

	str = str .."~".. tostring(Helper:date("%m",endTime)).."月"
	str = str .. tostring(Helper:date("%d",endTime)).."日期间，"..desc
	self.Text_5:setString(str)
end
function SuiMoJiFuLayer:getCostList()
	HttpManagerEx:getNewDailyList(self.actionId,function (status, errcode, errmsg, data, isEncrypted)
        if DEBUG_MODE == 1 then
            Helper:print_lua_table(data)
        end
        if status == 200 and errcode == 0 then
            self:setNowPanelAndNextPanel()
            self:setRewardPanel(data)
            self:setText()
        else
            PopText(errmsg)
            self:hideLayer()
        end
    end,IS_SHOW_WAITING)
end

function SuiMoJiFuLayer:setText()
    local text = "充值达到16元可领取一次奖励"
    if self.currRewardTimes == 8 then
        text = "本次活动终极奖励"
    end

    self.Text_1:setString(text)

    local textList = {
        "迎春（一）",
        "迎春（二）",
        "迎春（三）",
        "迎春（四）",
        "迎春（五）",
        "迎春（六）",
        "迎春（七）",
        "春归奖励"
    }

    self.Text_2:setString(textList[self.currRewardTimes])
end

function SuiMoJiFuLayer:setNowPanelAndNextPanel()
    self._nowPanel = self.Panel_kuang.Panel_1
    self._nextPanel = self.Panel_kuang.Panel_2
end


function SuiMoJiFuLayer:setBurronToPayAndBurronBack()
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer=MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			-- self:getCostList()
		end)
        self:hideLayer()
	end)
	self.Button_close:releaseFunc(function()
		self:hideLayer()
	end)
end
function SuiMoJiFuLayer:setRewardPanel(data,tag)
    local currRewardList  = self:getCurrRewardList(data)

	local pos = posList[#currRewardList]
	self._nextPanel:removeAllChildren()
	if tag == nil then
		self._nowPanel:removeAllChildren()
		for k,v in pairs(currRewardList) do 
			local panel = self:createPanel(v)
			panel:addTo(self._nowPanel)
			panel:setPosition(pos[k].x,pos[k].y)
		end
	elseif tag == "left" then
		self._nextPanel:setPosition(-400,332)
		for k,v in pairs(currRewardList) do 
			local panel = self:createPanel(v)
			panel:addTo(self._nextPanel)
			panel:setPosition(pos[k].x,pos[k].y)
		end
	elseif tag == "right" then
		self._nextPanel:setPosition(1200,332)
		for k,v in pairs(currRewardList) do 
			local panel = self:createPanel(v)
			panel:addTo(self._nextPanel)
			panel:setPosition(pos[k].x,pos[k].y)
		end
	end 
	self:createActionByTag(tag)
	self:setText()
	self:setLeftAndRightButton(data)
	self:setRewardButton(data)
end
function SuiMoJiFuLayer:setRewardButton(data)
    local times = data.times

    assert(times[tostring(self.currRewardTimes)],"SuiMoJiFuLayer:setRewardButton(data) 检查参数")
    
    local status = times[tostring(self.currRewardTimes)].istrd
    -- 0不可领取，1可领取，2已领取
	if status == 0 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("领取")
        self.Button_TotalPrize:setEnabled(false)
	elseif status == 1 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("领取")
        self.Button_TotalPrize:setEnabled(true)
		self.Button_TotalPrize:releaseFunc(function()
			self:checkCanReward(data)
		end)
	elseif status == 2 then
		self.Button_TotalPrize.Text_TotalPrizeName:setString("已领取")
		self.Button_TotalPrize:setEnabled(false)
	end
end

function SuiMoJiFuLayer:checkCanReward(data)
	local currRewardList  = self:getCurrRewardList(data)
    local rewardList = {}
	for k,v in pairs(currRewardList) do 
		if v.itemId ~= nil then
			rewardList[v.itemId] = v.number
		end
	end
	if User:getRole():checkCanBuyTwoOrMoreThings(rewardList) ~= true then
		return 
    end

	self:receiveReward(currRewardList)
end

function SuiMoJiFuLayer:receiveReward(currRewardList)
    local actionId = self.actionId
    local type = self.currRewardTimes
	HttpManagerEx:receiveNewDailyReward(self.actionId,type,function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 and errcode == 0 then
            self:getReward(currRewardList)
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function SuiMoJiFuLayer:getReward(currRewardList)
	local list = currRewardList
	for k,v in pairs(list) do 
		if v.itemId ~= nil then
			local item = User:getRole():getOneItemByKey(v.itemId)
			if item ~= nil then
				User:getRole():addItemCount(v.itemId,v.number)
				PopText("获得物品"..item.name.."X"..tostring(v.number))
			end
		else
			print("没有该物品","物品名字 = ",v.name,v.itemId)
		end
	end

	self.Button_TotalPrize.Text_TotalPrizeName:setString("已领取")
	self.Button_TotalPrize:setEnabled(false)
end

function SuiMoJiFuLayer:createActionByTag(tag)
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
function SuiMoJiFuLayer:createPanel(list)
	list = Helper:getDef(list,{})
	local panel = self:clonePanel()
	self:setPanel(panel,list)
	return panel
end
function SuiMoJiFuLayer:setPanel(panel,list)
	if not panel then
		return
	end
	list = Helper:getDef(list,{})
	panel.Image_zhuzi:loadTexture(list.imagePath,0)
	panel.Text_name:setString(list.name)
	if list.nameDes == nil then
		panel.Text_NameDdes:setVisible(false)
	end
	panel.Text_num:setString(tostring(list.number))
end
function SuiMoJiFuLayer:clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end
function SuiMoJiFuLayer:setLeftAndRightButton(data)
	local listTab=data
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
function SuiMoJiFuLayer:setLeftButton(data)
	if self.currRewardTimes <= 1 then
		self.Panel_left:releaseFunc(function()
		end)
	else
		self.Panel_left:releaseFunc(function()
            self.currRewardTimes = self.currRewardTimes - 1
			self:setRewardPanel(data,"left")
		end)
	end
end
function SuiMoJiFuLayer:setRightButton(data)
	if self.currRewardTimes >= 8 then
		self.Panel_right:releaseFunc(function()
		end)
	else
		self.Panel_right:releaseFunc(function()
            self.currRewardTimes = self.currRewardTimes + 1
			self:setRewardPanel(data,"right")
		end)
	end
end

--获得当前页面的奖励列表
function SuiMoJiFuLayer:getCurrRewardList(data)
    local currReward = self.currRewardTimes
    if currReward == nil then
        return {}
    end
    
    return data.config.base["goods_"..currReward] or {}
end

Helper:classDefNodeGetInstance(SuiMoJiFuLayer)

return SuiMoJiFuLayer00000
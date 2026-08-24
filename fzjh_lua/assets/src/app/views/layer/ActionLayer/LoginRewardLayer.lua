local LoginRewardLayer = class("LoginRewardLayer", LayerEx)

local REWARD_STATE = {
    NOT_START = 1,  --未开始
    NOT_REWARD = 2, --未领取
    OVER_TIME = 3,  --补领
    REWARDED = 5,   --已领取
}

local REWARD_TYPE = {
    NETATTR = 1,
    ATTR = 2,
    ITEM = 3,
}

function LoginRewardLayer:create()
	local p = LoginRewardLayer:new()
	p:init()
	return p
end

function LoginRewardLayer:init()
	local UI = require("Layer/ActionUI/LoginRewardUI.lua").create()['root']
	UI:addTo(self)

    Helper:convertUIByParent(self)
    
    self.Button_back:releaseFunc(function ()
        self:hideLayer()
    end)
    self.Text_back:releaseFunc(function ()
        self:hideLayer()
    end)
    
    self:hide()
end

function LoginRewardLayer:showLayer(data)
    self:setActionTitle(data.name)
    self:setActionDesc(data.dsc)
    self:setActionTime(data.activity_time)
    self:initList(data.relist)
    self:setTextBackStr("更多活动，请关注活动主页>>")
    self:show()
end

function LoginRewardLayer:hideLayer()
    PopupLayerController:hideLayer("LoginRewardLayer",function()
        self:hide()
    end)
end

function LoginRewardLayer:setActionTitle(title)
    self.Text_title:setString(title)
end

function LoginRewardLayer:setActionDesc(desc)
    if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
    end
    
    self.Text_dsc:setVisible(false)
    
	local richTextScroll = ExtRichTextScroll:create()
    self.Text_dsc:getParent():addChild(richTextScroll)

    local point = cc.p(self.Text_dsc:getPosition())
    local size = self.Text_dsc:getContentSize()

   	richTextScroll:move(point)
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:setAnchorPoint(cc.p(0.5, 0.5))
    richTextScroll:getRichText():setVerticalSpace(5)

   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
    self.RichText_Print:setTouchEnabled(false)
    
    local textColor = {r = 192, g = 192, b = 192}
    self.RichText_Print:pushBackText(desc, textColor, 255, Resource:getFontPath("default"), 40)
end

function LoginRewardLayer:setActionTime(time)
    self.Text_actionTime:setString(time)
end

function LoginRewardLayer:setTextBackStr(str)
    self.Text_back:setString(str)
end

function LoginRewardLayer:initList(listData)
    self.ListView_itemList:removeAllItems()
    local role = User:getRole()
    for k,panelData in pairs(listData) do
        local panel = self.Panel_row:clone()
        Helper:convertUIByParent(panel)
        panelData.rewardItems = {}

        for k,v in pairs(panelData.rewards) do
            if v.type == REWARD_TYPE.ITEM then
                local itemAttr = Item:getOneItemByKey(v.key)
                panelData.rewardItems[v.key] = v.value
            end
        end

        self:initPanel(panel,panelData)
        self.ListView_itemList:pushBackCustomItem(panel)
    end
end

local timeTextColor = {
    [REWARD_STATE.NOT_REWARD] = {r = 233, g = 231, b = 77},
    [REWARD_STATE.REWARDED] = {r = 148, g = 148, b = 148},
    [REWARD_STATE.OVER_TIME] = {r = 216, g = 216, b = 216},
}

local rewardTextColor = {
    [REWARD_STATE.NOT_REWARD] = {r = 37, g = 73, b = 172},
    [REWARD_STATE.REWARDED] = {r = 148, g = 148, b = 148},
    [REWARD_STATE.OVER_TIME] = {r = 216, g = 216, b = 216},
}

function LoginRewardLayer:initPanel(panel,panelData)
    local timeColor = timeTextColor[panelData.state] or timeTextColor[REWARD_STATE.NOT_REWARD]
    local rewardColor = rewardTextColor[panelData.state] or rewardTextColor[REWARD_STATE.NOT_REWARD]

    panel.Image_kuang.Text_time:setString(panelData.times)
    panel.Image_kuang.Text_time:setTextColor(timeColor)
    panel.Image_kuang.Text_reward:setString(panelData.dsc)
    panel.Image_kuang.Text_reward:setTextColor(rewardColor)
    panel.Image_kuang.Text_btn:setVisible(panelData.state ~= REWARD_STATE.REWARDED)
    panel.Image_kuang.Image_reward:setVisible(panelData.state == REWARD_STATE.REWARDED)
    panel.Image_kuang:setTouchEnabled(panelData.state ~= REWARD_STATE.REWARDED)

    panel.Image_kuang.Text_btn:releaseFunc(function()
        if self:checkCanGetReward(panelData.state,panelData.rewardItems) == true then
            self:getReward(panelData,function()
                panel.Image_kuang:setTouchEnabled(false)
                panel.Image_kuang.Text_btn:setVisible(false)
                panel.Image_kuang.Image_reward:setVisible(true)
                panel.Image_kuang.Text_time:setTextColor(timeTextColor[REWARD_STATE.REWARDED])
                panel.Image_kuang.Text_reward:setTextColor(rewardTextColor[REWARD_STATE.REWARDED])
            end)
        elseif panelData.state == REWARD_STATE.NOT_START then
            PopText("当前奖励尚未处于领取时间。")
        end
    end)

    panel.Image_kuang:releaseFunc(function()
        if self:checkCanGetReward(panelData.state,panelData.rewardItems) == true then
            self:getReward(panelData,function()
                panel.Image_kuang:setTouchEnabled(false)
                panel.Image_kuang.Text_btn:setVisible(false)
                panel.Image_kuang.Image_reward:setVisible(true)
                panel.Image_kuang.Text_time:setTextColor(timeTextColor[REWARD_STATE.REWARDED])
                panel.Image_kuang.Text_reward:setTextColor(rewardTextColor[REWARD_STATE.REWARDED])
            end)
        elseif panelData.state == REWARD_STATE.NOT_START then
            PopText("当前奖励尚未处于领取时间。")
        end
    end)
    
end

function LoginRewardLayer:checkCanGetReward(rewardState,rewardItems)
    if rewardState == REWARD_STATE.REWARDED or rewardState == REWARD_STATE.NOT_START then
        return false
    end
    if MapIsEmpty(rewardItems) == false and User:getRole():checkCanBuyTwoOrMoreThings(rewardItems) == false then
        return false
    end
    return true
end

function LoginRewardLayer:getReward(panelData,func)

    local getRewardFunc = function()
        local role = User:getRole()

        HttpManagerEx:setLoginYuandanReward(panelData.rewardId,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local reward = data.reward
                if MapIsEmpty(reward) == false then
                    for k,v in pairs(reward) do
                        if v.type == REWARD_TYPE.NETATTR then
                            PopText(role:getCHAttrName(v.key).."+"..tostring(v.value))
                        elseif v.type == REWARD_TYPE.ATTR then
                            role:addAttr(v.key,tonumber(v.value))
                            PopText(role:getCHAttrName(v.key).."+"..tostring(v.value))
                        elseif v.type == REWARD_TYPE.ITEM then
                            local itemAttr = Item:getOneItemByKey(v.key)
                            if itemAttr then
                                role:addItemCount(v.key,tonumber(v.value))
                                PopText(itemAttr.name.."X"..tostring(v.value))
                            end
                        end
                    end
                end
                
                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING)
    end

    if panelData.state == REWARD_STATE.OVER_TIME then
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show("是否要花费"..tostring(panelData.cost).."元宝补领此奖励？")
        dialog:setButton1("确定", function()
            getRewardFunc()
        end)

        dialog:setButton2("取消", function()
        end)
        dialog:setWeChatVisible(false)
    elseif panelData.state == REWARD_STATE.NOT_REWARD then
        getRewardFunc()
    end
end

Helper:classDefNodeGetInstance(LoginRewardLayer)

return LoginRewardLayer
00000000
--
-- Author: TanQinJian
-- Date: 2020-05-26 15:20:41
--
-- 手腕大赛 复用钓鱼玩法界面
local WristbandCompetitionLayer = class("WristbandCompetitionLayer", LayerEx)

function WristbandCompetitionLayer:create()
	local p = WristbandCompetitionLayer:new()
	p:init()
	return p
end

function WristbandCompetitionLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishingGameUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

    self.gameResult = nil -- 比赛结果 1成功 ，2失败
    self.animDuration = nil --光标移动速度
    self.gameMaxTimes = 0 --当前游戏最大回合数
    self.currGameTimes = 0 --当前回合数 

    self.sucfulRegional_X = nil --成功区域的横坐标（区域总长100.4，所以横坐标左右50.2的范围属于成功区域）
    self:initUI()
    self:setPoisonButton()
end

function WristbandCompetitionLayer:hideLayer()
    PopupLayerController:hideLayer("WristbandCompetitionLayer", function(layer)
        layer:hide(function ()
            MainControllLayer:resumeUpdate()
        end)
    end)
end

function WristbandCompetitionLayer:showLayer(gameTimes,speed,descText,successResultsFun,failedResultsFun,successReward,failReward)
    User:getRole():setFlag("PVP活动状态", "忙碌")
    self.animDuration = Helper:getDef(speed,3)
    self.gameMaxTimes = Helper:getDef(gameTimes,1)
    self:setText(descText)

    self.successResultsFun = successResultsFun
    self.failedResultsFun = failedResultsFun
    self.successReward = successReward
    self.failReward = failReward

	self:refreshUI()

    self:show(function ( )
        MainControllLayer:pauseUpdate()
    end)	
end

function WristbandCompetitionLayer:initUI()
	self.Panel_category.Text_Title:setString("扳腕大赛")
	self:setText()
	self.Text_distraction:setVisible(false)
	self.Text_focus:setVisible(false)
	self.Text_text:setVisible(false)
	self.Image_10:loadTexture("Image/UI/ArchiveUI/shouwan.png")
    self.Button_5.Text_buttonName:setString("扳倒")
end

function WristbandCompetitionLayer:setText(str)
    self.Text_dec:setString(str)
end

function WristbandCompetitionLayer:refreshUI()
    self.Button_5:setEnabled(true)

    -- 开始时间
	self.startTime = GetTime()

    -- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

    self._handle = self:schedule(function (ft)
		self:updateTime()
	end,0.1)

    self:randomSuccessfulRegional()

    self:moveBlock()
end

function WristbandCompetitionLayer:updateTime()
    local currTime = GetTime()
	local num = 0

	num = math.floor(90 - (currTime - self.startTime))

	if num <= 0 then
		num = 0
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

        --提交钓鱼结果
        self:stopMoveBlock()
        self.gameResult = 2 --超时算失败
        self:submitResults()
        return
	end

	self.Text_time:setString("剩余时间："..num.."秒")
end

--随机成功区域
function WristbandCompetitionLayer:randomSuccessfulRegional()
    local panel = self.Panel_bar
    local Image_3_x = (math.random( 1,10)-1)*100 + 50.2

    self.sucfulRegional_X = Image_3_x
    panel.Image_3:setPositionX(Image_3_x)
end

-- 移动方块
function WristbandCompetitionLayer:moveBlock()
    local panel = self.Panel_bar
    panel.Panel_track:setPositionX(20)

    local bar_w = panel:getSize().width
	local track_w = panel.Panel_track:getSize().width

    print("bar_w = ",bar_w)
    print("track_w = ",track_w)

	local x1 = bar_w - (track_w / 2)
	local x2 = (track_w / 2)

	panel.Panel_track:stopAllActions()

	local animDuration = Helper:getDef(self.animDuration,3)
	local action = cc.Sequence:create(
		cc.MoveTo:create(0, cc.p(x2, panel.Panel_track:getPositionY())),
		cc.MoveTo:create(animDuration, cc.p(x1, panel.Panel_track:getPositionY())),
        cc.MoveTo:create(animDuration, cc.p(x2, panel.Panel_track:getPositionY()))
	)
	panel.Panel_track:runAction(cc.RepeatForever:create(action))
end

-- 停止移动方块
function WristbandCompetitionLayer:stopMoveBlock()
	local panel = self.Panel_bar

	panel.Panel_track:stopAllActions()

	--判断是否在成功区域
    local minSucfulRegional_X = self.sucfulRegional_X - 50.2
    local maxSucfulRegional_X = self.sucfulRegional_X + 50.2

	local track_x = panel.Panel_track:getPositionX()

    if track_x >= minSucfulRegional_X and track_x <= maxSucfulRegional_X then
        --停在成功区域
        self.gameResult = 1 --成功
    else
        self.gameResult = 2 --失败
    end
end

function WristbandCompetitionLayer:setPoisonButton()
    self.Button_5:releaseFunc(function()
        if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

        self:stopMoveBlock()

        self:submitResults()
    end)
end

--提交钓鱼结果
function WristbandCompetitionLayer:submitResults()
    self.Button_5:setEnabled(false)
    local role = User:getRole()

    if self.gameResult == 2 then --失败
        self:endGame()
    else
        self.currGameTimes = self.currGameTimes + 1
        self:delayFunc(0.5,function()
            if self.currGameTimes >= self.gameMaxTimes then
                self:endGame()
            else
                self:refreshUI()
            end
        end)
    end
    
    
end


function WristbandCompetitionLayer:getReward(reward)
    if not reward then 
        return false
    end
    local rewardText = {}
    local role = User:getRole()
    local rewardArray = string.split(reward,";")
    if MapIsEmpty(rewardArray) == false then
        local itemNum = 0
        if rewardArray[1] then  
            local attrRewards = string.split(rewardArray[1],",")
            if MapIsEmpty(attrRewards) == false then 
                for k,v in pairs(attrRewards) do 
                    local attrInfo = string.split(v,":")
                    if MapIsEmpty(attrInfo) == false then 
                        role:addAttr(attrInfo[1],tonumber(attrInfo[2]))
                        local textStr = "获得"..role:getCHAttrName(attrInfo[1]).."："..tostring(attrInfo[2])
                        if attrInfo[1] == "money" or attrInfo[1] == "gold" then 
                            itemNum = itemNum + 1
                            rewardText["item_"..tostring(itemNum)] = textStr
                        else
                            rewardText[attrInfo[1]] = textStr
                        end 
                        
                    end
                end
            end
        end

        if rewardArray[2] then 
            local itemRewards = string.split(rewardArray[2],",")
            if MapIsEmpty(itemRewards) == false then 
                for k,v in pairs(itemRewards) do 
                    local itemInfo = string.split(v,":")
                    if MapIsEmpty(itemInfo) == false then 
                        itemNum = itemNum + 1
                        role:addItemCount(itemInfo[1],tonumber(itemInfo[2]))
                        local itemAttr  = Item:getOneItemByKey(itemInfo[1])
                        local textStr = "获得"..itemAttr.name.."："..tostring(itemInfo[2])
                        rewardText["item_"..tostring(itemNum)] = textStr
                    end
                end
            end
        end
    end
    return rewardText
end

function WristbandCompetitionLayer:endGame()
    if self.gameResult == 1 and self.successResultsFun then
        self.successResultsFun()
    elseif self.gameResult == 2 and self.failedResultsFun then
        self.failedResultsFun()
    end
    local rewardId
    if self.gameResult == 1 then
        rewardId = self.successReward
    else
        rewardId = self.failReward
    end

    local rewardText = self:getReward(rewardId)

    local resultStr = "你在本次比赛中胜利了！"
    if self.gameResult == 2 then 
        resultStr =  "你在本次比赛中失败了！"
    end

    self:hideLayer()

    PopupLayerController:showLayer("WristbandCompetitionResultLayer", function(layer)
        layer:showLayer()
        layer:initText()
        layer:setTextsStr(resultStr)
        for k,v in pairs(rewardText) do 
            if k == "exp" then
                layer:setExp(v)
            elseif k == "pot" then 
                layer:setPot(v)
            end
            if string.find(k,"item_") then
                local index = tonumber(string.sub(k,6))
                --目前总共可显示4个物品
                 layer:setTextHaveDsc(5-index,v)
            end
        end
    end)
    
end

Helper:classDefNodeGetInstance(WristbandCompetitionLayer)

return WristbandCompetitionLayer0000
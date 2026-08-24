-- 钓鱼玩法
local FishingGameLayer = class("FishingGameLayer", LayerEx)
local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")

function FishingGameLayer:create()
	local p = FishingGameLayer:new()
	p:init()
	return p
end

function FishingGameLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishingGameUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

    self.fishResult = nil -- 钓鱼结果 1成功 ，2失败
    self.animDuration = nil --动画时间
    self.fishRound = nil --当前回合数
    self.fishTab = nil --记录本次钓到的鱼

    self.sucfulRegional_X = nil --成功区域的横坐标（区域总长100.4，所以横坐标左右50.2的范围属于成功区域）

    self:setPoisonButton()
end

function FishingGameLayer:hideLayer()
    PopupLayerController:hideLayer("FishingGameLayer", function(layer)
        layer:hide(function ()
            MainControllLayer:resumeUpdate()
        end)
    end)
end

function FishingGameLayer:showLayer(animDuration,haveYuHuiLing)
    User:getRole():setFlag("PVP活动状态", "忙碌")
    self.animDuration = animDuration
    self.fishRound = 0
    self.fishTab = {}
    --御汇令buff
    self.haveYuHuiLing = haveYuHuiLing

    self.isTtitleGetDay = false

    self:checkIsGetTitleDay()

    self:setText()

	self:refreshUI()

    self:show(function ( )
        MainControllLayer:pauseUpdate()
    end)	
end

function FishingGameLayer:setText()
    self.Text_dec:setString("湖面波光粼粼，几条锦鲤在水中游舞，不时静止漂浮，不时摆动鱼尾，偶然因外界惊扰迅速窜入石缝之中，余下片片涟漪。需在九十秒中抓准时机，一击即中，方能钓到大鱼。")
end

function FishingGameLayer:refreshUI()
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

function FishingGameLayer:updateTime()
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
        self.fishResult = 2 --超时算失败
        self:submitResults()
        return
	end

	self.Text_time:setString("剩余时间："..num.."秒")
end

--随机成功区域
function FishingGameLayer:randomSuccessfulRegional()
    local panel = self.Panel_bar
    local Image_3_x = (math.random( 1,10)-1)*100 + 50.2

    self.sucfulRegional_X = Image_3_x
    panel.Image_3:setPositionX(Image_3_x)
end

-- 移动方块
function FishingGameLayer:moveBlock()
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
function FishingGameLayer:stopMoveBlock()
	local panel = self.Panel_bar

	panel.Panel_track:stopAllActions()

	--判断是否在成功区域
    local minSucfulRegional_X = self.sucfulRegional_X - 50.2
    local maxSucfulRegional_X = self.sucfulRegional_X + 50.2

	local track_x = panel.Panel_track:getPositionX()

    if track_x >= minSucfulRegional_X and track_x <= maxSucfulRegional_X then
        --停在成功区域
        self.fishResult = 1 --成功
    else
        self.fishResult = 2 --失败
    end
end

function FishingGameLayer:setPoisonButton()
    self.Button_5:releaseFunc(function()
        if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

        --提交钓鱼结果
        self:stopMoveBlock()

        self:submitResults()
    end)
end

--提交钓鱼结果
function FishingGameLayer:submitResults()
    self.Button_5:setEnabled(false)
    self.fishRound = self.fishRound + 1
    local role = User:getRole()
    local logFish
    if self.fishResult == 1 then
        local fishTab = role:getInheritFlag("周活钓鱼玩法结果")
        if fishTab == 0 or fishTab == nil then
            fishTab = {}
        end
        if DEBUG_MODE == 1 then
            print("周活钓鱼玩法结果")
            Helper:print_lua_table(fishTab)
        end

        local fishId = FishingGameUtil:getRandomFishId()
        logFish = FishingGameUtil:getFishAttr(fishId).fishname
        PopText("钓到"..FishingGameUtil:getFishAttr(fishId).fishname.."X 1")
        if fishTab[fishId] then
            fishTab[fishId] = fishTab[fishId] + 1
        else
            fishTab[fishId] = 1
        end

        if self.fishTab[fishId] then
            self.fishTab[fishId] = self.fishTab[fishId] + 1
        else
            self.fishTab[fishId] = 1
        end

        role:setInheritFlag("周活钓鱼玩法结果",fishTab)
    else
        PopText("本次未能钓到")
    end

    self:delayFunc(0.5,function()
        --本次钓鱼结束，每次4回合
        if self.fishRound >= 4 then
            local attrRewards = {
                ["pot"] = 3000,
                ["exp"] = 4000,
            }
            for k,v in pairs(attrRewards) do
                local buffAddValue = role:getDayFlag("yuhuiling_"..k)
                local addValue = 0 
                if self.haveYuHuiLing  then 
                    addValue = YUHUILING_BUFF * v 
                    if addValue > YUHUILING_NUM_LIMIT - buffAddValue then 
                        addValue = math.max(YUHUILING_NUM_LIMIT - buffAddValue,0)
                    end
                end
                role:setDayFlag("yuhuiling_"..k,buffAddValue + addValue)
                role:addAttr(k,v + addValue)
                attrRewards[k] = v + addValue
            end

            if self.isTtitleGetDay == false then 
                role:setInheritFlag("weekslcd_gameTimes", role:getInheritFlag("weekslcd_gameTimes") + 1)
            else 
                local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
                ActivityCalendarUtils:getSpecialTitle("weekslcd")
            end

            local fishTab = self.fishTab
            self:hideLayer()
            PopupLayerController:showLayer("FishingResultLayer", function(layer)
                layer:showLayer(fishTab)
                layer:setExp(attrRewards["exp"])
                layer:setPot(attrRewards["pot"])
            end)
        else
            self:refreshUI()
        end
    end)
    --记录获得的鱼
    if logFish then 
        local logTab = {}
        logTab[logFish] = 1
        local Record = require("app.models.Record.Record")
        Record:addLog(Record.LOG_TYPE.ACTION_FLAG,logTab,"fishing")
    end
end

--获得游字令
function FishingGameLayer:PopYouZiLingText(str1,str2)
    if str1 and str1~="" then 
        PopText(str1)
    end
     if str2 and str2~="" then 
        PopText(str2)
    end
end

function FishingGameLayer:checkIsGetTitleDay()
    local role = User:getRole()
    if role:getInheritFlag("weekslcd_gameTimes") >=42 then 
        self.isTtitleGetDay = true
    end 
end

Helper:classDefNodeGetInstance(FishingGameLayer)

return FishingGameLayer00000000000
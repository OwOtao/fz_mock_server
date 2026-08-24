local XiTaiQueueUpLayer = class("XiTaiQueueUpLayer", require("app.views.base.BaseLayer"))

--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")
--@RefType [app.models.SpringFestival.TheDogYear.QueueUp#QueueUp]
local QueueUp = require("app.models.SpringFestival.TheDogYear.QueueUp")

local SEAT_COUNT = 10
local ROW_COUNT = 5

--@desc 现有人数
local nowCount = 0
--@desc 开场需要人数
local needCount = 10
--@desc 开场需要等待最长的时间
local maxWaitTime = 60

--@desc 随机计数器
local _randomEventTimeCount = 0
--@desc 随机时间
local _randomEventTime = 0

--@RefType [app.models.map.BaseMap#BaseMap]
local _currMap

-- textList[1] = result.arg2 --开始排队文本
-- textList[2] = result.arg3 --等待过程中排队信息的文本
-- textList[3] = result.arg4 --发生随机事件人数+1文本
-- textList[4] = result.arg5 --发生随机事件人数-1文本
-- textList[5] = result.arg6 --等待时间结束文本
-- textList[6] = result.arg7 --达到最大人数文本
-- textList[7] = result.arg8 --离队文本
local start_wait_text,
    queue_text,
    random_event_add_text,
    random_event_sub_text,
    max_wait_time_text,
    max_num_text,
    leave_text = "", "", "", "", "", "", ""

--@desc 记录数据和UI绑定标记
local _tagList = {}

function XiTaiQueueUpLayer:create()
    local p = XiTaiQueueUpLayer:new()
    p:init()
    return p
end

function XiTaiQueueUpLayer:init()
    self._UI = require("Layer/ActionUI/XiTaiQueueUpUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    for i = 0, SEAT_COUNT - 1 do
        local int = math.modf(i / ROW_COUNT)

        local seat = self:createSeatPanel(i)

        self["ListView_Seat_" .. int]:pushBackCustomItem(seat)
    end

    self:initRichTextPreview()

    self.Panel_back:releaseFunc(
        function()
            if self.handle ~= nil then
                _currMap:pauseSchedule(self.handle)
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show("该操作会停止当前行为，是否继续？")
            dialog:setBack(false)
            dialog:setWeChatVisible(false)
            dialog:setButton1(
                "确定",
                function()
                    self:leaveXiTai()
                end
            )

            dialog:setButton2(
                "取消",
                function()
                    if self.handle ~= nil then
                        _currMap:resumeSchedule(self.handle)
                    end
                end
            )
        end
    )
end

function XiTaiQueueUpLayer:createSeatPanel(index)
    local panel = self.Panel_Seat:clone()
    Helper:convertUIByParent(panel)
    panel.index = index
    return panel
end

--@desc: 设置初始排队人数
--@author:Liang SongQiang
--@time:2018-02-09 11:38:43
--@count: 人数
function XiTaiQueueUpLayer:setStartPeople(count)
    nowCount = Helper:getRange(count, 0, SEAT_COUNT)
    if PRINT_MODE == 1 then
        print("设置初始化排队人数为：", count)
    end
    return true
end

--@desc: 设置开始播戏
--@author:Liang SongQiang
--@time:2018-02-09 17:02:04
function XiTaiQueueUpLayer:setStartPlayFunc(func)
    if type(func) ~= "function" then
        if DEBUG_MODE == 1 then
            assert(false, "传入参数必须是函数")
        end
        return
    end

    self.startPlayFunc = func
end

--@desc: 设置离开
--@author:Liang SongQiang
--@time:2018-02-09 17:41:16
function XiTaiQueueUpLayer:setLeaveXiTaiFunc(func)
    if type(func) ~= "function" then
        if DEBUG_MODE == 1 then
            assert(false, "传入参数必须是函数")
        end
        return
    end

    self.leaveXiTaiFunc = func
end

--@desc: 初始化输出文本
--@author:Liang SongQiang
--@time:2018-02-09 15:12:57
function XiTaiQueueUpLayer:setText(text)
    start_wait_text, queue_text, random_event_add_text = text[1], text[2], text[3]
    random_event_sub_text, max_wait_time_text, max_num_text, leave_text = text[4], text[5], text[6], text[7]
end

--@desc: 设置开场需求的人数
--@author:Liang SongQiang
--@time:2018-02-09 17:45:50
function XiTaiQueueUpLayer:setNeedCount( count )
    needCount = Helper:getRange(count, 0, SEAT_COUNT)
    if PRINT_MODE == 1 then
        print("设置开场需要的人数为：", count)
    end
    return true
end

--@desc: 设置最长等待时间
--@author:Liang SongQiang
--@time:2018-02-09 17:46:07
function XiTaiQueueUpLayer:setMaxWaitTime( time )
    maxWaitTime = Helper:getRange(time, 0, 60)
    if PRINT_MODE == 1 then
        print("设置最长等待时间:", time)
    end
    return true
end

function XiTaiQueueUpLayer:showLayer()
    User:getRole():setFlag("PVP活动状态", "忙碌")
    --@desc 初始化当前的baseMap
    --@RefType [app.models.map.BaseMap#BaseMap]
    _currMap = MainControllLayer:getLayer("MapLayer")._currMap
    _randomEventTime = math.random(1, 5)
    needCount = needCount

    if self.RichText_Print then
        self.RichText_Print:getRichText():removeAllElement()
    end

    local list = QueueUp:initQList(nowCount, 10)
    for i = 0, SEAT_COUNT - 1 do
        local int = math.modf(i / ROW_COUNT)
        local seat = self["ListView_Seat_" .. int]:getItem(i % ROW_COUNT)
        self:seatBindData(seat, i)

        QueueUp:setElementState(0,i)
    end

    for i=1,nowCount + 1 do
        local index = QueueUp:getRandomEmptySeat()

        if index ~= nil then
            if i == nowCount + 1 then
                QueueUp:setMySeatIndex(index)
            end
            
            QueueUp:sitDown(index)
        end

    end

    nowCount = #(QueueUp:getSeatList()) + 1

    self:startQueue()

    self:show(true)
end

function XiTaiQueueUpLayer:seatBindData(seat, index)
    local list = QueueUp:getQList()
    local data = {
        index = index,
        __tag = ""
    }
    data.__tag =
        binding.watch(
        list,
        index,
        function()
            if list[index] == 0 then
                seat.CheckBox_Seat:setSelected(false)
                seat.CheckBox_Seat.Text_Name:setString("空位")
                seat.CheckBox_Seat.Text_Name:setTextColor({r = 208, g = 208, b = 208})
            elseif list[index] == 1 then
                seat.CheckBox_Seat:setSelected(true)
                local mySeatIndex = QueueUp:getMySeatIndex()
                if index == mySeatIndex then
                    seat.CheckBox_Seat.Text_Name:setString("你")
                else
                    seat.CheckBox_Seat.Text_Name:setString("有人")
                end
                seat.CheckBox_Seat.Text_Name:setTextColor({r = 80, g = 244, b = 244})
            end
        end
    )

    _tagList[index] = data
end

--@desc: 退出界面
--@author:Liang SongQiang
--@time:2018-02-09 14:33:31
function XiTaiQueueUpLayer:hideLayer()
    PopupLayerController:hideLayer(
        "XiTaiQueueUpLayer",
        function(layer)
            nowCount = 0
            needCount = 10
            QueueUp:setMySeatIndex(-1)

            start_wait_text,
                queue_text,
                random_event_add_text,
                random_event_sub_text,
                max_wait_time_text,
                max_num_text,
                leave_text = "", "", "", "", "", "", ""

            if self.handle ~= nil then
                _currMap:unSchedule(self.handle)
                self.handle = nil
            end

            local qList = QueueUp:getQList()
            if not MapIsEmpty(_tagList) then
                for k, v in pairs(_tagList) do
                    QueueUp:setElementState(0, v.index)
                    binding.unwatch(qList, v.index, v.__tag)
                end
            end

            layer:hide(true)
        end
    )
end

--@desc: 初始化文本输出框
--@author:Liang SongQiang
--@time:2018-02-09 15:13:51
function XiTaiQueueUpLayer:initRichTextPreview()
    local x, y = self.Panel_Print.Panel_print:getPosition()
    local size = self.Panel_Print.Panel_print:getContentSize()
    if self.RichText_Print then
        self.RichText_Print:removeFromParent()
        self.RichText_Print = nil
    end
    local richTextScroll = ExtRichTextScroll:create()
    richTextScroll:setAnchorPoint(0.5, 0.5)
    self.Panel_Print.Panel_print:getParent():addChild(richTextScroll)
    local point = cc.p(self.Panel_Print.Panel_print:getPosition())
    richTextScroll:move(point)
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:getRichText():setVerticalSpace(5)
    self.RichText_Print = richTextScroll
    self.RichText_Print:setBounceEnabled(false)
    self.RichText_Print:setTouchEnabled(false)
end

function XiTaiQueueUpLayer:print(text, verticalSpace)
    local str = string.gsub(text, "$N", tonumber(nowCount))
    str = string.gsub(str, "$W", tonumber(needCount - nowCount))
    str = string.gsub(str, "$T", tonumber(needCount))

    local textColor = cc.c3b(102, 153, 153)
    local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
    if textHeight >= 6000 then
        self:initRichTextPreview()
    end
    self.Panel_Print.Panel_print:setVisible(false)
    self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

    if verticalSpace ~= nil and type(verticalSpace) == "number" then
        self.RichText_Print:pushBackNewLine(verticalSpace)
    else
        self.RichText_Print:pushBackNewLine()
    end
end

function XiTaiQueueUpLayer:startQueue()
    self:print(start_wait_text)

    local nowTime = 0
    self.handle =
        _currMap:setSchedule(
        function()
            nowTime = nowTime + 1
            if nowTime >= maxWaitTime then
                self:print(max_wait_time_text)
                self:startPlay()
                return
            end

            _randomEventTimeCount = _randomEventTimeCount + 1
            if _randomEventTimeCount >= _randomEventTime then
                _randomEventTimeCount = math.random(2, 5)
                _randomEventTimeCount = 0
                self:doRandomEvent(queue_text)
            end

            print("--------------------- nowTime "..nowTime.."-------------------")
            if nowTime % 3 == 0 and nowCount < 10 then
                self:print(queue_text)
            end
        end,
        1,
        1
    )
end

function XiTaiQueueUpLayer:doRandomEvent()
    local result = QueueUp:getRandomResult(nowCount)
    if result == 1 then
        --@desc 坐下
        local index = QueueUp:getRandomEmptySeat()
        if index ~= nil then
            QueueUp:sitDown(index)
            nowCount = #(QueueUp:getSeatList()) + 1
            
            if nowCount >= needCount then
                self:print(max_num_text)
                self:startPlay()
                return
            else
                self:print(random_event_add_text)
            end
        end
    elseif result == 2 then
        local index = QueueUp:getRandomSeat()
        if index ~= nil then
            QueueUp:leaveSeat(index)
            nowCount = #(QueueUp:getSeatList()) + 1
            self:print(random_event_sub_text)
        end

    end
end

--@desc 看戏开始
function XiTaiQueueUpLayer:startPlay()
    if self.handle ~= nil then
        _currMap:unSchedule(self.handle)
        self.handle = nil
    end

    self:delayFunc(
        2.0,
        function()
            _currMap:setCanLeave(true)
            User:getRole():setFlag("PVP活动状态", "空闲中")
            self.startPlayFunc()
            self:hideLayer()
        end
    )
end

--@desc 离开戏台
function XiTaiQueueUpLayer:leaveXiTai()
    if self.handle ~= nil then
        _currMap:unSchedule(self.handle)
        self.handle = nil
    end

    _currMap:setCanLeave(true)
    User:getRole():setFlag("PVP活动状态", "空闲中")
    self.leaveXiTaiFunc()
    self:hideLayer()
end

Helper:classDefNodeGetInstance(XiTaiQueueUpLayer)
return XiTaiQueueUpLayer
00000
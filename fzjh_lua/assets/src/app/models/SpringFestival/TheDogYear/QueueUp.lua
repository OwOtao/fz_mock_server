local QueueUp = {}
--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

--@RefType 排队列表
local qList = {}

--@desc 已经有人的位置索引列表
local seatList = {}

--@desc 没人的座位索引列表
local emptySeatList = {}

local SEAT_COUNT = 10

--@desc 坐下
local SITDOWN = 1
--@desc 离开座位
local LEAVESEAT = 0

--@desc 自己的位置索引，-1为无座
local mySeatIndex = -1

function QueueUp:initQList(nowNumber, needNumber)
	emptySeatList = {}
    for i = 0, SEAT_COUNT - 1 do
        table.insert(emptySeatList, i)
    end

    seatList = {}

    mySeatIndex = -1

    local tempList = {}
    for i = 0, needNumber - 1 do
        tempList[i] = true
    end

    qList = binding.bindable(tempList)

    return qList
end

--@desc: 获取排队列表
--@author:Liang SongQiang
--@time:2018-02-09 11:18:04
function QueueUp:getQList()
    return qList
end

--@desc: 随机获得空位索引
--@author:Liang SongQiang
--@time:2018-02-09 20:05:55
function QueueUp:getRandomEmptySeat()
    if MapIsEmpty(emptySeatList) then
        if DEBUG_MODE == 1 then
            print("已经没有空位！")
        end
        return nil
    end

    local emptySeatCount = #emptySeatList

    local index = math.random(1, emptySeatCount)

    return emptySeatList[index]
end

--@desc: 获取已有人的随机索引
--@author:Liang SongQiang
--@time:2018-02-09 20:36:43
function QueueUp:getRandomSeat()
    if MapIsEmpty(seatList) then
        if DEBUG_MODE == 1 then
            print("全部座位都是空的！")
            return nil
        end
    end

    local seatCount = #seatList

	local index = math.random(1, seatCount)
	
	return seatList[index]
end

--@desc: 坐下
--@author:Liang SongQiang
--@time:2018-02-09 20:07:41
--@index: 座位的索引
function QueueUp:sitDown(index)
    for i, v in ipairs(emptySeatList) do
        if index == v then
            table.remove(emptySeatList, i)
            break
        end
	end
	if index ~= mySeatIndex then
		table.insert(seatList, index)
	end
    self:setElementState(SITDOWN, index)
end



--@desc: 离开座位
--@author:Liang SongQiang
--@time:2018-02-09 20:14:52
function QueueUp:leaveSeat(index)
    for i, v in ipairs(seatList) do
        if v == index then
            table.remove(seatList, i)
            break
        end
    end

    table.insert(emptySeatList, index)
    self:setElementState(LEAVESEAT, index)
end

--@desc: 获取已有人的座位索引表
--@author:Liang SongQiang
--@time:2018-02-09 20:15:37
function QueueUp:getSeatList()
    return seatList
end

--@desc: 设置我的座位
--@author:Liang SongQiang
--@time:2018-02-09 20:29:19
function QueueUp:setMySeatIndex(index)
    mySeatIndex = index
end

--@desc: 获取我的座位
--@author:Liang SongQiang
--@time:2018-02-09 20:29:58
function QueueUp:getMySeatIndex()
    return mySeatIndex
end

--@desc: 改变排队元素状态
--@author:Liang SongQiang
--@time:2018-02-09 11:19:27
--@state:状态0,1，0为空，1为有人
--@index: 索引
function QueueUp:setElementState(state, index)
    if index < 0 or index > 9 then
        if PRINT_MODE == 1 then
            print("index 传参错误。")
        end
        return false
    end

    if state < 0 or state > 1 then
        if PRINT_MODE == 1 then
            print("state 传参错误。")
        end
        return false
    end

    if qList[index] ~= state then
        qList[index] = state
    end
    return true
end

--@desc: 清理排队列表，清理完毕后重新创建必须调用initQList方法创建列表
--@author:Liang SongQiang
--@time:2018-02-09 11:15:23
function QueueUp:clearQList()
    qList = {}
    if PRINT_MODE == 1 then
        print("已清理排队列表")
    end
    return true
end

function QueueUp:getRandomResult(nowCount)
    local list = nil
    if nowCount <= 1 then
        list = {[1] = 80, [2] = 0, [3] = 20}
    else
        list = {[1] = 50, [2] = 20, [3] = 10}
    end
    return Helper:RandomByWeight(list)
end

return QueueUp
00000000
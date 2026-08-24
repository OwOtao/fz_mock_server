
local HuaRongDaoModel = {}

local CHESSBOARD_STATUS = {
    READY = 0,
    RUNNING = 1,
    WIN = 2,
    LOSE = 3
}

--@desc 棋盘相关信息
local CHESSBOARD_INFO = {
    --@desc 棋盘锁
    board_lock = nil,
    --@desc 通关滑块
    key_block = nil,
    --@desc 当前触摸
    touch_block = nil,
    --@desc 前一次滑动的方向
    pre_move_dir = nil,
    --@desc 前一个触摸的点
    pre_touch_point = nil,
    --@desc 棋盘的rect
    boundingbox = nil,
    --@desc 棋盘的NODE
    container = nil,
    status = nil
}

--@desc 边长
local SIDE = 224

local DIRECTION = {
    NOT_MOVE = 0,
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3,
    UP = 4
}

local WIN_POINT = {
    x = SIDE,
    y = 0
}

function HuaRongDaoModel:getGuanQiaInfo()
    local res = require("script.others.huarongdao")["piece"]

    local guanqiaGroup = {}
    local guanqiaMax = 0
    for _, v in pairs(res) do
        local group = tostring(v.group)

        if guanqiaGroup[group] == nil then
            guanqiaGroup[group] = {}
            guanqiaMax = guanqiaMax + 1
        end

        guanqiaGroup[group][tostring(v.pieceid)] = v
    end

    if MapIsEmpty(guanqiaGroup) then
        assert(false,"HuaRongDaoModel:getGuanQiaInfo huarongdao资源有问题")
    end

    return guanqiaGroup,guanqiaMax
end

function HuaRongDaoModel:getGuanQiaDataByIndex(guanqia)
    local guanqiaGroup,max_guanqia = self:getGuanQiaInfo()

    if guanqia > max_guanqia then
        assert(false,"HuaRongDaoModel:getGuanQiaDataByIndex 关卡下标有问题")
    end

    return guanqiaGroup[tostring(guanqia)]
end

function HuaRongDaoModel:getRandGuanQia()

    local guanqiaGroup,max_guanqia = self:getGuanQiaInfo()

    if max_guanqia < 1 then
        max_guanqia = 1
        assert(false,"HuaRongDaoLayer:randGuanQia 关卡数小于1")
    end

    return math.random(1,max_guanqia)
end

function HuaRongDaoModel:getChessboardInfoData()
    return CHESSBOARD_INFO
end

--@desc: 清除棋盘信息
--@author:Liang SongQiang
--@time:2019-08-23 21:12:29
function HuaRongDaoModel:clearChessboardInfo(chessboard_info)
    for k, v in pairs(chessboard_info) do
        v = nil
    end
end

function HuaRongDaoModel:finishGame(chessboard_info)
    chessboard_info.board_lock = false

    chessboard_info.container:unscheduleAll()

    if chessboard_info.status == CHESSBOARD_STATUS.WIN then
        PopText("通关了！")
    elseif chessboard_info.status == CHESSBOARD_STATUS.LOSE then
        PopText("时间到！")
    end
end

--@desc 获取棋盘坐标
function HuaRongDaoModel:getChessboardPoint(x, y)
    local posX = x * SIDE

    local posY = y * SIDE

    return cc.p(posX, posY)
end

function HuaRongDaoModel:getChessboardCoordinate(point)
    local x = math.modf(point.x / SIDE)
    local y = math.modf(point.y / SIDE)
    return x, y
end

function HuaRongDaoModel:isTouchFocusNode(touch, node)
    local touchP = touch:getLocation()
    local bound = node:getBoundingBox()
    local point = node:convertTouchToNodeSpaceAR(touch)
    local anchor = node:getAnchorPoint()
    if (point.x >= -bound.width * anchor.x) and (point.x <= bound.width * (1 - anchor.x)) and (point.y >= -bound.height * anchor.y) and (point.y <= bound.height * (1 - anchor.y)) then
        return true
    end
    return false
end

function HuaRongDaoModel:getMoveDirection(nowPos, oldPos)
    local dx = nowPos.x - oldPos.x

    local dy = nowPos.y - oldPos.y

    local dir = DIRECTION.NOT_MOVE

    if dx == 0 and dy == 0 then
        return dir
    end

    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then
            dir = DIRECTION.RIGHT
        else
            dir = DIRECTION.LEFT
        end
    else
        if dy > 0 then
            dir = DIRECTION.UP
        else
            dir = DIRECTION.DOWN
        end
    end

    return dir
end

--@desc: 检测两矩形是否相交（边重叠不属于相交范围）
--@author:Liang SongQiang
--@time:2019-08-23 19:21:26
function HuaRongDaoModel:rectInterseectionRect(rect1, rect2)
    local intersect = not (rect1.x >= rect2.x + rect2.width or rect1.x + rect1.width <= rect2.x or rect1.y >= rect2.y + rect2.height or rect1.y + rect1.height <= rect2.y)

    return intersect
end

--@desc: 是否通关
--@author:Liang SongQiang
--@time:2019-08-23 19:22:33
function HuaRongDaoModel:isWin(move_block,key_block)
    if move_block ~= key_block then
        return false
    end

    local posX, posY = key_block:getPosition()

    if posX == WIN_POINT.x and posY == WIN_POINT.y then
        return true
    end

    return false
end

--通关后处理
function HuaRongDaoModel:doWinFun(chessboard_info)
    chessboard_info.status = CHESSBOARD_STATUS.WIN
    self:finishGame(chessboard_info)
end

--游戏状态设置
function HuaRongDaoModel:setGameStatus(chessboard_info,status)
    if "ready" == status then
        chessboard_info.status = CHESSBOARD_STATUS.READY
    elseif "running" == status then
        chessboard_info.status = CHESSBOARD_STATUS.RUNNING
    elseif "win" == status then
        chessboard_info.status = CHESSBOARD_STATUS.WIN
    elseif "lose" == status then
        chessboard_info.status = CHESSBOARD_STATUS.LOSE
    end
end

function HuaRongDaoModel:checkGameStatus(chessboard_status,status)
    if "ready" == status and chessboard_status == CHESSBOARD_STATUS.READY then
        return true
    elseif "running" == status and chessboard_status == CHESSBOARD_STATUS.RUNNING then
        return true
    elseif "win" == status and chessboard_status == CHESSBOARD_STATUS.WIN then
        return true
    elseif "lose" == status and chessboard_status == CHESSBOARD_STATUS.LOSE then
        return true
    end
    return false
end

--@desc: 松手时矫正滑块位置，必须在方格上。
--@author:Liang SongQiang
--@time:2019-08-23 18:17:39
--@touchNode: 当前移动的滑块
function HuaRongDaoModel:correctMoveBlock(touchNode)
    local px, py = touchNode:getPosition()

    local c_x, c_y = self:getChessboardCoordinate(cc.p(px, py))

    local pos = self:getChessboardPoint(c_x, c_y)

    if (px - pos.x) / SIDE > 0.5 then
        c_x = c_x + 1
    end

    if (py - pos.y) / SIDE > 0.5 then
        c_y = c_y + 1
    end

    local final_pos = self:getChessboardPoint(c_x, c_y)

    touchNode:setPosition(final_pos)
end

function HuaRongDaoModel:canMoveBlock(node, finalPoint, allNode)

    local node_boundingBox = node:getBoundingBox()

    local node_rect = {
        x = finalPoint.x,
        y = finalPoint.y,
        width = node_boundingBox.width,
        height = node_boundingBox.height
    }

    local canMove = true

    for i, targetNode in ipairs(allNode) do
        if node ~= targetNode then
            if self:rectInterseectionRect(node_rect, targetNode:getBoundingBox()) then
                canMove = false
                break
            end
        end
    end

    return canMove
end

function HuaRongDaoModel:onTouchBegin(chessboard_info,touch, event)
    if chessboard_info.board_lock ~= true then
        return false
    end

    local node = event:getCurrentTarget()

    if HuaRongDaoModel:isTouchFocusNode(touch, node) then
        chessboard_info.touch_block = node
        return true
    end

    return false
end

function HuaRongDaoModel:onTouchMove(chessboard_info,touch, event)
    local touchPoint = touch:getLocation()

    if chessboard_info.pre_touch_point == nil then
        chessboard_info.pre_touch_point = touchPoint
    end

    local movePoint = {x = touchPoint.x - chessboard_info.pre_touch_point.x, y = touchPoint.y - chessboard_info.pre_touch_point.y}

    if chessboard_info.touch_block then
        local nodeX, nodeY = chessboard_info.touch_block:getPosition()

        --@region 方向判断
        local now_dir = HuaRongDaoModel:getMoveDirection(touchPoint, chessboard_info.pre_touch_point)

        if chessboard_info.pre_move_dir == nil then
            chessboard_info.pre_move_dir = now_dir
        end

        if chessboard_info.pre_move_dir == DIRECTION.LEFT or chessboard_info.pre_move_dir == DIRECTION.RIGHT then
            if now_dir ~= DIRECTION.RIGHT or now_dir ~= DIRECTION.LEFT then
                now_dir = chessboard_info.pre_move_dir
            end
        elseif chessboard_info.pre_move_dir == DIRECTION.UP or chessboard_info.pre_move_dir == DIRECTION.DOWN then
            if now_dir ~= DIRECTION.DOWN or now_dir ~= DIRECTION.UP then
                now_dir = chessboard_info.pre_move_dir
            end
        end
        chessboard_info.pre_move_dir = now_dir
        --@endregion

        if now_dir == DIRECTION.LEFT or now_dir == DIRECTION.RIGHT then
            movePoint.y = 0
        elseif now_dir == DIRECTION.UP or now_dir == DIRECTION.DOWN then
            movePoint.x = 0
        else
            movePoint.x = 0
            movePoint.y = 0
        end

        local finalPoint = cc.pAdd(cc.p(nodeX, nodeY), movePoint)

        local touchNode_rect = chessboard_info.touch_block:getBoundingBox()

        if finalPoint.x + touchNode_rect.width > chessboard_info.boundingbox.width then
            finalPoint.x = chessboard_info.boundingbox.width - touchNode_rect.width
        end

        if finalPoint.y + touchNode_rect.height > chessboard_info.boundingbox.height then
            finalPoint.y = chessboard_info.boundingbox.height - touchNode_rect.height
        end

        if finalPoint.x < 0 then
            finalPoint.x = 0
        end

        if finalPoint.y < 0 then
            finalPoint.y = 0
        end
        --@endregion

        local allNode = chessboard_info.container:getChildren()
        if HuaRongDaoModel:canMoveBlock(chessboard_info.touch_block, finalPoint, allNode) then
            chessboard_info.touch_block:setPosition(finalPoint)
        end

        local touchNodeBox = chessboard_info.touch_block:getBoundingBox()
        chessboard_info.pre_touch_point = touchPoint
    -- print("--------------------------------------------------------------")
    -- print("touch point     ",touchPoint.x,touchPoint.y)
    -- print("old touch point ",chessboard_info.pre_touch_point.x,chessboard_info.pre_touch_point.y)
    -- print("move point      ",movePoint.x,movePoint.y)
    -- print("node position   ",nodeX,nodeY)
    -- print("end point       ",touchNodeBox.x,touchNodeBox.y)
    -- print("touch node size ",touchNodeBox.width,touchNodeBox.height)
    -- print("--------------------------------------------------------------\n")
    end

    return true
end

function HuaRongDaoModel:onTouchEnd(chessboard_info,touch, event)
    if chessboard_info.touch_block then
        HuaRongDaoModel:correctMoveBlock(chessboard_info.touch_block)
        local isWin = HuaRongDaoModel:isWin(chessboard_info.touch_block,chessboard_info.key_block)
        if isWin then
            HuaRongDaoModel:doWinFun(chessboard_info)
        end
        chessboard_info.touch_block = nil
    end

    if chessboard_info.pre_touch_point then
        chessboard_info.pre_touch_point = nil
    end

    if chessboard_info.pre_move_dir then
        chessboard_info.pre_move_dir = nil
    end

    return true
end

return HuaRongDaoModel0
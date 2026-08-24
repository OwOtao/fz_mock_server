--@SuperType [src.app.views.base.LayerEx#LayerEx]
local HuaRongDaoModel = require("app.models.MiniGame.HuaRongDaoModel")
local HuaRongDaoLayer = class("HuaRongDaoLayer", LayerEx)

--@desc 棋盘相关信息
local chessboard_info = {}

local function onTouchBegin(touch, event)
    return HuaRongDaoModel:onTouchBegin(chessboard_info,touch, event)
end

local function onTouchMove(touch, event)
    return HuaRongDaoModel:onTouchMove(chessboard_info,touch, event)
end

local function onTouchEnd(touch, event)
    return HuaRongDaoModel:onTouchEnd(chessboard_info,touch, event)
end

function HuaRongDaoLayer:create()
    local p = HuaRongDaoLayer:new()
    p:init()
    return p
end

-- local test_nodes = {
--     {x = 0, y = 0, imgName = "block1"},
--     {x = 3, y = 0, imgName = "block1"},
--     {x = 1, y = 1, imgName = "block1"},
--     {x = 2, y = 1, imgName = "block1"},
--     {x = 0, y = 3, imgName = "block1"},
--     {x = 0, y = 4, imgName = "block1"},
--     {x = 0, y = 1, imgName = "block2"},
--     {x = 3, y = 1, imgName = "block2"},
--     {x = 3, y = 3, imgName = "block2"},
--     {x = 1, y = 4, imgName = "block3"},
--     {x = 1, y = 2, imgName = "block4"}
-- }

function HuaRongDaoLayer:init()
    self._UI = require("Layer/MiniGame/HuaRongDaoUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:initData()

    self.Button_back:releaseFunc(
        function()
            if HuaRongDaoModel:checkGameStatus(chessboard_info.status,"running") then
                PopText("解谜中，无法退出")
                return
            end

            self:hideLayer()
        end
    )
end

function HuaRongDaoLayer:initData()
    chessboard_info = HuaRongDaoModel:getChessboardInfoData()
end

function HuaRongDaoLayer:hideLayer()
    PopupLayerController:hideLayer(
        "HuaRongDaoLayer",
        function(layer)
            MainControllLayer:resumeUpdate()

            self.Image_container:removeAllChildren()

            if HuaRongDaoModel:checkGameStatus(chessboard_info.status,"win") then
                if self._successCallback and type(self._successCallback) == "function" then
                    self._successCallback()
                end
            elseif HuaRongDaoModel:checkGameStatus(chessboard_info.status,"lose") then
                if self._failCallback and type(self._failCallback) == "function" then
                    self._failCallback()
                end
            end

            HuaRongDaoModel:clearChessboardInfo(chessboard_info)

            self._failCallback = nil
            self._successCallback = nil

            layer:hide()
        end
    )
end

--@desc: 开始游戏
--@author:Liang SongQiang
--@time:2019-08-24 09:40:42
function HuaRongDaoLayer:showLayer(game_time,text_desc,game_guanqia)
    MainControllLayer:pauseUpdate()
    
    chessboard_info.board_lock = true

    chessboard_info.boundingbox = self.Image_container:getBoundingBox()

    chessboard_info.container = self.Image_container

    chessboard_info.game_time = Helper:getDef(game_time,30)

    HuaRongDaoModel:setGameStatus(chessboard_info,"ready")

    self.Text_Desc:setString(Helper:getDef(text_desc,"机关钥被石片层层围住，难以解锁，需在规定时间内。拖动石片，移出机关钥，才能将断龙石放下顺利逃生。"))

    local guanqia = Helper:getDef(game_guanqia,1)

    local data = HuaRongDaoModel:getGuanQiaDataByIndex(guanqia)

    for _, v in pairs(data) do
        local block = self:createBlockSprite(v.imgName, v.x, v.y)
        block:addTouchEventListener(onTouchBegin, onTouchMove, onTouchEnd)
        self.Image_container:addChild(block)
    end

    self:show(
        function()
            chessboard_info.board_lock = true
            HuaRongDaoModel:setGameStatus(chessboard_info,"running")
            chessboard_info.startTime = GetTime()

            chessboard_info.container:schedule(
                function()
                    local nowTime = GetTime()
                    local interval = math.max(Helper:mathFloor(nowTime - chessboard_info.startTime), 0)

                    local time = math.max(Helper:mathFloor(chessboard_info.game_time - interval), 0)

                    self.Text_Time:setString("剩余时间" .. time .. "秒")

                    if time <= 0 then
                        HuaRongDaoModel:setGameStatus(chessboard_info,"lose")
                        HuaRongDaoModel:finishGame(chessboard_info)
                    end
                end
            )
        end
    )
end

--@desc:
--@author:Liang SongQiang
--@time:2019-08-23 15:08:02
--@imageName:
--@x:棋盘坐标x
--@y: 棋盘坐标Y
function HuaRongDaoLayer:createBlockSprite(imageName, x, y)
    local img_path = "Image/UI/MiniGame/HuaRongDao/" .. imageName .. ".png"

    local block = cc.Sprite:create(img_path)

    block:setAnchorPoint(0, 0)

    block:setPosition(HuaRongDaoModel:getChessboardPoint(x, y))

    if imageName == "block4" then
        chessboard_info.key_block = block
    end

    return block
end

function HuaRongDaoLayer:setSuccessCallBack(callback)
    self._successCallback = callback
end

function HuaRongDaoLayer:setFailCallBack(callback)
    self._failCallback = callback
end

Helper:classDefNodeGetInstance(HuaRongDaoLayer)
return HuaRongDaoLayer
00000000000000
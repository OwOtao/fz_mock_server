local class = require("third.class.NewClass")

local IFightUpdater = require("app.FightSystem.Updater.IFightUpdater")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.models.OnlineGame.Network#Network]
local Network = require("app.models.OnlineGame.Network")

local FightCommons = require("app.FightSystem.FightCommons")

local NETWORK_INFO = FightCommons:getNetworkInfo()

local LOGIC_FPS = 10

local VIWE_FPS = 30

local NetworkFightUpdater = {}

function NetworkFightUpdater:create()
    return NetworkFightUpdater.new()
end

function NetworkFightUpdater:ctor()
    self.__logic_frame_index = 0

    self.__view_frame_index = 0

    self.__network_id = 0

    --@desc 逻辑帧间隔，固定时间
    self.__LOGIC_UPDATE_DURATION = 1 / LOGIC_FPS

    --@desc 用于场景开始判断
    self.__is_start = false

    --@RefType [src.app.models.OnlineGame.Network#Network]
    self.__network = Network:create(NETWORK_INFO.IP, NETWORK_INFO.PORT)
    self.__network:setRecvDataFunc(
        function(data)
            self:__onRecvData(data)
        end
    )
end

function NetworkFightUpdater:init()
end

function NetworkFightUpdater:destory()
end

function NetworkFightUpdater:connect(callback)
    self.__network:resetGame(
        function(success)
            if success == true then
                self.__network:connect(
                    function(connect_success)
                        if connect_success == true then
                            FightUtil:printLog("服务器连接成功。")
                            self.__network:setIsHost(true)
                            callback(true)
                        else
                            callback(false)
                        end
                    end
                )
            else
                FightUtil:printLog("服务器连接失败。")
                callback(false)
            end
        end
    )
end

function NetworkFightUpdater:reconnent(callback)
    self.__network:connect(
        function(success)
            if success == true then
                FightUtil:printLog("重连成功")
                callback(true)
            else
                FightUtil:printLog("重连失败")
                callback(false)
            end
        end
    )
end

function NetworkFightUpdater:sendRpc(funcName, args)
    return self.__fightInteractor[funcName](self.__fightInteractor, unpack(args))
end

function NetworkFightUpdater:start()
    self.__node = cc.Node:create()
    local scene = cc.Director:getInstance():getRunningScene()
    self.__node:addTo(scene)

    self.__updateTag =
        self.__node:schedule(
        function(dt)
            if self.__is_start == true then
                self:__update(dt)
            end
        end,
        1 / VIWE_FPS,
        "FIGHT_UPDATE_TAG"
    )

    --@desc 每个逻辑帧的数据
    self.__logic_frames = {}

    --@desc 当前要上传的逻辑帧
    self.__upload_frames = {}

    --@desc 战斗开始后运行时间
    self.__current_time = 0

    --@desc 逻辑帧序
    self.__logic_frame_index = 0

    --@desc 渲染帧序
    self.__view_frame_index = 0

    self.__is_start = true

    self.__zero_frame = true

    self.__frame_duration = 0
end

function NetworkFightUpdater:finish()
    self.__node:unschedule(self.__updateTag)
    MainControllLayer:delayFunc(0.1,function ()
        
        self.__node:removeFromParent()
    end)
end

function NetworkFightUpdater:setIFightPresenter(fightPresenter)
    --@RefType[src.app.FightSystem.Presenter.IFightPresenter#IFightPresenter]
    self.__fightPresenter = fightPresenter
end

function NetworkFightUpdater:setIFightInteractor(fightInteractor)
    --@RefType[src.app.FightSystem.Interactor.IFightInteractor#IFightInteractor]
    self.__fightInteractor = fightInteractor
end

function NetworkFightUpdater:getLogicFrameIndex()
    return self.__logic_frame_index
end

function NetworkFightUpdater:getLogicFrameDuration()
    return self.__LOGIC_UPDATE_DURATION
end

--@desc: 发生当前帧数据
--@author:Seven
--@time:2021-03-09 16:04:31
--@frame: [src.app.FightSystem.FightDataModel.Frame#Frame]
function NetworkFightUpdater:putFrame(frame)
    self.__network:sendFrame(self.__network_id, frame:serialize())
end

function NetworkFightUpdater:__onRecvData(data)
    if data.EventType == 303 then
        FightUtil:printLog("only id :" , data.OnlyId)
    elseif data.EventType == 304 then
        --@desc action 数据
        self:__recvFrame(data.Frame)
    end
end

function NetworkFightUpdater:__recvFrame(frame_data)
    local curr_frame = Frame:create()
    curr_frame:init(frame_data)
    if self.__logic_frames[tostring(curr_frame:getFrameIndex())] == nil then
        self.__logic_frames[tostring(curr_frame:getFrameIndex())] = curr_frame
    end
end

function NetworkFightUpdater:updateView(dt)
    -- print("fight view update frame : " .. self.__view_frame_index)
    self.__fightPresenter:updateView(dt)
end

function NetworkFightUpdater:updateLogic(frame)
    self.__fightInteractor:processFrame(frame)
    if self.__network:isHost() == true then
        self.__fightInteractor:updateLogic()
    end
end

function NetworkFightUpdater:__update(dt)
    if self.__zero_frame == true and self.__network:isHost() == true then
        --@desc 第0帧，不做任何处理
        local zero_frame = Frame:create()
        zero_frame:setFrameIndex(self.__logic_frame_index)
        -- zero_frame:setFrameDurationTime(self.__LOGIC_UPDATE_DURATION)
        zero_frame:putFrameData("role_actions", {})
        self:putFrame(zero_frame)

        self.__view_frame_index = self.__view_frame_index + 1
        self.__logic_frame_index = self.__logic_frame_index + 1
        self.__zero_frame = false
        return
    end
    self.__frame_duration = self.__frame_duration + dt

    if self.__frame_duration >= self.__LOGIC_UPDATE_DURATION then
        local pre_frame = self.__logic_frames[tostring(self.__logic_frame_index - 1)]
        if pre_frame ~= nil then
            FightUtil:printLog("=================== 逻辑帧：", self.__logic_frame_index , " 开始 ===================")
            self:updateLogic(pre_frame)
            FightUtil:printLog("=================== 逻辑帧：", self.__logic_frame_index , " 结束 ===================")
            self.__logic_frames[tostring(self.__logic_frame_index - 1)] = nil
            self.__logic_frame_index = self.__logic_frame_index + 1
            self.__frame_duration = self.__frame_duration - self.__LOGIC_UPDATE_DURATION
        else
            FightUtil:printLog("逻辑帧 ：", tostring(self.__logic_frame_index - 1) , "数未到达")
        end
    end
end

return class("NetworkFightUpdater", {IFightUpdater}, NetworkFightUpdater)
000000000000
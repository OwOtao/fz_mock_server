--[[
    该接口负责更新UI帧及逻辑帧
]]
local interface = require("third.class.interface")

local IFightUpdater = {}

function IFightUpdater:init()
end

function IFightUpdater:destory()
end

function IFightUpdater:connect(callback)
end

function IFightUpdater:reconnent(callback)
end

function IFightUpdater:sendRpc(funcName, args)
end

function IFightUpdater:start()
end

function IFightUpdater:finish()
end

function IFightUpdater:setIFightPresenter(fightPresenter)
end

function IFightUpdater:setIFightInteractor(fightInteractor)
end

function IFightUpdater:getLogicFrameIndex()
end

function IFightUpdater:getLogicFrameDuration()
end

--@desc: 加入发送数据
--@author:Seven
--@time:2021-03-09 16:09:41
--@frame: [src.app.FightSystem.FightDataModel.Frame#Frame]
function IFightUpdater:putFrame(frame)
end

function IFightUpdater:updateView(dt)
end

--@desc: 更新逻辑帧
--@author:Seven
--@time:2021-03-13 17:05:44
--@frame: [src.app.FightSystem.FightDataModel.Frame#Frame]
function IFightUpdater:updateLogic(frame)
end

return interface("IFightUpdater", IFightUpdater)
00
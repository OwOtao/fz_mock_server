local newClass = require("third.class.NewClass")

local WuZangScoreRepair = {}

function WuZangScoreRepair:create(role)
    local p = WuZangScoreRepair.new()

    p:__init(role)

    return p
end

function WuZangScoreRepair:__init(role)
    self.__role = role
end

function WuZangScoreRepair:repair()
    if self.__role.wuZangScoreRepair == nil  then
        self:__repaireWuZangScore()
    end
end

--[[
    @desc: 修复武藏评分异常问题
    author:tanqinjian
    time:2025-11-10 10:38:58
    @return:
]]
function WuZangScoreRepair:__repaireWuZangScore()
    local XuanBingDongModel = require("app.models.ShenBing.XuanBingDongModel"):getInstance()
    XuanBingDongModel:getListFromServer()

    local CangYiGeModel = require("app.models.ShenBing.CangYiGeModel"):getInstance()
    CangYiGeModel:getListFromServer(EMPTY_FUNC)

    self.__role.wuZangScoreRepair = 1
end

return newClass("WuZangScoreRepair", {}, WuZangScoreRepair)
0000000000000000
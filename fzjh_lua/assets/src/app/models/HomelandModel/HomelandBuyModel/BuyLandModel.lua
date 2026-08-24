local BuyLandModel = {
    _needRefresh = false
}

local DiQiModel = require("app.models.HomelandModel.DiQiModel")

--@RefType [src.app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

--@desc 地皮数据
local landList = {}

local currPoint = 0

--@desc: 创建数据绑定结构
--@author:Liang SongQiang
--@time:2018-05-22 11:08:07
--@data: 服务器列表
function BuyLandModel:initData(data)
    landList = {}

    for i, v in ipairs(data) do
        local dpInfo = DiQiModel:getDpInfoById(v.dpId)
        v = Helper:tableCover(v, dpInfo)
        v.index = i
        v.type = "地契"
        landList[i] = binding.bindable(v)
    end

    currPoint = 0

    return landList
end

--@desc 获取初始化好的地皮列表
function BuyLandModel:getLandList()
    return landList
end

--@desc:设置当前价格
--@author:Liang SongQiang
--@time:2018-05-22 15:57:49
--@index:列表索引
--@currPrice:当前价格
function BuyLandModel:setCurrPrice(index, currPrice)
    if not currPrice or not index then
        if DEBUG_MODE == 1 then
            assert(false, "index 或者 crrPrice为空")
        end
    end

    landList[index].high_price = currPrice
end

--@desc 设置当前最高竞价者的名字
function BuyLandModel:setCurrHighName(index, name)
    if not name or not index then
        if DEBUG_MODE == 1 then
            assert(false, "index 或者 name为空")
        end
    end

    if type(name) ~= "string" then
        print("name 类型不为字符串")
        return
    end

    landList[index].high_name = name
end

--@desc 获取当前竞价剩余时间
function BuyLandModel:setSurplusTime(index, time)
    if not time or not index then
        if DEBUG_MODE == 1 then
            assert(false, "index 或者 time为空")
        end
    end

    -- if type(time) ~= "number" then
    --     print("time 类型不为数字")
    --     return
    -- end

    landList[index].surplusTime = time
end

--@desc 获取当前银票
function BuyLandModel:getCurrPoiont()
    return Helper:getDef(currPoint, 0)
end

--@desc: 设置当前银票值
--@author:Liang SongQiang
--@time:2018-05-24 12:29:55
function BuyLandModel:setCurrPoint(value)
    if currPoint ~= value then
        self._needRefresh = true
    end
    currPoint = value
end

--@desc:设置当前状态
--@author:Liang SongQiang
--@time:2018-05-22 15:58:20
--@index:列表索引
--@currState:1 上架 2 竞拍中
function BuyLandModel:setCurrState(index, currState)
    landList[index].state = currState
end

return BuyLandModel
000
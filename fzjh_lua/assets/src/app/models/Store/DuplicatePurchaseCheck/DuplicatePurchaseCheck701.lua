--[[
    服务器资源/货币，类型编码为701：判断条件可填写>、<、=、<=、>=几个符号，逻辑为判断玩家【已持有该资源数】与判断值数值的大小关系

    检索值可填写任意服务器资源Id，当前服务器资源有以下类型

    【类型4】为【旧服务器物品】，该类型为：旧服务器资源，有存储上限，无回溯功能

    【类型5】为【缓存数据】，该类型为：以服务器缓存为存储方式的货币

    【类型6】为【服务器可回溯资源】，该类型为：使用版本管理，有存档回溯机制，但未进入货币管理表的货币

    【类型10】为【货币管理表新货币】，该类型为：使用<货币管理配置表.xlsx>管理的新货币

    检索值：服务器资源id;服务器资源类型
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck701 = {}

--[[
    @desc: 
    author:tanqinjian
    time:2026-05-18 14:37:53
    --@role: 
    @return:bool true:不允许购买 false:允许购买
]]
function DuplicatePurchaseCheck701:checkDuplicatePurchase(role)
    local result = false
    
    local msg = nil
 
    local searchValue = string.split(self._res:getSearchvalue(), ";") 

    local serverResourceId = searchValue[1]

    local serverResourceType = tonumber(searchValue[2])

    local itemList = {
        {
            id = serverResourceId,
            type = serverResourceType
        }
    }

    local dataVer = role:getServerActionSystem():getDataVersion()

    local currencyVersion = role:getCurrencyVersion()

    HttpManagerEx:getServerResourceCount(itemList, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local countData = data.countData
            local count = nil

            for k, v in ipairs(countData) do
                if v.id == serverResourceId and v.type == serverResourceType then
                    count = v.count
                    break
                end
            end

            if not count then
                error("DuplicatePurchaseCheck701:checkDuplicatePurchase，商品资源id异常或获取数量异常，检索值为："..tostring(searchValue))
            end

            if self:_compareValue(count) then
                result = true
                if msg == nil then
                    msg = "已达到商品可持有数量的限制，不可购买！"
                end
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
    
    return result , msg
end

return newClass("DuplicatePurchaseCheck701", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck701)
00000000000
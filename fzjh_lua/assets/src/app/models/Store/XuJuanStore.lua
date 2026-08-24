local class = require("third.class.NewClass")
local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

local XuJuanStore = {}

function XuJuanStore:create()
    return XuJuanStore:new()
end

function XuJuanStore:ctor()
    self.__leftList = {}
    self.__rightList = {}
    self.__yuanBao = 0
    self.__isRefreshLimit = false
end

function XuJuanStore:setRefreshFunc(func)
    self._refreshFunc = Helper:getDef(func,EMPTY_FUNC)
end

function XuJuanStore:getLeftList()
    return self.__leftList
end

function XuJuanStore:getRightList()
    return self.__rightList
end

function XuJuanStore:getSpendYuanBao()
    return self.__yuanBao
end

function XuJuanStore:getIsRefreshLimit()
    return self.__isRefreshLimit
end

function XuJuanStore:getCurrencyNum()
    return self.__currencyNum
end

function XuJuanStore:getCurrencyName()
    return self.__currencyName
end

function XuJuanStore:getInfo(callback)
    self:__getMattersShopInfo(1,callback)
end

function XuJuanStore:refresh(callback)
    self:__getMattersShopInfo(2,callback)
end

function XuJuanStore:buyGoods(goodsId,callback)
    HttpManagerEx:buyMatters(goodsId, User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
        if status == 200 then 
            if errcode == 0 or errcode == 2 then
                if data.reward then
                    local itemInfo = data.reward
                    local name = SkillBreakThroughResManager:getBreakThroughItem(itemInfo.id).name
                    PopText("获得"..name.."X"..itemInfo.num)
                end

                if data.currencyVersion then
                    User:getRole():setCurrencyVersion(data.currencyVersion)
                end

                if callback then
                    callback(errcode)
                end

                if errcode == 2 then
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function XuJuanStore:__getMattersShopInfo(type,callback)
    HttpManagerEx:mattersShopInfo(type, User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__yuanBao = data.yuanbao_num

            self.__currencyNum = data.currency_number

            self.__currencyName = data.currency_name

            self.__isRefreshLimit = data.isRefreshLimit

            self:__initLeftList(data.matters_list)
            
            self:__initRightList(data.goods_list)

            if data.currencyVersion then
                User:getRole():setCurrencyVersion(data.currencyVersion)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function XuJuanStore:__initLeftList(list)
    self.__leftList = {}

    if MapIsEmpty(list) == false then
        for i, itemInfo in pairs(list) do
            local _itemInfo = {}
            _itemInfo.name = SkillBreakThroughResManager:getBreakThroughItem(itemInfo.id).name.." X "..itemInfo.num

            table.insert(self.__leftList,_itemInfo)
        end
    end
end

function XuJuanStore:__initRightList(list)
    self.__rightList = {}

    if MapIsEmpty(list) == false then
        for i, itemInfo in pairs(list) do
            local _itemInfo = {}
            _itemInfo.goodsId = itemInfo.key
            _itemInfo.num = itemInfo.num
            _itemInfo.price = itemInfo.price..self:getCurrencyName()

            local item = SkillBreakThroughResManager:getBreakThroughItem(itemInfo.id)
            _itemInfo.name = item.name
            _itemInfo.dsc = item.dsc

            table.insert(self.__rightList,_itemInfo)
        end
    end
end

return class("XuJuanStore", {}, XuJuanStore)
000000000
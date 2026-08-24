local class = require("third.class.NewClass")

local TeacherBuildResExchangeStore = {}

function TeacherBuildResExchangeStore:create()
    return TeacherBuildResExchangeStore:new()
end

function TeacherBuildResExchangeStore:ctor()
    self._desc = "可通过交易建筑材料获得其他师门奖励。"

    self._exchangeTimes = 0

    self._list = {}
end

function TeacherBuildResExchangeStore:setRole(role)
    self._role = role
end

function TeacherBuildResExchangeStore:init(successfulCallback, failedCallBack)
    local menpai = self._role:getFamilyId()
    if not menpai then
        assert(false, "需要加入门派才能进入")
        return
    end

    HttpManagerEx:getSectSupportShop(menpai,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._exchangeTimes = data.exchangeLimit - data.exchangeTimes 

            self:__dealWithInfo(data.list)
            
            if successfulCallback then
                successfulCallback()
            end
        else
            PopText(errmsg)
            if failedCallBack then
                failedCallBack()
            end
        end
    end,IS_SHOW_WAITING)
end

function TeacherBuildResExchangeStore:getActionDesc()
    return self._desc
end

function TeacherBuildResExchangeStore:getExchangeTimes()
    return self._exchangeTimes
end

function TeacherBuildResExchangeStore:getList()
    return self._list
end

function TeacherBuildResExchangeStore:getAttrName(attr)
    return self._role:getCHAttrName(attr)
end

function TeacherBuildResExchangeStore:buyGoods(rewardId,callback)
    HttpManagerEx:BuySectSupportGoods(self._role:getFamilyId(), rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local goodsList = data.gainList

            local costList = data.costList

            local currencies = data.currencies

            if MapIsEmpty(goodsList) == false then
                for __, goods in pairs(goodsList) do
                    PopText("获得"..self:getAttrName(goods.id).."X"..goods.number)
                end
            end

            if MapIsEmpty(costList) == false then
                for __, goods in pairs(costList) do
                    PopText("消耗"..self:getAttrName(goods.id).."X"..goods.number)
                end
            end

            if MapIsEmpty(currencies) == false then
                for k, v in pairs(currencies) do
                    if v.id == "donate" then
                        self._role:getTeacherBuildSystem():setDonate(v.number)
                    end

                    if v.id == "renown" then
                        self._role:getTeacherBuildSystem():setRenown(v.number)
                    end

                    if v.id == "sgbpoint" then
                        self._role:getTeacherBuildSystem():setSgbpoint(v.number)
                    end

                    if v.id == "gbpoint" then
                        self._role:getTeacherBuildSystem():setGbpoint(v.number)
                    end

                    if v.id == "reputation" then
                        self._role:getTeacherBuildSystem():setReputation(v.number)
                    end
                end
            end

            if data.msg then
                PopText(data.msg)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function TeacherBuildResExchangeStore:__dealWithInfo(info)
    self._list = {}

    if MapIsEmpty(info) == false then
        for k,v in pairs(info) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = v.id
                _info.state = v.state
                _info.text1 = v.titleText
                _info.text2 = v.contentText
                _info.text3 = v.unlockText
              
                table.insert(self._list,_info)
            end
        end
    end

    table.sort(self._list, function(a, b)
        return a.id < b.id
    end)
end

return class("TeacherBuildResExchangeStore", {}, TeacherBuildResExchangeStore)
000000
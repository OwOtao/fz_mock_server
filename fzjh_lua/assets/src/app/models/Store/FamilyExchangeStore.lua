local class = require("third.class.NewClass")

local FamilyExchangeStore = {}

function FamilyExchangeStore:create()
    return FamilyExchangeStore:new()
end

function FamilyExchangeStore:ctor()
    self._name = ""

    self._desc = ""

    self._currencys = {}

    self._rewardList = {}
end

function FamilyExchangeStore:setRole(role)
    self._role = role
end

function FamilyExchangeStore:init(callback)
    local menpai = self._role:getFamilyId()
    if not menpai then
        assert(false, "需要加入门派才能进入")
        return
    end

    HttpManagerEx:getSectExchangeStore(menpai,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._desc = "本商店每周一0点会刷新奖励和库存，本门弟子可以通过消耗佳绩兑换门派奖励。"

            self:__dealWithCurrency(data.currencies)

            self:__dealWithInfo(data.list)
            
            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function FamilyExchangeStore:getActionDesc()
    return self._desc
end

function FamilyExchangeStore:getRewardList()
    return self._rewardList
end

function FamilyExchangeStore:getCurrencys()
    return self._currencys
end

function FamilyExchangeStore:getAttrName(attr)
    return self._role:getCHAttrName(attr)
end

function FamilyExchangeStore:buyGoods(rewardId,callback)
    HttpManagerEx:buySectExchangeGoods(self._role:getFamilyId(), rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local goods = data.goods

            if MapIsEmpty(goods) == false then
                PopText("获得"..self:getAttrName(goods.id).."X"..goods.number)
            end

            if data.donate then
                self._role:getTeacherBuildSystem():setDonate(data.donate)
            end

            if data.renown then
                self._role:getTeacherBuildSystem():setRenown(data.renown)
            end

            if data.gbpoint then
                self._role:getTeacherBuildSystem():setGbpoint(data.gbpoint)
            end

            if data.sgbpoint then
                self._role:getTeacherBuildSystem():setSgbpoint(data.sgbpoint)
            end

            if data.reputation then
                self._role:getTeacherBuildSystem():setReputation(data.reputation)
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

function FamilyExchangeStore:__dealWithCurrency(list)
    local currencys = {}
    for k, v in pairs(list) do
        if not currencys[v.id] then
            v.name = self:getAttrName(v.id)
            currencys[v.id] = v
        end
    end

    self._currencys = currencys
end

function FamilyExchangeStore:__dealWithInfo(rewardInfo)
    self._rewardList = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = v.id
                _info.state = v.state
                _info.stock = v.stock
                _info.price = v.price
                _info.text1 = self:getAttrName(v.goods.id) .. v.goods.number .."点"
                _info.text2 = "库存："..v.stock
                _info.btnName = v.cost.number..self:getAttrName(v.cost.id)
                _info.loadTexture = "Image/UI/TaskUI/anniu.png"
                _info.index = 1
                _info.enable = true

                if v.state == 0 then
                    _info.btnName = "未解锁"
                    _info.loadTexture = "Image/UI/TaskUI/anniuhui.png"
                    _info.index = 3
                    _info.text1 = _info.text1.."\n"..v.unlockConditionText
                    _info.enable = false
                end

                if v.stock == 0 then
                    _info.state = 2 
                    _info.btnName = "售罄"
                    _info.loadTexture = "Image/UI/TaskUI/anniuhui.png"
                    _info.index = 2
                    _info.enable = false
                end

                table.insert(self._rewardList,_info)
            end
        end
    end

    table.sort(self._rewardList, function(a, b)
        if a.index == b.index then
            return a.id < b.id
        else
            return  a.index < b.index
        end
        
    end)
end

return class("FamilyExchangeStore", {}, FamilyExchangeStore)
00000
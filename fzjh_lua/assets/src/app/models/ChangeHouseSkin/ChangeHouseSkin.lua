local class = require("third.class.NewClass")

local SkinThemeView = {}

function SkinThemeView:create(info)
    return SkinThemeView.new():__init(info)
end

function SkinThemeView:__init(info)
    self.id = info.id
    self.skinId = info.uiId
    self.skinName = info.uiName
    self.rarity = info.rarity
    self.price = info.price
    self.btnTexture = info.button
    self.bgTexture = info.buttonbg

    -- 是否已购买
    self.purchased = info.isBuy == 1

    -- 可购买开始时间
    self.startTime = info.buyTime
    -- 可购买结束时间
    self.endTime = info.endTime

    -- 是否可购买
    self.canBuy = info.canBuy

    self.skType = info.type

    return self
end

function SkinThemeView:getSkinId()
    return self.skinId
end
function SkinThemeView:getSkinName()
    return self.skinName
end
function SkinThemeView:getRarity()
    return self.rarity
end
function SkinThemeView:getPrice()
    return self.price
end
function SkinThemeView:getBtnTexture()
    return self.btnTexture
end
function SkinThemeView:getBgTexture()
    return self.bgTexture
end
function SkinThemeView:getPurchased()
    return self.purchased
end
function SkinThemeView:getStartTime()
    return self.startTime
end
function SkinThemeView:getEndTime()
    return self.endTime
end
function SkinThemeView:getCanBuy()
    return self.canBuy
end
function SkinThemeView:getIsLimit()
    if self.purchased then
        return false
    end

    -- 2 为限时 1 为普通 3为默认
    if self.skType == 2 then
        return true
    end
end
function SkinThemeView:getCurrencyText()
    return self.price .. Role:getCHAttrName("canghuangling")
end
function SkinThemeView:buy()
    self.purchased = true
end
function SkinThemeView:isUsing()
    local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")

    local currSkinId = HouseSkin:getSkinId()

    if self.skinId == currSkinId then
        return true
    end

    return false
end
function SkinThemeView:getOperationName()
    if self.purchased then
        return "使用"
    end

    return "购买"
end

SkinThemeView = class("SkinThemeView", {}, SkinThemeView)

local ChangeHouseSkin = {}

function ChangeHouseSkin:create()
    return ChangeHouseSkin:new()
end

function ChangeHouseSkin:ctor()
    self.__currencyName = Role:getCHAttrName("canghuangling")

    -- 已购买列表
    self.__purchasedList = {}
    self.__storeList = {}
end

function ChangeHouseSkin:setRole(role)
    self.__role = role
end

function ChangeHouseSkin:setAfterRewardFunc(func)
    self.__afterRewardFunc = func
end

function ChangeHouseSkin:getRole()
    return self.__role
end

--已购买
function ChangeHouseSkin:getPurchasedList()
    return self.__purchasedList
end

--未购买
function ChangeHouseSkin:getStoreList()
    return self.__storeList
end

function ChangeHouseSkin:getCurrencyName()
    return self.__currencyName
end

function ChangeHouseSkin:getCurrencyNum()
    return self.__canghuangling
end

function ChangeHouseSkin:fetchSkinThemeData(success)
    self.__purchasedList = {}
    self.__storeList = {}
    HttpManagerEx:getUiThemeList(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__canghuangling = data.canghuangling
                self.__currUsedUiId = data.usedUiId

                self:__initList(data.list)

                if success then
                    success()
                end
                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ChangeHouseSkin:__removeSkinFromStoreList(skinId)
    if MapIsEmpty(self.__storeList) then
        return
    end

    for i, v in ipairs(self.__storeList) do
        if v:getSkinId() == skinId then
            return table.remove(self.__storeList, i)
        end
    end
end

function ChangeHouseSkin:__addSkinToStroeList(skinThemeView)
    table.insert(self.__storeList, skinThemeView)
end

function ChangeHouseSkin:__removeSkinFromPurchasedList(skinId)
    if MapIsEmpty(self.__purchasedList) then
        return
    end

    for i, v in ipairs(self.__purchasedList) do
        if v:getSkinId() == skinId then
            return table.remove(self.__purchasedList, i)
        end
    end
end

function ChangeHouseSkin:__addSkinToPurchasedList(skinThemeView)
    table.insert(self.__purchasedList, skinThemeView)
end

function ChangeHouseSkin:useUI(skinId, success)
    HttpManagerEx:useUiTheme(
        skinId,
        function(status, errcode, errmsg, data)
            if status == 200 then
                -- 0: 使用成功 2: 皮肤已在使用中
                if errcode == 0 or errcode == 2 then
                    local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
                    HouseSkin:setSkinId(skinId)

                    success()
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function ChangeHouseSkin:buyUI(skinId, success, failFunc)
    HttpManagerEx:buyUiTheme(
        skinId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__canghuangling = math.max(self.__canghuangling - data.remove, 0)

                local skinThemeView = self:__removeSkinFromStoreList(skinId)

                skinThemeView:buy()

                self:__addSkinToPurchasedList(skinThemeView)

                self:__sort(self.__purchasedList)

                success()
            else
                PopText(errmsg)
                if failFunc then
                    failFunc()
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function ChangeHouseSkin:__initList(data)
    if MapIsEmpty(data) then
        return
    end
    for k, v in pairs(data) do
        --@RefType [src.app.models.ChangeHouseSkin.ChangeHouseSkin#SkinThemeView]
        local skView = SkinThemeView:create(v)
        if skView:getPurchased() then
            table.insert(self.__purchasedList, skView)
        else
            table.insert(self.__storeList, skView)
        end
    end

    self:__sort(self.__purchasedList)
    self:__sort(self.__storeList)
end

function ChangeHouseSkin:__sort(tb)
    table.sort(
        tb,
        function(a, b)
            if a.rarity > b.rarity then
                return true
            elseif a.rarity == b.rarity then
                return a.id < b.id
            else
                return false
            end
        end
    )
end

return class("ChangeHouseSkin", {}, ChangeHouseSkin)
000000000
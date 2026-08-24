local DreamStoreLayer = class("DreamStoreLayer", cc.Layer)
local StoreItemRes = require("script.dreamworld.dreamzhaimengge")["Sheet1"]

local StoreItem_Type = {
    ITEM = 1, --物品
    SKILL = 2, --武学
}

local StoreItem_State = {
    CANBUY = 0, --可购买
    BOUGHT = 1, --已购买
    UNOPEN = 2  --未开启
}

function DreamStoreLayer:create()
    local p = DreamStoreLayer:new()
    p:init()
    return p
end

function DreamStoreLayer:init()
    self._UI = require("app.views.ui.DreamStoreUI.DreamStoreUI"):create()
    self._UI:addTo(self)
end

function DreamStoreLayer:showLayer()
    self:getDreamGoods(function()
        self._handel = self:schedule(
            function(elapsed)
                self:updata()
            end, 1
        )

        self:setTextTital()
        self:setTextDsc()
        self:setTextTime()
        self:setTextPoint()
        self:setButtonBack()
        self:setButtonClose()
        self:setListView()
        self._UI:showUI()
    end)
end

function DreamStoreLayer:getDreamGoods(callback)
    HttpManagerEx:getDreamGoods(
        function(status, errcode, errmsg, data)
            if 200 == status then
                if 0 == errcode then
                    self._period = data.period
                    self._time = data.expired_time
                    self._point = data.dreamYiYu
                    self._storeList = data.list
                    self._role = User:getRole()

                    if callback then
                        callback()
                    end
                else
                    self._UI:popText(errmsg)
                end
            else
                self._UI:popText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function DreamStoreLayer:setTextTital()
    self._UI:setTextTital("摘梦阁")
end

function DreamStoreLayer:setTextDsc()
    self._UI:setTextDsc("每次完成梦境即可获得梦内呓语，梦内呓语可以兑换本期指定奖励物品。")
end

function DreamStoreLayer:setTextTime()
    local day, hour, minute,second = Helper:sec3timeDsc(self._time)
    local timetext = day.."天"..hour.."小时"..minute.."分"..second.."秒"
    self._UI:setTextTime("活动剩余时间："..timetext)
end

function DreamStoreLayer:setTextPoint()
    self._UI:setTextPoint("梦内呓语："..self._point)
end

function DreamStoreLayer:setListView()
    if MapIsEmpty(self._storeList) then
        return
    end
    local retArray = {}
    for i,v in ipairs(self._storeList) do
        local tab = {
            name = "",
            num = nil,
            condition = "",
            buttonName = "",
            itemImage = "",
            buttonImage = ""
        }

        local onlyId = v.onlyId
        local itemData = assert(StoreItemRes[tostring(onlyId)],"商品不存在"..tostring(onlyId))
        local textNum,itemImage,buttonImage,buttonName,buttonFunc = self:createOneItemConfig(i,itemData,v)
        tab["name"] = itemData.name
        tab["num"] = textNum
        tab["buttonName"] = buttonName
        tab["itemImage"] = itemImage
        tab["buttonImage"] = buttonImage
        tab["condition"] = "兑换所需梦内呓语："..itemData.price
        tab["func"] = function()
            Audio:playEffect("xiaoAnNiu")
            buttonFunc()
        end
        table.insert(retArray, tab)
    end

    self._UI:setListView(retArray)
end

function DreamStoreLayer:setButtonBack()
    self._UI:setButtonBack(function()
        Audio:playEffect("fanHuiQuXiao")
        self:hideLayer()
    end)
end

function DreamStoreLayer:setButtonClose()
    self._UI:setButtonClose(function()
        Audio:playEffect("xiaoAnNiu")
        self:hideLayer()
    end)
end

function DreamStoreLayer:createOneItemConfig(index,itemData,values)
    local id = itemData.id
    local itemType = itemData.type
    local number = values.number --单次购买，物品数量
    local count = values.count --剩余商品数量
    local state = values.state
    local textNum,itemImage,buttonImage,buttonName,buttonFunc = "","","","",nil
    if itemType == StoreItem_Type.ITEM then
        if state == StoreItem_State.CANBUY then
            itemImage = "Image/UI/StoreUI/item1.png"
            buttonImage = "Image/UI/MapUI/anniu05.png"
            buttonName = "兑换"
            textNum = "剩余兑换数量："..count
            buttonFunc = function()
                local itemAttr = Item:getOneItemByKey(id)
                self:buyItem(itemData,number,function(data)
                    self._role:addItemCount(id,number)
                    values.count = values.count - 1
                    if values.count <= 0 then
                        values.state = StoreItem_State.BOUGHT
                    end
                    local newTextNum,newItemImage,newButtonImage,newButtonName,newButtonFunc = self:createOneItemConfig(index,itemData,values)
                    self._UI:refreshOneItem(index,{num = newTextNum,itemImage = newItemImage,buttonImage = newButtonImage,buttonName = newButtonName,func = newButtonFunc})
                    self._point = data.dreamYiYu
                    self:setTextPoint()
                    self._UI:popText("消耗"..data.cost.."梦内呓语成功兑换"..itemData.name)
                end,itemAttr.dsc,"已拥有:" .. self._role:getItemTotalCount(itemAttr.id) .. itemAttr.unit)
            end
        elseif state == StoreItem_State.BOUGHT then
            itemImage = "Image/UI/StoreUI/item2.png"
            buttonImage = "Image/UI/MapUI/anniu04.png"
            buttonName = "已兑换"
            buttonFunc = function()
                self._UI:popText("该物品已没有剩余兑换数量，请更换.")
            end
        elseif state == StoreItem_State.UNOPEN then
            itemImage = "Image/UI/StoreUI/item2.png"
            buttonImage = "Image/UI/MapUI/anniu04.png"
            buttonName = "未开启"
            buttonFunc = function()
                self._UI:popText("你还未解锁该物品。")
            end
        end
    elseif itemType == StoreItem_Type.SKILL then
        if state == StoreItem_State.CANBUY then
            if self._role:getSkillExp(id) > 0 then
                itemImage = "Image/UI/StoreUI/skill2.png"
                buttonImage = "Image/UI/MapUI/anniu04.png"
                buttonName = "已学习"
                buttonFunc = function()
                    self._UI:popText("你已学习过该武学。")
                end
            elseif self._role:getFamilyId() == itemData.menpai then
                itemImage = "Image/UI/StoreUI/skill2.png"
                buttonImage = "Image/UI/MapUI/anniu04.png"
                buttonName = "未开启"
                buttonFunc = function()
                    self._UI:popText("你无需兑换你的师门武学。")
                end
            else
                itemImage = "Image/UI/StoreUI/skill1.png"
                buttonImage = "Image/UI/MapUI/anniu05.png"
                buttonName = "兑换"
                textNum = "剩余兑换数量："..count
                buttonFunc = function()
                    self:buyItem(itemData,1,function(data)
                        self._role:addSkillExp(id, 1)
                        values.count = values.count - 1
                        if values.count <= 0 then
                            values.state = StoreItem_State.BOUGHT
                        end
                        local newTextNum,newItemImage,newButtonImage,newButtonName,newButtonFunc = self:createOneItemConfig(index,itemData,values)
                        self._UI:refreshOneItem(index,{num = newTextNum,itemImage = newItemImage,buttonImage = newButtonImage,buttonName = newButtonName,func = newButtonFunc})
                        self._point = data.dreamYiYu
                        self:setTextPoint()
                        self._UI:popText("消耗"..data.cost.."梦内呓语成功兑换"..itemData.name)
                    end,Skill:getSkill(id).dsc)
                end
            end
        elseif state == StoreItem_State.BOUGHT then
            itemImage = "Image/UI/StoreUI/skill2.png"
            buttonImage = "Image/UI/MapUI/anniu04.png"
            buttonName = "已兑换"
            buttonFunc = function()
                self._UI:popText("该物品已没有剩余兑换数量，请更换。")
            end
        elseif state == StoreItem_State.UNOPEN then
            itemImage = "Image/UI/StoreUI/skill2.png"
            buttonImage = "Image/UI/MapUI/anniu04.png"
            buttonName = "未开启"
            buttonFunc = function()
                self._UI:popText("你还未解锁该门派的武学。")
            end
        end
    end
    return textNum,itemImage,buttonImage,buttonName,buttonFunc
end

function DreamStoreLayer:buyItem(itemData,number,callback,dsc,Text_havenum)
    local textList = {
        Text_tital = itemData.name,
        Text_type = nil,
        Text_dsc = dsc,
        Text_price = "售价:"..itemData.price.."梦内呓语",
        Text_affirm = "确定购买"..itemData.name.."吗？",
        Text_havenum = Text_havenum,
    }
    
    local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
    PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
        layer:showLayer(textList,function()
        end)
        layer:setButton_confirm("确定",function()
            if itemData.type == StoreItem_Type.SKILL or self._role:checkCanBuyThings(itemData.id,number) == true then
                HttpManagerEx:buyDreamGood(itemData.onlyId,self._period,function(status, errcode, errmsg, data)
                    if 200 == status then
                        if errcode == 0 then
                            if callback then
                                callback(data)
                            end
                        elseif errcode == 2 then
                            self:getDreamGoods(function()
                                self._UI:popText(errmsg)
                                self:setTextTime()
                                self:setTextPoint()
                                self:setListView()
                            end)
                        else
                            self._UI:popText(errmsg)
                        end
                    else
                        self._UI:popText(errmsg)
                    end
                end,IS_SHOW_WAITING)
            end
        end)
        layer:setButton_close("取消", function()
        end)
    end)
end

function DreamStoreLayer:updata()
    if self._time > 0 then
        self._time = math.max(self._time - 1,0)
        self:setTextTime()
    else
        self:unschedule(self._handel)
    end
end

function DreamStoreLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DreamStoreLayer",
        function(layer)
            self:unschedule(self._handel)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(DreamStoreLayer)
return DreamStoreLayer
00000
local BiddingLayer = class("BiddingLayer", cc.Layer)

--@RefType [app.models.HomelandModel.HomelandBuyModel.BuyLandModel#BuyLandModel]
local BuyLandModel = require("app.models.HomelandModel.HomelandBuyModel.BuyLandModel")

function BiddingLayer:create()
    local p = BiddingLayer:new()
    p:init()
    return p
end

function BiddingLayer:init()
    self._UI = require("Layer/HomelandUI/BiddingUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Panel_Back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

local _land = {}

local _npcId = ""

local _isLand

function BiddingLayer:showLayer(land, npcId, isLand)
    _land = land
    _npcId = npcId
    _isLand = Helper:getDef(isLand, false)
    self:iniData()
    self:show()
end

function BiddingLayer:iniData()
    self:setLandName(_land.name)
    self:setLandCost("地税：" .. _land.cost)
    self:setPrice(_land.state, _land.high_price)
    self:setBiddingRoleName(_land.state, _land.high_name)
    self:initBiddingBtn()
end

--@desc 设置价格
function BiddingLayer:setPrice(state, value)
    if state == 1 then
        self.Panel_Detial.Text_Price:setString("初始价" .. tostring(_land.high_price))
    elseif state == 2 then
        self.Panel_Detial.Text_Price:setString("当前竞价" .. tostring(_land.high_price))
    end
end

function BiddingLayer:setLandName(name)
    self.Panel_Detial.Text_desc1:setString(name)
end

function BiddingLayer:setLandCost(cost)
    self.Panel_Detial.Text_desc2:setString(cost)
end

function BiddingLayer:setBiddingRoleName(state, roleName)
    if state == 1 then
        self.Panel_Detial.Text_desc3:setString("当前无人竞拍")
    else
        self.Panel_Detial.Text_desc3:setString("当前最高价：" .. roleName)
    end
end

function BiddingLayer:initBiddingBtn()
    local addPrice = {
        100,
        500,
        1000
    }

    for i = 1, 3 do
        self.Panel_Detial["Button_" .. tostring(i)]:releaseFunc(
            function()
                local function biddingLand()
                    local aPrice = addPrice[i]

                    local currPrice = _land.high_price + aPrice
                    -- high_price
                    HttpManagerEx:biddingLand(
                        _land.dpId,
                        _npcId,
                        currPrice,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    BuyLandModel:setCurrPrice(_land.index, currPrice)
                                    BuyLandModel:setCurrState(_land.index, 2)

                                    if data.surplusTime then
                                        BuyLandModel:setSurplusTime(_land.index, data.surplusTime)
                                    end

                                    BuyLandModel:setCurrHighName(_land.index, User:getRole():getName())

                                    local currPoint = BuyLandModel:getCurrPoiont()

                                    BuyLandModel:setCurrPoint(currPoint - data.remove_point)

                                    PopText("竞价成功")
                                    local text = "RED出价成功！请务必留意后续进展，如果交易达成，请尽快领取地契、并搬入房屋，否则可能会有地财两失之虞！NOR"
                                    RichPrint("main",text)
                                    self:hideLayer()
                                elseif errcode == 2 then
                                    BuyLandModel:setCurrPrice(_land.index, data.high_price)
                                    BuyLandModel:setCurrState(_land.index, 2)
                                    BuyLandModel:setCurrHighName(_land.index, data.high_name)

                                    self:setPrice(2, data.high_price)
                                    self:setBiddingRoleName(2, data.high_name)

                                    PopText(errmsg)
                                elseif errcode == 1 then
                                    PopText(errmsg)
                                    self:hideLayer()
                                else
                                    print("errcode = ", errcode)
                                    PopText(errmsg)
                                end
                                return true
                            else
                                PopText(errmsg)
                                return true
                            end
                        end,
                        IS_SHOW_WAITING,
                        HTTP_MANAGER_RETRY_TYPE_RETRY
                    )
                end

                if _isLand then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    --@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
                    local dialog = DialogALayer:getInstance()
                    dialog:show("您已经拥有一块土地，竞价新土地搬入后，之前的土地会被回收，是否继续竞价？")

                    dialog:setButton1(
                        "确定",
                        function()
                            biddingLand()
                        end
                    )

                    dialog:setButton2("取消", EMPTY_FUNC)
                    dialog:setWeChatVisible(false)
                else
                    biddingLand()
                end
            end
        )
    end
end

--@desc: 销毁隐藏界面
--@author:Liang SongQiang
--@time:2018-05-22 19:31:29
function BiddingLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BiddingLayer",
        function(layer)
            layer:hide()
        end
    )
end

Helper:classDefNodeGetInstance(BiddingLayer)
return BiddingLayer
00000
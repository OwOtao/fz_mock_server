local YaShiBenefitPresenter = class("YaShiBenefitPresenter", cc.Layer)


function YaShiBenefitPresenter:create()
    local p = YaShiBenefitPresenter:new()
    p:init()
    return p
end

function YaShiBenefitPresenter:init()
    self.__ui = require("app.views.ui.YaShiBenefit.YaShiBenefitUI"):create()

    self.__ui:addTo(self)

    self.__ui:setPanelBack(function()
        self:hideLayer()
    end)

    self.__interactor = require("app.models.YaShiBenefit.YaShiBenefit"):create()

    self.__interactor:setRole(User:getRole())
end

function YaShiBenefitPresenter:showLayer(currencyNum, callback)
    self.__interactor:setCurrencyNum(currencyNum)
    self.__interactor:initActiveZhaoInfoList()
    self.__skillTitleList = self.__interactor:getSkillList()
    self:setButtonFunc()
    self:setIndex(1)
    self:showTabListView()
    self:refreshSkillListView()
    self:showTextAttr1()
    self:showTextAttr2()
    self.__ui:show()
    self.__callback = callback
end

function YaShiBenefitPresenter:setButtonFunc()
    self.__ui:setButtonFunc(function()
        local info = self.__interactor:getNingShenDanInfo()
        if self.__interactor:getCurrencyNum() < info.price then
            PopText("可用"..info.priceName.."不足")
            return
        end

        PopupLayerController:showLayer("ChongZhiJiFenGoodsPresenter",function(layer)
            layer:setTitle("请确定兑换")
            layer:setTextDesc_1("    "..info.dsc)
            layer:setTextDesc_2("兑换可获得")
            layer:setTextDesc_3(info.name,info.number)
            layer:setTextDesc_4Visible(false)
            layer:setText_1Str("将花费：")
            layer:setItemName(info.name)
            layer:setUnitPrice(info.price)
            layer:setBuyNumber(info.number)
            layer:setMaxBuyNumber(info.max)
            layer:setSelectText(tostring(info.number).."/"..tostring(info.max))
            layer:setPriceName(info.priceName)
            layer:setText_2Str(tostring(info.price)..info.priceName)
    
            layer:showLayer()
            layer:setButton_1Func(function(buyNumber)
                if not buyNumber then
                    buyNumber = info.number
                end
    
                if buyNumber > info.max then
                    PopText("当前购买次数已超上限！")
                    return
                end

                self.__interactor:exchange(info.goodsId, buyNumber, 2, function(isTrue, msg)
                    if isTrue then
                        self:hideLayer()
                    else
                        self:showTextAttr1()

                        self:showTextAttr2()
                    end

                    if msg then
                        PopText(msg)
                    else
                        PopText("获得"..info.name.."X"..buyNumber)
                    end
                end)
            end)
    
            layer:setButton_2Func(function()
                layer:hideLayer()
            end)
        end)
    end)
end

function YaShiBenefitPresenter:hideLayer()
    PopupLayerController:hideLayer("YaShiBenefitPresenter",function()
        self.__ui:hide()
        local yaShiTime = self.__interactor:getYaShiTime()
        local currencyNum = self.__interactor:getCurrencyNum()
        if yaShiTime then
            if self.__callback then
                self.__callback(yaShiTime, currencyNum)
            end
        end
    end)
end

function YaShiBenefitPresenter:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)
    
    self:__setSkillListView()
end

function YaShiBenefitPresenter:setIndex(index)
    self.__index = index
end

function YaShiBenefitPresenter:setSkillId(skillId)
    self.__skillId = skillId
end

function YaShiBenefitPresenter:showTextAttr1()
    self.__ui:setTextAttr1("")
end

function YaShiBenefitPresenter:showTextAttr2()
    self.__ui:setTextAttr2("当前可用"..self.__interactor:getCurrencyName().. "："..self.__interactor:getCurrencyNum())
end

function YaShiBenefitPresenter:showTabListView()
    local retArray = {}
    for i,skillTab in ipairs(self.__skillTitleList) do
        local tab = {
            title = "",
            func = EMPTY_FUNC
        }
        tab["title"] = skillTab.name
        tab["func"] = function()
            self:setIndex(i)

            self:setSkillId(nil)

            self:refreshSkillListView()
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTabListView(retArray)
end

function YaShiBenefitPresenter:__setSkillListView()
    local retArray = {}
    local skillList = self.__skillTitleList[self.__index].list

    if MapIsEmpty(skillList) == false then
        self.__ui:setTipVisible(false)

        for index,v in ipairs(skillList) do
            local tab = {
                name = "",
                image = Resource:getImgPath("title_flod"),
                func = EMPTY_FUNC
            }

            local zhaoInfo = self.__interactor:getActiveZhaoInfoBySkillId(v.id)

            tab["name"] = "NZS"..v.name

            for i, zhao in ipairs(zhaoInfo) do
                if self.__interactor:getCurrencyNum() >= zhao.price then
                    tab["name"] = v.name
                    break
                end
            end

            if v.id == self.__skillId then
                tab["image"] = Resource:getImgPath("title_unflod")
            end

            tab["func"] = function()
                self:setSkillId(v.id)

                self:__setSkillListView()

                if not MapIsEmpty(zhaoInfo) then
                    local insetPos = index
                    
                    for i,zhao in ipairs(zhaoInfo) do
                        insetPos = insetPos + 1

                        local color = ""

                        if self.__interactor:getCurrencyNum() < zhao.price then
                            color = "NZS"
                        end

                        local currIndex = insetPos-1

                        local text1 = zhao.name.."("..tostring(zhao.lv).."重)"
                        local text2 = tostring(zhao.exp).."/"..tostring(zhao.maxExp).."("..tostring(zhao.price).."额度)"
       
                        self.__ui:insertActive(currIndex, 
                            {   
                                text1 = color..text1, 
                                text2 = color..text2,
                                func = function()
                                    if self.__interactor:getCurrencyNum() < zhao.price then
                                        PopText("当前可用"..self.__interactor:getCurrencyName().. "不足以兑换该主动技能的残页！")
                                        return
                                    end

                                    local GoodsHelper = require("app.models.Store.GoodsHelper")
                                    local goods = GoodsHelper:getGoodsResClass(zhao.goodsId)
                                    local itemAttr = Item:getOneItemByKey(goods:getItemId())
                                    
                                    local text = tostring(itemAttr.name).."\n"..tostring(itemAttr.dsc).."\n\n当前主动技能信息：\n「"..zhao.name.."」的重数为："..tostring(zhao.lv).."重，「"..zhao.name.."」的熟练度为："..tostring(zhao.exp).."/"..tostring(zhao.maxExp)

                                    self:__showConfirmLayer(text, "是否确定兑换", function()
                                        self.__interactor:exchange(zhao.id, 1, 1, function(isTrue, msg)
                                            if isTrue then
                                                self:hideLayer()
                                            else
                                                self:showTextAttr1()

                                                self:showTextAttr2()

                                                if self.__interactor:getCurrencyNum() < zhao.price then
                                                    self:__setSkillListView()
                                                end
                                            end

                                            PopText("已成功兑换"..itemAttr.name.."，并发放至书箱")
                                        end)
                                    end)
                                end
                            }
                        )
                    end
                    self.__ui:jumpToItem(index)
                end
            end
            table.insert(retArray, tab)
        end
    else
        self.__ui:setTipVisible(true)
    end

    self.__ui:setSkillListView(retArray)
end

function YaShiBenefitPresenter:__showConfirmLayer(text,desc,func)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

    local dialog = DialogALayer:getInstance()
    
    dialog:hide()
    dialog:show(text, desc)
    dialog:setButton1(
        "确定",
        function()
            func()
        end
    )
    dialog:setButton2("取消",EMPTY_FUNC)
    dialog:setWeChatVisible(false)
end


Helper:classDefNodeGetInstance(YaShiBenefitPresenter)
return YaShiBenefitPresenter
0000000000000000
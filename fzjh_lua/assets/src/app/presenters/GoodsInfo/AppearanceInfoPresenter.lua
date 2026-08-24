local NewClass = require("third.class.NewClass")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local AppearanceInfoPresenter = {}

function AppearanceInfoPresenter:create(goods)
    local o = AppearanceInfoPresenter.new()
    o:init(goods)
    return o
end

function AppearanceInfoPresenter:init(goods)
    self.__ui = require("app.views.ui.GoodsInfoUI.AppearanceInfoUI"):create()
    self.__goods = goods
    self.__item = Item:getOneItemByKey(self.__goods:getItemId())
end

function AppearanceInfoPresenter:getUI()
    return self.__ui
end

function AppearanceInfoPresenter:showUI()
    self.__index = 1
    self.__ui:setTitle("挂饰查看")
    self.__ui:setItemName(self.__item.name)
    self.__ui:setItemDesc(self.__item.dsc)

    local dscAdd = self.__item.dscAdd

    local i1, j1 = string.find(dscAdd,"入场动作")

    local i2, j2 = string.find(dscAdd,"胜利动作")

    local str1 = string.sub(dscAdd, i1, i2-2)

    local str2 = string.sub(dscAdd, i2, -1)

    self.__ui:setSubTitle(str1)

    local startAnim = AnimResManager:getOtherAnimName(self.__item.startAnim)

    local winAnim = AnimResManager:getOtherAnimName(self.__item.winAnim)

    self.__anim = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/enterVictory/enterVictory.skel", "Anim/enterVictory/enterVictory.atlas", 1), "动画初始化出错")
    self.__anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
    self.__ui:panelAnimAddNode(self.__anim)
    self.__anim:setPosition(cc.p(260, 360))
    self.__anim:setVisible(true)

    self.__anim:setAnimation(0,startAnim,true)

    self.__ui:setButtonLeft(function()
        if self.__index > 1 then
            self.__index = self.__index - 1

            self.__ui:setSubTitle(str1)

            self.__anim:setAnimation(0,startAnim,true)
        end
    end)

    self.__ui:setButtonRight(function()
        if self.__index < 2 then
            self.__index = self.__index + 1

            self.__ui:setSubTitle(str2)

            self.__anim:setAnimation(0,winAnim,true)
        end
    end)

    self.__ui:showUI()
end

function AppearanceInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function AppearanceInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

function AppearanceInfoPresenter:setAnimSlotColor()
    self.__anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
end

function AppearanceInfoPresenter:hide()
    self.__ui:hideUI()

    self.__ui:panelAnimRemoveAllChildren()
end

return NewClass("AppearanceInfoPresenter", {}, AppearanceInfoPresenter)000
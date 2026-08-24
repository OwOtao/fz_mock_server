-- local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")

local NewClass = require("third.class.NewClass")

local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local FondDrSkillAnimUI = {}

function FondDrSkillAnimUI:create(node)
    if node == nil then
        assert(false, "FondDrSkillAnimUI create args is error : node is empty")
    end

    local p = FondDrSkillAnimUI.new()
    p:onInit(node)
    return p
end

function FondDrSkillAnimUI:onInit(node)
    self.__node = node
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错"))

    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__animator:getSkeletonAnimation():setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__animator:getSkeletonAnimation():setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
    self.__node:addChild(self.__animator:getSkeletonAnimation())

    -- self.__animator:getSkeletonAnimation():retain()
end

function FondDrSkillAnimUI:onDestroy()
    self.__node:removeChild(self.__animator:getSkeletonAnimation())
end

function FondDrSkillAnimUI:setPosition(x, y, h)
    self.__node:setPosition(cc.p(x, y))
    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, h))
end

function FondDrSkillAnimUI:setSkeletonAnimationPosition(x, y)
    self.__animator:getSkeletonAnimation():setPosition(cc.p(x, y))
end

function FondDrSkillAnimUI:setVisible(bool)
    self.__node:setVisible(bool)
end

function FondDrSkillAnimUI:setAnimScaleX(value)
    self.__animator:getSkeletonAnimation():setScaleX(value)
end

function FondDrSkillAnimUI:getAnimScaleX()
    return self.__animator:getSkeletonAnimation():getScaleX()
end

function FondDrSkillAnimUI:playAnim(name, isLoop)
    if isLoop == nil then
        isLoop = false
    end
    self.__animator:play(name,isLoop)
end

function FondDrSkillAnimUI:setEventCallback(callback)
    if callback == nil then
        callback = function()
        end
    end
    self.__animator:setEventCallback(callback)
end

function FondDrSkillAnimUI:setWeaponSkin(weaponSkin)
    self.__animator:getSkeletonAnimation():setSkin(weaponSkin)
end

function FondDrSkillAnimUI:getBonePosition(boneName)
    return self.__animator:getSkeletonAnimation():getBonePosition(boneName)
end

function FondDrSkillAnimUI:onUpdate(ft)
    self.__animator:update(ft)
end

return NewClass("FondDrSkillAnimUI", {}, FondDrSkillAnimUI)
00000000000000
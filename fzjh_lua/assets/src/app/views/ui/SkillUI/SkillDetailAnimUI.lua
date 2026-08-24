--[[
    author:Seven
    time:2022-11-04 10:43:37
    desc:
]]
local NewClass = require("third.class.NewClass")

local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

local SkillDetailAnimUI = {}

function SkillDetailAnimUI:create(node)
    if node == nil then
        assert(false, "SkillDetailAnimUI create args is error : node is empty")
    end

    local p = SkillDetailAnimUI.new()
    p:bindUiNode(node)
    p:init()
    return p
end

function SkillDetailAnimUI:bindUiNode(node)
    self.__node = node

    local function _bindChildren(parent, children)
        if MapIsEmpty(children) == true then
            return
        end

        for i, child in ipairs(children) do
            parent[child:getName()] = child
            _bindChildren(child, child:getChildren())
        end
    end

    return _bindChildren(self, node:getChildren())
end

function SkillDetailAnimUI:init()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错"))

    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__animator:getSkeletonAnimation():setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__animator:getSkeletonAnimation():setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
    self.__node:addChild(self.__animator:getSkeletonAnimation())
end

function SkillDetailAnimUI:destroy()
    self.__node:removeChild(self.__animator:getSkeletonAnimation())
end

function SkillDetailAnimUI:setPosition(x, y, h)
    self.__node:setPosition(cc.p(x, y))
    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, h))
end

function SkillDetailAnimUI:getPosition()
    return cc.p(self.__node:getPosition()), self.__animator:getSkeletonAnimation():getPositionY()
end

function SkillDetailAnimUI:setSkeletonAnimationPosition(x, y)
    self.__animator:getSkeletonAnimation():setPosition(cc.p(x, y))
end

function SkillDetailAnimUI:setVisible(bool)
    self:getNode():setVisible(bool)
end

function SkillDetailAnimUI:setAnimScaleX(value)
    self.__animator:getSkeletonAnimation():setScaleX(value)
end

function SkillDetailAnimUI:getAnimScaleX()
    return self.__animator:getSkeletonAnimation():getScaleX()
end

function SkillDetailAnimUI:playAnim(name, isLoop, completeCallback)
    if isLoop == nil then
        isLoop = false
    end
    self.__animator:setCompleteCallback(completeCallback)

    self.__animator:play(name, isLoop)
end

function SkillDetailAnimUI:setEventCallback(callback)
    if callback == nil then
        callback = function()
        end
    end
    self.__animator:setEventCallback(callback)
end

function SkillDetailAnimUI:setWeaponSkin(weaponSkin)
    self.__animator:getSkeletonAnimation():setSkin(weaponSkin)
end

function SkillDetailAnimUI:getBonePosition(boneName)
    return self.__animator:getSkeletonAnimation():getBonePosition(boneName)
end

function SkillDetailAnimUI:update(ft)
    self.__animator:update(ft)
end

function SkillDetailAnimUI:getName()
    return self.__node:getName()
end

function SkillDetailAnimUI:getNode()
    return self.__node
end

return NewClass("SkillDetailAnimUI", {}, SkillDetailAnimUI)
00000
--[[
    跳跃状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local FightFormula = require("app.FightSystem.FightFormula")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local JumpState = {
    __stateType = CHARACTER_UI_STATE.JUMPING
}

function JumpState:onInit()
    self.__isInTargetPos = false
end

function JumpState:onEnter(params)
    self.__isInTargetPos = false

    self.__duration = 0

    self.__dir = params.dir

    self.__target_pos = {
        x = params.target_pos.x,
        y = params.target_pos.y,
        h = params.target_pos.h
    }

    -- self.__start_pos = {
    --     x = params.start_pos.x,
    --     y = params.start_pos.y,
    --     h = params.start_pos.h
    -- }

    self.__start_pos = self.__ctrl:getPosition()

    self.__highest = params.highest

    self.__total_time = params.total_time

    -- 移动距离太近，不需要跳跃
    if cc.pGetLength(cc.pSub(cc.p(self.__target_pos.x, self.__target_pos.y + self.__target_pos.h), cc.p(self.__start_pos.x, self.__start_pos.y + self.__start_pos.h))) >= 10 then
        self.__ctrl:playAnim(self.__animName, true)
    else
        self.__target_pos = self.__start_pos
    end

    local ok, blocker =
        self.__ctrl:tryGetCharacterUICtrls(
        function(ctrl)
            if self.__ctrl == ctrl then
                return
            end

            if ctrl:isDead() == false and math.abs(ctrl:getPosition().y - self.__target_pos.y) < 50 then
                if self.__ctrl:getAnimUI():getAnimScaleX() > 0 and ctrl:getAnimUI():getAnimScaleX() > 0 then
                    -- end
                    -- if self.__target_pos.x - ctrl:getPosition().x < 50 then
                    return true
                elseif self.__ctrl:getAnimUI():getAnimScaleX() < 0 and ctrl:getAnimUI():getAnimScaleX() < 0 then
                    -- if self.__target_pos.x - ctrl:getPosition().x > -50 then
                    return true
                -- end
                end
            end
        end
    )

    if ok then
        --@RefType [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
        self.__blocker = blocker
        self.__blocker:playAnim(self.__blocker:getJumpForwardAnim(), true)

        self.__blocker_start_position = self.__blocker:getPosition()
        self.__blocker_target_position = inherit({y = self.__start_pos.y}, self.__blocker_start_position)
    else
        self.__blocker = nil
    end
end

function JumpState:onLeave()
    self:onUpdate(self.__total_time)
end

function JumpState:onUpdate(ft)
    if self.__duration then
        if self.__isInTargetPos then
            return
        end
        local percent = math.min(self.__duration / self.__total_time, 1)

        do
            local next_pos
            if self.__dir == "forward" then
                next_pos = FightFormula:jumpFoward(self.__start_pos, self.__target_pos, percent)
            elseif self.__dir == "back" then
                next_pos = FightFormula:jumpBackward(self.__start_pos, self.__target_pos, percent)
            end

            local hight = FightFormula:jumpHeight(self.__highest, percent)

            self.__ctrl:setPosition(next_pos.x, next_pos.y, hight)

            if percent >= 1 then
                FightUtil:printLog(self.__ctrl:getVmAttr("name"), "动画跳跃结束")
                FightUtil:printLog("    当前位置:{ x:", next_pos.x, ", y:", next_pos.y, "}")
                self.__isInTargetPos = true
                self.__ctrl:enterIdleState()
            end
        end

        -- 阻挡者移动
        if self.__blocker then
            local blocker_percent = math.min(percent * 1.33333, 1)
            local next_pos
            if self.__dir == "forward" then
                next_pos = FightFormula:jumpFoward(self.__blocker_start_position, self.__blocker_target_position, blocker_percent)
            elseif self.__dir == "back" then
                next_pos = FightFormula:jumpBackward(self.__blocker_start_position, self.__blocker_target_position, blocker_percent)
            end

            local hight = FightFormula:jumpHeight(self.__highest, blocker_percent)

            self.__blocker:setPosition(next_pos.x, next_pos.y, hight)

            if blocker_percent >= 1 then
                self.__blocker:enterIdleState()
            end
        end

        if percent >= 1 then
            return
        end

        FightUtil:printLog(self.__ctrl:getVmAttr("name"), "动画跳跃中.,")
    end

    self.__duration = self.__duration + ft
end

return class("JumpState", {BaseCharacterUIState}, JumpState)
00000000
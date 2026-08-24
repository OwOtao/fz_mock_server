--[[
    author:Seven
    time:2023-10-31 10:18:47
    desc: 角色前跳视图事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local JumpForwardTween = require("app.FightSystem.Veiws.ViewCommonModel.ViewTween.JumpForwardTween")

local JumpHeightTween = require("app.FightSystem.Veiws.ViewCommonModel.ViewTween.JumpHeightTween")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterJumpForwardViewEvent = {}

function CharacterJumpForwardViewEvent:create(...)
    return CharacterJumpForwardViewEvent.new():__init(...)
end

function CharacterJumpForwardViewEvent:__init(jumperId, targetId, jumpOffset, jumpDuration)
    self.__jumperId = jumperId

    self.__targetId = targetId

    self.__jumpOffset = jumpOffset

    self.__jumpDuration = jumpDuration

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterJumpForwardViewEvent:doViewEvent(mainView)
    self.__mainView = mainView

    self:__jumpInit()

    self:__jumperJump()

    self:__blockerJump()
end

function CharacterJumpForwardViewEvent:__jumpInit()
    self.__jumperViewCharacter = self.__mainView:getViewCharacter(self.__jumperId)
    self.__targetViewCharacter = self.__mainView:getViewCharacter(self.__targetId)
    self.__targetPostion = self.__targetViewCharacter:getPosition()

    self.__jumperStartPostion = self.__jumperViewCharacter:getPosition()

    if self.__targetPostion.x - self.__jumperStartPostion.x >= 0 then
        self.__jumpDirFactor = 1
    else
        self.__jumpDirFactor = -1
    end

    self.__targetPos = {
        x = self.__targetPostion.x + ((-self.__jumpOffset) * self.__jumpDirFactor),
        y = self.__targetPostion.y
    }

    self.__jumpHighest = math.abs((self.__targetPos.x - self.__jumperStartPostion.x)) / 1080 * 30
end

function CharacterJumpForwardViewEvent:__jumperJump()
    local jumpTween =
        JumpForwardTween:create(
        function()
            local pos = self.__jumperViewCharacter:getPosition()
            return {x = pos.x, y = pos.y}
        end,
        function(next)
            self.__jumperViewCharacter:setPositionX(next.x)

            self.__jumperViewCharacter:setPositionY(next.y)

            local pos = self.__jumperViewCharacter:getPosition()

            self.__mainView:setCharacterAnimPosition(self.__jumperViewCharacter:getId(), pos.x, pos.y, pos.h)
        end,
        self.__targetPos,
        self.__jumpDuration
    ):onComplete(
        function()
            self.__mainView:playCharacterAnim(self.__jumperViewCharacter:getId(), self.__jumperViewCharacter:getIdleAnimName(), false)
        end
    )
    self.__mainView:playCharacterAnim(self.__jumperViewCharacter:getId(), self.__jumperViewCharacter:getJumpForwardAnimName(), false)

    self.__mainView:doUITween(jumpTween)

    local jumpHTween =
        JumpHeightTween:create(
        function()
            return self.__jumperViewCharacter:getPositionH()
        end,
        function(nextH)
            self.__jumperViewCharacter:setPositionH(nextH)

            local pos = self.__jumperViewCharacter:getPosition()

            self.__mainView:setCharacterAnimPosition(self.__jumperViewCharacter:getId(), pos.x, pos.y, pos.h)
        end,
        self.__jumpHighest,
        self.__jumpDuration
    )

    self.__mainView:doUITween(jumpHTween)
end

function CharacterJumpForwardViewEvent:__blockerJump()
    local blockerViewCharacter
    self.__mainView:walkViewCharacters(
        function(otherCharacter)
            --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
            otherCharacter = otherCharacter
            if otherCharacter:isDead() == true or otherCharacter == self.__jumperViewCharacter or otherCharacter == self.__targetViewCharacter then
                return false
            end

            if math.abs(otherCharacter:getPositionY() - self.__targetPos.y) < 50 then
                if self.__jumperViewCharacter:getScaleX() > 0 and otherCharacter:getScaleX() > 0 then
                    blockerViewCharacter = otherCharacter
                    return true
                elseif self.__jumperViewCharacter:getScaleX() < 0 and otherCharacter:getScaleX() < 0 then
                    blockerViewCharacter = otherCharacter
                    return true
                end
            end
            return false
        end
    )

    if blockerViewCharacter == nil then
        return
    end

    local blockerPostion = blockerViewCharacter:getPosition()

    local blockerTargetPos = {
        x = blockerPostion.x,
        y = self.__jumperViewCharacter:getPositionY(),
        h = blockerPostion.h
    }

    local blockerJumpTween =
        JumpForwardTween:create(
        function()
            local pos = blockerViewCharacter:getPosition()
            return {x = pos.x, y = pos.y}
        end,
        function(next)
            blockerViewCharacter:setPositionX(next.x)

            blockerViewCharacter:setPositionY(next.y)

            local pos = blockerViewCharacter:getPosition()

            self.__mainView:setCharacterAnimPosition(blockerViewCharacter:getId(), pos.x, pos.y, pos.h)
        end,
        blockerTargetPos,
        self.__jumpDuration * (1 - 0.3333)
    ):onComplete(
        function()
            self.__mainView:playCharacterAnim(blockerViewCharacter:getId(), blockerViewCharacter:getIdleAnimName(), false)
        end
    )
    self.__mainView:playCharacterAnim(blockerViewCharacter:getId(), blockerViewCharacter:getJumpForwardAnimName(), false)

    self.__mainView:doUITween(blockerJumpTween)

    local blockerJumpHTween =
        JumpHeightTween:create(
        function()
            return blockerViewCharacter:getPositionH()
        end,
        function(nextH)
            blockerViewCharacter:setPositionH(nextH)

            local pos = blockerViewCharacter:getPosition()

            self.__mainView:setCharacterAnimPosition(blockerViewCharacter:getId(), pos.x, pos.y, pos.h)
        end,
        self.__jumpHighest,
        self.__jumpDuration * (1 - 0.3333)
    )

    self.__mainView:doUITween(blockerJumpHTween)
end

return newClass("CharacterJumpForwardViewEvent", {IViewEvent}, CharacterJumpForwardViewEvent)
0000000000000000
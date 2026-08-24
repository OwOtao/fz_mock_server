local newClass = require("third.class.NewClass")

local ABtnCtrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARATER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
local ActiveSkillBtnCtrl = {
    __type = CHARATER_CMD_TYPE.RELEASE_ACTIVE
}

function ActiveSkillBtnCtrl:create(act_id)
    local p = ActiveSkillBtnCtrl:new()
    p:__init(act_id)
    return p
end

function ActiveSkillBtnCtrl:__init(act_id)
    self:setId(act_id)

    self.__pressTime = 0

    self.__isPress = false

    self.__isShowDialog = false

    self.__prePressTime = 0
end

function ActiveSkillBtnCtrl:beganFunc()
    local currPressTime = GetLocalTime()

    if currPressTime - self.__prePressTime < 0.3 then
        if self.__isPress then
            self.__isPress = false
        end

        if self.__pressTime > 0 then
            self.__pressTime = 0
        end

        return
    end

    self.__isPress = true

    self.__pressTime = 0

    self.__prePressTime = GetLocalTime()
end

function ActiveSkillBtnCtrl:releaseFunc()
    if self.__isShowDialog then
        self.__isShowDialog = false
    else
        self.__fightUICtrl:sendPlayerCommand(
            FightCommons.FIGHT_CMD_TYPE.CHARACTER_ACTIVE,
            {
                act_id = self:getId()
            }
        )
    end

    self.__pressTime = 0
    self.__isPress = false
end

function ActiveSkillBtnCtrl:canceledFunc()
    if self.__isShowDialog then
        self.__isShowDialog = false
    end

    self.__isPress = false
    self.__pressTime = 0
end

function ActiveSkillBtnCtrl:update(ft)
    if self.__isPress and not self.__isShowDialog then
        if self.__pressTime >= 0.5 then
            self.__fightUICtrl:showPlayerActiveSkillInfoPanel(self:getId())
            self.__isShowDialog = true
        end

        self.__pressTime = self.__pressTime + ft
    end
end

return newClass("ActiveSkillBtnCtrl", {ABtnCtrl}, ActiveSkillBtnCtrl)
00000000
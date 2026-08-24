local newClass = require("third.class.NewClass")

local ButtonsAreaCtrl = require("app.FightSystem.UICtrl.ButtonsAreaCtrl")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local HasHPHealButtonAreaCtrl = {}

function HasHPHealButtonAreaCtrl:create()
    return HasHPHealButtonAreaCtrl.new()
end

function HasHPHealButtonAreaCtrl:__initHealBtnCtrl()
    local vm = self.__playerCtrl:getRecoverQiVmInfo()

    self:addBtn(vm, 7)
end

function HasHPHealButtonAreaCtrl:startFight()
    self:__initStartFight()

    self:__initActiveSkillBtns()

    self:__addRunawayBtnCtrl()

    self:__addChangeWeaponBtn()

    self:__initHealBtnCtrl()

    self:__moveBtnPosition()
end

return newClass("HasHPHealButtonAreaCtrl", {ButtonsAreaCtrl}, HasHPHealButtonAreaCtrl)
0000000
--[[
    author:Seven
    time:2023-10-19 21:17:09
    desc: 视图层角色类
]]
local newClass = require("third.class.NewClass")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ViewCharacter = {}

function ViewCharacter:create(...)
    return ViewCharacter.new():__init(...)
end

function ViewCharacter:ctor()
    self.__attrs = {
        qi = 0,
        qiMax = 0,
        qiLimitBattle = 0,
        neili = 0,
        neiliMax = 0,
        neiliLimit = 0,
        tili = 0,
        tiliMax = 0
    }

    self.__pos = {
        x = 0,
        y = 0,
        h = 0
    }

    self.__id = nil

    self.__posindex = 1

    self.__name = nil

    self.__teamId = nil

    self.__isDead = false

    self.__icons = {}

    self.__targetId = nil

    self.__idleAnim = nil

    self.__weaponSkin = nil

    self.__scaleX = 1

    self.__activeSkillMap = {}

    self.__hurtAnimAndSoundMap = {}

    self.__deadAnimAndSoundMap = {}

    self.__icons = {}

    self.__qiRecover = nil

    self.__shieldAnimId = nil

    self.__shadowAnimId = nil

    self.__headText = nil
end

function ViewCharacter:__init(id, name, teamId)
    self.__id = id

    self.__name = name

    self.__teamId = teamId

    return self
end

function ViewCharacter:setMainView(mainView)
    --@RefType [FightMainView]
    self.__mainView = mainView
end

function ViewCharacter:setOriginPosIndex(index)
    self.__posindex = index

    local p = FightCommons.CHARACTER_POSITION[index]

    self.__pos.x = p.x

    self.__pos.y = p.y

    self.__pos.h = 0

    if index <= 3 then
        self.__scaleX = 1
    else
        self.__scaleX = -1
    end
end

function ViewCharacter:getOriginPosIndex()
    return self.__posindex
end

function ViewCharacter:setPosition(x, y, h)
    self.__pos.x = x

    self.__pos.y = y

    self.__pos.h = h
end

function ViewCharacter:getPosition()
    return self.__pos
end

function ViewCharacter:setPositionX(value)
    self.__pos.x = value
end

function ViewCharacter:setPositionY(value)
    self.__pos.y = value
end

function ViewCharacter:setPositionH(value)
    self.__pos.h = value
end

function ViewCharacter:getPositionX()
    return self.__pos.x
end

function ViewCharacter:getPositionY()
    return self.__pos.y
end

function ViewCharacter:getPositionH()
    return self.__pos.h
end

function ViewCharacter:getScaleX()
    return self.__scaleX
end

--@desc: 获取开始位置
--@author:Seven
--@time:2023-10-23 11:26:02
--@return: cc.p(x,y)
function ViewCharacter:getOriginStartPosition()
    local p = FightCommons.CHARACTER_POSITION[self.__posindex]
    return p.x, p.y
end

function ViewCharacter:getId()
    return self.__id
end

function ViewCharacter:getName()
    return self.__name
end

function ViewCharacter:setAttr(name, value)
    if self.__attrs[name] == nil then
        return
    end
    self.__attrs[name] = value
end

function ViewCharacter:getAttr(name)
    if self.__attrs[name] == nil then
        return 0
    end
    return self.__attrs[name]
end

function ViewCharacter:getAttrMap()
    return self.__attrs
end

function ViewCharacter:__limitAttr(name, finalValue)
    if name == "qi" then
        local limitValue = self:getAttr("qiMax")
        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    elseif name == "qiMax" then
        local limitValue = self:getAttr("qiLimitBattle")
        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    elseif name == "neili" then
        local limitValue = self:getAttr("neiliLimit")

        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    else
        if finalValue < 0 then
            return 0
        end
    end

    return finalValue
end

function ViewCharacter:getUIShowAttr(name)
    local finalValue = Helper:mathFloor(self:__limitAttr(name, self:getAttr(name)))

    return finalValue
end

function ViewCharacter:setIdleAnim(idleAnimId)
    self.__idleAnim = idleAnimId
end

--@desc: 获取当前角色静态动画
--@author:Seven
--@time:2023-10-20 14:31:55
function ViewCharacter:getIdleAnimName()
    return AnimResManager:getOtherAnimName(self.__idleAnim)
end

function ViewCharacter:setJumpForwardAnim(jumpForwardAnimId)
    self.__jumpForwardAnim = jumpForwardAnimId
end

function ViewCharacter:getJumpForwardAnimName()
    return AnimResManager:getOtherAnimName(self.__jumpForwardAnim)
end

function ViewCharacter:setJumpBackAnim(jumpBackAnimId)
    self.__jumpBackAnim = jumpBackAnimId
end

function ViewCharacter:getJumpBackAnimName()
    return AnimResManager:getOtherAnimName(self.__jumpBackAnim)
end

function ViewCharacter:setIcons(icons)
    self.__icons = icons
end

function ViewCharacter:getIcons()
    return self.__icons
end

function ViewCharacter:setTargetId(targetId)
    self.__targetId = targetId
end

function ViewCharacter:getTargetId()
    return self.__targetId
end

function ViewCharacter:setWeaponSkin(weaponSkin)
    self.__weaponSkin = weaponSkin
end

function ViewCharacter:getWeaponSkin()
    return self.__weaponSkin
end

--@desc: 添加主动技能视图类接口
--@author:Seven
--@time:2023-10-25 15:12:46
--@index: 位置索引
--@viewActiveSkill: [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
function ViewCharacter:addViewActiveSkill(index, viewActiveSkill)
    self.__activeSkillMap[tostring(index)] = viewActiveSkill
end

--@desc: 根据索引获取主动技能视图类接口，可返回空值
--@author:Seven
--@time:2023-10-25 15:26:01
--@index: 索引
--@return [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
function ViewCharacter:getViewActiveSkillByIndex(index)
    return self.__activeSkillMap[tostring(index)]
end

--@desc: 根据主动技能id获取
--@author:Seven
--@time:2023-10-25 15:27:22
--@activeSkillId: 主动技能id
--@return [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
function ViewCharacter:getViewActiveSkillById(activeSkillId)
    for k, v in pairs(self.__activeSkillMap) do
        if v:getViewActiveId() == activeSkillId then
            return v
        end
    end
end

function ViewCharacter:clearViewActiveSkillMap()
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local viewActiveSkill = self:getViewActiveSkillByIndex(i)
        if viewActiveSkill then
            viewActiveSkill:destory()
        end

        self.__activeSkillMap[tostring(i)] = nil
    end
end

function ViewCharacter:getViewActiveSkillMap()
    return self.__activeSkillMap
end

function ViewCharacter:setDead(bool)
    self.__isDead = bool
end

function ViewCharacter:isDead()
    return self.__isDead == true
end

function ViewCharacter:updateTiliView(old, new, ft)
    self:killTiliTween()

    local tiliMax = self:getAttr("tiliMax")

    self:setAttr("tili", old)
    self.__tiliTween =
        self.__mainView:doUINumberTween(
        function()
            return self:getAttr("tili")
        end,
        function(value)
            self:setAttr("tili", value)
            self.__mainView:setInfoTiliView(self:getId(), value, tiliMax)
        end,
        new,
        ft
    ):onComplete(
        function()
            self.__tiliTween = nil
        end
    )
end

function ViewCharacter:costTiliView(tili, tiliMax, costValue)
    self:killTiliTween()
    self:setAttr("tili", tili)
    self:setAttr("tiliMax", tiliMax)
    self.__mainView:setInfoTiliView(self.__id, tili, tiliMax)
end

function ViewCharacter:killTiliTween()
    if self.__tiliTween then
        self.__tiliTween:kill()
        self.__tiliTween = nil
    end
end

function ViewCharacter:costNeiliView(neili, neiliMax, costValue)
    self:setAttr("neili", neili)
    self:setAttr("neiliMax", neiliMax)
    self.__mainView:setInfoNeiliAndNeiliMaxView(self.__id, self:getUIShowAttr("neili"), self:getUIShowAttr("neiliMax"))
    self.__mainView:showCharacterCostNeiliView(self.__id, -costValue)
end

function ViewCharacter:setHurtAnimAndSoundMap(animMap)
    self.__hurtAnimAndSoundMap = animMap
end

function ViewCharacter:getHurtAnimAndHurtSound(hitPos)
    local list = self.__hurtAnimAndSoundMap[hitPos]

    if #list > 1 then
        local hurtAndSound = list[FightUtil:random(1, #list)]
        return hurtAndSound.hurtAnimName, hurtAndSound.hurtSoundId
    else
        return list[1].hurtAnimName, list[1].hurtSoundId
    end
end

function ViewCharacter:setDeadAnimAndSound(map)
    self.__deadAnimAndSoundMap = map
end

function ViewCharacter:getDeadAnimAndDeadSound(hitPos)
    local list = self.__deadAnimAndSoundMap[hitPos]

    if #list > 1 then
        local hurtAndSound = list[FightUtil:random(1, #list)]
        return hurtAndSound.hurtAnimName, hurtAndSound.hurtSoundId
    else
        return list[1].hurtAnimName, list[1].hurtSoundId
    end
end

function ViewCharacter:setParryHurtAnimAndSound(animMap)
    self.__parryHurtAnimAndSoundMap = animMap
end

function ViewCharacter:getParryHurtAnimAndHurtSound(hitPos)
    local list = self.__parryHurtAnimAndSoundMap[hitPos]

    if #list > 1 then
        local hurtAndSound = list[FightUtil:random(1, #list)]
        return hurtAndSound.hurtAnimName, hurtAndSound.hurtSoundId
    else
        return list[1].hurtAnimName, list[1].hurtSoundId
    end
end

function ViewCharacter:setDodgeAnimAndSound(map)
    self.__dodgeAnimAndSoundMap = map
end

function ViewCharacter:getDodgeAnimAndSound(hitPos)
    local list = self.__dodgeAnimAndSoundMap[hitPos]

    if #list > 1 then
        local hurtAndSound = list[FightUtil:random(1, #list)]
        return hurtAndSound.hurtAnimName, hurtAndSound.hurtSoundId, hurtAndSound.dodgeOffset
    else
        return list[1].hurtAnimName, list[1].hurtSoundId, list[1].dodgeOffset
    end
end

--@desc: 更新视图属性
--@author:Seven
--@time:2023-11-04 16:23:20
--@mainView: [FightMainView]
function ViewCharacter:updateAttrUI(mainView)
    local qi = self:getUIShowAttr("qi")
    local qiMax = self:getUIShowAttr("qiMax")
    local qiLimitBattle = self:getUIShowAttr("qiLimitBattle")
    local neili = self:getUIShowAttr("neili")
    local neiliMax = self:getUIShowAttr("neiliMax")
    mainView:setInfoQiAnQiMaxView(self:getId(), qi, qiMax, qiLimitBattle)
    mainView:setInfoNeiliAndNeiliMaxView(self:getId(), neili, neiliMax)
end

function ViewCharacter:setQiRecover(qiRecover)
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewQiRecover#ViewQiRecover]
    self.__qiRecover = qiRecover
end

function ViewCharacter:getQiRecover()
    return self.__qiRecover
end

function ViewCharacter:setRunaway(runaway)
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewRunaway#ViewRunaway]
    self.__viewRunaway = runaway
end

function ViewCharacter:getRunaway()
    return self.__viewRunaway
end

function ViewCharacter:setChangeWeapon(viewChangeWeapon)
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewChangeWeapon#ViewChangeWeapon]
    self.__viewChangeWeapon = viewChangeWeapon
end

--@desc: 易武视图类
--@author:Seven
--@time:2023-11-13 17:14:15
--@return [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewChangeWeapon#ViewChangeWeapon]
function ViewCharacter:getChangeWeapon()
    return self.__viewChangeWeapon
end

--@desc: 更新主界面buff图标显示
--@author:Seven
--@time:2023-11-24 14:10:59
--@mainView: [FightMainView]
function ViewCharacter:updateIconUI(mainView)
    mainView:updateBuffIcons(self:getId(), self:getIcons())
end

function ViewCharacter:setShieldAnimId(animId)
    self.__shieldAnimId = animId
end

function ViewCharacter:getShieldAnimId()
    return self.__shieldAnimId
end

--@desc: 更新角色护盾UI显示
--@author:Seven
--@time:2023-11-24 15:33:14
--@mainView: [FightMainView]
function ViewCharacter:updateShieldUI(mainView)
    if self.__shieldAnimId == nil then
        mainView:hideCharacterShieldAnim(self.__id)
        return
    end

    mainView:showCharacterShieldAnim(self:getId(), AnimResManager:getOtherAnimName(self.__shieldAnimId))
end

function ViewCharacter:setShadowAnimId(animId)
    self.__shadowAnimId = animId
end

--@mainView: [FightMainView]
function ViewCharacter:updateShadowUI(mainView)
    if self.__shadowAnimId == nil then
        mainView:hideCharacterShadowAnim(self.__id)
        return
    end

    mainView:showCharacterShadowAnim(self:getId(), AnimResManager:getOtherAnimName(self.__shadowAnimId))
end

function ViewCharacter:setHeadText(text)
    self.__headText = text
end

--@mainView: [FightMainView]
function ViewCharacter:updateHeadTextUI(mainView)
    if self.__headText == nil then
        mainView:hideStatusText(self.__id)
        return
    end

    mainView:showStatusText(self.__id, self.__headText)
end

return newClass("ViewCharacter", {}, ViewCharacter)
00000000000000
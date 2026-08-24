local Skill = require("app.models.skill.Skill")

local FightConfig = {
    __passiveEffectMap = {},
    __startFightSkillEffectMap = {},
    __effectAnims = {},
    __fragileConfigs = {},
    __augmentConfigs = {},
    __animalAttackPartMap = {},
    __partDamageMap = {},
    Constant = {
        AnimClassPos = {
            Foot = 1
        },
        AnimDisplayType = {
            Id = 0,
            State = 1
        },
        FragileCount = 20,
        AugmentCount = 20,
        EffectAnimPos = {
            Stand = "standingposture", --站姿
            StandCtrl = "controlledStunAnim", --晕迷瘫痪定身动画
            StandCtrlCf = "controlledConfuseAnim", --迷惑动画
            HurtH = "damagetakenH", --受击动画-头部
            HurtC = "damagetakenC", --受击动画-胸部
            HurtF = "damagetakenL", --受击动画-腿部
            Dead = "deathanimation", --死亡动画
            DodgeH = "dodgeanimationH", --闪避动画-头部
            DodgeC = "dodgeanimationC", --闪避动画-胸部
            DodgeF = "dodgeanimationL", --闪避动画-腿部
            ParryH = "blockanimationH", --格挡动画-头部
            ParryC = "blockanimationC", --格挡动画-胸部
            ParryF = "blockanimationL" --格挡动画-腿部
        }
    }
}

local function __initEffects(effectStr)
    local effects = {}

    local strList = string.split(effectStr, "|")

    for i, v in ipairs(strList) do
        local effectList = string.split(v, "#")

        local effectId = effectList[1]

        local effect = Skill:getSkillEffect(effectId):clone()

        local zArgs = {
            tonumber(effectList[2]),
            tonumber(effectList[3]),
            tonumber(effectList[4])
        }

        effect:setZArgs(zArgs)

        table.insert(effects, effect)
    end

    return effects
end

local function initPassiveEffects()
    local passiveEffectMap = require("script.skill.activeZhao").passiveEffect

    for id, v in pairs(passiveEffectMap) do
        if FightConfig.__passiveEffectMap[id] == nil then
            FightConfig.__passiveEffectMap[id] = {}
        end

        local effects = __initEffects(v.effectId)

        FightConfig.__passiveEffectMap[id] = {
            id = v.id,
            effects = effects,
            removeType = v.removeType
        }
    end
end

local function initStartFightSkillDefaultEffects()
    local startFightSkillEffectMap = require("script.skill.skillPassiveEffect").skillPassiveEffect

    FightConfig.__startFightSkillEffectMap = startFightSkillEffectMap
end

local function initEffectAnim()
    local effectAnim = require("script.skill.activeZhao").EffectAnim

    local __effectAnims = {}

    for k, v in pairs(effectAnim) do
        if __effectAnims[tostring(v.animClass)] == nil then
            __effectAnims[tostring(v.animClass)] = {}
        end
        table.insert(__effectAnims[tostring(v.animClass)], v)
    end

    FightConfig.__effectAnims = __effectAnims
end

local function initfragileConfigs()
    FightConfig.__fragileConfigs[1] = {
        id = 1,
        arg = "fragile1num",
        icon = "创d"
    }

    FightConfig.__fragileConfigs[2] = {
        id = 2,
        arg = "fragile2num",
        icon = "创d"
    }

    FightConfig.__fragileConfigs[3] = {
        id = 3,
        arg = "fragile3num",
        icon = "创d"
    }

    FightConfig.__fragileConfigs[4] = {
        id = 4,
        arg = "fragile4num",
        icon = "蛊d"
    }

    FightConfig.__fragileConfigs[5] = {
        id = 5,
        arg = "fragile5num",
        icon = "和d"
    }

    for i = 1, FightConfig.Constant.FragileCount do
        if MapIsEmpty(FightConfig.__fragileConfigs[i]) then
            FightConfig.__fragileConfigs[i] = {
                id = i,
                arg = "fragile" .. tostring(i) .. "num",
                icon = nil
            }
        end
    end
end

local function initAugmentConfigs()
    FightConfig.__augmentConfigs[1] = {
        id = 1,
        arg = "augment1num",
        icon = "激b"
    }

    FightConfig.__augmentConfigs[2] = {
        id = 2,
        arg = "augment2num",
        icon = "隐b"
    }

    FightConfig.__augmentConfigs[3] = {
        id = 3,
        arg = "augment3num",
        icon = "洞b"
    }

    FightConfig.__augmentConfigs[4] = {
        id = 4,
        arg = "augment4num",
        icon = "扬b"
    }

    FightConfig.__augmentConfigs[6] = {
        id = 6,
        arg = "augment6num",
        icon = "骁b"
    }

    FightConfig.__augmentConfigs[7] = {
        id = 7,
        arg = "augment7num",
        icon = "灵b"
    }

    FightConfig.__augmentConfigs[8] = {
        id = 8,
        arg = "augment8num",
        icon = "着b"
    }

    FightConfig.__augmentConfigs[10] = {
        id = 10,
        arg = "augment10num",
        icon = "庚b"
    }

    FightConfig.__augmentConfigs[12] = {
        id = 12,
        arg = "augment12num",
        icon = "因b"
    }

    FightConfig.__augmentConfigs[14] = {
        id = 14,
        arg = "augment14num",
        icon = "朽b"
    }

    for i = 1, FightConfig.Constant.AugmentCount do
        if MapIsEmpty(FightConfig.__augmentConfigs[i]) then
            FightConfig.__augmentConfigs[i] = {
                id = i,
                arg = "augment" .. tostring(i) .. "num",
                icon = nil
            }
        end
    end
end

local function initAnimalAttackPartConfig()
    local animalAttackPartMap = assert(require("script.skill.animalAttackPosition")["部位表示"])

    for k, attackPosition in pairs(animalAttackPartMap) do
        local animalAttackPartData = {}
        local parts = {}
        local realParts = {}
        for i = 1, 99 do
            local part = attackPosition["Part" .. i]
            if part ~= nil and part ~= "" then
                table.insert(parts, part)
            end
            local realPart = attackPosition["realPart" .. i]
            if realPart ~= nil and realPart ~= "" then
                table.insert(realParts, realPart)
            end
        end
        animalAttackPartData.parts = parts
        animalAttackPartData.realParts = realParts
        FightConfig.__animalAttackPartMap[attackPosition.animaltype] = animalAttackPartData
    end
end

local function initPartDamageConfig()
    local partDamageMap = assert(require("script.skill.attackPart")["部位系数"])

    for k, partData in pairs(partDamageMap) do
        FightConfig.__partDamageMap[partData.realPart] = partData
    end
end

initStartFightSkillDefaultEffects()
initEffectAnim()
initAugmentConfigs()
initfragileConfigs()

initAnimalAttackPartConfig()
initPartDamageConfig()

function FightConfig:getPassiveEffectsByActiveZhaoId(zhaoId)
    if MapIsEmpty(self.__passiveEffectMap) then
        initPassiveEffects()
    end

    if self.__passiveEffectMap[zhaoId] then
        return self.__passiveEffectMap[zhaoId].effects
    end
end

function FightConfig:getPassiveEffectsRemoveType(zhaoId)
    if MapIsEmpty(self.__passiveEffectMap) then
        initPassiveEffects()
    end

    if self.__passiveEffectMap[zhaoId] then
        return self.__passiveEffectMap[zhaoId].removeType
    end
end

--@desc: 获取角色脚底效果动画
--@author:LvBin
--@time:2023-03-11 15:55:52
--@animClass:
--@fightRole:
--@return
function FightConfig:getRoleShadowSpriteEffect(fightRole)
    local effectAnims = {}

    for k, effect in pairs(fightRole:getEffectMap()) do
        local effectAnim = self:__getEffectAnimByPos(self.Constant.AnimClassPos.Foot, effect:getId())
        if effectAnim then
            if effectAnim.animDisplayType == self.Constant.AnimDisplayType.Id then
                table.insert(effectAnims, effectAnim)
            elseif effectAnim.animDisplayType == self.Constant.AnimDisplayType.State and effect:getEffectObject(fightRole):isTakeEffect() then
                table.insert(effectAnims, effectAnim)
            end
        end
    end

    if #effectAnims > 1 then
        --从大到小排序
        table.sort(
            effectAnims,
            function(a, b)
                return a.animIndex > b.animIndex
            end
        )
    end

    if effectAnims[1] then
        return effectAnims[1].animate
    else
        return nil
    end
end

--@desc: 根据动画部位和效果Id获取动画
--@author:LvBin
--@time:2023-03-11 15:08:44
--@return
function FightConfig:__getEffectAnimByPos(animClass, effectId)
    local effectAnims = assert(self.__effectAnims[tostring(animClass)], "FightConfig:__getEffectAnimByPos 参数 动画部位系列找不到 animClass " .. animClass)

    for i, v in ipairs(effectAnims) do
        if effectId == v.effectId then
            return v
        end
    end

    return nil
end

--@desc: 根据效果Id获取动画数据
--@author:LvBin
--@time:2024-01-06 16:48:08
--@effectId:
--@return
function FightConfig:__getEffectAnims(effectId)
    local effectAnimRes = require("script.skill.activeZhao").EffectAnim

    for k, v in pairs(effectAnimRes) do
        if effectId == v.effectId then
            return v
        end
    end

    return nil
end

function FightConfig:getStartFightSkillDefaultEffects()
    local effects = {}

    for k, v in pairs(self.__startFightSkillEffectMap) do
        if not effects[v.effectId] then
            effects[v.effectId] = v
        end
    end

    return effects
end

function FightConfig:getStartFightInfoBySkillId(skillId)
    if MapIsEmpty(self.__startFightSkillEffectMap) == false then
        for k, v in pairs(self.__startFightSkillEffectMap) do
            if skillId == v.skillId then
                return v
            end
        end
    end
end

function FightConfig:getAugmentIdByArg(arg)
    for i = 1, self.Constant.AugmentCount do
        local info = self.__augmentConfigs[i]
        if arg == info.arg then
            return info.id
        end
    end
    assert(false, "FightConfig:getAugmentIdByArg arg is not found, arg is" .. arg)
end

function FightConfig:getAugmentInfoById(id)
    for i = 1, self.Constant.AugmentCount do
        local info = self.__augmentConfigs[i]
        if id == info.id then
            return info
        end
    end
    assert(false, "FightConfig:getAugmentInfoById id is not found, id is" .. id)
end

function FightConfig:getFragileIdByArg(arg)
    for i = 1, self.Constant.FragileCount do
        local info = self.__fragileConfigs[i]
        if arg == info.arg then
            return info.id
        end
    end
    assert(false, "FightConfig:getFragileIdByArg arg is not found, arg is" .. arg)
end

function FightConfig:getFragileInfoById(id)
    for i = 1, self.Constant.FragileCount do
        local info = self.__fragileConfigs[i]
        if id == info.id then
            return info
        end
    end
    assert(false, "FightConfig:getFragileInfoById id is not found, id is" .. id)
end

--@desc: 根据部位获取效果绑定动画
--@author:LvBin
--@time:2024-01-06 17:41:47
--@fightRole:
--@return
function FightConfig:getEffectBindAnimByPos(fightRole, pos)
    local effectAnims = {}

    for k, effect in pairs(fightRole:getEffectMap()) do
        local effectAnim = self:__getEffectAnims(effect:getId())
        if effectAnim and effectAnim[pos] then
            if effectAnim.animDisplayType == self.Constant.AnimDisplayType.Id then
                table.insert(effectAnims, effectAnim)
            elseif effectAnim.animDisplayType == self.Constant.AnimDisplayType.State and effect:getEffectObject(fightRole):isTakeEffect() then
                table.insert(effectAnims, effectAnim)
            end
        end
    end

    if #effectAnims > 1 then
        --从大到小排序
        table.sort(
            effectAnims,
            function(a, b)
                return a.animIndex > b.animIndex
            end
        )
    end

    if effectAnims[1] then
        return effectAnims[1][pos]
    else
        return nil
    end
end

function FightConfig:isSpecialActiveZhaoAnim(fightRole)
    if self:getEffectBindAnimByPos(fightRole, "specialanimation") == 2 then
        return true
    end

    return false
end

function FightConfig:getRandomAnimalAttackPart(animalType)
    local animalAttackPartData

    if animalType and self.__animalAttackPartMap[animalType] then
        animalAttackPartData = self.__animalAttackPartMap[animalType]
    else
        animalAttackPartData = self.__animalAttackPartMap["通用"]
    end

    local randomIndex = math.random(1, #animalAttackPartData.parts)
    return animalAttackPartData.parts[randomIndex], animalAttackPartData.realParts[randomIndex]
end

function FightConfig:getPartRate(partName)
    if not self.__partDamageMap[partName] then
        error("FightConfig:getPartRate part not " .. partName)
    end

    return self.__partDamageMap[partName].Rate
end

function FightConfig:getPartEquipName(partName)
    if not self.__partDamageMap[partName] then
        error("FightConfig:getPartEquipName part not " .. partName)
    end

    return self.__partDamageMap[partName].defPart
end

local test_config = nil
function FightConfig:testServerGMFactor(name, defaultValue)
    if device.platform ~= "windows" then
        assert(false, "非windows平台，不应该调用")
    end

    defaultValue = defaultValue or 1

    -- 延迟加载配置，只加载一次
    if test_config == nil then
        local fileName = "FightTestGMConfig.json"
        -- 需先判断文件在不在，防止打包后找不到文件报错
        local fullPath = cc.FileUtils:getInstance():getWritablePath() .. fileName
        if not cc.FileUtils:getInstance():isFileExist(fullPath) then
            test_config = false -- 标记为已尝试加载但失败
            return defaultValue
        end
        local config = json.decode(cc.FileUtils:getInstance():getStringFromFile(fullPath))
        if config == nil then
            test_config = false -- 标记为已尝试加载但失败
            return defaultValue
        end
        test_config = config["战斗GM系数"] or false
    end

    -- 如果配置加载失败或未启用，直接返回默认值
    if test_config == false then
        return defaultValue
    end

    -- 返回配置中的系数，如果不存在则返回1
    if test_config.enabled and test_config[name] then
        return test_config[name]
    end

    return defaultValue
end

-- 清除配置缓存，下次调用testServerGMFactor时会重新加载
function FightConfig:clearTestServerGMConfig()
    test_config = nil
end

return FightConfig
00000000000
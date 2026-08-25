local newClass = require("third.class.NewClass")

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

--@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
local FistFootEffect = require("app.models.FistFootSystem.FistFootEffect.FistFootEffect")

local FistFootConst = require("app.models.FistFootSystem.FistFootConst")

--@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
local PlayerFistFootTechnique = require("app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique")

local FistFootSystem = {
    __codeVersion = 1,
    __accpoint = 0, --固身元气
    __reflectExp = 0, --潜思经验
    __feelPoint = 0, --感悟点数
    __characterPoint = 0, --特性见解
    __branchInfo = {
        ["10010"] = {
            exp = 0,
            -- 拳法分支经验
            costTechnique = 0, --消耗技巧点数
            --已解锁技巧列表
            --[[
                techniqueList : 
                 ["10001"] = {
                     id = "10001",
                     lv = 1, --等级
                     branchId = "10010"
            },]]
            techniqueList = {},
            -- 特性列表 [{techniqueId = "10001",characterId = "1001"},]
            effects = {},
            unUseEffects = {}, --已抽取未装备特性列表
            --@desc 技巧对象
            techniqueClassMap = {}
        },
        ["10020"] = {
            exp = 0,
            -- 掌法分支经验
            costTechnique = 0, --消耗技巧点数
            techniqueList = {},
            effects = {},
            --已领悟特性列表
            unUseEffects = {}, --已抽取未装备特性列表
            --@desc 技巧对象
            techniqueClassMap = {}
        },
        ["10030"] = {
            exp = 0,
            -- 爪法分支经验
            costTechnique = 0, --消耗技巧点数
            techniqueList = {},
            effects = {},
            --已领悟特性列表
            unUseEffects = {}, --已抽取未装备特性列表
            --@desc 技巧对象
            techniqueClassMap = {}
        },
        ["10040"] = {
            exp = 0,
            -- 指法分支经验
            costTechnique = 0, --消耗技巧点数
            techniqueList = {},
            effects = {},
            --已领悟特性列表
            unUseEffects = {}, --已抽取未装备特性列表
            --@desc 技巧对象
            techniqueClassMap = {}
        },
        ["10050"] = {
            exp = 0,
            -- 腿法分支经验
            costTechnique = 0, --消耗技巧点数
            techniqueList = {},
            effects = {},
            --已领悟特性列表
            unUseEffects = {}, --已抽取未装备特性列表
            --@desc 技巧对象
            techniqueClassMap = {}
        }
    },
    -- 挂机数据
    __guajiInfo = {}
}

function FistFootSystem:create(player)
    local p = FistFootSystem.new(TableProxy:createEncryptedTable({}))
    p:__init(player)
    return p
end

function FistFootSystem:ctor()
    self.__isNotSerializable = true

    self.__player = nil
end

function FistFootSystem:__init(player)
    self.__player = player
end

function FistFootSystem:getPlayer()
    return self.__player
end

function FistFootSystem:createFistInfo(callback)
    self.__player:getServerActionSystem():createFistInfo(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                if not MapIsEmpty(data) then
                    self:initData(data)
                end

                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

function FistFootSystem:pullData(callback)
    self.__player:getServerActionSystem():getFistFootInFo(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                if not MapIsEmpty(data) then
                    self:initData(data)
                end

                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

function FistFootSystem:initData(data)
    if MapIsEmpty(data) then
        return
    end

    self:setAccpoint(data.accpoint)

    self:setGuaJiInfo(data.guajiInfo)

    self:setReflectExp(data.reflectExp)

    self:__initTelentPageData(data)

    self:setCharacterPoint(data.characterPoint)
end

function FistFootSystem:__initTelentPageData(data)
    self:__initBranchInfo(data.branchInfo)

    self:setFeelPoint(data.feelPoint)
end

function FistFootSystem:__initBranchInfo(branchInfo)
    self.__branchInfo = {}
    for branchType, v in pairs(branchInfo) do
        self.__branchInfo[branchType] = {}

        self.__branchInfo[branchType].exp = v.exp

        self.__branchInfo[branchType].costTechnique = v.costTechnique

        self.__branchInfo[branchType].techniqueList = v.techniqueList

        self:__initTechniqueClassMap(branchType)

        self:__initFistFootEffects(branchType, v.characterInUse)

        self:__initFistFootUnuseEffects(branchType, v.characterUnused)
    end
end

function FistFootSystem:__initTechniqueClassMap(branchType)
    self.__branchInfo[branchType].techniqueClassMap = {}

    for _, v in pairs(self.__branchInfo[branchType].techniqueList) do
        local p = PlayerFistFootTechnique:create(v.id, v.lv)

        self.__branchInfo[branchType].techniqueClassMap[tostring(v.id)] = p
    end
end

function FistFootSystem:__initFistFootEffects(branchType, characterInUse)
    self.__branchInfo[branchType].effects = {}
    if not MapIsEmpty(characterInUse) then
        for _, effectInfo in pairs(characterInUse) do
            table.insert(
                self.__branchInfo[branchType].effects,
                {
                    techniqueId = effectInfo.techniqueId,
                    characterId = effectInfo.characterId
                }
            )

            --@RefType[src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
            local p = self.__branchInfo[branchType]["techniqueClassMap"][tostring(effectInfo.techniqueId)]

            p:insertEffect(self:getFistFootEffect(effectInfo.characterId, p:getLevel()))
        end
    end
end

function FistFootSystem:__initFistFootUnuseEffects(branchType, characterUnused)
    self.__branchInfo[branchType].unUseEffects = {}
    if not MapIsEmpty(characterUnused) then
        for _, effectInfo in pairs(characterUnused) do
            table.insert(
                self.__branchInfo[branchType].unUseEffects,
                {
                    techniqueId = effectInfo.techniqueId,
                    characterId = effectInfo.characterId
                }
            )

            --@RefType[src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
            local p = self.__branchInfo[branchType]["techniqueClassMap"][tostring(effectInfo.techniqueId)]

            p:insertUnusedEffect(self:getFistFootEffect(effectInfo.characterId, p:getLevel()))
        end
    end
end

function FistFootSystem:isOpenSystem()
    local unlockFlag = FistFootConst:getConf("unlockFlag")
    local unlockLevel = tonumber(FistFootConst:getConf("unlockLevel"))

    return self:getPlayer():getInheritFlag(unlockFlag) == 1 and self:getPlayer():getLv() >= unlockLevel
end

function FistFootSystem:unlockSystem()
    local unlockFlag = FistFootConst:getConf("unlockFlag")

    self:getPlayer():setInheritFlag(unlockFlag, 1)
end

function FistFootSystem:setAccpoint(accpoint)
    self.__accpoint = accpoint
end

function FistFootSystem:addAccpoint(accpoint)
    self.__accpoint = self.__accpoint + accpoint
end

function FistFootSystem:getAccpoint()
    return self.__accpoint
end

function FistFootSystem:setFeelPoint(feelPoint)
    self.__feelPoint = feelPoint
end

function FistFootSystem:addFeelPoint(feelPoint)
    self.__feelPoint = self.__feelPoint + feelPoint
end

function FistFootSystem:getFeelPoint()
    return self.__feelPoint
end

function FistFootSystem:setCharacterPoint(point)
    self.__characterPoint = point
end

function FistFootSystem:addCharacterPoint(point)
    self.__characterPoint = self.__characterPoint + point
end

function FistFootSystem:getCharacterPoint()
    return self.__characterPoint
end

function FistFootSystem:setReflectExp(reflectExp)
    self.__reflectExp = reflectExp
end

function FistFootSystem:addReflectExp(addExp)
    self.__reflectExp = self.__reflectExp + addExp
end

function FistFootSystem:getReflectExp()
    return self.__reflectExp
end

--@desc: 获得特性资源配类
--@author:LvBin
--@time:2022-10-20 15:59:16
--@id:特性id
--@lv: 特性等级
--@return [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
function FistFootSystem:getFistFootEffect(id, lv)
    return FistFootResManager:getFistFootEffect(id, lv)
end

--@desc: 获得技巧资源类
--@author:LvBin
--@time:2022-10-10 18:26:33
--@id: 技巧id
--@lv: 技巧等级
--@return [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
function FistFootSystem:getBasicFistFootTechnique(id, lv)
    return FistFootResManager:getBasicFistFootTechnique(id, lv)
end

--@desc: 根据武学类型获取当前使用的特性
--@author:Seven
--@time:2022-10-17 15:26:43
--@branchType: 拳脚分支类型（即武学分类类型）
function FistFootSystem:getFistFootEffects(branchType)
    local list = {}

    self:__walkEffects(
        branchType,
        function(v)
            local e_id = v.characterId
            local t_id = v.techniqueId
            local lv
            self:__walkTechniqueByBranchType(
                branchType,
                function(t_info)
                    if tostring(t_info.id) == tostring(t_id) then
                        lv = t_info.lv
                        return true
                    end
                end
            )

            if lv == nil then
                assert(false, "FistFootSystem:getFistFootEffects : 未找到拳脚特性" .. e_id .. "对应的技巧信息id：" .. t_id)
            end

            local fistEffect = self:getFistFootEffect(e_id, lv)

            table.insert(list, fistEffect)
        end
    )

    return list
end

--@desc:
--@author:LvBin
--@time:2022-10-17 18:08:19
--@id:
--@return
function FistFootSystem:getTechnique(techniqueId)
    for k, v in pairs(self.__branchInfo) do
        local techniqueList = v.techniqueList
        if techniqueList[tostring(techniqueId)] then
            return techniqueList[tostring(techniqueId)]
        end
    end
    return nil
end

--@desc: 根据拳脚分支类型获取当前分支下技巧基础类
--@author:Seven
--@time:2022-10-18 17:06:30
--@b_type: 拳脚分支类型
--@return: list
function FistFootSystem:getBasicTechniqueByBranchType(b_type)
    local list = {}

    local branchInfo = self:__getBranchInfoDataByType(b_type)

    local t_data_list = branchInfo.techniqueList

    if not MapIsEmpty(t_data_list) then
        for _, v in pairs(t_data_list) do
            table.insert(list, self:getBasicFistFootTechnique(v.id, v.lv))
        end
    end

    return list
end

--@desc: 添加技巧
--@author:LvBin
--@time:2022-10-17 18:16:30
--@type:
--@techniqueId:
--@return
function FistFootSystem:addTechnique(type, techniqueId)
    local techniqueList = self:getTechniqueList(type)
    if techniqueList[tostring(techniqueId)] then
        print("技巧已存在，无法添加")
        return
    end

    techniqueList[tostring(techniqueId)] = {
        id = techniqueId,
        lv = 1,
        branchId = type
    }
end

--@desc: 获得技巧列表
--@author:LvBin
--@time:2022-10-10 18:24:42
--@type:
--@return
function FistFootSystem:getTechniqueList(type)
    return self.__branchInfo[tostring(type)].techniqueList
end

function FistFootSystem:getEffects(type)
    return self.__branchInfo[tostring(type)].effects
end

function FistFootSystem:getUnUseEffects(type)
    return self.__branchInfo[tostring(type)].unUseEffects
end

--@desc: 获得潜思等级
--@author:LvBin
--@time:2022-10-10 17:33:45
--@return
function FistFootSystem:getReflectLv()
    local lv = 0
    local exp = self:getReflectExp()
    local reflectLevelMap = FistFootResManager:getReflectLevelMap()
    for i, v in ipairs(reflectLevelMap) do
        if exp >= v.exp then
            lv = v.basislv
        end
    end
    return lv
end

--@desc: 获得潜思最大等级
--@author:LvBin
--@time:2022-10-10 17:38:43
--@return
function FistFootSystem:getReflectMaxLv()
    local reflectLevelMap = FistFootResManager:getReflectLevelMap()

    return reflectLevelMap[#reflectLevelMap].basislv
end

function FistFootSystem:getReflectData(lv)
    local reflectLevelMap = FistFootResManager:getReflectLevelMap()

    return assert(reflectLevelMap[lv], "---------FistFootSystem:getReflectData(lv)-----------潜思等级异常 lv = " .. lv)
end

function FistFootSystem:getBranchInfo()
    return self.__branchInfo
end

function FistFootSystem:setGuaJiInfo(guajiInfo)
    self.__guajiInfo = guajiInfo
end

--@desc: 获取挂机数据
--@author:LvBin
--@time:2022-09-18 16:00:07
--@return
function FistFootSystem:getGuaJiInfo()
    return self.__guajiInfo
end

--@desc: 获得分支经验
--@author:LvBin
--@time:2022-09-19 12:11:13
--@type:
--@return
function FistFootSystem:getBranchExp(type)
    return self.__branchInfo[tostring(type)].exp
end

--@desc: 添加分支经验
--@author:LvBin
--@time:2022-09-19 22:20:07
--@type:
--@exp:
--@return
function FistFootSystem:addBranchExp(type, exp)
    assert(self.__branchInfo[tostring(type)], "---------FistFootSystem:addBranchExp(type,exp)----------error type : " .. type)

    self.__branchInfo[tostring(type)].exp = self.__branchInfo[tostring(type)].exp + exp
end

--@desc: 添加消耗技巧感悟点数
--@author:LvBin
--@time:2022-10-24 10:08:05
--@branchType:
--@addCost:
--@return
function FistFootSystem:addCostTechnique(branchType, addCost)
    local branchInfo = self:__getBranchInfoDataByType(branchType)

    branchInfo.costTechnique = branchInfo.costTechnique + addCost
end

--@desc: 获得分支消耗技巧点数
--@author:LvBin
--@time:2022-09-19 15:34:10
--@type:
--@return
function FistFootSystem:getBranchCostTechnique(type)
    return self.__branchInfo[tostring(type)].costTechnique
end

--@desc: 获得拳脚分支等级
--@author:LvBin
--@time:2022-09-19 12:15:16
--@type:
--@return
function FistFootSystem:getBranchLv(type)
    local lv = 0
    local exp = self:getBranchExp(type)
    local branchMap = FistFootResManager:getBranchMap(type)
    for i, v in ipairs(branchMap) do
        if exp >= v.exp then
            lv = v.level
        end
    end
    return lv
end

--@desc: 获得技巧等级
--@author:LvBin
--@time:2022-10-10 16:26:57
--@techniqueId:
--@return
function FistFootSystem:getTechniqueLv(techniqueId)
    local technique = self:getTechnique(techniqueId)
    if technique then
        return technique.lv
    end

    return 0
end

--@desc: 获取技巧最大等级
--@author:LvBin
--@time:2022-10-17 23:00:35
--@techniqueId:
--@return
function FistFootSystem:getTechniqueMaxLv(techniqueId)
    local techniqueGroup = FistFootResManager:getTechniqueLevelGroup(tostring(techniqueId))

    return #techniqueGroup
end

--@desc: 获得分支武练值
--@author:LvBin
--@time:2022-09-19 15:09:36
--@type: 武学类型id
--@return
function FistFootSystem:getBranchDamage(type)
    local damage = 0
    local lv = self:getBranchLv(type)
    local branchMap = self:getBranchMap(type, lv)
    if branchMap then
        damage = self:getBranchMap(type, lv).damage
    end

    return damage
end

--@desc: 获得分支最大等级
--@author:LvBin
--@time:2022-09-19 14:53:17
--@type: 武学类型id
--@return
function FistFootSystem:getBranchMaxLv(type)
    local branchMap = FistFootResManager:getBranchMap(type)

    return branchMap[#branchMap].level
end

function FistFootSystem:getBranchMap(type, lv)
    local branchMap = FistFootResManager:getBranchMap(type)

    return branchMap[lv]
end

function FistFootSystem:getTaskMap()
    return FistFootResManager:getTaskMap()
end

function FistFootSystem:getTask(taskId)
    return self:getTaskMap()[tostring(taskId)]
end

function FistFootSystem:isGuaJi()
    return not MapIsEmpty(self.__guajiInfo)
end

function FistFootSystem:isCompleteGuaJi()
    local endTime = self.__guajiInfo.startTime + self:getTask(self.__guajiInfo.taskId).time * 3600 - self.__guajiInfo.speedUpTime
    if GetTime() > endTime then
        return true
    end
    return false
end

function FistFootSystem:refreshGamingTime()
    if not self:isGuaJi() then
        return
    end

    if self:isCompleteGuaJi() then
        local endTime = self.__guajiInfo.startTime + self:getTask(self.__guajiInfo.taskId).time * 3600 - self.__guajiInfo.speedUpTime
        if endTime > self.__player:getFlag("游戏时间") then
            self.__player:setGamingTime(endTime)
        end
    else
        self.__player:setGamingTime()
    end
end

--@desc: 开始修行
--@author:LvBin
--@time:2022-09-17 11:03:29
--@taskId:
--@callback:
--@return
function FistFootSystem:startFistTask(taskId, callback)
    self.__player:getServerActionSystem():startFistTask(
        taskId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                self.__guajiInfo = {}
                self.__guajiInfo.taskId = taskId
                self.__guajiInfo.startTime = data.startTime
                self.__guajiInfo.speedUpTime = 0

                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 中途停止修行
--@author:LvBin
--@time:2022-09-17 11:02:34
--@callback:
--@return
function FistFootSystem:stopFistTask(callback)
    self.__player:getServerActionSystem():stopFistTask(
        self.__guajiInfo.taskId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                self.__guajiInfo = {}

                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 加速修行
--@author:LvBin
--@time:2022-09-17 11:02:34
--@cost: 加速消耗资源数量
--@callback:
--@return
function FistFootSystem:speedUpFistTask(cost, callback)
    self.__player:getServerActionSystem():speedUpFistTask(
        self.__guajiInfo.taskId,
        cost,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                self.__accpoint = self.__accpoint - data.cost

                self.__guajiInfo.speedUpTime = self.__guajiInfo.speedUpTime + data.speedUpTime

                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 完成修行
--@author:LvBin
--@time:2022-09-17 11:02:34
--@bagEnough: 背包格子是否够 0不够 1够
--@callback:
--@return
function FistFootSystem:finishFistTask(bagEnough, callback)
    self.__player:getServerActionSystem():finishFistTask(
        self.__guajiInfo.taskId,
        bagEnough,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                self:getFistTaskReward(bagEnough, data.reward)

                self:setFeelPoint(data.feelPoint)

                self:__finishFistTaskExtraActionFunc(self.__guajiInfo.taskId)

                self.__guajiInfo = {}

                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc:
--@author:LvBin
--@time:2022-09-23 11:36:36
--@bagEnough: 背包格子是否够 0不够 1够
--@rewards: 奖励列表
--@return
function FistFootSystem:getFistTaskReward(bagEnough, rewards)
    if MapIsEmpty(rewards) then
        return
    end
    for i, v in ipairs(rewards) do
        if v[1] == FistFootConst.AwardType.Exp then
            self:addBranchExp(v[2], v[3])
        elseif v[1] == FistFootConst.AwardType.RefExp then
            self:addReflectExp(v[2])
        elseif v[1] == FistFootConst.AwardType.Item then
            if bagEnough == 1 then
                self.__player:addItemCount(v[2], v[3])
            end
        elseif v[1] == FistFootConst.AwardType.Net then
            if v[2] == "accpoint" then
                self:addAccpoint(v[3])
            elseif v[2] == "characterPoint" then
                self:addCharacterPoint(v[3])
            end
        end
    end
end

--@desc: 提升技巧
--@author:LvBin
--@time:2022-09-17 11:07:31
--@type: 武学类型id
--@techniqueId:
--@callback:
--@return
function FistFootSystem:upgradeTechnique(type, techniqueId, callback)
    self.__player:getServerActionSystem():upgradeTechnique(
        techniqueId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                local tech = self:getTechniqueByBranchTypeFromClassMap(type, techniqueId)

                if tech == nil then
                    self:__addTechniqueByBranchTypeToClassMap(type, PlayerFistFootTechnique:create(techniqueId, 1))
                else
                    tech:upgradeLevel(data.lv)
                end

                self:__updateBranchInfoFromTechniqueClass(type)

                self:setFeelPoint(data.feelPoint)

                self:addCostTechnique(type, data.cost)

                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 抽取特性
--@author:LvBin
--@time:2022-09-17 11:07:31
--@type: 武学类型id
--@techniqueId: 技巧id
--@isFirst: 是否是第一次领悟特性，第一次需要自动装备特性，否则备用
--@callback:
--@return
function FistFootSystem:extractCharacter(type, techniqueId, isFirst, callback)
    self.__player:getServerActionSystem():extractCharacter(
        techniqueId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                local p = self:getTechniqueByBranchTypeFromClassMap(type, techniqueId)
                if isFirst then
                    p:insertEffect(self:getFistFootEffect(data.characterInfo[tostring(techniqueId)].characterId, p:getLevel()))
                else
                    p:removeUnusedEffect(1)
                    p:insertUnusedEffect(self:getFistFootEffect(data.characterInfo[tostring(techniqueId)].characterId, p:getLevel()))
                end

                self:__updateBranchInfoFromTechniqueClass(type)

                self:setCharacterPoint(data.characterPoint)

                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

function FistFootSystem:__updateBranchInfoFromTechniqueClass(b_type)
    local branchInfo = self:__getBranchInfoDataByType(b_type)
    branchInfo.techniqueList = {}
    branchInfo.effects = {}
    branchInfo.unUseEffects = {}

    for k, v in pairs(branchInfo.techniqueClassMap) do
        --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
        local v = v

        local techniqueInfo, effectInfos, unUseEffects = v:serialization()

        branchInfo.techniqueList[tostring(techniqueInfo.id)] = techniqueInfo

        table.appendArray(branchInfo.effects, effectInfos)

        table.appendArray(branchInfo.unUseEffects, unUseEffects)
    end
end

--@desc: 替换特性
--@author:LvBin
--@time:2022-09-17 11:07:31
--@type: 武学类型
--@techniqueId: 技巧id
--@callback:
--@return
function FistFootSystem:replaceCharacter(b_type, techniqueId, callback)
    self.__player:getServerActionSystem():replaceCharacter(
        techniqueId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                local p = self:getTechniqueByBranchTypeFromClassMap(b_type, techniqueId)
                p:removeEffect(1)
                p:insertEffect(p:removeUnusedEffect(1))

                self:__updateBranchInfoFromTechniqueClass(b_type)

                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 重置天赋页数据
--@author:LvBin
--@time:2022-10-18 11:54:27
--@isCurrPage: 是否是当前装备的天赋页
--@talentPageId:
--@callback:
--@return
function FistFootSystem:resetTalentPage(isCurrPage, talentPageId, callback)
    self.__player:getServerActionSystem():resetTalentPage(
        talentPageId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                --只有重置当前天赋页才需要更新数据
                if isCurrPage then
                    self:setFeelPoint(data.feelPoint)

                    for branchType, v in pairs(data.branchInfo) do
                        self.__branchInfo[branchType].costTechnique = v.costTechnique

                        self.__branchInfo[branchType].techniqueList = v.techniqueList

                        self:__initTechniqueClassMap(branchType)

                        self:__initFistFootEffects(branchType, v.characterInUse)

                        self:__initFistFootUnuseEffects(branchType, v.characterUnused)
                    end
                end

                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--[[
    @desc: 获取天赋页信息
    author:{author}
    time:2022-10-13 16:43:47
    --@callback: 
    @return:
]]
function FistFootSystem:getTalentPageInfo(callback)
    self.__player:getServerActionSystem():getTalentPageInfo(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

function FistFootSystem:getTalentPageCount(callback, isRetry)
    self.__player:getServerActionSystem():getTalentPageCount(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end,
        isRetry
    )
end
--[[
    @desc: 获取特性池详情
    author:{author}
    time:2022-10-13 16:44:24
    --@poolId: 特性池id
	--@callback: 
    @return:
]]
function FistFootSystem:getCharacterPoolInfo(poolId, callback)
    self.__player:getServerActionSystem():getCharacterPoolInfo(
        poolId,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 更新拳脚系统标记
--@author:LvBin
--@time:2022-10-19 14:20:48
--@addFlags: 添加的标记数组
--@deleteFlags: 删除的标记数组
--@callback:
--@return
function FistFootSystem:updataFistFlag(addFlags, deleteFlags, callback)
    self.__player:getServerActionSystem():updataFistFlag(
        addFlags,
        deleteFlags,
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--[[
    @desc: 获取修行任务列表
    author:{author}
    time:2022-10-15 15:08:45
    --@callback: 
    @return:
]]
function FistFootSystem:getFistTasks(callback)
    self.__player:getServerActionSystem():getFistTasks(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(true, "", data)
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc: 根据拳脚分支类型遍历所有特性数据
--@author:Seven
--@time:2022-10-18 14:40:24
--@b_type: 拳脚分支类型
--@func: 遍历读取方法
function FistFootSystem:__walkEffects(b_type, func)
    local branchInfo = self:__getBranchInfoDataByType(b_type)
    local effects = branchInfo.effects
    for _, v in pairs(effects) do
        local isBreak = func(v)
        if isBreak then
            break
        end
    end
end

--@desc: 根据拳脚分支类型遍历未生效的特性数据
--@author:Seven
--@time:2022-10-18 14:40:24
--@b_type: 拳脚分支类型
--@func: 遍历读取方法
function FistFootSystem:__walkUnUseEffects(type, func)
    local branchInfo = self.__branchInfo[tostring(type)]
    if branchInfo == nil then
        assert(false, "FistFootSystem:__walkEffects 未知分支类型：" .. tostring(type))
    end
    local effects = branchInfo.unUseEffects
    for _, v in pairs(effects) do
        func(v)
    end
end

--@desc: 列表排序
--@author:Seven
--@time:2022-10-18 11:58:00
--@list: 特性列表
function FistFootSystem:___sortEffectList(list)
    table.sort(
        list,
        function(a, b)
            if tonumber(a.techniqueId) < tonumber(b.techniqueId) then
                return true
            end

            if tonumber(a.techniqueId) == tonumber(b.techniqueId) then
                if tonumber(a.characterId) < tonumber(b.characterId) then
                    return true
                end

                if tonumber(a.characterId) == tonumber(b.characterId) then
                    assert(false, "该列表内有特性id 和 技巧id都相同的特性")
                end

                return false
            end

            if tonumber(a.techniqueId) > tonumber(b.techniqueId) then
                return false
            end
        end
    )

    return list
end

--@desc: 根据分支和技巧ID获取特性列表
--@author:Seven
--@time:2022-10-18 11:35:54
--@branchType: 分支ID
--@techniqueId: 技巧ID
--@return:
function FistFootSystem:__getEffectByBranchAndTechnique(branchType, techniqueId)
    local list = {}
    self:__walkEffects(
        branchType,
        function(effectInfo)
            if tostring(effectInfo.techniqueId) == tostring(techniqueId) then
                table.insert(list, effectInfo)
            end
        end
    )

    list = self:___sortEffectList(list)

    return list
end

function FistFootSystem:__getUnusedEffectByBranchAndTechnique(branchType, techniqueId)
    local list = {}
    self:__walkUnUseEffects(
        branchType,
        function(effectInfo)
            if tostring(effectInfo.techniqueId) == tostring(techniqueId) then
                table.insert(list, effectInfo)
            end
        end
    )

    list = self:___sortEffectList(list)

    return list
end

function FistFootSystem:__getBranchInfoDataByType(branchType)
    local branchInfo = self.__branchInfo[tostring(branchType)]
    if branchInfo == nil then
        assert(false, "FistFootSystem:__getBranchInfoDataByType 未知分支类型：" .. tostring(branchType))
    end

    return branchInfo
end

function FistFootSystem:__walkTechniqueByBranchType(branchType, func)
    local branchInfo = self:__getBranchInfoDataByType(branchType)

    local list = branchInfo.techniqueList

    if not MapIsEmpty(list) then
        for t_id, t_info in pairs(list) do
            local isBreak = func(t_info)

            if isBreak then
                break
            end
        end
    end
end

--@desc:
--@author:Seven
--@time:2022-10-18 20:03:42
--@b_type: 拳脚分支类型
--@t_id: 技巧id
--@return: [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
function FistFootSystem:getTechniqueByBranchTypeFromClassMap(b_type, t_id)
    local branchInfo = self:__getBranchInfoDataByType(b_type)
    local t_class = branchInfo.techniqueClassMap[tostring(t_id)]
    return t_class
end

function FistFootSystem:getTechniquesByTypeFromClassMap(b_type)
    local branchInfo = self:__getBranchInfoDataByType(b_type)

    local list = table.mapToArray(branchInfo.techniqueClassMap)

    table.sort(
        list,
        function(a, b)
            if tonumber(a:getId()) < tonumber(b:getId()) then
                return true
            end

            return false
        end
    )

    return list
end

--@desc: 获取分支谙技值
--@author:LvBin
--@time:2025-02-25 11:35:20
--@b_type: 分支id
--@return
function FistFootSystem:getBranchJqdamage(b_type)
    local branchJqdamage = 0

    local techniques = self:getTechniquesByTypeFromClassMap(b_type)

    for i, technique in ipairs(techniques) do
        branchJqdamage = branchJqdamage + technique:getJqdamage()
    end

    return branchJqdamage
end

--@desc:
--@author:Seven
--@time:2022-10-19 11:13:32
--@b_type: 拳脚分支类型
--@techClass: [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
function FistFootSystem:__addTechniqueByBranchTypeToClassMap(b_type, techClass)
    local branchInfo = self:__getBranchInfoDataByType(b_type)

    branchInfo.techniqueClassMap[techClass:getTechniqueId()] = techClass
end

function FistFootSystem:repairFistFootFlag(callback)
    if self:getPlayer():getInheritFlag("repairFistFootFlag") ~= 0 then
        callback(true, "")
        return
    end

    local flagList = {
        "1001002k",
        "1001003k",
        "1002002k",
        "1002003k",
        "1003002k",
        "1003003k",
        "1004002k",
        "1004003k",
        "1005002k",
        "1005003k",
        "1001003llk",
        "1002003llk",
        "1003003llk",
        "1004003llk",
        "1005003llk"
    }

    local flags = {}

    for index, flagId in ipairs(flagList) do
        if self:getPlayer():getInheritFlag(flagId) ~= 0 then
            table.insert(flags, flagId)
        end
    end

    if not MapIsEmpty(flags) then
        self:updataFistFlag(
            flags,
            {},
            function(isOk, msg)
                callback(isOk, msg)

                if isOk then
                    for index, flagId in ipairs(flags) do
                        self:getPlayer():setInheritFlag(flagId, nil)
                    end

                    self:getPlayer():setInheritFlag("repairFistFootFlag", 1)
                end
            end
        )
    else
        callback(true, "")

        self:getPlayer():setInheritFlag("repairFistFootFlag", 1)
    end
end

function FistFootSystem:getCodeVersion()
    return self.__codeVersion
end

--@desc: 完成拳脚修行任务需要刷新限时历练活动状态
--@author:LvBin
--@time:2022-10-28 16:58:11
--@return
function FistFootSystem:__finishFistTaskExtraActionFunc(taskId)
    local task = self:getTask(taskId)

    local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

    if
        task.type == FistFootConst.TaskType.Quan or task.type == FistFootConst.TaskType.Zhang or task.type == FistFootConst.TaskType.Zhua or task.type == FistFootConst.TaskType.Tui or
            task.type == FistFootConst.TaskType.Zhi
     then
        if LimitedTimeExperience:checkTaskIsOpen("qjduantixiuxing") then
            LimitedTimeExperience:setRole(self:getPlayer())
            LimitedTimeExperience:finishTaskByTaskType("qjduantixiuxing")
        end
    elseif task.type == FistFootConst.TaskType.Character then
        if LimitedTimeExperience:checkTaskIsOpen("qjjiqiaoxiuxing") then
            LimitedTimeExperience:setRole(self:getPlayer())
            LimitedTimeExperience:finishTaskByTaskType("qjjiqiaoxiuxing")
        end
    end
end

--@desc: 切换技法心得
--@author:Seven
--@time:2023-01-07 16:27:22
--@pageNum: 页数
function FistFootSystem:changeTelentPage(pageNum, callback)
    if pageNum <= 0 then
        error("FistFootSystem:changeTelentPage ：pageNum 不可小于0")
    end
    self.__player:getServerActionSystem():changeTelentPage(
        pageNum,
        self:getCodeVersion(),
        function(isOk, data, errcode, errmsg)
            if isOk then
                if MapIsEmpty(data.branchInfo) or data.feelPoint == nil then
                    error("返回数据错误，请联系服务器")
                end
                self:__initTelentPageData(
                    {
                        feelPoint = data.feelPoint,
                        branchInfo = data.branchInfo
                    }
                )
            else
                print("FistFootSystem:changeTelentPage 切换失败:", tostring(errcode), errmsg)
            end
            callback(isOk, errmsg)
        end
    )
end

function FistFootSystem:serializationForPVP()
    local branchInfo = {}
    for branchId, info in pairs(self.__branchInfo) do
        local serializationData = {}

        serializationData.exp = info.exp

        serializationData.costTechnique = info.costTechnique

        serializationData.techniqueList = {}

        serializationData.characterInUse = {}

        serializationData.unUseEffects = {}

        for k, v in pairs(info.techniqueClassMap) do
            --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
            local v = v

            local techniqueInfo, effectInfos, unUseEffects = v:serialization()

            serializationData.techniqueList[tostring(techniqueInfo.id)] = techniqueInfo

            table.appendArray(serializationData.characterInUse, effectInfos)

            table.appendArray(serializationData.unUseEffects, unUseEffects)
        end

        branchInfo[branchId] = serializationData
    end

    return {
        reflectExp = self:getReflectExp(),
        branchInfo = branchInfo
    }
end

function FistFootSystem:initFromPVPData(data)
    self:__initBranchInfo(data.branchInfo)

    self:setReflectExp(data.reflectExp)
end

return newClass("FistFootSystem", {}, FistFootSystem)
00000000000
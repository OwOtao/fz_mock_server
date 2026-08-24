local class = require("third.class.NewClass")
local GameConst = require("app.models.game.GameConst")
local departFromFamilyAnimConfig = require("script.family.departFromFamilyAnimConfig")["Sheet1"]
local departFromFamilyCondition = require("script.family.departFromFamilyCondition")["1"]
local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local DepartFromFamily = {}

function DepartFromFamily:create()
    return DepartFromFamily:new()
end

function DepartFromFamily:ctor()
end

function DepartFromFamily:setRole(role)
    self._role = role
end

function DepartFromFamily:checkRoleCanStartLeaveTask()
    local configs = self:__getStartTaskConditions()

    local conditionsText = ""
    local failureText = ""
    local isTrue = true
    for attr, value in pairs(configs) do
        if attr == "unionleave" then
            local sectLv = self._role:getTeacherBuildSystem():getSectLv()
            conditionsText = conditionsText .. "师门等级" .. value .. "、"
            if sectLv < value then
                failureText = "师门等级不足"
                isTrue = false
            end
        elseif attr == "sgbpoint" then
            local sgbpoint = self._role:getTeacherBuildSystem():getSgbpoint()
            local name = self._role:getTeacherBuildSystem():getSgbpointName()
            conditionsText = conditionsText .. name .. value .. "、"
            if sgbpoint < value then
                failureText = name .. "不足"
                isTrue = false
            end
        end
    end

    conditionsText = string.sub(conditionsText, 1, -4)

    return isTrue, conditionsText, failureText
end

function DepartFromFamily:checkRoleStartLeaveTask()
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
    return self._role:getFlag(flag) == 1
end

function DepartFromFamily:checkRoleCanLeave()
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
    if self._role:getFlag(flag) < 2 then
        return false, "请调查祸乱云谷后再返回本门。"
    else
        return true
    end
end

function DepartFromFamily:startLeaveTask()
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
    self._role:setFlag(flag, 1)
    PopText("开始叛师剧情任务")
end

function DepartFromFamily:endLeaveTask()
end

function DepartFromFamily:getLeaveAnim()
    local animMap = {}
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
    local value = self._role:getFlag(flag)

    if value <= 1 then
        PopText("请调查祸乱云谷后再返回本门。")
        return
    end

    for k, v in pairs(departFromFamilyAnimConfig) do
        local config = v.flag
        if config[1] == flag and config[2] == value then
            local info = {}
            info.text = v.text
            info.index = v.index
            info.duration = v.time
            table.insert(animMap, info)
        end
    end

    if MapIsEmpty(animMap) then
        PopText("叛师任务结局标记值异常，值： " .. tostring(value))
        return
    end

    table.sort(
        animMap,
        function(a, b)
            return a.index < b.index
        end
    )

    return animMap
end

function DepartFromFamily:departFromFamily(func)
    local familyId = self._role:getFamilyId()
    local newFamilyId = GameConst:getDefaultValue("seclusion_family_id")

    HttpManagerEx:uploadUserData(
        "shangchuan",
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 and errcode == 0 then
                HttpManagerEx:TransferHomegateGroup(
                    familyId,
                    newFamilyId,
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            if data.transferSign then
                                self._role:setAttr("departFromFamilySign", data.transferSign)
                                self:dealWihtLocalData()

                                if func then
                                    func()
                                end
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function DepartFromFamily:dealWihtLocalData()
    self:__clearRoleTeacherBuild()
    self:__deleteFamilySkill()
    self:__clearPrepareSkill()
    self:__changeFamily()
    self:__clearTeacherGuaJiTask()
    self:__clearRankData()
    self:__deleteTeacherTrainingTitle()
    self:__clearTaskFlag()
    self:__updateHiddenMeridian()
end

function DepartFromFamily:__getStartTaskConditions()
    local configs = {}

    local function getConditionValueMap(condition)
        local valueMap = {}

        for k, v in pairs(condition) do
            valueMap[v[1]] = v[2]
        end

        return valueMap
    end

    local baseConditionValueMap, addConditionValueMap, reduceConditionValueMap
    local familyEffectId = self._role:getTeacherBuildSystem():getTransferFamilyEffectId()
    local transferId = self._role:getTeacherBuildSystem():getTransferSelfEffectId()
    print("建筑等级：", familyEffectId, "名位等级：", transferId)

    for k, v in pairs(departFromFamilyCondition) do
        if transferId == v.functionId then
            reduceConditionValueMap = getConditionValueMap(v.reduceCondition)
        end
        if familyEffectId == v.functionId then
            baseConditionValueMap = getConditionValueMap(v.condition)
            addConditionValueMap = getConditionValueMap(v.promoteCondition)
        end
    end

    for attr, value in pairs(baseConditionValueMap) do
        configs[attr] = value + addConditionValueMap[attr] - reduceConditionValueMap[attr]
    end

    return configs
end

function DepartFromFamily:__deleteFamilySkill()
    local familyId = self._role:getFamilyId()

    local skills = self._role:getSkills()

    local removeSkills = {}

    for skillId, v in pairs(skills) do
        local skill = Skill:getSkill(skillId)
        if skill.type == SKILL_TYPE_SPECIAL then
            table.insert(removeSkills, skillId)
        end
    end

    if MapIsEmpty(removeSkills) == false then
        for i, skillId in ipairs(removeSkills) do
            self._role:removeSkill(skillId)
        end
    end
end

function DepartFromFamily:__clearPrepareSkill()
    self._role:clearPrepareSkills()
    --重新刷新精力最大值
    self._role:setJingMax()
end

function DepartFromFamily:__changeFamily()
    self._role:setAttr("family", {name = "seclusion"})
    self._role:setAttr("teacherName", nil)
    self._role:setAttr("teacherId", nil)
end

function DepartFromFamily:__clearRoleTeacherBuild()
    self._role:resetTeacherBuildSystemData(nil)
end

function DepartFromFamily:__clearTeacherGuaJiTask()
    self._role:setAttr("teacherGuaJiTaskCount", {})
    self._role:setAttr("teacherGuaJiTask", {})
end

function DepartFromFamily:__clearRankData()
    DataBase:setLuaTable("rankingData", {})
end

function DepartFromFamily:__clearTaskFlag()
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
    self._role:setFlag(flag, nil)
end

function DepartFromFamily:__deleteTeacherTrainingTitle()
    local needDeleteTitleIds = string.split(GameConst:getConfigValue("departFromFamily_deleteTitles"), ";")

    for i = 1, #needDeleteTitleIds, 1 do
        local titleId = needDeleteTitleIds[i]

        if self._role:hasBasicTitle(titleId) then
            self._role:deleteBasicTitle(titleId)
        end
    end
end

--@desc: 修复判师回档异常
--@author:LvBin
--@time:2023-11-04 16:05:05
--@return
function DepartFromFamily:repairDepartFromFamilyError()
    local AsyncFunction = require("third.async.AsyncFunction")

    if self._role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
        local lianGongSystem = self._role:getLianGongSystem()
        local ok, msg = AsyncFunction:asyncAwaitWithCallback(lianGongSystem.stopLianGongOnline, lianGongSystem, "callback")
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
        local xiuLianSystem = self._role:getXiuLianSystem()
        local ok, msg = AsyncFunction:asyncAwaitWithCallback(xiuLianSystem.stopXiuLianOnline, xiuLianSystem, "callback")
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        self._role:stopBiGuan()
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        self._role:stopDaZuo()
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
        self._role:stopTeacherGuaJiTask()
    end

    self:dealWihtLocalData()
end

function DepartFromFamily:repairDepartFromFamilyData()
    if self._role:checkRoleisSeclusion() then
        self._role:setAttr("family", {name = "seclusion"})
        self._role:setAttr("isSeclusion", nil)
    end
end

function DepartFromFamily:__updateHiddenMeridian()
    self._role:getHiddenMeridianSystem():deleteHMBuffByNodal(HiddenMeridianConstants.DeleteBuffNodal.DEPARTFROMFAMILY)
end

return class("DepartFromFamily", {}, DepartFromFamily)
00
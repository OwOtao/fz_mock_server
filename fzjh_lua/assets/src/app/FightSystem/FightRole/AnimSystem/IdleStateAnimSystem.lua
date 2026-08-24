--[[
    author:Seven
    time:2023-02-10 10:11:52
    desc: 角色静态动画管理系统


]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local IdleStateAnimSystem = {}

function IdleStateAnimSystem:create()
    return IdleStateAnimSystem.new()
end

function IdleStateAnimSystem:onInit()
    self.__idleAnimList = {}
    self.__infoIdIndex = 5000
end

--@desc: 添加站立动画相关对象
--@author:Seven
--@time:2023-02-10 10:49:52
--@animStateInfo: [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
--@return 添加动画信息的id
function IdleStateAnimSystem:addIdleAnim(animStateInfo)
    self:__addAnimStateInfo(animStateInfo)

    animStateInfo:setId(self:__getNewAnimStateInfoId())

    self:__sortList()

    FightUtil:printFormatLog("IdleStateAnimSystem:addIdleAnim - %s 获得待机状态动画：%s", self.__character:getAttr("name"), animStateInfo:getAnimId())

    return animStateInfo:getId()
end

function IdleStateAnimSystem:__sortList()
    if table.getn(self.__idleAnimList) <= 0 then
        return
    end

    table.sort(
        self.__idleAnimList,
        function(animInfo1, animInfo2)
            return animInfo1:getPriority() > animInfo2:getPriority()
        end
    )
end

--@desc: 移除待机状态动画信息
--@author:Seven
--@time:2023-02-10 20:46:42
--@id: 待机状态id
--@return [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
function IdleStateAnimSystem:removeIdleAnim(id)
    local removeIndex
    local removeAnimInfo
    self:__walkAnimList(
        function(index, animInfo)
            if animInfo:getId() == id then
                removeAnimInfo = animInfo
                removeIndex = index
                return true
            end
        end
    )

    if removeIndex == nil then
        error("IdleStateAnimSystem:removeIdleAnim ，移除失败，id 无匹配：" .. tostring(id))
    end

    table.remove(self.__idleAnimList, removeIndex)

    FightUtil:printFormatLog("IdleStateAnimSystem:removeIdleAnim - %s 移除待机状态动画：%s , 索引：%s", self.__character:getAttr("name"), removeAnimInfo:getAnimId(), tostring(removeIndex))

    return removeAnimInfo
end

function IdleStateAnimSystem:__walkAnimList(func)
    if table.getn(self.__idleAnimList) <= 0 then
        return
    end

    for i, v in ipairs(self.__idleAnimList) do
        if func(i, v) == true then
            break
        end
    end
end

function IdleStateAnimSystem:__getNewAnimStateInfoId()
    self.__infoIdIndex = self.__infoIdIndex + 1
    return self.__infoIdIndex
end

function IdleStateAnimSystem:__addAnimStateInfo(animStateInfo)
    table.insert(self.__idleAnimList, animStateInfo)
end

function IdleStateAnimSystem:__getDefaultAnimId()
    return self.__character:getAttackSkill():getBattleIdleAnim()
end

function IdleStateAnimSystem:getIdleAnimId()
    if table.getn(self.__idleAnimList) <= 0 then
        return self:__getDefaultAnimId()
    end

    --@RefType [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
    local animInfo = self.__idleAnimList[1]

    return animInfo:getAnimId()
end

function IdleStateAnimSystem:onDestory()
end

function IdleStateAnimSystem:onUpdate(ft)
end

return newClass("IdleStateAnimSystem", {ABasicCharacterFuncSystem}, IdleStateAnimSystem)
0000000000000
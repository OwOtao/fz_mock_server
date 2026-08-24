--[[
    author:Seven
    time:2023-02-10 20:45:43
    desc: 角色脚底动画系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local BottomOfFootAnimSystem = {}

function BottomOfFootAnimSystem:create()
    return BottomOfFootAnimSystem.new()
end

function BottomOfFootAnimSystem:onInit()
    self.__bottomHaloAnimList = {}
    self.__infoIdIndex = 4000
end

--@desc: 添加脚底光环动画
--@author:Seven
--@time:2023-02-10 20:49:52
--@animStateInfo: [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
--@return 添加动画信息的id
function BottomOfFootAnimSystem:addHaloAnim(animStateInfo)
    self:__addHaloAnimStateInfo(animStateInfo)

    animStateInfo:setId(self:__getNewAnimStateInfoId())

    self:__sortList()

    FightUtil:printFormatLog(
        "BottomOfFootAnimSystem:addHaloAnim %s 添加脚底光环动画，id：%s，动画id：%s,优先级：%d",
        self.__character:getAttr("name"),
        animStateInfo:getId(),
        animStateInfo:getAnimId(),
        animStateInfo:getPriority()
    )

    return animStateInfo:getId()
end

function BottomOfFootAnimSystem:__sortList()
    if table.getn(self.__bottomHaloAnimList) <= 0 then
        return
    end

    table.sort(
        self.__bottomHaloAnimList,
        function(animInfo1, animInfo2)
            return animInfo1:getPriority() > animInfo2:getPriority()
        end
    )
end

--@desc: 移除脚部光环动画信息
--@author:Seven
--@time:2023-02-10 20:46:42
--@id: 光环动画对象id
--@return [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
function BottomOfFootAnimSystem:removeHaloAnim(id)
    local removeIndex
    local removeAnimInfo
    self:__walkHaloAnimList(
        function(index, animInfo)
            if animInfo:getId() == id then
                removeAnimInfo = animInfo
                removeIndex = index
                return true
            end
        end
    )

    if removeIndex == nil then
        error("BottomOfFootAnimSystem:removeHaloAnim ，移除失败，id 无匹配：" .. tostring(id))
    end

    FightUtil:printFormatLog(
        "BottomOfFootAnimSystem:removeHaloAnim %s 移除脚底光环动画，id：%s，动画id：%s,优先级：%s",
        self.__character:getAttr("name"),
        removeAnimInfo:getId(),
        removeAnimInfo:getAnimId(),
        removeAnimInfo:getPriority()
    )
    
    table.remove(self.__bottomHaloAnimList, removeIndex)

    return removeAnimInfo
end

function BottomOfFootAnimSystem:__walkHaloAnimList(func)
    if table.getn(self.__bottomHaloAnimList) <= 0 then
        return
    end

    for i, v in ipairs(self.__bottomHaloAnimList) do
        if func(i, v) == true then
            break
        end
    end
end

function BottomOfFootAnimSystem:__getNewAnimStateInfoId()
    self.__infoIdIndex = self.__infoIdIndex + 1
    return self.__infoIdIndex
end

function BottomOfFootAnimSystem:__addHaloAnimStateInfo(animStateInfo)
    table.insert(self.__bottomHaloAnimList, animStateInfo)
end

--@desc: 获取脚底光环动画id
--@author:Seven
--@time:2023-02-10 20:50:56
--@return: 动画id
function BottomOfFootAnimSystem:getHaloAnimId()
    --@RefType [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
    local animInfo = self.__bottomHaloAnimList[1]

    if animInfo ~= nil then
        return animInfo:getAnimId()
    end

    return nil
end

function BottomOfFootAnimSystem:onDestory()
end

function BottomOfFootAnimSystem:onUpdate(ft)
end

return newClass("BottomOfFootAnimSystem", {ABasicCharacterFuncSystem}, BottomOfFootAnimSystem)
00000000000
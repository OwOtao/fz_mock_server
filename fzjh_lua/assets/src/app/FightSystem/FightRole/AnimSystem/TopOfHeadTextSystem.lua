--[[
    author:Seven
    time:2023-02-10 21:13:07
    desc: 角色头顶显示信息
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local TopOfHeadTextSystem = {}

function TopOfHeadTextSystem:create()
    return TopOfHeadTextSystem.new()
end

function TopOfHeadTextSystem:onInit()
    self.__topTextList = {}
    self.__infoIdIndex = 3000
end

--@desc: 添加头部文字状态
--@author:Seven
--@time:2023-02-10 20:49:52
--@textStateInfo: [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
--@return 添加动画信息的id
function TopOfHeadTextSystem:addText(textStateInfo)
    self:__addTextStateInfo(textStateInfo)

    textStateInfo:setId(self:__getNewStateInfoId())

    self:__sortList()

    FightUtil:printFormatLog("TopOfHeadTextSystem:addText - %s 获得头顶状态文本：%s，优先级：%s", self.__character:getAttr("name"), textStateInfo:getText(), textStateInfo:getPriority())

    return textStateInfo:getId()
end

function TopOfHeadTextSystem:__sortList()
    if table.getn(self.__topTextList) <= 0 then
        return
    end

    table.sort(
        self.__topTextList,
        function(textInfo1, textInfo2)
            return textInfo1:getPriority() > textInfo2:getPriority()
        end
    )
end

--@desc: 移除头部文字
--@author:Seven
--@time:2023-02-10 20:46:42
--@id: 待机状态id
--@return [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
function TopOfHeadTextSystem:removeText(id)
    local removeIndex
    local removeTextInfo
    self:__walkTextList(
        function(index, animInfo)
            if animInfo:getId() == id then
                removeTextInfo = animInfo
                removeIndex = index
                return true
            end
        end
    )

    if removeIndex == nil then
        error("TopOfHeadTextSystem:removeText ，移除失败，id 无匹配：" .. tostring(id))
    end

    table.remove(self.__topTextList, removeIndex)
    FightUtil:printFormatLog("TopOfHeadTextSystem:removeText - %s 移除头顶状态文本：%s，优先级：%s", self.__character:getAttr("name"), removeTextInfo:getText(), removeTextInfo:getPriority())
    return removeTextInfo
end

function TopOfHeadTextSystem:__walkTextList(func)
    if table.getn(self.__topTextList) <= 0 then
        return
    end

    for i, v in ipairs(self.__topTextList) do
        if func(i, v) == true then
            break
        end
    end
end

function TopOfHeadTextSystem:__getNewStateInfoId()
    self.__infoIdIndex = self.__infoIdIndex + 1
    return self.__infoIdIndex
end

function TopOfHeadTextSystem:__addTextStateInfo(textStateInfo)
    table.insert(self.__topTextList, textStateInfo)
end

--@desc: 获取角色头部挂载文本信息
--@author:Seven
--@time:2023-02-10 20:50:56
--@return: 文本
function TopOfHeadTextSystem:getTopText()
    --@RefType [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
    local textInfo = self.__topTextList[1]

    if textInfo ~= nil then
        return textInfo:getText()
    end

    return ""
end

function TopOfHeadTextSystem:onDestory()
end

function TopOfHeadTextSystem:onUpdate(ft)
end

return newClass("TopOfHeadTextSystem", {ABasicCharacterFuncSystem}, TopOfHeadTextSystem)
0000000000
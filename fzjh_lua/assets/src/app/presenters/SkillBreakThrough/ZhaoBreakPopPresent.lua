local ZhaoBreakPopPresent = class("ZhaoBreakPopPresent", cc.Layer)

local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

function ZhaoBreakPopPresent:create()
    local p = ZhaoBreakPopPresent:new()
    p:init()
    return p
end

function ZhaoBreakPopPresent:init()
    self._UI = require("app.views.ui.SkillUI.ZhaoBreakPopUI"):create()
    self._UI:addTo(self)
end


function ZhaoBreakPopPresent:showLayer()
    self:showPanelTip()

    self._UI:showUI()
end

function ZhaoBreakPopPresent:setZhao(zhao)
	self.__zhao = zhao
end

function ZhaoBreakPopPresent:setRole(role)
	self.__role = role
end

function ZhaoBreakPopPresent:setCallBack(func)
	self.__callBack = func
end

function ZhaoBreakPopPresent:showPanelTip()
    local retData = {
        needItem1 = "",
        needItem2 = "",
        needItem3 = "",
        needItem4 = "",
    }
    
    retData["title"] = "技能突破"
    retData["name"] = self.__zhao.name
    retData["desc"] = "是否对以下主动技能进行突破？"
    retData["int"] = "当前悟性："..self.__role:getFinalAttr("currInt")
    
    local currZhaoLvLimit = self.__role:getZhaoLvLimit(self.__zhao.id)

    local currExpLimit = self.__role:getZhaoExpLimit(self.__zhao.id,currZhaoLvLimit)
    
    local nextZhaoLvLimit = currZhaoLvLimit + 1
    
    local nextExpLimit = self.__role:getZhaoExpLimit(self.__zhao.id,nextZhaoLvLimit) 

    local nextBreData = self.__role:getSkillBreakThroughSystem():getZhaoBreDataByZhaoIdAndZhaoLv(self.__zhao.id,nextZhaoLvLimit)

    retData["expNum"] = currExpLimit.."->"..nextExpLimit
    retData["bLevelNum"] = currZhaoLvLimit.."重->"..nextZhaoLvLimit.."重"

    local skillId = Skill:getSkillIdByZhaoId(self.__zhao.id)
    local skillLv = self.__role:getSkillLv(skillId)
    local skillName = Skill:getSkill(skillId)._NoColorName
    local skillNeedLv = nextBreData.skill
    
    retData["skillLv"] = skillName.."需要达到"..skillNeedLv.."级"
    retData["addExpTip"] = "知识类武学-溯源诀可略微提升特殊招式的上限熟练度"
    
    for i,v in ipairs(nextBreData.reitem) do
        retData["needItem"..i] = "所需".. SkillBreakThroughResManager:getBreakThroughItem(v[1]).name.."："..v[2]
    end

    retData["button1Name"] = "确定"
    retData["button1Func"] = function()
        if skillLv < skillNeedLv then
            PopText("突破所需武学等级不足，突破失败")
            return
        end
        self.__role:getSkillBreakThroughSystem():zhaoBreakThrough(self.__zhao.id,function(result,arg)
            if result == true then
                local reitem_list = arg.reitem_list

                if self.__callBack then
                    self.__callBack(true,reitem_list)
                end

                self:hideLayer()

                PopText("突破"..self.__zhao.name.."成功")
            else
                local errorMsg = arg
                PopText(errorMsg)

                -- if self.__callBack then
                --     self.__callBack(false,errorMsg)
                -- end
            end
            
        end)
    end
    retData["button2Name"] = "取消"
    retData["button2Func"] = function()
        self:hideLayer()
    end

    self._UI:showPanelTip(retData)
end

function ZhaoBreakPopPresent:hideLayer()
    PopupLayerController:hideLayer(
        "ZhaoBreakPopPresent",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ZhaoBreakPopPresent)
return ZhaoBreakPopPresent
00000000
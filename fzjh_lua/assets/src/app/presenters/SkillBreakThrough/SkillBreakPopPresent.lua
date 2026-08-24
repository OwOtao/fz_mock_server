local SkillBreakPopPresent = class("SkillBreakPopPresent", cc.Layer)

function SkillBreakPopPresent:create()
    local p = SkillBreakPopPresent:new()
    p:init()
    return p
end

function SkillBreakPopPresent:init()
    self._UI = require("app.views.ui.SkillUI.SkillBreakPopUI"):create()
    self._UI:addTo(self)
end


function SkillBreakPopPresent:showLayer()
    self:showPanelTip()

    self._UI:showUI()
end

function SkillBreakPopPresent:setSkill(skill)
	self.__skill = skill
end

function SkillBreakPopPresent:setRole(role)
	self.__role = role
end

function SkillBreakPopPresent:setCallBack(func)
	self.__callBack = func
end

function SkillBreakPopPresent:showPanelTip()
    local breMap = self.__role:getSkillBreakThroughSystem():getSkillBreakThroughMap(self.__skill.id)
    local currLevel = breMap.class
    local nextBreMap = self.__role:getSkillBreakThroughSystem():getSkillBreakThroughMapByLevel(currLevel + 1)
    local retData = {
        needWxxd1 = "",
        needWxxd2 = "",
        needWxxd3 = "",
        needItem1 = "",
        needItem2 = "",
        needItem3 = "",
        needItem4 = "",
    }

    for i,v in ipairs(nextBreMap.resource) do
        retData["needWxxd"..i] = "所需".. self.__role:getCHAttrName(v[1]).."："..v[2]
    end

    if MapIsEmpty(nextBreMap.reitem) then
        retData["needItemTitle"] = ""
        retData["button1PosY"] = 847
        retData["button2PosY"] = 671
    else
        for i,v in ipairs(nextBreMap.reitem) do
            retData["needItem"..i] = Item:getOneItemByKey(v[1]).name.."*"..v[2]
        end

        retData["needItemTitle"] = "所需道具："
        retData["button1PosY"] = 647
        retData["button2PosY"] = 471
    end
    
    
    retData["title"] = "武学突破"
    retData["name"] = self.__skill.name
    retData["desc"] = "是否消耗对应资源，对以下武学进行突破？"
    retData["bLevelNum"] = breMap.Blevel.."级->"..nextBreMap.Blevel.."级"
    retData["button1Name"] = "确定"
    retData["button1Func"] = function()
        local reitem = nextBreMap.reitem
        for i, v in ipairs(reitem) do
            local itemId = v[1]
            local count = tonumber(v[2])
            local itemName = Item:getOneItemByKey(itemId).name
            local roleCount = self.__role:getItemCount(itemId)
            if roleCount < count then
                PopText("突破所需"..itemName.."不足，突破失败")
                return
            end
        end
        self.__role:getSkillBreakThroughSystem():skillBreakThrough(self.__skill.id,function(result,arg)
            if result == true then
                local currency_list = arg.currency_list

                if self.__callBack then
                    self.__callBack(true,currency_list)
                end

                self:hideLayer()

                PopText("突破"..self.__skill.name.."成功")
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

function SkillBreakPopPresent:hideLayer()
    PopupLayerController:hideLayer(
        "SkillBreakPopPresent",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(SkillBreakPopPresent)
return SkillBreakPopPresent
000000000000
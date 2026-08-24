--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local HeroFeastModule = class("HeroFeastModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local HeroFeastModel = require("app.models.Action.HeroFeast.HeroFeastModel")
local CRFactory = require("app.models.HomelandModel.CRFactory")
--@desc 开启状态，默认开启
HeroFeastModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
HeroFeastModule.activityTime = 0

HeroFeastModule.doResult = {
    ["举办宴席"] = function (map, result, environment)
        if HeroFeastModel:checkIsActivityTime() == false then
            PopText("已经过了举办宴席的时间！")
            return
        end
        local role = User:getRole()
        local flagTab = role:getInheritFlag("2021英雄宴奖励")
        if type(flagTab) == "table" then
            local dayNum = HeroFeastModel:calCurrHeroFeastTimes()
            if flagTab[dayNum] then
                PopText("今日已经举办过宴席了")
                return 
            end
        end
        PopupLayerController:showLayer("PrepareHeroFeastLayer",function(layer)
            layer:showLayer()
        end)
    end
}

function HeroFeastModule:entryMap(map, currTime)
    if map:getMapType() ~= MAP_TYPE.MYHOME then
        return
    end

    self:initGuanJiaConditionAndResults(map)
end

function HeroFeastModule:initGuanJiaConditionAndResults(map)
    -- 活动时间开启
    if HeroFeastModel:checkIsActivityTime() == true then
    else
        return
    end
    if HomelandRoleUtil:currMapHaveGj(map) == true then
        local guanjia = map:getRole("guanjia1001")
        if guanjia then
            CRFactory:createBtnCR(guanjia, "举办宴席", "举办宴席")
            CRFactory:openOrCloseBtnFunc(guanjia, "举办宴席", "open")
        end
    end
end


return HeroFeastModule
00000000000
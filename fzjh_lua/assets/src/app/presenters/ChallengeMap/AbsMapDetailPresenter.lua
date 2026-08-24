local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local AbsMapDetailPresenter = class("AbsMapDetailPresenter", cc.Layer)

function AbsMapDetailPresenter:enterMap(mapId, callback)
    ChallengeMapSystem:getInstance():enterChallengeMap(
        mapId,
        function(isOk, arg1,arg2)
            if isOk then
                local map = arg1
                self:_enterMap(map)

                for i, v in ipairs(arg2) do
                    PopText("已使用" .. Item:getOneItemByKey(v.id).name .. "X".. v.num)
                end
            else
                local errmsg = arg1
                PopText(errmsg)
            end
        end
    )
end

return AbsMapDetailPresenter
000000000
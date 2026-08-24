local Module = require("third.module.Module")
local RoleChallengeMapNpcModule = class("RoleChallengeMapNpcModule", Module)

function RoleChallengeMapNpcModule:ctor()
    -- 模块名
    self._name = "RoleChallengeMapNpcModule"
end

function RoleChallengeMapNpcModule:getDsc(target, role, isNeedAgeDesc, isNeedLookDesc, isNeedQiDesc)
    local innerFunc = function(self)
        isNeedAgeDesc = Helper:getDef(isNeedAgeDesc, true)
        isNeedLookDesc = Helper:getDef(isNeedLookDesc, true)
        isNeedQiDesc = Helper:getDef(isNeedQiDesc, true)
        local desc = ""
        local cl = "WHT"
        local sex = "他"
        if self.sex == "女" then
            sex = "她"
        elseif self.sex == "野兽" then
            return (self.dsc == nil and "" or tostring(self.dsc))
        end

        if self:checkRoleIsPolymorph() then --易容改貌
            if self.polymorph.sex == "女" then
                sex = "她"
            else
                sex = "他"
            end
        end
        if MapIsEmpty(role) == false then
            local relation = role:getRelation(self)
            if relation and self:getAttr("onlyId") ~= User:getRoleAttr("onlyId") then
                desc = cl .. self.name .. "是你的" .. relation .. "。\n"
            end
        end
        local dsc = ""
        if self.dsc then
            dsc = self.dsc
        end
        local title = ""
        if self.title then
            title = "江湖人称" .. self.title .. "。"
        end

        desc = desc .. cl .. sex .. "就是" .. tostring(self.name) .. "。" .. title .. tostring(dsc) .. "\n"

        -- add by XiaoZhiWei 2017/03/31 11:16:40 增加年龄描述开关
        if isNeedAgeDesc == true then
            desc = desc .. cl .. sex .. "看起来约" .. self:getAgeDsc()
        end

        -- add by XiaoZhiWei 2017/03/31 11:22:50 增加长相描述开关
        if self:getFaceDsc() ~= nil and isNeedLookDesc == true then
            if isNeedAgeDesc == true then
                desc = desc .. "，" .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
            else
                desc = desc .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
            end
        end
        if isNeedQiDesc == true then
            desc = desc .. cl .. sex .. "的武功看来" .. self:getKongfuDsc() .. cl .. "，出手似乎" .. self:getJialiDsc() .. cl .. "。\n"

            desc = desc .. cl .. sex .. "看起来" .. self:getQiDsc() .. "。\n"
        end

        if not MapIsEmpty(self.showequip) then
            for i, text in ipairs(self.showequip) do
                desc = desc .. cl .. "	□" .. text .. cl .. "\n"
            end
        end
        return desc
    end

    return true, innerFunc(target)
end

return RoleChallengeMapNpcModule
0000000
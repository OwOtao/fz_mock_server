local Module = require("third.module.Module")
local RoleDreamNpcModule = class("RoleDreamNpcModule", Module)

function RoleDreamNpcModule:ctor()
    -- 模块名
    self._name = "RoleDreamNpcModule"
end

function RoleDreamNpcModule:getDsc(target, role, isNeedAgeDesc, isNeedLookDesc , isNeedQiDesc)

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
        if self.title then --title 不知道哪里用了
            title = "江湖人称" .. self.title .. "。"
        end

        if self.onlyId == User:getRoleAttr("onlyId") then
            if string.len(dsc) > 0 then
                desc = desc .. tostring(dsc) .. "\n"
            end
        else
            if self.jobType and self.realName then
                desc = desc .. cl .. sex .. "就是" .. tostring(self.realName) .. "。" .. title .. tostring(dsc) .. "\n"
            else
                desc = desc .. cl .. sex .. "就是" .. tostring(self.name) .. "。" .. title .. tostring(dsc) .. "\n"
            end
        end

        -- add by XiaoZhiWei 2017/03/31 11:16:40 增加年龄描述开关
        if isNeedAgeDesc == true then
            desc = desc .. cl .. sex .. "看起来约" .. self:getAgeDsc()
        end
        if self.specialType == "中元节" or self.specialType == "中元节伴生" then
            if type(self.npcDsc) ~= "string" then
                local ghosts = require("app.models.Activities.ghosts")
                self.npcDsc = ghosts:checkGhostDsc(self)
            end
            desc = "WHT" .. self.npcDsc .. "\n"
            if self.sex == "男" then
                sex = "他"
            else
                sex = "她"
            end
        end
        -- add by XiaoZhiWei 2017/03/31 11:22:50 增加长相描述开关
        if self:getFaceDsc() ~= nil and isNeedLookDesc == true then
            if isNeedAgeDesc == true then
                if (self.specialType == "中元节" or self.specialType == "中元节伴生") and self.ghostPlayer ~= 1 then
                    -- desc = desc..sex..cl.."生得"..self:getFaceDsc()..cl.."。\n"
                    -- print(dsc,"相貌描述1")
                elseif self.ghostPlayer == 1 then
                elseif self.canSeeInheritHistory == true then
                    desc = "WHT" .. sex .. "就是" .. "self.name。\n"
                    desc = desc .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
                else
                    desc = desc .. "，" .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
                end
            else
                desc = desc .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
            end
        end
        if isNeedQiDesc == true then
            desc = desc .. cl .. sex .. "气息绵长，RED无法看出其武学造诣NOR" .. cl .. "。\n"

            desc = desc .. cl .. sex .. "面色红润，HIG无丝毫受伤迹象NOR" .. "。\n"
        end

        if self.specialType == "中元节" or self.specialType == "中元节伴生" then
            local role = User:getRole()
            if self.canSeeInheritHistory == true then
                for k, v in pairs(self.inheritHistory) do
                    if i == #self.inheritHistory then
                        -- 判断是否有改名
                        if v.inheritName ~= self.name then
                            v.inheritName = self.name
                        end
                    end
                    local map = role:getMapById("fb" .. tostring(v.retireMap))
                    desc =
                        desc ..
                        cl ..
                            "公元" ..
                                Helper:numberCast(Helper:date("%y", v.inheritTime)) ..
                                    "年" ..
                                        Helper:numberCast(Helper:date("%m", v.inheritTime)) ..
                                            "月" .. Helper:numberCast(Helper:date("%d", v.inheritTime)) .. "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. map.name .. "。\n"
                end
            end
        else
            for i, v in ipairs(self.inheritHistory) do
                if i == #self.inheritHistory then
                    -- 判断是否有改名
                    if v.inheritName ~= self.name then
                        v.inheritName = self.name
                    end
                end
                desc =
                    desc ..
                    cl ..
                        "公元" ..
                            Helper:numberCast(Helper:date("%y", v.inheritTime)) ..
                                "年" ..
                                    Helper:numberCast(Helper:date("%m", v.inheritTime)) ..
                                        "月" ..
                                            Helper:numberCast(Helper:date("%d", v.inheritTime)) ..
                                                "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. Map:getDefaultMapById(Map:getMapIdByIndex(v.retireMap)).name .. "。\n"
            end
        end

        if self.ZhiZuoZuTotalCount ~= nil then
            if self.name == "柳如烟" then
                desc = desc .. cl .. "她已收到" .. self.ZhiZuoZuTotalCount .. "个钱袋。\n"
            else
                desc = desc .. cl .. "此人已被怒怼" .. self.ZhiZuoZuTotalCount .. "次。\n"
            end
        end

        if self.isShowEquips == 1 then
            local weapoonName = self:getCurrWeaponName()
            local weapon = self:getEquipByName("weapon")
            if weapon then
                desc = desc .. cl .. "	□" .. weapoonName .. cl .. "\n"
            end

            local equipsTab = {
                [1] = "head", -- 头帽
                [2] = "cloth", -- 上装
                [3] = "pants", -- 下装
                [4] = "belt", -- 腰带
                [5] = "yaozhui", -- 腰坠
                [6] = "shoes", -- 鞋子
                [7] = "necklace", -- 项链
                [8] = "hand", -- 手部
                [9] = "ring" -- 戒指
            }

            for i, v in ipairs(equipsTab) do
                local equip = self:getEquipByName(v)
                if equip and self:getOneItemByKey(equip.itemId) then
                    desc = desc .. cl .. "	□" .. self:getOneItemByKey(equip.itemId).name .. cl .. "\n"
                end
            end
        end
        return desc
    end

    return true, innerFunc(target)
end

return RoleDreamNpcModule00
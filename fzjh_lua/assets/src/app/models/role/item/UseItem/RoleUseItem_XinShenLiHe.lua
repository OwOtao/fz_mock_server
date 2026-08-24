local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

local RoleUseItem_XinShenLiHe = {}

local rewards = {
    {
        id = "minditem3",
        name = "凝心露",
        type = 3,
        number = 3
    },
    {
        id = "minditem4",
        name = "聚心丹",
        type = 3,
        number = 2
    },
    {
        id = "xinggongsan",
        name = "行功散",
        type = 1,
        number = 3
    },
    {
        id = "liuyunganlu",
        name = "流云甘露",
        type = 1,
        number = 3
    }
}

function RoleUseItem_XinShenLiHe:__canUseItem()
    local items = {}
    for k,v in pairs(rewards) do
        if v.type == 1 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    end

    local role = self._role
    local isTrue = true

    for k,v in pairs(rewards) do
        if v.type == 3 then
            role:getServerActionSystem():getItemCount(v.id, 1, function(arg1, arg2)
                if arg1 == false then
                    PopText(arg2)
                    isTrue = false
                end

                local itemData = arg2

                if itemData.limit then
                    if itemData.count + v.number > itemData.limit then
                        PopText("打开后"..v.name.."数量超出上限，打开失败")
                        isTrue = false
                    end
                else
                    error("该心神道具未设置上限，道具id:"..v.id)
                end
            end)

            if isTrue == false then
                break
            end
        end
    end

    return isTrue
end

function RoleUseItem_XinShenLiHe:__doUseItem()
    local role = self._role
    local item = self._item

    HttpManagerEx:checkItemIsCanUse(item.id,1,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            for k,v in ipairs(rewards) do
                if v.type == 3 then
                    role:getServerActionSystem():addItemCount(v.id,v.number,1,function(isTrue,msg)
                        if isTrue == true then
                            PopText("获得"..v.name.." X "..v.number)
                        else
                            PopText(msg)
                        end
                    end)
                elseif v.type == 1 then
                    role:addItemCount(v.id,v.number,nil,nil,"心神礼盒开启")
                    PopText("获得"..v.name.." X "..v.number)
                end
            end
            
            role:addItemCount(item.id, -1,nil,nil,"使用心神礼盒")
            
            self:__onUseAft()
        else
            self:__popText(errmsg)
        end
    end,IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_XinShenLiHe", {AbstractUseItem}, RoleUseItem_XinShenLiHe)
0000000000000
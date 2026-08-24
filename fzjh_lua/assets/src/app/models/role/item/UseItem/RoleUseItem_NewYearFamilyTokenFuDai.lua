local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_NewYearFamilyTokenFuDai = {}

function RoleUseItem_NewYearFamilyTokenFuDai:__canUseItem()
    local role = self._role
    local item = self._item

    if role:getAttr("weight") - #role:getItems() < 1 then
        self:__popText("背包空间不足")
        return false
    end

    return true
end

local randomList = {
    --华山、丐帮、雪山寺、五毒、白驼山、落月山庄、全真教
    ["21xcxwfd1"] = {"huashanxinwu","gaibangxinwu","mizongxinwu","wuduxinwu","baituoshanxinwu","luoyuexinwu","quanzhenxinwu"},
    --天山、崆峒、昆仑、古墓、少林、铁掌、唐门
    ["21xcxwfd2"] = {"tianshanxinwu","kongtongxinwu","kunlunxinwu","gumuxinwu","shaolinxinwu","tiezhangxinwu","tangmenxinwu"},
    --峨眉、金钱帮、桃花岛、武当、明教、星宿、海鲸
    ["21xcxwfd3"] = {"emeixinwu","jinqianbangxinwu","taohuadaoxinwu","wudangxinwu","mingjiaoxinwu","xingxiuxinwu","haijingxinwu"},
}

function RoleUseItem_NewYearFamilyTokenFuDai:__doUseItem()
    local role = self._role
    local item = self._item

    HttpManagerEx:checkItemIsCanUse(item.id,1,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local currRandomList = randomList[item.id]

            if MapIsEmpty(currRandomList) == false then
                local random_index = math.random(1,#currRandomList)
                local random_id = currRandomList[random_index]
                role:addItemCount(item.id, -1)

                local itemAttr = role:getOneItemByKey(random_id)
                if itemAttr then
                    role:addItemCount(random_id,1)
                    self:__popText("获得了"..itemAttr.name.." X1")
                end
            end
            
            self:__onUseAft()
        else
            self:__popText(errmsg)
        end
    end,IS_SHOW_WAITING)
   
    return true
end

return NewClass("RoleUseItem_NewYearFamilyTokenFuDai", {AbstractUseItem}, RoleUseItem_NewYearFamilyTokenFuDai)
000000000
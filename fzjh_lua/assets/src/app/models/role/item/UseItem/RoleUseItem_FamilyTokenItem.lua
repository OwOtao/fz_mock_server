local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local familyTokenItems = requireWithEncrypt("script.others.familyTokenItems")["Sheet1"]

local RoleUseItem_FamilyTokenItem = {}

function RoleUseItem_FamilyTokenItem:__canUseItem()
    local role = self._role
    local item = self._item

    local DreamWorldPreConditionUtils = require("app.models.DreamWorldModel.DreamWorldPreConditionUtils")
    if DreamWorldPreConditionUtils:isFinishPreTask() == false then
        self:__popText("你似乎尚未掌握使用此物的法门。")
        return false
    end

    if familyTokenItems[item.id] then
        local tokenItem = familyTokenItems[item.id]
        local failText = tokenItem.failTextout
        local familyId = tokenItem.menpaiId
        local needUnlockId = tokenItem.UnlockId
        local unlockFailText = tokenItem.unlockIdTextout

        if needUnlockId ~= 0 and AchievementSystem:checkUnlockPointIsUnlock(needUnlockId) ~= true then
            self:__popText(unlockFailText)
            return false
        end

        if role:getFamilyId() == familyId then
            self:__popText(failText)
            return false
        end
    else
        assert(false,"策划配置表 师门信物未找到该物品"..tostring(item.id))
    end

    return true
end

function RoleUseItem_FamilyTokenItem:__doUseItem()
    local role = self._role
    local item = self._item

    if familyTokenItems[item.id] then
        local tokenItem = familyTokenItems[item.id]
        local duration = tokenItem.timeend
        local familyId = tokenItem.menpaiId
        local successText = tokenItem.successTextout

        local useFunc = function()
            HttpManagerEx:checkItemIsCanUse("familyToken",1,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
                    role:setTimeLimitFlag("family_token_id",familyId,tonumber(duration))
                    role:addItemCount(item.id, -1)
        
                    self:__popText(successText)
                    self:__onUseAft()
				else
					self:__popText(errmsg)
				end
			end,IS_SHOW_WAITING)
        end

        local cancelFunc = function()
        end

        local str = "使用后你的入梦门派将与信物关联，是否继续使用?"
        if role:getTimeLimitFlagTime("family_token_id") > 0 then
            str = "你已使用过信物，继续使用此信物会替代原信物，是否继续使用？"
        end

        role._iOutput:showFamilyTokenItem(str,useFunc,cancelFunc)
    else
        assert(false,"策划配置表 师门信物未找到该物品"..tostring(item.id))
    end

    return true
end

return NewClass("RoleUseItem_FamilyTokenItem", {AbstractUseItem}, RoleUseItem_FamilyTokenItem)
00000000000000
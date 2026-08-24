local class = require("third.class.NewClass")

local MapBag = {}

function MapBag:getLeftButtonNameByItemId(itemId)
    return switch(
        itemId,
        {
            ["lingshi1"] = "询\n问",
            ["default"] = nil
        }
    )
end

local partSortRules={
    ["头帽"]=1,["上装"]=2,["下装"]=3,["腰带"]=4,
    ["腰坠"]=5,["鞋子"]=6,["项链"]=7,["手部"]=8,["戒指"]=9
}

local rightButtonNameByItemId = {
   ["shimenwupin29"] = "使\n用",
   ["shimenwupin30"] = "使\n用",
   ["shimenwupin32"] = "使\n用",
   ["shimenwupin33"] = "使\n用",
}

local rightButtonNameByType = {
    ["房契"] = "查\n看",
    ["地契"] = "查\n看",
    ["历练任务"] = "快前\n速往",
}

local leftButtonNameByType = {
    ["面具"] = "放饰\n装箱",
    ["信物"] = "放饰\n装箱",
    ["挂饰"] = "放饰\n装箱",
    ["书页"] = "放书\n入箱",
    ["武学秘宝"] = "放书\n入箱",
    ["书籍"] = "放书\n入匣",
    ["锻造图谱"] = "放书\n入匣",
    ["毒术书籍"] = "放书\n入匣",
    ["房契"] = "前\n往",
    ["淬炼材料"] = "放炼\n冶箱",
    ["锻造材料"] = "放炼\n冶箱",
}


local rightButtonNameBySpecial = {
    ["canUse"] = "使\n用",
    ["combo"] = "合\n成", 
    ["equipUp"] = "穿\n上",
    ["equipDown"] = "卸\n下",
}

--特殊类型 升级
local leftButtonNameBySpecial= {
    ["upgrade"] = "升\n级"
}


function MapBag:create()
    return MapBag:new()
end

function MapBag:ctor()
end

function MapBag:setRole(role)
    self._role = role
end

function MapBag:getRole()
    return self._role
end

function MapBag:init()
end

function MapBag:getOneItemByKey(itemId)
    return self._role:getOneItemByKey(itemId)
end

function MapBag:getRoleBagItems()
    local bagItems = self._role:getItems()

    local bagItemInfoList = {}

    for k, item in ipairs(bagItems) do
        local itemAttr = self._role:getOneItemByKey(item.itemId)
        local itemInfo = {}
        itemInfo.itemId = item.itemId
        itemInfo.id = item.id
        itemInfo.count = item.count

        if itemAttr.canFold == ITEM_STATE_FALSE then
            if item.wanhaodu == 0 then
                itemInfo.text = itemAttr.name.."(损)"
            else
                itemInfo.text = itemAttr.name
            end
            --神兵武器颜色自带
            if itemAttr.wpType == "神兵" then
                itemInfo.text = itemAttr.nameColor .. itemInfo.text
            end
        else
            itemInfo.text = itemAttr.name .. " X" .. item.count
        end

        itemInfo.equipVisible = false
        itemInfo.backVisible = false
        itemInfo.equipWeaponIconVisible = false
        itemInfo.prepareWeaponIconVisible = false

        if self:__checkIsEquip(item.id) then
            itemInfo.equipVisible = true

            if self:__checkIsEquipWeapon(item.id) then
                itemInfo.equipVisible = false
                itemInfo.equipWeaponIconVisible = true
                itemInfo.equipWeaponIcon = "Image/UI/AttrUI/beibao2.png"
            end
        end

        if self:__checkIsPrepareWeapon(item.id) then
            itemInfo.equipVisible = false
            itemInfo.prepareWeaponIconVisible = true
            itemInfo.prepareWeaponIcon = "Image/UI/AttrUI/beibao1.png"
        end

        table.insert(bagItemInfoList,itemInfo)
    end

    if #bagItemInfoList > 1 then
        return self:__sortList(bagItemInfoList)
    else
        return bagItemInfoList
    end
end

function MapBag:createRoleDefaultItems()
    local defaultItems = {"shuxiang", "decorativeBox", "literaryBox","smeltBox"}

	if POISONSYS then
		if self._role:getInheritFlag("毒药系统") >= 1 or DEBUG_MODE == 1 then
			defaultItems = {"shuxiang", "decorativeBox", "literaryBox","medicinalBox","smeltBox"}
		end
	end

    --@desc 家园系统
	if JIAYUAN_SYSTEM_IS_OPEN == true then
		--@RefType [app.models.map.BaseMap#BaseMap] 
		local currMap = Map:getCurrMap()
		if currMap and currMap:getMapType() == MAP_TYPE.MYHOME then
			local bookRoomNum = currMap:getRoomCountByType("tsfangjian006")
			if bookRoomNum > 0 then
				for i = #defaultItems,1,-1 do
					if defaultItems[i] == "shuxiang" or defaultItems[i] == "literaryBox" then
						table.remove( defaultItems,i )
					end
				end
			end
	
			local decorRoomNum = currMap:getRoomCountByType("tsfangjian010")
			if decorRoomNum > 0 then
				for i = #defaultItems,1,-1 do
					if defaultItems[i] == "decorativeBox" then
						table.remove(defaultItems,i )
					end
				end
			end
		end
	end

    if self._role:getSelfCreatedSkillSystem():isOpenSystem() then
		table.insert(defaultItems, "bookRack")
	end

    table.insert(defaultItems, "volumeBox")

    local map = Map:getCurrMap()
    if map and map.id == "fb220" then
        defaultItems = {}
    end

    return defaultItems
end

function MapBag:getRoleDefaultItems()
    local defaultItems = self:createRoleDefaultItems()

    local defaultItemInfoList = {}

    for i, v in ipairs(defaultItems) do
        local itemAttr = self._role:getOneItemByKey(v)
        local itemInfo = {}
        itemInfo.itemId = v
        itemInfo.text = itemAttr.name
        itemInfo.equipVisible = false
        itemInfo.backVisible = false
        itemInfo.equipWeaponIconVisible = false
        itemInfo.prepareWeaponIconVisible = false
        table.insert(defaultItemInfoList,itemInfo)
    end

    return defaultItemInfoList
end

function MapBag:getItemLeftName(itemId)
    if self:getLeftButtonNameByItemId(itemId) then
        return self:getLeftButtonNameByItemId(itemId)
    end

    local itemAttr = self._role:getOneItemByKey(itemId)
 
    if leftButtonNameByType[itemAttr.type] then
        return leftButtonNameByType[itemAttr.type]
    end

    if itemAttr.upgrade ~= nil then
        return leftButtonNameBySpecial["upgrade"]
    end

    return nil
end

function MapBag:getItemRightName(itemId,onlyId)
    if rightButtonNameByItemId[itemId] then
        return rightButtonNameByItemId[itemId]
    end

    local itemAttr = self._role:getOneItemByKey(itemId)
 
    if rightButtonNameByType[itemAttr.type] then
        if itemAttr.type == "历练任务" then
            if self._role:getSkill("wuxingdunfa") ~= nil then
				if self._role:getTask(self._role:getAttr("currTaskId")).state == TASK_STATE_TO_SUBMIT then
					return nil
				else
					return rightButtonNameByType[itemAttr.type]
				end
			else
				return nil
			end
        else
            return rightButtonNameByType[itemAttr.type]
        end
    end

    if itemAttr.canUse == ITEM_STATE_FALSE and itemAttr.canEquip == ITEM_STATE_FALSE then
        return nil
    end

    if itemAttr.canUse == ITEM_STATE_FALSE then
        if self._role:checkItemIsEquip(onlyId) then
            return rightButtonNameBySpecial["equipDown"]
        else
            return rightButtonNameBySpecial["equipUp"]
        end
    elseif itemAttr.combo == ITEM_STATE_TRUE then
        return rightButtonNameBySpecial["combo"]
    else
        return rightButtonNameBySpecial["canUse"]
    end

    return nil
end

function MapBag:getItemName(itemId)
    local itemAttr = self._role:getOneItemByKey(itemId)

    if MapIsEmpty(itemAttr) == false then
        if itemAttr.wpType == "神兵" then
            return itemAttr.nameColor..itemAttr.name
        end
        return itemAttr.name
    end
end

function MapBag:getItemType(itemId)
    local itemAttr = self._role:getOneItemByKey(itemId)

    if MapIsEmpty(itemAttr) == false then
        return itemAttr.type
    end
end

function MapBag:getItemDesc(itemId)
    local itemAttr = self._role:getOneItemByKey(itemId)

	if itemAttr.type == "神书" then
		local str
        local ShenShuHelper = require("app.models.shenshu.shenshu")
		local list = ShenShuHelper:getTaskSongLiNpcList(self._role)
        
		for k, v in pairs(list) do
			if v.bookId == itemId then
				if itemAttr.name and v.name then
					str = "这是一本书，上面写着" .. itemAttr.name .. "几个大字，听说" .. v.name .. "正在寻找这本书籍，该书籍每晚24点将会消失。"
				end
			end
		end
		return str
	elseif type(itemAttr.timeend) == "number" or type(itemAttr.timeend) =="string" then
		return itemAttr:getDsc()
	elseif itemAttr.id =="item201_17" then
		local str = self._role:getAttr("ghostInfo").itemDes
        return str
	else
		return itemAttr:getDsc()
	end
end

function MapBag:getItemTimeDesc(itemId,onlyId)
    local itemAttr = self._role:getOneItemByKey(itemId)
    local item = self._role:getItemWithOnlyId(onlyId)
    --限时道具
    if type(itemAttr.timeend) == "number" or type(itemAttr.timeend) == "string" then
        if type(item.time) ~= "number" then
            item.time = self._role:getItemTimeLimit(itemAttr)
            self._role:setItemTimeByItemId(item.itemId,item.time)
        end

        if item.time >= GetTime() then
            local remainTime=Helper:diffWithSecond(item.time,GetTime())
            local remainDay=Helper:mathFloor(remainTime/(60*60*24))
            local remainHour=Helper:mathFloor(remainTime/(60*60)%24)
            local remainMinute=Helper:mathFloor(remainTime / 60 % 60)
            local remainSecond=Helper:mathFloor(remainTime%60)
            local str=""
            if remainDay>0 then 
                str=str..tostring(remainDay).."日"
            end
            if remainHour>0 then 
                str=str..tostring(remainHour).."时"
            end
            if remainMinute>0 then 
                str=str..tostring(remainMinute).."分"
            end
            if remainSecond>=0 then 
                str=str..tostring(remainSecond).."秒"
            end

            if itemAttr.type == "地契" then
                str = "搬入剩余时间："..str.."\n"
                str = str .. "到时若是没有搬入该地，土地将会被回收。"
            else
                str = "(该道具将在"..str .. "后被销毁)"
            end
            return str
        else
            return "该物品已经过期！"
        end
    end
    return nil
end

function MapBag:getItemCdPercent(itemId)
    local itemAttr = self._role:getOneItemByKey(itemId)
    if itemAttr == nil or itemAttr.type ~= "药品" or itemAttr.cooldown == nil or (itemAttr.attr and itemAttr.attr[1] ~= "qiPercent") then -- add by LvBin 2019/06/13 11:11:52 目前只有作用qiPercent的药品才用到cd时间
        return nil
    else
        local currTime = GetTime()
        local userTime = self._role:getFlag("药品使用时间")
        local coolDown = itemAttr.cooldown
        
        if userTime == 0 or (currTime - userTime > coolDown) then
            return nil
        else
            local percent = ((GetTime() - userTime) / coolDown) * 100
            percent = 100 - percent
            if percent <= 0 then
                percent = 0
            elseif percent >= 100 then
                percent = 100
            end
            return percent
        end
    end
end

function MapBag:__checkIsEquip(onlyId)
    if self._role:checkItemIsEquip(onlyId) then
		return true
	end

    return false
end

function MapBag:__checkIsPrepareWeapon(onlyId)
    if self._role:checkIsPrepareWeapon(onlyId) then 
		return true
	end

    return false
end

function MapBag:__checkIsEquipWeapon(onlyId)
    if self:__checkIsEquip(onlyId) then
        local weaponData = self._role:getEquipByName("weapon")
        if weaponData and weaponData.id == onlyId then 
            return true
        end
    end

    return false
end

function MapBag:__sortList(bagItems)
    if type(bagItems) ~= "table" then
		return nil
	end

    table.sort(bagItems, function(a, b)
        local itemAttr_a = self._role:getOneItemByKey(a.itemId)
        local itemAttr_b = self._role:getOneItemByKey(b.itemId)

        if not itemAttr_a or not itemAttr_b then
            return false
        end
        
        local rest = true
        if itemAttr_a.type == "房契" then
            return true
        elseif itemAttr_b.type == "房契" then
            return false
        end

        if itemAttr_a.type == "地契" and itemAttr_b.type == "地契" then
            return false
        end
        
        if itemAttr_a.type == "地契" then
            return true
        elseif itemAttr_b.type == "地契" then
            return false
        end

        if itemAttr_a.canEquip == ITEM_STATE_TRUE and itemAttr_b.canEquip == ITEM_STATE_TRUE then
            if self._role:checkItemIsEquip(a.id) and self._role:checkItemIsEquip(b.id) then
                
                if partSortRules[itemAttr_a.type] and partSortRules[itemAttr_b.type] then 
                    rest = partSortRules[itemAttr_a.type] < partSortRules[itemAttr_b.type]
                end
                --装备中有武器的话 武器排前面
                local weaponData = self._role:getEquipByName("weapon")
                if weaponData then 
                    if weaponData.itemId == a.itemId then 
                        rest=true
                    elseif weaponData.itemId == b.itemId then 
                        rest=false
                    end
                end
            elseif self._role:checkItemIsEquip(a.id) and not self._role:checkItemIsEquip(b.id) then
                rest = true
                --准备武器排前面
                if self._role:checkIsPrepareWeapon(b.id) then 
                    local weaponData = self._role:getEquipByName("weapon")
                    if weaponData and weaponData.id == a.id then 
                    else
                        rest = false
                    end
                end
            elseif not self._role:checkItemIsEquip(a.id) and self._role:checkItemIsEquip(b.id) then
                rest = false
                --准备武器排前面
                if self._role:checkIsPrepareWeapon(a.id) then 
                    local weaponData = self._role:getEquipByName("weapon")
                    if weaponData and weaponData.id == b.id then 
                    else
                        rest = true
                    end
                end
            else
                rest = a.itemId > b.itemId
                if self._role:checkIsPrepareWeapon(a.id) then 
                    rest = true
                elseif self._role:checkIsPrepareWeapon(b.id) then 
                    rest = false
                end
            end
        elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
            rest = a.itemId > b.itemId
        elseif itemAttr_a.canEquip == ITEM_STATE_TRUE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
            rest = true
        elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_TRUE then
            rest = false
        end

        -- @desc 同一个物品, 按照数目排序
        if rest == false then
            if a.itemId == b.itemId then
                return a.count > b.count
            end
        end

        return rest
    end)

    return bagItems
end

return class("MapBag", {}, MapBag)
0000000000000
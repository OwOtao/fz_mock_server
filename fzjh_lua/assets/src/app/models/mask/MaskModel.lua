local NewClass = require("third.class.NewClass")
local MaskConst = require("app.models.mask.MaskConst")
local MaskModel = {}

function MaskModel:create(role)
    local p = MaskModel.new()
    p:init(role)
    return p
end

function MaskModel:init(role)
    self._role = role
end

--@desc 添加面具等级
function MaskModel:addMaskLv(itemId)
	local decorative = self._role:getAttr("decorative")
	if MapIsEmpty(decorative) == false then
		for k,v in pairs(decorative) do
			if v.itemId == itemId then
                if v.lv == nil then
                    v.lv = 1
                end
                v.lv = v.lv + 1
			end
		end
	end
	return false
end

--@desc 获取面具等级
function MaskModel:getMaskLv(itemId)
	local decorative = self._role:getAttr("decorative")
	if MapIsEmpty(decorative) == false then
		for k,v in pairs(decorative) do
			if v.itemId == itemId then
				return v.lv or 1
			end
		end
	end
	return 1
end

--@desc 面具升级
function MaskModel:maskUpgrade(type,param,callback)
    if type == nil or param == nil then
        return false,"无法解锁"
    end
    if type == 0 then
       return 0 
    end
    local types = string.split(type,"#")
    local params = string.split(param,"|")

    local paramArray = {}

    for i,type in ipairs(types) do
        table.insert(paramArray, {type = tonumber(type),num = params[i]})
    end

    for i,v in ipairs(paramArray) do
        if v.type == MaskConst.Condition.Item then
            local itemStr = string.split(v.num,"#")
            local itemId = itemStr[1]
            local num = tonumber(itemStr[2])
            local itemName = Item:getOneItemByKey(itemId).name
            if self._role:getItemCount(itemId) < num then
                PopText("升级所需"..itemName.."不足")
                return false
            end
        elseif v.type == MaskConst.Condition.Lv then
            if self._role:getLv() < tonumber(v.num) then
                PopText("未满足解锁条件")
                return false
            end
        elseif v.type == MaskConst.Condition.InheritCount then
            if self._role:getAttr("inheritCount") < tonumber(v.num) then
                PopText("未满足解锁条件")
                return false
            end
        elseif v.type == MaskConst.Condition.Money then
            if self._role:getAttr("money") < tonumber(v.num) then
                PopText("解锁所需碎银不足")
                return false
            end
        end
    end

    HttpManagerEx:maskUpgrade(paramArray,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self:consumeRes(paramArray)
                if callback then
                    callback()
                end
                PopText("解锁成功")
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function MaskModel:consumeRes(paramArray)
    for i,v in ipairs(paramArray) do
        if v.type == MaskConst.Condition.Item then
            local itemStr = string.split(v.num,"#")
            local itemId = itemStr[1]
            local num = tonumber(itemStr[2])
            local itemName = Item:getOneItemByKey(itemId).name
            self._role:addItemCount(itemId,-num)
            PopText("消耗"..itemName.."*"..num)
        elseif v.type == MaskConst.Condition.Money then
            self._role:addAttr("money",-tonumber(v.num))
            PopText("消耗碎银*"..v.num)
        elseif v.type == MaskConst.Condition.Yinpiao then
            PopText("消耗银票*"..v.num)
        elseif v.type == MaskConst.Condition.Spcl then
            PopText("消耗饰品材料*"..v.num)
        end
    end
end

return NewClass("MaskModel", {}, MaskModel)
0
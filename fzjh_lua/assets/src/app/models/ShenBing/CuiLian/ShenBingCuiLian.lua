local ShenBingCuiLian = {}
  
local godweapon = requireWithEncrypt("script.others.godweapon")

function ShenBingCuiLian:getEverytimeCostJing()
    return 40
end

function ShenBingCuiLian:getCuiLianAttrName(attr)
    local cName = {
		yindu = "硬度",
		rendu = "韧度",
		weight = "重量值",
		damage = "伤害力",
		effctNum = "特性值"
    }
    
    return cName[attr]
end

--@desc: 获取神兵淬炼材料列表
--@author:LvBin
--@time:2023-01-04 11:19:41
--@weaponBType: 
--@return
function ShenBingCuiLian:getCuiLianItemList(weaponBType)
    local data = godweapon["cuiLianOfWepon"]

	local itemMap = {}
	
    for i = 1, 9999 do
        if data[tostring(i)] then
            if data[tostring(i)].Cuiliantype == weaponBType then
                table.insert(itemMap, data[tostring(i)])
            end
        else
            break
        end
    end
    
    return itemMap
end

function ShenBingCuiLian:getCuiLianSuccessRate(cuiLianCount,roleType,skillLv)
	local result = 0
    local count = cuiLianCount
    
	if roleType == 1 then
		if count <= 50 then
			result = 80
		elseif count > 50 and count <= 100 then
			result = math.min( (20/count + skillLv / 1000)*100 ,60)
		elseif count > 100 and count <= 200 then
			result = math.min((20/count + skillLv / 1500)*100 ,50)
		elseif count > 200 and count <= 300 then
			result = math.min((10/count + skillLv / 3600)*100 ,25)
		else
			assert(nil, "超过最大锻造次数")
		end
		if User:getRole():getBuffAttr("xingzhenCuiLian") ~= 0 then
			result = math.min(result +  User:getRole():getBuffAttr("xingzhenCuiLian"),100)
		end
	else
		if count <= 50 then
			result = 100
		elseif count > 50 and count <= 100 then
			result = math.min(math.floor( (20/count + skillLv / 1000)*100 ),85)
		elseif count > 100 and count <= 200 then
			result = math.min(math.floor( (30/count + skillLv / 1500)*100 ),75)
		elseif count > 200 and count <= 300 then
			result = math.min(math.floor( (10/count + skillLv / 3600)*100 ),40)
		else
			assert(nil, "超过最大锻造次数")
		end
	end
	
	return result
end

return ShenBingCuiLian000000000000
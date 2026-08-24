local ShenBingCuiLianModel = {}

local godweapon = requireWithEncrypt("script.others.godweapon")

local Meridian = require("app.models.Meridian.Meridian")

function ShenBingCuiLianModel:getEverytimeCostJing()
    return 40
end

--@desc: 获取欧冶子淬炼每日上限
--@author:LvBin
--@time:2023-02-14 17:37:31
--@return
function ShenBingCuiLianModel:getOuYeZiCuiLianCountDayLimit()
	return 50
end

function ShenBingCuiLianModel:getEverytimeCostGold(skilv,cuilianCount,costFactor)
	local costGold = skilv / 12 + math.pow((cuilianCount + 1), 1.2)
		
	if User:getRole():isHaveImprintingId("lingbingyin") then
		local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")

		costGold = math.ceil(costGold * meridianBuffValue)
	end

	costGold = costGold * (1 - costFactor)

	return Helper:mathFloor(costGold) 
end

function ShenBingCuiLianModel:getCuiLianAttrName(attr)
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
function ShenBingCuiLianModel:getCuiLianItemList(weaponBType)
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

function ShenBingCuiLianModel:getSelfCuiLianSuccessRate(cuiLianCount,skillLv)
	local result = 0
    local count = cuiLianCount
    
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
	
	return result
end

function ShenBingCuiLianModel:getNpcCuiLianSuccessRate(cuiLianCount,skillLv)
	local result = 0
    local count = cuiLianCount
    
	if count <= 50 then
		result = 100
	elseif count > 50 and count <= 100 then
		result = math.min((20/count + skillLv / 1000)*100 ,85)
	elseif count > 100 and count <= 200 then
		result = math.min((20/count + skillLv / 1500)*100 ,75)
	elseif count > 200 and count <= 300 then
		result = math.min(math.floor( (10/count + skillLv / 2400)*100 ),40)
	else
		assert(nil, "超过最大锻造次数")
	end
	
	return result
end

--@desc: 神兵属性四舍五入精确小数位
--@author:LvBin
--@time:2023-03-27 12:01:42
--@weapon: 
--@return
function ShenBingCuiLianModel:weaponAttrRoundPreciseDecimal(weapon)
	weapon.yindu = Helper:roundPreciseDecimal(weapon.yindu,3)
	weapon.rendu = Helper:roundPreciseDecimal(weapon.rendu,3)
	weapon.weight = Helper:roundPreciseDecimal(weapon.weight,3)
	weapon.damage = Helper:roundPreciseDecimal(weapon.damage,3)
	weapon.effctNum = Helper:roundPreciseDecimal(weapon.effctNum,3)
end

return ShenBingCuiLianModel0000000
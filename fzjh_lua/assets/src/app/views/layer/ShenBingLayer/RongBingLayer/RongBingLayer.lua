local RongBingLayer = class("RongBingLayer")

--@RefType [app.models.ShenBing.DuanZao.ShenBingDuanZao#ShenBingDuanZao]
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

-- local weapon = {
-- 	id = "weapon_1", 	-- 必须唯一
-- 	name = "测试",		-- 名字
-- 	nameColor = "", -- 名字颜色 
-- 	type = "刀",	-- 武器类型
-- 	wpType = "神兵", 	-- 类型 (用于区分神兵和普通兵器)
-- 	damage = 0,		-- 伤害值
-- 	yindu = 0, 		-- 硬度值
-- 	rendu = 0, 		-- 韧度值
-- 	weight = 0,		-- 重量值
-- 	effctNum = 0,	-- 特性值 (计算得出,到达一定值可开启特效)
-- 	naijiu = 0,	-- 当前耐久度 (耐久度小于等于0表示已损坏,需要修理,同时完好度需变为0.耐久度一般由硬度和渐坚韧度计算得出)
-- 	wanhaodu = 0,	-- 完好度 (损坏完好度为0, 修理后耐久度修复,完好度根据计算得出)
-- 	effct1 = "",		-- 特效1
-- 	effct2 = "",		-- 特效2
-- 	effct3 = "",		-- 特效3 (暂定三个特效,特效效果读取资源配置表)
-- 	cuilianitems = {},  -- 加工使用的物品列表 {itemid = count}
-- 	useNeiLi = 0,		-- 注入的内力值
-- 	desc = "",			-- 武器的描述,在第一次载入的时候计算生成(生成规则查看策划案)
-- 	lookDesc = "", 		-- 外观描述
-- 	equipDesc = "", 		-- 装备描述
-- 	getoffDesc = "", 		-- 拖下描述
-- 	status = 0, 		-- 铸造状态 0 铸造中,1 铸造完成未取名,2 铸造完成已取名
-- 	canEquip = 1,		-- 可装备
-- 	cuilianCount = 2,  -- 淬炼次数
-- 	--- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
-- 	cuilianFailedCount = 0, --淬炼失败次数
-- 	duanzaoitems = {},	-- 锻造使用的物品列表 {itemid = count}
-- 	cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}
-- }
--@desc: 
--@author:Liang SongQiang
--@time:2017-12-19 15:27:37
function RongBingLayer:showLayer()
	local filterFun = function(item)
		return item.type == "神兵"
	end
	
	local items = Helper:getDef(User:getRole():getItems(filterFun), {})
	
	if MapIsEmpty(items) then
		PopText("你没有神兵")
		return
	end

	local isSuccess = false
	
	PopupLayerController:showLayer("ShenBingBagLayer", function(layer)
		layer:btnLeftClickFunc(function()
			if self._backFunc then
				self._backFunc = nil
			end

			layer:destory()
		end, "取消")
		
		layer:btnRightClickFunc(function(leftList, rightList)
			if MapIsEmpty(rightList) then
				PopText("请选择要销毁的神兵")
				return
			end
			
			local weaponData = rightList[1]
			local role = User:getRole()
			local weaponItemId = weaponData.itemId
			local weapon = role:getOneItemByKey(weaponItemId)
			local cuilianCount = weapon.cuilianCount

			local function rongLianFunc(itemId)
				role:addItemCount(itemId, - 1)
				ShenBingDuanZao:deleteShenBingWeaponById(itemId)

				local defaultShenBingItemId = role:getAttr("defaultShenBingItemId")
				if defaultShenBingItemId == itemId then
					role:setAttr("defaultShenBingItemId", nil)
				end
			end

			PopupLayerController:showLayer("PopConfirmLayer", function(dialog)
				dialog:showRefreshPannel()
				dialog:setDsc("熔炼神兵能获得其淬炼的部分材料，熔兵后神兵将会永远消失，你确定要熔炼这把神兵吗？")
				dialog:setCanelButtonNameAndCallFunc("返回")
				dialog:setButtonNameAndCallFunc("确定", function()
					HttpManagerEx:getWeaponCuilianNum(weaponItemId, nil, function(status, errcode, errmsg, data)
						if status == 200 and errcode == 0 then
							if isSuccess == true then
								layer:destory()

								if self._backFunc then
									self._backFunc()
									self._backFunc = nil
								end

								return
							end

							--@desc 没有淬炼过的情况 或者 没有成功淬炼成功的情况
							if MapIsEmpty(data) or cuilianCount == 0 then
								rongLianFunc(weaponItemId)
								isSuccess = true

								self:print("RED你将NOR" .. weapon.name .. "RED放入熔炉中煅烧融毁，过了许久，兵器方才融完，没有材料留下。NOR")

								layer:destory()

								if self._backFunc then
									self._backFunc()
									self._backFunc = nil
								end

								return
							end

							local cuilianTimes = 0

							for k, v in pairs(data) do
								cuilianTimes = v + cuilianTimes
							end
							
							if cuilianCount < cuilianTimes then 
								cuilianTimes = cuilianCount
							end

							cuilianTimes = math.ceil(cuilianTimes / 2)

							if not role:checkCanBuyThings("cuilianruyi",cuilianTimes) then 
								PopText("背包空间不足")
								return
							end

							role:addItemCount("cuilianruyi",cuilianTimes)

							rongLianFunc(weaponItemId)

							isSuccess = true

							self:print("铁匠看着已经化成铁水的神兵，感叹了一下，开口安慰你：可惜了一把神兵……莫灰心，这里是"..cuilianTimes.."个HIY如意NOR，重新再造一把就是了")

							layer:destory()
							
							if self._backFunc then
								self._backFunc()
								self._backFunc = nil
							end
						else
							PopText("熔兵失败，请重试")
						end
					end,IS_SHOW_WAITING)
					
				end)
			end)
		end, "熔兵")
		
		layer:setCondiPushRightList(function(leftList, rightList, item)
			if rightList and #rightList >= 1 then
				PopText("一次只能熔兵一把")
				return false
			end
			--@RefType [app.models.role.Role#Role]
			local role = User:getRole()
			local equipsWeapon = role:getEquipByName("weapon")
			if equipsWeapon ~= nil and not MapIsEmpty(equipsWeapon) then
				if equipsWeapon.itemId == item.itemId then
					PopText("请把神兵脱下，再进行熔兵")
					return false
				end	
			end
			local prepareWeapon = role:getPrepareWeapon()
			if prepareWeapon then 
				if prepareWeapon.itemId == item.itemId then
					PopText("请先把准备神兵取消，再进行熔兵")
					return false
				end	
			end
			
			return true
		end)

		for i, shenBing in ipairs(items) do
			layer:pushItemToLeftList(shenBing)
		end
		
		layer:setRightName("熔炉")
		layer:setTextMoney("黄金：" .. User:getRole():getAttr("gold"))
		layer:showLayer()
	end)
	
end


function RongBingLayer:print( str )
	local layerName = MainControllLayer:getCurrLayer()					
	local layer = MainControllLayer:getLayer(layerName)

	if layerName == "ShenBingLayer" then
		layer:print(str)
		layer:isShow()
	elseif layerName == "FurnaceLayer" then
		layer:print(str)
	else
		RichPrint("main",str)
	end
end

function RongBingLayer:setBackFunc(func)
	self._backFunc = func
end


return RongBingLayer00000000000
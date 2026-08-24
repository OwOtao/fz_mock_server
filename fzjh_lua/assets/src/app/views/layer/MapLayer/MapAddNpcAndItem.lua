local Resource = require("app.Resource")
local User = require("app.models.user.User")
local Item = require("app.models.item.Item")

local MapAddNpcAndItem = {}

local maps = {}



local MapAddNpc = 
{
	-- fb25 = 
	-- -- fb02 =
	-- {
	-- 	fb25_28 = 
	-- 	-- fb02_01 =
	-- 	{	
	-- 		roles = 
	-- 		{
	-- 			gongsunzhi = 
	-- 			{
	-- 				isCreate = "Y",--判断是否是加入到副本的物品或者NPC
	-- 				type = "role",
	-- 				id = "gongsunzhi",
	-- 				name = "公孙冶",
	-- 				age = 43,
	-- 				looks = 20,
	-- 				sex = "男",
	-- 				dsc = "",

	-- 				buttons = 
	-- 				{
	-- 					buttonTalk = 
	-- 					{
	-- 						name = "交谈",
	-- 						func = function(...)
	-- 							local params = {...}
	-- 							local RoleObserveLayer = params[1]
	-- 							Audio:playEffect("xiaoAnNiu")
	-- 							RichPrint("main", "锻造兵器老夫在行，销毁兵器老夫亦是拿手。你若有什么神兵利器需要销毁，可交给老夫来做。")
	-- 							RoleObserveLayer:hide()
	-- 						end
	-- 					},
	-- 					buttonDestroy =
	-- 					{
	-- 						name = "销毁",
	-- 						func = function(...)
	-- 							MapAddNpcAndItem:setGongSunZhiRole(...)
	-- 						end
	-- 					}
	-- 				}
	-- 			}
	-- 		}
	-- 	}	
	-- },
	-- 第十个副本的32号房间  添加 NPC 程药发
	fb10 =
	-- fb01 = 
	{
		fb10_32 = 
		-- fb01_01 =
		{
			roles = 
			{
				chengyaofa = 
				{
					isCreate = "Y",--判断是否是加入到副本的物品或者NPC
					type = "role",
					id = "chengyaofa",
					name = "程药发",
					age = 43,
					looks = 20,
					sex = "男",
					dsc = "扬州现任知府。"	,


					buttons = 
					{
						buttonTalk = 
						{
							name = "交谈",
							func = function(...)
								-- local params = {...}
								-- local RoleObserveLayer = params[1]
								Audio:playEffect("xiaoAnNiu")
								RichPrint("main", "YEL程药发：在下程药发。")
								-- RoleObserveLayer:hide()
							end
						},
						buttonPresent =
						{
							name = "送礼",
							func = function(...)
								MapAddNpcAndItem:setZhiFuRole(...)
							end
						},
					
					}
				}	
			}
		}
	}
}
local MapAddItem = 
{
	--悬崖
	-- fb19 =
	-- -- fb02 = 
	-- {
	-- 	fb19_40 =
	-- 	-- fb02_02 = 
	-- 	{
	-- 		items = 
	-- 		{
	-- 			xuanya = 
	-- 			{	
	-- 				isCreate = "Y",--判断是否是加入到副本的物品或者NPC
	-- 				type = "item",
	-- 				id = "xuanya",
	-- 				name = "悬崖",
	-- 				dsc = "下临深谷，前方再无去路，脚下云雾缠绕，无法看到谷底，悬崖边上有一石碑，其上刻着“断肠崖”，这里就是断肠崖了。 雁飞高兮邈难寻,空断肠兮思切切，自古以来多少豪杰都在此弃刀归隐。",

	-- 				buttons = 
	-- 				{
	-- 					buttonXuanYa = 
	-- 					{
	-- 						name = "弃兵",
	-- 						func = function(...)
	-- 							MapAddNpcAndItem:setXuanYaRole(...)
	-- 						end
	-- 					}
	-- 				}				
	-- 			}
	-- 		}
	-- 	}
	-- },
    --土堆的生成
    -- fb22 = 
    -- {
    --     fb22_33 = 
    --     {
    --         items =
    --         {
    --             tudui =
    --             {
    --                 isCreate = "Y",
    --                 type = "item",
    --                 id = "tudui",
    --                 name = "土堆",
    --                 dsc = "树影婆娑，斑驳的光影泼洒在这抔 黄土之上，凄冷的风挟带这悠长的笛声，这剑冢之中不知埋藏了多少剑客的遗恨。 心头中默然响起掩埋神兵之日，便是重铸之时。",
    --                 canThrow = _type,--能否操作

    --                 buttons = 
    --                 {
    --                     buttonCangBing =
    --                     {
    --                         name = "藏兵",
    --                         func = function( ... )
    --                             MapAddNpcAndItem:set
    --                         end
    --                     }
    --                 }

    --             }
    --         }
    --     }
    -- }
}
--创建NPC
function MapAddNpcAndItem:createNpc(Mapid,Roomid,RoleList)
	if not Mapid or not Roomid then
		return 
	end
	if MapAddNpc[Mapid] == nil or MapAddNpc[Mapid][Roomid] == nil then
		return
	end
	for k,role in pairs(MapAddNpc[Mapid][Roomid].roles) do
		role = Helper:tableCover(Role:create(), role)
		table.insert(RoleList,role)
	end
	if PRINT_MODE ==1 then
		-- Helper:print_lua_table(RoleList)
	end
end

--创建Item
function MapAddNpcAndItem:createItem(Mapid,Roomid,RoleList)
	if not Mapid or not Roomid then
		return 
	end
	if MapAddItem[Mapid] == nil or MapAddItem[Mapid][Roomid] == nil then
		return  
	end
	for k,item in pairs(MapAddItem[Mapid][Roomid].items) do
		item = Helper:tableCover(require("app.models.item.BaseItem"):create(),item)
		table.insert(RoleList,item)
	end
	if PRINT_MODE ==1 then
		-- Helper:print_lua_table(RoleList)
	end

	return 
end

function MapAddNpcAndItem:setXuanYaRole(...)
	local params = {...}
	local RoleObserveLayer = params[1]

    Audio:playEffect("xiaoAnNiu")

    local role = User:getRole()
    local shenBingweapon = role.shenBingweapon

    local items = User:getRole():getItems(function(item)
        if item.type == "神兵" then
            return true
        end
        return false
    end)
    if MapIsEmpty(items) == true then
        PopText("你身上没有神兵")
        return 
    end



    -- if shenBingweapon.status ~= "2" then
    --     PopText("你都没有锻造神兵何来弃兵之说！！！")
    --     return
    -- end
    --已结装备着。请先卸下载进行弃兵操作
    --用mapist里面的id才能判断是否已经装备
    local shenBingItem = Item:getOneItemByKey(items[1].itemId)
    if  role:checkItemIsEquip(shenBingItem.id)  then
        PopText(tostring(shenBingweapon.colorname)..tostring(shenBingweapon.name).."NOR已经装备，如何丢弃？")
        return
    end     
    if PRINT_MODE ==1 then
        Helper:print_lua_table(shenBingweapon)
    end
    PopupLayerController:showLayer("DialogUseLayer", function(layer)
        layer:show()
        layer:setTitle("弃兵")
        layer:setTextUseGoods("NOR你确定要丢弃你的"..tostring(shenBingweapon.name).."?")
        layer:setTextDesc("（丢弃后只得重新打造，望三思）")
        --确定按钮
        layer:setButton1(function()
        --把神兵的结构数据发给服务器
            local params = 
            {
                data = role.shenBingweapon,
                type = 1,
                index = 1,
            }
            HttpManagerEx:throwShenBingWeapon(2,1,params, function(status, errcode, errmsg, data)
                if 200 == status then
                    --处理进入界面时候，武器描述为原始的情况，应该记录最新的描述，下次进来设置上去
                     --确定之后要处理的事情，清楚神兵的数据
                     --在清除数据之前把神兵从背包清除
                     if 0 == errcode then
                        role:addItemCount(shenBingweapon.id,-1)
                        self:deleteShenBingData(shenBingweapon)
                        RichPrint("main","你将神兵丢下了悬崖，神兵快速坠落，渐渐地成了一个黑点，消失在你的视野之中。")       
                        return true
                    else
                        PopText(tostring(errmsg))                
                    end
                    
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
                --增加重试界面
            end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
            PopupLayerController:hideLayer("DialogUseLayer", function(layer)
                layer:hide()
            end)
        end)

        -- if PRINT_MODE ==1 then
        --     --清除之后打印神兵数据看看
        --     -- Helper:print_lua_table(shenBingweapon)
        -- end     
        --取消按钮
        layer:setButton2(function()
            PopupLayerController:hideLayer("DialogUseLayer", function(layer)
                layer:hide()
            end)
        end) 
    end)
    RoleObserveLayer:hide()
end

--公孙冶的显示文本
function MapAddNpcAndItem:gongSunZhiText(shenBingweapon)
    local str = ""
    if not shenBingweapon.type then
        return nil
    elseif shenBingweapon.type == "剑" then
        str = "HIR公孙冶大喝一声，一掌擎剑，一锤猛力击下。结果轰隆一声巨响。"..tostring(shenBingweapon.colorname)..shenBingweapon.name.."HIR断为两截!"
    elseif shenBingweapon.type == "刀" then
        str = "HIR公孙冶大喝一声，一掌擎刀，一锤猛力击下。结果轰隆一声巨响。"..shenBingweapon.colorname..shenBingweapon.name.."HIR断为两截!"
    elseif shenBingweapon.type == "鞭" then
        str = "HIR公孙冶大喝一声，一手擎鞭，一锤猛的一扯。结果啪的一声爆响。"..shenBingweapon.colorname..shenBingweapon.name.."HIR断为两截!"
    elseif shenBingweapon.type == "棍" then
        str = "HIR公孙冶大喝一声，一掌擎棍，一锤猛力击下。结果轰隆一声巨响。"..shenBingweapon.colorname..shenBingweapon.name.."HIR断为两截!"
    end
    return str
end



--清空神兵数据
function MapAddNpcAndItem:deleteShenBingData(shenBingweapon)
    shenBingweapon.status = "0"
    shenBingweapon.lv = 0
    shenBingweapon.payYuanBao = 0
    shenBingweapon.name = nil---不清空，留着用
    shenBingweapon.id =""  --设置一个唯一的id  方便在物品里使用
    shenBingweapon.material = ""
    shenBingweapon.beginDazaoTime = nil --开始打造时间

    shenBingweapon.unit = ""            -- 单位
    shenBingweapon.canFold = 0          -- 可堆叠
    shenBingweapon.canUse = 0           -- 可使用
    shenBingweapon.canEquip = 1         -- 可装备
    shenBingweapon.combo = 0            -- 可合成
    shenBingweapon.canSell = 0      -- 可出售
    shenBingweapon.canDrop = 0              -- 可丢弃
    shenBingweapon.equipPart = "" --装的时候用的属性
    shenBingweapon.loadingBarPersent = 0
    shenBingweapon.damage = 0 --初始化伤害值10            
    shenBingweapon.strDesc = " " -- 武器描述
    shenBingweapon.dsc =" "-- 武器描述
    shenBingweapon.strAppearance = ""-- 武器的外观描述
    shenBingweapon.colorname = nil
    shenBingweapon.color = nil
    shenBingweapon.colorid =nil
    shenBingweapon.type =nil
    shenBingweapon.unwieldText = nil ---回鞘特效
    shenBingweapon.equipText = nil
    shenBingweapon.weapon_in = nil--回鞘特效--------------
    shenBingweapon.weapon_out = nil--拔剑特效------------------
    shenBingweapon.neili_level = 0--实质上花费的内力（累计）发送服务器
    shenBingweapon.neilicast = 0--根据富源相当于消耗多少内力的达到的效果()
    
    -- needGold = 0,
    shenBingweapon.gold_level = 0--花费的黄金（）发送服务器
    shenBingweapon.goldcast = 0--花费的黄金（）发送服务器   
end
--创建公孙冶   25章28号房间
function MapAddNpcAndItem:setGongSunZhiRole(...)   
    print("---setGongSunZhiRole-------------------------------------------------------------------------------------------------------------")
    local params = {...}
    local RoleObserveLayer = params[1]

    --销毁按钮
    Audio:playEffect("xiaoAnNiu")
    local role = User:getRole()
    local shenBingweapon = role.shenBingweapon
    if shenBingweapon.status ~= "2" then
        PopText("你都没有锻造神兵何来销毁之说！！！")
        RoleObserveLayer:hide()
        return
    end
    if	PRINT_MODE ==1 then
    	Helper:print_lua_table(shenBingweapon)
    end
    --已结装备着。请先卸下载进行弃兵操作
    --用mapist里面的id才能判断是否已经装备
    local shenBingItem = role:getItem(shenBingweapon.id)
    if  role:checkItemIsEquip(shenBingItem.id)  then
        PopText(shenBingweapon.colorname..shenBingweapon.name.."NOR已经装备，如何销毁？")
        return
    end     
    if PRINT_MODE ==1 then
        -- Helper:print_lua_table(shenBingweapon)
    end
    PopupLayerController:showLayer("DialogUseLayer", function(layer)
        layer:show()
        layer:setTitle("销毁")
        layer:setTextUseGoods("NOR你确定要销毁你的"..tostring(shenBingweapon.name).."?")
        layer:setTextDesc("（销毁后只得重新打造，望三思）")
        --确定按钮
        layer:setButton1(function()
             --把神兵的结构数据发给服务器
            local params = 
            {
                data = role.shenBingweapon,
                index = 1,
                type = 1,
            }
            HttpManagerEx:throwShenBingWeapon(3,1,params, function(status, errcode, errmsg, data)
                if 200 == status then
                    --确定之后要处理的事情，清楚神兵的数据
                    --在清楚数据之前把神兵从背包清除
                    if 0 == errcode then
                        local str = self:gongSunZhiText(shenBingweapon)
                        role:addItemCount(shenBingweapon.id,-1)
                        RichPrint("main",str)
                        self:deleteShenBingData(shenBingweapon) 
                        return true
                    else
                        PopText(tostring(errmsg))                
                    end

                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
                --不用反复重试
            end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
            PopupLayerController:showLayer("DialogUseLayer", function(layer)
                layer:hide()
            end)
        end)

        if PRINT_MODE ==1 then
            --清除之后打印神兵数据看看
            -- Helper:print_lua_table(shenBingweapon)
        end     
        --取消按钮
        layer:setButton2(function()
            PopupLayerController:showLayer("DialogUseLayer", function(layer)
                layer:hide()
            end)
        end) 
    end)
    RoleObserveLayer:hide()
end

-- 创建知府按钮 副本10 房间32
function MapAddNpcAndItem:setZhiFuRole(...)
	-- local params = {...}
	-- local RoleObserveLayer = params[1]

    local player = User:getRole()
    -- 送礼 -- 
    Audio:playEffect("xiaoAnNiu")
    local items = player:getItemsWithItemId("guanfugongwen")
    if MapIsEmpty(items) == true then
        RichPrint("main", "我不接受你的物品！")
    else
        RichPrint("main", "YEL程药发：一封公文？待我看看。")
        HttpManagerEx:useShopGoods("guanfugongwen", function(status, errcode, errmsg, data)
            if 200 == status then
                if 0 == errcode then
                    RichPrint("main", "YEL程药发：嗯，不错，是官府公文不假，谭师爷，帮他办下手续吧。")
                    RichPrint("main", "CYN谭师爷：是，知府大人。")
                    RichPrint("main", "谭师爷拿出一本厚厚的册子，用毛笔在上面一划。")
                    RichPrint("main", "YEL谭师爷：行了，你的户籍已经吊销，从此江湖再无 HIG『"..player:getName().."』YEL 这号人物。")
                    player:setAttr("name", "无名氏")
                    player:addItemCount("guanfugongwen", -1)

                    --有传承数据则当前传承角色也对应改成无名氏
                    local inheritHistory = player:getAttr("inheritHistory")
                    for i,v in ipairs(inheritHistory) do
                        if i == #inheritHistory then
                             v.inheritName = "无名氏"
                        end
                    end
                else
                    PopText(tostring(errmsg))
                end
            else
                PopText("网络请求出错,请换个网络环境再试!")
            end
        end, IS_SHOW_WAITING)
    end
    -- RoleObserveLayer:hide()
end


function MapAddNpcAndItem:onEvent(eventName, map, room)
    if eventName == "entryRoom" then
        
    end
end 


return MapAddNpcAndItem
0000000000000
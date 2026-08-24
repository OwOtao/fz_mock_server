-- --[[
--     梦呓商人
-- ]]
-- local DreamSalesModel = {}

-- function DreamSalesModel:getSaleGoodsAndOpenLayer()
--     return self:getSalesGoods(
--         "N",
--         function(data, errmsg)
--             if errmsg ~= nil then
--                 PopText(errmsg)
--                 return
--             end

--             PopupLayerController:showLayer(
--                 "DreamSalesLayer",
--                 function(layer)
--                     Helper:print_lua_table(data)
--                     layer:showLayer(data)
--                 end
--             )
--         end
--     )
-- end

-- --@desc: 刷新列表
-- --@author:Liang SongQiang
-- --@time:2019-09-29 11:21:13
-- function DreamSalesModel:refreshGoodList(callback)
--     return self:getSalesGoods(
--         "Y",
--         function(data, errmsg)
--             if errmsg ~= nil then
--                 PopText(errmsg)
--                 return
--             end

--             callback(data)
--         end
--     )
-- end

-- function DreamSalesModel:getSalesGoods(isRefresh, callback)
--     isRefresh = Helper:getDef(isRefresh, "N")
--     HttpManagerEx:getDreamGoods(
--         isRefresh,
--         function(status, errcode, errmsg, data)
--             if 200 == status then
--                 if 0 == errcode then
--                     callback(data)
--                 else
--                     callback(nil, errmsg)
--                     print(errcode, errmsg)
--                 end
--             else
--                 callback(data, errmsg)
--             end
--         end,
--         IS_SHOW_WAITING
--     )
-- end

-- --@desc: 购买技能
-- --@author:Liang SongQiang
-- --@time:2019-09-29 15:34:07
-- --@sellerItem: 技能ID ，也是梦呓商人下发的商品结构
-- function DreamSalesModel:buySkill(sellerItem, callback)
--     local player = User:getRole()

--     local skillId = sellerItem.itemId

--     local role_skill = player:getSkill(skillId)

--     if role_skill ~= nil then
--         PopText("你已学会该技能，无需重复学习")
--         return
--     end

--     local info_list = {
--         Text_tital = Helper:getDef(sellerItem.nameColor, "") .. sellerItem.name,
--         Text_type = "武学",
--         Rich_dsc = sellerItem.dsc .. "\nYEL" .. Helper:getDef(sellerItem.introduce, ""),
--         Text_price = "售价:" .. sellerItem.price .. User:getRole():getCHAttrName("dreamCoins"),
--         Text_affirm = "HIW确定学习" .. sellerItem.name .. "吗？NOR",
--         Text_havenum = nil
--     }

--     self:openShoppingDialog(
--         info_list,
--         function()
--             HttpManagerEx:buyDreamGood(
--                 skillId,
--                 function(status, errcode, errmsg, data)
--                     if 200 == status then
--                         if errcode == 0 then
--                             player:addSkillExp(skillId, 1)

--                             local skill = Skill:getSkill(skillId)

--                             PopText("你学会了" .. skill.name)

--                             callback(data)
--                         else
--                             callback(nil, errmsg)
--                             print(errcode, errmsg)
--                         end
--                     else
--                         callback(data, errmsg)
--                     end
--                 end,
--                 IS_SHOW_WAITING
--             )
--         end
--     )
-- end

-- function DreamSalesModel:openShoppingDialog(info_list, ok_func)
--     ok_func = Helper:getDef(ok_func, EMPTY_FUNC)
--     PopupLayerController:showLayer(
--         "ShoppingDialogLayer",
--         function(layer)
--             layer:showLayer(info_list, EMPTY_FUNC)
--             layer:setButton_confirm(
--                 "确定",
--                 function()
--                     ok_func()
--                 end
--             )
--             layer:setButton_close("取消", EMPTY_FUNC)
--         end
--     )
-- end

-- return DreamSalesModel
0000000
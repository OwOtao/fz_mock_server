local ShenBingDuanQiLayer = {}

--@RefType [app.models.ShenBing.DuanZao.ShenBingDuanZao#ShenBingDuanZao]
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")

--锻器 神兵完好度提升 roleType 1  欧冶子 2 家园铁匠 name 当前人物名字
function ShenBingDuanQiLayer:showLayer(roleType, name)
    if not roleType then
        print("给谁修？？？？？")
        return
    end

    local items =
        Helper:getDef(
        User:getRole():getItems(
            function(itemData)
                -- print("--------------------------------------", itemData.itemId)
                local _item = User:getRole():getOneItemByKey(itemData.itemId)

                if _item and _item.wpType == "神兵" then
                    return true
                end

                return false
            end
        ),
        {}
    )

    if MapIsEmpty(items) then
        PopText("你身上没有神兵")
        return
    end

    local nickName = "少侠"

    if roleType == 2 then
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        nickName = HomelandDesc:subChengHuText("#ch#")
    else
        nickName = "少侠"
    end
    PopupLayerController:showLayer(
        "ShenBingBagLayer",
        function(layer)
            layer:setRightName(name)
            layer:setTextWeight((#User:getRole():getItems()) .. "/" .. User:getRoleAttr("weight"))
            layer:setTextMoney("黄金：" .. User:getRole():getAttr("gold"))
            layer:showLayer()

            for k, itemData in pairs(items) do
                if itemData.type == "神兵" then
                    local _shenWeapon = User:getRole():getOneItemByKey(itemData.itemId)
                    if _shenWeapon ~= nil then
                        itemData.wanhaodu = _shenWeapon.wanhaodu
                    end
                end
                local data = {
                    id = itemData.id,
                    itemId = itemData.itemId,
                    count = itemData.count,
                    wanhaodu = Helper:getDef(itemData.wanhaodu, 100)
                }

                layer:pushItemToLeftList(
                    data,
                    function(item, func)
                        if func then
                            func()
                        end
                    end
                )
            end

            layer:btnLeftClickFunc(
                function()
                    PopupLayerController:hideLayer(
                        "ShenBingBagLayer",
                        function(layer)
                            layer:destory()
                        end
                    )
                end,
                "取消"
            )

            layer:btnRightClickFunc(
                function(leftList, rightList)
                    if MapIsEmpty(rightList) then
                        PopText("请选择兵器")
                        return
                    end

                    local _weapon = rightList[1]
                    --@RefType [app.models.role.Role#Role]
                    local player = User:getRole()
                    local weaponData = player:getItemWithOnlyId(_weapon.id)

                    local text = ""
                    local costGold = 500
                    local weapon = player:getOneItemByKey(weaponData.itemId)
                    if weaponData.type == "神兵" then
                        if roleType == 1 then
                            local Meridian = require("app.models.Meridian.Meridian")
                            local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
                            if User:getRole():isHaveImprintingId("lingbingyin") then
                                costGold = math.ceil(costGold * meridianBuffValue)
                            end
                            text = "你确定消耗一个金刚石和" .. tostring(costGold) .. "黄金来锻器提升神兵的完好度？"
                        elseif roleType == 2 then
                            text = "你确定消耗一个金刚石来锻器提升神兵的完好度？"
                        end
                    else
                        print("怎么有普通武器！！！")
                    end

                    local dialog = require("app.views.layer.DialogLayer.DialogALayer"):getInstance()
                    dialog:show(text)
                    dialog:setButton1(
                        "确定",
                        function()
                            if roleType == 1 and player:getAttr("gold") - costGold < 0 then
                                PopText("你的黄金不够，无法锻器。")
                                return
                            end
                            
                            if player:getItemCount("2019duanqi1") < 1 then
                                PopText(nickName .. "，若想通过锻器提升神兵完好度，需加入“金刚石”，但你身上并无此物。")
                                return
                            end
                            Audio:pauseMusic()
                            self.musicId = Audio:playEffect("DuanDa", true)
                            if roleType == 1 then
                                print("修理消耗了" .. costGold .. "黄金")
                                player:setAttr("gold", player:getAttr("gold") - costGold)
                            end
                            player:addItemCount("2019duanqi1", -1)
                            self:updateShenBingWeaponWanHaoDu(weaponData, roleType, name)
                            layer:destory()
                        end
                    )

                    dialog:setButton2(
                        "取消",
                        function()
                            dialog:hide()
                        end
                    )
                end,
                "锻器"
            )

            layer:setCondiPushRightList(
                function(leftList, rightList, item)
                    if #rightList >= 1 then
                        PopText("一次只能锻器一把")
                        return false
                    end
                    if item.wanhaodu < 100 then
                        PopText(nickName .. "，你的神兵已经破损，还是先修理一番吧。")
                        return false
                    elseif item.wanhaodu >= 120 then
                        PopText(nickName .. "，你的神兵已经足够完美了，无需锻器。")
                        return false
                    end

                    return true
                end
            )
        end
    )
end

--锻器 神兵提升完好度
function ShenBingDuanQiLayer:updateShenBingWeaponWanHaoDu(itemData, roleType, name)
    if itemData.type ~= "神兵" then
        print("怎么有普通武器！！！")
        return
    end
    local wanhaoduAf = 120
    local item = User:getRole():getOneItemByKey(itemData.itemId)
    ShenBingDuanZao:updateShenBingInfo({id = item.id, wanhaodu = wanhaoduAf})
    self:printUpdateText(roleType, name)
end

function ShenBingDuanQiLayer:printUpdateText(roleType, name)
    local currLayer = MainControllLayer:getCurrLayer()
    User:getRole():setFlag("锻造状态", "忙碌")

    local text = ShenBingDesc:getShenBingDuanQiText()

    local TIME = 2
    local maplayer = MainControllLayer:getLayer(currLayer)

    if currLayer == "MapLayer" then
        local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
        User:getRole():setFlag("PVP活动状态", "忙碌")
        MapRoleLayer:statusButtonFunc(
            false,
            function()
                PopText("兵器锻器中，请稍等")
            end
        )
        MapRoleLayer:exitButtonFunc(
            false,
            function()
                PopText("兵器锻器中，请稍等")
            end
        )
        maplayer:setUnmoveRoom(
            true,
            function()
                PopText("兵器锻器中，请稍等")
            end
        )
        maplayer._currMap:setCanLeave(false)
        maplayer:setNPCTouchEnabled(
            true,
            function()
                PopText("兵器锻器中，请稍等")
            end
        )

        for i = 1, #text do
            maplayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    text[i] = string.gsub(text[i], "#name#", name)
                    RichPrint("main", text[i])
                    if i == #text then
                        if self.musicId then
                            Audio:stopEffect(self.musicId)
                            self.musicId = nil
                        end
                        PopText("锻器成功！")
                        Audio:resumeMusic()
                        MapRoleLayer:statusButtonFunc(true)
                        MapRoleLayer:exitButtonFunc(true)
                        maplayer:setUnmoveRoom(false)
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                        User:getRole():setFlag("锻造状态", "空闲")
                        maplayer._currMap:setCanLeave(true)
                        maplayer:setNPCTouchEnabled(false)
                    end
                end
            )
        end
    end
end

return ShenBingDuanQiLayer
00000000000000
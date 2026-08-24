local ShenBingFixLayer = class("ShenBingFixLayer")
--@RefType [app.models.ShenBing.DuanZao.ShenBingDuanZao#ShenBingDuanZao]
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")
local repaireInfo = require("script.others.repairSummary").Sheet1
local repaireFormulas = require("script.others.repairFormula").Sheet1

local _worker = {
    skiLv = 0,
    name = "",
    nickName ="少侠"
}


function ShenBingFixLayer:startFix(itemData)
    if itemData.wanhaodu then
        itemData.wanhaodu = nil
    end

    local item = Item:getOneItemByKey(itemData.itemId)
    local wanhaodu = tonumber(item.wanhaodu)
    local curValue, maxValue = wanhaodu, 100
    local skillLv = _worker.skiLv
    local weaponType = 1  -- 0 普通兵器 1 神兵

    if itemData.type ~= "神兵" then
        maxValue = wanhaodu
        curValue = 0
        weaponType = 0
    end

    local roleType = 1  -- 1 自己 2Npc
    if _worker.roleType ~= 1 then
        roleType = 2
    end

    local formula = self:getFixFormula(roleType, weaponType, skillLv, curValue)

    local value = self:getAfterFixValue(curValue, maxValue, skillLv, formula)

    if weaponType == 1 then
        ShenBingDuanZao:updateShenBingInfo({id = item.id, wanhaodu = value})
    end
    
    self:printText(value)
end


--@desc: 修理的文本输出
--@author:Liang SongQiang
--@time:2017-12-25 11:07:25
--@wanhaodu: 神兵的完好度
function ShenBingFixLayer:printText(wanhaodu)
    local currLayer = MainControllLayer:getCurrLayer()
    User:getRole():setFlag("锻造状态","忙碌")

    local text = {}
    if _worker.roleType == 1 then
        text = ShenBingDesc:getShenBingFixText(1,math.min(wanhaodu,100))
    else
        text = ShenBingDesc:getShenBingFixText(2,wanhaodu)
    end

    local TIME = 2
    local maplayer = MainControllLayer:getLayer(currLayer)
    local name = _worker.name
    if _worker.name == "锻造台" then
        name = "你"
    end

    --@desc 有两个界面可进入修理界面，RichPrint 需区分
    if currLayer == "MapLayer" then
        local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
        User:getRole():setFlag("PVP活动状态", "忙碌")
        MapRoleLayer:statusButtonFunc(
            false,
            function ()
                PopText("兵器修理中，请稍等")
            end
        )
        MapRoleLayer:exitButtonFunc(
            false,
            function()
                PopText("兵器修理中，请稍等")
            end
        )
        maplayer:setUnmoveRoom(
            true,
            function()
                PopText("兵器修理中，请稍等")
            end
        )
        maplayer._currMap:setCanLeave(false)
        maplayer:setNPCTouchEnabled(
            true,
            function()
                PopText("兵器修理中，请稍等")
            end
        )

        for i = 1, #text do
            maplayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    text[i] = string.gsub(text[i], "#name#", name)
                    text[i] = string.gsub(text[i], "#nickName#", _worker.nickName)
                    RichPrint("main", text[i])
                    if i == #text then
                        if self.musicId then
                            Audio:stopEffect(self.musicId)
                            self.musicId = nil
                        end
                        Audio:resumeMusic()
                        MapRoleLayer:statusButtonFunc(true)
                        MapRoleLayer:exitButtonFunc(true)
                        maplayer:setUnmoveRoom(false)
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                        User:getRole():setFlag("锻造状态","空闲")
                        maplayer._currMap:setCanLeave(true)
                        maplayer:setNPCTouchEnabled(false)
                    end
                end
            )
        end
    elseif currLayer == "ShenBingLayer" then
        maplayer:setBtnCondition(false, "兵器修理中，请稍等")
        local title = MainControllLayer:getLayer("TitleLayer")
        title:ButtonBack(
            function()
                PopText("兵器修理中，请稍等")
            end
        )
        for i = 1, #text do
            maplayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    text[i] = string.gsub(text[i], "#name#", name)
                    text[i] = string.gsub(text[i], "#nickName#",  _worker.nickName)
                    maplayer:print(text[i])
                    if i == #text then
                        maplayer:setBtnCondition(true)
                        title:setTitleBack()
                        User:getRole():setFlag("锻造状态","空闲")
                        if self.musicId then
                            Audio:stopEffect(self.musicId)
                            self.musicId = nil
                        end
                        Audio:resumeMusic()
                    end
                end
            )
        end
    end
end

--@desc:
--@author:Liang SongQiang
--@time:2017-12-19 15:27:37
--@roleType: 1:自己，2，欧冶子 ，3. 铁匠 4 家园铁匠
function ShenBingFixLayer:showLayer(roleType, skillLv, name)
    if not roleType then
        print("给谁修？？？？？")
        return
    end

    local ratio_1 = 0
    local ratio_2 = 0

    if roleType == 1 then
        --@RefType [app.models.role.Role#Role]
        local role = User:getRole()
        local sLv = role:getSkillLv("duanzaozhishu")
        if (not sLv or sLv == 0) then
            PopText("你没有学锻造之术吧")
            return
        --sLv = 200
        end
        _worker.skiLv = sLv
        _worker.name = "锻造台"
        _worker.roleType = roleType
    elseif roleType == 2 then
        _worker.skiLv = OU_SKILL_LV
        _worker.name = "欧冶子"
        _worker.roleType = roleType
        _worker.nickName = "少侠"
    elseif roleType == 3 or roleType == 4 then
        ratio_1 = 200
        ratio_2 = 1.2
        if skillLv and type(skillLv) == "number" then
            _worker.skiLv = skillLv
        else
            _worker.skiLv = TIEJIANG_SKILL_LV
        end

        if name then
            _worker.name = name
        else
            _worker.name = "铁匠"
        end

        if roleType==4 then 
            local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
            _worker.nickName = HomelandDesc:subChengHuText("#ch#")
        else
            _worker.nickName = "少侠"
        end
    end
    _worker.roleType = roleType

    local items =
        Helper:getDef(
        User:getRole():getItems(
            function(itemData)
                local typeMap = {
                    ["剑"] = true,
                    ["刀"] = true,
                    ["棍"] = true,
                    ["鞭"] = true,
                    ["双持"] = true,
                    ["乐器"] = true,
                    ["暗器"] = true,
                }
                -- print("--------------------------------------", itemData.itemId)
                local _item = Item:getOneItemByKey(itemData.itemId)
                if _item == nil then --老神兵
                    return false
                end
                if _item.wpType == "神兵" then
                    return true
                end

                if typeMap[_item.type] then
                    return true
                end

                return false
            end
        ),
        {}
    )

    if MapIsEmpty(items) then
        PopText("你身上没有兵器")
        return
    end

    local fixItems = {}
    for k, itemData in pairs(items) do
        if itemData.type == "神兵" then
            local _shenWeapon = Item:getOneItemByKey(itemData.itemId)
            if _shenWeapon ~= nil then
                itemData.wanhaodu = _shenWeapon.wanhaodu
            end
        end

        local wanhaodu = Helper:getDef(itemData.wanhaodu, 100)
        local name = Item:getOneItemByKey(itemData.itemId).name
        if itemData.wanhaodu == 0 then
            name = name .. "(损)"
        end

        local data = {
            id = itemData.id,
            wanhaodu = wanhaodu,
            name = name
        }

        table.insert(fixItems, data)
    end

    PopupLayerController:showLayer(
        "NewShenBingBagLayer",
        function(layer)
            layer:setRightName(_worker.name)
            layer:setTextWeight((#User:getRole():getItems()) .. "/" .. User:getRoleAttr("weight"))
            layer:setTextMoney("黄金：" .. User:getRole():getAttr("gold"))
            layer:showLayer()

            layer:setLeftItemsInfo(fixItems)
            layer:setRightItemsInfo()

            layer:setConditionPushRightFunc(function(item)
                local rightItems = layer:getRightItemsInfo()
                if #rightItems >= 1 then
                    PopText("一次只能修理一把")
                    return false
                end

                if item.wanhaodu >= 100 then
                    PopText("该武器已无需修理。")
                    return false
                end

                return true
            end)

            layer:setConditionPushLeftFunc(function()
                return true
            end)

            layer:setOutGoingCKFunc(function(item, func)
                local leftItems = layer:getLeftItemsInfo()
                local rightItems = {}
                for i = #leftItems, 1, -1 do
                    if item.id == leftItems[i].id then
                        local info = {
                            id = item.id,
                            wanhaodu = item.wanhaodu,
                            name = item.name,
                            text = "完好度："..tostring(item.wanhaodu)
                        }
                        table.insert(rightItems,info)
                        table.remove(leftItems, i)
                        break
                    end
                end

                layer:setLeftItemsInfo(leftItems)
                layer:setRightItemsInfo(rightItems)

                if func then
                    func()
                end
            end)

            layer:setBePutCKFunc(function(item, func)
                local leftItems = layer:getLeftItemsInfo()
                local info = {
                    id = item.id,
                    wanhaodu = item.wanhaodu,
                    name = item.name
                }
                table.insert(leftItems,info)

                layer:setLeftItemsInfo(leftItems)
                layer:setRightItemsInfo()

                if func then
                    func()
                end
            end)

            layer:btnLeftClickFunc(
                function()
                    layer:destory()
                end,
                "取消"
            )

            layer:btnRightClickFunc(
                function()
                    local rightItems = layer:getRightItemsInfo() 
                    if MapIsEmpty(rightItems) then
                        PopText("请选择要修理的兵器")
                        return
                    end

                    local _weapon = rightItems[1]
                    local plyaer = User:getRole()
                    local weaponData = plyaer:getItemWithOnlyId(_weapon.id)

                    local text = "你确定消耗25精力修理这把兵器么？"
                    local costGold = 0
                    local weapon = Item:getOneItemByKey(weaponData.itemId)
                    if weaponData.type == "神兵" then
                        if roleType == 1 then
                            text = "你确定消耗25精力修理这把神兵么？"
                        end
                        local Meridian = require("app.models.Meridian.Meridian")
                        local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
                        if roleType == 2 then
                            costGold = math.floor(100 + 1.5 * weapon.cuilianCount)
                            if User:getRole():isHaveImprintingId("lingbingyin") then
                                costGold = math.ceil(costGold * meridianBuffValue)
                            end
                            text = "修理这把神兵需要" .. costGold .. "黄金，你确定么？"
                        elseif roleType == 3 or roleType == 4 then
                            costGold = math.floor((1 + _worker.skiLv / 1000) * 60 + 1.2 * weapon.cuilianCount)
                            if User:getRole():isHaveImprintingId("lingbingyin") then
                                costGold = math.ceil(costGold * meridianBuffValue)
                            end
                            text = "修理这把神兵需要" .. costGold .. "黄金，你确定么？"
                        end
                    else
                        if roleType == 2 or roleType == 3 or roleType == 4 then
                            costGold = math.floor(weapon.damage * 1.25 + 20)
                            text = "修理这把兵器需要" .. costGold .. "黄金，你确定么？"
                        end
                    end

                    local dialog = require("app.views.layer.DialogLayer.DialogALayer"):getInstance()
                    dialog:show(text,"提示：修理普通武器必定会成功，神兵则有可能打坏哦")
                    dialog:setButton1(
                        "确定",
                        function()
                            local costJing = 0

                            if roleType ~= 1 and plyaer:getAttr("gold") - costGold < 0 then
                                PopText("你黄金不够，去苏州城王合计处看看吧")
                                return
                            end

                            if roleType == 1 then
                                costJing = 25
                                if plyaer:getFinalAttr("jing") < costJing then
                                    PopText("你精力不足，无法对兵器进行修理")
                                    return
                                end
                            end

                            Audio:pauseMusic()
                            self.musicId = Audio:playEffect("DuanDa",true)

                            print("修理等级" .. _worker.skiLv .. "级")

                            if costGold ~= 0 then
                                plyaer:setAttr("gold", plyaer:getAttr("gold") - costGold)
                                print("修理消耗了" .. costGold .. "黄金")
                            end
                            
                            if costJing ~= 0 then
                                plyaer:setAttr("jing", plyaer:getFinalAttr("jing") - costJing)
                            end
                            
                            self:startFix(weaponData)

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
                "修理"
            )
            layer:refreshUI()
            layer:showLayer()
        end
    )
end

function ShenBingFixLayer:getFixFormula(roleType, weaponType, skillLv, wanhaodu)
    local formuluId

    print("----------参数-------------")
    print("------修理者类型：",roleType)
    print("------兵器类型:",weaponType)
    print("------武器完好度:",wanhaodu)
    print("------锻造之术等级:",skillLv)
    print("--------------------------")

    for k, v in pairs(repaireInfo) do
        if v.repairerType == roleType and v.weaponType == weaponType then
            if v.conditionType == 0 then
                formuluId = v.repairFormula
                break
            elseif v.conditionType == 1 then
                if skillLv >= v.conditionMin and skillLv <= v.conditionMax then
                    formuluId = v.repairFormula
                    break
                end
            elseif v.conditionType == 2 then
                if wanhaodu >= v.conditionMin and wanhaodu <= v.conditionMax then
                    formuluId = v.repairFormula
                    break
                end
            end
        end
    end

    assert(formuluId, "ShenBingFixLayer:getFixFormula is not found in repaireInfo")

    local formulas = {}

    for k, v in pairs(repaireFormulas) do
        if v.repairFormula == formuluId then
            formulas[tostring(v.id)] = v
        end
    end

    if MapIsEmpty(formulas) == false then
        local id = Helper:RandomByWeight(formulas, "randomValue", "id")
        return formulas[tostring(id)]
    else
        assert(formuluId, "ShenBingFixLayer:getFixFormula is not found in repaireFormulas")      
    end
end

--修理后兵器完好度 = min( 修理前兵器完好度 + floor(修理基础值+random(修理随机值min,修理随机值max)*(1+锻造之术等级X锻造等级影响系数)) , 
--固定修理上限 , 兵器完好度上限 )
function ShenBingFixLayer:getAfterFixValue(currValue, maxValue, skillLv, formulu)
    assert(formulu, "ShenBingFixLayer:addWanHaoDu formulu is null")

    local foundation = formulu.foundation
    local randomMin = formulu.randomMin
    local randomMax = formulu.randomMax
    local coefficient  = formulu.coefficient 
    local limit  = formulu.limit
    local randomValue = math.random(randomMin, randomMax)

    local addValue = math.floor(foundation + randomValue * (1 + skillLv * coefficient))
    return math.min(currValue + addValue, maxValue, limit)
end


return ShenBingFixLayer
0
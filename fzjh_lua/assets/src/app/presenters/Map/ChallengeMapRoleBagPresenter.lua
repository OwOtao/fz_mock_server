local class = require("third.class.NewClass")
local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local ChallengeMapRoleBagPresenter = {}

function ChallengeMapRoleBagPresenter:create()
    local p = ChallengeMapRoleBagPresenter.new()
    return p
end

function ChallengeMapRoleBagPresenter:setInput(iBagModel)
    self.__input = iBagModel
end

function ChallengeMapRoleBagPresenter:setOutput(iBagView)
    self.__output = iBagView
end

function ChallengeMapRoleBagPresenter:setRole(role)
    self.__input:setRole(role)
end

function ChallengeMapRoleBagPresenter:showBagList()
    local bagList = self.__input:getRoleBagItems()
    for __,itemInfo in ipairs(bagList) do
        itemInfo.func = function()
            self:__initItemFunc(itemInfo.itemId,itemInfo.id)
        end
    end

    local defaultList = self.__input:getRoleDefaultItems()
    for __,itemInfo in ipairs(defaultList) do
        itemInfo.func = function()
            self:__initItemFunc(itemInfo.itemId,itemInfo.id)
        end
    end
    self.__output:showBagList(bagList,defaultList)
end

function ChallengeMapRoleBagPresenter:setBagWeight()
    local role = self.__input:getRole()
    local items = role:getItems()
    local weight = role:getAttr("weight")

    if MapIsEmpty(items) then
		items = {}
	end

	if tonumber(weight) == nil or tonumber(weight) < 0 then
		weight = 0
	end

    self.__output:setWeightUI(tostring(#items) .. "/" .. tostring(weight))
end

function ChallengeMapRoleBagPresenter:__initItemFunc(itemId,onlyId)
    self.__output:beforeClickItemFunc()

    if itemId == "shuxiang" then
        self:__clickShuXiang()
        return
    end

    if itemId == "decorativeBox" then
        self:__clickDecorativeBox()
        return
    end

    if itemId == "literaryBox" then
        self:__clickLiteraryBox()
        return
    end

    if itemId == "medicinalBox" then
        self:__clickMedicinalBox()
        return
    end

    if itemId == "smeltBox" then
        self:__clickSmeltBox()
        return
    end

    if itemId == "bookRack" then
        self:__clickBookRack()
        return
    end

    local itemAttr = self.__input:getOneItemByKey(itemId)
    if itemAttr.equipPart == "weapon" then
        self:__clickWeapon(itemId,onlyId)
        return
    end

    local name = self.__input:getItemName(itemId)
    local itemType = self.__input:getItemType(itemId)
    local desc = self.__input:getItemDesc(itemId)
    local timeDesc = self.__input:getItemTimeDesc(itemId,onlyId)
    local rightBtnName = self.__input:getItemRightName(itemId,onlyId)
    local leftBtnName = self.__input:getItemLeftName(itemId)

    self.__output:setBagDescLayerItemName(name)
    self.__output:setBagDescLayerItemType(itemType)
    self.__output:setBagDescLayerItemDesc(desc)

    if timeDesc then
        self.__output:setBagDescLayerTimeDescText(timeDesc)
        self.__output:setBagDescLayerTimeDescVisible(true)
    else
        self.__output:setBagDescLayerTimeDescVisible(false)
    end

    if rightBtnName then
        self.__output:setBagDescLayerRightButtonName(rightBtnName)
        self.__output:setBagDescLayerRightButtonVisible(true)
        self.__output:setBagDescLayerRightButtonFunc(function()
            self:__initItemRightFunc(itemId,onlyId)
        end)
    else
        self.__output:setBagDescLayerRightButtonVisible(false)
    end

    if leftBtnName then
        self.__output:setBagDescLayerLeftButtonName(leftBtnName)
        self.__output:setBagDescLayerLeftButtonVisible(true)
        self.__output:setBagDescLayerLeftButtonFunc(function()
            self:__initItemLeftFunc(itemId,onlyId)
        end)
    else
        self.__output:setBagDescLayerLeftButtonVisible(false)
    end

    self.__output:itemDescShow(true)
    self.__output:clickNormalItem()
end

function ChallengeMapRoleBagPresenter:__clickShuXiang()
    PopupLayerController:showLayer("BookCaseLayer", function(layer)
        layer:showLayer()
    end)
    self.__output:clickShuXiang()
end

function ChallengeMapRoleBagPresenter:__clickDecorativeBox()
    PopupLayerController:showLayer("DecorativeBoxLayer", function(layer)
        layer:showLayer(function()
            self:showBagList()
        end)
    end)
    self.__output:clickDecorativeBox()
end

function ChallengeMapRoleBagPresenter:__clickLiteraryBox()
    PopupLayerController:showLayer("BookLiteraryLayer", function(layer)
        layer:showLayer(false)
    end)
    self.__output:clickLiteraryBox()
end

function ChallengeMapRoleBagPresenter:__clickMedicinalBox()
    PopupLayerController:showLayer("MedicinalLayer",function(layer)
        layer:showLayer(true)
    end)
    self.__output:clickMedicinalBox()
end

function ChallengeMapRoleBagPresenter:__clickSmeltBox()
    PopupLayerController:showLayer("SmeltBoxLayer",function(layer)
        layer:showLayer(true)
    end)
    self.__output:clickSmeltBox()
end

function ChallengeMapRoleBagPresenter:__clickBookRack()
    PopupLayerController:showLayer("BookRackUI",function(layer)
        layer:showLayer()
    end)
    self.__output:clickBookRack()
end

function ChallengeMapRoleBagPresenter:__clickWeapon(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)

    PopupLayerController:showLayer("BagDescLayer",function(layer)
        layer:setRole(role)
        layer:setRefreshListFunc(function()
            self:showBagList()
        end)
        layer:setPrepareButtonVisible(true,item)
        if itemAttr.wpType == "神兵" then
            layer:setCangKuButtonVisible("放仓\n入库")
        else
            layer:setCangKuButtonVisible()
        end
        layer:setPrepareFunc(function(funcType)
            if funcType == "prepare" and itemAttr.wpType == "神兵" then
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)
    
                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        ChallengeMapSystem:getInstance():removeBuff(buffId,role)
                    end
                end
            end
        end)
        layer:setEquipItemFunc(function(item, itemAttr)
            self:__equipOneItem(item, itemAttr)
        end)

        layer:showLayer(item,itemAttr)
    end)
    self.__output:clickWeapon(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__initWeaponBagDescLayer(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__initItemLeftFunc(itemId,onlyId)
    local itemAttr = self.__input:getOneItemByKey(itemId)

    if itemId == "lingshi1" then
        self:__lingShiLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "面具" or itemAttr.type == "信物" or itemAttr.type == "挂饰" then
        self:__faceOrXinWuOrGuaShiLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
        self:__bookCaseOrActiveZhaoBookCaseLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "书籍" or itemAttr.type == "锻造图谱" or itemAttr.type == "毒术书籍" then
        self:__libraryBooksOrPoisonLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "房契" then
        self:__fangQiLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
        self:__shenBingMaterialLeftBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.upgrade ~= nil then
        self:__upgradeItemLeftBtnFunc(itemId,onlyId)
        return
    end
end

function ChallengeMapRoleBagPresenter:__lingShiLeftBtnFunc(itemId,onlyId)
    self.__output:lingShiLeftBtnFunc(function()
        local role = self.__input:getRole()
        role:addItemCount("lingshi1", - 1)
        self:showPanelBag()
    end)
end

function ChallengeMapRoleBagPresenter:__faceOrXinWuOrGuaShiLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()

    if role:checkItemIsEquip(onlyId) then
        self.__output:popText("装备已经穿上，请先卸下再放入装饰箱")
        return
    end

    if role:getDecorativeCount(onlyId) > 0 then
        local item,i = role:getItemWithOnlyId(onlyId)
        local itemAttr = role:getOneItemByKey(itemId)
        local bagItems = role:getItems()

        local typeDsc = ""
        if itemAttr.type == "挂饰" then
            typeDsc = "你已经拥有相同的挂饰，是否还要放入装饰箱里。多个相同挂饰只显示一个。"
        else
            typeDsc = "你已经拥有相同的饰品，装饰箱内相同饰品只显示一个，是否放入？（可在家园雇佣绣女，将多余饰品转化为饰品材料）"
        end
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(typeDsc)
        dialog:setRichText(typeDsc)
        dialog:setButton1("是", function()
            if role:addDecorative(itemId, item.count) ~= true then
                return
            end

            if not MapIsEmpty(bagItems) then
                table.remove(bagItems, i)
            end

            self.__output:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入装饰箱")
            self:showPanelBag()
            self:setBagWeight()
        end)

        dialog:setButton2("否", function()
            dialog:hide()
        end)
    else
        if role:addDecorative(item.itemId, item.count) ~= true then
            return
        end

        if not MapIsEmpty(bagItems) then
            table.remove(bagItems, i)
        end

        self.__output:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入装饰箱")
        self:showPanelBag()
        self:setBagWeight()
    end

    self.__output:faceOrXinWuOrGuaShiLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__bookCaseOrActiveZhaoBookCaseLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)

    if role:addItemCount(item.itemId, item.count) ~= true then
        return
    end

    local itemAttr = role:getOneItemByKey(item.itemId)
    local bagItems = role:getItems()

    if not MapIsEmpty(bagItems) then
        table.remove(bagItems, i)
    end

    self:showPanelBag()
    self:setBagWeight()

    self.__output:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入书箱")
    self.__output:bookCaseOrActiveZhaoBookCaseLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__libraryBooksOrPoisonLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)

    if role:addLiteraryBox(item.itemId, item.count) ~= true then
        return
    end

    local bagItems = role:getItems()
    local itemAttr = role:getOneItemByKey(item.itemId)

    if not MapIsEmpty(bagItems) then
        table.remove(bagItems, i)
    end

    local BookLiterary = require("app.models.book.BookLiterary")

    self.__output:popText("将"..itemAttr.name.." X"..item.count.."放入书匣")

    local count = role:getLiteraryCount(BookLiterary:getLiteraryByItemId(item.itemId).id)
    if count <= 10 and count * BookLiterary:getLiteraryByItemId(item.itemId).jifen <= BookLiterary:getLiteraryByItemId(item.itemId).jifenlimit then
        self.__output:popText("藏书评价 + " .. BookLiterary:getLiteraryByItemId(item.itemId).jifen)
    end
        
    if count == 1 then
        if itemAttr.type == "毒术书籍" then
            PoisonFormula:unlockPoisonFormulaByBookLvUp(0,1,item.itemId)
        elseif itemAttr.type == "锻造图谱" then
            ForgeSkill:addUserFoegeKnowledge(item.itemId)
        end
    end

    self:showPanelBag()
    self:setBagWeight()

    self.__output:libraryBooksOrPoisonLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__fangQiLeftBtnFunc(itemId,onlyId)
    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
    FangQiModel:useItemToUserMap(function()
        self.__output:hide()
    end)

    self.__output:fangQiLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__shenBingMaterialLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)
    
    if role:addItemCount(item.itemId, item.count) ~= true then
        return
    end

    local bagItems = role:getItems()
    local itemAttr = role:getOneItemByKey(item.itemId)

    if not MapIsEmpty(bagItems) then
        table.remove(bagItems, i)
    end

    self:showPanelBag()
    self:setBagWeight()

    self.__output:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入冶炼箱")
    self.__output:shenBingMaterialLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__upgradeItemLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    if role:checkItemIsEquip(onlyId) then
        self:popText("装备已经穿上，请先卸下再升级")
        return
    end

    local item, i = role:getItemWithOnlyId(onlyId)
    local bagItems = role:getItems()
    local itemAttr = role:getOneItemByKey(itemId)

    itemAttr:upgradeItem(role, function()
        if not MapIsEmpty(bagItems) then
            table.remove(bagItems, i)
        end
    end)

    self:showBagList()

    self.__output:upgradeItemLeftBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__initItemRightFunc(itemId,onlyId)
    local itemAttr = self.__input:getOneItemByKey(itemId)

    if itemAttr.id == "shimenwupin29" or itemAttr.id == "shimenwupin30" or itemAttr.id == "shimenwupin32" or itemAttr.id == "shimenwupin33" then
        self:__activityFamilyItemsRightBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "房契" then
        self:__fangQiRightBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "地契" then
        self:__diQiRightBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.canUse == ITEM_STATE_FALSE then
        self:__equipsOrNotUseTypeRightBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.id == "zhongyuanlazhu1" or itemAttr.id == "zhongyuannuomi1" or itemAttr.id == "zhongyuuangouyuan1" or 
        itemAttr.id == "zhongyuantaomujian1" or itemAttr.id == "zhongyuantaotongqian1"then
        self:__zhongYuanFestivalItemsRightBtnFunc(itemId,onlyId)
        return
    end

    if itemAttr.type == "历练任务" then
        self:__liLianTaskItemsRightBtnFunc(itemId,onlyId)
        return
    end

    self:__itemUseRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__itemUseRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item,i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)
    itemAttr:useItem(function()
        self:showBagList()
        self:setBagWeight()
    end,self,nil,nil,role,item.count)

    self.__output:itemUseRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__activityFamilyItemsRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    itemAttr:useItem(function()
        self:showBagList()
        self:setBagWeight()
    end, self,nil,nil,role,1)

    self.__output:activityFamilyItemsRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__fangQiRightBtnFunc(itemId,onlyId)
    local fqModel = require("app.models.HomelandModel.FangQiModel")
    fqModel:viewFangQi()

    self.__output:fangQiRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__diQiRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local DiQiModel = require("app.models.HomelandModel.DiQiModel")
    DiQiModel:viewDiQi(itemAttr.id,itemAttr.dpId,function ()
        self.__output:hide()
    end)

    self.__output:diQiRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__equipsOrNotUseTypeRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local item , i = role:getItemWithOnlyId(onlyId)

    self:__equipOneItem(item,itemAttr)

    self:showBagList()
    self:setBagWeight()

    FubenClient:setValue("equips", role:getAttr("equips"))

    self.__output:equipsOrNotUseTypeRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__zhongYuanFestivalItemsRightBtnFunc(itemId,onlyId)
    self.__output:zhongYuanFestivalItemsRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__liLianTaskItemsRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local TaskItemModel = require("app.models.TaskItems.TaskItemModel")
	TaskItemModel:useTaskItem(itemAttr)

    self.__output:liLianTaskItemsRightBtnFunc(itemId,onlyId)
end

function ChallengeMapRoleBagPresenter:__equipOneItem(item, itemAttr)
    if not item then
		return
	end

	if item.type == "神兵" then
		if itemAttr.wanhaodu == 0 then
			self.__output:popText("该武器已被损坏")
			return
		end
	else
		if item.wanhaodu and item.wanhaodu == 0 then
			self.__output:popText("该武器已被损坏")	
			return
		end
	end

    local role = self.__input:getRole()

	local desc = ""

	if not role:checkItemIsEquip(item.id) then
        if itemAttr.equipPart == "weapon" then
            local weapon = role:getEquipByName("weapon")
            if weapon then
                local itemId = weapon.itemId
                if role:isShengBing(itemId) then
                    local shenBing = role:getOneItemByKey(itemId)
                    local buffs = ShenBingEffct:getShenBingNormalBuff(shenBing)

                    if MapIsEmpty(buffs) == false then
                        for __,buffId in ipairs(buffs) do
                            ChallengeMapSystem:getInstance():removeBuff(buffId,role)
                        end
                    end
                end
            end
        end

		role:setEquipByName(itemAttr.equipPart, item)
		desc = itemAttr.equipText

		if itemAttr.wpType == "神兵" then
            do
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)

                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        ChallengeMapSystem:getInstance():addBuff(buffId,role)
                    end
                end
            end
            
			desc = ShenBingDesc:getWeaponEquipText(itemAttr)
		end
	else
		role:setEquipByName(itemAttr.equipPart, nil)
		desc = itemAttr.unwieldText
		if itemAttr.wpType == "神兵" then
            do
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)

                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        ChallengeMapSystem:getInstance():removeBuff(buffId,role)
                    end
                end
            end

			desc = ShenBingDesc:getWeaponTakeOffText(itemAttr)
		end
	end

	desc = string.gsub(desc, "$N", "你")
	desc = string.gsub(desc, "$w", itemAttr.name)
	desc = string.gsub(desc, "$W", itemAttr.name)

	self.__output:richPrint("main", "WHT" .. tostring(desc))
    self.__output:equipOneItem(item, itemAttr)
end

return class("ChallengeMapRoleBagPresenter", {}, ChallengeMapRoleBagPresenter)
0000000000000000
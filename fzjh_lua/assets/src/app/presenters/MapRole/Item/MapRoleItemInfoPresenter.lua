--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-08 17:55:02
--]]
local class = require("third.class.NewClass")

local MapRoleItemInfoPresenter = {}

function MapRoleItemInfoPresenter:create()
    local p = MapRoleItemInfoPresenter.new()
    return p
end

function MapRoleItemInfoPresenter:setInput(model)
    self.__input = model
end

function MapRoleItemInfoPresenter:setBagPresenter(bagPresenter)
    self.__bagPresenter = bagPresenter
end

function MapRoleItemInfoPresenter:setUI(ui)
    self.__ui = ui
end

function MapRoleItemInfoPresenter:showPresenter(itemId,onlyId)
    local name = self.__input:getItemName(itemId)
    local itemType = self.__input:getItemType(itemId)
    local desc = self.__input:getItemDesc(itemId)
    local rightBtnName = self.__input:getItemRightName(itemId,onlyId)
    local leftBtnName = self.__input:getItemLeftName(itemId)

    self.__ui:setTextItemName(name)
    self.__ui:setTextItemType(itemType)
    self.__ui:setTextItemDesc(desc)
    self.__ui:setPanelItemFunc(function()
        self:hidePresenter()
    end)

    if rightBtnName then
        self.__ui:setRightButtonName(rightBtnName)
        self.__ui:setRightButtonVisible(true)
        self.__ui:setRightButtonFunc(function()
            self:__initItemRightFunc(itemId,onlyId)
        end)
    else
        self.__ui:setRightButtonVisible(false)
    end

    if leftBtnName then
        self.__ui:setLeftButtonName(leftBtnName)
        self.__ui:setLeftButtonVisible(true)
        self.__ui:setLeftButtonFunc(function()
            self:__initItemLeftFunc(itemId,onlyId)
        end)
    else
        self.__ui:setLeftButtonVisible(false)
    end

    self:setSchedule(itemId,onlyId)
    
    self.__ui:showUI()

    self:playShowAnim()
end

function MapRoleItemInfoPresenter:hidePresenter()
    self:unschedule()
    
    self:playHideAnim()

    self.__bagPresenter:destroyMapRoleItemInfoPresenter()
end

function MapRoleItemInfoPresenter:playShowAnim()
    local panel = self.__ui:getPanelItemInfo()
    panel:setVisible(true)
    local actionTag = panel:getActionTagByName("move")
    panel:stopActionByTag(actionTag)
    panel:move(cc.p(380, 1610))
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1440)), cc.FadeIn:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
            end
        )
    )
    action:setTag(actionTag)
    panel:runAction(action)
end

function MapRoleItemInfoPresenter:playHideAnim()
    local panel = self.__ui:getPanelItemInfo()
	local actionTag = panel:getActionTagByName("move")
	panel:stopActionByTag(actionTag)
	panel:setCascadeOpacityEnabled(true)
	panel:callAllChild(function(child)
		child:setCascadeOpacityEnabled(true)
	end)
	local action = cc.Sequence:create(
	cc.Spawn:create(
	cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1536)),
	cc.FadeOut:create(UI_ANIM_DURATION)
	),
	cc.CallFunc:create(
	function()
        panel:setVisible(false)
		PopupLayerController:hideLayer("MapRoleItemUI",function( ui )
            ui:hideUI()
        end,0)
	end))
	action:setTag(actionTag)
	panel:runAction(action)
end

function MapRoleItemInfoPresenter:__initItemRightFunc(itemId,onlyId)
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

    
	if itemAttr.type == "奇遇" then
		self:__qiYuTypeRightBtnFunc(itemId,onlyId)
        return
	end

    self:__itemUseRightBtnFunc(itemId,onlyId)
end



function MapRoleItemInfoPresenter:__initItemLeftFunc(itemId,onlyId)
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

function MapRoleItemInfoPresenter:__lingShiLeftBtnFunc(itemId,onlyId)
    local mapLayer = MainControllLayer:getLayer("MapLayer")
    if mapLayer._currMap:canLeaveRoom() == false then
        self:popText("请专注眼前事，莫要分心！")
        return
    end

    local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
    if RoleTaskControllor:clickMapLayer(self.__input:getRole()) == false then
        return
    end

	self:hidePresenter()

    local ShenShu = require("app.views.layer.ShenShu.ShenShuLayer")
    ShenShu:shouLayer(2, mapLayer, function()
        local role = self.__input:getRole()
        role:addItemCount("lingshi1", - 1)
        self.__bagPresenter:hideMainPresenter()
    end)
end

function MapRoleItemInfoPresenter:__faceOrXinWuOrGuaShiLeftBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()

    if role:checkItemIsEquip(onlyId) then
        self:popText("装备已经穿上，请先卸下再放入装饰箱")
        return
    end
    
    local item,i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)
    local bagItems = role:getItems()

    if role:getDecorativeCount(onlyId) > 0 then
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

            self:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入装饰箱")
            self.__bagPresenter:showBagList()
            self.__bagPresenter:setBagWeight()
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

        self:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入装饰箱")
        self.__bagPresenter:showBagList()
        self.__bagPresenter:setBagWeight()
    end

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__bookCaseOrActiveZhaoBookCaseLeftBtnFunc(itemId,onlyId)
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

    self.__bagPresenter:showBagList()
    self.__bagPresenter:setBagWeight()

    self:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入书箱")

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__libraryBooksOrPoisonLeftBtnFunc(itemId,onlyId)
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

    self:popText("将"..itemAttr.name.." X"..item.count.."放入书匣")

    local count = role:getLiteraryCount(BookLiterary:getLiteraryByItemId(item.itemId).id)
    if count <= 10 and count * BookLiterary:getLiteraryByItemId(item.itemId).jifen <= BookLiterary:getLiteraryByItemId(item.itemId).jifenlimit then
        self:popText("藏书评价 + " .. BookLiterary:getLiteraryByItemId(item.itemId).jifen)
    end
        
    if count == 1 then
        if itemAttr.type == "毒术书籍" then
            PoisonFormula:unlockPoisonFormulaByBookLvUp(0,1,item.itemId)
        elseif itemAttr.type == "锻造图谱" then
            ForgeSkill:addUserFoegeKnowledge(item.itemId)
        end
    end

    self.__bagPresenter:showBagList()
    self.__bagPresenter:setBagWeight()

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__fangQiLeftBtnFunc(itemId,onlyId)
    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
    FangQiModel:useItemToUserMap(function()
    end)
    self:hidePresenter()
    self.__bagPresenter:hideMainPresenter()
end

function MapRoleItemInfoPresenter:__shenBingMaterialLeftBtnFunc(itemId,onlyId)
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

    self.__bagPresenter:showBagList()
    self.__bagPresenter:setBagWeight()

    self:popText("将" .. itemAttr.name .. " X" .. item.count .. "放入冶炼箱")
    
    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__upgradeItemLeftBtnFunc(itemId,onlyId)
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

    self.__bagPresenter:showBagList()

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__qiYuTypeRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item,i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)
    itemAttr:useItem(function()
        self.__bagPresenter:hideMainPresenter()
    end,nil,nil,nil,role,item.count)

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__itemUseRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local item,i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)
    itemAttr:useItem(function()
        self.__bagPresenter:showBagList()
        self.__bagPresenter:setBagWeight()
    end,nil,nil,nil,role,item.count)

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__activityFamilyItemsRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    itemAttr:useItem(function()
        self.__bagPresenter:showBagList()
        self.__bagPresenter:setBagWeight()
    end, nil,nil,nil,role,1)

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__fangQiRightBtnFunc(itemId,onlyId)
    local fqModel = require("app.models.HomelandModel.FangQiModel")
    fqModel:viewFangQi()

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__diQiRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local DiQiModel = require("app.models.HomelandModel.DiQiModel")
    DiQiModel:viewDiQi(itemAttr.id,itemAttr.dpId,function ()
        self.__bagPresenter:hideMainPresenter()
    end)

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__equipsOrNotUseTypeRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local item , i = role:getItemWithOnlyId(onlyId)

    self.__bagPresenter:__equipOneItem(item,itemAttr)

    self.__bagPresenter:showBagList()
    self.__bagPresenter:setBagWeight()

    FubenClient:setValue("equips", role:getAttr("equips"))

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__zhongYuanFestivalItemsRightBtnFunc(itemId,onlyId)
    self:hidePresenter()
end

function MapRoleItemInfoPresenter:__liLianTaskItemsRightBtnFunc(itemId,onlyId)
    local role = self.__input:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    local TaskItemModel = require("app.models.TaskItems.TaskItemModel")
	TaskItemModel:useTaskItem(itemAttr)

    self:hidePresenter()
end

function MapRoleItemInfoPresenter:setSchedule(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)

    if itemAttr and item then
        self.__ui:scheduleUnique(
            function()
                local cdPercent = self.__input:getItemCdPercent(itemId)
                if cdPercent then
                    self.__ui:setLoadingBarPercent(cdPercent)
                    self.__ui:setLoadingBarVisible(true)
                else
                    self.__ui:setLoadingBarVisible(false)
                end
    
                local timeDesc = self.__input:getItemTimeDesc(itemId,onlyId)
    
                if timeDesc then
                    self.__ui:setTextItemTimeDesc(timeDesc)
                    self.__ui:setItemTimeDescVisible(true)
                else
                    self.__ui:setItemTimeDescVisible(false)
                end
            end,
            0,
            "itemSchedule"
        )
    end
end

function MapRoleItemInfoPresenter:unschedule()
    self.__ui:unscheduleWithTag("itemSchedule")
end

function MapRoleItemInfoPresenter:popText(text)
    PopText(text)
end

return class("MapRoleItemInfoPresenter", {}, MapRoleItemInfoPresenter)
0000000000000
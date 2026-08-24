local ShenBingNpcAutoCuiLianLayer = class("ShenBingNpcAutoCuiLianLayer", cc.Layer)

local ShenBingCuiLianModel = require("app.models.ShenBing.CuiLian.ShenBingCuiLianModel")

local SELECT_LIMIT = 50

function ShenBingNpcAutoCuiLianLayer:create()
    local p = ShenBingNpcAutoCuiLianLayer.new()
    p:__init()
    return p
end

function ShenBingNpcAutoCuiLianLayer:__init()
    self.__ui = require("app.views.ui.ShenBing.ShenBingAutoCuiLianUI"):create()

    self.__ui:addTo(self)
end

function ShenBingNpcAutoCuiLianLayer:showLayer()
    self:__initCuiLianItems()

    self.__selectList = {
        {itemId = nil,num = 0},
        {itemId = nil,num = 0},
        {itemId = nil,num = 0},
    }

    self.__touchTime = 0

    self:setTextTitle()

    self:setTextCuiLianNum()

    self:setTextCostGoldNum()

    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:setPanelBack(EMPTY_FUNC)

    self:setListViewItem()

    self:setPanelrow()

    self.__ui:showUI()
end

function ShenBingNpcAutoCuiLianLayer:__initCuiLianItems()
    local itemList = ShenBingCuiLianModel:getCuiLianItemList(self.__weapon.bType)
    for i,v in ipairs(itemList) do
        self["__item"..i] = Item:getOneItemByKey(v.Cuilianid)
        self["__cuiLianData"..i] = v
    end
end

function ShenBingNpcAutoCuiLianLayer:setWeapon(weapon)
    self.__weapon = weapon
end

function ShenBingNpcAutoCuiLianLayer:setPlayer(player)
    self.__player = player
end

function ShenBingNpcAutoCuiLianLayer:setWorker(worker)
    self.__worker = worker
end

function ShenBingNpcAutoCuiLianLayer:setCallBack(callback)
    self.__callback = callback
end

function ShenBingNpcAutoCuiLianLayer:getGold()
    return Helper:mathFloor(self.__player:getAttr("gold"))
end

function ShenBingNpcAutoCuiLianLayer:getItemNum(itemId)
    return self.__player:getSmeltBoxItemCount(itemId)
end

function ShenBingNpcAutoCuiLianLayer:getItemSelectNum(itemId)
    local num = 0
    for i,v in ipairs(self.__selectList) do
        if v.itemId == itemId then
            num = num + v.num
        end
    end
    return num
end

function ShenBingNpcAutoCuiLianLayer:getSumItemSelectNum()
    local sumNum = 0
    for i,v in ipairs(self.__selectList) do
        sumNum = sumNum + v.num
    end

    return sumNum
end

function ShenBingNpcAutoCuiLianLayer:setTextTitle()
    self.__ui:setTextTitle("淬炼神兵："..self.__weapon.name)
end

function ShenBingNpcAutoCuiLianLayer:setTextCuiLianNum()
    local sumNum = self:getSumItemSelectNum()

    self.__ui:setTextCuiLianNum("本次淬炼次数："..tostring(sumNum))
end

function ShenBingNpcAutoCuiLianLayer:setTextCostGoldNum()
    self.__ui:setTextCostJingNum("预计消耗黄金：根据神兵成功淬炼次数消耗")
end

function ShenBingNpcAutoCuiLianLayer:setPanelrow()
    local list = {
        {name = "当前成功淬炼：",num = self.__weapon.cuilianCount},
        {name = "黄金：",num = self:getGold() .. "→" .. "？"},
        {name = self.__item1.name.."：",num = self:getItemNum(self.__item1.id) .. "→" .. self:getItemNum(self.__item1.id) - self:getItemSelectNum(self.__item1.id)},
        {name = self.__item2.name.."：",num = self:getItemNum(self.__item2.id) .. "→" .. self:getItemNum(self.__item2.id) - self:getItemSelectNum(self.__item2.id)},
        {name = self.__item3.name.."：",num = self:getItemNum(self.__item3.id) .. "→" .. self:getItemNum(self.__item3.id) - self:getItemSelectNum(self.__item3.id)},
    }

    for i,v in ipairs(list) do
        self.__ui:setPanelrow(i,v)
    end
end

function ShenBingNpcAutoCuiLianLayer:getConfigData()
    local configList = {}

    for i = 1,3 do
        table.insert(configList,{
            subTitle = "第"..Helper:numberCast(i).."段淬炼请选择投入：",

            itemNum = self.__selectList[i].num,

            buttonData1 = {
                imageGrey = "Image/UI/AttrUI/leftgrey.png",
                imageBright = "Image/UI/AttrUI/leftbright.png",
                title = "-10",
                addNum = -10,
                symbolType = 1,
            },

            buttonData2 = {
                imageGrey = "Image/UI/AttrUI/leftgrey.png",
                imageBright = "Image/UI/AttrUI/leftbright.png",
                title = "-1",
                addNum = -1,
                symbolType = 1,
            },

            buttonData3 = {
                imageGrey = "Image/UI/AttrUI/jiali02b.png",
                imageBright = "Image/UI/AttrUI/jiali02.png",
                title = "+1",
                addNum = 1,
                symbolType = 2,
            },

            buttonData4 = {
                imageGrey = "Image/UI/AttrUI/jiali02b.png",
                imageBright = "Image/UI/AttrUI/jiali02.png",
                title = "+10",
                addNum = 10,
                symbolType = 2,
            },
        })
    end

    return configList
end

function ShenBingNpcAutoCuiLianLayer:getConfigList()
    local configList = self:getConfigData()

    local retList = {}

    for i,v in ipairs(configList) do
        local retData = {}

        retData.subTitle = v.subTitle

        retData.itemNum = v.itemNum

        retData.buttonData1 = self:createItemButtonData(i,v.buttonData1)

        retData.buttonData2 = self:createItemButtonData(i,v.buttonData2)

        retData.buttonData3 = self:createItemButtonData(i,v.buttonData3)

        retData.buttonData4 = self:createItemButtonData(i,v.buttonData4)

        retData.selectName = self:getSelectName(self.__selectList[i].itemId)

        retData.name = self:getSelectName(self.__selectList[i].itemId)

        retData.selectFunc = function()
            self.__ui:showPanelItemImageSelecet2(i,
                {
                    name = self:getSelectName(self.__selectList[i].itemId),

                    selectName1 = self.__item1.name,

                    selectFunc1 = function()
                        self:selectCuiLianItemId(i,self.__item1.id)
                    end,

                    selectName2 = self.__item2.name,

                    selectFunc2 = function()
                        self:selectCuiLianItemId(i,self.__item2.id)
                    end,

                    selectName3 = self.__item3.name,

                    selectFunc3 = function()
                        self:selectCuiLianItemId(i,self.__item3.id)
                    end
                }
            )

            self.__ui:setPanelBack(function()
                self.__ui:hidePanelItemImageSelecet2(i)

                self.__ui:setButtonsTouchEnabled(true)

                self.__ui:setPanelBack(EMPTY_FUNC)
            end)

            self.__ui:setButtonsTouchEnabled(false)
        end

        table.insert( retList,retData)
    end

    return retList
end

function ShenBingNpcAutoCuiLianLayer:selectCuiLianItemId(index,itemId)
    self.__selectList[index].itemId = itemId

    self.__selectList[index].num = 0

    self:setTextCuiLianNum()

    self:refreshPanelItemNum(index)

    self:refreshListViewItemButton()

    self:refreshPanelItemSelectName(index)

	self:setPanelrow()
    
    self.__ui:setButtonsTouchEnabled(true)
end

function ShenBingNpcAutoCuiLianLayer:selectCuiLianItemNum(index,selectNum)
    self.__selectList[index].num = self.__selectList[index].num + selectNum

    self:setTextCuiLianNum()

    self:refreshPanelItemNum(index)

    self:refreshListViewItemButton()

    self:setPanelrow()
end

function ShenBingNpcAutoCuiLianLayer:setListViewItem()
    local retList = self:getConfigList()

    self.__ui:setListViewItem(retList)
end

function ShenBingNpcAutoCuiLianLayer:createItemButtonData(index,buttonData)
    local retData = {}

    local imageGrey = buttonData.imageGrey
    local imageBright = buttonData.imageBright
    local title = buttonData.title
    local addNum = buttonData.addNum
    local symbolType = buttonData.symbolType

    local isbright,msg = self:getIsbrightResult(index,addNum,symbolType)

    retData.title = title

    if isbright then
        retData["image"] = imageBright
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                isbright,msg = self:getIsbrightResult(index,addNum,symbolType)

                if not isbright then
                    if msg then
                        PopText(msg)
                    end
                    self:clearHandle()
                    return
                end

                self:selectCuiLianItemNum(index,addNum)
            end
        )

        retData["endedFunc"] = function()
            self:selectCuiLianItemNum(index,addNum)

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    else
        retData.image = imageGrey
        retData.titleColor = {r = 255, g = 255, b = 255}
        retData.beganFunc = EMPTY_FUNC
        retData.endedFunc = function()
            if msg then
                PopText(msg)
            end
        end
        retData.canceledFunc = EMPTY_FUNC
    end

    return retData
end

function ShenBingNpcAutoCuiLianLayer:getIsbrightResult(index,addNum,symbolType)
    local isBright
    local msg

    if symbolType == 1 then
        if self.__selectList[index].itemId == nil then
            isBright = false
            msg = "当前未投入材料，请投入材料"
        elseif self.__selectList[index].num + addNum >= 0 then
            isBright = true
        else
            isBright = false
        end
    else
        if self.__selectList[index].itemId == nil then
            isBright = false
            msg = "当前未投入材料，请投入材料"
        elseif self:getSumItemSelectNum() + addNum > SELECT_LIMIT then
            isBright = false
            msg = "一次性淬炼太多，有可能会很大风险哦"
        elseif self:getItemSelectNum(self.__selectList[index].itemId) + addNum > self:getItemNum(self.__selectList[index].itemId) then
            isBright = false
            msg = "材料不足，无法投放"
        else
            isBright = true
        end
    end

    return isBright,msg
end

function ShenBingNpcAutoCuiLianLayer:refreshListViewItemButton()
    local configList = self:getConfigList()

    self.__ui:refreshListViewItemButton(configList)
end

function ShenBingNpcAutoCuiLianLayer:refreshPanelItemNum(index)
    local itemNum = self.__selectList[index].num
    
    self.__ui:refreshPanelItemNum(index,itemNum)
end

function ShenBingNpcAutoCuiLianLayer:refreshPanelItemSelectName(index)
    local name = self:getSelectName(self.__selectList[index].itemId)
    
    self.__ui:refreshPanelItemSelectName(index,name)
end

function ShenBingNpcAutoCuiLianLayer:getSelectName(selectItemId)
    local name
    if selectItemId == nil then
        name = "无"
    else
        name = Item:getOneItemByKey(selectItemId).name
    end

    return name
end

function ShenBingNpcAutoCuiLianLayer:createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:clearHandle()

        local total_time = 0

        self._handle =
            self:schedule(
            function(ft)
                total_time = total_time + ft
                if total_time > 1.25 then
                    callback()
                end
            end
        )
    end
    return retFunc
end

function ShenBingNpcAutoCuiLianLayer:clearHandle()
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end
end

function ShenBingNpcAutoCuiLianLayer:checkCanStartAutoCuiLian()
    if self.__weapon.typeDesc == nil then
        PopText("神兵"..self.__weapon.name.."数据异常，请联系客服！")
        return false
    end

    if self.__weapon.wanhaodu == nil then
        PopText("神兵数据异常，没有完好度")
        return false
    end

    if self.__weapon.wanhaodu <= 0 then
        PopText("您的神兵已被损坏，无法被淬炼。")
        return false
    end

    if self.__weapon.cuilianCount >= 300 then
        PopText("该神兵已经淬炼300次了")
        return false
    end

    local sumNum = self:getSumItemSelectNum()
    if sumNum == 0 then
        PopText("当前未投入材料，请投入材料")
        return false
    end

    if self:getGold() < ShenBingCuiLianModel:getEverytimeCostGold(self.__worker.skilv,self.__weapon.cuilianCount,self.__worker._costFactor) then
        PopText("黄金不足，无法开始淬炼")

        return false
    end

    if self.__worker.roleType == 2 then
		local todayCount = self.__player:getDayFlag("欧冶子淬炼")
		if todayCount + sumNum > ShenBingCuiLianModel:getOuYeZiCuiLianCountDayLimit() then
			PopText("已超出每日淬炼次数")
			return false
		end
	end

    return true
end

function ShenBingNpcAutoCuiLianLayer:setButtonConfirm()
    self.__ui:setButtonConfirm(
        "自动淬炼",
        function()
            if self:checkCanStartAutoCuiLian() == false then
                return
            end
            
            PopupLayerController:showLayer(
				"ShenBingNpcAutoCuiLianDetailLayer",
                function(layer)
                    layer:setSelectCuiLianItemList(self.__selectList)
                    layer:setCallBack(self.__callback)
                    layer:setWeapon(self.__weapon)
                    layer:setPlayer(self.__player)
                    layer:setWorker(self.__worker)
					layer:showLayer()
				end
            )
            
            PopText("开始自动淬炼")

            self:hideLayer()
        end
    )
end

function ShenBingNpcAutoCuiLianLayer:setButtonCancel()
    self.__ui:setButtonCancel(
        "取消",
        function()
            self:hideLayer()
        end
    )
end

function ShenBingNpcAutoCuiLianLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ShenBingNpcAutoCuiLianLayer",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ShenBingNpcAutoCuiLianLayer)
return ShenBingNpcAutoCuiLianLayer
00000
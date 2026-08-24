local VolumeBoxPresent = class("VolumeBoxPresent",LayerEx)

local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

local TitleTable = {
    {name = "门派续卷", type = "门派续卷", list = {},text = "你的门派续卷空空如也"},
    {name = "江湖续卷", type = "江湖续卷", list = {},text = "你的江湖续卷空空如也"},
}

function VolumeBoxPresent:create()
    local p = VolumeBoxPresent:new()
    p:init()
    return p
end

function VolumeBoxPresent:init()
    local UI = require("Layer/GongfuPage/BookCaseUI.lua").create()["root"]
    UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
    self:setShowAndHideAnimType("ROLL")

    self._titleVector = {}

    self:initTabView(TitleTable)
    self:setBack()

    self:VolumeDsc()
    
    self.Text_bookcase:setString("续卷箱")
    self.Text_bookcase:setPositionX(520)

    self.Button_change:setVisible(false)

    self.Text_desc:setString("\n点击上方感叹号可查看续卷箱介绍。")

    self:setTitleImageShow()
end

function VolumeBoxPresent:initTitleTableList(volumeList)
    TitleTable[1].list = {}
    TitleTable[2].list = {}

    if not MapIsEmpty(volumeList) then
        for i, v in ipairs(volumeList) do
            local item = SkillBreakThroughResManager:getBreakThroughItem(v.id)
            if item.type == TitleTable[1].type then
                table.insert(TitleTable[1].list, v)
            elseif item.type == TitleTable[2].type then
                table.insert(TitleTable[2].list, v)
            end
        end
    end
end

-- isBag 是否从背包打开
function VolumeBoxPresent:showLayer(volumeList)
    self:initTitleTableList(volumeList)

    self:createListView(1)
    self:setTitleImageShow()
    self:show()
end

-- 初始化标签页
function VolumeBoxPresent:initTabView(titleTable)
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)
    self.Image_tab.ListView_tab:setItemsMargin(480)
    self.Image_tab.ListView_tab:setTouchEnabled(false)
    local tag = 999
    for i, table in ipairs(titleTable) do
        local panel = self.Panel_back_title:clone()
        panel:setSize({width = 250.00,height = 102.00})
        Helper:convertUIByParent(panel)
        panel:setTag(tag)
        panel.Text_title:setString(table.name)
        panel.Text_title:setColor(textColor)
        panel.Text_title:enableOutline(outlineColor, outlineWidth)
        panel.Image_back:setVisible(false)

        self.Image_tab.ListView_tab:pushBackCustomItem(panel)
        panel:releaseFunc(
            function()
                self.currPageIndex = i
                self:createListView(i)
                self:setTitleImageShow(panel)
            end
        )
        self._titleVector[#self._titleVector + 1] = panel
        tag = tag + 1
    end
end

function VolumeBoxPresent:createListView(index)
    --@desc tab切换时清空之前绑定已点击的row
    if self.hidePreBg ~= nil then
        self.hidePreBg = nil
    end

    self:showCaiLiaoList(index)
end

function VolumeBoxPresent:showCaiLiaoList(index)
    if index == nil or type(TitleTable[index]) ~= "table" then
        return
    end

    local list = TitleTable[index].list
    local emptyText = TitleTable[index].text

    if not MapIsEmpty(list) then
        self.Text_empty:setVisible(false)
    else
        self.Text_empty:setString(emptyText)
        self.Text_empty:setVisible(true)
    end

    self.ListView_titlelistArea:removeAllItems()

    for i, v in ipairs(list) do
        local row = self.Panel_title1:clone()

        Helper:convertUIByParent(row)
        row.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        row.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        row.Text_name:setTextColor{r = 208, g = 208, b = 208}

        self.ListView_titlelistArea:pushBackCustomItem(row)


        local item = SkillBreakThroughResManager:getBreakThroughItem(v.id)

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(false)

        row.Text_name:setString(item.name)
        local numText = v.num

        row.Text_desc2:setString("X" .. numText)

        row:releaseFunc(
            function()
                if self.hidePreBg ~= nil then
                    self:hidePreBg()
                end
                row:setTouchEnabled(false)

                row.Image_title_bg_1:setVisible(true)
                row.Image_title_bg_2:setVisible(true)
                row.Image_title_bg_3:setVisible(true)

                self.hidePreBg = self:setHidePreBgFunc(row)

                PopupLayerController:showLayer(
                    "ItemDetailLayer",
                    --@layer: [app.views.layer.PopLayer.ItemDetailLayer#ItemDetailLayer]
                    function(layer)
                        layer:setItemDesc(item.dsc)
                        layer:setItemType(item.type)
                        layer:setLeftBtn()
                        layer:setRightBtn()
                        layer:clearListView()
                        layer:setItemDescTwo()
                        layer:showLayer(
                            item,
                            function()
                                row:setTouchEnabled(true)
                            end
                        )
                    end
                )
            end
        )
    end

    self.ListView_titlelistArea:jumpToTop()
end

--@desc 设置点击当前的row选中条隐藏方法，点击下一个row的时候隐藏当前row的选择条
function VolumeBoxPresent:setHidePreBgFunc(row)
    if row == nil then
        assert(false, "setHidePreBgFunc arg1 is nil,check the code!!")
        return
    end

    return function(self)
        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
    end
end

-- 高亮选择标题
function VolumeBoxPresent:setTitleImageShow(panel)
    if panel then
        local tag = panel:getTag()
        if not MapIsEmpty(self._titleVector) and tag then
            for i, v in ipairs(self._titleVector) do
                if v:getTag() and v:getTag() == tag then
                    v.Image_back:setVisible(true)
                else
                    v.Image_back:setVisible(false)
                end
            end
        end
    else
        if not MapIsEmpty(self._titleVector) then
            for i, v in ipairs(self._titleVector) do
                if i == 1 then
                    self._titleVector[i].Image_back:setVisible(true)
                else
                    self._titleVector[i].Image_back:setVisible(false)
                end
            end
        end
    end
end

function VolumeBoxPresent:setBack()
    self.Image_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "VolumeBoxPresent",
                function(layer)
                    layer:hide()
                end
            )
        end
    )

    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "VolumeBoxPresent",
                function(layer)
                    layer:hide()
                end
            )
        end
    )
end

function VolumeBoxPresent:VolumeDsc()
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Panel_tips.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
	    		dialog:show("用于收纳续卷的箱子，续卷可用于特殊招式突破，不同品类的特殊招式需消耗相对应的续卷。续卷可从天都峰处的商人墨无锋进行兑换，兑换所需“功法学识”可通过江湖轶闻获取。")
	    		dialog:setPanelBack(function()
	    			self.Panel_tips.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Panel_tips.Image_7:setVisible(true)
	        end
	    end)
end

Helper:classDefNodeGetInstance(VolumeBoxPresent)
return VolumeBoxPresent
0
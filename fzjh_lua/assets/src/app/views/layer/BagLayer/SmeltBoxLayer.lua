local SmeltBoxLayer = class("SmeltBoxLayer",LayerEx)

local TitleTable = {
    {name = "淬炼材料", type = "淬炼材料", list = {},text = "你的淬炼材料箱空空如也"},
    {name = "锻造材料", type = "锻造材料", list = {},text = "你的锻造材料箱空空如也"},
}

function SmeltBoxLayer:create()
    local p = SmeltBoxLayer:new()
    p:init()
    return p
end

function SmeltBoxLayer:init()
    local UI = require("Layer/GongfuPage/BookCaseUI.lua").create()["root"]
    UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
    self:setShowAndHideAnimType("ROLL")

    self._titleVector = {}

    -- 是否从背包界面打开
    self.isFromBag = false

    self:initTabView(TitleTable)
    self:setBack()

    self:SmeltBoxDsc()
    
    self.Text_bookcase:setString("冶炼箱")
    self.Text_bookcase:setPositionX(520)

    self.Button_change:setVisible(false)

    self.Text_desc:setString("\n点击上方感叹号可查看冶炼箱介绍。")

    self:setTitleImageShow()
end

function SmeltBoxLayer:initTitleTableList()
    TitleTable[1].list = {}
    TitleTable[2].list = {}

    local role = User:getRole()
    local SmeltList = role:getAttr("smeltBox")

    if not MapIsEmpty(SmeltList) then
        for i, v in ipairs(SmeltList) do
            local item = Item:getOneItemByKey(v.itemId)
            if item.type == "淬炼材料" then
                table.insert(TitleTable[1].list, v)
            elseif item.type == "锻造材料" then
                table.insert(TitleTable[2].list, v)
            end
        end
    end
end

-- isBag 是否从背包打开
function SmeltBoxLayer:showLayer(isBag)
    if isBag == nil then
        isBag = false
    end
    self:initTitleTableList()

    self.isFromBag = isBag
    self:createListView(1)
    self:setTitleImageShow()
    self:show()
end

-- 初始化标签页
function SmeltBoxLayer:initTabView(titleTable)
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)
    self.Image_tab.ListView_tab:setItemsMargin(480)
    self.Image_tab.ListView_tab:setTouchEnabled(false)
    local tag = 999
    for k, table in pairs(titleTable) do
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
                self.currPageIndex = k
                self:createListView(k)
                self:setTitleImageShow(panel)
            end
        )
        self._titleVector[#self._titleVector + 1] = panel
        tag = tag + 1
    end
end

function SmeltBoxLayer:createListView(tag)
    --@desc tab切换时清空之前绑定已点击的row
    if self.hidePreBg ~= nil then
        self.hidePreBg = nil
    end

    self:showCaiLiaoList(tag)
end

function SmeltBoxLayer:showCaiLiaoList(tag)
    if tag == nil or type(TitleTable[tag]) ~= "table" then
        return
    end

    local list = TitleTable[tag].list
    local emptyText = TitleTable[tag].text

    if not MapIsEmpty(list) then
        self.Text_empty:setVisible(false)
    else
        self.Text_empty:setString(emptyText)
        self.Text_empty:setVisible(true)
    end

    local cailiaoCount = #list
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - cailiaoCount > 0  then
        local removePosition = listCount - cailiaoCount
        for i=listCount-1,cailiaoCount,-1 do
            self.ListView_titlelistArea:removeItem(i)
        end
    end

    for i, v in ipairs(list) do
        local row = self.ListView_titlelistArea:getItem(i - 1)
        if not row then
            row = self.Panel_title1:clone()
            
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            row.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)

            self.ListView_titlelistArea:pushBackCustomItem(row)
        else
            row.Text_name:setTextColor{r = 208, g = 208, b = 208}
        end
        local item = Item:getOneItemByKey(v.itemId)

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(false)

        row.Text_name:setString(item.name)
        local numText = v.count
        if v.count > 9999 then
            numText = 9999
        end
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
function SmeltBoxLayer:setHidePreBgFunc(row)
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
function SmeltBoxLayer:setTitleImageShow(panel)
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

function SmeltBoxLayer:setBack()
    self.Image_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "SmeltBoxLayer",
                function(layer)
                    layer:hide()
                end
            )
        end
    )

    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "SmeltBoxLayer",
                function(layer)
                    layer:hide()
                end
            )
        end
    )
end

--冶炼箱描述
function SmeltBoxLayer:SmeltBoxDsc()
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Panel_tips.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
	    		dialog:show("锻造材料和淬炼材料是神兵锻造和强化所不可或缺的。锻造材料对神兵初始的成品影响很大，淬炼材料对神兵后续的强化至关重要。\n完成唐门之乱剧情，可开启神兵系统。")
	    		dialog:setPanelBack(function()
	    			self.Panel_tips.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Panel_tips.Image_7:setVisible(true)
	        end
	    end)
end

Helper:classDefNodeGetInstance(SmeltBoxLayer)
return SmeltBoxLayer
0000000000
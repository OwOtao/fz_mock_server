local MedicinalLayer = class("MedicinalLayer", LayerEx)

--@RefType [app.Resource#Resource]
local Resource = require("app.Resource")
--@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
local PoisonUtil = require("app.models.Poison.PoisonUtil")

--@RefType [app.models.Poison.MedicinalBoxModel#MedicinalBoxModel]
local MedicinalBoxModel = require("app.models.Poison.MedicinalBoxModel")

local TitleTable = {
    {name = "毒药", type = "poison", list = nil},
    {name = "材料", type = "materials", list = nil},
    {name = "配方", type = "recipe", list = nil}
}


function MedicinalLayer:create()
    local p = MedicinalLayer:new()
    p:init()
    return p
end

function MedicinalLayer:init()
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

    self:medicinalBoxDsc()
    
    self.Text_bookcase:setString("药 囊")
    self.Button_change:setVisible(false)

    self.Text_desc:setString("\n点击上方感叹号可查看关于毒术玩法介绍。")

    self:setTitleImageShow()
end

-- isBag 是否从背包打开
function MedicinalLayer:showLayer(isBag)
    if isBag == nil then
        isBag = false
    end
    MedicinalBoxModel:classifyBox()
    self.isFromBag = isBag
    self:createListView(1)
    self:setTitleImageShow()
    self:show()
end

-- 初始化标签页
function MedicinalLayer:initTabView(titleTable)
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)
    self.Image_tab.ListView_tab:setItemsMargin(230)
    local tag = 999
    for k, table in pairs(titleTable) do
        local panel = self.Panel_back_title:clone()
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

function MedicinalLayer:createListView(tag)
    --@desc tab切换时清空之前绑定已点击的row
    if self.hidePreBg ~= nil then
        self.hidePreBg = nil
    end

    -- self.ListView_titlelistArea:removeAllItems()
    switch(
        tag,
        {
            [1] = function()
                self:showPoisonList()
            end,
            [2] = function()
                self:showStuffsList()
            end,
            [3] = function()
                self:showFormulaList()
            end
        }
    )
end

function MedicinalLayer:showPoisonList()
    local list = MedicinalBoxModel:getPoisonList()

    if not MapIsEmpty(list) then
        self.Text_empty:setVisible(false)
    else
        self.Text_empty:setString("你的毒药箱空空如也")
        self.Text_empty:setVisible(true)
    end

    local poisonCount = #list
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - poisonCount > 0  then
        local removePosition = listCount - poisonCount
        for i=listCount-1,poisonCount,-1 do
            self.ListView_titlelistArea:removeItem(i)
        end
    end

    for i, v in ipairs(list) do
        local row = self.ListView_titlelistArea:getItem(i - 1)
        if not row then
            row = self.Panel_title1:clone()
            self.ListView_titlelistArea:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            row.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        else
            row.Text_name:setTextColor{r = 208, g = 208, b = 208}
        end
        local item = Item:getOneItemByKey(v.itemId)

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(false)

        row.Text_name:setString(item.name)
        row.Text_desc2:setString("X" .. v.count)

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
                        layer:setRightBtnImage(Resource:getImgPath("zhiliao"))
                        layer:setItemDesc(item.dsc)
                        layer:setItemType(item.type)
                        layer:setLeftBtn()
                        layer:clearListView()
                        layer:setItemDescTwo()
                        layer:setRightBtn(
                            "淬 毒",
                            function()
                                PoisonUtil:PoisonWeapon(item.id,function ()
                                    self:createListView(1)
                                end)
                            end
                        )
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

--@desc: show 材料箱
--@author:Liang SongQiang
--@time:2018-01-12 15:02:42
function MedicinalLayer:showStuffsList()
    local list = MedicinalBoxModel:getStuffList()

    local stuffCount = #list
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - stuffCount > 0  then
        for i=listCount-1,stuffCount,-1 do
            self.ListView_titlelistArea:removeItem(i)
        end
    end

    if not MapIsEmpty(list) then
        self.Text_empty:setVisible(false)
    else
        self.Text_empty:setString("你的材料箱空空如也")
        self.Text_empty:setVisible(true)
    end

    for i, v in ipairs(list) do
        local row = self.ListView_titlelistArea:getItem(i - 1)
        if not row then
            row = self.Panel_title1:clone()
            self.ListView_titlelistArea:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            row.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        else
            row.Text_name:setTextColor{r = 208, g = 208, b = 208}
        end
        local item = Item:getOneItemByKey(v.itemId)

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(false)

        row.Text_name:setString(item.name)
        row.Text_desc2:setString("X" .. v.count)

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
                        layer:setRightBtnImage(Resource:getImgPath("zhiliao"))
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

--@desc: show 配方
--@author:Liang SongQiang
--@time:2018-01-08 14:26:36
--@list: 配方列表
function MedicinalLayer:showFormulaList()
    local list = MedicinalBoxModel:getFormulaList()
    local formulas = require("script.others.poison")["formula"]

    local formulaCount = #list
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - formulaCount > 0  then
        for i=listCount-1,formulaCount,-1 do
            self.ListView_titlelistArea:removeItem(i)
        end
    end

    if not MapIsEmpty(list) then
        self.Text_empty:setVisible(false)
    else
        self.Text_empty:setString("你没有学会任何毒药配方")
        self.Text_empty:setVisible(true)
    end

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    for i, v in ipairs(list) do
        local row = self.ListView_titlelistArea:getItem(i - 1)
        if not row then
            row = self.Panel_title1:clone()
            Helper:convertUIByParent(row)
            self.ListView_titlelistArea:pushBackCustomItem(row)
            row.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            row.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        else
            row.Text_name:setTextColor{r = 208, g = 208, b = 208}
        end

        local pf = formulas[v]

        local skill = Skill:getSkill(pf.skillid)

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(true)

        row.Text_name:setString(pf.name)
        row.Text_desc1:setString(skill.name)
        local lv = role:getSkillLv(pf.skillid)
        row.Text_desc2:setString(lv .. "级")

        row:releaseFunc(
            function()
                if self.hidePreBg ~= nil then
                    self:hidePreBg()
                end

                row.Image_title_bg_1:setVisible(true)
                row.Image_title_bg_2:setVisible(true)
                row.Image_title_bg_3:setVisible(true)

                self.hidePreBg = self:setHidePreBgFunc(row)

                PopupLayerController:showLayer(
                    "ItemDetailLayer",
                    --@layer: [app.views.layer.PopLayer.ItemDetailLayer#ItemDetailLayer]
                    function(layer)
                        layer:setRightBtnImage(Resource:getImgPath("zhiliao"))
                        layer:setItemDesc(pf.desc)
                        layer:setItemType("配方")
                        layer:setItemDescTwo("制作需求材料：")
                        layer:setLeftBtn()
                        layer:setRightBtn(
                            "制 作",
                            function()
                                RichPrint("main",pf.location)
                                -- local location = {}

                                -- location.map = string.split(pf.location, "_")[1]
                                -- location.room = pf.location

                                -- local map = Map:getMapById(location.map)

                                -- RichPrint("main","请前往YEL" .. map.name .. map.room[location.room].name .. "NOR制作")
                            end
                        )

                        layer:clearListView()

                        local s_List = string.split(pf.stuff, ";")

                        if not MapIsEmpty(s_List) then
                            for i, stuffCount in ipairs(s_List) do
                                local stuff = string.split(stuffCount, ",")
                                local sid = stuff[1]
                                local count = stuff[2]

                                local sname = Item:getOneItemByKey(sid).name
                                local iCount = MedicinalBoxModel:getHasStuffCount(sid)
                                local _row = layer:getRowOfMedicinals()
                                _row.Item_Name_Text:setString(sname)
                                _row.Item_Desc_Text:setString("(" .. iCount .. "/" .. count .. ")")
                                layer:addRowToListView(_row)
                            end
                        end

                        layer:showLayer(pf)
                    end
                )
            end
        )

    end
    self.ListView_titlelistArea:jumpToTop()
end

--@desc 设置点击当前的row选中条隐藏方法，点击下一个row的时候隐藏当前row的选择条
function MedicinalLayer:setHidePreBgFunc(row)
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
function MedicinalLayer:setTitleImageShow(panel)
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

function MedicinalLayer:setBack()
    self.Image_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "MedicinalLayer",
                function(layer)
                    layer:hide()
                end
            )
        end
    )

    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "MedicinalLayer",
                function(layer)
                    layer:hide()
                end
            )
        end
    )
end




--药囊描述
function MedicinalLayer:medicinalBoxDsc()
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Panel_tips.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
	    		dialog:show("制毒、淬毒、研读毒术书籍可提升江湖毒术等级。提升江湖毒术等级可解锁更多毒术配方，门派毒术可向师傅请教。\n门派毒术传承不保留，江湖毒术传承保留一半经验值，如传承后配方少了，请勿担心，这是因为江湖毒术等级降低了，提升江湖毒术即可再次学习对应毒术配方。")
	    		dialog:setPanelBack(function()
	    			self.Panel_tips.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Panel_tips.Image_7:setVisible(true)
	        end
	    end)
end

Helper:classDefNodeGetInstance(MedicinalLayer)
return MedicinalLayer
0
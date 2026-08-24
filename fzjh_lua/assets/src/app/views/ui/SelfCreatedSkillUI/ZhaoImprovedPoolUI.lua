local ZhaoImprovedPoolUI = class("ZhaoImprovedPoolUI", LayerEx)
local IZhaoImprovedPoolPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.IZhaoImprovedPoolPresenterOutput")
local IZhaoImprovedPoolPresenterInput = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.IZhaoImprovedPoolPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function ZhaoImprovedPoolUI:create()
    local p = ZhaoImprovedPoolUI:new()
    p:init()
    return p
end

function ZhaoImprovedPoolUI:init()
    self._round = require("Layer/GongfuPage/BookCaseUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
    self:setShowAndHideAnimType("ROLL")
    self._titleVector = {}
    
    self.Button_change:setVisible(false)
end

function ZhaoImprovedPoolUI:showLayer(selfCreatedSkillSystem,propList,presenter,zhaoIndex,canUseItem,func,skillId)
    self._IZhaoImprovedPoolPresenterInput = isImplement(presenter:create(self,selfCreatedSkillSystem,zhaoIndex), IZhaoImprovedPoolPresenterInput)

    self._IZhaoImprovedPoolPresenterInput:showLayer(propList,canUseItem,func,skillId)
end

function ZhaoImprovedPoolUI:setShowLayer()
    self:show()
end

-- 初始化标签页
function ZhaoImprovedPoolUI:initTabView(titleTable,callback)
    self._titleVector = {}
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)
    self.Image_tab.ListView_tab:setItemsMargin(230)
    self.Image_tab.ListView_tab:removeAllItems()
    local tag = 999
    for i, table in ipairs(titleTable) do
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
                if callback then
                    callback(i,panel)
                end
            end
        )
        self._titleVector[#self._titleVector + 1] = panel
        tag = tag + 1
    end
end

-- 高亮选择标题
function ZhaoImprovedPoolUI:setTitleImageShow(panel)
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

function ZhaoImprovedPoolUI:setTextTital(isVisible)
    self.Text_bookcase:setVisible(isVisible)
end

function ZhaoImprovedPoolUI:setTextDesc(isVisible)
    -- self.Text_desc:setString(text)
    self.Text_desc:setVisible(isVisible)
end

function ZhaoImprovedPoolUI:setTextDsc(text,isVisible)
    self.Text_dsc:setVisible(isVisible)
    self.Text_dsc:setString(text)
end

function ZhaoImprovedPoolUI:setTextEmpty(isVisible,text)
    self.Text_empty:setVisible(isVisible)
    self.Text_empty:setString(text)
end

function ZhaoImprovedPoolUI:setListView(list)
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - #list > 0  then
        for i = listCount-1,#list,-1 do
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

        row.Image_title_bg_1:setVisible(false)
        row.Image_title_bg_2:setVisible(false)
        row.Image_title_bg_3:setVisible(false)
        row.Text_desc1:setVisible(false)

        row.Text_name:setString(v.name)
        row.Text_desc2:setString("X" .. v.count)

        row:releaseFunc(
            function()
                v.buttonFunc(row)
            end
        )
    end

    self.ListView_titlelistArea:jumpToTop()
end

--@desc 设置点击当前的row选中条隐藏方法，点击下一个row的时候隐藏当前row的选择条
function ZhaoImprovedPoolUI:setHidePreBgFunc(row)
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

function ZhaoImprovedPoolUI:setImageBack(func)
    self.Image_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ZhaoImprovedPoolUI:setPanelBack(func)
    self.Panel_back:releaseFunc(
        function()
            if func then
                func()
            end
            
        end
    )
end

function ZhaoImprovedPoolUI:hideLayer()
    PopupLayerController:hideLayer("ZhaoImprovedPoolUI",function(layer)
        layer:hide()
    end)
end

function ZhaoImprovedPoolUI:setTipDsc(isVisible)
    self.Panel_tips:setVisible(isVisible)
    -- local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    -- local dialog = DialogELayer:getInstance()
	-- self.Panel_tips:addTouchEventListener(
	-- 	function(ref, eventType)
	--     	if eventType == ccui.TouchEventType.began then
	--     		self.Panel_tips.Image_7:setVisible(false)
	--         elseif eventType == ccui.TouchEventType.ended then
	--     		dialog:show(text)
	--     		dialog:setPanelBack(function()
	--     			self.Panel_tips.Image_7:setVisible(true)
	--     		end)
	-- 		elseif eventType == ccui.TouchEventType.canceled then
	--     		self.Panel_tips.Image_7:setVisible(true)
	--         end
	--     end)
end

function ZhaoImprovedPoolUI:richPrint(text)
    RichPrint("main",text)
end

function ZhaoImprovedPoolUI:popText(text)
    PopText(text)    
end

isImplement(ZhaoImprovedPoolUI,IZhaoImprovedPoolPresenterOutput)
Helper:classDefNodeGetInstance(ZhaoImprovedPoolUI)
return ZhaoImprovedPoolUI
00000
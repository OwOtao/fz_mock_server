local BookRackUI = class("BookRackUI", LayerEx)
local BookRackPresenter = require("app.presenters.selfCreatedSkill.bookRack.BookRackPresenter")
local IBookRackPresenterOutput = require("app.presenters.selfCreatedSkill.bookRack.IBookRackPresenterOutput")
local IBookRackPresenterInput = require("app.presenters.selfCreatedSkill.bookRack.IBookRackPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local RoleSkillInfoListBarUI = require("app.views.ui.SkillUI.RoleSkillInfoListBarUI")
local SkillInfoPopSpecialUI = require("app.views.ui.SkillUI.SkillInfoPopSpecialUI")

function BookRackUI:create()
    local p = BookRackUI:new()
    p:init()
    return p
end

function BookRackUI:init()
    self._round = require("Layer/GongfuPage/BookCaseUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
    self:setShowAndHideAnimType("ROLL")
    self._titleVector = {}

    self.__hideCallback = nil
    
    self.Button_change:setVisible(false)
end

function BookRackUI:showLayer()
    self._IBookRackPresenterInput = isImplement(BookRackPresenter:create(self), IBookRackPresenterInput)

    self._IBookRackPresenterInput:showLayer()
end

function BookRackUI:setHideCallback(callback)
    self.__hideCallback = callback
end

function BookRackUI:setShowLayer()
    self:show()
end

-- 初始化标签页
function BookRackUI:initTabView(titleTable,callback)
    self._titleVector = {}
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)
    self.Image_tab.ListView_tab:setItemsMargin(30)
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
                if self.Pis_show then
                    self:hideSkillInfo(true)
                end

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
function BookRackUI:setTitleImageShow(panel)
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

function BookRackUI:setTextTital(text)
    self.Text_bookcase:setString(text)
end

function BookRackUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function BookRackUI:setTextEmpty(isVisible,text)
    self.Text_empty:setVisible(isVisible)
    self.Text_empty:setString(text)
end

function BookRackUI:setListView(list)
    local listCount = #self.ListView_titlelistArea:getItems()
    if listCount - #list > 0  then
        for i = listCount-1,#list,-1 do
            self.ListView_titlelistArea:removeItem(i)
        end
    end

    for i, v in ipairs(list) do
        local skillInfoListBar = self.ListView_titlelistArea:getItem(i - 1)
        if not skillInfoListBar then
            skillInfoListBar = RoleSkillInfoListBarUI:create()
            self.ListView_titlelistArea:pushBackCustomItem(skillInfoListBar)
        end

        skillInfoListBar:setName(v.name)
        skillInfoListBar:setExpDsc(v.exp)
        skillInfoListBar:setStageDsc(v.stageDsc)

        skillInfoListBar:releaseFunc(
            function()
                v.buttonFunc(skillInfoListBar)
            end
        )
    end

    self.ListView_titlelistArea:jumpToTop()
end

function BookRackUI:setItemImageBack(cItem)
	local items = self.ListView_titlelistArea:getItems()
	for k,item in pairs(items) do
		if cItem == item then
			item:setImageBack(true)
		else
			item:setImageBack(false)
		end
	end
end

function BookRackUI:setImageBack(func)
    self.Image_back:releaseFunc(
        function()
            if self.Pis_show then
                self:hideSkillInfo(true)
                return
            end
            if func then
                func()
            end
        end
    )
end

function BookRackUI:setPanelBack(func)
    self.Panel_back:releaseFunc(
        function()
            if self.Pis_show then
                self:hideSkillInfo(true)
                return
            end
            if func then
                func()
            end
            
        end
    )
end

function BookRackUI:hideLayer()
    PopupLayerController:hideLayer("BookRackUI",function(layer)
        if self.__hideCallback then
            self.__hideCallback()
            self.__hideCallback = nil
        end
        layer:hide()
    end)
end

function BookRackUI:setTipDsc(text)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Panel_tips.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
	    		dialog:show(text)
	    		dialog:setPanelBack(function()
	    			self.Panel_tips.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Panel_tips.Image_7:setVisible(true)
	        end
	    end)
end

function BookRackUI:initPopUI()
	if self.skillInfoPopSpecialUI == nil then
		self.skillInfoPopSpecialUI = SkillInfoPopSpecialUI:create()
		self.skillInfoPopSpecialUI:addTo(self)
	end
	self.Pis_show = false
	self.skillInfoPopSpecialUI:hide()
end

-- 显示技能信息
function BookRackUI:popSkillInfo(params)
	self.skillInfoPopSpecialUI:setName(params.name)
	self.skillInfoPopSpecialUI:setSkillStageDsc(params.desc)
	self.skillInfoPopSpecialUI:setSkillDetailDsc(params.dsc)
	self.skillInfoPopSpecialUI:setSkillExpDsc(params.expDsc)
    self.skillInfoPopSpecialUI:setButton1(params.butn1, params.func1)
    self.skillInfoPopSpecialUI:setButton2(params.butn2, params.func2)
    self.skillInfoPopSpecialUI:setButton3(params.butn3, params.func3)
	self.skillInfoPopSpecialUI:setActiveZhaoList(params.zhaoList)
	self.skillInfoPopSpecialUI.Image_infoArea:releaseFunc(
	function()
		self:hideSkillInfo(true)
	end)
	if not self.Pis_show then
		self.Pis_show = true
		self.skillInfoPopSpecialUI:show(true)
    end
    self.skillInfoPopSpecialUI:setPanelLearnSkill(params.tital,params.tipText)
end

-- 隐藏技能详细
function BookRackUI:hideSkillInfo(isAnim)
	self.skillInfoPopSpecialUI:hide(isAnim)
	self.Pis_show = false
end

function BookRackUI:popText(text)
    PopText(text)
end

isImplement(BookRackUI,IBookRackPresenterOutput)
Helper:classDefNodeGetInstance(BookRackUI)
return BookRackUI
000000000000
local inherit = require("third.inherit.inherit")
local IBookRackPresenterOutput = require("app.presenters.selfCreatedSkill.bookRack.IBookRackPresenterOutput")
local IBookRackPresenterInput = require("app.presenters.selfCreatedSkill.bookRack.IBookRackPresenterInput")
local SkillInfoPopSpecialUI = require("app.views.ui.SkillUI.SkillInfoPopSpecialUI")
local Skill = require("app.models.skill.Skill")
local SkillHelper = require("app.models.skill.SkillHelper")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local BookRackPresenter = {}
local qjList, bqList, qgList, ngList, zjList = {}, {}, {}, {}, {}

function BookRackPresenter:create(IBookRackOutput)
    local p = inherit({}, BookRackPresenter)
    p:init(IBookRackOutput)
    return p
end

function BookRackPresenter:init(IBookRackOutput)
    self._selfCreatedSkillSystem = User:getRole():getSelfCreatedSkillSystem()
    self._IBookRackPresenterOutput = isImplement(IBookRackOutput, IBookRackPresenterOutput)
    self._role = self._selfCreatedSkillSystem:getRole()
end


function BookRackPresenter:showLayer()
    self.__currTitleIndex = 1
    self._IBookRackPresenterOutput:initPopUI()
    self:initSkillList()
    self:initTabView()
    self:createListView(self.__currTitleIndex)
    self:setTitleImageShow()
    self:setImageBack()
    self:setPanelBack()
    self:showTextTital()
    self:showTextDesc()
    self:setTipDsc()

    self._IBookRackPresenterOutput:setShowLayer()
end

function BookRackPresenter:initTabView()
    local titleTable = {
        {name = "拳脚", list = qjList},
        {name = "兵器", list = bqList},
        {name = "轻功", list = qgList},
        {name = "内功", list = ngList},
        {name = "招架", list = zjList},
    }

    self._IBookRackPresenterOutput:initTabView(titleTable,function(index,panel)
        self.__currTitleIndex = index
        self:createListView(index)
        self:setTitleImageShow(panel)
    end)
end

function BookRackPresenter:createListView(index)
    local list = {}
    if index == 1 then
        list = qjList
    elseif index == 2 then
        list = bqList
    elseif index == 3 then
        list = qgList
    elseif index == 4 then
        list = ngList
    elseif index == 5 then
        list = zjList
    end

    local retData = {}
    
    if not MapIsEmpty(list) then
        self._IBookRackPresenterOutput:setTextEmpty(false,"")
    else
        self._IBookRackPresenterOutput:setTextEmpty(true,"你的书架空空如也")
    end

    for i, skill in ipairs(list) do
        local retList = {
            name = "武学名称",
            stageDsc = "",
            exp = "",
            buttonFunc = EMPTY_FUNC
        }
        retList["name"] = skill:getName()
        retList["stageDsc"] = ""
        retList["exp"] = ""
        retList["buttonFunc"] = function(row)
            self:showSkillInfo(skill)
            self:setItemImageBack(row)
        end
        table.insert(retData, retList)
    end

    self._IBookRackPresenterOutput:setListView(retData)
end



function BookRackPresenter:setItemImageBack(cItem)
	self._IBookRackPresenterOutput:setItemImageBack(cItem)
end

function BookRackPresenter:initSkillList()
    qjList, bqList, qgList, ngList, zjList = {}, {}, {}, {}, {}
    local books = self._selfCreatedSkillSystem:getBooks()
    for k,v in pairs(books) do
        local skill = self._selfCreatedSkillSystem:getOldSkill(v)
        if skill and skill.methods then
            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(qjList, skill)
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(ngList, skill)
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(qgList, skill)
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA then
                    table.insert(zjList, skill)
                else
                    
                    local temp = false
                    for _,tempSkill in pairs(bqList) do
                        if tempSkill.id == v.id then
                            temp = true
                        end
                    end

                    if temp == false then
                        table.insert(bqList, skill)
                    end

                end
            end
        end
    end
end

function BookRackPresenter:showSkillInfo(skill)
    local skillId = skill.id
    local role = self._role
    local name = skill.name 
	local desc = ""
	local dsc = skill.dsc
    local expDsc = ""
    local zhaoList = role:getSkillZhaoList(skillId)
	local butn1 = "详情"
    local func1 = function()
		local titalIndex = ""

		local TuJianUtil = require("app.models.TuJian.TuJianUtil")

        titalIndex = TuJianUtil:getSkillDefalutTuJianType(skillId)

		self._IBookRackPresenterOutput:hideSkillInfo(false)
		
		PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
			layer:setName(name)
			layer:setSkillDetailDsc(dsc)
			layer:setActiveZhaoList(zhaoList)
			layer:playWuXueAnim(skill.id,titalIndex)
			layer:setAutoZhaoDsc(skill.id,titalIndex,true)
			
			layer:showLayer()
		end)
    end
    local butn2
    local func2 = EMPTY_FUNC
    if not role:getSkill(skillId) then
        butn2 = "学习"
        func2 = function()
            self._selfCreatedSkillSystem:learnSkillBookBySkillId(skillId,function()
                self._IBookRackPresenterOutput:hideSkillInfo(false)
                self._IBookRackPresenterOutput:popText("你学习了"..name)
            end)
        end
    end
    
    local tital = "学习条件"
    local tipText = "学习条件\n  \n"
    local unlocks = skill.unlocks
    if MapIsEmpty(unlocks) == false then
        for i,unlockId in ipairs(unlocks) do
            tipText = tipText..AchievementSystem:getUnlockText(unlockId).."\n"
        end
    end

    local butn3
    local func3 = EMPTY_FUNC
    butn3 = "丢弃"
    func3 = function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local str1 = "HIW你确定丢弃" .. Helper:getNoColorStr(skill.name) .. "吗？NOR"
        dialog:show(str1, "HIR丢弃后将无法恢复NOR")
        dialog:setBack(false)
        dialog:setWeChatVisible(false)
        dialog:setButton2("取消", EMPTY_FUNC)
        dialog:setButton1(
            "确定",
            function()
                self._selfCreatedSkillSystem:deleteCompletedBookBySkillId(
                    skillId,
                    function(result)
                        if result == 0 then
                            self._IBookRackPresenterOutput:popText("你丢弃了" .. skill.name)
                            self._IBookRackPresenterOutput:hideSkillInfo(true)
                            self:initSkillList()
                            self:createListView(self.__currTitleIndex)
                        elseif result == 1 then
                            self._IBookRackPresenterOutput:popText("该书籍未创建完成，无法丢弃。")
                        elseif result == 2 then
                            self._IBookRackPresenterOutput:popText("需要丢弃的书籍未找到。")
                        end
                    end
                )
            end
        )
    end
    
	local params =
	{
		name = name,
		desc = desc,
		dsc = dsc,
		expDsc = expDsc,
		butn1 = butn1,
        func1 = func1,
        butn2 = butn2,
        func2 = func2,
        butn3 = butn3,
		func3 = func3,
        zhaoList = zhaoList,
        tital = tital,
        tipText = tipText
    }
    
    self._IBookRackPresenterOutput:popSkillInfo(params)
end

function BookRackPresenter:setTitleImageShow(panel)
    self._IBookRackPresenterOutput:setTitleImageShow(panel)
end

function BookRackPresenter:setImageBack()
    self._IBookRackPresenterOutput:setImageBack(function()
        self:hideLayer()
    end)
end

function BookRackPresenter:setPanelBack()
    self._IBookRackPresenterOutput:setPanelBack(function()
        self:hideLayer()
    end)
end

function BookRackPresenter:showTextTital()
    local text = "书架"
    self._IBookRackPresenterOutput:setTextTital(text)
end

function BookRackPresenter:showTextDesc()
    local text = "\n点击上方感叹号可查看关于书架玩法介绍。"
    self._IBookRackPresenterOutput:setTextDesc(text)
end

function BookRackPresenter:setTipDsc()
    local text = "已完成自创的武学将存放在书架上。\n学习可以将该武学添加至我的技能中。\n书架中所有的武学传承全部保留。"
    self._IBookRackPresenterOutput:setTipDsc(text)
end

function BookRackPresenter:hideLayer()
    self._IBookRackPresenterOutput:hideLayer()
end

isImplement(BookRackPresenter, IBookRackPresenterInput)
return BookRackPresenter
000000000000
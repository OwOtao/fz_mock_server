local inherit = require("third.inherit.inherit")
local ISelectSkillTypePresenterOutput = require("app.presenters.selfCreatedSkill.selectSkillType.ISelectSkillTypePresenterOutput")
local ISelectSkillTypePresenterInput = require("app.presenters.selfCreatedSkill.selectSkillType.ISelectSkillTypePresenterInput")

local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local SelectSkillTypePresenter = {}

function SelectSkillTypePresenter:create(ISelectSkillFirstTypeOutput,selfCreatedSkillSystem,callback,costPot,costJing)
    local p = inherit({}, SelectSkillTypePresenter)
    p:init(ISelectSkillFirstTypeOutput,selfCreatedSkillSystem,callback,costPot,costJing)
    return p
end

function SelectSkillTypePresenter:init(ISelectSkillFirstTypeOutput,selfCreatedSkillSystem,callback,costPot,costJing)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback
    self._skillCreator = self._selfCreatedSkillSystem:getSkillCreator()
    self._costPot = costPot
    self._costJing = costJing

    self._ISelectSkillTypePresenterOutput = isImplement(ISelectSkillFirstTypeOutput, ISelectSkillTypePresenterOutput)
end

function SelectSkillTypePresenter:showLayer()
    self:showTitalText()
    self:showFirstPanel()
    self._ISelectSkillTypePresenterOutput:setShowLayer()
end

function SelectSkillTypePresenter:showTitalText()
    local text = "请选择要自创的武学种类"
    self._ISelectSkillTypePresenterOutput:setTitalText(text)
end

function SelectSkillTypePresenter:creatZhaoFunc(firstType,secondType)
    self._selfCreatedSkillSystem:createZhao(secondType,function(ret,msg,zhaoData)
        local role = self._selfCreatedSkillSystem:getRole()
        role:addAttr("pot",-self._costPot)
        role:addAttr("jing",-self._costJing)
        self._ISelectSkillTypePresenterOutput:popText("潜能-"..self._costPot)
        self._ISelectSkillTypePresenterOutput:popText("精力-"..self._costJing)


        -- 开始创造武学
        self._skillCreator:creating()
        
        self:showCreatedZhaoLayer({ret = ret,msg = msg,zhaoData = zhaoData})
    
        if self._callback then
            self._callback()
        end
    end)

end

--@desc 配置
local firstList = {
    -- ["轻功"] = {
    --     x = 282.44,
    --     y = 1343.24,
    --     image = "Image/UI/SelfCreatedSkillUI/06.png",
    --     secondList = {}
    -- },
    ["拳脚"] = {
        x = 782,
        y = 1188,
        image = "Image/UI/SelfCreatedSkillUI/04.png",
        secondList = {
            ["拳法"] = {x = 440.58,y = 443.21},
            ["爪法"] = {x = 240.09,y = 503.53},
            ["掌法"] = {x = 81.16,y = 390.31},
            ["指法"] = {x = 76.77,y = 182.37},
            ["腿法"] = {x = 222.14,y = 58.04},
        }
    },
    -- ["内功"] = {
    --     x = 282.40,
    --     y = 783.95,
    --     image = "Image/UI/SelfCreatedSkillUI/05.png",
    --     secondList = {}
    -- },
    ["兵器"] = {
        x = 352,
        y = 570,
        image = "Image/UI/SelfCreatedSkillUI/07.png",
        secondList = {
            ["剑法"] = {x = 440.58,y = 443.21},
            ["刀法"] = {x = 240.09,y = 503.53},
            ["棍法"] = {x = 81.16,y = 390.31},
            ["鞭法"] = {x = 66.77,y = 195.37},
            ["暗器"] = {x = 205.14,y = 62.04},
            ["双持"] = {x = 410.86,y = 91.46},
            ["乐器"] = {x = 506.85,y = 248.25},
        }
    }
}

function SelectSkillTypePresenter:showFirstPanel()
    local firstTypeList = self._skillCreator:getSkillFirstTypeList()
    if MapIsEmpty(firstTypeList) then
        return
    end
    local retData = {}
    for i,v in ipairs(firstTypeList) do
        local firstType = v.type
        local firstName = v.name
        local panelData = {
            name = "",
            posX = 0,
            posY = 0,
            func = EMPTY_FUNC
        }
        local secondTypeList = self._skillCreator:getSkillThirdTypeListByFirstTypeName(firstName)
        panelData["name"] = firstName
        panelData["posX"] = firstList[firstName].x
        panelData["posY"] = firstList[firstName].y
        panelData["image"] = firstList[firstName].image

        if MapIsEmpty(secondTypeList) then
            assert(nil,"firstName = "..firstName.."类型二为空")
        end

        if #secondTypeList == 1 then
            panelData["func"] = function(panel)
                Audio:playEffect("xiaoAnNiu")
                self:creatZhaoFunc(firstType,secondTypeList[1].type)
            end
        else
            panelData["func"] = function(parent)
                Audio:playEffect("xiaoAnNiu")
                local retData2 = {}
                for i,v in ipairs(secondTypeList) do
                    local secondType = v.type
                    local secondName = v.name
                    local panel2Data = {
                        name = "",
                        name1 = "",
                        posX = 0,
                        posY = 0,
                        func = EMPTY_FUNC
                    }
                    panel2Data["name"] = string.sub(secondName,1,3)
                    panel2Data["name1"] = string.sub(secondName,4,6)
                    panel2Data["posX"] = firstList[firstName].secondList[secondName].x
                    panel2Data["posY"] = firstList[firstName].secondList[secondName].y
                    panel2Data["func"] = function()
                        Audio:playEffect("xiaoAnNiu")
                        self:creatZhaoFunc(firstType,secondType)
                    end

                    table.insert(retData2,panel2Data)
                end
                self._ISelectSkillTypePresenterOutput:setSecondPanel(parent,retData2)
            end
        end

        
        table.insert(retData,panelData)
    end
    self._ISelectSkillTypePresenterOutput:setFirstPanel(retData)
end

function SelectSkillTypePresenter:hideLayer()
    self._ISelectSkillTypePresenterOutput:hideLayer()
end

function SelectSkillTypePresenter:showCreatedZhaoLayer(zhaoCreateResult)
    PopupLayerController:showLayer(
        "CreatedZhaoUI",
        function(layer)
            if zhaoCreateResult.ret == true then
                layer:setAfterAnimCallback(
                    function()
                        self:hideLayer()
                        layer:setPanelCreateZhaoNameIsVisible(true)
                    end
                )
            else
                layer:setAfterAnimCallback(
                    function()        
                        self:hideLayer()
                        self._ISelectSkillTypePresenterOutput:richPrint(zhaoCreateResult.msg)
                        layer:setButtonHide(true,function()
                            layer:hideLayer()
                        end)
                    end
                )
            end
            layer:setBackgroundMusic("createZhao",true)
            layer:setCreatingMusicEffect("creatingZhao",false)
            layer:showLayer(self._selfCreatedSkillSystem,zhaoCreateResult,function()
                local ZhaosLibraryPresenter = require("app.presenters.selfCreatedSkill.zhaosLibrary.ZhaosLibraryPresenter")
                PopupLayerController:showLayer(
                    "ZhaosLibraryUI",
                    function(layer)
                        layer:showLayer(self._selfCreatedSkillSystem,function()
                            if self._callback then
                                self._callback()
                            end
                        end,ZhaosLibraryPresenter)
                    end
                )
            end)
        end
    )
end

isImplement(SelectSkillTypePresenter, ISelectSkillTypePresenterInput)
return SelectSkillTypePresenter
00000
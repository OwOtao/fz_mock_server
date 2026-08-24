local inherit = require("third.inherit.inherit")
local ISelfCreatedSkillMenuPresenterOutput = require("app.presenters.selfCreatedSkill.selfCreatedSkillMenu.ISelfCreatedSkillMenuPresenterOutput")
local ISelfCreatedSkillMenuPresenterInput = require("app.presenters.selfCreatedSkill.selfCreatedSkillMenu.ISelfCreatedSkillMenuPresenterInput")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local isImplement = require("third.assertIsInstance.assertIsInstance")

local SelfCreatedSkillMenuPresenter = {}

function SelfCreatedSkillMenuPresenter:create(ISelfCreatedSkillMenuOutput,selfCreatedSkillSystem)
    local p = inherit({}, SelfCreatedSkillMenuPresenter)
    p:init(ISelfCreatedSkillMenuOutput,selfCreatedSkillSystem)
    return p
end

function SelfCreatedSkillMenuPresenter:init(ISelfCreatedSkillMenuOutput,selfCreatedSkillSystem)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._ISelfCreatedSkillMenuPresenterOutput = isImplement(ISelfCreatedSkillMenuOutput, ISelfCreatedSkillMenuPresenterOutput)
end


function SelfCreatedSkillMenuPresenter:showLayer()
    self:setCostPotAndJing()
    self:setTextPot()
    self:setTextJing()
    self:setTextDsc()
    self:setTextSkillNum()
    self:setTextCurrSkillName()
    self:setButtonCreate()
    self:setButton1()

    self._ISelfCreatedSkillMenuPresenterOutput:setShowLayer()
end

function SelfCreatedSkillMenuPresenter:refreshLayer()
    self:setCostPotAndJing()
    self:setTextPot()
    self:setTextJing()
    self:setTextSkillNum()
    self:setTextCurrSkillName()
    self:setButtonCreate()
    self:setButton1()
end

function SelfCreatedSkillMenuPresenter:setTextPot()
    local role = self._selfCreatedSkillSystem:getRole()
    local pot = role:getNumAttr("pot")
    self._ISelfCreatedSkillMenuPresenterOutput:setTextPot("『潜能』"..pot)
end

function SelfCreatedSkillMenuPresenter:setTextJing()
    local role = self._selfCreatedSkillSystem:getRole()
    local jing = role:getNumAttr("jing")
    self._ISelfCreatedSkillMenuPresenterOutput:setTextJing("『精力』"..jing)
end

function SelfCreatedSkillMenuPresenter:setTextDsc()
    local text = "这是一间幽静的书房。书房远离喧嚣，关上房门像是与世隔绝，只有若有若无的墨香从里面传出，是静心创作的合适场所。"
    self._ISelfCreatedSkillMenuPresenterOutput:setTextDsc(text)
end

function SelfCreatedSkillMenuPresenter:setTextSkillNum()
    local count = self._selfCreatedSkillSystem:getBookCount()

    self._ISelfCreatedSkillMenuPresenterOutput:setTextSkillNum(count.."/"..SelfCreatedSkillConstants.SelfCreatedSkillCountMax)
end

function SelfCreatedSkillMenuPresenter:setTextCurrSkillName()
    local isCreating = self._selfCreatedSkillSystem:checkIsCreating()
    local text1,text2,text3,text4 = "","","",""
    if isCreating == false then
        text2 = "当前尚未开始自创武学"
        text4 = "本次消耗"..self._costPot.."潜能，"..self._costJing.."精力"
    else
        local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
        local skillTypeName = skill:getSkillTypeName()
        text1 = skillTypeName
        text2 = "当前正在自创一门"
        text3 = "武学"
    end
    self._ISelfCreatedSkillMenuPresenterOutput:setText4(text1)
    self._ISelfCreatedSkillMenuPresenterOutput:setText5(text2)
    self._ISelfCreatedSkillMenuPresenterOutput:setText6(text3)
    self._ISelfCreatedSkillMenuPresenterOutput:setText7(text4)
end

function SelfCreatedSkillMenuPresenter:setButton1()
    local buttonEnabled = false
    local count = self._selfCreatedSkillSystem:getBookCount()
    if count > 0 then
        buttonEnabled = true
    end
    self._ISelfCreatedSkillMenuPresenterOutput:setButton1(buttonEnabled,function()
        Audio:playEffect("xiaoAnNiu")
        PopupLayerController:showLayer("BookRackUI",function(layer)
            layer:setHideCallback(function()
                self:refreshLayer()
            end)
			layer:showLayer()
		end)
    end)
end

function SelfCreatedSkillMenuPresenter:setCostPotAndJing()
    local role = self._selfCreatedSkillSystem:getRole()
    local roleLv = role:getLv()
    local lvRateMap = SelfCreatedSkillManager:getConsumeLvRateMap(roleLv)
    local zhaoRateMap =  SelfCreatedSkillManager:getConsumeZhaoRateMap(0)
    local lvPotRate = lvRateMap.costPot
    local lvJingRate = lvRateMap.costJingLi
    local zhaoCostRate = zhaoRateMap.costParam
    local costPot =  math.floor(lvPotRate * zhaoCostRate)
    local costJing = math.floor(lvJingRate * zhaoCostRate)
    self._costPot = costPot
    self._costJing = costJing
end

function SelfCreatedSkillMenuPresenter:setButtonCreate()
    local isCreating = self._selfCreatedSkillSystem:checkIsCreating()
    local isStart = false
    local buttonName = "自创武学"
    if isCreating ~= false then
        isStart = true
        buttonName = "继续自创"
    end
    self._ISelfCreatedSkillMenuPresenterOutput:setButtonCreate(buttonName,function()
        if isStart == false then
            Audio:playEffect("daAnNiu")
            local count = self._selfCreatedSkillSystem:getBookCount()
            if count >= SelfCreatedSkillConstants.SelfCreatedSkillCountMax then
                self._ISelfCreatedSkillMenuPresenterOutput:popText("你的书架已经满了")
                return
            end
           
            local role = self._selfCreatedSkillSystem:getRole()
            local pot = role:getNumAttr("pot")
            local jing = role:getNumAttr("jing")
            if pot < self._costPot  then
                self._ISelfCreatedSkillMenuPresenterOutput:popText("你的潜能不够")
                return
            end
            if jing < self._costJing  then
                self._ISelfCreatedSkillMenuPresenterOutput:popText("你的精力不够")
                return
            end
            self:showSelectSkillTypeUI()
        else
            Audio:playEffect("daSuanPan")
            local ZhaosLibraryPresenter = require("app.presenters.selfCreatedSkill.zhaosLibrary.ZhaosLibraryPresenter")
            PopupLayerController:showLayer(
                "ZhaosLibraryUI",
                function(layer)
                    layer:showLayer(self._selfCreatedSkillSystem,function()
                        self:refreshLayer()
                    end,ZhaosLibraryPresenter)
                end
            )
        end
    end)
end

function SelfCreatedSkillMenuPresenter:showSelectSkillTypeUI()
    PopupLayerController:showLayer("SelectSkillTypeUI", function(layer)
        layer:showLayer(self._selfCreatedSkillSystem,function()
            self:refreshLayer()
        end,self._costPot,self._costJing)
    end)
end


isImplement(SelfCreatedSkillMenuPresenter, ISelfCreatedSkillMenuPresenterInput)
return SelfCreatedSkillMenuPresenter
00000000000000
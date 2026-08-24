local inherit = require("third.inherit.inherit")
local IZhaosLibraryPresenterOutput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterOutput")
local IZhaosLibraryPresenterInput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local TuJianUtil = require("app.models.TuJian.TuJianUtil")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ZhaosLibraryPresenter = {}

function ZhaosLibraryPresenter:create(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    local p = inherit({}, ZhaosLibraryPresenter)
    p:init(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    return p
end

function ZhaosLibraryPresenter:init(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback

    self._IZhaosLibraryOutput = isImplement(IZhaosLibraryOutput, IZhaosLibraryPresenterOutput)
end


function ZhaosLibraryPresenter:showLayer(skillId)
    self:setTextPot()
    self:setTextJing()
    self:setTextDsc()
    self:setButtonComplete()
    self:setPanelCreateZhao()
    self:setButtonSkillInfo()
    self:showZhaosListView()
    self:setBackButton()
    self:setButtonProp()

    self._IZhaosLibraryOutput:setButtonCreateZhaoIsVisible(true)	
    self._IZhaosLibraryOutput:setButtonCompleteIsVisible(true)
    self._IZhaosLibraryOutput:setButtonPropIsVisible(true)
    
    self._IZhaosLibraryOutput:setShowLayer()
end

function ZhaosLibraryPresenter:refreshLayer()
    self:setTextPot()
    self:setTextJing()
    self:setPanelCreateZhao()
    self:setButtonComplete()
    self:showZhaosListView()
end

function ZhaosLibraryPresenter:setTextPot()
    local role = self._selfCreatedSkillSystem:getRole()
    local pot = role:getNumAttr("pot")
    self._IZhaosLibraryOutput:setTextPot("『潜能』"..pot)
end

function ZhaosLibraryPresenter:setTextJing()
    local role = self._selfCreatedSkillSystem:getRole()
    local jing = role:getNumAttr("jing")
    self._IZhaosLibraryOutput:setTextJing("『精力』"..jing)
end

function ZhaosLibraryPresenter:setTextDsc()
    local role = self._selfCreatedSkillSystem:getRole()
    local text1 = "这些是你还在反复推敲的招式。"
    local text2 = ""
    local text3 = ""
    do
        local dsc = ""
        local finalScore = 0
        local tujianIndexArray = TuJianUtil:getTujianIndexArray()
        for i ,v in ipairs(tujianIndexArray) do
            finalScore = finalScore + TuJianUtil:getWuXueScore(v,role)
        end 

        local dscList = TuJianUtil:getTujianDscList()

        for i, v in ipairs(dscList) do
            if finalScore >= v.score then
                dsc = v.dsc
            end
        end

        text2 = "你的武学成就已达YEL"..dsc.."NOR之境"
    end

    do
        local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
        local tujianIndex = skill:getSkillTuJianIndex()
        local indexText = TuJianUtil:getTypeChineseName(tujianIndex)
        local score = TuJianUtil:getWuXueScore(tujianIndex)
        local textarry = TuJianUtil:getTextArry(tujianIndex,score)
		local text = textarry.wxtext

		text3 = "你的"..indexText.."类武学心得已达"..text.."之境。"
    end
    self._IZhaosLibraryOutput:setTextDsc(text1.."\n"..text2.."，"..text3)
end

function ZhaosLibraryPresenter:setButtonComplete()
    local skillCreator = self._selfCreatedSkillSystem:getSkillCreator() 
    local buttonEnabled = skillCreator:isCreateZhaoCompleted()
    self._IZhaosLibraryOutput:setButtonComplete(buttonEnabled,function()
        Audio:playEffect("xiaoAnNiu")
        local text = "你确定要完成招式创作吗？"
        local dsc = ""
        local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
        local propId = skill:getPropId()
        local prop = SelfCreatedSkillManager:getPropMap(propId)
        if prop then
            dsc = "完成招式将会失去"..prop.name
        end
        self:showConfirmLayer(text,dsc,function()
            self:showCreateSkillUI()
        end)
    end)
end

function ZhaosLibraryPresenter:getZhaoNumText(zhaoNum)
    local text = ""
    if zhaoNum >= 15 then
        text = "颇多"
    elseif zhaoNum >= 7 then
        text = "较多"
    else
        text = "少量"
    end
    return text
end

function ZhaosLibraryPresenter:getSuccessRateText(successRate)
    local text = ""
    if successRate >= 0.9 then
        text = "HIY易如反掌"
    elseif successRate >= 0.7 then
        text = "HIY较为轻松"
    elseif successRate >= 0.5 then
        text = "HIB有些艰难"
    elseif successRate >= 0.3 then
        text = "HIR甚是艰难"
    else
        text = "HIR极为困难"
    end
    return text
end


function ZhaosLibraryPresenter:setPanelCreateZhao()
    local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
    local propId = skill:getPropId()

    local propRate = 0
    local propText = ""
    local prop = SelfCreatedSkillManager:getPropMap(propId)
    if prop then
        propRate = prop.costCutDown
        propText = "当前已经使用:"..prop.name
    end
    self._IZhaosLibraryOutput:setButtonCreateZhao(function()
        Audio:playEffect("daAnNiu")
        local skillCreator = self._selfCreatedSkillSystem:getSkillCreator() 
        if skillCreator:isCreateZhaoUpperLimit() then
            self._IZhaosLibraryOutput:popText("你的招式已经足够多了。")
            return
        end 
        self._selfCreatedSkillSystem:getZhaoSuccessRate(function(successRate)
            local role = self._selfCreatedSkillSystem:getRole()
            local roleLv = role:getLv()
            local pot = role:getNumAttr("pot")
            local jing = role:getNumAttr("jing")
            local zhaoNum = skill:getZhaoNum()
            local zhaoNumText = self:getZhaoNumText(zhaoNum)
            local successRateText = self:getSuccessRateText(successRate)
            local lvRateMap = SelfCreatedSkillManager:getConsumeLvRateMap(roleLv)
            local zhaoRateMap =  SelfCreatedSkillManager:getConsumeZhaoRateMap(zhaoNum)
            local lvPotRate = lvRateMap.costPot
            local lvJingRate = lvRateMap.costJingLi
            local zhaoCostRate = zhaoRateMap.costParam
            local costPot = math.floor((lvPotRate * zhaoCostRate)*(1-propRate))
            local costJing = math.floor((lvJingRate * zhaoCostRate)*(1-propRate))

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show("本次需要消耗"..costPot.."潜能，"..costJing.."精力！你确定要自创吗？","你已经创作出"..zhaoNumText.."招式，本次创作"..successRateText)
            dialog:setButton1("确定",function()
                if pot < costPot  then
                    self._IZhaosLibraryOutput:popText("你的潜能不够")
                    return
                end
                if jing < costJing  then
                    self._IZhaosLibraryOutput:popText("你的精力不够")
                    return
                end
                
                self._selfCreatedSkillSystem:createZhao(skill:getThirdType(),function(ret,msg,zhaoData)
                    role:addAttr("pot",-costPot)
                    role:addAttr("jing",-costJing)
                    self._IZhaosLibraryOutput:popText("潜能-"..costPot)
                    self._IZhaosLibraryOutput:popText("精力-"..costJing)
                    self:showCreatedZhaoLayer({ret = ret,msg = msg,zhaoData = zhaoData})
                end)
            end)
            dialog:setButton2("取消",function()
            end)
            dialog:setWeChatVisible(false)
        end)
    end)
    self._IZhaosLibraryOutput:setTextUseProp(propText)
end

function ZhaosLibraryPresenter:showCreatedZhaoLayer(zhaoCreateResult)
    PopupLayerController:showLayer(
        "CreatedZhaoUI",
        function(layer)
            if zhaoCreateResult.ret == true then
                layer:setAfterAnimCallback(
                    function()
                        layer:setPanelCreateZhaoNameIsVisible(true)
                    end
                )
            else
                layer:setAfterAnimCallback(
                    function()
                        self._IZhaosLibraryOutput:richPrint(zhaoCreateResult.msg)
                        layer:setButtonHide(true,function()
                            self:refreshLayer()
                            layer:hideLayer()
                        end)
                    end
                )
            end
            layer:setBackgroundMusic("createZhao",true)
            layer:setCreatingMusicEffect("creatingZhao",false)
            layer:showLayer(self._selfCreatedSkillSystem,zhaoCreateResult,function()
                self:refreshLayer()
            end)
        end
    )
end

function ZhaosLibraryPresenter:setButtonSkillInfo()
    self._IZhaosLibraryOutput:setButtonSkillInfo(function()
        Audio:playEffect("xiaoAnNiu")
        self:showCurrSkillInfoUI()
    end)
end

function ZhaosLibraryPresenter:showZhaosListView()
    local zhaoArray = {}
    local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
    for zhaoIndex,zhao in ipairs(skill:getZhaos()) do
        local zhaolist = {}
        local zhaoName = zhao:getName()
        local zhaoDscId = zhao:getDscId()
        local zhaoNameColor = zhao:getColor()
        zhaolist["Text_zhaoIndex"] = self:getTextZhaoIndex(zhaoIndex)
        zhaolist["Text_zhaoNameColor"] = zhaoNameColor
        zhaolist["Text_zhaoName"] = zhaoName
        zhaolist["Text_zhaoType"] = zhao:getUseTypeText()
        zhaolist["TextField_desc"] = SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(zhaoDscId,zhao)
        if zhao:getUseType() == 2 then
            zhaolist["Image"] = "Image/UI/SelfCreatedSkillUI/dikuang2.png"
        else
            zhaolist["Image"] = "Image/UI/SelfCreatedSkillUI/dikuang.png"
        end  
        zhaolist["Button_func"] = function()
            Audio:playEffect("xiaoAnNiu")
            self:showZhaoInfoUI(zhaoIndex)
        end
        table.insert( zhaoArray, zhaolist)
    end
    self._IZhaosLibraryOutput:setShowZhaosListView(zhaoArray)
end

function ZhaosLibraryPresenter:getTextZhaoIndex(zhaoIndex)
    local str = "第"..Helper:numberCast(zhaoIndex).."招"
    local newStr = ""
    for i = 1,string.len(str)/3 do
        local startP = 3*i-2
        local endP = 3*i
        newStr = newStr..string.sub(str,startP,endP).."\n"
    end
    return newStr
end

function ZhaosLibraryPresenter:showCreateSkillUI()
    PopupLayerController:showLayer("CreatedSkillUI",function(layer)
        layer:showLayer(self._selfCreatedSkillSystem,function()
            self._IZhaosLibraryOutput:hideLayer()
            if self._callback then
                self._callback()
            end
        end)
    end)
end

function ZhaosLibraryPresenter:showZhaoInfoUI(zhaoIndex)
    PopupLayerController:showLayer("ZhaoInfoUI",function(layer)
        local ZhaoInfoPresenter = require("app.presenters.selfCreatedSkill.zhaoInfo.ZhaoInfoPresenter")
        layer:showLayer(self._selfCreatedSkillSystem,zhaoIndex,function()
            self:refreshLayer()
        end,ZhaoInfoPresenter)
    end)
end

function ZhaosLibraryPresenter:showCurrSkillInfoUI()
    PopupLayerController:showLayer("CurrSkillInfoUI",function(layer)
        local skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()
        layer:showLayer(self._selfCreatedSkillSystem,skill)
    end)
end

function ZhaosLibraryPresenter:setBackButton()
    self._IZhaosLibraryOutput:setBackButton(function()
        Audio:playEffect("fanHuiQuXiao")
        self._IZhaosLibraryOutput:hideLayer()
        if self._callback then
            self._callback()
        end
    end)
end

function ZhaosLibraryPresenter:setButtonProp()
    self._IZhaosLibraryOutput:setButtonProp(function()
        Audio:playEffect("xiaoAnNiu")
        self._selfCreatedSkillSystem:getCreatePropList(function(propList)
            PopupLayerController:showLayer("ZhaoImprovedPoolUI",
            function(layer)
                local presenter = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.ZhaoCreatePropPresenter")
                layer:showLayer(self._selfCreatedSkillSystem,propList,presenter,self._zhaoIndex,true,function()
                    self:setPanelCreateZhao()
                end)
            end)
        end)
    end)
end

function ZhaosLibraryPresenter:showConfirmLayer(text,dsc,func)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(text,dsc)
    dialog:setButton1("确定",function()
        if func then
            func()
        end
    end)
    dialog:setButton2("取消",function()
    end)
    dialog:setWeChatVisible(false)
end

isImplement(ZhaosLibraryPresenter, IZhaosLibraryPresenterInput)
return ZhaosLibraryPresenter
0000000000000
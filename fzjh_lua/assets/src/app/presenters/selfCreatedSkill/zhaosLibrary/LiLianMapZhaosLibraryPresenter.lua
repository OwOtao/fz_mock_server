local inherit = require("third.inherit.inherit")
local IZhaosLibraryPresenterOutput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterOutput")
local IZhaosLibraryPresenterInput = require("app.presenters.selfCreatedSkill.zhaosLibrary.IZhaosLibraryPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill")
local TuJianUtil = require("app.models.TuJian.TuJianUtil")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local LiLianMapZhaosLibraryPresenter = {}

function LiLianMapZhaosLibraryPresenter:create(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    local p = inherit({}, LiLianMapZhaosLibraryPresenter)
    p:init(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    return p
end

function LiLianMapZhaosLibraryPresenter:init(IZhaosLibraryOutput,selfCreatedSkillSystem,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback

    self._IZhaosLibraryOutput = isImplement(IZhaosLibraryOutput, IZhaosLibraryPresenterOutput)
end


function LiLianMapZhaosLibraryPresenter:showLayer(skillId)
    --自创武学
    self._skill = self._selfCreatedSkillSystem:getCreatedSkillBySkillId(skillId)

    self:setTextPot()
    self:setTextJing()
    self:setTextDsc()

    self:setButtonSkillInfo()
    self:showZhaosListView()
    self:setBackButton()

    self._IZhaosLibraryOutput:setButtonCreateZhaoIsVisible(false)	
    self._IZhaosLibraryOutput:setButtonCompleteIsVisible(false)
    self._IZhaosLibraryOutput:setButtonPropIsVisible(false)
    
    self._IZhaosLibraryOutput:setShowLayer()
end

function LiLianMapZhaosLibraryPresenter:refreshLayer()
    self:showZhaosListView()
end

function LiLianMapZhaosLibraryPresenter:setTextPot()
    local role = self._selfCreatedSkillSystem:getRole()
    local pot = role:getNumAttr("pot")
    self._IZhaosLibraryOutput:setTextPot("『潜能』"..pot)
end

function LiLianMapZhaosLibraryPresenter:setTextJing()
    local role = self._selfCreatedSkillSystem:getRole()
    local jing = role:getNumAttr("jing")
    self._IZhaosLibraryOutput:setTextJing("『精力』"..jing)
end

function LiLianMapZhaosLibraryPresenter:setTextDsc()
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
        local tujianIndex = self._skill:getSkillTuJianIndex()
        local indexText = TuJianUtil:getTypeChineseName(tujianIndex)
        local score = TuJianUtil:getWuXueScore(tujianIndex)
        local textarry = TuJianUtil:getTextArry(tujianIndex,score)
		local text = textarry.wxtext

		text3 = "你的"..indexText.."类武学心得已达"..text.."之境。"
    end
    self._IZhaosLibraryOutput:setTextDsc(text1.."\n"..text2.."，"..text3)
end

function LiLianMapZhaosLibraryPresenter:setButtonSkillInfo()
    self._IZhaosLibraryOutput:setButtonSkillInfo(function()
        Audio:playEffect("xiaoAnNiu")
        self:showCurrSkillInfoUI()
    end)
end

function LiLianMapZhaosLibraryPresenter:showZhaosListView()
    local zhaoArray = {}
    local zhaos = self._skill:getZhaos()
    for zhaoIndex,zhao in ipairs(zhaos) do
        local zhaolist = {}
        local zhaoName = zhao:getName()
        local zhaoDscId = zhao:getDscId()
        local zhaoColorId = zhao:getColorId()
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
        table.insert(zhaoArray, zhaolist)
    end
    self._IZhaosLibraryOutput:setShowZhaosListView(zhaoArray)
end

function LiLianMapZhaosLibraryPresenter:getTextZhaoIndex(zhaoIndex)
    local str = "第"..Helper:numberCast(zhaoIndex).."招"
    local newStr = ""
    for i = 1,string.len(str)/3 do
        local startP = 3*i-2
        local endP = 3*i
        newStr = newStr..string.sub(str,startP,endP).."\n"
    end
    return newStr
end


function LiLianMapZhaosLibraryPresenter:showZhaoInfoUI(zhaoIndex)
    PopupLayerController:showLayer("ZhaoInfoUI",function(layer)
        local LiLianMapZhaoInfoPresenter = require("app.presenters.selfCreatedSkill.zhaoInfo.LiLianMapZhaoInfoPresenter")
        layer:showLayer(self._selfCreatedSkillSystem,zhaoIndex,function()
            self._skill = self._selfCreatedSkillSystem:getCreatedSkillBySkillId(self._skill:getId())
            self:refreshLayer()
        end,LiLianMapZhaoInfoPresenter, self._skill)
    end)
end

function LiLianMapZhaosLibraryPresenter:showCurrSkillInfoUI()
    PopupLayerController:showLayer("CurrSkillInfoUI",function(layer)
        layer:showLayer(self._selfCreatedSkillSystem,self._skill)
    end)
end

function LiLianMapZhaosLibraryPresenter:setBackButton()
    self._IZhaosLibraryOutput:setBackButton(function()
        Audio:playEffect("fanHuiQuXiao")
        self._IZhaosLibraryOutput:hideLayer()
        if self._callback then
            self._callback()
        end
    end)
end

isImplement(LiLianMapZhaosLibraryPresenter, IZhaosLibraryPresenterInput)
return LiLianMapZhaosLibraryPresenter
00000
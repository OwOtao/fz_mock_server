local inherit = require("third.inherit.inherit")
local ICreatedSkillPresenterOutput = require("app.presenters.selfCreatedSkill.createdSkill.ICreatedSkillPresenterOutput")
local ICreatedSkillPresenterInput = require("app.presenters.selfCreatedSkill.createdSkill.ICreatedSkillPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local CreatedSkillPresenter = {}

function CreatedSkillPresenter:create(ICreatedSkillOutput,selfCreatedSkillSystem,callback)
    local p = inherit({}, CreatedSkillPresenter)
    p:init(ICreatedSkillOutput,selfCreatedSkillSystem,callback)
    return p
end

function CreatedSkillPresenter:init(ICreatedSkillOutput,selfCreatedSkillSystem,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback
    self._skillCreator = self._selfCreatedSkillSystem:getSkillCreator()
    self._skill = self._selfCreatedSkillSystem:getSelfCreatingSkill()

    self._ICreatedSkillOutput = isImplement(ICreatedSkillOutput, ICreatedSkillPresenterOutput)
end


function CreatedSkillPresenter:showLayer()
    self._selectAffixState = 1
    self._nameAffix = self._skill:getNameAffixId()

    self:createEditBox()
    self:setButtonOk()
    self:setRandomNameButton()
    self:setButtonSelectNameAfterAffix()
    self:setNameAffix()
    self:showTextSkillDsc()
    self:showTextPreSkillType()
    self:showTextEquipType()
    self:showTextActiveZhaoNum()
    self:showTextAutoZhaoNum()

    self:showTextStr1()
    self:showTextStr2()
    self:showTextStr3()
    self:showTextStr4()
    self:showTextStr5()
    self:showTextStr6()
    self:showTextStr7()
    self:showTextStr8()
    
    self._ICreatedSkillOutput:setShowLayer()
end

function CreatedSkillPresenter:createEditBox()
    self._ICreatedSkillOutput:createEditBox()
end

function CreatedSkillPresenter:setButtonSelectNameAfterAffix()
    self._ICreatedSkillOutput:setButtonSelectNameAfterAffix(function()
        Audio:playEffect("xiaoAnNiu")
        if self._selectAffixState == 1 then
            self._selfCreatedSkillSystem:getSkillNameAffixs(function(affixList)
                self._selectAffixState = 2
                self._ICreatedSkillOutput:setPanelHideIsVisible(true)
                self._ICreatedSkillOutput:setPanel4IsVisible(true)
                self._ICreatedSkillOutput:setImageDownIsVisible(false)
                self._ICreatedSkillOutput:setImageUpIsVisible(true)
                
                self:setNameAfterAffixListView(affixList)
            end)
        else
            self._selectAffixState = 1
            self._ICreatedSkillOutput:setPanelHideIsVisible(false)
            self._ICreatedSkillOutput:setPanel4IsVisible(false)
            self._ICreatedSkillOutput:setImageDownIsVisible(true)
            self._ICreatedSkillOutput:setImageUpIsVisible(false)
        end
    end)
end

function CreatedSkillPresenter:setNameAfterAffixListView(affixList)
    local retTab = {}
    for i,v in ipairs(affixList) do
        local affixArray = {
            nameAffix = "",
            ImageSuoIsVisible = false,
            func = EMPTY_FUNC,
        }
        local affixId = v.id
        local affixData = SelfCreatedSkillManager:getSkillNameAfterAffixMap(affixId)
        if v.state == 1 then
            affixArray["nameAffix"] = affixData.name
            affixArray["ImageSuoIsVisible"] = false
            affixArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                self._selectAffixState = 1
                self._ICreatedSkillOutput:setPanelHideIsVisible(false)
                self._ICreatedSkillOutput:setPanel4IsVisible(false)
                self._ICreatedSkillOutput:setImageDownIsVisible(true)
                self._ICreatedSkillOutput:setImageUpIsVisible(false)

                self._nameAffix = affixId
                self:setNameAffix()
            end
        else
            affixArray["nameAffix"] = affixData.name
            affixArray["ImageSuoIsVisible"] = true
            affixArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                local textList = {
                    Text_tital = affixData.name,
                    Text_type = "",
                    Text_dsc = affixData.dsc,
                    Text_price = "售价:"..v.price.."元宝",
                    Text_affirm = "确定购买"..affixData.name.."吗？",
                    Text_havenum = "",
                }
                local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
                PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                    layer:showLayer(textList,function()
                    end)
                    layer:setButton_confirm("确定",function()
                        self._selfCreatedSkillSystem:unlockSkillNameAffixs(affixId,function(newAffixList)
                            self:setNameAfterAffixListView(newAffixList)
                        end)
                    end)
                    layer:setButton_close("取消", function()
                    end)
                end)
            end
        end

        table.insert( retTab, affixArray)
    end

    self._ICreatedSkillOutput:setDscListView(retTab)
end

function CreatedSkillPresenter:setNameAffix()
    local textId = self._nameAffix
    local text = SelfCreatedSkillManager:getSkillNameAfterAffixMap(textId).name
    self._ICreatedSkillOutput:setNameAffix(text)
end

function CreatedSkillPresenter:showTextSkillDsc()
    local text = self._skill:getCreatedSkillDsc()
    self._ICreatedSkillOutput:setTextSkillDsc(text)
end

function CreatedSkillPresenter:showTextPreSkillType()
    local skillTypeName = self._skill:getSkillTypeName()
    self._ICreatedSkillOutput:setTextPreSkillType("可准备为："..skillTypeName)
end

function CreatedSkillPresenter:showTextEquipType()
    local text = self._skill:getWeapontypeText()
    if text == 0 or text == nil then
        text = ""
    else
        text = "需要装备："..text
    end
    self._ICreatedSkillOutput:setTextEquipType(text)
end

function CreatedSkillPresenter:showTextActiveZhaoNum()
    local text = 0
    self._ICreatedSkillOutput:setTextActiveZhaoNum(text)
end

function CreatedSkillPresenter:showTextAutoZhaoNum()
    local zhaosNum = self._skill:getZhaoNum()
    self._ICreatedSkillOutput:setTextAutoZhaoNum(zhaosNum)
end

function CreatedSkillPresenter:showTextStr1()
    local text = "【力道】"
    local level = self._skill:getAttackLevel()
    self._ICreatedSkillOutput:setTextStr1(text)
    self._ICreatedSkillOutput:setTextLevel1(level)
end

function CreatedSkillPresenter:showTextStr2()
    local text = "【命中】"
    local level = self._skill:getHitLevel()
    self._ICreatedSkillOutput:setTextStr2(text)
    self._ICreatedSkillOutput:setTextLevel2(level)
end

function CreatedSkillPresenter:showTextStr3()
    local text = "【防御】"
    local level = self._skill:getDefenseLevel()
    self._ICreatedSkillOutput:setTextStr3(text)
    self._ICreatedSkillOutput:setTextLevel3(level)
end

function CreatedSkillPresenter:showTextStr4()
    local text = "【格挡】"
    local level = self._skill:getParryLevel()
    self._ICreatedSkillOutput:setTextStr4(text)
    self._ICreatedSkillOutput:setTextLevel4(level)
end

function CreatedSkillPresenter:showTextStr5()
    local text = "【攻速】"
    local level = self._skill:getAttackSpeedLevel()
    self._ICreatedSkillOutput:setTextStr5(text)
    self._ICreatedSkillOutput:setTextLevel5(level)
end

function CreatedSkillPresenter:showTextStr6()
    local text = "【闪躲】"
    local level = self._skill:getDodgeLevel()
    self._ICreatedSkillOutput:setTextStr6(text)
    self._ICreatedSkillOutput:setTextLevel6(level)
end

function CreatedSkillPresenter:showTextStr7()
    local text = "【气血】"
    local level = self._skill:getBloodLevel()
    self._ICreatedSkillOutput:setTextStr7(text)
    self._ICreatedSkillOutput:setTextLevel7(level)
end

function CreatedSkillPresenter:showTextStr8()
    local text = "【回复】"
    local level = self._skill:getRecoveryLevel()
    self._ICreatedSkillOutput:setTextStr8(text)
    self._ICreatedSkillOutput:setTextLevel8(level)
end

function CreatedSkillPresenter:setButtonOk()
    self._ICreatedSkillOutput:setButtonOk(function(editName)
        Audio:playEffect("xiaoAnNiu")
        local count = self._selfCreatedSkillSystem:getBookCount()
        if count >= SelfCreatedSkillConstants.SelfCreatedSkillCountMax then
            self._ICreatedSkillOutput:popText("自创武学数量达到上限")
            return
        end
        local skillName = editName..SelfCreatedSkillManager:getSkillNameAfterAffixMap(self._nameAffix).name
        
        if self:checkSkillName(editName) and (self:checkSkillName(skillName) and self:__isOfficially(skillName)) then
            self._selfCreatedSkillSystem:completeSkillCreate(skillName,function()
                if self._callback then
                    self._callback()
                end
                self._ICreatedSkillOutput:hideLayer()
            end)
        end
    end)
end

function CreatedSkillPresenter:setRandomNameButton()
    self._ICreatedSkillOutput:setRandomNameButton(function()
        Audio:playEffect("xiaoAnNiu")
        return self._skillCreator:createRandomName()
    end)
end

function CreatedSkillPresenter:__isOfficially(name)
    if Skill:getSkillsNameDict()[name] ~= nil then
        self._ICreatedSkillOutput:popText("该名称已存在!")
        return false
    end
    return true
end

function CreatedSkillPresenter:checkSkillName(name)
    if name == nil or name == "" then
        self._ICreatedSkillOutput:popText("名字不能为空!!!")
        return false
    end

    if not Helper:isChinese(name) then
        self._ICreatedSkillOutput:popText("名字必须是中文!!!")
        return false
    end

    -- 一个 utf－8的中文字，占3个字节
    if string.len(name) > 7 * 3 then		
        self._ICreatedSkillOutput:popText("名字最多七个字")
        return false
    end

    if self:__checkIsSkillMaskWord(name)  then
        -- self._ICreatedSkillOutput:popText("名字包含不合法字符!")
        self._ICreatedSkillOutput:popText(tostring(name) .. " 是非法词汇，请更换后再试。")
        return false
    end

    if Helper:isMaskOff(name)  then
        -- self._ICreatedSkillOutput:popText("名字包含不合法字符!")
        self._ICreatedSkillOutput:popText(tostring(name) .. " 是非法词汇，请更换后再试。")
        return false
    else
        return true
    end
end


function CreatedSkillPresenter:__checkIsSkillMaskWord(skillName)
     return SelfCreatedSkillManager:checkIsMaskWords(skillName)
end

isImplement(CreatedSkillPresenter, ICreatedSkillPresenterInput)
return CreatedSkillPresenter
00000
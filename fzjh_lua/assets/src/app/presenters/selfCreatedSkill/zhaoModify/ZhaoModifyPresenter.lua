local inherit = require("third.inherit.inherit")
local IZhaoModifyPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoModify.IZhaoModifyPresenterOutput")
local IZhaoModifyPresenterInput = require("app.presenters.selfCreatedSkill.zhaoModify.IZhaoModifyPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ZhaoModifyPresenter = {}

function ZhaoModifyPresenter:create(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex)
    local p = inherit({}, ZhaoModifyPresenter)
    p:init(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex)
    return p
end

function ZhaoModifyPresenter:init(IZhaoInfoOutput,selfCreatedSkillSystem,zhaoIndex)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    local skillCreator = self._selfCreatedSkillSystem:getSkillCreator()
    self._zhaoIndex = zhaoIndex
    self._zhao = self._selfCreatedSkillSystem:getSelfCreatingZhao(self._zhaoIndex)
    self._zhaoCreator = skillCreator:getZhaoCreator(zhaoIndex)

    self._IZhaoModifyOutput = isImplement(IZhaoInfoOutput, IZhaoModifyPresenterOutput)
end


function ZhaoModifyPresenter:showLayer(callback)
    self._zhaoDscId = self._zhao:getDscId()
    self._colorId = self._zhao:getColorId()
    self._selectColorState = 1
    self.callback = callback
    self:showTextRandomDsc()
    self:createEditBox()
    self:setRandomNameButton()
    self:setRandomDscButton()
    self:setButtonSelectColor()
    self:showTextAndtEditBoxFontColor()

    self:setButtonOk()
    self:setButtonCancel()

    self._IZhaoModifyOutput:setShowLayer()
end

function ZhaoModifyPresenter:showTextRandomDsc()
    local text = SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(self._zhaoDscId,self._zhao)
    self._IZhaoModifyOutput:setTextRandomDsc(text)
end

function ZhaoModifyPresenter:createEditBox()
    local name = self._zhao:getName()
    self._IZhaoModifyOutput:createEditBox()
    self._IZhaoModifyOutput:setEditBoxText(name)
end

function ZhaoModifyPresenter:setRandomNameButton()
    self._IZhaoModifyOutput:setRandomNameButton(function()
        Audio:playEffect("xiaoAnNiu")
        return self._zhaoCreator:createRandomName()
    end)
end

function ZhaoModifyPresenter:setRandomDscButton()
    self._IZhaoModifyOutput:setRandomDscButton(function()
        Audio:playEffect("xiaoAnNiu")
        local templateId = self._zhao:getTemplateId()
        self._selfCreatedSkillSystem:getZhaoDscs(templateId,function(dscList)
            PopupLayerController:showLayer("ZhaoSelectDscUI",function(layer)
                layer:showLayer(self._selfCreatedSkillSystem,self._zhaoDscId,self._zhao,dscList,function(zhaoDscId)
                    self._zhaoDscId = zhaoDscId
                    self:showTextRandomDsc()
                end)
            end)
        end)
    end)
end

function ZhaoModifyPresenter:showTextAndtEditBoxFontColor()
    local colorData = SelfCreatedSkillManager:getZhaoColorMap(self._colorId)
    local color = {r = colorData.field1, g = colorData.field2, b = colorData.field3}
    self._IZhaoModifyOutput:setEditBoxFontColor(color)
end

function ZhaoModifyPresenter:setButtonSelectColor()
    self._IZhaoModifyOutput:setButtonSelectColor(function()
        Audio:playEffect("xiaoAnNiu")
        if self._selectColorState == 1 then
            self._selfCreatedSkillSystem:getZhaoColors(function(colorList)
                self._selectColorState = 2
                self._IZhaoModifyOutput:setPanelHideIsVisible(true)
                self._IZhaoModifyOutput:setPanel4IsVisible(true)
                self._IZhaoModifyOutput:setImageDownIsVisible(false)
                self._IZhaoModifyOutput:setImageUpIsVisible(true)
                
                self:setColorListView(colorList)
            end)
        else
            self._selectColorState = 1
            self._IZhaoModifyOutput:setPanelHideIsVisible(false)
            self._IZhaoModifyOutput:setPanel4IsVisible(false)
            self._IZhaoModifyOutput:setImageDownIsVisible(true)
            self._IZhaoModifyOutput:setImageUpIsVisible(false)
        end
        
    end)
end

function ZhaoModifyPresenter:setColorListView(colorList)
    local retTab = {}
    for i,v in ipairs(colorList) do
        local colorArray = {
            Image_1IsVisible = false,
            Image_1Image = "Image/UI/SelfCreatedSkillUI/color1.png",
            Image_2IsVisible = false,
            func = EMPTY_FUNC,
        }
        local colorId = v.id
        local colorData = SelfCreatedSkillManager:getZhaoColorMap(colorId)
        if v.state == 1 then
            colorArray["Image_1IsVisible"] = true
            colorArray["Image_1Image"] = colorData.image
            colorArray["Image_2IsVisible"] = false
            colorArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                self._selectColorState = 1
                self._IZhaoModifyOutput:setPanelHideIsVisible(false)
                self._IZhaoModifyOutput:setPanel4IsVisible(false)
                self._IZhaoModifyOutput:setImageDownIsVisible(true)
                self._IZhaoModifyOutput:setImageUpIsVisible(false)

                self._colorId = colorId
                self:showTextAndtEditBoxFontColor()
            end
        else
            colorArray["Image_1IsVisible"] = true
            colorArray["Image_1Image"] = colorData.image
            colorArray["Image_2IsVisible"] = true
            colorArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                local textList = {
                    Text_tital = colorData.name,
                    Text_type = "",
                    Text_dsc = colorData.dsc,
                    Text_price = "售价:"..v.price.."元宝",
                    Text_affirm = "确定购买"..colorData.name.."吗？",
                    Text_havenum = "",
                }
                local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
                PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                    layer:showLayer(textList,function()
                    end)
                    layer:setButton_confirm("确定",function()
                        self._selfCreatedSkillSystem:unlockZhaoColor(colorId,function(newColorList)
                            self:setColorListView(newColorList)
                        end)
                    end)
                    layer:setButton_close("取消", function()
                    end)
                end)
            end
        end

        table.insert( retTab, colorArray)
    end

    self._IZhaoModifyOutput:setColorListView(retTab)
end

function ZhaoModifyPresenter:setButtonOk()
    self._IZhaoModifyOutput:setButtonOk(function(editName)
        Audio:playEffect("xiaoAnNiu")
        if self:checkZhaoName(editName) then
            local params = {
                skillId = self._selfCreatedSkillSystem:getSelfCreatingSkill():getId(),
                zhaoIndex = self._zhaoIndex,
                name = editName,
                colorId = self._colorId,
                dscId = self._zhaoDscId
            }
            self._selfCreatedSkillSystem:setZhaoAttr(params,function()
                self._zhaoCreator:setZhaoDscId(self._zhaoDscId)
                self._zhaoCreator:setColorId(self._colorId)
                self._selfCreatedSkillSystem:setZhaoName(self._zhaoCreator,editName)
    
                if self.callback then
                    self.callback()
                end
                self:hideLayer()
            end)
        end
    end)
end

function ZhaoModifyPresenter:setButtonCancel()
    self._IZhaoModifyOutput:setButtonCancel(function()
        Audio:playEffect("xiaoAnNiu")
        self:hideLayer()
    end)
end

function ZhaoModifyPresenter:hideLayer()
    self._zhaoDscId = nil
    self._colorId = nil
    self._IZhaoModifyOutput:hideLayer()
end

function ZhaoModifyPresenter:checkZhaoName(name)
    if name == nil or name == "" then
        self._IZhaoModifyOutput:popText("名字不能为空!!!")
        return false
    end

    if not Helper:isChinese(name) then
        self._IZhaoModifyOutput:popText("名字必须是中文!!!")
        return false
    end

    -- 一个 utf－8的中文字，占3个字节
    if string.len(name) > 5 * 3 then		
        self._IZhaoModifyOutput:popText("名字最多五个字")
        return false
    end

    if Helper:isMaskOff(name)  then
        -- self._IZhaoModifyOutput:popText("名字包含不合法字符!")
        self._IZhaoModifyOutput:popText(tostring(name) .. " 是非法词汇，请更换后再试。")
        return false
    else
        return true
    end
end

isImplement(ZhaoModifyPresenter, IZhaoModifyPresenterInput)
return ZhaoModifyPresenter
00
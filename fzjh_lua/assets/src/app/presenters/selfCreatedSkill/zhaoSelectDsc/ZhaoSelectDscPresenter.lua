local inherit = require("third.inherit.inherit")
local IZhaoSelectDscPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoSelectDsc.IZhaoSelectDscPresenterOutput")
local IZhaoSelectDscPresenterInput = require("app.presenters.selfCreatedSkill.zhaoSelectDsc.IZhaoSelectDscPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ZhaoSelectDscPresenter = {}

function ZhaoSelectDscPresenter:create(IZhaoSelectDscOutput,selfCreatedSkillSystem,zhaoDscId,zhao,dscList,callback)
    local p = inherit({}, ZhaoSelectDscPresenter)
    p:init(IZhaoSelectDscOutput,selfCreatedSkillSystem,zhaoDscId,zhao,dscList,callback)
    return p
end

function ZhaoSelectDscPresenter:init(IZhaoSelectDscOutput,selfCreatedSkillSystem,zhaoDscId,zhao,dscList,callback)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._callback = callback
    self._currZhaoDscId = zhaoDscId
    self._dscList = dscList
    self._zhao = zhao
    
    self._IZhaoSelectDscOutput = isImplement(IZhaoSelectDscOutput, IZhaoSelectDscPresenterOutput)
end


function ZhaoSelectDscPresenter:showLayer()
    self:showZhaoDscListView(self._dscList)
    self:setBackButton()
    
    self._IZhaoSelectDscOutput:setShowLayer()
end

function ZhaoSelectDscPresenter:refreshLayer()
    self:showZhaoDscListView()
end

function ZhaoSelectDscPresenter:showZhaoDscListView(dscList)
    self:sortDscList(dscList)

    local retTab = {}
    for i,v in ipairs(dscList) do
        local dscArray = {
            dsc = "",
            Image2IsVisible = false,
            Image1IsVisible = true,
            ImageXZIsVisible = false,
            func = EMPTY_FUNC,
        }
        local xiLieId = v.xiLieId
        local text = SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(v.id,self._zhao)
        local xiLieData = SelfCreatedSkillManager:getZhaoDscXiLieMap(xiLieId)
        dscArray["dsc"] = text
        if v.state == 1 then
            dscArray["Image2IsVisible"] = false
            if tostring(self._currZhaoDscId) == tostring(v.id) then
                dscArray["Image1IsVisible"] = false
                dscArray["ImageXZIsVisible"] = true
            else
                dscArray["Image1IsVisible"] = true
                dscArray["ImageXZIsVisible"] = false
            end
            dscArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                self._currZhaoDscId = v.id
                if self._callback then
                    self._callback(self._currZhaoDscId)
                    self._IZhaoSelectDscOutput:hideLayer()
                end
            end
        else
            dscArray["Image1IsVisible"] = true
            dscArray["ImageXZIsVisible"] = false
            dscArray["Image2IsVisible"] = true
            dscArray["func"] = function()
                Audio:playEffect("xiaoAnNiu")
                local textList = {
                    Text_tital = xiLieData.name,
                    Text_type = "",
                    Text_dsc = xiLieData.dsc,
                    Text_price = "售价:"..v.price.."元宝",
                    Text_affirm = "确定购买"..xiLieData.name.."吗？",
                    Text_havenum = "",
                }
                local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
                PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                    layer:showLayer(textList,function()
                    end)
                    layer:setButton_confirm("确定",function()
                        self._selfCreatedSkillSystem:unlockZhaoDsc(xiLieId,self._zhao:getTemplateId(),
                            function(newDscList)
                                self:showZhaoDscListView(newDscList)
                            end)
                        end)
                    layer:setButton_close("取消", function()
                    end)
                end)
            end
        end

        table.insert(retTab, dscArray)
    end

    self._IZhaoSelectDscOutput:setShowZhaoDscListView(retTab)
end

function ZhaoSelectDscPresenter:sortDscList(dscList)
    for i,v in ipairs(dscList) do
        if tostring(self._currZhaoDscId) == tostring(v.id) then
            table.insert(dscList,1,table.remove(dscList,i))
            return dscList
        end
    end
    return dscList
end


function ZhaoSelectDscPresenter:setBackButton()
    self._IZhaoSelectDscOutput:setBackButton(function()
        Audio:playEffect("fanHuiQuXiao")
        if self._callback then
            self._callback(self._currZhaoDscId)
        end
        self._IZhaoSelectDscOutput:hideLayer()
    end)
end

isImplement(ZhaoSelectDscPresenter, IZhaoSelectDscPresenterInput)
return ZhaoSelectDscPresenter
00
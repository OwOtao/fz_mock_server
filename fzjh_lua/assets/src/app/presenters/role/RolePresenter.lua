local NewClass = require("third.class.NewClass")
local IRolePresenterInput = require("app.presenters.role.IRolePresenterInput")
local IRoleOutput = require("app.models.role.interface.IRoleOutput")

local RolePresenter = {}

function RolePresenter:create(iPresenterOutput, iRoleModelInput)
    local p = RolePresenter.new()
    p.__isNotSerializable = true
    p:init(iPresenterOutput, iRoleModelInput)
    return p
end

function RolePresenter:init(iPresenterOutput, iRoleModelInput)
    self._iPresenterOutput = iPresenterOutput
    self._iRoleModelInput = iRoleModelInput
    self._iRoleModelInput:setOutput(self)
end

function RolePresenter:useItem(itemId)
    self._iRoleModelInput:useItem(itemId)
end

function RolePresenter:popText(str)
    self._iPresenterOutput:popText(str)
end

function RolePresenter:richPrint(str)
    self._iPresenterOutput:richPrint(str)
end

function RolePresenter:showUseItemConfirm(item, onYes, onNo)
    self._iPresenterOutput:showUseItemConfirm(item, onYes, onNo)
end

function RolePresenter:showUseXiSuiDanConfirm(item, extraDesc, onYes, onNo)
    self._iPresenterOutput:showUseXiSuiDanConfirm(item, extraDesc, onYes, onNo)
end

function RolePresenter:showDrinkConfirm(onXiaoKou, onDakou)
    self._iPresenterOutput:showDrinkConfirm(onXiaoKou, onDakou)
end

function RolePresenter:showLearnChangShengJueYin(onConfirm, onCancel)
    self._iPresenterOutput:showLearnChangShengJueYin(onConfirm, onCancel)
end

function RolePresenter:showLearnChangShengJueYang(onConfirm, onCancel)
    self._iPresenterOutput:showLearnChangShengJueYang(onConfirm, onCancel)
end

function RolePresenter:delayTextPrint(delayTime, text)
    self._iPresenterOutput:delayTextPrint(delayTime, text)
end

function RolePresenter:showJunQingMiHanConfirm(onDestroy, onCancel)
    self._iPresenterOutput:showJunQingMiHanConfirm(onDestroy, onCancel)
end

function RolePresenter:showShiHeUse(dinnerName,dinnerValue,textList)
    self._iPresenterOutput:showShiHeUse(dinnerName,dinnerValue,textList)
end

function RolePresenter:showShiWuDuiHuan(okFunc)
    self._iPresenterOutput:showShiWuDuiHuan(okFunc)
end

function RolePresenter:showAttrChangePopText(role, attrName, attrValue, delayTime)
    self._iPresenterOutput:showAttrChangePopText(role, attrName, attrValue, delayTime)
end

function RolePresenter:showBatchUseItem(item, itemCount,confirmFunc)
    self._iPresenterOutput:showBatchUseItem(item, itemCount,confirmFunc)
end

function RolePresenter:showBatchUseItemConfirm(item,itemCount, onYes, onNo)
    self._iPresenterOutput:showBatchUseItemConfirm(item,itemCount, onYes, onNo)
end

function RolePresenter:showFamilyTokenItem(str, onYes, onNo)
    self._iPresenterOutput:showFamilyTokenItem(str, onYes, onNo)
end



return NewClass("RolePresenter", {IRolePresenterInput, IRoleOutput}, RolePresenter)
0
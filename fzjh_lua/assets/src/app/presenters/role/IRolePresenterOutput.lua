local interface = require("third.class.interface")

local IRolePresenterOutput = {}

function IRolePresenterOutput:popText(str)
end

function IRolePresenterOutput:richPrint(str)
end

function IRolePresenterOutput:showUseItemConfirm(item, onYes, onNo)
end

function IRolePresenterOutput:showUseXiSuiDanConfirm(item, extraDesc, onYes, onNo)
end

function IRolePresenterOutput:showDrinkConfirm(onXiaoKou, onDaKou)
end

function IRolePresenterOutput:showLearnChangShengJueYin(onConfirm, onCancel)
end

function IRolePresenterOutput:showLearnChangShengJueYang(onConfirm, onCancel)
end

function IRolePresenterOutput:delayTextPrint(delayTime, text)
end

function IRolePresenterOutput:showJunQingMiHanConfirm(onDestroy, onCancel)
end

function IRolePresenterOutput:showShiHeUse(dinnerName,dinnerValue,textList)
end

function IRolePresenterOutput:showShiWuDuiHuan(okFunc)
end

function IRolePresenterOutput:showAttrChangePopText(role, attrName, attrValue, delayTime)
end

function IRolePresenterOutput:showBatchUseItemConfirm(item,itemCount, onYes, onNo)
end

function IRolePresenterOutput:showBatchUseItem(item, itemCount,confirmFunc)
end

function IRolePresenterOutput:showFamilyTokenItem(str, onYes, onNo)
end


return interface("IRolePresenterOutput", IRolePresenterOutput)
0000000
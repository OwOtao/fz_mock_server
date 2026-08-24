local interface = require("third.class.interface")

local IRoleOutput = {}

function IRoleOutput:popText(str)
end

function IRoleOutput:richPrint(str)
end

function IRoleOutput:showUseItemConfirm(item, onYes, onNo)
end

function IRoleOutput:showUseXiSuiDanConfirm(item, extraDesc, onYes, onNo)
end

function IRoleOutput:showDrinkConfirm(onXiaoKou, onDaKou)
end

function IRoleOutput:showLearnChangShengJueYin(onConfirm, onCancel)
end

function IRoleOutput:showLearnChangShengJueYang(onConfirm, onCancel)
end

function IRoleOutput:delayTextPrint(delayTime, text)
end

function IRoleOutput:showJunQingMiHanConfirm(onDestroy, onCancel)
end

function IRoleOutput:showShiHeUse(dinnerName,dinnerValue,textList)
end

function IRoleOutput:showShiWuDuiHuan(okFunc)
end

function IRoleOutput:showAttrChangePopText(role, attrName, attrValue, delayTime)
end

function IRoleOutput:showBatchUseItem(item, itemCount,confirmFunc)
end

function IRoleOutput:showBatchUseItemConfirm(item,itemCount, onYes, onNo)
end

function IRoleOutput:showFamilyTokenItem(str, onYes, onNo)
end


return interface("IRoleOutput", IRoleOutput)
000000000
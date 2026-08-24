local NewClass = require("third.class.NewClass")
local IRolePresenterOutput = require("app.presenters.role.IRolePresenterOutput")
local RolePresenter = require("app.presenters.role.RolePresenter")

-- local RoleGlobalLayer = class("RoleGlobalLayer", cc.Layer)
local RoleGlobalLayer = {}

function RoleGlobalLayer:create(iRoleInputModel)
    local p = RoleGlobalLayer.new()
    p:init(iRoleInputModel)
    return p
end

function RoleGlobalLayer:init(iRoleInputModel)
    self._iRolePresenterInput = RolePresenter:create(self, iRoleInputModel)
end

function RoleGlobalLayer:popText(str)
    PopText(str)
end

function RoleGlobalLayer:richPrint(str)
    RichPrint("main", str)
end

-- @desc 使用物品确认
function RoleGlobalLayer:showUseItemConfirm(item, onYes, onNo)
    local desc, str = tostring(item.dsc), "将消耗一" .. tostring(item.unit) .. tostring(item.name) .. "，是否确定？", ""
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    dialog:show(desc, str)
    dialog:setRichText(desc)
    dialog:setButton1("是", onYes)
    dialog:setButton2("否", onNo)
end

-- @desc 使用洗髓丹确认
function RoleGlobalLayer:showUseXiSuiDanConfirm(item, extraDesc, onYes, onNo)
    local desc, str = tostring(item.dsc), "将消耗一" .. tostring(item.unit) .. tostring(item.name) .. "，是否确定？"
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    dialog:show(desc, str)
    dialog:setExtraDescVisible(true)
    dialog:setExtraDesc(extraDesc)
    dialog:setRichText(desc)
    dialog:setButton1("是", onYes)
    dialog:setButton2("否", onNo)
end

-- @desc 喝酒
function RoleGlobalLayer:showDrinkConfirm(onYes, onNo)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    dialog:show("面对醇香的菊花酒，你决定")
    dialog:setButton1("小口抿", onYes)
    dialog:setButton2("大口喝", onNo)
end

-- @desc 学习长生诀阴
function RoleGlobalLayer:showLearnChangShengJueYin(onConfirm, onCancel)
    local showText = "你确定要研习长生诀残篇.阴么？", "长生诀阴阳图谱只能学习其一"
    local textList = {
        "HIW你拿起这张图谱阅读了一番，上述文字精深奥妙，与之前所学一脉相传，但却又大有不同，你拿起图谱细细钻研了起来...",
        "HIW其中所载内容精深奥妙，可你已习得五篇长生诀，图谱上所述与你之前所学相互映证，你突然有所顿悟！",
        "HIW顿时，你灵台空明一片，内力真气缓缓流动，条条经脉都映入你的眼中，你已悟得【长生诀阴】"
    }
    self:__showLearnSkillBookConfirm(showText, textList, onConfirm, onCancel)
end

-- @desc 学习长生诀阳
function RoleGlobalLayer:showLearnChangShengJueYang(onConfirm, onCancel)
    local showText = "你确定要研习长生诀残篇.阳么？", "长生诀阴阳图谱只能学习其一"
    local textList = {
        "HIW你拿起这张图谱阅读了一番，上述文字精深奥妙，与之前所学一脉相传，但却又大有不同，你拿起图谱细细钻研了起来...",
        "HIW其中所载内容精深奥妙，可你已习得五篇长生诀，图谱上所述与你之前所学相互映证，你突然有所顿悟！",
        "HIW顿时，你丹田一片火热，内力真气飞速流动，待你回过神来，真气已运转了数个周天，你已悟得【长生诀阳】"
    }
    self:__showLearnSkillBookConfirm(showText, textList, onConfirm, onCancel)
end

-- @desc 学习书籍确认界面
function RoleGlobalLayer:__showLearnSkillBookConfirm(showText, textList, onConfirm, onCancel)
    local Dialog = require("app.views.layer.DialogLayer.DialogALayer")
    local dialogA = Dialog:getInstance()

    dialogA:show(showText)
    dialogA:setButton1(
        "确定",
        function()
            local TIME = 1.5
            for i = 1, #textList do
                MainControllLayer:delayFunc(
                    0 + (i - 1) * TIME,
                    function()
                        self:richPrint(textList[i])
                    end
                )

                if i == #textList then
                    MainControllLayer:delayFunc(
                        0 + (i) * TIME,
                        function()
                            onConfirm()
                        end
                    )
                end
            end
        end
    )

    dialogA:setButton2("取消", onCancel)
    dialogA:setBack(false)
end

--延时文本输出
function RoleGlobalLayer:delayTextPrint(delayTime, text)
    MainControllLayer:delayFunc(
        delayTime,
        function()
            self:richPrint(text)
        end
    )
end

--军情密函使用
function RoleGlobalLayer:showJunQingMiHanConfirm(onDestroy, onCancel)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show("确定要毁掉这封密函吗？")
    dialog:setBack(false)
    dialog:setButton1("销毁", onDestroy)
    dialog:setButton2("取消", onCancel)
end

--食盒使用
function RoleGlobalLayer:showShiHeUse(dinnerName, dinnerValue, textList)
    self:__showGlobalShadeLayer()
    local TIME = 2
    for i = 1, #textList do
        MainControllLayer:delayFunc(
            0 + (i - 1) * TIME,
            function()
                self:richPrint(textList[i])
                if i == #textList then
                    if dinnerName and dinnerValue then
                        self:richPrint(dinnerName .. " ：" .. dinnerValue)
                    end
                    self:__hideGlobalShadeLayer()
                end
            end
        )
    end
end

function RoleGlobalLayer:__showGlobalShadeLayer()
    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:showLayer()
            layer:setPopText("你正在干别的事情。")
        end
    )
end

function RoleGlobalLayer:__hideGlobalShadeLayer()
    PopupLayerController:hideLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:hideLayer()
        end
    )
end

-- @desc 弹出显示
function RoleGlobalLayer:showAttrChangePopText(role, attrName, attrValue, delayTime)
    if delayTime == nil then
        delayTime = 0
    end

    MainControllLayer:delayFunc(
        delayTime,
        function()
            if attrName == nil or attrValue == nil then
                return
            end

            local text = role:getCHAttrName(attrName)
            if attrName == "qiPercent" then
                if role:getAttr("onlyId") == User:getRoleAttr("onlyId") then
                    text = "你的伤势好了不少，伤势回复"
                else
                    text = role:getAttr("name") .. "的伤势好了不少，伤势回复"
                end
                if attrValue <= 1 then
                    attrValue = math.floor(attrValue * role:getFinalAttr("qiMax"))
                end
            end

            if text ~= nil and tonumber(attrValue) ~= nil then
                if tonumber(attrValue) > 0 then
                    PopText(tostring(text) .. " + " .. tostring(attrValue))
                elseif tonumber(attrValue) < 0 then
                    PopText(tostring(text) .. " - " .. tostring(math.abs(attrValue)))
                else
                end
            end
        end
    )
end
--实物兑换
function RoleGlobalLayer:showShiWuDuiHuan(okFunc)
    local EntityLotteryLayer = require("app.views.layer.ActionLayer.EntityLotteryLayer")
	local dialog = EntityLotteryLayer:getInstance()
	dialog:showLayer()
    dialog:setPanelOneButtons(function()
        if okFunc then
            okFunc()
        end
	end)
end

-- @desc 批量使用物品界面
function RoleGlobalLayer:showBatchUseItem(item, itemCount,confirmFunc)
    PopupLayerController:showLayer("BatchProcessLayer",function(layer)
		layer:showLayer()
		layer:setInitNum(1)
		layer:setMinNum(1)
		layer:setMaxNum(Helper:getDef(itemCount,1))
		layer:setTextDesc(item.name)
		layer:setTextDesc4("选择你要使用的数量")
		layer:setButtonConfirm(function(batchUseNum)
			print("使用数量 = ",batchUseNum)
			if confirmFunc then
				confirmFunc(batchUseNum)
			end
		end)
	end)
end

-- @desc 批量使用物品确认
function RoleGlobalLayer:showBatchUseItemConfirm(item,itemCount, onYes, onNo)
    local desc, str = tostring(item.dsc), "将消耗".. Helper:numberCast(itemCount) .. tostring(item.unit) .. tostring(item.name) .. "，是否确定？", ""
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    dialog:show(desc, str)
    dialog:setRichText(desc)
    dialog:setButton1("是", onYes)
    dialog:setButton2("否", onNo)
end

--师门信物使用确认
function RoleGlobalLayer:showFamilyTokenItem(str, onYes, onNo)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

    dialog:show(str)
    dialog:setBack(false)
    dialog:setButton1("是", onYes)
    dialog:setButton2("否", onNo)
end



return NewClass("RoleGlobalLayer", {IRolePresenterOutput}, RoleGlobalLayer)
0000
local TuJianMenuLayer = class("TuJianMenuLayer", cc.Layer)
local TuJianUtil = require("app.models.TuJian.TuJianUtil")

function TuJianMenuLayer:create()
	local p = TuJianMenuLayer:new()
	p:init()
	return p
end

function TuJianMenuLayer:init()
	self._round = require("Layer/TuJianUI/tuJianUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)
end

function TuJianMenuLayer:showLayer()
    self:setTextDsc()
    self:setXinDeDsc()
    self:setReadTuJianButton()
    self:setSkillStateText()
    self:setTipsDsc()
	self:show()
end


function TuJianMenuLayer:setTextDsc()
    local text = "你根据百晓生写下的《武学图鉴总谱》，自己拟了一本《武学图鉴》用于记载闯荡江湖时所见过的武学招式。因为经常翻阅，书皮看起来有些破旧了。"
	self.Text_dsc:setString(text)
end

function TuJianMenuLayer:setXinDeDsc()
    local dsc,dsc1= "",""

    local finalScore = 0
    local maxScore = 0
    local maxIndex
	local tujianIndexArray = TuJianUtil:getTujianIndexArray()
    for i ,v in ipairs(tujianIndexArray) do
        finalScore = finalScore + TuJianUtil:getWuXueScore(v)

        if TuJianUtil:getWuXueScore(v) >= maxScore then
            maxScore = TuJianUtil:getWuXueScore(v)
            maxIndex = v
        end
    end 

    local dscList = TuJianUtil:getTujianDscList()

    for i, v in ipairs(dscList) do
        if finalScore >= v.score then
            dsc = v.dsc
            dsc1 = v.dsc1
        end
    end

    self.Text_xinde:setString(dsc)
    self.Text_2:setString(dsc1)

    local text1 = TuJianUtil:getTextArry(maxIndex,maxScore).wxtexts
    -- print("maxIndex",maxIndex,"maxScore",maxScore,"text1 = ",text1)
    self.Text_3:setFontSize(40)
    self.Text_1:setString(Helper:getDef(TuJianUtil:getTextArry(maxIndex,maxScore).wxtexts,""))
    self.Text_3:setString(Helper:getDef(TuJianUtil:getTextArry(maxIndex,maxScore).wxtstext,""))
end

function TuJianMenuLayer:setReadTuJianButton()
    self.Button_tujian:releaseFunc(function()
        Audio:playEffect("xiaoAnNiu")
        MainControllLayer:pushLayer("TuJianInFoLayer")
        local layer = MainControllLayer:getLayer("TuJianInFoLayer")
        local TitleLayer = MainControllLayer:getLayer("TitleLayer")
        TitleLayer:setLayerTitleName("TuJianInFoLayer","武学图鉴")
        local tujianList = TuJianUtil:getTuJianTable()
        layer:showLayer(tujianList)
    end)
end

function TuJianMenuLayer:setSkillStateText()
    local role = User:getRole()
    local text1,text2,text3,text4 = "","","",""
    text1 = tostring(TuJianUtil:getSeeWuXueNum())
    text2 = tostring(TuJianUtil:getSeeZhiShiNum())
    text3 = tostring(TuJianUtil:getZhangWoWuXueNum())
    text4 = tostring(#TuJianUtil:getRoleSkillsTable()["zhishi"])

    self.Text_jianwen1:setString(text1)
    self.Text_jianwen3:setString(text2)
    self.Text_zhangwo1:setString(text3)
    self.Text_zhangwo3:setString(text4)
end

function TuJianMenuLayer:setTipsDsc()
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show("WHT江湖公认的武学评价，是依据百晓生《武学图鉴总谱》中的体系划分，共五层，以个人掌握的各类武学熟练度总和为判断。这五层分别是：\n一层：武林拾慧\n二层：武海泛舟\n三层：独步武林\n四层：武学巨擘\n五层：武道宗师NOR")
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

Helper:classDefNodeGetInstance(TuJianMenuLayer)
return TuJianMenuLayer00000000
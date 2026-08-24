local InheritConfirmLayer = class("InheritConfirmLayer", LayerEx)

function InheritConfirmLayer:create()
    local p = InheritConfirmLayer:new()
    p:init()
    return p
end

function InheritConfirmLayer:init()
    self._UI = require("Layer/InheritUI/InheritConfirmUI.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUIByParent(self)
    self:setShowAndHideAnimType("ROLL")

    self.EditBoxInput = nil
    self.EditBoxStrs = ""
    self.isEditing = false

    -- 转生次数对应奖励属性点总和上限
    local point = 0
    local inheritCount = User:getRoleAttr("inheritCount")
    if inheritCount == 0 then
        point = 30
    elseif inheritCount == 1 then
        point = 40
    elseif inheritCount >= 2 then
        point = 50
    end

    local role = User:getRole()

    self.Text_desc:setString("你的继承人各方面的能力已经是同辈中的佼佼者了，你确定要将衣钵传给你的继承人吗？\n传承后你自身将退隐江湖，取而代之的是你的继承人，\n你的继承人将开始闯荡江湖，且先天资质更高，成长速度更快了，\n你对继承人的培养使" .. role:getHeOrHer(role:getAttr("inherit").sex) .. "初入江湖时便有些基本武功防身，读书识字也有些基础，无须太过担心。同时你的颜值，福缘，金钱，背包及仓库中的家当，江湖阅历，神兵，江湖名士腰牌，包月分身符，均可传承给继承人。")

    self:setButton()
    self:setEditBox()
end

function InheritConfirmLayer:setEditBox()
    self.EditBoxStrs = ""

    if self.EditBoxInput == nil then
        local size = self.EditBox:getContentSize()
        self.EditBoxInput = ccui.EditBox:create(size, "请输入")

        self.EditBoxInput:setInputMode(1)
        self.EditBoxInput:setInputFlag(3)
        self.EditBoxInput:setReturnType(1)
        self.EditBoxInput:setFontSize(62)
        self.EditBoxInput:setPlaceholderFontSize(54)
		self.EditBoxInput:setPlaceholderFontName("Font/default.ttf")

        self.EditBox:getParent():addChild(self.EditBoxInput)
        self.EditBoxInput:setPosition(self.EditBox:getPositionX(), self.EditBox:getPositionY())

        self.EditBoxInput:onEditHandler(function(event)
            local eventName = event.name
            local eventTarget = event.target

            if eventName == "began" then
                self.isEditing = true
            elseif eventName == "changed" then
                if not device.platform == "android" then 
                    self.isEditing = true
                end
                self.EditBoxStrs = self.EditBoxInput:getText()
            elseif eventName == "return" then
                self.isEditing = false
            end
        end)
    end
end

function InheritConfirmLayer:setButton()
    self.Panel_back:releaseFunc(function()
	if device.platform == "android" then	
	elseif device.platform == "ios" then
		if self.isEditing == true then
			return
		end
    elseif device.platform == "windows" then
        if self.isEditing == true then
            return
        end
	else
	end
        PopupLayerController:hideLayer("InheritConfirmLayer", function(layer)
            self:hide()
        end)
    end)

    self.Button_1:releaseFunc(function()
        Audio:playEffect("xiaoAnNiu")
	if device.platform == "android" then	
	elseif device.platform == "ios" then
		if self.isEditing == true then
			return
		end
    elseif device.platform == "windows" then
        if self.isEditing == true then
            return
        end
	else
	end
        if self.Text_desc:isVisible() then
            if self:checkCanInherit() then
                self:hideDesc()
            end
        else
            if self.EditBoxStrs == "确定" then
                self.bg:setVisible(true)
                self.EditBoxInput:setText("")
                if self:checkCanInherit() then
                    PopupLayerController:hideLayer("InheritConfirmLayer", function(layer)
                        self:hide()
                    end, 0)

                    local ImprintingInherit = require("app.models.Meridian.Inherit.ImprintingInherit"):create(User:getRole())

                    if ImprintingInherit:needSelectMeridianImprintingForInherit() then
                        PopupLayerController:showLayer("MeridianInheritPresenter", function(presenter)
                            local ui = require("app.views.ui.Meridian.MeridianInheritUI"):create()
                            presenter:setInput(ImprintingInherit)
                            presenter:setUI(ui)
                            presenter:showPresenter()
                        end)
                    else
                        ImprintingInherit:initInheritDefaultSelectMeridianImprintingData()
                        ImprintingInherit:inherit()
                    end
                else
                    end
            else
                PopText("输入错误")
            end
        end
    end)

    self.Button_2:releaseFunc(function()
        Audio:playEffect("xiaoAnNiu")
        if self.isEditing == true then
            return
        end
        PopupLayerController:hideLayer("InheritConfirmLayer", function(layer)
            self:hide()
        end)
    end)
end

-- 检测是否能传承
function InheritConfirmLayer:checkCanInherit()
    local inherit = User:getRoleAttr("inherit")
    -- physique = 0,			-- 体质
    -- physiqueMax = 100,		-- 体质最大值
    -- noema = 0,				-- 心智
    -- noemaMax = 100,			-- 心智最大值
    -- morality = 0,			-- 德行
    -- moralityMax = 100,		-- 德行最大值
    -- temperament = 0,			-- 气质
    -- temperamentMax = 100,	-- 气质最大值
    if inherit.physique < inherit.physiqueMax or inherit.noema < inherit.noemaMax or inherit.morality < inherit.moralityMax or inherit.temperament < inherit.temperamentMax then
        PopText("能力未满，无法传承")
        return false
    end
    if inherit.intimacy < 37 then
        PopText("亲近度不足，无法传承")
        return false
    end
    return true
end

function InheritConfirmLayer:showDesc()
    self.bg:setVisible(false)
    self.Text_desc:setVisible(true)

    self.Text_desc1:setVisible(false)
    self.Text_1:setVisible(false)
    self.EditBox:setVisible(false)
    self.EditBoxInput:setVisible(false)


    if self.EditBoxInput ~= nil then
        self.EditBoxInput:setText("")
        self.EditBoxStrs = ""
    end
end

function InheritConfirmLayer:hideDesc()
    self.bg:setVisible(false)
    self.Text_desc:setVisible(false)

    self.Text_desc1:setVisible(true)
    self.Text_1:setVisible(true)
    self.EditBox:setVisible(true)
    self.EditBoxInput:setVisible(true)
end

Helper:classDefNodeGetInstance(InheritConfirmLayer)

return InheritConfirmLayer
000000
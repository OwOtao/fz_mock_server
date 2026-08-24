local class = require("third.class.NewClass")

local DreamMapRoleInfoPresenter = {}

function DreamMapRoleInfoPresenter:create()
    local p = DreamMapRoleInfoPresenter.new()
    return p
end

function DreamMapRoleInfoPresenter:setInput(iRoleAttrModel)
    self.__input = iRoleAttrModel
end

function DreamMapRoleInfoPresenter:setUI(ui)
    self.__ui = ui
end

function DreamMapRoleInfoPresenter:showPresenter()
    PopupLayerController:showLayer("DreamMapRoleInfoUI",function(ui)
		self:setUI(ui)

        self:__setImageHead()

        self:__setEmotion()
        
        self.__ui:setTextName(self.__input:getName())

        self.__ui:setTextBirth(self.__input:getBirth())

        self.__ui:setTextSex(self.__input:getSex())

        self.__ui:setTextAge(self.__input:getAge())

        self.__ui:setTextLv(self.__input:getLv())

        self.__ui:setTextCurrency(self.__input:getCurrency())
        
        self.__ui:scheduleUnique(
            function(elapsed)
                self:__refreshRoleAttr()
            end,
            0,
            "roleInfoSchedule"
        )

		self.__ui:showUI()
	end)
end

function DreamMapRoleInfoPresenter:__setEmotion()
    self.__ui:setTextEmotion(self.__input:getEmotion())
end

function DreamMapRoleInfoPresenter:__setImageHead()
	local imagePath = User:getRole():getDreamSystem():getDreamRoleFaceImagPath(self.__input:getRole())

	local present = require("app.presenters.HeadView.HVIPresent"):create(self.__ui:getImageHead(),{path = imagePath})
    
    present:showHead()
end

function DreamMapRoleInfoPresenter:__refreshRoleAttr()
    local qi = Helper:mathFloor(self.__input:getRole():getNumAttr("qi"))

    local currQiMax = Helper:mathFloor(self.__input:getRole():getCurrQiMax())
    
    local qiMax = Helper:mathFloor(self.__input:getRole():getFinalAttr("qiMax"))

    local qiPercent = (qi / qiMax) * 100

    local neili = Helper:mathFloor(self.__input:getRole():getNumAttr("neili"))

    local neiliMax = Helper:mathFloor(self.__input:getRole():getFinalAttr("neiliMax"))

    local neiliPercent = (neili / neiliMax) * 100

    local qiMaxPercent = Helper:mathFloor(self.__input:getRole():getAttr("qiPercent") * 100)

    self.__ui:setTextQi(qi .. "/" .. currQiMax .. "(" .. Helper:mathFloor(self.__input:getRole():getAttr("qiPercent") * 100) .. "%)")

    self.__ui:setTextNeiLi(neili .. "/" .. neiliMax .. "(" .. self.__input:getRole():getNumAttr("jiaLi") .. ")")

    self.__ui:setQiPercent(qiPercent)

    self.__ui:setQimaxPercent(qiMaxPercent)

    self.__ui:setNeiLiPercent(neiliPercent)
end

function DreamMapRoleInfoPresenter:hidePresenter()
    PopupLayerController:hideLayer("DreamMapRoleInfoUI",function(ui)
        ui:unscheduleWithTag("roleInfoSchedule")

		ui:hideUI()
	end)
end

return class("DreamMapRoleInfoPresenter", {}, DreamMapRoleInfoPresenter)
0
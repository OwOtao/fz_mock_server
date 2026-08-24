local class = require("third.class.NewClass")

local ChallengeMapRoleInfoPresenter = {}

function ChallengeMapRoleInfoPresenter:create()
    local p = ChallengeMapRoleInfoPresenter.new()
    return p
end

function ChallengeMapRoleInfoPresenter:setOutput(iRoleInfoView)
    self.__output = iRoleInfoView
end

function ChallengeMapRoleInfoPresenter:setInput(iRoleInfoModel)
    self.__input = iRoleInfoModel
end

function ChallengeMapRoleInfoPresenter:setRole(role)
    self.__input:setRole(role)
end

function ChallengeMapRoleInfoPresenter:showRoleInfoPanel()
    self.__output:initRoleInfoPanel()

    local role = self.__input:getRole()

    local neili, neiliMax = role:getNumAttr("neili"), Helper:mathFloor(role:getFinalAttr("neiliMax"))

    local neiliValue = neili .. "/" .. neiliMax .. "(" .. role:getNumAttr("jiaLi") .. ")"

    local neiliPercent = (neili / neiliMax) * 100

    local qi, currQiMax, qiMax = role:getNumAttr("qi"), role:getCurrQiMax(), Helper:mathFloor(role:getFinalAttr("qiMax"))

    local qiValue = qi .. "/" .. Helper:mathFloor(currQiMax) .. "(" .. Helper:mathFloor(role:getAttr("qiPercent") * 100) .. "%)"

    local qiValuePercent = (qi / qiMax) * 100

    local qiPercent = Helper:mathFloor(role:getAttr("qiPercent") * 100)

    self.__output:setRoleNeiLiValue(neiliValue)
    self.__output:setRoleNeiLiPercent(neiliPercent)
    self.__output:setRoleQiMaxPercent(qiPercent)
    self.__output:setRoleQiValue(qiValue)
    self.__output:setRoleQiPercent(qiValuePercent)

    self:__setRoleAge()
    self:__setRoleExp()
    self:__setRoleFamily()
    self:__setRoleLv()
    self:__setRoleName()
    self:__setDaZuo()
    self:__setHuiFu()
    self:__setLiaoShang()
end

function ChallengeMapRoleInfoPresenter:__setRoleName()
    local chengHao = self.__input:getRoleChengHao()
    local name = self.__input:getRoleName()

    self.__output:setRoleName(chengHao.." "..name)
end

function ChallengeMapRoleInfoPresenter:__setRoleFamily()
    local familyName = self.__input:getRoleFamilyName()

    self.__output:setRoleFamily("【门派】"..familyName)
end

function ChallengeMapRoleInfoPresenter:__setRoleExp()
    local exp = self.__input:getRoleExp()

    self.__output:setRoleExp("经验："..tostring(math.floor(exp)))
end

function ChallengeMapRoleInfoPresenter:__setRoleLv()
    local lv = self.__input:getRoleLv()

    self.__output:setRoleLv("等级："..tostring(lv))
end

function ChallengeMapRoleInfoPresenter:__setRoleAge()
    local age = self.__input:getRoleAgeDesc()

    self.__output:setRoleAge("年龄："..tostring(age))
end

function ChallengeMapRoleInfoPresenter:__setDaZuo()
    local isDaZuo = self.__input:getRoleIsDaZuo()
    if isDaZuo then
        self.__output:setButtonName(3,"正在打坐")
    else
        self.__output:setButtonName(3,"打坐")
    end

    self.__output:setButtonTouchEnable(3,true)
    self.__output:setButtonVisible(3,true)
    self.__output:setButtonFunc(3,function()
        local canDaZuo,msg = self.__input:checkCanDaZuo()
        if canDaZuo then
            self.__input:startDaZuo()
            self.__input:daZuo()
            
            self.__output:startDaZuo()
            self.__output:setDaZuoFunc(function()
                self.__input:daZuo()
            end)
        else
            self.__output:popText(Helper:getDef(msg,""))
        end
    end)
end

function ChallengeMapRoleInfoPresenter:__setHuiFu()
    self.__output:setButtonName(1,"回复气血")
    self.__output:setButtonTouchEnable(1,true)
    self.__output:setButtonVisible(1,true)
    self.__output:setButtonFunc(1,function()
        if self.__output.__huiFuTime then
            return
        end

        local canHuiFu,msg = self.__input:checkCanHuiFu()

        if canHuiFu then
            self.__input:huiFu()
            self.__output:startHuiFu()
        else
            self.__output:popText(Helper:getDef(msg,""))
        end
    end)
end

function ChallengeMapRoleInfoPresenter:__setLiaoShang()
    self.__output:setButtonName(2,"疗伤")
    self.__output:setButtonTouchEnable(2,true)
    self.__output:setButtonVisible(2,true)
    self.__output:setButtonFunc(2,function()
        if self.__output.__liaoShangTime then
            return
        end

        local canLiaoShang,msg = self.__input:checkCanLiaoShang()

        if canLiaoShang then
            self.__input:liaoShang()
            self.__output:startLiaoShang()
        else
            self.__output:popText(Helper:getDef(msg,""))
        end
    end)
end

return class("ChallengeMapRoleInfoPresenter", {}, ChallengeMapRoleInfoPresenter)
0000000000000
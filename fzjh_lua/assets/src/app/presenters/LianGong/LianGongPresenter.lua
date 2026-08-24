local LianGongPresenter = class("LianGongPresenter", cc.Layer)

local Role = require("app.models.role.Role")

function LianGongPresenter:create()
    local p = LianGongPresenter.new()
    p:__init()
    return p
end

function LianGongPresenter:__init()
    self.__ui = require("app.views.ui.LianGongUI.LianGongUI"):create()

    self.__ui:addTo(self)
end

function LianGongPresenter:showLayer(skillId)
    self.__lianGongSystem = User:getRole():getLianGongSystem()

    self._player = self.__lianGongSystem:getPlayer()

    self._playerLv = self._player:getLv()

    self._skillId = skillId
    
    self._skill = Skill:getSkill(skillId)

    self._skillLv = self._player:getSkillLv(skillId)

    self._exp = self._player:getSkillExp(skillId)

    self._skillLvLimit = self._player:getSkillLvLimit(self._skill.id)

    self.__lianGongSystem:setStartExp(self._exp)

    self.__lianGongSystem:setStartLvLimit(self._skillLvLimit)

    self.__lianGongSystem:setPlayerLv(self._playerLv)

    self.__callback = nil

    self._touchTime = 0

    self.__lianGongSystem:setXinShen(self._xinshen)

    self.__lianGongSystem:setSkillId(skillId)

    self.__lianGongSystem:setVariates(
        {
            csjLv = self._player:getSkillLv("changshengjueyang"),
            inheritCount = self._player:getAttr("inheritCount"),
            dsszLv = self._player:getSkillLv("dushushizi"),
            int = self._player:getFinalAttr("int")
        }
    )

    --@desc 提升后的武学等级
    self._afterSkillLv = self.__lianGongSystem:calLianGongLvLimit(self._jibenSkillLv)

    --@desc 选择提升到的武学等级
    self._addSelectSkillLv = self._afterSkillLv

    self.__lianGongSystem:setSelectLv(self._addSelectSkillLv)

    self._selectJing = self:getJingMax()

    self.__lianGongSystem:setSelectJing(self._selectJing)

    self._selectTiLi = 0

    self.__lianGongSystem:setSelectTiLi(self._selectTiLi)

    self:setTextTitle()

    self:setTextSubTitle1()

    self:setTextSubTitle2()

    self:setTextSubTitle3()

    self:setTextXinShenNum()

    self:setTextTiLiNum()

    self:setButtonConfirm()

    self:setButtonBack()

    self:setButtonXinShen()

    self:refreshButtonLv()

    self:refreshButtonJing()

    self:refreshButtonTiLi()

    self:setSelectLvText()

    self:setSelectJingNum()

    self:setSelectTiLiNum()

    self:setListView()

    self.__ui:showUI()
end

function LianGongPresenter:setXinShen(xinshen)
    self._xinshen = xinshen
end

function LianGongPresenter:setXinShenMax(xinshenMax)
    self._xinshenMax = xinshenMax
end

function LianGongPresenter:setTiLi(tili)
    self._tili = tili
end

function LianGongPresenter:setTiLiMax(tiliMax)
    self._tiliMax = tiliMax
end

function LianGongPresenter:setJiBenSkillLv(jibenSkillLv)
    self._jibenSkillLv = jibenSkillLv
end

function LianGongPresenter:setCallBack(callback)
    self.__callback = callback
end

function LianGongPresenter:refreshButtonLv()
    self:setButtonLv1()

    self:setButtonLv2()

    self:setButtonLv3()

    self:setButtonLv4()
end

function LianGongPresenter:refreshButtonJing()
    self:setButtonJing1()

    self:setButtonJing2()

    self:setButtonJing3()

    self:setButtonJing4()
end

function LianGongPresenter:refreshButtonTiLi()
    self:setButtonTiLi1()

    self:setButtonTiLi2()

    self:setButtonTiLi3()

    self:setButtonTiLi4()
end

function LianGongPresenter:getTiLiName()
    return Role:getCHAttrName("lianGongTiLi")
end

function LianGongPresenter:setTextTitle()
    self.__ui:setTextTitle("练功准备")
end

function LianGongPresenter:setTextSubTitle1()
    self.__ui:setTextSubTitle1("请选择练功武学目标等级：")
end

function LianGongPresenter:setTextSubTitle2()
    self.__ui:setTextSubTitle2("请选择加速练功消耗精力：")
end

function LianGongPresenter:setTextSubTitle3()
    self.__ui:setTextSubTitle3("请选择加速练功消耗"..self:getTiLiName().."：")
end

function LianGongPresenter:setTextXinShenNum()
    self.__ui:setTextXinShenNum("心神：" .. self._xinshen .. "/" .. self._xinshenMax)
end

function LianGongPresenter:setTextTiLiNum()
    self.__ui:setTextTiLiNum(self:getTiLiName().."：" .. self._tili .. "/" .. self._tiliMax)
end

function LianGongPresenter:getJingMax()
    return math.floor(math.min(self.__lianGongSystem:getCanSelectJingMax(),self._player:getAttr("jing")))
end

function LianGongPresenter:getTiLiMax()
    return math.floor(math.min(self.__lianGongSystem:getCanSelectTiLiMax(),self._tili))
end

function LianGongPresenter:setListView()
    local retArray = {}

    table.insert(retArray, {title = "心神：", content = self._xinshen .. "→" .. math.max(self._xinshen - self.__lianGongSystem:getCostXinShen(),0)})

    table.insert(retArray, {title = "精力：", content = math.floor(self._player:getAttr("jing")) .. "→" .. math.floor(self._player:getAttr("jing")) - self._selectJing})

    table.insert(retArray, {title = self:getTiLiName().."：", content = self._tili .. "→" .. self._tili - self._selectTiLi})

    local hour, min, sec = Helper:sec2timeDsc(self.__lianGongSystem:calLianGongTime())

    table.insert(retArray, {title = "练功时间：", content = hour .. "小时" .. min .. "分钟" .. sec .. "秒"})

    hour, min, sec = Helper:sec2timeDsc(self.__lianGongSystem:getLianGongSpeedUpTime())

    table.insert(retArray, {title = "节省时间：", content = hour .. "小时" .. min .. "分钟" .. sec .. "秒",tipVisible = true,tipText = "练功节省时间构成：\n1、精力加速节省时间\n2、长生诀(阳)节省时间\n3、"..self:getTiLiName().."加速节省时间"})

    table.insert(retArray, {title = "练功武学：", content = self._skill.name})

    table.insert(retArray, {title = "等级变化：", content = self._skillLv .. "→" .. self._player:getSkillLv(self._skillId, self.__lianGongSystem:getPredictExp())})

    table.insert(retArray, {title = "增加经验：", content = self.__lianGongSystem:getPredictExp()})

    self.__ui:setListView(retArray)
end

function LianGongPresenter:setSelectLvText()
    self.__ui:setSelectLvText(tostring(self._addSelectSkillLv))
end

function LianGongPresenter:setSelectJingNum()
    self.__ui:setSelectJingNum(tostring(self._selectJing))
end

function LianGongPresenter:setSelectTiLiNum()
    self._selectTiLi = math.min(self._selectTiLi,self:getTiLiMax())

    self.__ui:setSelectTiLiNum(tostring(self._selectTiLi))
end

function LianGongPresenter:changeLvResfesh()
    self.__lianGongSystem:setSelectLv(self._addSelectSkillLv)

    self:setSelectLvText()

    self:refreshButtonLv()
end

function LianGongPresenter:setMaxJing()
	self._selectJing = self:getJingMax()
end

function LianGongPresenter:changeJingResfesh()
    self._selectJing = math.min(self._selectJing,self:getJingMax())

    self.__lianGongSystem:setSelectJing(self._selectJing)

    self:setSelectJingNum()

    self:refreshButtonJing()
end

function LianGongPresenter:changeTiLiResfesh()
    self._selectTiLi = math.min(self._selectTiLi,self:getTiLiMax())

    self.__lianGongSystem:setSelectTiLi(self._selectTiLi)

    self:setSelectTiLiNum()

    self:refreshButtonTiLi()
end

function LianGongPresenter:createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self._touchTime < 0.3 then
            return
        end

        self._touchTime = currTime

        self:clearHandle()

        local total_time = 0

        self._handle =
            self:schedule(
            function(ft)
                total_time = total_time + ft
                if total_time > 1.25 then
                    callback()
                end
            end
        )
    end
    return retFunc
end

function LianGongPresenter:clearHandle()
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end
end

function LianGongPresenter:setButtonLv1()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "-10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("距武学目标最小值不足10级")
        end,
        canceledFunc = EMPTY_FUNC
    }
    if self._addSelectSkillLv - 10 >= self.__lianGongSystem:getLianGongSelectMinLv(self._jibenSkillLv) then
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._addSelectSkillLv - 10 < self.__lianGongSystem:getLianGongSelectMinLv(self._jibenSkillLv) then
                    self:clearHandle()
                    return
                end

                self._addSelectSkillLv = self._addSelectSkillLv - 10

                self:changeLvResfesh()

				self:setMaxJing()

                self:changeJingResfesh()

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._addSelectSkillLv = self._addSelectSkillLv - 10

            self:changeLvResfesh()

			self:setMaxJing()

            self:changeJingResfesh()

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonLv1(retData)
end

function LianGongPresenter:setButtonLv2()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "-1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("已达武学目标最小值")
        end,
        canceledFunc = EMPTY_FUNC
    }
    if self._addSelectSkillLv - 1 >= self.__lianGongSystem:getLianGongSelectMinLv(self._jibenSkillLv) then
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._addSelectSkillLv - 1 < self.__lianGongSystem:getLianGongSelectMinLv(self._jibenSkillLv) then
                    self:clearHandle()
                    return
                end

                self._addSelectSkillLv = self._addSelectSkillLv - 1

                self:changeLvResfesh()

				self:setMaxJing()

                self:changeJingResfesh()

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._addSelectSkillLv = self._addSelectSkillLv - 1

            self:changeLvResfesh()

			self:setMaxJing()

            self:changeJingResfesh()

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonLv2(retData)
end

function LianGongPresenter:checkAddLv(addLv,isPopText)
    if self._addSelectSkillLv + addLv > self._skillLvLimit then
        if isPopText then
            PopText("武学等级达到上限，无法提升武学目标等级")
        end
        return false
    end

    if self._jibenSkillLv == nil or self._addSelectSkillLv + addLv > self._jibenSkillLv + 1 then
        if isPopText then
            PopText("基本功火候未到，无法提升武学目标等级")
        end
        return false
    end

    if self._addSelectSkillLv + addLv > self._playerLv then
        if isPopText then
            PopText("实战经验不足，无法提升武学目标等级")
        end
        return false
    end

    if self.__lianGongSystem:getXinShenTime() < self.__lianGongSystem:getLianGongMinTimeByLv(self._addSelectSkillLv + addLv) then
        if isPopText then
            PopText("心神不足，无法提升武学目标等级")
        end
        return false
    end

    if self.__lianGongSystem:getLianGongMinTimeByLv(self._addSelectSkillLv + addLv) > self.__lianGongSystem:getLianGongTimeLimit() then
        if isPopText then
            PopText("已达练功最长时间，无法提升武学目标等级")
        end
        return false
    end

    if self._addSelectSkillLv + addLv > self._afterSkillLv then
        if isPopText then
            PopText("已达本次练功目标等级最大值，无法提升武学目标等级")
        end
        return false
    end

    return true
end

function LianGongPresenter:setButtonLv3()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "+1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            self:checkAddLv(1,true)
        end,
        canceledFunc = EMPTY_FUNC
    }
    if self:checkAddLv(1,false) then
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self:checkAddLv(1,true) == false then
                    self:clearHandle()
                    return
                end

                self._addSelectSkillLv = self._addSelectSkillLv + 1

                self:changeLvResfesh()

				self:setMaxJing()

                self:changeJingResfesh()

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._addSelectSkillLv = self._addSelectSkillLv + 1

            self:changeLvResfesh()

			self:setMaxJing()

            self:changeJingResfesh()

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonLv3(retData)
end

function LianGongPresenter:setButtonLv4()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "+10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            self:checkAddLv(10,true)
        end,
        canceledFunc = EMPTY_FUNC
    }
    if self:checkAddLv(10,false) then
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self:checkAddLv(10,true) == false then
                    self:clearHandle()
                    return
                end

                self._addSelectSkillLv = self._addSelectSkillLv + 10

                self:changeLvResfesh()

				self:setMaxJing()

                self:changeJingResfesh()

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._addSelectSkillLv = self._addSelectSkillLv + 10

            self:changeLvResfesh()

			self:setMaxJing()
			
            self:changeJingResfesh()

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonLv4(retData)
end

function LianGongPresenter:setButtonJing1()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "-10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("距精力消耗最小值不足10")
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectJing - 10 >= 0 then
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectJing - 10 < 0 then
                    self:clearHandle()
                    return
                end

                self._selectJing = self._selectJing - 10

                self:changeJingResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectJing = self._selectJing - 10

            self:changeJingResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonJing1(retData)
end

function LianGongPresenter:setButtonJing2()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "-1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("已达精力消耗最小值")
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectJing - 1 >= 0 then
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectJing - 1 < 0 then
                    self:clearHandle()
                    return
                end

                self._selectJing = self._selectJing - 1

                self:changeJingResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectJing = self._selectJing - 1

            self:changeJingResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonJing2(retData)
end

function LianGongPresenter:setButtonJing3()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "+1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectJing + 1 > self._player:getAttr("jing") then
        retData["endedFunc"] = function()
            PopText("精力不足，无法增加精力消耗")
        end
    elseif self._selectJing + 1 > self.__lianGongSystem:getCanSelectJingMax() then
        retData["endedFunc"] = function()
            PopText("消耗已达当前练功时长上限，无法增加精力消耗")
        end
    else
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectJing + 1 > self:getJingMax() then
                    self:clearHandle()
                    return
                end

                self._selectJing = self._selectJing + 1

                self:changeJingResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectJing = self._selectJing + 1

            self:changeJingResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonJing3(retData)
end

function LianGongPresenter:setButtonJing4()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "+10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectJing + 10 > self._player:getAttr("jing") then
        retData["endedFunc"] = function()
            PopText("精力不足，无法增加精力消耗")
        end
    elseif self._selectJing + 10 > self.__lianGongSystem:getCanSelectJingMax() then
        retData["endedFunc"] = function()
            PopText("消耗已达当前练功时长上限，无法增加精力消耗")
        end
    else
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectJing + 10 > self:getJingMax() then
                    self:clearHandle()
                    return
                end

                self._selectJing = self._selectJing + 10

                self:changeJingResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectJing = self._selectJing + 10

            self:changeJingResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonJing4(retData)
end

function LianGongPresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(
        "开始练功",
        function()
            if self.__callback then
                self.__callback()
            end

            self:hideLayer()
        end
    )
end

function LianGongPresenter:setButtonBack()
    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function LianGongPresenter:setButtonXinShen()
    self.__ui:setButtonXinShen(
        "回复心神",
        function()
            self._player:getXinShenSystem():getItemMap(function(ok, xinShenData)
                if ok then
                    self._player:getXinShenSystem():getXinShenRecoverStartTime(function(ok, recoverData)
                        if ok then
                            HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
                                if status == 200 and errcode == 0 and data.time ~= nil then
                                    SetTime(tonumber(data.time))
                                    PopupLayerController:showLayer("XinShenRecoveryPresenter",function(layer)
                                        layer:setXinShen(self._xinshen)
                                        layer:setXinShenMax(self._xinshenMax)
                                        layer:setRecoverTime(recoverData.time)
                                        layer:setRecoverItemMap(xinShenData.itemMap)
                                        layer:setCallBack(function(xinshenNum)
                                            self:setXinShen(xinshenNum)
                                            self.__lianGongSystem:setXinShen(xinshenNum)
                                            self:setTextXinShenNum()
                                            self._afterSkillLv = self.__lianGongSystem:calLianGongLvLimit(self._jibenSkillLv)
                                            self:setListView()
                                            self:refreshButtonLv()
                                        end)
                                        layer:showLayer()
                                    end)   
                                else
                                    PopText(errmsg)
                                end
                            end)
                        else
                            local msg = recoverData
                            PopText(msg)
                        end
                    end)
                else
                    PopText(data)
                end
            end)
        end
    )
end

function LianGongPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "LianGongPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function LianGongPresenter:setButtonTiLi1()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "-10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("距"..self:getTiLiName().."消耗最小值不足10")
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectTiLi - 10 >= 0 then
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectTiLi - 10 < 0 then
                    self:clearHandle()
                    return
                end

                self._selectTiLi = self._selectTiLi - 10

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectTiLi = self._selectTiLi - 10

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonTiLi1(retData)
end

function LianGongPresenter:setButtonTiLi2()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "-1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            PopText("已达"..self:getTiLiName().."消耗最小值")
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectTiLi - 1 >= 0 then
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectTiLi - 1 < 0 then
                    self:clearHandle()
                    return
                end

                self._selectTiLi = self._selectTiLi - 1

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectTiLi = self._selectTiLi - 1

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonTiLi2(retData)
end

function LianGongPresenter:setButtonTiLi3()
    local retData = {
        image = "Image/UI/AttrUI/leftgrey.png",
        title = "+1",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectTiLi + 1 > self._tili then
        retData["endedFunc"] = function()
            PopText(self:getTiLiName().."不足，无法增加"..self:getTiLiName().."消耗")
        end
    elseif self._selectTiLi + 1 > self.__lianGongSystem:getCanSelectTiLiMax() then
        retData["endedFunc"] = function()
            PopText("消耗已达当前练功时长上限，无法增加"..self:getTiLiName().."消耗")
        end
    else
        retData["image"] = "Image/UI/AttrUI/leftbright.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectTiLi + 1 > self:getTiLiMax() then
                    self:clearHandle()
                    return
                end

                self._selectTiLi = self._selectTiLi + 1

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectTiLi = self._selectTiLi + 1

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonTiLi3(retData)
end

function LianGongPresenter:setButtonTiLi4()
    local retData = {
        image = "Image/UI/AttrUI/jiali02b.png",
        title = "+10",
        titleColor = {r = 255, g = 255, b = 255},
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
        end,
        canceledFunc = EMPTY_FUNC
    }

    if self._selectTiLi + 10 > self._tili then
        retData["endedFunc"] = function()
            PopText(self:getTiLiName().."不足，无法增加"..self:getTiLiName().."消耗")
        end
    elseif self._selectTiLi + 10 > self.__lianGongSystem:getCanSelectTiLiMax() then
        retData["endedFunc"] = function()
            PopText("消耗已达当前练功时长上限，无法增加"..self:getTiLiName().."消耗")
        end
    else
        retData["image"] = "Image/UI/AttrUI/jiali02.png"
        retData["titleColor"] = {r = 19, g = 227, b = 30}
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self._selectTiLi + 10 > self:getTiLiMax() then
                    self:clearHandle()
                    return
                end

                self._selectTiLi = self._selectTiLi + 10

                self:changeTiLiResfesh()

                self:setListView()
            end
        )

        retData["endedFunc"] = function()
            self._selectTiLi = self._selectTiLi + 10

            self:changeTiLiResfesh()

            self:setListView()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonTiLi4(retData)
end

Helper:classDefNodeGetInstance(LianGongPresenter)
return LianGongPresenter
000000000000
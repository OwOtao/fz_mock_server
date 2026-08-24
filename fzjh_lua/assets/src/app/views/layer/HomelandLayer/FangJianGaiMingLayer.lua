local FangJianGaiMingLayer = class("FangJianGaiMingLayer", cc.Layer)
local FangQiModel = require("app.models.HomelandModel.FangQiModel")

local list = {"屋","斋", "苑", "院","轩", "阁", "楼", "府"}
local randomName1 = {"霁","栖","馨","梅","惜","岚","槿","邀","悦","懿","棠","斓","华","隐","玉","清","观","未","竹","梦","漓","知","乾","镜","雨","若"}
local randomName2 = {"萦","映","归","星","衍","心","海","风","红","樱","竹","祥","梨","静","秋","央","乾","兰","嫣","画","宁","月","合","晨"}
local COST = 500

function FangJianGaiMingLayer:create()
    local p = FangJianGaiMingLayer:new()
    p:init()
    return p
end

function FangJianGaiMingLayer:init()
    self._UI = require("Layer/HomelandUI/HomeRenameUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setVisible(false)

    self._rnum = nil --房间数量
    self._pnum = nil --仆人数量
end

function FangJianGaiMingLayer:showLayer(rnum,pnum)
    self._pnum = tonumber(pnum) or 0

    self._rnum = tonumber(rnum) or 0

    self:initLayer()
    
    self:show()
end

function FangJianGaiMingLayer:initLayer()
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")
    
    self:createEditBox()
    self:setEightButton()
    self:setEightButtonFalse()
    self:setRandNameButton()
    self:setCancelButton()
    self:setConfirmButton()
    self.Text_Dsc_2:setString("屋")
    self.Text_Dsc_1:setVisible(true)
    if fq.isRename == false then
        self.Text_Dsc_1:setString("本次改名免费")
    else
        self.Text_Dsc_1:setString("此次改名要花费"..COST.."元宝")
    end
end

function FangJianGaiMingLayer:hideLayer()
    PopupLayerController:hideLayer("FangJianGaiMingLayer",function (layer)
        self._pnum = 0
        self._rnum = 0
        layer:hide()
    end)
end

function FangJianGaiMingLayer:setRename(name)
    local namee = self.editBox:getText()
    local len = string.len(namee)
    local nameee = string.sub(namee, 1, len - 3)
    self.editBox:setText(nameee .. name)
end

function FangJianGaiMingLayer:createEditBox()
    -- self.EditBoxArea:setTouchEnabled(true)
    local editBox
    local size = self.EditBoxArea:getContentSize()
    if self.editBox == nil then
        editBox = ccui.EditBox:create(size, "请输入")
        self.editBox = editBox
        editBox:setFontName("Font/default.ttf")
        editBox:setFontSize(54)
        editBox:setVisible(true)
        editBox:setPlaceholderFontSize(54)
        editBox:setPlaceholderFontName("Font/default.ttf")
        -- 设置输入类型
        editBox:setInputMode(6)
        editBox:setReturnType(1)

        editBox:onEditHandler(
			function(event)
				local eventName = event.name
				local eventTarget = event.target

				if PRINT_MODE == 1 then
					print("eventName = " .. tostring(eventName))
					print("eventTarget = " .. tostring(eventTarget))
				end

				if eventName == "began" then
					self._isEditing = true
				elseif eventName == "changed" then
					self._editBoxString = editBox:getText()
					if PRINT_MODE == 1 then
						print("self._editBoxString = " .. tostring(self._editBoxString))
					end
				elseif eventName == "end" then
				elseif eventName == "return" then
					self._isEditing = false
				end
			end
        )
        
        self.EditBoxArea:getParent():addChild(editBox)
        editBox:setPosition(self.EditBoxArea:getPositionX(), self.EditBoxArea:getPositionY())
    end
end

function FangJianGaiMingLayer:setEightButton()

    for i = 1, #list do
        local checkbox = self.Panel_btn["CheckBox_" .. i]
        local function selectedEvent(sender, eventType)
            if eventType == ccui.CheckBoxEventType.selected then
                local name = list[i]
                local bool ,text = self:checkNameCondition(name)
                if not bool then
                    checkbox:setSelectedState(false)
                    PopText(text)
                    return
                end

                for j=1,8 do
                    if i ~= j then
                        self.Panel_btn["CheckBox_" .. j]:setSelectedState(false)
                        self.Panel_btn["CheckBox_" .. j].Text_name:setTextColor({r = 208, g = 208, b = 208})
                    end
                end
                self.Text_Dsc_2:setString(name)
                checkbox.Text_name:setTextColor({r = 80, g = 246, b = 244})
            elseif eventType == ccui.CheckBoxEventType.unselected then
                if checkbox:getSelectedState() then
                    checkbox:setSelectedState(true)
                    return
                end
                checkbox.Text_name:setTextColor({r = 208, g = 208, b = 208})
            end
        end
        checkbox:addEventListenerCheckBox(selectedEvent)
    end
end

function FangJianGaiMingLayer:setEightButtonFalse()
    for i = 1, #list do
        local checkbox = self.Panel_btn["CheckBox_" .. i]
        if i == 1 then
            checkbox:setSelectedState(true)
            checkbox.Text_name:setTextColor({r = 80, g = 246, b = 244})
        else
            checkbox:setSelectedState(false)
            checkbox.Text_name:setTextColor({r = 208, g = 208, b = 208})
        end
    end
end

function FangJianGaiMingLayer:setRandNameButton(fangwu)
    self.Button_randomName:releaseFunc(
        function()
            if self.editBox ~= nil and self._isEditing ~= true then
                local num1 = math.random(1,#randomName1)
                local num2 = math.random(1,#randomName2)
                local name = randomName1[num1]..randomName2[num2]
                print("============================================随机名字",name)
                self.editBox:setText(name)
            end
        end
    )
end

function FangJianGaiMingLayer:setConfirmButton()
    self.Button_1:releaseFunc(
        function()
            self._editBoxString = self.editBox:getText()
            local name = self._editBoxString .. self.Text_Dsc_2:getString()

            local function rename(mid, point)
                HttpManagerEx:renameHome(
                    mid,
                    name,
                    point,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                local data = {houseName = name, isRename = true}
                                FangQiModel:updateInfo(data)
                                PopText("改名成功")
                                self:hideLayer()
                            else
                                print(errcode)
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING 
                )
            end

            if self:checkName(name) then
                local role = User:getRole()
                local fq = role:getHomelandAttr("fq")
                if fq.isRename then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()

                    dialog:hide()
                    dialog:show("此次改名将消耗" .. COST .. "元宝，你确定吗？")
                    dialog:setBack(false)
                    dialog:setButton1(
                        "确定",
                        function()
                            rename(fq.mid, COST)
                        end
                    )
                    dialog:setButton2(
                        "取消",
                        function()
                        end
                    )
                else
                    rename(fq.mid, 0)
                end
            else
            end
        end
    )
end

function FangJianGaiMingLayer:setCancelButton()
    self.Button_2:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function FangJianGaiMingLayer:checkName(name)
    local len = string.len(self._editBoxString)
    if self._editBoxString == nil or self._editBoxString == "" then
        PopText("名字不能为空!!!")
        return false
    end

    if not Helper:isChinese(self._editBoxString) then
        PopText("名字必须是中文!!!")
        return false
    end

    if Helper:isMaskOff(self._editBoxString) or Helper:isMaskOff(name) then
        -- PopText("名字包含不合法字符!!")
        PopText(tostring(self._editBoxString) .. " 是非法词汇，请更换后再试。")
        return false
    end

    -- 一个 utf－8的中文字，占3个字节
    if string.len(self._editBoxString) > 4 * 3 then
        if PRINT_MODE == 1 then
            print("string.len(self._editBoxString) = " .. tostring(string.len(self._editBoxString)))
        end
        PopText("名字最多四个字")
        return false
    end

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local fqStatus = role:getHouseStatus()

    if fqStatus ~= 1 then
        PopText("请先搬家，正式入住了再改名！")
        return false
    end
    

    return true
end

function FangJianGaiMingLayer:showTouchSwallowLayer()
    if self._touchSwallowLayer == nil then
        self._touchSwallowLayer = ccui.Widget:create()
        self._touchSwallowLayer:ignoreContentAdaptWithSize(false)
        self:addChild(self._touchSwallowLayer, 10)
        self._touchSwallowLayer:setSize(1080, 1920)
        self._touchSwallowLayer:setAnchorPoint(cc.p(0, 0))
    end
    self._touchSwallowLayer:setTouchEnabled(true)
end

-- 隐藏触摸遮盖层
function FangJianGaiMingLayer:hideTouchSwallowLayer()
    if self._touchSwallowLayer == nil then
        return
    end
    self._touchSwallowLayer:setTouchEnabled(false)
end


function FangJianGaiMingLayer:checkNameCondition(name)

    local bool, msg = true, ""

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local roomnum = self._rnum

    local roomCount = roomnum

    bool,msg = switch(
        name,
        {
            ["苑"] = function()
                if roomCount > 10 then
                    return true
                end
                return false,"您的房屋房间数量还不够多，无法使用该后缀！"
            end,
            ["院"] = function()
                if roomCount > 15 then
                    return true
                end
                return false,"您的房屋房间数量还不够多，无法使用该后缀！"
            end,
            ["轩"] = function()
                if roomCount > 20 then
                    return true
                end
                return false,"您的房屋房间数量还不够多，无法使用该后缀！"
            end,
            ["阁"] = function()
                if roomCount > 30 then
                    return true
                end
                return false,"您的房屋房间数量还不够多，无法使用该后缀！"
            end,
            ["楼"] = function()
                local serCount = self._pnum

                if serCount > 8 then
                    return true
                end
                return false,"您的房屋仆人数量还不够多，无法使用该后缀！"
            end,
            ["府"] = function()
                local tb = {
                    ["yangzhou145"] = true,
                    ["yangzhou146"] = true,
                    ["yangzhou147"] = true,
                    ["yangzhou148"] = true,
                    ["yangzhou149"] = true,
                    ["yangzhou150"] = true,
                    ["yangzhou151"] = true,
                    ["yangzhou152"] = true,
                }
                local fq = role:getHomelandAttr("fq")
                if tb[fq.fqId] then
                    return true
                end

                return false,"满足特殊条件方可使用该后缀"
            end,
            default = function ()
                return true
            end
        }
    )

    return bool,msg
end


Helper:classDefNodeGetInstance(FangJianGaiMingLayer)
return FangJianGaiMingLayer
0000000000000
local InheritSetNameLayer = class("InheritSetNameLayer", require("app.views.base.BaseLayer"))

function InheritSetNameLayer:create()
    local p = InheritSetNameLayer:new()
    p:init()
    return p
end

function InheritSetNameLayer:init()
    self._UI = require("Layer/InheritUI/InheritSetNameUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.editBoxStr = ""
    self.editBox = nil
    self.isEditing = false

    -- 初始化编辑框
    local size = self.EditBoxArea:getContentSize()
    local editBox = ccui.EditBox:create(size, "请输入")
    self.EditBoxArea:getParent():addChild(editBox)
    editBox:setPosition(self.EditBoxArea:getPositionX(), self.EditBoxArea:getPositionY())

    -- 设置输入类型
    editBox:setInputMode(6)
    editBox:setReturnType(1)

    -- 注册事件监听
    editBox:onEditHandler(
        function(event)
            local eventName = event.name
            local eventTarget = event.target

            if eventName == "began" then
                self.isEditing = true
            elseif eventName == "changed" then
                self.editBoxStr = editBox:getText()
            elseif eventName == "end" then
            elseif eventName == "return" then
                self.isEditing = false
            end
        end
    )
    self.editBox = editBox

    self:setButton()
end

function InheritSetNameLayer:setInheritLayer(layer)
    self.inheritLayer = layer
end

function InheritSetNameLayer:setButton()
    self.Button_randomName:releaseFunc(
        function()
            if self.isEditing == false then
                self.editBox:setText(Helper:getRandomName(User:getRoleAttr("inherit").sex))
                self.editBoxStr = self.editBox:getText()
            end
        end
    )

    local existNameMap = {}
    self.Button_confirm:releaseFunc(
        function()
            if self.isEditing == true then
                return
            end
            if self.editBoxStr == nil or self.editBoxStr == "" then
                PopText("名字不能为空!!!")
                return
            end

            if not Helper:isChinese(self.editBoxStr) then
                PopText("名字必须是中文!!!")
                return
            end

            if Helper:isMaskOff(self.editBoxStr) then
                -- PopText("名字包含不合法字符!!")
                PopText(tostring(self.editBoxStr) .. " 是非法词汇，请更换后再试。")
                return
            end

            if existNameMap[self.editBoxStr] then
                PopText("名字已经存在")
                return
            end
            -- 一个 utf－8的中文字，占3个字节
            if string.len(self.editBoxStr) > 4 * 3 then
                PopText("名字最多四个字")
                return
            end

            HttpManagerEx:CreateHeir(
                self.editBoxStr,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("取名成功")
                            local inherit = User:getRoleAttr("inherit")
                            inherit.userid = data.userid
                            inherit.name = self.editBoxStr
                            inherit.isSetName = true
                            self:hide()
                            self.inheritLayer.ControllLayer:popLayer()
                            self.inheritLayer:setVisible(false)
                            local InheritAttrLayer = self.inheritLayer.ControllLayer:getLayer("InheritAttrLayer")
                            InheritAttrLayer:setHeadImg()
                            self.inheritLayer.ControllLayer:pushLayer("InheritAttrLayer")
                        elseif errcode == 3 then
                            local inherit = User:getRoleAttr("inherit")
                            inherit.userid = data.userid
                            inherit.name = data.name
                            inherit.isSetName = true
                            self:hide()
                            self.inheritLayer.ControllLayer:popLayer()
                            self.inheritLayer:setVisible(false)
                            local InheritAttrLayer = self.inheritLayer.ControllLayer:getLayer("InheritAttrLayer")
                            InheritAttrLayer:setHeadImg()
                            self.inheritLayer.ControllLayer:pushLayer("InheritAttrLayer")
                        else
                            PopText(errmsg)
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self.Button_cancel:releaseFunc(
        function()
            self:hide()
        end
    )

    self.Panel_back:releaseFunc(
        function()
            self:hide()
        end
    )
end

function InheritSetNameLayer:show()
    self.editBoxStr = ""
    if self.editBox ~= nil then
        self.editBox:setText("")
    end
    self.isEditing = false

    self:setVisible(true)
end

function InheritSetNameLayer:hide()
    PopupLayerController:hideLayer(
        "InheritSetNameLayer",
        function(layer)
            self:setVisible(false)
        end
    )
end

Helper:classDefNodeGetInstance(InheritSetNameLayer)

return InheritSetNameLayer
000000000000000
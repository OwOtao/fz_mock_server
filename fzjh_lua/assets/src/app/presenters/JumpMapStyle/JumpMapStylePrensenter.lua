local class = require("third.class.NewClass")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local JumpMapStyle = require("app.models.JumpMapStyle.JumpMapStyle")
local JumpMapConstants = require("app.models.JumpMapStyle.JumpMapConstants")
local UseFailureState = JumpMapConstants.UseFailureState
local UseFailureMsg = JumpMapConstants.UseFailureMsg
local JumpMapStylePrensenter = {}

function JumpMapStylePrensenter:create()
    local p = JumpMapStylePrensenter:new()
    p:init()
    return p
end

function JumpMapStylePrensenter:init()
    self._interactor = JumpMapStyle:create()
    self._ui = DialogALayer:getInstance()
end

function JumpMapStylePrensenter:setRole(role)
    assert(role, "JumpMapStylePrensenter:setRole role为空")
    self._interactor:setRole(role)
end

function JumpMapStylePrensenter:setMapId(mapId)
    assert(mapId, "JumpMapStylePrensenter:setMapId mapId为空")
    self._interactor:setMapId(mapId)
end

function JumpMapStylePrensenter:setRoomId(roomId)
    assert(roomId, "JumpMapStylePrensenter:setRoomId roomId为空")
    self._interactor:setRoomId(roomId)
end

function JumpMapStylePrensenter:setText(text)
	self._ui:setText(text)
end

function JumpMapStylePrensenter:setCallFunc(func)
    func = Helper:getDef(func, EMPTY_FUNC)
    self._callFunc = func
end

function JumpMapStylePrensenter:setButton1()
	self._ui:setButton1("自行前往", function()
        local result, failureState = self._interactor:checkCanToSelectMap()

        if result == false then
            if UseFailureMsg[failureState] then
                PopText(UseFailureMsg[failureState])
            end

            self:hideLayer()

            self._callFunc(result, failureState)
            return
        end

        local func = function(result, failureState)
            self._callFunc(result, failureState)

            self:hideLayer()
        end

        self._interactor:toSelectMapLayer(func)
    end)
end

function JumpMapStylePrensenter:setButton2()
	self._ui:setButton2("用遁地符", function()
        local result, failureState = self._interactor:checkCanUseDunDiFu()

        if result == false then
            if UseFailureMsg[failureState] then
                PopText(UseFailureMsg[failureState])
            end

            self:hideLayer()

            self._callFunc(result, failureState)
            return
        end

        local result, failureState = self._interactor:checkCanJumpMap()

        if result == false then
            if UseFailureMsg[failureState] then
                PopText(UseFailureMsg[failureState])
            end

            self:hideLayer()

            self._callFunc(result, failureState)
            return
        end

        local func = function(result, failureState)
            self._callFunc(result, failureState)

            self:hideLayer()
        end

        self._interactor:useDunDiFu(func)
    end)
end

function JumpMapStylePrensenter:setButton3()
    local skill = self._interactor:getRole():getSkill("wuxingdunfa")

    if MapIsEmpty(skill) == false then
        self._ui:setButton3("五行遁法", function()
            local result, failureState = self._interactor:checkCanUseWuXingDunFa()

            if result == false then
                if UseFailureMsg[failureState] then
                    PopText(UseFailureMsg[failureState])
                end

                self:hideLayer()

                self._callFunc(result, failureState)
                return
            end

            result, failureState = self._interactor:checkCanJumpMap()

            if result == false then
                if UseFailureMsg[failureState] then
                    PopText(UseFailureMsg[failureState])
                end

                self:hideLayer()

                self._callFunc(result, failureState)
                return
            end

            local func = function(result, failureState)
                if result then
                    RichPrint("main", "HIY你心中默念五行遁法的口诀，只见金光一闪，你已经消失不见了。")
                    self:hideLayer()
                end

                if failureState and failureState == UseFailureState.RATE_FAILURE then
                    RichPrint("main", "HIY你心中默念五行遁法的口诀，但却什么都没有发生，看来此次施术似乎是失败了。")
				    PopText("五行遁法使用失败")
                    self._ui:setVisible(true)
                end

                self._callFunc(result, failureState)
            end

            self._interactor:useWuXingDunFa(func)
        end)
    end
end

-- canHide false 点击背景不能隐藏界面  true 点击背景可以隐藏界面 默认 true
function JumpMapStylePrensenter:setBackHide(canHide)
    self._ui:setBack(canHide)
end

--[[
    @desc: 
    author:tanqinjian
    time:2026-05-21 10:17:43
    --@role: 跳转角色
	--@mapId: 跳转副本id
	--@roomId: 跳转房间
	--@text: 跳转提示文本
	--@backClick: 跳转界面背景是否可点击
	--@callFunc: 跳转回调方法
    @return:
]]
function JumpMapStylePrensenter:showLayer(role, mapId, roomId, text, backClick, callFunc)
    self._ui:show()
    self._ui:setWeChatVisible(false)
    self:setRole(role)
    self:setMapId(mapId)
    self:setRoomId(roomId)
    self:setText(text)
    self:setBackHide(Helper:getDef(backClick, true))
    self:setCallFunc(callFunc)
    self:setButton1()
    self:setButton2()
    self:setButton3()
end

function JumpMapStylePrensenter:hideLayer()
    self._ui = nil
    self._interactor = nil
    self._successFunc = nil
end

return class("JumpMapStylePrensenter", {}, JumpMapStylePrensenter)
00
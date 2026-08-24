-- 测试界面
local LogTestLayer = class("LogTestLayer", LayerEx)

local LogSystem = require("app.models.LogSystem.LogSystem")

function LogTestLayer:create()
    local p = LogTestLayer:new()
    p:init()
    
    return p
end

function LogTestLayer:init()
    self._UI = require("Layer/DebugUI/TestUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)
    self:setButton()
end

function LogTestLayer:showLayer()
    self:show()
end

function LogTestLayer:onEnable()
    self:initAllItems()
end

function LogTestLayer:onDisable()
    self:__removeAllItem()
end

function LogTestLayer:__removeAllItem()
    self.ListView:removeAllItems()
end

function LogTestLayer:initAllItems()
    self:addOpenLogSystemButton()

    self:addSetPatternPanel()

    self:addButton(
        "添加战斗日志筛选",
        function(panel)
            LogSystem:addPattern("FightLog")
            self:__removeAllItem()
            self:initAllItems()
        end
    )

    self:addButton(
        "删除战斗日志筛选",
        function(panel)
            LogSystem:removePattern("FightLog")
            self:__removeAllItem()
            self:initAllItems()
        end
    )

    self:addButton(
        "添加战斗BUFF日志筛选",
        function(panel)
            LogSystem:addPattern("增益日志.")
            self:__removeAllItem()
            self:initAllItems()
        end
    )

    self:addButton(
        "删除战斗BUFF日志筛选",
        function(panel)
            LogSystem:removePattern("增益日志.")
            self:__removeAllItem()
            self:initAllItems()
        end
    )
end

function LogTestLayer:addSetPatternPanel()
    local str

    local patterns = LogSystem:getFilterPattern()

    if #patterns > 0 then
        str = ""
        for i, v in ipairs(patterns) do
            if i == #patterns then
                str = str .. v
            else
                str = str .. v .. "|"
            end
        end
    else
        str = "打印类别1|打印类别2"
    end

    local editBox =
        self:addEditor(
        "设置过滤",
        nil,
        function(editBox, text)
            local inputText = string.trim(text)

            if inputText == nil or inputText == "" then
                PopText("请输入正确字符！！")
                return
            end

            local LogSystem = require("app.models.LogSystem.LogSystem")
            LogSystem:setFilterPattern(inputText)

            PopText("筛选类别：" .. inputText .. "，设置成功！")
        end
    )

    editBox:setText(str)
end

function LogTestLayer:addOpenLogSystemButton()
    local enable = LogSystem:getEnabled()

    local enableStr = "当前打印：开"

    local disableStr = "当前打印：关"

    local str

    if enable then
        str = enableStr
    else
        str = disableStr
    end

    self:addButton(
        str,
        function(panel)
            if LogSystem:getEnabled() then
                LogSystem:setEnabled(false)
            else
                LogSystem:setEnabled(true)
            end
            self:__removeAllItem()
            self:initAllItems()
        end
    )
end

function LogTestLayer:addButton(btnName, btnFunc)
    local panel = self.Panel:clone()
    Helper:convertUIByParent(panel)
    panel.Text_button_1:setString(btnName)
    panel.Button_1:setSize(800, 100)

    panel.Button_1:releaseFunc(
        function()
            if btnFunc then
                btnFunc(panel)
            end
        end
    )

    self.ListView:pushBackCustomItem(panel)
end

function LogTestLayer:setButton()
    self.Text_return:releaseFunc(
        function()
            self:hide(
                function()
                    self:removeFromParent(true)
                end
            )
        end
    )
end

function LogTestLayer:addEditor(name, defaultText, btnFunc)
    local panel = self.Panel_1:clone()

    Helper:convertUIByParent(panel)

    if btnFunc == nil then
        return
    end

    if defaultText == nil then
        defaultText = "请输入"
    end

    panel.Text_desc:setString(name)
    local size = panel.Image_num:getContentSize()
    local editBox = ccui.EditBox:create(size, defaultText)
    editBox:setInputMode(1)
    editBox:setInputFlag(3)
    editBox:setReturnType(1)
    editBox:setFontSize(48)
    editBox:addTo(panel)
    editBox:setPosition(panel.Image_num:getPositionX(), panel.Image_num:getPositionY())
    editBox:setTag(999)

    editBox:onEditHandler(
        function(event)
            if event.name == "return" then
            end
        end
    )

    panel.Button_back:releaseFunc(
        function()
            if btnFunc ~= nil then
                btnFunc(editBox, editBox:getText())
            end
        end
    )

    self.ListView:pushBackCustomItem(panel)

    return editBox
end

Helper:classDefNodeGetInstance(LogTestLayer)
return LogTestLayer
000
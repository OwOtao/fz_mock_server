-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/12 10:02:00
-- @desc 有进度条的按钮
local LoadingBarButton = {}

function LoadingBarButton:create()
    local p = Helper:tableCover(Resource:getUIByName("Panel_buttonWithLoadingBar_1"), LoadingBarButton)
    p:init()
    return p
end

function LoadingBarButton:init()
    Helper:convertUIByParent(self)
    
    -- 成员变量定义 add by TangJian 2017/02/24 17:05:44
    self._enable = true
    
    -- self.Text_name:setTextColor()
    self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    
    -- 默认开启进度条动画效果
    self.LoadingBar_1:setAnimEnable(true)
    
    -- 注册默认按键事件
    self:releaseFunc(function()
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:00:38
-- @desc 设置按钮上的字符串
function LoadingBarButton:setName(name)
    self.Text_name:setString(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:00:38
-- @desc 设置按钮上的字符串
function LoadingBarButton:setString(str)
    self.Text_name:setString(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:00:59
-- @desc 设置按钮的百分比
function LoadingBarButton:setPercent(percent)
    self.LoadingBar_1:setPercent(percent)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:01:11
-- @desc 设置shader模式
function LoadingBarButton:setShaderMode(mode)
    if mode == "normal" then
        self.LoadingBar_1:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteNormalShder())
    elseif mode == "gray" then
        self.LoadingBar_1:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:01:24
-- @desc 设置按钮是否可用
function LoadingBarButton:setEnable(enable)
    Helper:getDef(enable, false)
    if self._enable ~= enable then
        self._enable = enable
        if enable == true then
            self:setShaderMode("normal")
        else
            self:setShaderMode("gray")
        end
    end
end

function LoadingBarButton:setLoadingBarBgTexture(path)
    if path == nil then
        path = "Image/UI/MapUI/anniu04.png"
    end
    self.Image_huifu:loadTexture(path, 0)
end

return LoadingBarButton
000000
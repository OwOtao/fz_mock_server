local SignInPayYuanBaoLayer = class("SignInPayYuanBaoLayer", LayerEx)


function SignInPayYuanBaoLayer:create()
    local p = SignInPayYuanBaoLayer.new()
    return p
end

function SignInPayYuanBaoLayer:ctor()
    self:init()
end

function SignInPayYuanBaoLayer:init()
    local UI = require("Layer/SignInUI/SignInPayYuanBaoUI.lua").create()['root']
    self:addChild(UI)
    Helper:convertUI(self)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置描述
function SignInPayYuanBaoLayer:setItemDesc(desc)
    self.Text_desc:setTextVerticalAlignment(1)
    self.Text_desc:setString(desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置商品名称
function SignInPayYuanBaoLayer:setItemName(name)
    self.Text_itemName:setString(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置商品图片
function SignInPayYuanBaoLayer:setItemIcon(icon)
    if cc.FileUtils:getInstance():isFileExist(icon) then
        self.Image_itemIcon:loadTexture(icon)
    else
        self.Image_itemIcon:loadTexture("Image/UI/StoreUI/zhuzi.png") -- 设置为默认图标
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置分享
function SignInPayYuanBaoLayer:setShareDesc(shareDesc)
    if self.Text_notice == nil then
        return
    end
    if shareDesc then
        self.Text_notice:setVisible(true)
        self.Text_notice:setString(tostring(shareDesc))
    else
        self.Text_notice:setVisible(false)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置价格描述
function SignInPayYuanBaoLayer:setItemPrice(priceDsc)
    self.Text_price:setString(tostring(priceDsc).." 元宝")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置付费方法
function SignInPayYuanBaoLayer:setPayFunc(func)
    self.Button_pay:releaseFunc(function()
        if func then
            func()
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置取消方法
function SignInPayYuanBaoLayer:setCancelFunc(func)
    self.Button_cancel:releaseFunc(function()
            if func then
                func()
            end
    end)
end

Helper:classDefNodeGetInstance(SignInPayYuanBaoLayer)
return SignInPayYuanBaoLayer
000000